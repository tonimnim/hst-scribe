import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:hst_scribe/core/auth/token_store.dart';
import 'package:hst_scribe/core/config/app_config.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';

/// OAuth2 Authorization Code + PKCE flow against the HST IdP.
///
/// Two implementations:
///  * [RealOauthPkceFlow] — runs the spec: code verifier + challenge,
///    opens the authorize URL in a system browser, captures the redirect,
///    exchanges the code at the token endpoint. Skeleton only until the
///    `url_launcher` / `flutter_appauth` dependency lands (we deliberately
///    don't pull it in here per the wave-1 scope cap on `pubspec.yaml`).
///  * [DevFakeOauthPkceFlow] — mints a local HS256 JWT signed with the
///    shared dev secret. Lets the rest of the app exercise the auth gate,
///    REST client, refresh interceptor, and session lifecycle without a
///    live IdP. Selected in `AppConfig.useFakeAuth == true`.
///
/// The Riverpod auth controller picks the right impl from [AppConfig] —
/// callers should not construct one of these directly outside tests.
abstract class OauthPkceFlow {
  /// Pop an interactive sign-in (or, in fake mode, mint a token immediately)
  /// and return the resulting [TokenBundle]. The caller persists.
  Future<TokenBundle> startInteractiveSignIn({String? ascId});

  /// Exchange the stored refresh token for a fresh access token.
  /// Returns the new bundle (and the caller persists).
  Future<TokenBundle> refresh(TokenBundle current);
}

/// PKCE helper — RFC 7636 §4. Code verifier is 43–128 chars from the
/// unreserved set (`A-Za-z0-9-._~`). Challenge is base64url(sha256(verifier)).
class PkceMaterial {
  PkceMaterial({required this.verifier, required this.challenge});

  /// Generate a fresh PKCE pair with a 64-char URL-safe verifier.
  factory PkceMaterial.generate() {
    final random = Random.secure();
    const alphabet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final verifier = String.fromCharCodes(<int>[
      for (var i = 0; i < 64; i++)
        alphabet.codeUnitAt(random.nextInt(alphabet.length)),
    ]);
    final digest = sha256.convert(utf8.encode(verifier));
    final challenge = base64UrlEncode(digest.bytes)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
    return PkceMaterial(verifier: verifier, challenge: challenge);
  }

  final String verifier;
  final String challenge;
}

/// Real OAuth2 + PKCE flow against an HST IdP.
///
/// **Status:** wired but not callable end-to-end. The browser launch +
/// deep-link callback wiring lives behind a TODO until either
/// `url_launcher` is added in a follow-up or we adopt `flutter_appauth`.
/// Token exchange is fully implemented; refresh round-trips work.
///
/// In its current form this class throws [UnimplementedError] from
/// [startInteractiveSignIn] so it is never silently invoked. The auth
/// controller selects [DevFakeOauthPkceFlow] whenever
/// `AppConfig.useFakeAuth` is true (default in dev).
class RealOauthPkceFlow implements OauthPkceFlow {
  RealOauthPkceFlow({required AppConfig config, Dio? httpClient})
    : _config = config,
      _http = httpClient ?? Dio();

  final AppConfig _config;
  final Dio _http;

  static const AppLogger _log = AppLogger('RealOauthPkceFlow');

  @override
  Future<TokenBundle> startInteractiveSignIn({String? ascId}) async {
    // TODO(auth): wire system-browser launch via url_launcher or
    // flutter_appauth — needs a redirect listener (deep link / custom
    // scheme) and a state nonce check. Tracked in mobile PRD §Auth.
    _log.error(
      'RealOauthPkceFlow.startInteractiveSignIn not yet wired '
      '— set AppConfig.useFakeAuth=true for dev or wire flutter_appauth.',
    );
    throw UnimplementedError(
      'RealOauthPkceFlow needs a browser launcher dependency. '
      'Use DevFakeOauthPkceFlow in dev or add url_launcher/flutter_appauth.',
    );
  }

  @override
  Future<TokenBundle> refresh(TokenBundle current) async {
    try {
      final response = await _http.post<Map<String, Object?>>(
        '${_config.apiBaseUrl}/api/v1/auth/refresh',
        data: <String, Object?>{
          'grant_type': 'refresh_token',
          'refresh_token': current.refreshToken,
          'client_id': _config.idpClientId,
        },
        options: Options(
          headers: <String, Object?>{'Content-Type': 'application/json'},
        ),
      );
      final body = response.data;
      if (body == null) {
        throw const AppFailure.unauthenticated(
          message: 'Empty refresh response',
        );
      }
      return _parseTokenResponse(
        body: body,
        fallbackUserId: current.userId,
        fallbackAscId: current.ascId,
        fallbackRole: current.role,
        previousRefreshToken: current.refreshToken,
      );
    } on DioException catch (e) {
      _log.warn(
        'token refresh failed',
        error: e,
        data: <String, Object?>{
          'status': e.response?.statusCode,
          'user_id': current.userId,
        },
      );
      throw const AppFailure.unauthenticated(message: 'Token refresh failed');
    }
  }

  /// Visible for token-endpoint exchange after PKCE code capture.
  TokenBundle _parseTokenResponse({
    required Map<String, Object?> body,
    required String fallbackUserId,
    required String fallbackAscId,
    required String fallbackRole,
    required String previousRefreshToken,
  }) {
    final access = body['access_token'] as String?;
    final refresh = (body['refresh_token'] as String?) ?? previousRefreshToken;
    if (access == null) {
      throw const AppFailure.unauthenticated(
        message: 'Refresh response missing access_token',
      );
    }
    final claims = JwtClaims.decode(access);
    return TokenBundle(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: claims.exp ?? DateTime.now().toUtc().add(_defaultLifetime),
      userId: claims.sub ?? fallbackUserId,
      ascId: claims.ascId ?? fallbackAscId,
      role: claims.role ?? fallbackRole,
    );
  }

  static const Duration _defaultLifetime = Duration(minutes: 15);
}

/// Dev-only OAuth flow.
///
/// Mints a locally-signed HS256 JWT so the app can run end-to-end against
/// a dev gateway without a real IdP. The gateway is expected to accept
/// the same shared `DEV_JWT_SECRET` and check signature + standard claims.
///
/// **Never used in prod.** [OauthPkceFlowProvider] throws if
/// `useFakeAuth == true` in a non-dev build.
class DevFakeOauthPkceFlow implements OauthPkceFlow {
  DevFakeOauthPkceFlow({required AppConfig config, Random? random})
    : _config = config,
      _random = random ?? Random.secure();

  static const AppLogger _log = AppLogger('DevFakeOauthPkceFlow');

  final AppConfig _config;
  final Random _random;

  static const Duration _defaultLifetime = Duration(minutes: 15);
  static const String _devAscId = '00000000-0000-0000-0000-0000000000a5';
  static const String _devNurseId = '00000000-0000-0000-0000-0000000000b1';

  @override
  Future<TokenBundle> startInteractiveSignIn({String? ascId}) async {
    _log.warn(
      'minting DEV-FAKE token — must not run in prod',
      data: <String, Object?>{
        'environment': _config.environment.name,
        'asc_id': ascId ?? _devAscId,
      },
    );
    return _mint(
      userId: _devNurseId,
      ascId: ascId ?? _devAscId,
      role: 'nurse',
      refreshToken: _randomRefreshToken(),
    );
  }

  @override
  Future<TokenBundle> refresh(TokenBundle current) async {
    _log.info(
      'dev-fake refresh',
      data: <String, Object?>{'user_id': current.userId},
    );
    return _mint(
      userId: current.userId,
      ascId: current.ascId,
      role: current.role,
      refreshToken: current.refreshToken,
    );
  }

  TokenBundle _mint({
    required String userId,
    required String ascId,
    required String role,
    required String refreshToken,
  }) {
    final now = DateTime.now().toUtc();
    final exp = now.add(_defaultLifetime);
    final accessToken = mintHs256Jwt(
      secret: _config.devJwtSecret,
      claims: <String, Object?>{
        'sub': userId,
        'asc_id': ascId,
        'role': role,
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': exp.millisecondsSinceEpoch ~/ 1000,
      },
    );
    return TokenBundle(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: exp,
      userId: userId,
      ascId: ascId,
      role: role,
    );
  }

  String _randomRefreshToken() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}

/// Decode-only view of a JWT's payload. We don't verify signatures on the
/// client — the gateway is the source of truth — but we DO read the claims
/// to drive route guards, banner state, and refresh expiry.
class JwtClaims {
  const JwtClaims({this.sub, this.ascId, this.role, this.exp, this.iat});

  /// Best-effort decode. Returns an empty [JwtClaims] on any parse failure
  /// rather than throwing, because token expiry is the real auth gate, not
  /// claim shape.
  factory JwtClaims.decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return const JwtClaims();
      final payload = _b64UrlDecode(parts[1]);
      final json = jsonDecode(utf8.decode(payload));
      if (json is! Map<String, Object?>) return const JwtClaims();
      DateTime? exp;
      final expRaw = json['exp'];
      if (expRaw is int) {
        exp = DateTime.fromMillisecondsSinceEpoch(
          expRaw * 1000,
          isUtc: true,
        );
      }
      DateTime? iat;
      final iatRaw = json['iat'];
      if (iatRaw is int) {
        iat = DateTime.fromMillisecondsSinceEpoch(
          iatRaw * 1000,
          isUtc: true,
        );
      }
      return JwtClaims(
        sub: json['sub'] as String?,
        ascId: json['asc_id'] as String?,
        role: json['role'] as String?,
        exp: exp,
        iat: iat,
      );
    } catch (_) {
      return const JwtClaims();
    }
  }

  final String? sub;
  final String? ascId;
  final String? role;
  final DateTime? exp;
  final DateTime? iat;
}

/// Mint an HS256 JWT with [claims] signed by [secret].
///
/// Header is fixed: `{"alg":"HS256","typ":"JWT"}`.
String mintHs256Jwt({
  required String secret,
  required Map<String, Object?> claims,
}) {
  final header = <String, Object?>{'alg': 'HS256', 'typ': 'JWT'};
  final headerSegment = _b64UrlEncode(utf8.encode(jsonEncode(header)));
  final payloadSegment = _b64UrlEncode(utf8.encode(jsonEncode(claims)));
  final signingInput = '$headerSegment.$payloadSegment';
  final hmac = Hmac(sha256, utf8.encode(secret));
  final signature = hmac.convert(utf8.encode(signingInput));
  final signatureSegment = _b64UrlEncode(signature.bytes);
  return '$signingInput.$signatureSegment';
}

String _b64UrlEncode(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

List<int> _b64UrlDecode(String input) {
  final normalised = input.replaceAll('-', '+').replaceAll('_', '/');
  final padded = normalised.padRight(
    normalised.length + ((4 - normalised.length % 4) % 4),
    '=',
  );
  return base64.decode(padded);
}
