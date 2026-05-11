import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/core/auth/auth_providers.dart';
import 'package:hst_scribe/core/config/app_config.dart';
import 'package:hst_scribe/core/config/app_config_provider.dart';
import 'package:hst_scribe/features/auth/domain/auth_state.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';

/// Sign-in screen. Single primary action: kick off the OAuth flow via
/// [AuthController.signIn]. Routing is handled centrally by the auth gate
/// in `app/router.dart` — this widget never calls `context.go` itself.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (config.useFakeAuth) _DevBanner(config: config),
                  if (config.useFakeAuth) const SizedBox(height: 16),
                  Icon(
                    Icons.medical_services_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _SignInButton(asyncState: auth),
                  const SizedBox(height: 16),
                  _AuthFailureNotice(asyncState: auth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends ConsumerWidget {
  const _SignInButton({required this.asyncState});

  final AsyncValue<AuthState> asyncState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isLoading = asyncState.isLoading;
    return FilledButton.icon(
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.login),
      label: Text(l10n.loginButton),
      onPressed: isLoading
          ? null
          : () async {
              await ref.read(authControllerProvider.notifier).signIn();
            },
    );
  }
}

/// Surfaces the reason for the most recent unauthenticated transition
/// (e.g. silent refresh failed). Only shown when we have a typed failure
/// to render — never echoes raw error strings.
class _AuthFailureNotice extends StatelessWidget {
  const _AuthFailureNotice({required this.asyncState});

  final AsyncValue<AuthState> asyncState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = asyncState.valueOrNull;
    if (value is! UnauthenticatedAuthState) return const SizedBox.shrink();
    if (value.failure == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.errorAuthInvalid,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevBanner extends StatelessWidget {
  const _DevBanner({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.loginDevModeBanner,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.science_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.loginDevModeBanner} (${config.environment.name})',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
