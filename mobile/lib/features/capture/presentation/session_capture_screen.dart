import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/features/patient/domain/patient_context_model.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';
import 'package:hst_scribe/widgets/patient_banner.dart';

/// Live capture screen — transcript on the left (60%), event cards on
/// the right (40%) on tablets; stacked on phones.
///
/// Phase A: renders the patient banner and the layout shell. Real
/// transcript pane + event-card column land with the capture and events
/// feature implementations.
class SessionCaptureScreen extends ConsumerWidget {
  const SessionCaptureScreen({required this.sessionId, super.key});

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
      appBar: AppBar(title: Text(l10n.captureTitle)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const PatientBanner(patient: placeholder),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  if (isWide) {
                    return const Row(
                      children: <Widget>[
                        Expanded(flex: 6, child: _TranscriptPanePlaceholder()),
                        VerticalDivider(width: 1),
                        Expanded(flex: 4, child: _EventColumnPlaceholder()),
                      ],
                    );
                  }
                  return const Column(
                    children: <Widget>[
                      Expanded(child: _TranscriptPanePlaceholder()),
                      Divider(height: 1),
                      Expanded(child: _EventColumnPlaceholder()),
                    ],
                  );
                },
              ),
            ),
            const _CaptureControlBar(),
          ],
        ),
      ),
    );
  }
}

class _TranscriptPanePlaceholder extends StatelessWidget {
  const _TranscriptPanePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Transcript pane — TODO(capture)',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _EventColumnPlaceholder extends StatelessWidget {
  const _EventColumnPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Event cards — TODO(events)',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _CaptureControlBar extends StatelessWidget {
  const _CaptureControlBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FilledButton.icon(
              icon: const Icon(Icons.mic),
              label: Text(l10n.capturePushToTalk),
              onPressed: () {
                // TODO(capture): wire AudioCapture stream + WssConnection.
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.pause),
              label: Text(l10n.capturePause),
              onPressed: () {
                // TODO(capture): emit session_pause.
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.stop),
              label: Text(l10n.captureEnd),
              onPressed: () {
                // TODO(capture): emit session_end + navigate to sign.
              },
            ),
          ],
        ),
      ),
    );
  }
}
