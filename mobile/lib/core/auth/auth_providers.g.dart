// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenStoreHash() => r'9f40490b8ca3d070bd9abe456128233f61dbedfa';

/// Singleton [TokenStore]. Tests override.
///
/// Copied from [tokenStore].
@ProviderFor(tokenStore)
final tokenStoreProvider = Provider<TokenStore>.internal(
  tokenStore,
  name: r'tokenStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokenStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TokenStoreRef = ProviderRef<TokenStore>;
String _$oauthPkceFlowHash() => r'0e7955314418865641ef2f736500432940b253be';

/// Pick the OAuth flow based on [AppConfig.useFakeAuth].
///
/// **Safety:** if `useFakeAuth == true` but environment is NOT dev, this
/// throws — the build pipeline must not ship a fake-auth release.
///
/// Copied from [oauthPkceFlow].
@ProviderFor(oauthPkceFlow)
final oauthPkceFlowProvider = Provider<OauthPkceFlow>.internal(
  oauthPkceFlow,
  name: r'oauthPkceFlowProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$oauthPkceFlowHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OauthPkceFlowRef = ProviderRef<OauthPkceFlow>;
String _$authClaimsHash() => r'72f7c04bd8f77a6a155c456c79f9953ca587c918';

/// Synchronous accessor: returns the current [AuthClaims] if and only if
/// the controller has resolved to [AuthState.authenticated]. Returns null
/// otherwise — including during the initial async load.
///
/// Useful for callers that need claims but can tolerate "not yet" (e.g.
/// the router redirect logic).
///
/// Copied from [authClaims].
@ProviderFor(authClaims)
final authClaimsProvider = Provider<AuthClaims?>.internal(
  authClaims,
  name: r'authClaimsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authClaimsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthClaimsRef = ProviderRef<AuthClaims?>;
String _$authControllerHash() => r'5f3fb2645394837147ff4aa5c13a4ec4861b9ccd';

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
///
/// Copied from [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>.internal(
      AuthController.new,
      name: r'authControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthController = AsyncNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
