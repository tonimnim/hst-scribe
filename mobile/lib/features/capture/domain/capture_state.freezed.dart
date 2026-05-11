// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capture_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CaptureState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function() connecting,
    required TResult Function() listening,
    required TResult Function() paused,
    required TResult Function(AppFailure failure) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function()? connecting,
    TResult? Function()? listening,
    TResult? Function()? paused,
    TResult? Function(AppFailure failure)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function()? connecting,
    TResult Function()? listening,
    TResult Function()? paused,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DisconnectedCaptureState value) disconnected,
    required TResult Function(ConnectingCaptureState value) connecting,
    required TResult Function(ListeningCaptureState value) listening,
    required TResult Function(PausedCaptureState value) paused,
    required TResult Function(ErrorCaptureState value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DisconnectedCaptureState value)? disconnected,
    TResult? Function(ConnectingCaptureState value)? connecting,
    TResult? Function(ListeningCaptureState value)? listening,
    TResult? Function(PausedCaptureState value)? paused,
    TResult? Function(ErrorCaptureState value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DisconnectedCaptureState value)? disconnected,
    TResult Function(ConnectingCaptureState value)? connecting,
    TResult Function(ListeningCaptureState value)? listening,
    TResult Function(PausedCaptureState value)? paused,
    TResult Function(ErrorCaptureState value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaptureStateCopyWith<$Res> {
  factory $CaptureStateCopyWith(
    CaptureState value,
    $Res Function(CaptureState) then,
  ) = _$CaptureStateCopyWithImpl<$Res, CaptureState>;
}

/// @nodoc
class _$CaptureStateCopyWithImpl<$Res, $Val extends CaptureState>
    implements $CaptureStateCopyWith<$Res> {
  _$CaptureStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DisconnectedCaptureStateImplCopyWith<$Res> {
  factory _$$DisconnectedCaptureStateImplCopyWith(
    _$DisconnectedCaptureStateImpl value,
    $Res Function(_$DisconnectedCaptureStateImpl) then,
  ) = __$$DisconnectedCaptureStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DisconnectedCaptureStateImplCopyWithImpl<$Res>
    extends _$CaptureStateCopyWithImpl<$Res, _$DisconnectedCaptureStateImpl>
    implements _$$DisconnectedCaptureStateImplCopyWith<$Res> {
  __$$DisconnectedCaptureStateImplCopyWithImpl(
    _$DisconnectedCaptureStateImpl _value,
    $Res Function(_$DisconnectedCaptureStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DisconnectedCaptureStateImpl implements DisconnectedCaptureState {
  const _$DisconnectedCaptureStateImpl();

  @override
  String toString() {
    return 'CaptureState.disconnected()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisconnectedCaptureStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function() connecting,
    required TResult Function() listening,
    required TResult Function() paused,
    required TResult Function(AppFailure failure) error,
  }) {
    return disconnected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function()? connecting,
    TResult? Function()? listening,
    TResult? Function()? paused,
    TResult? Function(AppFailure failure)? error,
  }) {
    return disconnected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function()? connecting,
    TResult Function()? listening,
    TResult Function()? paused,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (disconnected != null) {
      return disconnected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DisconnectedCaptureState value) disconnected,
    required TResult Function(ConnectingCaptureState value) connecting,
    required TResult Function(ListeningCaptureState value) listening,
    required TResult Function(PausedCaptureState value) paused,
    required TResult Function(ErrorCaptureState value) error,
  }) {
    return disconnected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DisconnectedCaptureState value)? disconnected,
    TResult? Function(ConnectingCaptureState value)? connecting,
    TResult? Function(ListeningCaptureState value)? listening,
    TResult? Function(PausedCaptureState value)? paused,
    TResult? Function(ErrorCaptureState value)? error,
  }) {
    return disconnected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DisconnectedCaptureState value)? disconnected,
    TResult Function(ConnectingCaptureState value)? connecting,
    TResult Function(ListeningCaptureState value)? listening,
    TResult Function(PausedCaptureState value)? paused,
    TResult Function(ErrorCaptureState value)? error,
    required TResult orElse(),
  }) {
    if (disconnected != null) {
      return disconnected(this);
    }
    return orElse();
  }
}

abstract class DisconnectedCaptureState implements CaptureState {
  const factory DisconnectedCaptureState() = _$DisconnectedCaptureStateImpl;
}

/// @nodoc
abstract class _$$ConnectingCaptureStateImplCopyWith<$Res> {
  factory _$$ConnectingCaptureStateImplCopyWith(
    _$ConnectingCaptureStateImpl value,
    $Res Function(_$ConnectingCaptureStateImpl) then,
  ) = __$$ConnectingCaptureStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ConnectingCaptureStateImplCopyWithImpl<$Res>
    extends _$CaptureStateCopyWithImpl<$Res, _$ConnectingCaptureStateImpl>
    implements _$$ConnectingCaptureStateImplCopyWith<$Res> {
  __$$ConnectingCaptureStateImplCopyWithImpl(
    _$ConnectingCaptureStateImpl _value,
    $Res Function(_$ConnectingCaptureStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ConnectingCaptureStateImpl implements ConnectingCaptureState {
  const _$ConnectingCaptureStateImpl();

  @override
  String toString() {
    return 'CaptureState.connecting()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectingCaptureStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function() connecting,
    required TResult Function() listening,
    required TResult Function() paused,
    required TResult Function(AppFailure failure) error,
  }) {
    return connecting();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function()? connecting,
    TResult? Function()? listening,
    TResult? Function()? paused,
    TResult? Function(AppFailure failure)? error,
  }) {
    return connecting?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function()? connecting,
    TResult Function()? listening,
    TResult Function()? paused,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (connecting != null) {
      return connecting();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DisconnectedCaptureState value) disconnected,
    required TResult Function(ConnectingCaptureState value) connecting,
    required TResult Function(ListeningCaptureState value) listening,
    required TResult Function(PausedCaptureState value) paused,
    required TResult Function(ErrorCaptureState value) error,
  }) {
    return connecting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DisconnectedCaptureState value)? disconnected,
    TResult? Function(ConnectingCaptureState value)? connecting,
    TResult? Function(ListeningCaptureState value)? listening,
    TResult? Function(PausedCaptureState value)? paused,
    TResult? Function(ErrorCaptureState value)? error,
  }) {
    return connecting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DisconnectedCaptureState value)? disconnected,
    TResult Function(ConnectingCaptureState value)? connecting,
    TResult Function(ListeningCaptureState value)? listening,
    TResult Function(PausedCaptureState value)? paused,
    TResult Function(ErrorCaptureState value)? error,
    required TResult orElse(),
  }) {
    if (connecting != null) {
      return connecting(this);
    }
    return orElse();
  }
}

abstract class ConnectingCaptureState implements CaptureState {
  const factory ConnectingCaptureState() = _$ConnectingCaptureStateImpl;
}

/// @nodoc
abstract class _$$ListeningCaptureStateImplCopyWith<$Res> {
  factory _$$ListeningCaptureStateImplCopyWith(
    _$ListeningCaptureStateImpl value,
    $Res Function(_$ListeningCaptureStateImpl) then,
  ) = __$$ListeningCaptureStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ListeningCaptureStateImplCopyWithImpl<$Res>
    extends _$CaptureStateCopyWithImpl<$Res, _$ListeningCaptureStateImpl>
    implements _$$ListeningCaptureStateImplCopyWith<$Res> {
  __$$ListeningCaptureStateImplCopyWithImpl(
    _$ListeningCaptureStateImpl _value,
    $Res Function(_$ListeningCaptureStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ListeningCaptureStateImpl implements ListeningCaptureState {
  const _$ListeningCaptureStateImpl();

  @override
  String toString() {
    return 'CaptureState.listening()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListeningCaptureStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function() connecting,
    required TResult Function() listening,
    required TResult Function() paused,
    required TResult Function(AppFailure failure) error,
  }) {
    return listening();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function()? connecting,
    TResult? Function()? listening,
    TResult? Function()? paused,
    TResult? Function(AppFailure failure)? error,
  }) {
    return listening?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function()? connecting,
    TResult Function()? listening,
    TResult Function()? paused,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (listening != null) {
      return listening();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DisconnectedCaptureState value) disconnected,
    required TResult Function(ConnectingCaptureState value) connecting,
    required TResult Function(ListeningCaptureState value) listening,
    required TResult Function(PausedCaptureState value) paused,
    required TResult Function(ErrorCaptureState value) error,
  }) {
    return listening(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DisconnectedCaptureState value)? disconnected,
    TResult? Function(ConnectingCaptureState value)? connecting,
    TResult? Function(ListeningCaptureState value)? listening,
    TResult? Function(PausedCaptureState value)? paused,
    TResult? Function(ErrorCaptureState value)? error,
  }) {
    return listening?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DisconnectedCaptureState value)? disconnected,
    TResult Function(ConnectingCaptureState value)? connecting,
    TResult Function(ListeningCaptureState value)? listening,
    TResult Function(PausedCaptureState value)? paused,
    TResult Function(ErrorCaptureState value)? error,
    required TResult orElse(),
  }) {
    if (listening != null) {
      return listening(this);
    }
    return orElse();
  }
}

abstract class ListeningCaptureState implements CaptureState {
  const factory ListeningCaptureState() = _$ListeningCaptureStateImpl;
}

/// @nodoc
abstract class _$$PausedCaptureStateImplCopyWith<$Res> {
  factory _$$PausedCaptureStateImplCopyWith(
    _$PausedCaptureStateImpl value,
    $Res Function(_$PausedCaptureStateImpl) then,
  ) = __$$PausedCaptureStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PausedCaptureStateImplCopyWithImpl<$Res>
    extends _$CaptureStateCopyWithImpl<$Res, _$PausedCaptureStateImpl>
    implements _$$PausedCaptureStateImplCopyWith<$Res> {
  __$$PausedCaptureStateImplCopyWithImpl(
    _$PausedCaptureStateImpl _value,
    $Res Function(_$PausedCaptureStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PausedCaptureStateImpl implements PausedCaptureState {
  const _$PausedCaptureStateImpl();

  @override
  String toString() {
    return 'CaptureState.paused()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PausedCaptureStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function() connecting,
    required TResult Function() listening,
    required TResult Function() paused,
    required TResult Function(AppFailure failure) error,
  }) {
    return paused();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function()? connecting,
    TResult? Function()? listening,
    TResult? Function()? paused,
    TResult? Function(AppFailure failure)? error,
  }) {
    return paused?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function()? connecting,
    TResult Function()? listening,
    TResult Function()? paused,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DisconnectedCaptureState value) disconnected,
    required TResult Function(ConnectingCaptureState value) connecting,
    required TResult Function(ListeningCaptureState value) listening,
    required TResult Function(PausedCaptureState value) paused,
    required TResult Function(ErrorCaptureState value) error,
  }) {
    return paused(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DisconnectedCaptureState value)? disconnected,
    TResult? Function(ConnectingCaptureState value)? connecting,
    TResult? Function(ListeningCaptureState value)? listening,
    TResult? Function(PausedCaptureState value)? paused,
    TResult? Function(ErrorCaptureState value)? error,
  }) {
    return paused?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DisconnectedCaptureState value)? disconnected,
    TResult Function(ConnectingCaptureState value)? connecting,
    TResult Function(ListeningCaptureState value)? listening,
    TResult Function(PausedCaptureState value)? paused,
    TResult Function(ErrorCaptureState value)? error,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(this);
    }
    return orElse();
  }
}

abstract class PausedCaptureState implements CaptureState {
  const factory PausedCaptureState() = _$PausedCaptureStateImpl;
}

/// @nodoc
abstract class _$$ErrorCaptureStateImplCopyWith<$Res> {
  factory _$$ErrorCaptureStateImplCopyWith(
    _$ErrorCaptureStateImpl value,
    $Res Function(_$ErrorCaptureStateImpl) then,
  ) = __$$ErrorCaptureStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AppFailure failure});

  $AppFailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$ErrorCaptureStateImplCopyWithImpl<$Res>
    extends _$CaptureStateCopyWithImpl<$Res, _$ErrorCaptureStateImpl>
    implements _$$ErrorCaptureStateImplCopyWith<$Res> {
  __$$ErrorCaptureStateImplCopyWithImpl(
    _$ErrorCaptureStateImpl _value,
    $Res Function(_$ErrorCaptureStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? failure = null}) {
    return _then(
      _$ErrorCaptureStateImpl(
        null == failure
            ? _value.failure
            : failure // ignore: cast_nullable_to_non_nullable
                as AppFailure,
      ),
    );
  }

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppFailureCopyWith<$Res> get failure {
    return $AppFailureCopyWith<$Res>(_value.failure, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }
}

/// @nodoc

class _$ErrorCaptureStateImpl implements ErrorCaptureState {
  const _$ErrorCaptureStateImpl(this.failure);

  @override
  final AppFailure failure;

  @override
  String toString() {
    return 'CaptureState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorCaptureStateImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorCaptureStateImplCopyWith<_$ErrorCaptureStateImpl> get copyWith =>
      __$$ErrorCaptureStateImplCopyWithImpl<_$ErrorCaptureStateImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() disconnected,
    required TResult Function() connecting,
    required TResult Function() listening,
    required TResult Function() paused,
    required TResult Function(AppFailure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? disconnected,
    TResult? Function()? connecting,
    TResult? Function()? listening,
    TResult? Function()? paused,
    TResult? Function(AppFailure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? disconnected,
    TResult Function()? connecting,
    TResult Function()? listening,
    TResult Function()? paused,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DisconnectedCaptureState value) disconnected,
    required TResult Function(ConnectingCaptureState value) connecting,
    required TResult Function(ListeningCaptureState value) listening,
    required TResult Function(PausedCaptureState value) paused,
    required TResult Function(ErrorCaptureState value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DisconnectedCaptureState value)? disconnected,
    TResult? Function(ConnectingCaptureState value)? connecting,
    TResult? Function(ListeningCaptureState value)? listening,
    TResult? Function(PausedCaptureState value)? paused,
    TResult? Function(ErrorCaptureState value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DisconnectedCaptureState value)? disconnected,
    TResult Function(ConnectingCaptureState value)? connecting,
    TResult Function(ListeningCaptureState value)? listening,
    TResult Function(PausedCaptureState value)? paused,
    TResult Function(ErrorCaptureState value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ErrorCaptureState implements CaptureState {
  const factory ErrorCaptureState(final AppFailure failure) =
      _$ErrorCaptureStateImpl;

  AppFailure get failure;

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorCaptureStateImplCopyWith<_$ErrorCaptureStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
