import 'dart:async';
import 'dart:typed_data';

import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:record/record.dart';

/// Required PCM frame: 16 kHz mono signed 16-bit little-endian,
/// chunked every 250 ms (= 8000 bytes per chunk).
///
/// Servers reject other formats with `audio_format_unsupported`.
class PcmFormat {
  const PcmFormat({
    this.sampleRate = 16000,
    this.channels = 1,
    this.bytesPerSample = 2,
    this.chunkMs = 250,
  });

  static const PcmFormat clinical = PcmFormat();

  final int sampleRate;
  final int channels;
  final int bytesPerSample;
  final int chunkMs;

  int get bytesPerChunk =>
      (sampleRate * chunkMs ~/ 1000) * channels * bytesPerSample;
}

/// Streaming audio capture. The interface every implementation must satisfy.
///
/// Lifecycle:
///   start() -> capture() yields chunks ... pause()/resume() ... stop()/dispose()
///
/// Implementations:
///  * [FakeAudioCapture] — emits silence at the contract chunk rate.
///    Used in tests and in dev when the device has no mic permission.
///  * [RealAudioCapture] — wraps `package:record` in stream mode and
///    re-frames its raw PCM output to exactly `chunkMs` per chunk.
abstract class AudioCapture {
  /// Audio format produced by [capture]. Must match `PcmFormat.clinical`
  /// to satisfy the wire contract; subclasses may not deviate.
  PcmFormat get format;

  /// True once [start] has been called and not yet [stop]ped.
  bool get isCapturing;

  /// True if currently paused via [pause].
  bool get isPaused;

  /// Open the mic / configure encoder. Must be called before [capture].
  ///
  /// Throws `AppFailure.platform` if mic permission is denied or no input
  /// device is available.
  Future<void> start();

  /// Hot stream of PCM frames. Single subscriber.
  ///
  /// Emission cadence == `format.chunkMs` (250 ms by default). Each event
  /// is `format.bytesPerChunk` bytes (8000 for clinical defaults).
  ///
  /// Errors are surfaced on the stream — listener should not assume the
  /// stream stays healthy after one. The capture will continue trying
  /// until [stop].
  Stream<Uint8List> capture();

  /// Stop emitting frames but keep the audio device open. The mic stays
  /// hot — calling [resume] picks up immediately without prompting again.
  Future<void> pause();

  Future<void> resume();

  /// Stop capturing AND release the mic. After this you must call [start]
  /// again before [capture] yields anything.
  Future<void> stop();

  /// Final teardown. After this the instance is unusable.
  Future<void> dispose();
}

/// Re-frames a stream of arbitrary-sized PCM buffers into fixed-size chunks.
///
/// `package:record` does not guarantee any particular chunk size on its
/// stream — on iOS it may emit 100ms frames, on Android it may emit 20ms
/// frames, on macOS something else again. The wire contract requires a
/// single 250ms (= 8000 byte) frame per `audio_chunk`, so we buffer
/// incoming bytes until we have exactly one chunk, then emit.
///
/// Trailing partial chunks at `flush()` are dropped — the server rejects
/// short frames with `audio_format_unsupported`, and 25ms of silence at
/// the end of a session is not worth the bandwidth.
///
/// Exposed for test coverage; production wiring lives inside
/// [RealAudioCapture].
class PcmChunkAssembler {
  PcmChunkAssembler({required this.bytesPerChunk});

  /// Target chunk size in bytes. [add] only emits when this is reached.
  final int bytesPerChunk;

  final BytesBuilder _builder = BytesBuilder(copy: false);

  /// Append [bytes] to the buffer and return zero or more complete chunks.
  ///
  /// Each returned chunk is exactly [bytesPerChunk] bytes. The internal
  /// buffer retains any leftover bytes for the next call.
  List<Uint8List> add(Uint8List bytes) {
    if (bytes.isEmpty) return const <Uint8List>[];
    _builder.add(bytes);
    final emitted = <Uint8List>[];
    while (_builder.length >= bytesPerChunk) {
      final all = _builder.toBytes();
      emitted.add(Uint8List.sublistView(all, 0, bytesPerChunk));
      _builder
        ..clear()
        ..add(Uint8List.sublistView(all, bytesPerChunk));
    }
    return emitted;
  }

  /// Number of bytes currently waiting for a full chunk.
  int get pendingBytes => _builder.length;

  void reset() => _builder.clear();
}

/// Fake implementation that emits silence at the contract cadence.
///
/// Use in tests, in golden-tests for capture screens, and as a fallback
/// when running on a simulator without mic input.
class FakeAudioCapture implements AudioCapture {
  FakeAudioCapture({this.format = PcmFormat.clinical});

  static const AppLogger _log = AppLogger('FakeAudioCapture');

  @override
  final PcmFormat format;

  final StreamController<Uint8List> _controller =
      StreamController<Uint8List>.broadcast();
  Timer? _timer;
  bool _capturing = false;
  bool _paused = false;
  bool _disposed = false;

  @override
  bool get isCapturing => _capturing;

  @override
  bool get isPaused => _paused;

  @override
  Future<void> start() async {
    if (_disposed) throw StateError('FakeAudioCapture used after dispose()');
    if (_capturing) return;
    _capturing = true;
    _paused = false;
    _log.info(
      'fake audio capture started',
      data: <String, Object?>{
        'sample_rate': format.sampleRate,
        'channels': format.channels,
        'chunk_ms': format.chunkMs,
      },
    );
    _scheduleEmission();
  }

  void _scheduleEmission() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: format.chunkMs), (_) {
      if (_paused || !_capturing) return;
      // 8000 zero-bytes = 250 ms of PCM16 silence at 16kHz mono.
      _controller.add(Uint8List(format.bytesPerChunk));
    });
  }

  @override
  Stream<Uint8List> capture() => _controller.stream;

  @override
  Future<void> pause() async {
    if (!_capturing) return;
    _paused = true;
    _log.info('fake audio capture paused');
  }

  @override
  Future<void> resume() async {
    if (!_capturing) return;
    _paused = false;
    _log.info('fake audio capture resumed');
  }

  @override
  Future<void> stop() async {
    if (!_capturing) return;
    _timer?.cancel();
    _timer = null;
    _capturing = false;
    _paused = false;
    _log.info('fake audio capture stopped');
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop();
    await _controller.close();
  }
}

/// Factory for the [AudioRecorder] handle so tests can inject a fake.
typedef AudioRecorderFactory = AudioRecorder Function();

AudioRecorder _defaultRecorderFactory() => AudioRecorder();

/// Real microphone capture backed by `package:record`.
///
/// The platform plugin streams raw PCM at whatever buffer size it picks.
/// We re-frame to exactly [PcmFormat.bytesPerChunk] (8000 bytes / 250ms
/// at 16kHz mono) via [PcmChunkAssembler] before exposing on [capture].
///
/// Permissions are requested lazily on [start] — never at construction
/// time. A denied prompt throws [AppFailure.platform] with `mic_permission_denied`.
///
/// **PHI safety:** the raw PCM bytes are never logged; only frame counts
/// and chunk sizes ever leave the class.
class RealAudioCapture implements AudioCapture {
  RealAudioCapture({
    this.format = PcmFormat.clinical,
    AudioRecorderFactory? recorderFactory,
  }) : _recorderFactory = recorderFactory ?? _defaultRecorderFactory;

  static const AppLogger _log = AppLogger('RealAudioCapture');

  @override
  final PcmFormat format;

  final AudioRecorderFactory _recorderFactory;

  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _rawSub;
  late final PcmChunkAssembler _assembler = PcmChunkAssembler(
    bytesPerChunk: format.bytesPerChunk,
  );

  final StreamController<Uint8List> _controller =
      StreamController<Uint8List>.broadcast();

  bool _capturing = false;
  bool _paused = false;
  bool _disposed = false;

  @override
  bool get isCapturing => _capturing;

  @override
  bool get isPaused => _paused;

  @override
  Future<void> start() async {
    if (_disposed) {
      throw StateError('RealAudioCapture used after dispose()');
    }
    if (_capturing) return;

    final recorder = _recorder ??= _recorderFactory();

    // Lazy permission prompt on first start. The plugin shows the system
    // dialog only if permission has not yet been granted.
    final hasPermission = await recorder.hasPermission();
    if (!hasPermission) {
      _log.warn('mic permission denied');
      throw const AppFailure.platform(
        message: 'Microphone permission denied',
        code: 'mic_permission_denied',
      );
    }

    try {
      final raw = await recorder.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: format.sampleRate,
          numChannels: format.channels,
          // Echo cancellation + noise suppression help the ASR but may
          // attenuate quiet speech; leave off for the clinical room.
          // (Defaults are already false; explicit for safety/readability.)
        ),
      );

      _assembler.reset();
      _rawSub = raw.listen(
        _onRawBytes,
        onError: _onRawError,
        onDone: _onRawDone,
        cancelOnError: false,
      );
      _capturing = true;
      _paused = false;
      _log.info(
        'real audio capture started',
        data: <String, Object?>{
          'sample_rate': format.sampleRate,
          'channels': format.channels,
          'chunk_ms': format.chunkMs,
          'bytes_per_chunk': format.bytesPerChunk,
        },
      );
    } on Object catch (e, st) {
      _log.warn('real audio capture failed to start', error: e, stackTrace: st);
      throw AppFailure.platform(
        message: 'Audio capture could not start: $e',
        code: 'audio_start_failed',
      );
    }
  }

  void _onRawBytes(Uint8List bytes) {
    if (_paused || !_capturing) return;
    final chunks = _assembler.add(bytes);
    for (final chunk in chunks) {
      _controller.add(chunk);
    }
  }

  void _onRawError(Object error, StackTrace stack) {
    _log.warn('mic stream error', error: error, stackTrace: stack);
    if (!_controller.isClosed) {
      _controller.addError(
        AppFailure.platform(
          message: 'Microphone error: $error',
          code: 'mic_stream_error',
        ),
        stack,
      );
    }
  }

  void _onRawDone() {
    _log.info('mic stream done');
  }

  @override
  Stream<Uint8List> capture() => _controller.stream;

  @override
  Future<void> pause() async {
    if (!_capturing || _paused) return;
    _paused = true;
    try {
      await _recorder?.pause();
    } on Object catch (e, st) {
      _log.warn('mic pause failed', error: e, stackTrace: st);
    }
    _log.info('real audio capture paused');
  }

  @override
  Future<void> resume() async {
    if (!_capturing || !_paused) return;
    _paused = false;
    try {
      await _recorder?.resume();
    } on Object catch (e, st) {
      _log.warn('mic resume failed', error: e, stackTrace: st);
    }
    _log.info('real audio capture resumed');
  }

  @override
  Future<void> stop() async {
    if (!_capturing) return;
    _capturing = false;
    _paused = false;
    await _rawSub?.cancel();
    _rawSub = null;
    try {
      await _recorder?.stop();
    } on Object catch (e, st) {
      _log.warn('mic stop failed', error: e, stackTrace: st);
    }
    _assembler.reset();
    _log.info('real audio capture stopped');
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop();
    try {
      await _recorder?.dispose();
    } on Object catch (e, st) {
      _log.warn('mic dispose failed', error: e, stackTrace: st);
    }
    _recorder = null;
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
