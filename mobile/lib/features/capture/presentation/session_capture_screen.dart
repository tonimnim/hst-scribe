import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hst_scribe/app/router.dart';
import 'package:hst_scribe/core/contract/wss_messages.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/features/capture/data/capture_controller.dart';
import 'package:hst_scribe/features/capture/domain/capture_state.dart';
import 'package:hst_scribe/features/capture/presentation/transcript_pane.dart';
import 'package:hst_scribe/features/events/presentation/events_list.dart';
import 'package:hst_scribe/features/session/data/session_repository.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';
import 'package:hst_scribe/widgets/patient_banner.dart';

/// Live capture screen.
///
/// Layout:
///  * Tablet (>= 720dp wide):
///      [PatientBanner] (pinned top)
///      |  Transcript pane (flex 6)  | Event cards (flex 4) |
///      [Control bar]
///  * Phone fallback: tabs (transcript / events).
///
/// All async edges respect AGENTS.md:
///   * `mounted` check after every await
///   * No PHI in any log or analytics breadcrumb
///   * Touch targets ≥ 44pt; PTT button ≥ 72pt
class SessionCaptureScreen extends ConsumerStatefulWidget {
  const SessionCaptureScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<SessionCaptureScreen> createState() =>
      _SessionCaptureScreenState();
}

class _SessionCaptureScreenState extends ConsumerState<SessionCaptureScreen> {
  bool _voiceCommandsEnabled = false;

  @override
  void initState() {
    super.initState();
    // Start the capture loop on screen entry. The patient confirmation
    // step is the gate (router redirect / patient_confirm_screen handles
    // the lock). We trust the upstream guarantee.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final session = ref.read(activeSessionProvider);
      if (session == null || session.id != widget.sessionId) {
        // No session — bounce back to start.
        if (!mounted) return;
        context.goNamed(Routes.sessionStart);
        return;
      }
      await ref
          .read(captureControllerProvider(widget.sessionId).notifier)
          .startCapture();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(activeSessionProvider);

    // No session: render a placeholder and let initState bounce us.
    if (session == null || session.id != widget.sessionId) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.captureTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final captureState = ref.watch(captureControllerProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.captureTitle)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            PatientBanner(patient: session.patientContext),
            if (captureState is ErrorCaptureState)
              _ConnectionBanner(failure: captureState.failure),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  if (isWide) {
                    return Row(
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: TranscriptPane(sessionId: widget.sessionId),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          flex: 4,
                          child: EventsList(sessionId: widget.sessionId),
                        ),
                      ],
                    );
                  }
                  return _PhoneTabs(sessionId: widget.sessionId);
                },
              ),
            ),
            _CaptureControlBar(
              sessionId: widget.sessionId,
              voiceCommandsEnabled: _voiceCommandsEnabled,
              onToggleVoiceCommands: (bool enabled) {
                setState(() => _voiceCommandsEnabled = enabled);
              },
              onEndSession: _onEndSession,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onEndSession() async {
    final session = ref.read(activeSessionProvider);
    if (session == null) return;
    await ref
        .read(captureControllerProvider(widget.sessionId).notifier)
        .endSession();
    if (!mounted) return;
    context.goNamed(
      Routes.sessionSign,
      pathParameters: <String, String>{'sessionId': session.id},
    );
  }
}

class _PhoneTabs extends StatelessWidget {
  const _PhoneTabs({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.subtitles), text: 'Transcript'),
              Tab(icon: Icon(Icons.event_note_outlined), text: 'Events'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                TranscriptPane(sessionId: sessionId),
                EventsList(sessionId: sessionId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final message = switch (failure) {
      WireAppFailure(:final message) => message,
      NetworkAppFailure() => l10n.captureReconnecting,
      PlatformAppFailure(:final code) when code == 'mic_permission_denied' =>
        l10n.captureMicDenied,
      PlatformAppFailure(:final message) => message,
      UnauthenticatedAppFailure() => l10n.errorAuthInvalid,
      UnexpectedAppFailure() => l10n.errorUnexpected,
    };
    return Container(
      color: theme.colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(Icons.warning_amber, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureControlBar extends ConsumerWidget {
  const _CaptureControlBar({
    required this.sessionId,
    required this.voiceCommandsEnabled,
    required this.onToggleVoiceCommands,
    required this.onEndSession,
  });

  final String sessionId;
  final bool voiceCommandsEnabled;
  final ValueChanged<bool> onToggleVoiceCommands;
  final Future<void> Function() onEndSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final captureState = ref.watch(captureControllerProvider(sessionId));
    final controller = ref.read(captureControllerProvider(sessionId).notifier);

    final isListening = captureState is ListeningCaptureState;
    final isPaused = captureState is PausedCaptureState;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: <Widget>[
            // PTT button — large, ≥72pt per AGENTS.md.
            _PttButton(
              isListening: isListening,
              isPaused: isPaused,
              onPress: () async {
                if (isPaused) {
                  await controller.resumePtt();
                } else if (isListening) {
                  await controller.pausePtt();
                } else {
                  await controller.startCapture();
                }
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  _VoiceCommandToggle(
                    enabled: voiceCommandsEnabled,
                    onToggle: onToggleVoiceCommands,
                    onConfirmLast:
                        () => controller.handleVoiceCommand(
                          VoiceCommand.confirmLast,
                        ),
                    onStrikeLast:
                        () => controller.handleVoiceCommand(
                          VoiceCommand.strikeLast,
                        ),
                  ),
                  Semantics(
                    button: true,
                    label: l10n.captureEnd,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.stop),
                      label: Text(l10n.captureEnd),
                      onPressed: onEndSession,
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

class _PttButton extends StatelessWidget {
  const _PttButton({
    required this.isListening,
    required this.isPaused,
    required this.onPress,
  });

  final bool isListening;
  final bool isPaused;
  final Future<void> Function() onPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final (IconData icon, String label, Color color) =
        isListening
            ? (
              Icons.pause_circle_filled,
              l10n.capturePause,
              theme.colorScheme.secondary,
            )
            : isPaused
            ? (Icons.mic, l10n.captureResume, theme.colorScheme.primary)
            : (
              Icons.mic_none,
              l10n.capturePushToTalk,
              theme.colorScheme.primary,
            );
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: 72,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: const Size(120, 72),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: Icon(icon, size: 28),
          label: Text(label),
          onPressed: onPress,
        ),
      ),
    );
  }
}

class _VoiceCommandToggle extends StatelessWidget {
  const _VoiceCommandToggle({
    required this.enabled,
    required this.onToggle,
    required this.onConfirmLast,
    required this.onStrikeLast,
  });

  final bool enabled;
  final ValueChanged<bool> onToggle;
  final Future<void> Function() onConfirmLast;
  final Future<void> Function() onStrikeLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip:
          enabled ? l10n.captureVoiceCommandsOn : l10n.captureVoiceCommandsOff,
      icon: Icon(
        enabled ? Icons.record_voice_over : Icons.voice_over_off_outlined,
        size: 28,
      ),
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            CheckedPopupMenuItem<String>(
              value: 'toggle',
              checked: enabled,
              child: Text(
                enabled
                    ? l10n.captureVoiceCommandsOn
                    : l10n.captureVoiceCommandsOff,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'confirm_last',
              enabled: enabled,
              child: const Text('Confirm last'),
            ),
            PopupMenuItem<String>(
              value: 'strike_last',
              enabled: enabled,
              child: const Text('Strike last'),
            ),
          ],
      onSelected: (String value) async {
        switch (value) {
          case 'toggle':
            onToggle(!enabled);
          case 'confirm_last':
            await onConfirmLast();
          case 'strike_last':
            await onStrikeLast();
        }
      },
    );
  }
}
