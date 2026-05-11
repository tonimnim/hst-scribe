import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/core/auth/auth_providers.dart';
import 'package:hst_scribe/core/auth/oauth_pkce_flow.dart';
import 'package:hst_scribe/core/auth/token_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Thin façade over the auth machinery for feature code.
///
/// Most callers should use the [AuthController] / [authClaimsProvider]
/// pair directly; this repository exists so that login/sign-out
/// presentation widgets don't import core/auth internals.
class AuthRepository {
  AuthRepository({
    required OauthPkceFlow flow,
    required TokenStore tokenStore,
  }) : _flow = flow,
       _tokenStore = tokenStore;

  final OauthPkceFlow _flow;
  final TokenStore _tokenStore;

  Future<TokenBundle> signIn({String? ascId}) async {
    final bundle = await _flow.startInteractiveSignIn(ascId: ascId);
    await _tokenStore.write(bundle);
    return bundle;
  }

  Future<void> signOut() => _tokenStore.clear();

  Future<TokenBundle?> currentBundle() => _tokenStore.read();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepository(
  flow: ref.watch(oauthPkceFlowProvider),
  tokenStore: ref.watch(tokenStoreProvider),
);
