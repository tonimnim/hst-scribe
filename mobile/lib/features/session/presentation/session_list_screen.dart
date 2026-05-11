import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hst_scribe/app/router.dart';
import 'package:hst_scribe/core/auth/auth_providers.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';

/// Recent-sessions list. Contract has no list endpoint yet (CONTRACT.md §1
/// covers only POST/GET single session + sign), so this screen renders an
/// empty state with a "Start new session" CTA. Once the backend adds
/// `GET /sessions?asc_id=...` we replace [_EmptyState] with an AsyncValue
/// driven list.
class SessionListScreen extends ConsumerWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final claims = ref.watch(authClaimsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionListTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.sessionListSignOut,
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.goNamed(Routes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (claims != null) _SignedInChip(roleText: claims.role),
            const Expanded(child: _EmptyState()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.sessionListNewSession),
        onPressed: () => context.goNamed(Routes.sessionStart),
      ),
    );
  }
}

class _SignedInChip extends StatelessWidget {
  const _SignedInChip({required this.roleText});

  final String roleText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          avatar: const Icon(Icons.verified_user_outlined, size: 18),
          label: Text('${l10n.sessionListSignedInAs} $roleText'),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.history_toggle_off,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.sessionListEmpty,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
