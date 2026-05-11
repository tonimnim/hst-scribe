import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/contract/patient_context.dart' as wire;
import 'package:hst_scribe/features/patient/domain/patient_context_model.dart';

part 'session.freezed.dart';

/// `workflow_type` per CONTRACT.md §POST /sessions.
enum WorkflowType {
  pacu,
  preop,
  intraop;

  String get wireValue {
    switch (this) {
      case WorkflowType.pacu:
        return 'pacu';
      case WorkflowType.preop:
        return 'preop';
      case WorkflowType.intraop:
        return 'intraop';
    }
  }

  static WorkflowType fromWire(String raw) {
    switch (raw) {
      case 'preop':
        return WorkflowType.preop;
      case 'intraop':
        return WorkflowType.intraop;
      case 'pacu':
      default:
        return WorkflowType.pacu;
    }
  }
}

/// Lifecycle status carried in [Session.status]. Server is authoritative.
enum SessionStatus {
  /// Created but no audio yet.
  active,

  /// Paused (network grace timer or user pressed pause).
  paused,

  /// Idle timeout exceeded; needs explicit resume.
  expired,

  /// Sign workflow completed.
  signed,

  /// Server-side error left this session non-recoverable.
  failed;

  static SessionStatus fromWire(String? raw) {
    switch (raw) {
      case 'paused':
        return SessionStatus.paused;
      case 'expired':
        return SessionStatus.expired;
      case 'signed':
        return SessionStatus.signed;
      case 'failed':
        return SessionStatus.failed;
      case 'active':
      default:
        return SessionStatus.active;
    }
  }
}

/// Domain representation of a clinical session, mapped from the
/// `POST /sessions` and `GET /sessions/{id}` responses.
@freezed
class Session with _$Session {
  const factory Session({
    required String id,
    required String wssUrl,
    required PatientContextModel patientContext,
    required DateTime startedAt,
    required DateTime expiresAt,
    required SessionStatus status,
    @Default(WorkflowType.pacu) WorkflowType workflowType,
  }) = _Session;

  const Session._();

  /// Parse the wire response from `POST /sessions` / `GET /sessions/{id}`.
  ///
  /// Per CONTRACT.md the shape is:
  /// ```json
  /// {
  ///   "session_id": "...",
  ///   "wss_url": "wss://...",
  ///   "patient_context": { ... },
  ///   "started_at": "RFC3339",
  ///   "expires_at": "RFC3339",
  ///   "status": "active"            // (optional in POST, present in GET)
  /// }
  /// ```
  factory Session.fromWire(Map<String, Object?> json) {
    final id = json['session_id'] as String?;
    final wssUrl = json['wss_url'] as String?;
    final startedRaw = json['started_at'] as String?;
    final expiresRaw = json['expires_at'] as String?;
    final patientRaw = (json['patient_context'] as Map<Object?, Object?>?)
        ?.cast<String, Object?>();

    if (id == null ||
        wssUrl == null ||
        startedRaw == null ||
        expiresRaw == null ||
        patientRaw == null) {
      throw const FormatException(
        'Session response missing required field '
        '(session_id, wss_url, started_at, expires_at, patient_context)',
      );
    }
    final patient = PatientContextModel.fromWire(
      wire.PatientContext.fromJson(patientRaw),
    );
    return Session(
      id: id,
      wssUrl: wssUrl,
      patientContext: patient,
      startedAt: DateTime.parse(startedRaw),
      expiresAt: DateTime.parse(expiresRaw),
      status: SessionStatus.fromWire(json['status'] as String?),
      workflowType: WorkflowType.fromWire(
        (json['workflow_type'] as String?) ?? 'pacu',
      ),
    );
  }
}
