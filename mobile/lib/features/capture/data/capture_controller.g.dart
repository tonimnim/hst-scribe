// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioCaptureHash() => r'd8d31e9a67e3b1797276722b7b35d75aa84c5e75';

/// Factory provider for the AudioCapture impl in use.
///
/// Tests / dev override this with [FakeAudioCapture]; production wiring
/// returns [RealAudioCapture]. Riverpod owns the disposal lifecycle.
///
/// Copied from [audioCapture].
@ProviderFor(audioCapture)
final audioCaptureProvider = Provider<AudioCapture>.internal(
  audioCapture,
  name: r'audioCaptureProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$audioCaptureHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioCaptureRef = ProviderRef<AudioCapture>;
String _$activeWssConnectionHash() =>
    r'a1ee6ae662baf16cdbbf8a30538b10d76e96e8d1';

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

/// One WSS connection per active session_id. Owned by [CaptureController];
/// torn down on session end.
///
/// Keyed on session_id so a screen rebuild does not reconnect. The
/// connection lives for the lifetime of the session, not the screen.
///
/// Copied from [activeWssConnection].
@ProviderFor(activeWssConnection)
const activeWssConnectionProvider = ActiveWssConnectionFamily();

/// One WSS connection per active session_id. Owned by [CaptureController];
/// torn down on session end.
///
/// Keyed on session_id so a screen rebuild does not reconnect. The
/// connection lives for the lifetime of the session, not the screen.
///
/// Copied from [activeWssConnection].
class ActiveWssConnectionFamily extends Family<WssConnection> {
  /// One WSS connection per active session_id. Owned by [CaptureController];
  /// torn down on session end.
  ///
  /// Keyed on session_id so a screen rebuild does not reconnect. The
  /// connection lives for the lifetime of the session, not the screen.
  ///
  /// Copied from [activeWssConnection].
  const ActiveWssConnectionFamily();

  /// One WSS connection per active session_id. Owned by [CaptureController];
  /// torn down on session end.
  ///
  /// Keyed on session_id so a screen rebuild does not reconnect. The
  /// connection lives for the lifetime of the session, not the screen.
  ///
  /// Copied from [activeWssConnection].
  ActiveWssConnectionProvider call(String sessionId) {
    return ActiveWssConnectionProvider(sessionId);
  }

  @override
  ActiveWssConnectionProvider getProviderOverride(
    covariant ActiveWssConnectionProvider provider,
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
  String? get name => r'activeWssConnectionProvider';
}

/// One WSS connection per active session_id. Owned by [CaptureController];
/// torn down on session end.
///
/// Keyed on session_id so a screen rebuild does not reconnect. The
/// connection lives for the lifetime of the session, not the screen.
///
/// Copied from [activeWssConnection].
class ActiveWssConnectionProvider extends Provider<WssConnection> {
  /// One WSS connection per active session_id. Owned by [CaptureController];
  /// torn down on session end.
  ///
  /// Keyed on session_id so a screen rebuild does not reconnect. The
  /// connection lives for the lifetime of the session, not the screen.
  ///
  /// Copied from [activeWssConnection].
  ActiveWssConnectionProvider(String sessionId)
    : this._internal(
        (ref) => activeWssConnection(ref as ActiveWssConnectionRef, sessionId),
        from: activeWssConnectionProvider,
        name: r'activeWssConnectionProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$activeWssConnectionHash,
        dependencies: ActiveWssConnectionFamily._dependencies,
        allTransitiveDependencies:
            ActiveWssConnectionFamily._allTransitiveDependencies,
        sessionId: sessionId,
      );

  ActiveWssConnectionProvider._internal(
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
  Override overrideWith(
    WssConnection Function(ActiveWssConnectionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveWssConnectionProvider._internal(
        (ref) => create(ref as ActiveWssConnectionRef),
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
  ProviderElement<WssConnection> createElement() {
    return _ActiveWssConnectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveWssConnectionProvider && other.sessionId == sessionId;
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
mixin ActiveWssConnectionRef on ProviderRef<WssConnection> {
  /// The parameter `sessionId` of this provider.
  String get sessionId;
}

class _ActiveWssConnectionProviderElement extends ProviderElement<WssConnection>
    with ActiveWssConnectionRef {
  _ActiveWssConnectionProviderElement(super.provider);

  @override
  String get sessionId => (origin as ActiveWssConnectionProvider).sessionId;
}

String _$captureControllerHash() => r'1e034d0e78fbc0966502bfb1a40dc30a644b6e5a';

abstract class _$CaptureController extends BuildlessNotifier<CaptureState> {
  late final String sessionId;

  CaptureState build(String sessionId);
}

/// Owns the live capture loop for a single session.
///
/// Responsibilities:
///   * Build the WSS connection with a real bearer token.
///   * Subscribe to incoming envelopes; forward transcripts to local state
///     and `event_extracted` payloads to [EventsController].
///   * Open the mic via [AudioCapture] and forward 250ms PCM frames as
///     `audio_chunk` envelopes.
///   * Buffer the rolling last-30s of PCM for replay on reconnect.
///   * Voice commands (`confirm_last`, `strike_last`) are dispatched into
///     [EventsController].
///
/// The controller holds the WSS + AudioCapture lifecycle. Widgets read
/// `state` (a [CaptureState] + transcript snapshot via separate providers)
/// and call [startCapture] / [pausePtt] / [resumePtt] / [endSession].
///
/// Copied from [CaptureController].
@ProviderFor(CaptureController)
const captureControllerProvider = CaptureControllerFamily();

/// Owns the live capture loop for a single session.
///
/// Responsibilities:
///   * Build the WSS connection with a real bearer token.
///   * Subscribe to incoming envelopes; forward transcripts to local state
///     and `event_extracted` payloads to [EventsController].
///   * Open the mic via [AudioCapture] and forward 250ms PCM frames as
///     `audio_chunk` envelopes.
///   * Buffer the rolling last-30s of PCM for replay on reconnect.
///   * Voice commands (`confirm_last`, `strike_last`) are dispatched into
///     [EventsController].
///
/// The controller holds the WSS + AudioCapture lifecycle. Widgets read
/// `state` (a [CaptureState] + transcript snapshot via separate providers)
/// and call [startCapture] / [pausePtt] / [resumePtt] / [endSession].
///
/// Copied from [CaptureController].
class CaptureControllerFamily extends Family<CaptureState> {
  /// Owns the live capture loop for a single session.
  ///
  /// Responsibilities:
  ///   * Build the WSS connection with a real bearer token.
  ///   * Subscribe to incoming envelopes; forward transcripts to local state
  ///     and `event_extracted` payloads to [EventsController].
  ///   * Open the mic via [AudioCapture] and forward 250ms PCM frames as
  ///     `audio_chunk` envelopes.
  ///   * Buffer the rolling last-30s of PCM for replay on reconnect.
  ///   * Voice commands (`confirm_last`, `strike_last`) are dispatched into
  ///     [EventsController].
  ///
  /// The controller holds the WSS + AudioCapture lifecycle. Widgets read
  /// `state` (a [CaptureState] + transcript snapshot via separate providers)
  /// and call [startCapture] / [pausePtt] / [resumePtt] / [endSession].
  ///
  /// Copied from [CaptureController].
  const CaptureControllerFamily();

  /// Owns the live capture loop for a single session.
  ///
  /// Responsibilities:
  ///   * Build the WSS connection with a real bearer token.
  ///   * Subscribe to incoming envelopes; forward transcripts to local state
  ///     and `event_extracted` payloads to [EventsController].
  ///   * Open the mic via [AudioCapture] and forward 250ms PCM frames as
  ///     `audio_chunk` envelopes.
  ///   * Buffer the rolling last-30s of PCM for replay on reconnect.
  ///   * Voice commands (`confirm_last`, `strike_last`) are dispatched into
  ///     [EventsController].
  ///
  /// The controller holds the WSS + AudioCapture lifecycle. Widgets read
  /// `state` (a [CaptureState] + transcript snapshot via separate providers)
  /// and call [startCapture] / [pausePtt] / [resumePtt] / [endSession].
  ///
  /// Copied from [CaptureController].
  CaptureControllerProvider call(String sessionId) {
    return CaptureControllerProvider(sessionId);
  }

  @override
  CaptureControllerProvider getProviderOverride(
    covariant CaptureControllerProvider provider,
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
  String? get name => r'captureControllerProvider';
}

/// Owns the live capture loop for a single session.
///
/// Responsibilities:
///   * Build the WSS connection with a real bearer token.
///   * Subscribe to incoming envelopes; forward transcripts to local state
///     and `event_extracted` payloads to [EventsController].
///   * Open the mic via [AudioCapture] and forward 250ms PCM frames as
///     `audio_chunk` envelopes.
///   * Buffer the rolling last-30s of PCM for replay on reconnect.
///   * Voice commands (`confirm_last`, `strike_last`) are dispatched into
///     [EventsController].
///
/// The controller holds the WSS + AudioCapture lifecycle. Widgets read
/// `state` (a [CaptureState] + transcript snapshot via separate providers)
/// and call [startCapture] / [pausePtt] / [resumePtt] / [endSession].
///
/// Copied from [CaptureController].
class CaptureControllerProvider
    extends NotifierProviderImpl<CaptureController, CaptureState> {
  /// Owns the live capture loop for a single session.
  ///
  /// Responsibilities:
  ///   * Build the WSS connection with a real bearer token.
  ///   * Subscribe to incoming envelopes; forward transcripts to local state
  ///     and `event_extracted` payloads to [EventsController].
  ///   * Open the mic via [AudioCapture] and forward 250ms PCM frames as
  ///     `audio_chunk` envelopes.
  ///   * Buffer the rolling last-30s of PCM for replay on reconnect.
  ///   * Voice commands (`confirm_last`, `strike_last`) are dispatched into
  ///     [EventsController].
  ///
  /// The controller holds the WSS + AudioCapture lifecycle. Widgets read
  /// `state` (a [CaptureState] + transcript snapshot via separate providers)
  /// and call [startCapture] / [pausePtt] / [resumePtt] / [endSession].
  ///
  /// Copied from [CaptureController].
  CaptureControllerProvider(String sessionId)
    : this._internal(
        () => CaptureController()..sessionId = sessionId,
        from: captureControllerProvider,
        name: r'captureControllerProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$captureControllerHash,
        dependencies: CaptureControllerFamily._dependencies,
        allTransitiveDependencies:
            CaptureControllerFamily._allTransitiveDependencies,
        sessionId: sessionId,
      );

  CaptureControllerProvider._internal(
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
  CaptureState runNotifierBuild(covariant CaptureController notifier) {
    return notifier.build(sessionId);
  }

  @override
  Override overrideWith(CaptureController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CaptureControllerProvider._internal(
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
  NotifierProviderElement<CaptureController, CaptureState> createElement() {
    return _CaptureControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CaptureControllerProvider && other.sessionId == sessionId;
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
mixin CaptureControllerRef on NotifierProviderRef<CaptureState> {
  /// The parameter `sessionId` of this provider.
  String get sessionId;
}

class _CaptureControllerProviderElement
    extends NotifierProviderElement<CaptureController, CaptureState>
    with CaptureControllerRef {
  _CaptureControllerProviderElement(super.provider);

  @override
  String get sessionId => (origin as CaptureControllerProvider).sessionId;
}

String _$transcriptControllerHash() =>
    r'bcd2df08851c0b6417e0eac562dadf09c8d04652';

abstract class _$TranscriptController
    extends BuildlessNotifier<List<TranscriptLine>> {
  late final String sessionId;

  List<TranscriptLine> build(String sessionId);
}

/// Transcript state for a single session.
///
/// Held separately from [CaptureController] so transcript-only widgets
/// can rebuild without touching the WSS/audio plumbing.
///
/// Copied from [TranscriptController].
@ProviderFor(TranscriptController)
const transcriptControllerProvider = TranscriptControllerFamily();

/// Transcript state for a single session.
///
/// Held separately from [CaptureController] so transcript-only widgets
/// can rebuild without touching the WSS/audio plumbing.
///
/// Copied from [TranscriptController].
class TranscriptControllerFamily extends Family<List<TranscriptLine>> {
  /// Transcript state for a single session.
  ///
  /// Held separately from [CaptureController] so transcript-only widgets
  /// can rebuild without touching the WSS/audio plumbing.
  ///
  /// Copied from [TranscriptController].
  const TranscriptControllerFamily();

  /// Transcript state for a single session.
  ///
  /// Held separately from [CaptureController] so transcript-only widgets
  /// can rebuild without touching the WSS/audio plumbing.
  ///
  /// Copied from [TranscriptController].
  TranscriptControllerProvider call(String sessionId) {
    return TranscriptControllerProvider(sessionId);
  }

  @override
  TranscriptControllerProvider getProviderOverride(
    covariant TranscriptControllerProvider provider,
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
  String? get name => r'transcriptControllerProvider';
}

/// Transcript state for a single session.
///
/// Held separately from [CaptureController] so transcript-only widgets
/// can rebuild without touching the WSS/audio plumbing.
///
/// Copied from [TranscriptController].
class TranscriptControllerProvider
    extends NotifierProviderImpl<TranscriptController, List<TranscriptLine>> {
  /// Transcript state for a single session.
  ///
  /// Held separately from [CaptureController] so transcript-only widgets
  /// can rebuild without touching the WSS/audio plumbing.
  ///
  /// Copied from [TranscriptController].
  TranscriptControllerProvider(String sessionId)
    : this._internal(
        () => TranscriptController()..sessionId = sessionId,
        from: transcriptControllerProvider,
        name: r'transcriptControllerProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$transcriptControllerHash,
        dependencies: TranscriptControllerFamily._dependencies,
        allTransitiveDependencies:
            TranscriptControllerFamily._allTransitiveDependencies,
        sessionId: sessionId,
      );

  TranscriptControllerProvider._internal(
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
  List<TranscriptLine> runNotifierBuild(
    covariant TranscriptController notifier,
  ) {
    return notifier.build(sessionId);
  }

  @override
  Override overrideWith(TranscriptController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TranscriptControllerProvider._internal(
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
  NotifierProviderElement<TranscriptController, List<TranscriptLine>>
  createElement() {
    return _TranscriptControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TranscriptControllerProvider &&
        other.sessionId == sessionId;
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
mixin TranscriptControllerRef on NotifierProviderRef<List<TranscriptLine>> {
  /// The parameter `sessionId` of this provider.
  String get sessionId;
}

class _TranscriptControllerProviderElement
    extends NotifierProviderElement<TranscriptController, List<TranscriptLine>>
    with TranscriptControllerRef {
  _TranscriptControllerProviderElement(super.provider);

  @override
  String get sessionId => (origin as TranscriptControllerProvider).sessionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
