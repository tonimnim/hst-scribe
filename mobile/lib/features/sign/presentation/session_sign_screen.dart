import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/features/patient/domain/patient_context_model.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';
import 'package:hst_scribe/widgets/patient_banner.dart';

class SessionSignScreen extends ConsumerWidget {
  const SessionSignScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // TODO(session): replace with provider-supplied patient context.
    const placeholder = PatientContextModel(
      patientId: '00000000-0000-0000-0000-000000000000',
      displayNameInitials: 'J.D.',
      mrnLast4: '4821',
      procedure: 'Right knee arthroscopy',
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const PatientBanner(patient: placeholder),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FilledButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n.signBiometric),
                    onPressed: () {
                      // TODO(sign): local_auth biometric prompt → POST /sign.
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.pin),
                    label: Text(l10n.signPin),
                    onPressed: () {
                      // TODO(sign): show PIN entry sheet.
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
