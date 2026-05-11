import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/features/patient/domain/patient_context_model.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';
import 'package:hst_scribe/widgets/patient_banner.dart';

/// Session-start flow: scan wristband -> fetch patient context ->
/// confirm with the nurse -> POST /sessions -> route to capture.
///
/// This is a Phase A stub: it renders the banner against a placeholder
/// patient so layout + accessibility can be reviewed before the real
/// `POST /sessions` data layer lands.
class SessionStartScreen extends ConsumerWidget {
  const SessionStartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    const placeholder = PatientContextModel(
      patientId: '00000000-0000-0000-0000-000000000000',
      displayNameInitials: 'J.D.',
      mrnLast4: '4821',
      procedure: 'Right knee arthroscopy',
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionStartTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const PatientBanner(patient: placeholder),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.sessionStartConfirmPrompt,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FilledButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(l10n.sessionStartScanWristband),
                    onPressed: () {
                      // TODO(capture): wire mobile_scanner here.
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(l10n.sessionStartConfirm),
                    onPressed: () {
                      // TODO(session): POST /sessions and navigate to capture.
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.sessionStartCancel),
                    onPressed: () {
                      // TODO(session): clear scanned patient and reopen scanner.
                    },
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
