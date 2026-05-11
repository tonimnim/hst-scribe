// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$biometricAvailableHash() =>
    r'f4da495256929a6cd4a36c0f8acc5d1fb9c2bb25';

/// Synchronous accessor: is biometric available in this build?
///
/// Exposed so the UI can label the primary CTA appropriately ("Sign with
/// Face ID" vs "Enter PIN") without poking at the local_auth API.
///
/// Copied from [biometricAvailable].
@ProviderFor(biometricAvailable)
final biometricAvailableProvider = AutoDisposeProvider<bool>.internal(
  biometricAvailable,
  name: r'biometricAvailableProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$biometricAvailableHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BiometricAvailableRef = AutoDisposeProviderRef<bool>;
String _$signControllerHash() => r'7a82ba8f78be1d7f96209ec34fd5806343d266b8';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SignController
    extends BuildlessAutoDisposeNotifier<SignState> {
  late final String sessionId;

  SignState build(String sessionId);
}

/// Drives the sign-off flow.
///
/// Lifecycle:
///   * UI calls [beginSign] → controller flips state through
///     `summarizing → promptingBiometric / promptingPin`.
///   * On biometric success or PIN submission, the controller POSTs
///     `/sessions/{id}/sign` and emits `success` or `error`.
///
/// The actual biometric prompt UI lives in the screen, NOT in the
/// controller — `local_auth` requires a `BuildContext`-bound platform
/// channel call and we keep widgets out of controllers per AGENTS.md.
///
/// Copied from [SignController].
@ProviderFor(SignController)
const signControllerProvider = SignControllerFamily();

/// Drives the sign-off flow.
///
/// Lifecycle:
///   * UI calls [beginSign] → controller flips state through
///     `summarizing → promptingBiometric / promptingPin`.
///   * On biometric success or PIN submission, the controller POSTs
///     `/sessions/{id}/sign` and emits `success` or `error`.
///
/// The actual biometric prompt UI lives in the screen, NOT in the
/// controller — `local_auth` requires a `BuildContext`-bound platform
/// channel call and we keep widgets out of controllers per AGENTS.md.
///
/// Copied from [SignController].
class SignControllerFamily extends Family<SignState> {
  /// Drives the sign-off flow.
  ///
  /// Lifecycle:
  ///   * UI calls [beginSign] → controller flips state through
  ///     `summarizing → promptingBiometric / promptingPin`.
  ///   * On biometric success or PIN submission, the controller POSTs
  ///     `/sessions/{id}/sign` and emits `success` or `error`.
  ///
  /// The actual biometric prompt UI lives in the screen, NOT in the
  /// controller — `local_auth` requires a `BuildContext`-bound platform
  /// channel call and we keep widgets out of controllers per AGENTS.md.
  ///
  /// Copied from [SignController].
  const SignControllerFamily();

  /// Drives the sign-off flow.
  ///
  /// Lifecycle:
  ///   * UI calls [beginSign] → controller flips state through
  ///     `summarizing → promptingBiometric / promptingPin`.
  ///   * On biometric success or PIN submission, the controller POSTs
  ///     `/sessions/{id}/sign` and emits `success` or `error`.
  ///
  /// The actual biometric prompt UI lives in the screen, NOT in the
  /// controller — `local_auth` requires a `BuildContext`-bound platform
  /// channel call and we keep widgets out of controllers per AGENTS.md.
  ///
  /// Copied from [SignController].
  SignControllerProvider call(String sessionId) {
    return SignControllerProvider(sessionId);
  }

  @override
  SignControllerProvider getProviderOverride(
    covariant SignControllerProvider provider,
  ) {
    return call(provider.sessionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'signControllerProvider';
}

/// Drives the sign-off flow.
///
/// Lifecycle:
///   * UI calls [beginSign] → controller flips state through
///     `summarizing → promptingBiometric / promptingPin`.
///   * On biometric success or PIN submission, the controller POSTs
///     `/sessions/{id}/sign` and emits `success` or `error`.
///
/// The actual biometric prompt UI lives in the screen, NOT in the
/// controller — `local_auth` requires a `BuildContext`-bound platform
/// channel call and we keep widgets out of controllers per AGENTS.md.
///
/// Copied from [SignController].
class SignControllerProvider
    extends AutoDisposeNotifierProviderImpl<SignController, SignState> {
  /// Drives the sign-off flow.
  ///
  /// Lifecycle:
  ///   * UI calls [beginSign] → controller flips state through
  ///     `summarizing → promptingBiometric / promptingPin`.
  ///   * On biometric success or PIN submission, the controller POSTs
  ///     `/sessions/{id}/sign` and emits `success` or `error`.
  ///
  /// The actual biometric prompt UI lives in the screen, NOT in the
  /// controller — `local_auth` requires a `BuildContext`-bound platform
  /// channel call and we keep widgets out of controllers per AGENTS.md.
  ///
  /// Copied from [SignController].
  SignControllerProvider(String sessionId)
    : this._internal(
        () => SignController()..sessionId = sessionId,
        from: signControllerProvider,
        name: r'signControllerProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$signControllerHash,
        dependencies: SignControllerFamily._dependencies,
        allTransitiveDependencies:
            SignControllerFamily._allTransitiveDependencies,
        sessionId: sessionId,
      );

  SignControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final String sessionId;

  @override
  SignState runNotifierBuild(covariant SignController notifier) {
    return notifier.build(sessionId);
  }

  @override
  Override overrideWith(SignController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SignControllerProvider._internal(
        () => create()..sessionId = sessionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SignController, SignState>
  createElement() {
    return _SignControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SignControllerProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SignControllerRef on AutoDisposeNotifierProviderRef<SignState> {
  /// The parameter `sessionId` of this provider.
  String get sessionId;
}

class _SignControllerProviderElement
    extends AutoDisposeNotifierProviderElement<SignController, SignState>
    with SignControllerRef {
  _SignControllerProviderElement(super.provider);

  @override
  String get sessionId => (origin as SignControllerProvider).sessionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
