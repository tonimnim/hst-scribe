import 'dart:async';

import 'package:hst_scribe/core/auth/token_store.dart';
import 'package:hst_scribe/core/config/app_config.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';

/// OAuth2 Authorization Code + PKCE flow against the HST IdP.
///
/// **Phase A (now):** skeleton only. [startInteractiveSignIn] returns a
/// dummy token bundle so the rest of the app (router redirects, REST client
/// auth header) can be wired up. The real flow needs a system browser
/// (ASWebAuthenticationSession / Custom Tab) plus a redirect-URI listener.
///
/// **Phase B:** add `flutter_appauth` (or implement the flow directly
/// against `dart:io` HTTP + a deep-link handler), wire the IdP endpoints
/// from [AppConfig], persist via [TokenStore].
class OauthPkceFlow {
  OauthPkceFlow({required AppConfig config, required TokenStore tokenStore})
    : _config = config,
      _tokenStore = tokenStore;

  // ignore: unused_field, prefer_final_fields
  final AppConfig _config;
  final TokenStore _tokenStore;
  static const AppLogger _log = AppLogger('OauthPkceFlow');

  /// **Phase A stub.** Returns a fixed dummy token so the app can boot.
  /// Real implementation in Phase B.
  Future<TokenBundle> startInteractiveSignIn() async {
    _log.warn('using Phase A dummy token bundle — replace before pilot');
    final now = DateTime.now().toUtc();
    final bundle = TokenBundle(
      accessToken: 'dev.access.${now.millisecondsSinceEpoch}',
      refreshToken: 'dev.refresh.${now.millisecondsSinceEpoch}',
      expiresAt: now.add(const Duration(minutes: 15)),
      userId: '00000000-0000-0000-0000-000000000001',
      ascId: '00000000-0000-0000-0000-000000000010',
      role: 'nurse',
    );
    await _tokenStore.write(bundle);
    return bundle;
  }

  /// **Phase A stub.** Real impl will call `POST /auth/refresh` with the
  /// stored refresh token and update the bundle.
  Future<TokenBundle> refresh() async {
    final current = await _tokenStore.read();
    if (current == null) {
      throw const AppFailure.unauthenticated(
        message: 'No token bundle to refresh',
      );
    }
    _log.warn('using Phase A dummy refresh — replace before pilot');
    final refreshed = TokenBundle(
      accessToken: 'dev.access.${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: current.refreshToken,
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 15)),
      userId: current.userId,
      ascId: current.ascId,
      role: current.role,
    );
    await _tokenStore.write(refreshed);
    return refreshed;
  }

  Future<void> signOut() async {
    await _tokenStore.clear();
  }
}
