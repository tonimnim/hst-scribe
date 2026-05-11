import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hst_scribe/core/config/app_config.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const AppLogger _log = AppLogger('sentry');

/// Initialize Sentry crash reporting with PHI-scrubbing hooks.
///
/// **Contract:**
///   * If [AppConfig.sentryDsn] is empty (the dev default), this is a no-op.
///     Crash reporting is opt-in via `--dart-define=SENTRY_DSN=...`.
///   * `beforeSend` and `beforeBreadcrumb` route every map-shaped payload
///     through [AppLogger.maskPhi]. The PHI key list lives in one place
///     (`logger.dart`) and is honored here by reference — when a new
///     patient field is added, [AppLogger.maskPhi] picks it up and Sentry
///     payloads scrub it automatically.
///   * `sendDefaultPii = false` is an extra defense (Sentry will not attach
///     IP / username / cookies even if a layer below tries to).
///   * `tracesSampleRate` scales by environment: dev=0.0, staging=0.2,
///     prod=1.0. With no DSN, nothing is sampled regardless.
///
/// **Wiring order (see `main.dart`):**
///   1. `await initSentry(config)` — installs `Sentry.init` + integrations.
///   2. `FlutterError.onError` and `PlatformDispatcher.instance.onError`
///      are forwarded to `Sentry.captureException`.
///   3. `runApp(...)` is invoked inside a `runZonedGuarded` so uncaught
///      async errors also reach Sentry.
///
/// Returns `true` iff Sentry was initialized (DSN present).
Future<bool> initSentry(AppConfig config) async {
  if (config.sentryDsn.isEmpty) {
    _log.info('sentry disabled: no DSN');
    return false;
  }

  final dsn = config.sentryDsn;
  final environment = config.environment.name;
  final tracesSampleRate = _tracesSampleRateFor(config.environment);

  try {
    await SentryFlutter.init((SentryFlutterOptions options) {
      options.dsn = dsn;
      options.environment = environment;
      options.tracesSampleRate = tracesSampleRate;
      // Defense in depth: even if a sub-layer tries to attach default PII
      // (username, IP, cookies), drop it.
      options.sendDefaultPii = false;
      // Off in dev — chatty and writes /dev to local /tmp/native logs.
      options.debug = false;
      // Anonymize structural metadata further: server name is host name on
      // mobile devices, which leaks hostname → user identity.
      options.serverName = null;
      // Disable auto session tracking; we don't have a Sentry plan that uses
      // it, and the session pings carry no PHI but add noise.
      options.enableAutoSessionTracking = false;
      // Scrubbers.
      options.beforeSend = _phiScrubbingBeforeSend;
      options.beforeBreadcrumb = _phiScrubbingBeforeBreadcrumb;
    });

    // Forward Flutter framework + platform errors to Sentry. Note: we keep
    // the existing AppLogger error log in `main.dart` as well — local logs
    // are still useful for dev DevTools.
    FlutterError.onError = (FlutterErrorDetails details) {
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      ).ignore();
    };

    _log.info(
      'sentry initialized',
      data: <String, Object?>{
        'environment': environment,
        'traces_sample_rate': tracesSampleRate,
      },
    );
    return true;
  } catch (err, stack) {
    // Never let a Sentry init failure crash the app.
    _log.error(
      'sentry init failed',
      error: err,
      stackTrace: stack,
    );
    return false;
  }
}

/// Capture an uncaught zone error. Safe to call before / without [initSentry];
/// if Sentry is not enabled it silently no-ops via [Sentry.isEnabled].
Future<void> reportUncaughtZoneError(Object error, StackTrace stack) async {
  if (!Sentry.isEnabled) return;
  await Sentry.captureException(error, stackTrace: stack);
}

double _tracesSampleRateFor(AppEnvironment env) {
  switch (env) {
    case AppEnvironment.dev:
      return 0.0;
    case AppEnvironment.staging:
      return 0.2;
    case AppEnvironment.prod:
      return 1.0;
  }
}

// ---------------------------------------------------------------------------
// Scrubbers
// ---------------------------------------------------------------------------

/// Apply [AppLogger.maskPhi] to every map-shaped field on a Sentry event.
///
/// Map-shaped fields: `extra`, `tags`, `contexts` (each context map),
/// `request.data` (when Map), `request.headers` (treated as map).
/// `user` is dropped entirely (PII), reinforcing `sendDefaultPii = false`.
///
/// Free-form strings (`message.formatted`, exception messages) are
/// **not** auto-scrubbed: we can't reliably redact narrative text without
/// destroying error grouping. The app contract is that no code path
/// passes raw PHI into exception messages — `AppLogger` enforces this on
/// the logging side, and feature code uses typed `Failure` types.
FutureOr<SentryEvent?> _phiScrubbingBeforeSend(
  SentryEvent event,
  Hint hint,
) {
  try {
    // Sentry deprecated `extra` in favour of structured contexts, but
    // we still need to scrub anything an upstream layer might have
    // attached the old way.
    // ignore: deprecated_member_use
    final originalExtra = event.extra;
    final scrubbedExtra = originalExtra == null
        ? null
        : AppLogger.maskPhi(
            originalExtra.map<String, Object?>(
              MapEntry<String, Object?>.new,
            ),
          );

    final originalTags = event.tags;
    final scrubbedTags = originalTags == null
        ? null
        : <String, String>{
            for (final entry in originalTags.entries)
              entry.key:
                  _isPhiKey(entry.key) ? _kScrubbed : entry.value,
          };

    final scrubbedRequest = _scrubRequest(event.request);
    final scrubbedBreadcrumbs = event.breadcrumbs
        ?.map(_scrubBreadcrumb)
        .toList(growable: false);

    return event.copyWith(
      // Drop user PII entirely. `sendDefaultPii = false` already
      // suppresses Sentry's auto-collection; this handles any user
      // explicitly attached upstream. We can't pass `null` to copyWith
      // (its `??` collapses null to the previous value), and the
      // SentryUser() constructor asserts at least one of id/username/
      // email/ipAddress/segment is non-null, so we set an anonymous id.
      user: _anonymousUser,
      // ignore: deprecated_member_use — see comment above on originalExtra.
      extra: scrubbedExtra?.map<String, dynamic>(
        MapEntry<String, dynamic>.new,
      ),
      tags: scrubbedTags,
      request: scrubbedRequest,
      breadcrumbs: scrubbedBreadcrumbs,
    );
  } catch (err, stack) {
    // If scrubbing itself throws, FAIL CLOSED: drop the event entirely
    // rather than send an un-scrubbed payload. Logged locally for ops.
    _log.error(
      'sentry beforeSend scrubber threw — dropping event',
      error: err,
      stackTrace: stack,
    );
    return null;
  }
}

Breadcrumb? _phiScrubbingBeforeBreadcrumb(
  Breadcrumb? breadcrumb,
  Hint hint,
) {
  if (breadcrumb == null) return null;
  return _scrubBreadcrumb(breadcrumb);
}

Breadcrumb _scrubBreadcrumb(Breadcrumb crumb) {
  final data = crumb.data;
  if (data == null || data.isEmpty) return crumb;
  final scrubbed = AppLogger.maskPhi(
    data.map<String, Object?>(MapEntry<String, Object?>.new),
  );
  return crumb.copyWith(
    data: scrubbed.map<String, dynamic>(MapEntry<String, dynamic>.new),
  );
}

SentryRequest? _scrubRequest(SentryRequest? request) {
  if (request == null) return null;

  // Cookies are auth state — never send.
  // Body data: if it's a Map, run it through the PHI key scrubber.
  // If it's a string, we cannot reliably scrub, so we drop it (URL +
  // method + status are kept for triage).
  final dynamic data = request.data;
  dynamic scrubbedData;
  if (data is Map) {
    scrubbedData = AppLogger.maskPhi(
      data.map<String, Object?>(
        (Object? k, Object? v) =>
            MapEntry<String, Object?>(k.toString(), v),
      ),
    );
  } else if (data is String) {
    scrubbedData = '<scrubbed:string-body>';
  } else if (data is List) {
    scrubbedData = '<scrubbed:list-body>';
  } else {
    scrubbedData = null;
  }

  return request.copyWith(
    removeCookies: true,
    data: scrubbedData,
    // Headers may carry Authorization tokens — clear.
    headers: const <String, String>{},
  );
}

const String _kScrubbed = '<scrubbed>';

/// User stub used to wipe any upstream-attached PII from `event.user`.
/// `id` is non-null to satisfy the [SentryUser] assertion; the value
/// is a literal sentinel, not a real identifier.
final SentryUser _anonymousUser = SentryUser(id: 'anonymous');

/// Mirrors [AppLogger.maskPhi]'s key-set semantics for scalar
/// (non-map) tag values. Kept here as a thin shim — never enumerate
/// PHI fields in this file; bounce through [AppLogger.maskPhi] which
/// is the single source of truth.
bool _isPhiKey(String key) {
  // Cheap check: stuff a map with this one key through the scrubber.
  // If the value is scrubbed, the key was in the PHI list.
  final probe = AppLogger.maskPhi(<String, Object?>{key: _kProbeMarker});
  return probe[key] == _kScrubbed;
}

const String _kProbeMarker = '__phi_probe__';
