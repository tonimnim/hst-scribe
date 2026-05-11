import 'package:flutter/foundation.dart';

/// Build environment for the app.
///
/// Drives feature flags, log verbosity, and which crash-reporting DSN we use.
enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.dev;
    }
  }
}

/// Immutable runtime configuration.
///
/// Three layers of precedence (highest wins):
///  1. MDM-supplied managed app config (Intune / Jamf). Not yet wired —
///     see [AppConfig.fromMdm] skeleton; reads from a platform channel
///     in a real build.
///  2. `--dart-define` values supplied at build time.
///  3. Hard-coded fallback defaults appropriate for local dev.
///
/// PHI safety: this class holds only non-PHI server endpoints + environment.
/// Never put a tenant secret here.
@immutable
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.wssBaseUrl,
    required this.environment,
    required this.sentryDsn,
    required this.idpClientId,
    required this.idpAuthorizationUrl,
    required this.idpTokenUrl,
    required this.idpRedirectUri,
    required this.appLockIdleTimeout,
    required this.sessionIdleTimeout,
    required this.useFakeAuth,
    required this.devJwtSecret,
  });

  /// Build config from `--dart-define` values.
  ///
  /// Example:
  /// ```
  /// flutter run \
  ///   --dart-define=API_BASE_URL=https://api.dev.hst-scribe.example \
  ///   --dart-define=WSS_BASE_URL=wss://api.dev.hst-scribe.example \
  ///   --dart-define=ENVIRONMENT=dev
  /// ```
  factory AppConfig.fromDartDefines() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.dev.hst-scribe.example',
    );
    const wssBaseUrl = String.fromEnvironment(
      'WSS_BASE_URL',
      defaultValue: 'wss://api.dev.hst-scribe.example',
    );
    const environmentRaw = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'dev',
    );
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    const idpClientId = String.fromEnvironment(
      'IDP_CLIENT_ID',
      defaultValue: 'hst-scribe-mobile-dev',
    );
    const idpAuthorizationUrl = String.fromEnvironment(
      'IDP_AUTH_URL',
      defaultValue: 'https://idp.dev.hst-scribe.example/oauth2/authorize',
    );
    const idpTokenUrl = String.fromEnvironment(
      'IDP_TOKEN_URL',
      defaultValue: 'https://idp.dev.hst-scribe.example/oauth2/token',
    );
    const idpRedirectUri = String.fromEnvironment(
      'IDP_REDIRECT_URI',
      defaultValue: 'com.hstpathways.hstscribe://oauth/callback',
    );
    const useFakeAuthRaw = String.fromEnvironment(
      'USE_FAKE_AUTH',
      defaultValue: '',
    );
    const devJwtSecret = String.fromEnvironment(
      'DEV_JWT_SECRET',
      defaultValue: 'dev-secret-do-not-use-in-prod',
    );

    final environment = AppEnvironment.fromString(environmentRaw);
    // Default: fake auth ON in dev, OFF in staging/prod. `--dart-define
    // USE_FAKE_AUTH=true|false` overrides explicitly.
    final useFakeAuth = useFakeAuthRaw.isEmpty
        ? environment == AppEnvironment.dev
        : useFakeAuthRaw.toLowerCase() == 'true';

    return AppConfig(
      apiBaseUrl: apiBaseUrl,
      wssBaseUrl: wssBaseUrl,
      environment: environment,
      sentryDsn: sentryDsn,
      idpClientId: idpClientId,
      idpAuthorizationUrl: idpAuthorizationUrl,
      idpTokenUrl: idpTokenUrl,
      idpRedirectUri: idpRedirectUri,
      appLockIdleTimeout: const Duration(minutes: 5),
      sessionIdleTimeout: const Duration(minutes: 30),
      useFakeAuth: useFakeAuth,
      devJwtSecret: devJwtSecret,
    );
  }

  /// Stub — Phase B will read managed-app-config from the native side
  /// (`NSUserDefaults.standard.dictionaryForKey('com.apple.configuration.managed')`
  /// on iOS, `RestrictionsManager` on Android) via a platform channel and
  /// merge over [base].
  ///
  /// Until that channel exists, this returns [base] unchanged.
  // ignore: prefer_const_constructors_in_immutables
  factory AppConfig.fromMdm(AppConfig base) {
    // TODO(mdm): wire `core/config/mdm_channel.dart` — tracked in PRD §MDM.
    return base;
  }

  final String apiBaseUrl;
  final String wssBaseUrl;
  final AppEnvironment environment;

  /// Empty string disables Sentry.
  final String sentryDsn;

  // OAuth2 + PKCE
  final String idpClientId;
  final String idpAuthorizationUrl;
  final String idpTokenUrl;
  final String idpRedirectUri;

  /// FR — App locks after this much foreground inactivity.
  final Duration appLockIdleTimeout;

  /// FR — Session auto-ends after this much idle (with warning 5min prior).
  final Duration sessionIdleTimeout;

  /// When true, the auth flow uses [DevFakeOauthPkceFlow] and mints a local
  /// HS256 JWT signed with [devJwtSecret] instead of round-tripping to an
  /// IdP. Defaults to `true` in dev and `false` everywhere else.
  ///
  /// **Hard rule:** must be `false` in prod. The build pipeline asserts this.
  final bool useFakeAuth;

  /// Shared secret used by [DevFakeOauthPkceFlow] to sign the local JWT.
  /// Matches the dev gateway's `DEV_JWT_SECRET` env so the fake token validates.
  /// Never used in staging or prod.
  final String devJwtSecret;

  bool get isProd => environment == AppEnvironment.prod;
  bool get isDev => environment == AppEnvironment.dev;
  bool get debugLogging => !isProd || kDebugMode;
}
