import 'package:freezed_annotation/freezed_annotation.dart';

part 'extracted_event.freezed.dart';
part 'extracted_event.g.dart';

/// `event_type` discriminator per CONTRACT.md §3.
enum WireEventType {
  @JsonValue('vital_sign')
  vitalSign,
  @JsonValue('medication_administered')
  medicationAdministered,
  @JsonValue('dispo')
  dispo,
  @JsonValue('note')
  note,
}

/// `vital_sign.fields.vital_type` enumeration.
enum VitalType {
  @JsonValue('blood_pressure_systolic')
  bloodPressureSystolic,
  @JsonValue('blood_pressure_diastolic')
  bloodPressureDiastolic,
  @JsonValue('heart_rate')
  heartRate,
  @JsonValue('spo2')
  spo2,
  @JsonValue('respiratory_rate')
  respiratoryRate,
  @JsonValue('temperature_c')
  temperatureC,
  @JsonValue('temperature_f')
  temperatureF,
  @JsonValue('pain_score')
  painScore,
}

/// `medication_administered.fields.route`.
enum MedicationRoute {
  @JsonValue('iv')
  iv,
  @JsonValue('im')
  im,
  @JsonValue('po')
  po,
  @JsonValue('sublingual')
  sublingual,
  @JsonValue('topical')
  topical,
  @JsonValue('inhaled')
  inhaled,
  @JsonValue('intranasal')
  intranasal,
  @JsonValue('rectal')
  rectal,
  @JsonValue('subcutaneous')
  subcutaneous,
}

/// `medication_administered.fields.dose_unit`.
enum DoseUnit {
  @JsonValue('mg')
  mg,
  @JsonValue('mcg')
  mcg,
  @JsonValue('g')
  g,
  @JsonValue('ml')
  ml,
  @JsonValue('unit')
  unit,
}

/// `dispo.fields.disposition_type`.
enum DispositionType {
  @JsonValue('discharge_home')
  dischargeHome,
  @JsonValue('transfer_to_hospital')
  transferToHospital,
  @JsonValue('admit_observation')
  admitObservation,
  @JsonValue('transfer_to_floor')
  transferToFloor,
}

@freezed
class VitalSignFields with _$VitalSignFields {
  const factory VitalSignFields({
    @JsonKey(name: 'vital_type') required VitalType vitalType,
    required num value,
    required String unit,
  }) = _VitalSignFields;

  factory VitalSignFields.fromJson(Map<String, Object?> json) =>
      _$VitalSignFieldsFromJson(json);
}

@freezed
class MedicationAdministeredFields with _$MedicationAdministeredFields {
  const factory MedicationAdministeredFields({
    @JsonKey(name: 'medication_name') required String medicationName,
    @JsonKey(name: 'rxnorm_code') required String rxnormCode,
    @JsonKey(name: 'dose_value') required num doseValue,
    @JsonKey(name: 'dose_unit') required DoseUnit doseUnit,
    required MedicationRoute route,
    String? indication,
  }) = _MedicationAdministeredFields;

  factory MedicationAdministeredFields.fromJson(Map<String, Object?> json) =>
      _$MedicationAdministeredFieldsFromJson(json);
}

@freezed
class DispoFields with _$DispoFields {
  const factory DispoFields({
    @JsonKey(name: 'disposition_type') required DispositionType dispositionType,
    @JsonKey(name: 'discharge_criteria_met') bool? dischargeCriteriaMet,
    String? notes,
  }) = _DispoFields;

  factory DispoFields.fromJson(Map<String, Object?> json) =>
      _$DispoFieldsFromJson(json);
}

@freezed
class NoteFields with _$NoteFields {
  const factory NoteFields({
    @JsonKey(name: 'note_text') required String noteText,
    @Default(<String>[]) List<String> tags,
  }) = _NoteFields;

  factory NoteFields.fromJson(Map<String, Object?> json) =>
      _$NoteFieldsFromJson(json);
}

/// Sealed union of every extracted-event variant per CONTRACT.md §3.
///
/// Discrimination: the wire `event_type` field. Each variant carries
/// its own typed `fields`. JSON round-trip is handled by [ExtractedEventX.fromJson]
/// and [ExtractedEventX.toContractJson] (we don't use freezed's `unionKey`
/// because the wire shape nests typed fields inside `fields:` and freezed's
/// default JSON layout is flat).
@Freezed(unionKey: 'event_type', unionValueCase: FreezedUnionCase.snake)
sealed class ExtractedEvent with _$ExtractedEvent {
  @FreezedUnionValue('vital_sign')
  const factory ExtractedEvent.vitalSign({
    @JsonKey(name: 'event_id') required String eventId,
    required VitalSignFields fields,
    required double confidence,
    @JsonKey(name: 'source_utterance') required String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required DateTime extractedAt,
    @JsonKey(name: 'event_time') required DateTime eventTime,
  }) = ExtractedVitalSign;

  @FreezedUnionValue('medication_administered')
  const factory ExtractedEvent.medicationAdministered({
    @JsonKey(name: 'event_id') required String eventId,
    required MedicationAdministeredFields fields,
    required double confidence,
    @JsonKey(name: 'source_utterance') required String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required DateTime extractedAt,
    @JsonKey(name: 'event_time') required DateTime eventTime,
  }) = ExtractedMedicationAdministered;

  @FreezedUnionValue('dispo')
  const factory ExtractedEvent.dispo({
    @JsonKey(name: 'event_id') required String eventId,
    required DispoFields fields,
    required double confidence,
    @JsonKey(name: 'source_utterance') required String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required DateTime extractedAt,
    @JsonKey(name: 'event_time') required DateTime eventTime,
  }) = ExtractedDispo;

  @FreezedUnionValue('note')
  const factory ExtractedEvent.note({
    @JsonKey(name: 'event_id') required String eventId,
    required NoteFields fields,
    required double confidence,
    @JsonKey(name: 'source_utterance') required String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required DateTime extractedAt,
    @JsonKey(name: 'event_time') required DateTime eventTime,
  }) = ExtractedNote;

  factory ExtractedEvent.fromJson(Map<String, Object?> json) =>
      _$ExtractedEventFromJson(json);
}

extension ExtractedEventX on ExtractedEvent {
  /// Property accessor — every variant carries these common fields.
  String get eventId => switch (this) {
    ExtractedVitalSign(:final eventId) => eventId,
    ExtractedMedicationAdministered(:final eventId) => eventId,
    ExtractedDispo(:final eventId) => eventId,
    ExtractedNote(:final eventId) => eventId,
  };

  double get confidence => switch (this) {
    ExtractedVitalSign(:final confidence) => confidence,
    ExtractedMedicationAdministered(:final confidence) => confidence,
    ExtractedDispo(:final confidence) => confidence,
    ExtractedNote(:final confidence) => confidence,
  };

  String get sourceUtterance => switch (this) {
    ExtractedVitalSign(:final sourceUtterance) => sourceUtterance,
    ExtractedMedicationAdministered(:final sourceUtterance) => sourceUtterance,
    ExtractedDispo(:final sourceUtterance) => sourceUtterance,
    ExtractedNote(:final sourceUtterance) => sourceUtterance,
  };

  List<String> get sourceTranscriptIds => switch (this) {
    ExtractedVitalSign(:final sourceTranscriptIds) => sourceTranscriptIds,
    ExtractedMedicationAdministered(:final sourceTranscriptIds) =>
      sourceTranscriptIds,
    ExtractedDispo(:final sourceTranscriptIds) => sourceTranscriptIds,
    ExtractedNote(:final sourceTranscriptIds) => sourceTranscriptIds,
  };

  DateTime get extractedAt => switch (this) {
    ExtractedVitalSign(:final extractedAt) => extractedAt,
    ExtractedMedicationAdministered(:final extractedAt) => extractedAt,
    ExtractedDispo(:final extractedAt) => extractedAt,
    ExtractedNote(:final extractedAt) => extractedAt,
  };

  DateTime get eventTime => switch (this) {
    ExtractedVitalSign(:final eventTime) => eventTime,
    ExtractedMedicationAdministered(:final eventTime) => eventTime,
    ExtractedDispo(:final eventTime) => eventTime,
    ExtractedNote(:final eventTime) => eventTime,
  };

  WireEventType get eventType => switch (this) {
    ExtractedVitalSign() => WireEventType.vitalSign,
    ExtractedMedicationAdministered() => WireEventType.medicationAdministered,
    ExtractedDispo() => WireEventType.dispo,
    ExtractedNote() => WireEventType.note,
  };

  /// Serialize using the freezed-generated discriminator output.
  /// Wraps [ExtractedEvent.toJson] so call-sites have a stable name even
  /// if we later swap discrimination strategies.
  Map<String, Object?> toContractJson() => toJson();
}

/// UI-facing confidence bucket per AGENTS.md: green ≥0.9, yellow 0.7–0.9, red <0.7.
enum ConfidenceBand { high, medium, low }

extension ConfidenceBandX on double {
  ConfidenceBand get confidenceBand {
    if (this >= 0.9) return ConfidenceBand.high;
    if (this >= 0.7) return ConfidenceBand.medium;
    return ConfidenceBand.low;
  }
}
