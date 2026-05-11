// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventCountsHash() => r'f7ec37ad6a18d65dab5453a82d69add86da0e20f';

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

/// See also [eventCounts].
@ProviderFor(eventCounts)
const eventCountsProvider = EventCountsFamily();

/// See also [eventCounts].
class EventCountsFamily extends Family<EventCounts> {
  /// See also [eventCounts].
  const EventCountsFamily();

  /// See also [eventCounts].
  EventCountsProvider call(String sessionId) {
    return EventCountsProvider(sessionId);
  }

  @override
  EventCountsProvider getProviderOverride(
    covariant EventCountsProvider provider,
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
  String? get name => r'eventCountsProvider';
}

/// See also [eventCounts].
class EventCountsProvider extends AutoDisposeProvider<EventCounts> {
  /// See also [eventCounts].
  EventCountsProvider(String sessionId)
    : this._internal(
        (ref) => eventCounts(ref as EventCountsRef, sessionId),
        from: eventCountsProvider,
        name: r'eventCountsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$eventCountsHash,
        dependencies: EventCountsFamily._dependencies,
        allTransitiveDependencies: EventCountsFamily._allTransitiveDependencies,
        sessionId: sessionId,
      );

  EventCountsProvider._internal(
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
  Override overrideWith(EventCounts Function(EventCountsRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: EventCountsProvider._internal(
        (ref) => create(ref as EventCountsRef),
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
  AutoDisposeProviderElement<EventCounts> createElement() {
    return _EventCountsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventCountsProvider && other.sessionId == sessionId;
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
mixin EventCountsRef on AutoDisposeProviderRef<EventCounts> {
  /// The parameter `sessionId` of this provider.
  String get sessionId;
}

class _EventCountsProviderElement
    extends AutoDisposeProviderElement<EventCounts>
    with EventCountsRef {
  _EventCountsProviderElement(super.provider);

  @override
  String get sessionId => (origin as EventCountsProvider).sessionId;
}

String _$eventsControllerHash() => r'a9e4aed855f029cb6888020ce022d9e662cb814c';

abstract class _$EventsController extends BuildlessNotifier<List<DraftEvent>> {
  late final String sessionId;

  List<DraftEvent> build(String sessionId);
}

/// Holds the list of draft events for a single active session.
///
/// Wired from [CaptureController]: every `event_extracted` WSS frame is
/// forwarded here via [addExtracted]. Voice commands `confirm_last` /
/// `strike_last` are dispatched to [confirmLast] / [rejectLast].
///
/// Optimistic UI:
///   * `confirm` flips status to [DraftEventStatus.confirming] immediately,
///      POST in the background; on success → [DraftEventStatus.confirmed].
///      On failure → revert to [DraftEventStatus.pending] + set lastError.
///   * Same pattern for reject and edit.
///
/// Newest events are at the head of the list (index 0). Source of truth
/// for the "events confirmed / rejected / drafts pending" counts that
/// the sign screen reads.
///
/// Copied from [EventsController].
@ProviderFor(EventsController)
const eventsControllerProvider = EventsControllerFamily();

/// Holds the list of draft events for a single active session.
///
/// Wired from [CaptureController]: every `event_extracted` WSS frame is
/// forwarded here via [addExtracted]. Voice commands `confirm_last` /
/// `strike_last` are dispatched to [confirmLast] / [rejectLast].
///
/// Optimistic UI:
///   * `confirm` flips status to [DraftEventStatus.confirming] immediately,
///      POST in the background; on success → [DraftEventStatus.confirmed].
///      On failure → revert to [DraftEventStatus.pending] + set lastError.
///   * Same pattern for reject and edit.
///
/// Newest events are at the head of the list (index 0). Source of truth
/// for the "events confirmed / rejected / drafts pending" counts that
/// the sign screen reads.
///
/// Copied from [EventsController].
class EventsControllerFamily extends Family<List<DraftEvent>> {
  /// Holds the list of draft events for a single active session.
  ///
  /// Wired from [CaptureController]: every `event_extracted` WSS frame is
  /// forwarded here via [addExtracted]. Voice commands `confirm_last` /
  /// `strike_last` are dispatched to [confirmLast] / [rejectLast].
  ///
  /// Optimistic UI:
  ///   * `confirm` flips status to [DraftEventStatus.confirming] immediately,
  ///      POST in the background; on success → [DraftEventStatus.confirmed].
  ///      On failure → revert to [DraftEventStatus.pending] + set lastError.
  ///   * Same pattern for reject and edit.
  ///
  /// Newest events are at the head of the list (index 0). Source of truth
  /// for the "events confirmed / rejected / drafts pending" counts that
  /// the sign screen reads.
  ///
  /// Copied from [EventsController].
  const EventsControllerFamily();

  /// Holds the list of draft events for a single active session.
  ///
  /// Wired from [CaptureController]: every `event_extracted` WSS frame is
  /// forwarded here via [addExtracted]. Voice commands `confirm_last` /
  /// `strike_last` are dispatched to [confirmLast] / [rejectLast].
  ///
  /// Optimistic UI:
  ///   * `confirm` flips status to [DraftEventStatus.confirming] immediately,
  ///      POST in the background; on success → [DraftEventStatus.confirmed].
  ///      On failure → revert to [DraftEventStatus.pending] + set lastError.
  ///   * Same pattern for reject and edit.
  ///
  /// Newest events are at the head of the list (index 0). Source of truth
  /// for the "events confirmed / rejected / drafts pending" counts that
  /// the sign screen reads.
  ///
  /// Copied from [EventsController].
  EventsControllerProvider call(String sessionId) {
    return EventsControllerProvider(sessionId);
  }

  @override
  EventsControllerProvider getProviderOverride(
    covariant EventsControllerProvider provider,
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
  String? get name => r'eventsControllerProvider';
}

/// Holds the list of draft events for a single active session.
///
/// Wired from [CaptureController]: every `event_extracted` WSS frame is
/// forwarded here via [addExtracted]. Voice commands `confirm_last` /
/// `strike_last` are dispatched to [confirmLast] / [rejectLast].
///
/// Optimistic UI:
///   * `confirm` flips status to [DraftEventStatus.confirming] immediately,
///      POST in the background; on success → [DraftEventStatus.confirmed].
///      On failure → revert to [DraftEventStatus.pending] + set lastError.
///   * Same pattern for reject and edit.
///
/// Newest events are at the head of the list (index 0). Source of truth
/// for the "events confirmed / rejected / drafts pending" counts that
/// the sign screen reads.
///
/// Copied from [EventsController].
class EventsControllerProvider
    extends NotifierProviderImpl<EventsController, List<DraftEvent>> {
  /// Holds the list of draft events for a single active session.
  ///
  /// Wired from [CaptureController]: every `event_extracted` WSS frame is
  /// forwarded here via [addExtracted]. Voice commands `confirm_last` /
  /// `strike_last` are dispatched to [confirmLast] / [rejectLast].
  ///
  /// Optimistic UI:
  ///   * `confirm` flips status to [DraftEventStatus.confirming] immediately,
  ///      POST in the background; on success → [DraftEventStatus.confirmed].
  ///      On failure → revert to [DraftEventStatus.pending] + set lastError.
  ///   * Same pattern for reject and edit.
  ///
  /// Newest events are at the head of the list (index 0). Source of truth
  /// for the "events confirmed / rejected / drafts pending" counts that
  /// the sign screen reads.
  ///
  /// Copied from [EventsController].
  EventsControllerProvider(String sessionId)
    : this._internal(
        () => EventsController()..sessionId = sessionId,
        from: eventsControllerProvider,
        name: r'eventsControllerProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$eventsControllerHash,
        dependencies: EventsControllerFamily._dependencies,
        allTransitiveDependencies:
            EventsControllerFamily._allTransitiveDependencies,
        sessionId: sessionId,
      );

  EventsControllerProvider._internal(
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
  List<DraftEvent> runNotifierBuild(covariant EventsController notifier) {
    return notifier.build(sessionId);
  }

  @override
  Override overrideWith(EventsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: EventsControllerProvider._internal(
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
  NotifierProviderElement<EventsController, List<DraftEvent>> createElement() {
    return _EventsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsControllerProvider && other.sessionId == sessionId;
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
mixin EventsControllerRef on NotifierProviderRef<List<DraftEvent>> {
  /// The parameter `sessionId` of this provider.
  String get sessionId;
}

class _EventsControllerProviderElement
    extends NotifierProviderElement<EventsController, List<DraftEvent>>
    with EventsControllerRef {
  _EventsControllerProviderElement(super.provider);

  @override
  String get sessionId => (origin as EventsControllerProvider).sessionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
