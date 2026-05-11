import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';

part 'sign_state.freezed.dart';

/// Result of a successful `POST /sessions/{id}/sign` per CONTRACT.md §1.
@freezed
class SignedSession with _$SignedSession {
  const factory SignedSession({
    required String sessionId,
    required DateTime signedAt,
    required int eventsWritten,
    required int eventsRejected,
  }) = _SignedSession;

  factory SignedSession.fromWire(Map<String, Object?> json) {
    final id = json['session_id'] as String?;
    final signedAtRaw = json['signed_at'] as String?;
    if (id == null || signedAtRaw == null) {
      throw const FormatException(
        'Sign response missing session_id or signed_at',
      );
    }
    return SignedSession(
      sessionId: id,
      signedAt: DateTime.parse(signedAtRaw),
      eventsWritten: (json['events_written'] as num?)?.toInt() ?? 0,
      eventsRejected: (json['events_rejected'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Sign-off state machine.
///
/// idle
///   |  beginSign()
///   v
/// summarizing -- counts ready --> promptingBiometric (or promptingPin)
///                                    |   onAuthSuccess
///                                    v
///                                  submitting -- POST 200 --> success
///                                    |
///                                    v
///                                  error(failure)
@freezed
sealed class SignState with _$SignState {
  const factory SignState.idle() = IdleSignState;
  const factory SignState.summarizing() = SummarizingSignState;
  const factory SignState.promptingBiometric() = PromptingBiometricSignState;
  const factory SignState.promptingPin() = PromptingPinSignState;
  const factory SignState.submitting() = SubmittingSignState;
  const factory SignState.success({required SignedSession signed}) =
      SuccessSignState;
  const factory SignState.error({required AppFailure failure}) = ErrorSignState;
}
