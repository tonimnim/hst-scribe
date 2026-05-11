import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/features/patient/domain/patient_context_model.dart';
import 'package:hst_scribe/features/session/data/session_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_provider.g.dart';

/// Patient context for the currently-active session. Returns null when no
/// session is active — the banner widget hides itself in that case.
///
/// Wave-2 capture/events screens watch this to render the pinned banner.
@Riverpod(keepAlive: true)
PatientContextModel? activePatient(ActivePatientRef ref) {
  final session = ref.watch(activeSessionProvider);
  return session?.patientContext;
}
