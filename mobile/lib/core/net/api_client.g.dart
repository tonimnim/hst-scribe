// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$apiClientHash() => r'0263483b5e5d3d36b726eb297993da2763d2f503';

/// Singleton REST client wired against [AppConfig.apiBaseUrl] with:
///  * Bearer token attached from [TokenStore] on every request.
///  * Single-shot 401 → refresh → retry. Second 401 surfaces as
///    [AppFailure.unauthenticated] and clears the token store.
///  * Response errors mapped to [AppFailure] (wire / network / unexpected).
///  * Request lifecycle logged via [AppLogger]: URL + status + duration
///    only — never bodies, which may contain PHI.
///
/// Copied from [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = Provider<ApiClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiClientRef = ProviderRef<ApiClient>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
