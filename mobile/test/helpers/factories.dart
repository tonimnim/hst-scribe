// Pure factories used across widget + unit tests.
//
// Goals:
//   * Build freezed types with sensible defaults so call sites stay short.
//   * Every parameter is named + override-able to let tests pin down only
//     the field they care about.
//   * No PHI — all values are obviously synthetic (`Test`, `J.D.`, last4
//     `4821` matching the example in CONTRACT.md §POST /sessions).
import 'package:hst_scribe/core/auth/token_store.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/features/auth/domain/auth_state.dart';
import 'package:hst_scribe/features/patient/domain/patient_context_model.dart';
import 'package:hst_scribe/features/session/domain/session.dart';

/// Builds a [PatientContextModel] with safe (non-PHI) defaults.
///
/// Defaults intentionally match the worked example in CONTRACT.md §1 so
/// golden / behavior tests reference the same canonical patient.
PatientContextModel makePatientContext({
  String patientId = '01931d7e-aaaa-bbbb-cccc-dddddddddddd',
  String displayNameInitials = 'J.D.',
  String mrnLast4 = '4821',
  String procedure = 'Right knee arthroscopy',
  List<MedicationSummaryModel>? currentMedications,
  List<AllergyModel>? allergies,
  List<String>? comorbidities,
}) {
  return PatientContextModel(
    patientId: patientId,
    displayNameInitials: displayNameInitials,
    mrnLast4: mrnLast4,
    procedure: procedure,
    currentMedications:
        currentMedications ??
        const <MedicationSummaryModel>[
          MedicationSummaryModel(
            rxnormCode: '26225',
            name: 'Ondansetron',
            dose: '4 mg',
            route: 'iv',
          ),
        ],
    allergies:
        allergies ??
        const <AllergyModel>[
          AllergyModel(name: 'Penicillin', severity: 'severe'),
        ],
    comorbidities: comorbidities ?? const <String>['diabetes_type_2'],
  );
}

/// Builds a [Session] with sensible defaults. `id`, `wssUrl`, `startedAt`,
/// and `expiresAt` are pinned to the same values used in CONTRACT.md to
/// keep widget snapshots stable.
Session makeSession({
  String id = '01931d80-aaaa-bbbb-cccc-dddddddddddd',
  String wssUrl =
      'wss://api.hst-scribe.example/api/v1/sessions/01931d80-aaaa-bbbb-cccc-dddddddddddd/stream',
  PatientContextModel? patientContext,
  DateTime? startedAt,
  DateTime? expiresAt,
  SessionStatus status = SessionStatus.active,
  WorkflowType workflowType = WorkflowType.pacu,
}) {
  // 2026-05-11T14:30:00Z — frozen clock to keep tests deterministic.
  final start = startedAt ?? DateTime.utc(2026, 5, 11, 14, 30);
  return Session(
    id: id,
    wssUrl: wssUrl,
    patientContext: patientContext ?? makePatientContext(),
    startedAt: start,
    expiresAt: expiresAt ?? start.add(const Duration(minutes: 30)),
    status: status,
    workflowType: workflowType,
  );
}

/// Builds a [TokenBundle]. Default expiry is 15 minutes in the future,
/// matching the standard access-token lifetime in CONTRACT.md §4.
TokenBundle makeTokenBundle({
  String accessToken = 'access.token.value',
  String refreshToken = 'refresh.token.value',
  DateTime? expiresAt,
  String userId = '00000000-0000-0000-0000-0000000000b1',
  String ascId = '00000000-0000-0000-0000-0000000000a5',
  String role = 'nurse',
}) {
  return TokenBundle(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresAt:
        expiresAt ?? DateTime.now().toUtc().add(const Duration(minutes: 15)),
    userId: userId,
    ascId: ascId,
    role: role,
  );
}

/// Builds an [AuthClaims] mirroring the defaults of [makeTokenBundle].
AuthClaims makeAuthClaims({
  String userId = '00000000-0000-0000-0000-0000000000b1',
  String ascId = '00000000-0000-0000-0000-0000000000a5',
  String role = 'nurse',
  DateTime? expiresAt,
}) {
  return AuthClaims(
    userId: userId,
    ascId: ascId,
    role: role,
    expiresAt:
        expiresAt ?? DateTime.now().toUtc().add(const Duration(minutes: 15)),
  );
}

/// Convenience for an authenticated [AuthState].
AuthState makeAuthenticatedState({AuthClaims? claims}) {
  return AuthState.authenticated(claims: claims ?? makeAuthClaims());
}

/// Convenience for an unauthenticated [AuthState] with an optional failure.
AuthState makeUnauthenticatedState({AppFailure? failure}) {
  return AuthState.unauthenticated(failure: failure);
}
