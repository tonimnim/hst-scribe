import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_context.freezed.dart';
part 'patient_context.g.dart';

@freezed
class MedicationSummary with _$MedicationSummary {
  const factory MedicationSummary({
    @JsonKey(name: 'rxnorm_code') required String rxnormCode,
    required String name,
    required String dose,
    required String route,
  }) = _MedicationSummary;

  factory MedicationSummary.fromJson(Map<String, Object?> json) =>
      _$MedicationSummaryFromJson(json);
}

@freezed
class AllergySummary with _$AllergySummary {
  const factory AllergySummary({
    required String name,
    required String severity,
  }) = _AllergySummary;

  factory AllergySummary.fromJson(Map<String, Object?> json) =>
      _$AllergySummaryFromJson(json);
}

/// Patient context returned by `POST /sessions` and carried on
/// `session_started`. Per CONTRACT.md, only `displayNameInitials` and
/// `mrnLast4` are safe to render in logs.
@freezed
class PatientContext with _$PatientContext {
  const factory PatientContext({
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'display_name_initials') required String displayNameInitials,
    @JsonKey(name: 'mrn_last4') required String mrnLast4,
    required String procedure,
    @JsonKey(name: 'current_medications')
    @Default(<MedicationSummary>[])
    List<MedicationSummary> currentMedications,
    @Default(<AllergySummary>[]) List<AllergySummary> allergies,
    @Default(<String>[]) List<String> comorbidities,
  }) = _PatientContext;

  factory PatientContext.fromJson(Map<String, Object?> json) =>
      _$PatientContextFromJson(json);
}
