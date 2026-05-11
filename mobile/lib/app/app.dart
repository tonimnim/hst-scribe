import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/app/router.dart';
import 'package:hst_scribe/app/theme.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';

/// Root of the application. `ProviderScope` is mounted in `main.dart`,
/// not here, so tests can wrap [HstScribeApp] in their own scope with
/// overrides.
class HstScribeApp extends ConsumerWidget {
  const HstScribeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'HST Scribe',
      restorationScopeId: 'hst_scribe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? child) {
        // Cap text scale at 2.0 — clinical UIs must remain readable, but
        // unbounded text scaling breaks dense data layouts.
        final mq = MediaQuery.of(context);
        final clampedScaler = mq.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 2.0,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clampedScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
