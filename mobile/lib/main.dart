import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/app/app.dart';
import 'package:hst_scribe/core/config/app_config.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:hst_scribe/core/obs/sentry.dart';

const AppLogger _bootLog = AppLogger('boot');

Future<void> main() async {
  // `runZonedGuarded` is the outermost layer so that any uncaught async
  // error during boot (config parse, secure-storage init, Sentry init
  // itself) reaches the crash reporter instead of being swallowed.
  await runZonedGuarded<Future<void>>(_boot, _onZoneError);
}

Future<void> _boot() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final config = AppConfig.fromMdm(AppConfig.fromDartDefines());

  // Sentry init must run BEFORE `runApp` so the scrubbers are wired
  // before the first Flutter frame can emit a breadcrumb. With no DSN
  // (dev default) this is a no-op and falls through immediately.
  final sentryEnabled = await initSentry(config);

  // Local AppLogger handler stays installed regardless of Sentry: dev
  // builds still want framework errors in DevTools, and if Sentry init
  // failed for any reason we don't lose visibility. If Sentry is on,
  // `initSentry` replaced FlutterError.onError with the Sentry forward;
  // we chain our local logger after that.
  final priorOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    _bootLog.error(
      'flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
      data: <String, Object?>{
        'library': details.library,
        'context': details.context?.toDescription(),
      },
    );
    priorOnError?.call(details);
  };

  _bootLog.info(
    'app starting',
    data: <String, Object?>{
      'environment': config.environment.name,
      'sentry_enabled': sentryEnabled,
    },
  );

  runApp(const ProviderScope(child: HstScribeApp()));
}

void _onZoneError(Object error, StackTrace stack) {
  // Log locally first — `reportUncaughtZoneError` is async and we
  // want at least one record on every channel before the process dies.
  _bootLog.error(
    'uncaught zone error',
    error: error,
    stackTrace: stack,
  );
  // Forward to Sentry. Fire-and-forget: the process may be dying.
  unawaited(reportUncaughtZoneError(error, stack));
}
