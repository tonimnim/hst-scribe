import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hst_scribe/app/router.dart';
import 'package:hst_scribe/features/patient/domain/patient_context_model.dart';
import 'package:hst_scribe/features/session/data/session_repository.dart';
import 'package:hst_scribe/features/session/domain/session.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';
import 'package:hst_scribe/widgets/patient_banner.dart';

/// Patient-confirmation step. The nurse sees the full patient context and
/// must explicitly confirm before audio capture is permitted.
///
/// Confirm  → set [ActiveSession] state to "ready" implicitly (we already
///            stored it on create) and navigate to capture.
/// Reject   → clear the active session and return to start.
///
/// CLAUDE.md guardrail: capture is impossible until the nurse confirms.
class PatientConfirmScreen extends ConsumerWidget {
  const PatientConfirmScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeSessionProvider);

    // If a deep-link or rebuild lands here with no in-memory session, we
    // route back to start rather than render a half-empty screen.
    if (active == null || active.id != sessionId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.goNamed(Routes.sessionStart);
      });
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionStartTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final patient = active.patientContext;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientConfirmTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PatientBanner(patient: patient),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                children: <Widget>[
                  _SectionLabel(text: l10n.patientConfirmProcedureSection),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        patient.procedure,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel(text: l10n.patientConfirmAllergiesSection),
                  _AllergiesCard(allergies: patient.allergies),
                  const SizedBox(height: 16),
                  _SectionLabel(text: l10n.patientConfirmMedsSection),
                  _MedicationsCard(meds: patient.currentMedications),
                  const SizedBox(height: 16),
                  if (patient.comorbidities.isNotEmpty) ...<Widget>[
                    _SectionLabel(text: l10n.patientConfirmComorbiditiesSection),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            for (final String c in patient.comorbidities)
                              Chip(label: Text(c)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(l10n.patientConfirmYes),
                    onPressed: () => _onConfirm(context, active),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(l10n.patientConfirmNo),
                    onPressed: () => _onReject(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onConfirm(BuildContext context, Session session) {
    context.goNamed(
      Routes.sessionCapture,
      pathParameters: <String, String>{'sessionId': session.id},
    );
  }

  void _onReject(BuildContext context, WidgetRef ref) {
    ref.read(activeSessionProvider.notifier).clear();
    context.goNamed(Routes.sessionStart);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AllergiesCard extends StatelessWidget {
  const _AllergiesCard({required this.allergies});

  final List<AllergyModel> allergies;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (allergies.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.patientConfirmAllergiesNone),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final AllergyModel a in allergies)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.warning_amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(a.name)),
                    Chip(
                      label: Text(a.severity),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MedicationsCard extends StatelessWidget {
  const _MedicationsCard({required this.meds});

  final List<MedicationSummaryModel> meds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (meds.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.patientConfirmMedsNone),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final MedicationSummaryModel m in meds)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.medication_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            m.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${m.dose} · ${m.route}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
