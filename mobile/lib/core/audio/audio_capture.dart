import 'dart:async';
import 'dart:typed_data';

import 'package:hst_scribe/core/obs/logger.dart';

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
///  * `RecordAudioCapture` (Phase B) — wraps `package:record` in stream mode.
///    Lives in `core/audio/record_audio_capture.dart` (not yet implemented).
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
