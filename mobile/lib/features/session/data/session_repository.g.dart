// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionRepositoryHash() => r'b512e98ac575ad1d40bb65dbcca84ccb55e6ff82';

/// See also [sessionRepository].
@ProviderFor(sessionRepository)
final sessionRepositoryProvider = Provider<SessionRepository>.internal(
  sessionRepository,
  name: r'sessionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionRepositoryRef = ProviderRef<SessionRepository>;
String _$activeSessionHash() => r'6d732c5909ab716fe65bafa5a119a5fb0018d120';

/// Holder for the currently active session created by the start flow.
///
/// Wave-2 capture agent reads this to obtain the WSS URL + patient context.
/// Independent of [authControllerProvider] — we want the session to survive
/// silent token refresh without rebuilding.
///
/// Copied from [ActiveSession].
@ProviderFor(ActiveSession)
final activeSessionProvider =
    NotifierProvider<ActiveSession, Session?>.internal(
      ActiveSession.new,
      name: r'activeSessionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeSessionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveSession = Notifier<Session?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
