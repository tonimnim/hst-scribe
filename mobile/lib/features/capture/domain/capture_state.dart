import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';

part 'capture_state.freezed.dart';

/// State graph for [CaptureController].
///
/// Transitions:
///   disconnected
///      |  startCapture()
///      v
///   connecting --- onError ---> error(failure)
///      |
///      v
///   listening
///      |  pausePtt()       ^  resumePtt()
///      v                   |
///   paused -----------------+
///      |  endSession()
///      v
///   disconnected  (and then [CaptureController] tears down)
///
@freezed
sealed class CaptureState with _$CaptureState {
  /// No active WSS or mic. Default state on screen entry.
  const factory CaptureState.disconnected() = DisconnectedCaptureState;

  /// WSS handshake in flight.
  const factory CaptureState.connecting() = ConnectingCaptureState;

  /// Mic open and audio_chunk frames flowing.
  const factory CaptureState.listening() = ListeningCaptureState;

  /// Mic paused (push-to-talk released). WSS stays open.
  const factory CaptureState.paused() = PausedCaptureState;

  /// Terminal error — typically `audio_format_unsupported`,
  /// `mic_permission_denied`, or `network`. Surfaces to the UI as a
  /// banner; the nurse must explicitly retry.
  const factory CaptureState.error(AppFailure failure) = ErrorCaptureState;
}
