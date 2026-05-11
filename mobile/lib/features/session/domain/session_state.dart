import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/features/patient/domain/patient_context_model.dart';
import 'package:hst_scribe/features/session/domain/session.dart';

part 'session_state.freezed.dart';

/// State of the currently-active session.
///
/// The capture + events agent (Wave 2) reads this to obtain:
///  * `session.id`     → URL path + WSS frame envelope
///  * `session.wssUrl` → the resolved WSS URL with auth-bearing scheme
///  * `patient`        → patient banner + locked patient context
///  * `confirmed`      → whether the nurse has confirmed the patient; capture
///    is forbidden while this is false (CLAUDE.md PHI guardrail).
@freezed
sealed class ActiveSessionState with _$ActiveSessionState {
  /// No session is active. Default state.
  const factory ActiveSessionState.none() = NoActiveSession;

  /// `POST /sessions` is in flight.
  const factory ActiveSessionState.starting() = StartingActiveSession;

  /// Session created but the nurse hasn't confirmed the patient yet.
  /// Capture must be blocked in this state.
  const factory ActiveSessionState.awaitingPatientConfirm({
    required Session session,
  }) = AwaitingPatientConfirmActiveSession;

  /// Patient confirmed; capture is allowed.
  const factory ActiveSessionState.ready({
    required Session session,
  }) = ReadyActiveSession;
}

/// Convenience accessors so the capture screen doesn't have to switch
/// on the variant every time.
extension ActiveSessionStateX on ActiveSessionState {
  Session? get session => switch (this) {
    NoActiveSession() => null,
    StartingActiveSession() => null,
    AwaitingPatientConfirmActiveSession(:final session) => session,
    ReadyActiveSession(:final session) => session,
  };

  PatientContextModel? get patient => session?.patientContext;

  /// True only when [ReadyActiveSession]. Capture screens must short-circuit
  /// if this is false.
  bool get isConfirmed => this is ReadyActiveSession;
}
