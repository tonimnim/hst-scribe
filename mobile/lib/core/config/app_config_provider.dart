import 'package:hst_scribe/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config_provider.g.dart';

/// Singleton runtime configuration. Built once at app start and immutable.
///
/// Override in tests via `ProviderScope(overrides: [appConfigProvider.overrideWithValue(...)])`.
@Riverpod(keepAlive: true)
AppConfig appConfig(AppConfigRef ref) =>
    AppConfig.fromMdm(AppConfig.fromDartDefines());
