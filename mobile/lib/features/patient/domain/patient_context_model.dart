import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/contract/patient_context.dart' as wire;

part 'patient_context_model.freezed.dart';

/// Domain-layer patient context.
///
/// Distinct from `core/contract/PatientContext` so changes to the wire shape
/// don't ripple into widgets. Map at the data layer with [fromWire].
@freezed
class PatientContextModel with _$PatientContextModel {
  const factory PatientContextModel({
    required String patientId,
    required String displayNameInitials,
    required String mrnLast4,
    required String procedure,
    @Default(<MedicationSummaryModel>[])
    List<MedicationSummaryModel> currentMedications,
    @Default(<AllergyModel>[]) List<AllergyModel> allergies,
    @Default(<String>[]) List<String> comorbidities,
  }) = _PatientContextModel;

  const PatientContextModel._();

  factory PatientContextModel.fromWire(wire.PatientContext w) =>
      PatientContextModel(
        patientId: w.patientId,
        displayNameInitials: w.displayNameInitials,
        mrnLast4: w.mrnLast4,
        procedure: w.procedure,
        currentMedications: <MedicationSummaryModel>[
          for (final m in w.currentMedications)
            MedicationSummaryModel(
              rxnormCode: m.rxnormCode,
              name: m.name,
              dose: m.dose,
              route: m.route,
            ),
        ],
        allergies: <AllergyModel>[
          for (final a in w.allergies)
            AllergyModel(name: a.name, severity: a.severity),
        ],
        comorbidities: w.comorbidities,
      );

  /// Convenience: the only patient-identifying text we ever render on
  /// the banner. Safe to pass through logger as long as it stays in this
  /// shape (initials + last4 + procedure are not PHI by themselves per
  /// CONTRACT.md §1).
  String get bannerSummary =>
      '$displayNameInitials · MRN ••••$mrnLast4 · $procedure';
}

@freezed
class MedicationSummaryModel with _$MedicationSummaryModel {
  const factory MedicationSummaryModel({
    required String rxnormCode,
    required String name,
    required String dose,
    required String route,
  }) = _MedicationSummaryModel;
}

@freezed
class AllergyModel with _$AllergyModel {
  const factory AllergyModel({required String name, required String severity}) =
      _AllergyModel;
}
