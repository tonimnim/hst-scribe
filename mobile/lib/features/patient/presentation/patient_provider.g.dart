// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activePatientHash() => r'cf034de2480839cf657d3b7d1f11b1236a5d6ea4';

/// Patient context for the currently-active session. Returns null when no
/// session is active — the banner widget hides itself in that case.
///
/// Wave-2 capture/events screens watch this to render the pinned banner.
///
/// Copied from [activePatient].
@ProviderFor(activePatient)
final activePatientProvider = Provider<PatientContextModel?>.internal(
  activePatient,
  name: r'activePatientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activePatientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivePatientRef = ProviderRef<PatientContextModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
