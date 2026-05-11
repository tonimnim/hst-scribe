import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/core/auth/oauth_pkce_flow.dart';
import 'package:hst_scribe/core/auth/token_store.dart';
import 'package:hst_scribe/core/config/app_config.dart';
import 'package:hst_scribe/core/config/app_config_provider.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:hst_scribe/features/auth/domain/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

const AppLogger _log = AppLogger('auth');

/// Singleton [TokenStore]. Tests override.
@Riverpod(keepAlive: true)
TokenStore tokenStore(TokenStoreRef ref) => TokenStore();

/// Pick the OAuth flow based on [AppConfig.useFakeAuth].
///
/// **Safety:** if `useFakeAuth == true` but environment is NOT dev, this
/// throws — the build pipeline must not ship a fake-auth release.
@Riverpod(keepAlive: true)
OauthPkceFlow oauthPkceFlow(OauthPkceFlowRef ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useFakeAuth) {
    if (config.environment != AppEnvironment.dev) {
      throw StateError(
        'useFakeAuth=true is only permitted in AppEnvironment.dev '
        '(got ${config.environment.name})',
      );
    }
    return DevFakeOauthPkceFlow(config: config);
  }
  return RealOauthPkceFlow(config: config);
}

/// Authenticated session controller. Holds an [AsyncValue<AuthState>] so the
/// UI can render loading / error / data uniformly.
///
/// Lifecycle:
///   build() -> read persisted bundle -> emit Authenticated(claims) or
///   Unauthenticated.
///
///   signIn() -> Refreshing -> oauth flow -> persist -> Authenticated
///
///   signOut() -> clear TokenStore -> Unauthenticated
///
/// Auto-invalidated on token-store mutations from the API client (e.g. 401
/// after a failed refresh).
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthState> build() async {
    final store = ref.watch(tokenStoreProvider);
    final bundle = await store.read();
    if (bundle == null) {
      _log.info('no token bundle — unauthenticated');
      return const AuthState.unauthenticated();
    }
    if (!bundle.expiresAt.isAfter(DateTime.now().toUtc())) {
      _log.info(
        'token bundle present but expired — attempting silent refresh',
        data: <String, Object?>{'user_id': bundle.userId},
      );
      try {
        final flow = ref.read(oauthPkceFlowProvider);
        final refreshed = await flow.refresh(bundle);
        await store.write(refreshed);
        return AuthState.authenticated(
          claims: AuthClaims.fromBundle(refreshed),
        );
      } on AppFailure catch (failure) {
        _log.warn(
          'silent refresh failed — clearing tokens',
          data: <String, Object?>{'user_id': bundle.userId},
        );
        await store.clear();
        return AuthState.unauthenticated(failure: failure);
      }
    }
    _log.info(
      'token bundle valid',
      data: <String, Object?>{
        'user_id': bundle.userId,
        'asc_id': bundle.ascId,
      },
    );
    return AuthState.authenticated(claims: AuthClaims.fromBundle(bundle));
  }

  /// Run the interactive OAuth flow and persist the resulting tokens.
  Future<void> signIn({String? ascId}) async {
    state = const AsyncValue<AuthState>.loading();
    final flow = ref.read(oauthPkceFlowProvider);
    final store = ref.read(tokenStoreProvider);
    state = await AsyncValue.guard<AuthState>(() async {
      final bundle = await flow.startInteractiveSignIn(ascId: ascId);
      await store.write(bundle);
      return AuthState.authenticated(claims: AuthClaims.fromBundle(bundle));
    });
  }

  /// Forget all tokens and force the user back to the login screen.
  Future<void> signOut() async {
    final store = ref.read(tokenStoreProvider);
    await store.clear();
    state = const AsyncValue<AuthState>.data(AuthState.unauthenticated());
  }

  /// Called by [ApiClient] when a 401 followed by a failed refresh tells us
  /// the bundle is dead. Drops auth state without re-entering [build].
  void onTokenExpiredFromApi() {
    _log.info('auth controller notified: tokens expired from API path');
    state = AsyncValue<AuthState>.data(
      AuthState.unauthenticated(
        failure: const AppFailure.unauthenticated(
          message: 'Token expired; please sign in again',
        ),
      ),
    );
  }
}

/// Synchronous accessor: returns the current [AuthClaims] if and only if
/// the controller has resolved to [AuthState.authenticated]. Returns null
/// otherwise — including during the initial async load.
///
/// Useful for callers that need claims but can tolerate "not yet" (e.g.
/// the router redirect logic).
@Riverpod(keepAlive: true)
AuthClaims? authClaims(AuthClaimsRef ref) {
  final state = ref.watch(authControllerProvider);
  return state.maybeWhen<AuthClaims?>(
    data: (AuthState s) => switch (s) {
      AuthenticatedAuthState(:final claims) => claims,
      _ => null,
    },
    orElse: () => null,
  );
}
