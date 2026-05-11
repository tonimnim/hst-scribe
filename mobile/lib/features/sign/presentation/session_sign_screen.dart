import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hst_scribe/app/router.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/features/events/data/events_controller.dart';
import 'package:hst_scribe/features/session/data/session_repository.dart';
import 'package:hst_scribe/features/sign/data/sign_controller.dart';
import 'package:hst_scribe/features/sign/domain/sign_state.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';
import 'package:hst_scribe/widgets/patient_banner.dart';

/// End-of-session sign-off screen.
///
/// Sections (top → bottom):
///   1. Patient banner pinned.
///   2. Counts summary: confirmed / rejected / pending drafts.
///   3. CTA. Blocks sign-off if any drafts are pending — explicit
///      "Review remaining" CTA bounces back to the capture screen.
///   4. Biometric or PIN prompt.
///   5. Success card with eventsWritten count and "Done".
///
/// PHI safety: never logs patient initials, MRN, or transcript. The
/// patient banner widget itself only renders initials + last4 + procedure.
class SessionSignScreen extends ConsumerWidget {
  const SessionSignScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(activeSessionProvider);
    final counts = ref.watch(eventCountsProvider(sessionId));
    final signState = ref.watch(signControllerProvider(sessionId));

    if (session == null || session.id != sessionId) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.signTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PatientBanner(patient: session.patientContext),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _SummaryCard(counts: counts),
                    const SizedBox(height: 16),
                    _SignArea(
                      sessionId: sessionId,
                      counts: counts,
                      signState: signState,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.counts});

  final EventCounts counts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Session summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _CountRow(
              icon: Icons.check_circle,
              color: theme.colorScheme.tertiary,
              label: l10n.signSummaryConfirmed,
              count: counts.confirmed + counts.edited,
            ),
            const SizedBox(height: 8),
            _CountRow(
              icon: Icons.cancel,
              color: theme.colorScheme.error,
              label: l10n.signSummaryRejected,
              count: counts.rejected,
            ),
            const SizedBox(height: 8),
            _CountRow(
              icon: Icons.hourglass_empty,
              color: theme.colorScheme.secondary,
              label: l10n.signSummaryDraftsPending,
              count: counts.pending,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(
          '$count',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SignArea extends ConsumerWidget {
  const _SignArea({
    required this.sessionId,
    required this.counts,
    required this.signState,
  });

  final String sessionId;
  final EventCounts counts;
  final SignState signState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final local = signState;
    if (local is SuccessSignState) {
      return _SuccessCard(signed: local.signed, sessionId: sessionId);
    }

    // Hard block: drafts still pending. Show a CTA back to capture.
    if (counts.hasPending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.warning_amber,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.signBlockUntilResolved,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Review remaining'),
                    onPressed:
                        () => context.goNamed(
                          Routes.sessionCapture,
                          pathParameters: <String, String>{
                            'sessionId': sessionId,
                          },
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _AuthFlow(sessionId: sessionId, signState: signState);
  }
}

/// The auth subtree. Branches on [SignState]:
///   * idle       → big "Sign session" button → calls beginSign()
///   * prompting* → render either biometric prompt or PIN entry
///   * submitting → spinner
///   * error      → banner + retry
class _AuthFlow extends ConsumerWidget {
  const _AuthFlow({required this.sessionId, required this.signState});

  final String sessionId;
  final SignState signState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    final controller = ref.read(signControllerProvider(sessionId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (signState is IdleSignState) ...<Widget>[
          _SignCta(
            label: biometricAvailable ? l10n.signBiometric : l10n.signPin,
            icon: biometricAvailable ? Icons.fingerprint : Icons.pin,
            onPressed: () => controller.beginSign(),
          ),
          if (biometricAvailable) ...<Widget>[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.pin),
              label: Text(l10n.signPin),
              onPressed: () => controller.beginSign(forcePin: true),
            ),
          ],
        ],
        if (signState is PromptingBiometricSignState)
          _BiometricPanel(sessionId: sessionId),
        if (signState is PromptingPinSignState) _PinPanel(sessionId: sessionId),
        if (signState is SubmittingSignState)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
        if (signState is ErrorSignState) ...<Widget>[
          _ErrorPanel(failure: (signState as ErrorSignState).failure),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: controller.reset,
            child: const Text('Try again'),
          ),
        ],
        // (Intentionally no else — the sealed states above cover everything.)
      ],
    );
  }
}

class _SignCta extends StatelessWidget {
  const _SignCta({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: 72,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size(120, 72),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: Icon(icon, size: 28),
          label: Text(label),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// Biometric prompt.
///
/// Wave 1: [biometricAvailableProvider] is hard-coded false because
/// `local_auth` is disabled in pubspec.yaml. This panel therefore exists
/// only as a forward-compatibility placeholder; the controller's
/// [SignController.beginSign] short-circuits straight to PIN when the
/// flag is false, so we never actually mount it.
///
/// When agent 3 re-enables `local_auth`, flip [_biometricAvailable] in
/// `sign_controller.dart` and wire the real `LocalAuthentication`
/// invocation here.
class _BiometricPanel extends ConsumerStatefulWidget {
  const _BiometricPanel({required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<_BiometricPanel> createState() => _BiometricPanelState();
}

class _BiometricPanelState extends ConsumerState<_BiometricPanel> {
  bool _prompted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  Future<void> _prompt() async {
    if (_prompted) return;
    _prompted = true;
    // TODO(local_auth): when agent 3 re-enables `local_auth`, call:
    //   final auth = LocalAuthentication();
    //   final didAuth = await auth.authenticate(
    //     localizedReason: AppLocalizations.of(context).signBiometricPrompt,
    //     options: const AuthenticationOptions(biometricOnly: true),
    //   );
    //   if (!didAuth) controller.fallbackToPin();
    //   else controller.submit(authMethod: 'biometric', authToken: '...');
    // For now, immediately fall back to PIN since the dep is disabled.
    if (!mounted) return;
    ref.read(signControllerProvider(widget.sessionId).notifier).fallbackToPin();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Icon(Icons.fingerprint, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.signBiometricPrompt,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed:
                  () =>
                      ref
                          .read(
                            signControllerProvider(widget.sessionId).notifier,
                          )
                          .fallbackToPin(),
              child: Text(l10n.signPin),
            ),
          ],
        ),
      ),
    );
  }
}

/// 6-digit PIN entry. Numeric keypad + autofocus on the field.
class _PinPanel extends ConsumerStatefulWidget {
  const _PinPanel({required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<_PinPanel> createState() => _PinPanelState();
}

class _PinPanelState extends ConsumerState<_PinPanel> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const int _pinLength = 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.signPinPrompt,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: _pinLength,
              autofillHints: const <String>[AutofillHints.password],
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_pinLength),
              ],
              style: const TextStyle(
                fontSize: 32,
                letterSpacing: 8,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(counterText: ''),
              onSubmitted: (String v) => _onSubmit(v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Sign'),
              onPressed: () => _onSubmit(_ctrl.text),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit(String pin) async {
    if (pin.length != _pinLength) return;
    final controller = ref.read(
      signControllerProvider(widget.sessionId).notifier,
    );
    await controller.submit(authMethod: 'pin', authToken: pin);
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (failure) {
      WireAppFailure(:final message) => message,
      NetworkAppFailure() => l10n.errorNetwork,
      UnauthenticatedAppFailure() => l10n.errorAuthInvalid,
      PlatformAppFailure(:final message) => message,
      UnexpectedAppFailure() => l10n.errorUnexpected,
    };
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessCard extends ConsumerWidget {
  const _SuccessCard({required this.signed, required this.sessionId});

  final SignedSession signed;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.check_circle_outline,
              size: 56,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.signSuccess,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${signed.eventsWritten} events written to chart.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (signed.eventsRejected > 0) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                '${signed.eventsRejected} rejected.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                // Clear the active session and bounce to the list.
                ref.read(activeSessionProvider.notifier).clear();
                context.goNamed(Routes.sessionList);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
