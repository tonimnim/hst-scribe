import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:hst_scribe/core/contract/wss_envelope.dart';
import 'package:hst_scribe/core/contract/wss_messages.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Lifecycle states surfaced to the UI.
enum WssConnectionState {
  /// Not yet started, or [WssConnection.dispose] has been called.
  idle,

  /// Attempting to open / reopen the socket.
  connecting,

  /// Socket open and bidirectional messaging is possible.
  connected,

  /// Socket closed unexpectedly; backoff timer is running before reconnect.
  reconnecting,

  /// 5-minute reconnect grace window elapsed; server has paused the session.
  paused,

  /// Closed by client request (graceful) — no further reconnect attempts.
  closed,
}

/// Builds a `WebSocketChannel` against [url] with the supplied `Authorization`
/// header. Indirection so tests can inject a fake transport.
typedef WssChannelFactory =
    WebSocketChannel Function(Uri url, Map<String, Object?> headers);

WebSocketChannel _defaultChannelFactory(Uri url, Map<String, Object?> headers) {
  return IOWebSocketChannel.connect(
    url,
    headers: headers,
    pingInterval: const Duration(seconds: 20),
  );
}

/// Single-session WebSocket connection.
///
/// Wraps a `web_socket_channel` with:
///  * Exponential backoff reconnect (0.5s, 1s, 2s, 4s, 8s, 16s, 30s cap)
///  * `last_seq` resume query param per CONTRACT.md §5
///  * Connection-state stream for UI banners ("Reconnecting…")
///  * Envelope decode → typed `WssEnvelope` stream
///
/// **Not yet implemented (deferred to feature wiring):**
///  * Local audio buffer replay on reconnect (lives in `features/capture/`).
///  * Pending-ack tracking for client→server `audio_chunk`s.
///
/// PHI safety: incoming/outgoing JSON is NOT logged. Only envelope summaries
/// (type / seq / session_id / ts) are emitted at info level.
class WssConnection {
  WssConnection({
    required Uri baseUrl,
    required String sessionId,
    required String accessToken,
    WssChannelFactory? channelFactory,
    Duration initialBackoff = const Duration(milliseconds: 500),
    Duration maxBackoff = const Duration(seconds: 30),
    Duration disconnectGrace = const Duration(minutes: 5),
  }) : _baseUrl = baseUrl,
       _sessionId = sessionId,
       _accessToken = accessToken,
       _channelFactory = channelFactory ?? _defaultChannelFactory,
       _initialBackoff = initialBackoff,
       _maxBackoff = maxBackoff,
       _disconnectGrace = disconnectGrace;

  static const AppLogger _log = AppLogger('WssConnection');

  final Uri _baseUrl;
  final String _sessionId;
  final String _accessToken;
  final WssChannelFactory _channelFactory;
  final Duration _initialBackoff;
  final Duration _maxBackoff;
  final Duration _disconnectGrace;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSub;

  final StreamController<WssEnvelope> _incoming =
      StreamController<WssEnvelope>.broadcast();
  final StreamController<WssConnectionState> _state =
      StreamController<WssConnectionState>.broadcast();

  WssConnectionState _currentState = WssConnectionState.idle;
  int _serverLastSeq = 0;
  int _clientSeq = 0;
  int _backoffAttempt = 0;
  Timer? _reconnectTimer;
  Timer? _disconnectGraceTimer;
  bool _disposed = false;

  Stream<WssEnvelope> get incoming => _incoming.stream;
  Stream<WssConnectionState> get state => _state.stream;
  WssConnectionState get currentState => _currentState;
  int get serverLastSeq => _serverLastSeq;

  Future<void> connect() async {
    if (_disposed) {
      throw StateError('WssConnection used after dispose()');
    }
    _setState(WssConnectionState.connecting);

    final url = _resumeUrl();
    try {
      final ch = _channelFactory(url, <String, Object?>{
        'Authorization': 'Bearer $_accessToken',
      });
      await ch.ready;
      _channel = ch;
      _channelSub = ch.stream.listen(
        _onRawMessage,
        onError: _onChannelError,
        onDone: _onChannelDone,
        cancelOnError: false,
      );
      _backoffAttempt = 0;
      _setState(WssConnectionState.connected);
      _log.info(
        'wss connected',
        data: <String, Object?>{
          'session_id': _sessionId,
          'last_seq': _serverLastSeq,
        },
      );
    } catch (e, st) {
      _log.warn(
        'wss connect failed',
        error: e,
        stackTrace: st,
        data: <String, Object?>{'session_id': _sessionId},
      );
      _scheduleReconnect();
    }
  }

  Uri _resumeUrl() {
    final path = '/api/v1/sessions/$_sessionId/stream';
    final query = <String, String>{
      if (_serverLastSeq > 0) 'last_seq': '$_serverLastSeq',
    };
    return _baseUrl.replace(
      path: path,
      queryParameters: query.isEmpty ? null : query,
    );
  }

  /// Send a typed envelope. Caller is responsible for assigning the correct
  /// `seq` via [nextClientSeq] if it wants strict monotonicity tracking.
  void send(WssEnvelope envelope) {
    final ch = _channel;
    if (ch == null || _currentState != WssConnectionState.connected) {
      _log.warn(
        'attempted send while not connected',
        data: <String, Object?>{
          'state': _currentState.name,
          'type': envelope.type.wireValue,
        },
      );
      return;
    }
    final encoded = jsonEncode(envelope.toJson());
    ch.sink.add(encoded);
    _log.trace(
      'wss send',
      data: <String, Object?>{
        ...envelope.toLogSummary(),
        // audioChunk payload is base64 PCM — never logged.
      },
    );
  }

  /// Next monotonic seq for a client→server message.
  int nextClientSeq() => ++_clientSeq;

  void _onRawMessage(dynamic raw) {
    try {
      final text = raw is String ? raw : utf8.decode(raw as List<int>);
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, Object?>) {
        _log.warn('wss frame not a JSON object');
        return;
      }
      final envelope = WssEnvelope.fromJson(decoded);
      if (envelope.seq <= _serverLastSeq) {
        _log.warn(
          'wss duplicate/regressed seq dropped',
          data: <String, Object?>{
            'incoming_seq': envelope.seq,
            'last_seq': _serverLastSeq,
          },
        );
        return;
      }
      _serverLastSeq = envelope.seq;
      _log.trace('wss recv', data: envelope.toLogSummary());
      _incoming.add(envelope);
    } catch (e, st) {
      _log.warn('wss frame decode failed', error: e, stackTrace: st);
    }
  }

  void _onChannelError(Object error, StackTrace stack) {
    _log.warn(
      'wss channel error',
      error: error,
      stackTrace: stack,
      data: <String, Object?>{'session_id': _sessionId},
    );
    _incoming.addError(
      AppFailure.network(message: 'WSS error: $error', cause: error),
    );
    _scheduleReconnect();
  }

  void _onChannelDone() {
    if (_currentState == WssConnectionState.closed) return;
    _log.info(
      'wss channel closed',
      data: <String, Object?>{
        'session_id': _sessionId,
        'close_code': _channel?.closeCode,
      },
    );
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _currentState == WssConnectionState.closed) return;
    _channelSub?.cancel();
    _channelSub = null;
    _channel = null;

    _setState(WssConnectionState.reconnecting);

    // 5-minute grace per CONTRACT.md §5 — after that the session goes paused.
    _disconnectGraceTimer ??= Timer(_disconnectGrace, () {
      _log.warn(
        'wss disconnect grace exceeded — session paused',
        data: <String, Object?>{'session_id': _sessionId},
      );
      _setState(WssConnectionState.paused);
    });

    final delay = _nextBackoffDelay();
    _backoffAttempt++;
    _log.info(
      'wss reconnect scheduled',
      data: <String, Object?>{
        'attempt': _backoffAttempt,
        'delay_ms': delay.inMilliseconds,
      },
    );
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_disposed) return;
      unawaited(connect());
    });
  }

  Duration _nextBackoffDelay() {
    final base =
        _initialBackoff.inMilliseconds *
        pow(2, _backoffAttempt.clamp(0, 6)).toInt();
    final capped = min(base, _maxBackoff.inMilliseconds);
    // ±20% jitter to avoid thundering herd.
    final jitter = Random().nextDouble() * 0.4 - 0.2;
    final jittered = (capped * (1 + jitter)).round();
    return Duration(milliseconds: jittered);
  }

  /// Cancel the disconnect grace timer once a reconnect succeeds.
  void _setState(WssConnectionState next) {
    _currentState = next;
    if (next == WssConnectionState.connected) {
      _disconnectGraceTimer?.cancel();
      _disconnectGraceTimer = null;
    }
    if (!_state.isClosed) _state.add(next);
  }

  /// Close the socket cleanly (no reconnect). Idempotent.
  Future<void> close({int code = ws_status.normalClosure}) async {
    if (_currentState == WssConnectionState.closed) return;
    _setState(WssConnectionState.closed);
    _reconnectTimer?.cancel();
    _disconnectGraceTimer?.cancel();
    await _channelSub?.cancel();
    await _channel?.sink.close(code);
    _channel = null;
    _channelSub = null;
    _log.info('wss closed', data: <String, Object?>{'session_id': _sessionId});
  }

  /// Final teardown. After this the connection cannot be reused.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await close();
    await _incoming.close();
    await _state.close();
  }
}
