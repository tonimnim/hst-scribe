import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/auth/token_store.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';

part 'auth_state.freezed.dart';

/// Server-issued claims we keep in memory while signed in.
///
/// We do NOT store the access token itself — that lives in [TokenStore]
/// behind Keychain/Keystore. The claims are the safe-to-log subset.
@freezed
class AuthClaims with _$AuthClaims {
  const factory AuthClaims({
    required String userId,
    required String ascId,
    required String role,
    required DateTime expiresAt,
  }) = _AuthClaims;

  const AuthClaims._();

  factory AuthClaims.fromBundle(TokenBundle bundle) => AuthClaims(
    userId: bundle.userId,
    ascId: bundle.ascId,
    role: bundle.role,
    expiresAt: bundle.expiresAt,
  );

  /// True if the access token is past its server `exp`.
  bool get isExpired => !expiresAt.isAfter(DateTime.now().toUtc());
}

/// Three-state auth model:
///  * [Unauthenticated] — never signed in, or signed out, or refresh died.
///    `failure` is set when the transition was forced by an error.
///  * [Authenticated] — a [TokenBundle] is in storage and its claims are
///    surfaced via [AuthClaims].
///  * [Refreshing] — a refresh-token round-trip is in flight. UI keeps the
///    previous claims visible to avoid yanking the user back to login mid-call.
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unauthenticated({AppFailure? failure}) =
      UnauthenticatedAuthState;

  const factory AuthState.authenticated({required AuthClaims claims}) =
      AuthenticatedAuthState;

  const factory AuthState.refreshing({required AuthClaims previousClaims}) =
      RefreshingAuthState;
}
