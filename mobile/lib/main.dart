import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/app/app.dart';
import 'package:hst_scribe/core/obs/logger.dart';

const AppLogger _bootLog = AppLogger('boot');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

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
  };

  _bootLog.info('app starting');

  runApp(const ProviderScope(child: HstScribeApp()));
}
