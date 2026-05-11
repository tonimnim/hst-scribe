import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hst_scribe/app/router.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';

/// Splash / boot screen. Reads the auth state and forwards to either
/// the login screen or the session list.
///
/// TODO(auth): replace the timer-based redirect with a real `authStateProvider`
/// once the auth feature is wired in Phase B.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Phase A: always send the nurse to the login screen.
      // Phase B: read auth state and route to /sessions if signed in.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      context.goNamed(Routes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.medical_services_outlined, size: 56),
            const SizedBox(height: 16),
            Text(l10n.appTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.splashLoading,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
