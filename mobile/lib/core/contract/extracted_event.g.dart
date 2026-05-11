// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extracted_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VitalSignFieldsImpl _$$VitalSignFieldsImplFromJson(
  Map<String, dynamic> json,
) => _$VitalSignFieldsImpl(
  vitalType: $enumDecode(_$VitalTypeEnumMap, json['vital_type']),
  value: json['value'] as num,
  unit: json['unit'] as String,
);

Map<String, dynamic> _$$VitalSignFieldsImplToJson(
  _$VitalSignFieldsImpl instance,
) => <String, dynamic>{
  'vital_type': _$VitalTypeEnumMap[instance.vitalType]!,
  'value': instance.value,
  'unit': instance.unit,
};

const _$VitalTypeEnumMap = {
  VitalType.bloodPressureSystolic: 'blood_pressure_systolic',
  VitalType.bloodPressureDiastolic: 'blood_pressure_diastolic',
  VitalType.heartRate: 'heart_rate',
  VitalType.spo2: 'spo2',
  VitalType.respiratoryRate: 'respiratory_rate',
  VitalType.temperatureC: 'temperature_c',
  VitalType.temperatureF: 'temperature_f',
  VitalType.painScore: 'pain_score',
};

_$MedicationAdministeredFieldsImpl _$$MedicationAdministeredFieldsImplFromJson(
  Map<String, dynamic> json,
) => _$MedicationAdministeredFieldsImpl(
  medicationName: json['medication_name'] as String,
  rxnormCode: json['rxnorm_code'] as String,
  doseValue: json['dose_value'] as num,
  doseUnit: $enumDecode(_$DoseUnitEnumMap, json['dose_unit']),
  route: $enumDecode(_$MedicationRouteEnumMap, json['route']),
  indication: json['indication'] as String?,
);

Map<String, dynamic> _$$MedicationAdministeredFieldsImplToJson(
  _$MedicationAdministeredFieldsImpl instance,
) => <String, dynamic>{
  'medication_name': instance.medicationName,
  'rxnorm_code': instance.rxnormCode,
  'dose_value': instance.doseValue,
  'dose_unit': _$DoseUnitEnumMap[instance.doseUnit]!,
  'route': _$MedicationRouteEnumMap[instance.route]!,
  'indication': instance.indication,
};

const _$DoseUnitEnumMap = {
  DoseUnit.mg: 'mg',
  DoseUnit.mcg: 'mcg',
  DoseUnit.g: 'g',
  DoseUnit.ml: 'ml',
  DoseUnit.unit: 'unit',
};

const _$MedicationRouteEnumMap = {
  MedicationRoute.iv: 'iv',
  MedicationRoute.im: 'im',
  MedicationRoute.po: 'po',
  MedicationRoute.sublingual: 'sublingual',
  MedicationRoute.topical: 'topical',
  MedicationRoute.inhaled: 'inhaled',
  MedicationRoute.intranasal: 'intranasal',
  MedicationRoute.rectal: 'rectal',
  MedicationRoute.subcutaneous: 'subcutaneous',
};

_$DispoFieldsImpl _$$DispoFieldsImplFromJson(Map<String, dynamic> json) =>
    _$DispoFieldsImpl(
      dispositionType: $enumDecode(
        _$DispositionTypeEnumMap,
        json['disposition_type'],
      ),
      dischargeCriteriaMet: json['discharge_criteria_met'] as bool?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$DispoFieldsImplToJson(_$DispoFieldsImpl instance) =>
    <String, dynamic>{
      'disposition_type': _$DispositionTypeEnumMap[instance.dispositionType]!,
      'discharge_criteria_met': instance.dischargeCriteriaMet,
      'notes': instance.notes,
    };

const _$DispositionTypeEnumMap = {
  DispositionType.dischargeHome: 'discharge_home',
  DispositionType.transferToHospital: 'transfer_to_hospital',
  DispositionType.admitObservation: 'admit_observation',
  DispositionType.transferToFloor: 'transfer_to_floor',
};

_$NoteFieldsImpl _$$NoteFieldsImplFromJson(Map<String, dynamic> json) =>
    _$NoteFieldsImpl(
      noteText: json['note_text'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$NoteFieldsImplToJson(_$NoteFieldsImpl instance) =>
    <String, dynamic>{'note_text': instance.noteText, 'tags': instance.tags};

_$ExtractedVitalSignImpl _$$ExtractedVitalSignImplFromJson(
  Map<String, dynamic> json,
) => _$ExtractedVitalSignImpl(
  eventId: json['event_id'] as String,
  fields: VitalSignFields.fromJson(json['fields'] as Map<String, dynamic>),
  confidence: (json['confidence'] as num).toDouble(),
  sourceUtterance: json['source_utterance'] as String,
  sourceTranscriptIds: (json['source_transcript_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  extractedAt: DateTime.parse(json['extracted_at'] as String),
  eventTime: DateTime.parse(json['event_time'] as String),
  $type: json['event_type'] as String?,
);

Map<String, dynamic> _$$ExtractedVitalSignImplToJson(
  _$ExtractedVitalSignImpl instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'fields': instance.fields,
  'confidence': instance.confidence,
  'source_utterance': instance.sourceUtterance,
  'source_transcript_ids': instance.sourceTranscriptIds,
  'extracted_at': instance.extractedAt.toIso8601String(),
  'event_time': instance.eventTime.toIso8601String(),
  'event_type': instance.$type,
};

_$ExtractedMedicationAdministeredImpl
_$$ExtractedMedicationAdministeredImplFromJson(Map<String, dynamic> json) =>
    _$ExtractedMedicationAdministeredImpl(
      eventId: json['event_id'] as String,
      fields: MedicationAdministeredFields.fromJson(
        json['fields'] as Map<String, dynamic>,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      sourceUtterance: json['source_utterance'] as String,
      sourceTranscriptIds: (json['source_transcript_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      extractedAt: DateTime.parse(json['extracted_at'] as String),
      eventTime: DateTime.parse(json['event_time'] as String),
      $type: json['event_type'] as String?,
    );

Map<String, dynamic> _$$ExtractedMedicationAdministeredImplToJson(
  _$ExtractedMedicationAdministeredImpl instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'fields': instance.fields,
  'confidence': instance.confidence,
  'source_utterance': instance.sourceUtterance,
  'source_transcript_ids': instance.sourceTranscriptIds,
  'extracted_at': instance.extractedAt.toIso8601String(),
  'event_time': instance.eventTime.toIso8601String(),
  'event_type': instance.$type,
};

_$ExtractedDispoImpl _$$ExtractedDispoImplFromJson(Map<String, dynamic> json) =>
    _$ExtractedDispoImpl(
      eventId: json['event_id'] as String,
      fields: DispoFields.fromJson(json['fields'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
      sourceUtterance: json['source_utterance'] as String,
      sourceTranscriptIds: (json['source_transcript_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      extractedAt: DateTime.parse(json['extracted_at'] as String),
      eventTime: DateTime.parse(json['event_time'] as String),
      $type: json['event_type'] as String?,
    );

Map<String, dynamic> _$$ExtractedDispoImplToJson(
  _$ExtractedDispoImpl instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'fields': instance.fields,
  'confidence': instance.confidence,
  'source_utterance': instance.sourceUtterance,
  'source_transcript_ids': instance.sourceTranscriptIds,
  'extracted_at': instance.extractedAt.toIso8601String(),
  'event_time': instance.eventTime.toIso8601String(),
  'event_type': instance.$type,
};

_$ExtractedNoteImpl _$$ExtractedNoteImplFromJson(Map<String, dynamic> json) =>
    _$ExtractedNoteImpl(
      eventId: json['event_id'] as String,
      fields: NoteFields.fromJson(json['fields'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
      sourceUtterance: json['source_utterance'] as String,
      sourceTranscriptIds: (json['source_transcript_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      extractedAt: DateTime.parse(json['extracted_at'] as String),
      eventTime: DateTime.parse(json['event_time'] as String),
      $type: json['event_type'] as String?,
    );

Map<String, dynamic> _$$ExtractedNoteImplToJson(_$ExtractedNoteImpl instance) =>
    <String, dynamic>{
      'event_id': instance.eventId,
      'fields': instance.fields,
      'confidence': instance.confidence,
      'source_utterance': instance.sourceUtterance,
      'source_transcript_ids': instance.sourceTranscriptIds,
      'extracted_at': instance.extractedAt.toIso8601String(),
      'event_time': instance.eventTime.toIso8601String(),
      'event_type': instance.$type,
    };
