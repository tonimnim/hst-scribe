import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/obs/logger.dart';

part 'token_store.freezed.dart';

/// Persisted OAuth2 token bundle. Lives in Keychain (iOS) / Keystore (Android)
/// only. Never goes into `SharedPreferences`, never into logs.
@freezed
class TokenBundle with _$TokenBundle {
  const factory TokenBundle({
    required String accessToken,
    required String refreshToken,

    /// Server `exp` claim as a local DateTime in UTC.
    required DateTime expiresAt,

    /// Server-issued user ID. Safe to log (UUID, not PHI).
    required String userId,

    /// Server-issued ASC tenant ID. Safe to log.
    required String ascId,

    /// Role / scope claim string. Safe to log.
    required String role,
  }) = _TokenBundle;
}

/// Secure-storage-backed token persistence.
///
/// **Threat model:** the device is physically lost. Keychain/Keystore is the
/// device's hardware-backed secret store; we add no further wrapping because
/// rolling our own crypto would weaken, not strengthen, the OS guarantees.
///
/// Phase B will replace [issueDummyTokens] with a real OAuth2 + PKCE flow
/// (`flutter_appauth` is a likely candidate; not added yet because we don't
/// have a server-side IdP to exchange against).
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const String _kAccessToken = 'auth.access_token';
  static const String _kRefreshToken = 'auth.refresh_token';
  static const String _kExpiresAt = 'auth.expires_at';
  static const String _kUserId = 'auth.user_id';
  static const String _kAscId = 'auth.asc_id';
  static const String _kRole = 'auth.role';

  static const AppLogger _log = AppLogger('TokenStore');

  final FlutterSecureStorage _storage;

  Future<TokenBundle?> read() async {
    final access = await _storage.read(key: _kAccessToken);
    final refresh = await _storage.read(key: _kRefreshToken);
    final expiresAtRaw = await _storage.read(key: _kExpiresAt);
    final userId = await _storage.read(key: _kUserId);
    final ascId = await _storage.read(key: _kAscId);
    final role = await _storage.read(key: _kRole);
    if (access == null ||
        refresh == null ||
        expiresAtRaw == null ||
        userId == null ||
        ascId == null ||
        role == null) {
      return null;
    }
    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) {
      _log.warn('expires_at unparseable; treating as no-token');
      return null;
    }
    return TokenBundle(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: expiresAt.toUtc(),
      userId: userId,
      ascId: ascId,
      role: role,
    );
  }

  Future<void> write(TokenBundle bundle) async {
    await Future.wait<void>(<Future<void>>[
      _storage.write(key: _kAccessToken, value: bundle.accessToken),
      _storage.write(key: _kRefreshToken, value: bundle.refreshToken),
      _storage.write(
        key: _kExpiresAt,
        value: bundle.expiresAt.toUtc().toIso8601String(),
      ),
      _storage.write(key: _kUserId, value: bundle.userId),
      _storage.write(key: _kAscId, value: bundle.ascId),
      _storage.write(key: _kRole, value: bundle.role),
    ]);
    _log.info(
      'token bundle written',
      data: <String, Object?>{
        'user_id': bundle.userId,
        'asc_id': bundle.ascId,
        'role': bundle.role,
        'expires_at': bundle.expiresAt.toIso8601String(),
      },
    );
  }

  Future<void> clear() async {
    await Future.wait<void>(<Future<void>>[
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kExpiresAt),
      _storage.delete(key: _kUserId),
      _storage.delete(key: _kAscId),
      _storage.delete(key: _kRole),
    ]);
    _log.info('token bundle cleared');
  }

  /// True if we have a token whose `expiresAt` is strictly in the future.
  Future<bool> hasValidToken() async {
    final bundle = await read();
    if (bundle == null) return false;
    return bundle.expiresAt.isAfter(DateTime.now().toUtc());
  }
}
