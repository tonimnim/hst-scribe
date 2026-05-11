// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicationSummaryImpl _$$MedicationSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$MedicationSummaryImpl(
  rxnormCode: json['rxnorm_code'] as String,
  name: json['name'] as String,
  dose: json['dose'] as String,
  route: json['route'] as String,
);

Map<String, dynamic> _$$MedicationSummaryImplToJson(
  _$MedicationSummaryImpl instance,
) => <String, dynamic>{
  'rxnorm_code': instance.rxnormCode,
  'name': instance.name,
  'dose': instance.dose,
  'route': instance.route,
};

_$AllergySummaryImpl _$$AllergySummaryImplFromJson(Map<String, dynamic> json) =>
    _$AllergySummaryImpl(
      name: json['name'] as String,
      severity: json['severity'] as String,
    );

Map<String, dynamic> _$$AllergySummaryImplToJson(
  _$AllergySummaryImpl instance,
) => <String, dynamic>{'name': instance.name, 'severity': instance.severity};

_$PatientContextImpl _$$PatientContextImplFromJson(Map<String, dynamic> json) =>
    _$PatientContextImpl(
      patientId: json['patient_id'] as String,
      displayNameInitials: json['display_name_initials'] as String,
      mrnLast4: json['mrn_last4'] as String,
      procedure: json['procedure'] as String,
      currentMedications:
          (json['current_medications'] as List<dynamic>?)
              ?.map(
                (e) => MedicationSummary.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <MedicationSummary>[],
      allergies:
          (json['allergies'] as List<dynamic>?)
              ?.map((e) => AllergySummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AllergySummary>[],
      comorbidities:
          (json['comorbidities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$PatientContextImplToJson(
  _$PatientContextImpl instance,
) => <String, dynamic>{
  'patient_id': instance.patientId,
  'display_name_initials': instance.displayNameInitials,
  'mrn_last4': instance.mrnLast4,
  'procedure': instance.procedure,
  'current_medications': instance.currentMedications,
  'allergies': instance.allergies,
  'comorbidities': instance.comorbidities,
};
