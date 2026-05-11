import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:hst_scribe/core/audio/audio_capture.dart';
import 'package:hst_scribe/core/auth/auth_providers.dart';
import 'package:hst_scribe/core/config/app_config_provider.dart';
import 'package:hst_scribe/core/contract/wss_envelope.dart';
import 'package:hst_scribe/core/contract/wss_messages.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:hst_scribe/core/wss/wss_connection.dart';
import 'package:hst_scribe/features/capture/domain/capture_state.dart';
import 'package:hst_scribe/features/capture/domain/transcript_line.dart';
import 'package:hst_scribe/features/events/data/events_controller.dart';
import 'package:hst_scribe/features/session/data/session_repository.dart';
import 'package:hst_scribe/features/session/domain/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capture_controller.g.dart';

/// Factory provider for the AudioCapture impl in use.
///
/// Tests / dev override this with [FakeAudioCapture]; production wiring
/// returns [RealAudioCapture]. Riverpod owns the disposal lifecycle.
@Riverpod(keepAlive: true)
AudioCapture audioCapture(AudioCaptureRef ref) {
  final capture = RealAudioCapture();
  ref.onDispose(() async {
    await capture.dispose();
  });
  return capture;
}

/// One WSS connection per active session_id. Owned by [CaptureController];
/// torn down on session end.
///
/// Keyed on session_id so a screen rebuild does not reconnect. The
/// connection lives for the lifetime of the session, not the screen.
///
/// Resolves a fresh bearer token from [TokenStore] before constructing
/// the connection. Returns an [AsyncValue] so the UI can render
/// `connecting` while we wait. Tests override this provider with a
/// pre-built connection backed by a fake transport.
@Riverpod(keepAlive: true)
Future<WssConnection> activeWssConnection(
  ActiveWssConnectionRef ref,
  String sessionId,
) async {
  final config = ref.read(appConfigProvider);
  final tokenStore = ref.read(tokenStoreProvider);
  final bundle = await tokenStore.read();
  if (bundle == null) {
    throw const AppFailure.unauthenticated(
      message: 'No access token available for WSS connection',
    );
  }
  // The session's wss_url may include the full path; we want only the
  // host/scheme. [CaptureController._baseUrlFromSession] computes that
  // when a Session is available; for this provider we use the global
  // wssBaseUrl as a sensible default.
  final connection = WssConnection(
    baseUrl: Uri.parse(config.wssBaseUrl),
    sessionId: sessionId,
    accessToken: bundle.accessToken,
  );
  ref.onDispose(() async {
    await connection.dispose();
  });
  return connection;
}

const AppLogger _log = AppLogger('CaptureController');

/// Owns the live capture loop for a single session.
///
/// Responsibilities:
///   * Build the WSS connection with a real bearer token.
///   * Subscribe to incoming envelopes; forward transcripts to local state
///     and `event_extracted` payloads to [EventsController].
///   * Open the mic via [AudioCapture] and forward 250ms PCM frames as
///     `audio_chunk` envelopes.
///   * Buffer the rolling last-30s of PCM for replay on reconnect.
///   * Voice commands (`confirm_last`, `strike_last`) are dispatched into
///     [EventsController].
///
/// The controller holds the WSS + AudioCapture lifecycle. Widgets read
/// `state` (a [CaptureState] + transcript snapshot via separate providers)
/// and call [startCapture] / [pausePtt] / [resumePtt] / [endSession].
@Riverpod(keepAlive: true)
class CaptureController extends _$CaptureController {
  /// Last 30s rolling buffer of outbound `audio_chunk` payloads, for
  /// CONTRACT.md §5 reconnect replay. 30s / 250ms = 120 chunks max.
  static const int _maxBufferedChunks = 120;

  // ------------ instance fields ------------

  WssConnection? _wss;
  StreamSubscription<WssEnvelope>? _wssSub;
  StreamSubscription<WssConnectionState>? _wssStateSub;
  AudioCapture? _audio;
  StreamSubscription<Uint8List>? _audioSub;
  final Queue<AudioChunkPayload> _rollingBuffer = Queue<AudioChunkPayload>();

  /// Monotonic chunk counter. Combined with the session_id + boot time
  /// to produce a unique chunk_id without pulling in a UUID dependency.
  int _chunkCounter = 0;

  bool _terminated = false;

  @override
  CaptureState build(String sessionId) {
    ref.onDispose(_teardown);
    return const CaptureState.disconnected();
  }

  // ------------ public API ------------

  /// Start (or resume after error) the capture loop.
  ///
  /// Hard preconditions:
  ///   * The active session must be in `ReadyActiveSession` state —
  ///     i.e. the patient has been confirmed. Caller's responsibility.
  ///   * Auth must be authenticated and tokens valid.
  ///
  /// Idempotent: calling while already `listening` is a no-op.
  Future<void> startCapture() async {
    if (_terminated) return;
    if (state is ListeningCaptureState) return;

    state = const CaptureState.connecting();

    final session = ref.read(activeSessionProvider);
    if (session == null || session.id != sessionId) {
      state = const CaptureState.error(
        AppFailure.unexpected(
          message: 'No active session matches capture sessionId',
        ),
      );
      return;
    }

    if (ref.read(authClaimsProvider) == null) {
      state = const CaptureState.error(
        AppFailure.unauthenticated(message: 'Not signed in'),
      );
      return;
    }

    final tokenStore = ref.read(tokenStoreProvider);
    final bundle = await tokenStore.read();
    if (bundle == null) {
      state = const CaptureState.error(
        AppFailure.unauthenticated(message: 'Auth token missing'),
      );
      return;
    }

    // (Re)build the WSS connection with the live token. The
    // [activeWssConnectionProvider] is a fallback for tests; we
    // always rebuild here so we have the freshest token.
    final config = ref.read(appConfigProvider);
    final connection = WssConnection(
      baseUrl: Uri.parse(_baseUrlFromSession(session, config.wssBaseUrl)),
      sessionId: session.id,
      accessToken: bundle.accessToken,
    );
    _wss = connection;
    _wssSub = connection.incoming.listen(
      _onWssEnvelope,
      onError: _onWssError,
      cancelOnError: false,
    );
    _wssStateSub = connection.state.listen(_onWssState);

    await connection.connect();

    // Open the mic.
    final audio = ref.read(audioCaptureProvider);
    _audio = audio;
    try {
      await audio.start();
    } on AppFailure catch (failure) {
      state = CaptureState.error(failure);
      return;
    }
    _audioSub = audio.capture().listen(
      _onAudioChunk,
      onError: _onAudioError,
      cancelOnError: false,
    );

    if (!_terminated) {
      state = const CaptureState.listening();
    }
  }

  /// Push-to-talk released. Pauses the mic; WSS stays open.
  Future<void> pausePtt() async {
    if (state is! ListeningCaptureState) return;
    await _audio?.pause();
    _sendMarker(WssMessageType.sessionPause);
    state = const CaptureState.paused();
  }

  /// Push-to-talk pressed again. Resumes the mic.
  Future<void> resumePtt() async {
    if (state is! PausedCaptureState) return;
    await _audio?.resume();
    _sendMarker(WssMessageType.sessionResume);
    state = const CaptureState.listening();
  }

  /// Graceful end. Sends `session_end`, drains, tears down.
  Future<void> endSession() async {
    if (_terminated) return;
    _sendMarker(WssMessageType.sessionEnd);
    await _teardown();
    state = const CaptureState.disconnected();
  }

  /// Dispatch a voice command into the events controller. Called by the
  /// (future) on-device voice command recognizer or by manual UI buttons.
  Future<void> handleVoiceCommand(VoiceCommand command) async {
    _log.info(
      'voice command',
      data: <String, Object?>{'session_id': sessionId, 'command': command.name},
    );
    // Inform the server too (server logs the command for audit).
    _sendVoiceCommand(command);
    switch (command) {
      case VoiceCommand.confirmLast:
        await ref
            .read(eventsControllerProvider(sessionId).notifier)
            .confirmLast();
      case VoiceCommand.strikeLast:
        await ref
            .read(eventsControllerProvider(sessionId).notifier)
            .rejectLast();
      case VoiceCommand.pause:
        await pausePtt();
      case VoiceCommand.resume:
        await resumePtt();
      case VoiceCommand.endSession:
        await endSession();
    }
  }

  // ------------ WSS plumbing ------------

  void _onWssEnvelope(WssEnvelope env) {
    final payload = env.payload;
    switch (payload) {
      case SessionStartedWssPayload():
        _log.info(
          'session_started',
          data: <String, Object?>{'session_id': env.sessionId},
        );
      case TranscriptPartialWssPayload(:final payload):
        ref
            .read(transcriptControllerProvider(sessionId).notifier)
            .addPartial(payload);
      case TranscriptFinalWssPayload(:final payload):
        ref
            .read(transcriptControllerProvider(sessionId).notifier)
            .addFinal(payload);
      case EventExtractedWssPayload(:final payload):
        // Forward the typed extracted event into the events controller.
        // PHI safety: we DO NOT log the event fields here — the events
        // controller logs only event_id + event_type.
        ref
            .read(eventsControllerProvider(sessionId).notifier)
            .addExtracted(payload.event);
      case EventAckWssPayload(:final payload):
        _log.info(
          'event_ack',
          data: <String, Object?>{
            'event_id': payload.eventId,
            'status': payload.status.name,
          },
        );
      case SessionEndedWssPayload():
        _log.info('session_ended received from server');
        if (!_terminated) {
          unawaited(_teardown());
          state = const CaptureState.disconnected();
        }
      case ErrorWssPayload(:final payload):
        _log.warn(
          'wss error frame',
          data: <String, Object?>{'code': payload.code},
        );
        state = CaptureState.error(
          AppFailure.fromWireError(payload.code, payload.message),
        );
      case AudioChunkWssPayload():
      case VoiceCommandWssPayload():
      case SessionPauseWssPayload():
      case SessionResumeWssPayload():
      case SessionEndWssPayload():
      case PingWssPayload():
      case PongWssPayload():
      case UnknownWssPayload():
        // Client→server or non-actionable; ignore.
        break;
    }
  }

  void _onWssError(Object error, StackTrace stack) {
    _log.warn('wss stream error', error: error, stackTrace: stack);
    // We don't flip to error state on transient network errors — the
    // WssConnection has its own reconnect loop and will surface state
    // via _onWssState.
  }

  void _onWssState(WssConnectionState wssState) {
    _log.info(
      'wss state',
      data: <String, Object?>{'session_id': sessionId, 'state': wssState.name},
    );
    // Surface paused state to the UI so it can render "Reconnecting…"
    // banners. We don't flip CaptureState on reconnecting — the mic
    // keeps capturing into the rolling buffer.
    switch (wssState) {
      case WssConnectionState.connected:
        // If we were in error, optimistically clear to listening only if
        // mic was also live.
        if (state is ErrorCaptureState && _audio?.isCapturing == true) {
          state =
              _audio!.isPaused
                  ? const CaptureState.paused()
                  : const CaptureState.listening();
          // Replay buffered chunks per CONTRACT.md §5.
          _replayBuffer();
        }
      case WssConnectionState.paused:
        state = const CaptureState.error(
          AppFailure.network(message: 'Connection lost — session paused'),
        );
      case WssConnectionState.closed:
      case WssConnectionState.idle:
      case WssConnectionState.connecting:
      case WssConnectionState.reconnecting:
        break;
    }
  }

  void _replayBuffer() {
    final connection = _wss;
    if (connection == null) return;
    for (final AudioChunkPayload chunk in _rollingBuffer) {
      connection.send(
        WssEnvelope(
          type: WssMessageType.audioChunk,
          sessionId: sessionId,
          seq: connection.nextClientSeq(),
          ts: DateTime.now().toUtc(),
          payload: WssPayload.audioChunk(chunk),
        ),
      );
    }
    _log.info(
      'replayed buffered audio chunks',
      data: <String, Object?>{'count': _rollingBuffer.length},
    );
  }

  // ------------ Audio plumbing ------------

  void _onAudioChunk(Uint8List pcm) {
    final connection = _wss;
    if (connection == null) return;
    final chunkPayload = AudioChunkPayload(
      chunkId: _nextChunkId(),
      audioB64: base64Encode(pcm),
    );
    // Maintain rolling 30s buffer.
    _rollingBuffer.add(chunkPayload);
    while (_rollingBuffer.length > _maxBufferedChunks) {
      _rollingBuffer.removeFirst();
    }
    connection.send(
      WssEnvelope(
        type: WssMessageType.audioChunk,
        sessionId: sessionId,
        seq: connection.nextClientSeq(),
        ts: DateTime.now().toUtc(),
        payload: WssPayload.audioChunk(chunkPayload),
      ),
    );
  }

  void _onAudioError(Object error, StackTrace stack) {
    _log.warn('audio stream error', error: error, stackTrace: stack);
    if (error is AppFailure) {
      state = CaptureState.error(error);
    } else {
      state = CaptureState.error(
        AppFailure.platform(message: 'Audio error: $error'),
      );
    }
  }

  void _sendMarker(WssMessageType type) {
    final connection = _wss;
    if (connection == null) return;
    final WssPayload payload = switch (type) {
      WssMessageType.sessionPause => const WssPayload.sessionPause(),
      WssMessageType.sessionResume => const WssPayload.sessionResume(),
      WssMessageType.sessionEnd => const WssPayload.sessionEnd(),
      _ => const WssPayload.ping(),
    };
    connection.send(
      WssEnvelope(
        type: type,
        sessionId: sessionId,
        seq: connection.nextClientSeq(),
        ts: DateTime.now().toUtc(),
        payload: payload,
      ),
    );
  }

  void _sendVoiceCommand(VoiceCommand command) {
    final connection = _wss;
    if (connection == null) return;
    connection.send(
      WssEnvelope(
        type: WssMessageType.voiceCommand,
        sessionId: sessionId,
        seq: connection.nextClientSeq(),
        ts: DateTime.now().toUtc(),
        payload: WssPayload.voiceCommand(VoiceCommandPayload(command: command)),
      ),
    );
  }

  // ------------ Teardown ------------

  Future<void> _teardown() async {
    if (_terminated) return;
    _terminated = true;
    await _audioSub?.cancel();
    _audioSub = null;
    await _audio?.stop();
    // We do NOT dispose the audio capture here — the provider owns its
    // lifecycle and disposes on ref disposal.
    await _wssSub?.cancel();
    _wssSub = null;
    await _wssStateSub?.cancel();
    _wssStateSub = null;
    await _wss?.dispose();
    _wss = null;
    _rollingBuffer.clear();
  }

  /// Generate a unique chunk id. Server dedupes per CONTRACT.md §5, so
  /// the format only matters insofar as it's unique within the session.
  /// `<sessionId>-<counter>` is unique by construction.
  String _nextChunkId() {
    _chunkCounter++;
    return '$sessionId-$_chunkCounter';
  }

  /// Compute the WSS URL the controller should connect to.
  ///
  /// The session response includes a fully-qualified `wss_url` per
  /// CONTRACT.md §1. We prefer that. As a fallback (e.g. dev/tests where
  /// the gateway returned a relative URL), we synthesize from
  /// [AppConfig.wssBaseUrl].
  static String _baseUrlFromSession(Session session, String fallbackBase) {
    if (session.wssUrl.isNotEmpty &&
        (session.wssUrl.startsWith('ws://') ||
            session.wssUrl.startsWith('wss://'))) {
      // The WssConnection wants a base URL; it appends the session path
      // itself. We strip the trailing `/api/v1/sessions/{id}/stream` if
      // present.
      const marker = '/api/v1/sessions/';
      final idx = session.wssUrl.indexOf(marker);
      if (idx >= 0) {
        return session.wssUrl.substring(0, idx);
      }
      return session.wssUrl;
    }
    return fallbackBase;
  }
}

/// Transcript state for a single session.
///
/// Held separately from [CaptureController] so transcript-only widgets
/// can rebuild without touching the WSS/audio plumbing.
@Riverpod(keepAlive: true)
class TranscriptController extends _$TranscriptController {
  /// Cap on retained transcript lines — long sessions otherwise grow
  /// unbounded. 200 is enough for ~10 minutes of dense narration.
  static const int _maxLines = 200;

  @override
  List<TranscriptLine> build(String sessionId) => const <TranscriptLine>[];

  void addPartial(TranscriptPartialPayload payload) {
    final next = List<TranscriptLine>.of(state);
    // Replace the most recent partial in place; otherwise append.
    if (next.isNotEmpty &&
        !next.last.isFinal &&
        next.last.transcriptId == null) {
      next[next.length - 1] = TranscriptLine(
        text: payload.text,
        speaker: payload.speaker,
        isFinal: false,
        receivedAt: DateTime.now().toUtc(),
      );
    } else {
      next.add(
        TranscriptLine(
          text: payload.text,
          speaker: payload.speaker,
          isFinal: false,
          receivedAt: DateTime.now().toUtc(),
        ),
      );
    }
    state = _cap(next);
  }

  void addFinal(TranscriptFinalPayload payload) {
    final next = List<TranscriptLine>.of(state);
    final line = TranscriptLine(
      text: payload.text,
      speaker: payload.speaker,
      transcriptId: payload.transcriptId,
      isFinal: true,
      receivedAt: DateTime.now().toUtc(),
    );
    // Replace the trailing partial if present (the final supersedes it).
    if (next.isNotEmpty && !next.last.isFinal) {
      next[next.length - 1] = line;
    } else {
      next.add(line);
    }
    state = _cap(next);
  }

  List<TranscriptLine> _cap(List<TranscriptLine> lines) {
    if (lines.length <= _maxLines) return lines;
    return lines.sublist(lines.length - _maxLines);
  }
}
