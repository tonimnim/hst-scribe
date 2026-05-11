// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SignedSession {
  String get sessionId => throw _privateConstructorUsedError;
  DateTime get signedAt => throw _privateConstructorUsedError;
  int get eventsWritten => throw _privateConstructorUsedError;
  int get eventsRejected => throw _privateConstructorUsedError;

  /// Create a copy of SignedSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignedSessionCopyWith<SignedSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignedSessionCopyWith<$Res> {
  factory $SignedSessionCopyWith(
    SignedSession value,
    $Res Function(SignedSession) then,
  ) = _$SignedSessionCopyWithImpl<$Res, SignedSession>;
  @useResult
  $Res call({
    String sessionId,
    DateTime signedAt,
    int eventsWritten,
    int eventsRejected,
  });
}

/// @nodoc
class _$SignedSessionCopyWithImpl<$Res, $Val extends SignedSession>
    implements $SignedSessionCopyWith<$Res> {
  _$SignedSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignedSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? signedAt = null,
    Object? eventsWritten = null,
    Object? eventsRejected = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId:
                null == sessionId
                    ? _value.sessionId
                    : sessionId // ignore: cast_nullable_to_non_nullable
                        as String,
            signedAt:
                null == signedAt
                    ? _value.signedAt
                    : signedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            eventsWritten:
                null == eventsWritten
                    ? _value.eventsWritten
                    : eventsWritten // ignore: cast_nullable_to_non_nullable
                        as int,
            eventsRejected:
                null == eventsRejected
                    ? _value.eventsRejected
                    : eventsRejected // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SignedSessionImplCopyWith<$Res>
    implements $SignedSessionCopyWith<$Res> {
  factory _$$SignedSessionImplCopyWith(
    _$SignedSessionImpl value,
    $Res Function(_$SignedSessionImpl) then,
  ) = __$$SignedSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    DateTime signedAt,
    int eventsWritten,
    int eventsRejected,
  });
}

/// @nodoc
class __$$SignedSessionImplCopyWithImpl<$Res>
    extends _$SignedSessionCopyWithImpl<$Res, _$SignedSessionImpl>
    implements _$$SignedSessionImplCopyWith<$Res> {
  __$$SignedSessionImplCopyWithImpl(
    _$SignedSessionImpl _value,
    $Res Function(_$SignedSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignedSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? signedAt = null,
    Object? eventsWritten = null,
    Object? eventsRejected = null,
  }) {
    return _then(
      _$SignedSessionImpl(
        sessionId:
            null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                    as String,
        signedAt:
            null == signedAt
                ? _value.signedAt
                : signedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        eventsWritten:
            null == eventsWritten
                ? _value.eventsWritten
                : eventsWritten // ignore: cast_nullable_to_non_nullable
                    as int,
        eventsRejected:
            null == eventsRejected
                ? _value.eventsRejected
                : eventsRejected // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc

class _$SignedSessionImpl implements _SignedSession {
  const _$SignedSessionImpl({
    required this.sessionId,
    required this.signedAt,
    required this.eventsWritten,
    required this.eventsRejected,
  });

  @override
  final String sessionId;
  @override
  final DateTime signedAt;
  @override
  final int eventsWritten;
  @override
  final int eventsRejected;

  @override
  String toString() {
    return 'SignedSession(sessionId: $sessionId, signedAt: $signedAt, eventsWritten: $eventsWritten, eventsRejected: $eventsRejected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignedSessionImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.signedAt, signedAt) ||
                other.signedAt == signedAt) &&
            (identical(other.eventsWritten, eventsWritten) ||
                other.eventsWritten == eventsWritten) &&
            (identical(other.eventsRejected, eventsRejected) ||
                other.eventsRejected == eventsRejected));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    signedAt,
    eventsWritten,
    eventsRejected,
  );

  /// Create a copy of SignedSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignedSessionImplCopyWith<_$SignedSessionImpl> get copyWith =>
      __$$SignedSessionImplCopyWithImpl<_$SignedSessionImpl>(this, _$identity);
}

abstract class _SignedSession implements SignedSession {
  const factory _SignedSession({
    required final String sessionId,
    required final DateTime signedAt,
    required final int eventsWritten,
    required final int eventsRejected,
  }) = _$SignedSessionImpl;

  @override
  String get sessionId;
  @override
  DateTime get signedAt;
  @override
  int get eventsWritten;
  @override
  int get eventsRejected;

  /// Create a copy of SignedSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignedSessionImplCopyWith<_$SignedSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SignState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() summarizing,
    required TResult Function() promptingBiometric,
    required TResult Function() promptingPin,
    required TResult Function() submitting,
    required TResult Function(SignedSession signed) success,
    required TResult Function(AppFailure failure) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? summarizing,
    TResult? Function()? promptingBiometric,
    TResult? Function()? promptingPin,
    TResult? Function()? submitting,
    TResult? Function(SignedSession signed)? success,
    TResult? Function(AppFailure failure)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? summarizing,
    TResult Function()? promptingBiometric,
    TResult Function()? promptingPin,
    TResult Function()? submitting,
    TResult Function(SignedSession signed)? success,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleSignState value) idle,
    required TResult Function(SummarizingSignState value) summarizing,
    required TResult Function(PromptingBiometricSignState value)
    promptingBiometric,
    required TResult Function(PromptingPinSignState value) promptingPin,
    required TResult Function(SubmittingSignState value) submitting,
    required TResult Function(SuccessSignState value) success,
    required TResult Function(ErrorSignState value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleSignState value)? idle,
    TResult? Function(SummarizingSignState value)? summarizing,
    TResult? Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult? Function(PromptingPinSignState value)? promptingPin,
    TResult? Function(SubmittingSignState value)? submitting,
    TResult? Function(SuccessSignState value)? success,
    TResult? Function(ErrorSignState value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleSignState value)? idle,
    TResult Function(SummarizingSignState value)? summarizing,
    TResult Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult Function(PromptingPinSignState value)? promptingPin,
    TResult Function(SubmittingSignState value)? submitting,
    TResult Function(SuccessSignState value)? success,
    TResult Function(ErrorSignState value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignStateCopyWith<$Res> {
  factory $SignStateCopyWith(SignState value, $Res Function(SignState) then) =
      _$SignStateCopyWithImpl<$Res, SignState>;
}

/// @nodoc
class _$SignStateCopyWithImpl<$Res, $Val extends SignState>
    implements $SignStateCopyWith<$Res> {
  _$SignStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleSignStateImplCopyWith<$Res> {
  factory _$$IdleSignStateImplCopyWith(
    _$IdleSignStateImpl value,
    $Res Function(_$IdleSignStateImpl) then,
  ) = __$$IdleSignStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleSignStateImplCopyWithImpl<$Res>
    extends _$SignStateCopyWithImpl<$Res, _$IdleSignStateImpl>
    implements _$$IdleSignStateImplCopyWith<$Res> {
  __$$IdleSignStateImplCopyWithImpl(
    _$IdleSignStateImpl _value,
    $Res Function(_$IdleSignStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$IdleSignStateImpl implements IdleSignState {
  const _$IdleSignStateImpl();

  @override
  String toString() {
    return 'SignState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleSignStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() summarizing,
    required TResult Function() promptingBiometric,
    required TResult Function() promptingPin,
    required TResult Function() submitting,
    required TResult Function(SignedSession signed) success,
    required TResult Function(AppFailure failure) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? summarizing,
    TResult? Function()? promptingBiometric,
    TResult? Function()? promptingPin,
    TResult? Function()? submitting,
    TResult? Function(SignedSession signed)? success,
    TResult? Function(AppFailure failure)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? summarizing,
    TResult Function()? promptingBiometric,
    TResult Function()? promptingPin,
    TResult Function()? submitting,
    TResult Function(SignedSession signed)? success,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleSignState value) idle,
    required TResult Function(SummarizingSignState value) summarizing,
    required TResult Function(PromptingBiometricSignState value)
    promptingBiometric,
    required TResult Function(PromptingPinSignState value) promptingPin,
    required TResult Function(SubmittingSignState value) submitting,
    required TResult Function(SuccessSignState value) success,
    required TResult Function(ErrorSignState value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleSignState value)? idle,
    TResult? Function(SummarizingSignState value)? summarizing,
    TResult? Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult? Function(PromptingPinSignState value)? promptingPin,
    TResult? Function(SubmittingSignState value)? submitting,
    TResult? Function(SuccessSignState value)? success,
    TResult? Function(ErrorSignState value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleSignState value)? idle,
    TResult Function(SummarizingSignState value)? summarizing,
    TResult Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult Function(PromptingPinSignState value)? promptingPin,
    TResult Function(SubmittingSignState value)? submitting,
    TResult Function(SuccessSignState value)? success,
    TResult Function(ErrorSignState value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class IdleSignState implements SignState {
  const factory IdleSignState() = _$IdleSignStateImpl;
}

/// @nodoc
abstract class _$$SummarizingSignStateImplCopyWith<$Res> {
  factory _$$SummarizingSignStateImplCopyWith(
    _$SummarizingSignStateImpl value,
    $Res Function(_$SummarizingSignStateImpl) then,
  ) = __$$SummarizingSignStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SummarizingSignStateImplCopyWithImpl<$Res>
    extends _$SignStateCopyWithImpl<$Res, _$SummarizingSignStateImpl>
    implements _$$SummarizingSignStateImplCopyWith<$Res> {
  __$$SummarizingSignStateImplCopyWithImpl(
    _$SummarizingSignStateImpl _value,
    $Res Function(_$SummarizingSignStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SummarizingSignStateImpl implements SummarizingSignState {
  const _$SummarizingSignStateImpl();

  @override
  String toString() {
    return 'SignState.summarizing()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummarizingSignStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() summarizing,
    required TResult Function() promptingBiometric,
    required TResult Function() promptingPin,
    required TResult Function() submitting,
    required TResult Function(SignedSession signed) success,
    required TResult Function(AppFailure failure) error,
  }) {
    return summarizing();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? summarizing,
    TResult? Function()? promptingBiometric,
    TResult? Function()? promptingPin,
    TResult? Function()? submitting,
    TResult? Function(SignedSession signed)? success,
    TResult? Function(AppFailure failure)? error,
  }) {
    return summarizing?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? summarizing,
    TResult Function()? promptingBiometric,
    TResult Function()? promptingPin,
    TResult Function()? submitting,
    TResult Function(SignedSession signed)? success,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (summarizing != null) {
      return summarizing();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleSignState value) idle,
    required TResult Function(SummarizingSignState value) summarizing,
    required TResult Function(PromptingBiometricSignState value)
    promptingBiometric,
    required TResult Function(PromptingPinSignState value) promptingPin,
    required TResult Function(SubmittingSignState value) submitting,
    required TResult Function(SuccessSignState value) success,
    required TResult Function(ErrorSignState value) error,
  }) {
    return summarizing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleSignState value)? idle,
    TResult? Function(SummarizingSignState value)? summarizing,
    TResult? Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult? Function(PromptingPinSignState value)? promptingPin,
    TResult? Function(SubmittingSignState value)? submitting,
    TResult? Function(SuccessSignState value)? success,
    TResult? Function(ErrorSignState value)? error,
  }) {
    return summarizing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleSignState value)? idle,
    TResult Function(SummarizingSignState value)? summarizing,
    TResult Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult Function(PromptingPinSignState value)? promptingPin,
    TResult Function(SubmittingSignState value)? submitting,
    TResult Function(SuccessSignState value)? success,
    TResult Function(ErrorSignState value)? error,
    required TResult orElse(),
  }) {
    if (summarizing != null) {
      return summarizing(this);
    }
    return orElse();
  }
}

abstract class SummarizingSignState implements SignState {
  const factory SummarizingSignState() = _$SummarizingSignStateImpl;
}

/// @nodoc
abstract class _$$PromptingBiometricSignStateImplCopyWith<$Res> {
  factory _$$PromptingBiometricSignStateImplCopyWith(
    _$PromptingBiometricSignStateImpl value,
    $Res Function(_$PromptingBiometricSignStateImpl) then,
  ) = __$$PromptingBiometricSignStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PromptingBiometricSignStateImplCopyWithImpl<$Res>
    extends _$SignStateCopyWithImpl<$Res, _$PromptingBiometricSignStateImpl>
    implements _$$PromptingBiometricSignStateImplCopyWith<$Res> {
  __$$PromptingBiometricSignStateImplCopyWithImpl(
    _$PromptingBiometricSignStateImpl _value,
    $Res Function(_$PromptingBiometricSignStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PromptingBiometricSignStateImpl implements PromptingBiometricSignState {
  const _$PromptingBiometricSignStateImpl();

  @override
  String toString() {
    return 'SignState.promptingBiometric()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromptingBiometricSignStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() summarizing,
    required TResult Function() promptingBiometric,
    required TResult Function() promptingPin,
    required TResult Function() submitting,
    required TResult Function(SignedSession signed) success,
    required TResult Function(AppFailure failure) error,
  }) {
    return promptingBiometric();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? summarizing,
    TResult? Function()? promptingBiometric,
    TResult? Function()? promptingPin,
    TResult? Function()? submitting,
    TResult? Function(SignedSession signed)? success,
    TResult? Function(AppFailure failure)? error,
  }) {
    return promptingBiometric?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? summarizing,
    TResult Function()? promptingBiometric,
    TResult Function()? promptingPin,
    TResult Function()? submitting,
    TResult Function(SignedSession signed)? success,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (promptingBiometric != null) {
      return promptingBiometric();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleSignState value) idle,
    required TResult Function(SummarizingSignState value) summarizing,
    required TResult Function(PromptingBiometricSignState value)
    promptingBiometric,
    required TResult Function(PromptingPinSignState value) promptingPin,
    required TResult Function(SubmittingSignState value) submitting,
    required TResult Function(SuccessSignState value) success,
    required TResult Function(ErrorSignState value) error,
  }) {
    return promptingBiometric(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleSignState value)? idle,
    TResult? Function(SummarizingSignState value)? summarizing,
    TResult? Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult? Function(PromptingPinSignState value)? promptingPin,
    TResult? Function(SubmittingSignState value)? submitting,
    TResult? Function(SuccessSignState value)? success,
    TResult? Function(ErrorSignState value)? error,
  }) {
    return promptingBiometric?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleSignState value)? idle,
    TResult Function(SummarizingSignState value)? summarizing,
    TResult Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult Function(PromptingPinSignState value)? promptingPin,
    TResult Function(SubmittingSignState value)? submitting,
    TResult Function(SuccessSignState value)? success,
    TResult Function(ErrorSignState value)? error,
    required TResult orElse(),
  }) {
    if (promptingBiometric != null) {
      return promptingBiometric(this);
    }
    return orElse();
  }
}

abstract class PromptingBiometricSignState implements SignState {
  const factory PromptingBiometricSignState() =
      _$PromptingBiometricSignStateImpl;
}

/// @nodoc
abstract class _$$PromptingPinSignStateImplCopyWith<$Res> {
  factory _$$PromptingPinSignStateImplCopyWith(
    _$PromptingPinSignStateImpl value,
    $Res Function(_$PromptingPinSignStateImpl) then,
  ) = __$$PromptingPinSignStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PromptingPinSignStateImplCopyWithImpl<$Res>
    extends _$SignStateCopyWithImpl<$Res, _$PromptingPinSignStateImpl>
    implements _$$PromptingPinSignStateImplCopyWith<$Res> {
  __$$PromptingPinSignStateImplCopyWithImpl(
    _$PromptingPinSignStateImpl _value,
    $Res Function(_$PromptingPinSignStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PromptingPinSignStateImpl implements PromptingPinSignState {
  const _$PromptingPinSignStateImpl();

  @override
  String toString() {
    return 'SignState.promptingPin()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromptingPinSignStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() summarizing,
    required TResult Function() promptingBiometric,
    required TResult Function() promptingPin,
    required TResult Function() submitting,
    required TResult Function(SignedSession signed) success,
    required TResult Function(AppFailure failure) error,
  }) {
    return promptingPin();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? summarizing,
    TResult? Function()? promptingBiometric,
    TResult? Function()? promptingPin,
    TResult? Function()? submitting,
    TResult? Function(SignedSession signed)? success,
    TResult? Function(AppFailure failure)? error,
  }) {
    return promptingPin?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? summarizing,
    TResult Function()? promptingBiometric,
    TResult Function()? promptingPin,
    TResult Function()? submitting,
    TResult Function(SignedSession signed)? success,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (promptingPin != null) {
      return promptingPin();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleSignState value) idle,
    required TResult Function(SummarizingSignState value) summarizing,
    required TResult Function(PromptingBiometricSignState value)
    promptingBiometric,
    required TResult Function(PromptingPinSignState value) promptingPin,
    required TResult Function(SubmittingSignState value) submitting,
    required TResult Function(SuccessSignState value) success,
    required TResult Function(ErrorSignState value) error,
  }) {
    return promptingPin(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleSignState value)? idle,
    TResult? Function(SummarizingSignState value)? summarizing,
    TResult? Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult? Function(PromptingPinSignState value)? promptingPin,
    TResult? Function(SubmittingSignState value)? submitting,
    TResult? Function(SuccessSignState value)? success,
    TResult? Function(ErrorSignState value)? error,
  }) {
    return promptingPin?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleSignState value)? idle,
    TResult Function(SummarizingSignState value)? summarizing,
    TResult Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult Function(PromptingPinSignState value)? promptingPin,
    TResult Function(SubmittingSignState value)? submitting,
    TResult Function(SuccessSignState value)? success,
    TResult Function(ErrorSignState value)? error,
    required TResult orElse(),
  }) {
    if (promptingPin != null) {
      return promptingPin(this);
    }
    return orElse();
  }
}

abstract class PromptingPinSignState implements SignState {
  const factory PromptingPinSignState() = _$PromptingPinSignStateImpl;
}

/// @nodoc
abstract class _$$SubmittingSignStateImplCopyWith<$Res> {
  factory _$$SubmittingSignStateImplCopyWith(
    _$SubmittingSignStateImpl value,
    $Res Function(_$SubmittingSignStateImpl) then,
  ) = __$$SubmittingSignStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubmittingSignStateImplCopyWithImpl<$Res>
    extends _$SignStateCopyWithImpl<$Res, _$SubmittingSignStateImpl>
    implements _$$SubmittingSignStateImplCopyWith<$Res> {
  __$$SubmittingSignStateImplCopyWithImpl(
    _$SubmittingSignStateImpl _value,
    $Res Function(_$SubmittingSignStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SubmittingSignStateImpl implements SubmittingSignState {
  const _$SubmittingSignStateImpl();

  @override
  String toString() {
    return 'SignState.submitting()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmittingSignStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() summarizing,
    required TResult Function() promptingBiometric,
    required TResult Function() promptingPin,
    required TResult Function() submitting,
    required TResult Function(SignedSession signed) success,
    required TResult Function(AppFailure failure) error,
  }) {
    return submitting();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? summarizing,
    TResult? Function()? promptingBiometric,
    TResult? Function()? promptingPin,
    TResult? Function()? submitting,
    TResult? Function(SignedSession signed)? success,
    TResult? Function(AppFailure failure)? error,
  }) {
    return submitting?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? summarizing,
    TResult Function()? promptingBiometric,
    TResult Function()? promptingPin,
    TResult Function()? submitting,
    TResult Function(SignedSession signed)? success,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleSignState value) idle,
    required TResult Function(SummarizingSignState value) summarizing,
    required TResult Function(PromptingBiometricSignState value)
    promptingBiometric,
    required TResult Function(PromptingPinSignState value) promptingPin,
    required TResult Function(SubmittingSignState value) submitting,
    required TResult Function(SuccessSignState value) success,
    required TResult Function(ErrorSignState value) error,
  }) {
    return submitting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleSignState value)? idle,
    TResult? Function(SummarizingSignState value)? summarizing,
    TResult? Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult? Function(PromptingPinSignState value)? promptingPin,
    TResult? Function(SubmittingSignState value)? submitting,
    TResult? Function(SuccessSignState value)? success,
    TResult? Function(ErrorSignState value)? error,
  }) {
    return submitting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleSignState value)? idle,
    TResult Function(SummarizingSignState value)? summarizing,
    TResult Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult Function(PromptingPinSignState value)? promptingPin,
    TResult Function(SubmittingSignState value)? submitting,
    TResult Function(SuccessSignState value)? success,
    TResult Function(ErrorSignState value)? error,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting(this);
    }
    return orElse();
  }
}

abstract class SubmittingSignState implements SignState {
  const factory SubmittingSignState() = _$SubmittingSignStateImpl;
}

/// @nodoc
abstract class _$$SuccessSignStateImplCopyWith<$Res> {
  factory _$$SuccessSignStateImplCopyWith(
    _$SuccessSignStateImpl value,
    $Res Function(_$SuccessSignStateImpl) then,
  ) = __$$SuccessSignStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SignedSession signed});

  $SignedSessionCopyWith<$Res> get signed;
}

/// @nodoc
class __$$SuccessSignStateImplCopyWithImpl<$Res>
    extends _$SignStateCopyWithImpl<$Res, _$SuccessSignStateImpl>
    implements _$$SuccessSignStateImplCopyWith<$Res> {
  __$$SuccessSignStateImplCopyWithImpl(
    _$SuccessSignStateImpl _value,
    $Res Function(_$SuccessSignStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? signed = null}) {
    return _then(
      _$SuccessSignStateImpl(
        signed:
            null == signed
                ? _value.signed
                : signed // ignore: cast_nullable_to_non_nullable
                    as SignedSession,
      ),
    );
  }

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SignedSessionCopyWith<$Res> get signed {
    return $SignedSessionCopyWith<$Res>(_value.signed, (value) {
      return _then(_value.copyWith(signed: value));
    });
  }
}

/// @nodoc

class _$SuccessSignStateImpl implements SuccessSignState {
  const _$SuccessSignStateImpl({required this.signed});

  @override
  final SignedSession signed;

  @override
  String toString() {
    return 'SignState.success(signed: $signed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessSignStateImpl &&
            (identical(other.signed, signed) || other.signed == signed));
  }

  @override
  int get hashCode => Object.hash(runtimeType, signed);

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessSignStateImplCopyWith<_$SuccessSignStateImpl> get copyWith =>
      __$$SuccessSignStateImplCopyWithImpl<_$SuccessSignStateImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() summarizing,
    required TResult Function() promptingBiometric,
    required TResult Function() promptingPin,
    required TResult Function() submitting,
    required TResult Function(SignedSession signed) success,
    required TResult Function(AppFailure failure) error,
  }) {
    return success(signed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? summarizing,
    TResult? Function()? promptingBiometric,
    TResult? Function()? promptingPin,
    TResult? Function()? submitting,
    TResult? Function(SignedSession signed)? success,
    TResult? Function(AppFailure failure)? error,
  }) {
    return success?.call(signed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? summarizing,
    TResult Function()? promptingBiometric,
    TResult Function()? promptingPin,
    TResult Function()? submitting,
    TResult Function(SignedSession signed)? success,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(signed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleSignState value) idle,
    required TResult Function(SummarizingSignState value) summarizing,
    required TResult Function(PromptingBiometricSignState value)
    promptingBiometric,
    required TResult Function(PromptingPinSignState value) promptingPin,
    required TResult Function(SubmittingSignState value) submitting,
    required TResult Function(SuccessSignState value) success,
    required TResult Function(ErrorSignState value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleSignState value)? idle,
    TResult? Function(SummarizingSignState value)? summarizing,
    TResult? Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult? Function(PromptingPinSignState value)? promptingPin,
    TResult? Function(SubmittingSignState value)? submitting,
    TResult? Function(SuccessSignState value)? success,
    TResult? Function(ErrorSignState value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleSignState value)? idle,
    TResult Function(SummarizingSignState value)? summarizing,
    TResult Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult Function(PromptingPinSignState value)? promptingPin,
    TResult Function(SubmittingSignState value)? submitting,
    TResult Function(SuccessSignState value)? success,
    TResult Function(ErrorSignState value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class SuccessSignState implements SignState {
  const factory SuccessSignState({required final SignedSession signed}) =
      _$SuccessSignStateImpl;

  SignedSession get signed;

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessSignStateImplCopyWith<_$SuccessSignStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorSignStateImplCopyWith<$Res> {
  factory _$$ErrorSignStateImplCopyWith(
    _$ErrorSignStateImpl value,
    $Res Function(_$ErrorSignStateImpl) then,
  ) = __$$ErrorSignStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AppFailure failure});

  $AppFailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$ErrorSignStateImplCopyWithImpl<$Res>
    extends _$SignStateCopyWithImpl<$Res, _$ErrorSignStateImpl>
    implements _$$ErrorSignStateImplCopyWith<$Res> {
  __$$ErrorSignStateImplCopyWithImpl(
    _$ErrorSignStateImpl _value,
    $Res Function(_$ErrorSignStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? failure = null}) {
    return _then(
      _$ErrorSignStateImpl(
        failure:
            null == failure
                ? _value.failure
                : failure // ignore: cast_nullable_to_non_nullable
                    as AppFailure,
      ),
    );
  }

  /// Create a copy of SignState
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

class _$ErrorSignStateImpl implements ErrorSignState {
  const _$ErrorSignStateImpl({required this.failure});

  @override
  final AppFailure failure;

  @override
  String toString() {
    return 'SignState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorSignStateImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorSignStateImplCopyWith<_$ErrorSignStateImpl> get copyWith =>
      __$$ErrorSignStateImplCopyWithImpl<_$ErrorSignStateImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() summarizing,
    required TResult Function() promptingBiometric,
    required TResult Function() promptingPin,
    required TResult Function() submitting,
    required TResult Function(SignedSession signed) success,
    required TResult Function(AppFailure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? summarizing,
    TResult? Function()? promptingBiometric,
    TResult? Function()? promptingPin,
    TResult? Function()? submitting,
    TResult? Function(SignedSession signed)? success,
    TResult? Function(AppFailure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? summarizing,
    TResult Function()? promptingBiometric,
    TResult Function()? promptingPin,
    TResult Function()? submitting,
    TResult Function(SignedSession signed)? success,
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
    required TResult Function(IdleSignState value) idle,
    required TResult Function(SummarizingSignState value) summarizing,
    required TResult Function(PromptingBiometricSignState value)
    promptingBiometric,
    required TResult Function(PromptingPinSignState value) promptingPin,
    required TResult Function(SubmittingSignState value) submitting,
    required TResult Function(SuccessSignState value) success,
    required TResult Function(ErrorSignState value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleSignState value)? idle,
    TResult? Function(SummarizingSignState value)? summarizing,
    TResult? Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult? Function(PromptingPinSignState value)? promptingPin,
    TResult? Function(SubmittingSignState value)? submitting,
    TResult? Function(SuccessSignState value)? success,
    TResult? Function(ErrorSignState value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleSignState value)? idle,
    TResult Function(SummarizingSignState value)? summarizing,
    TResult Function(PromptingBiometricSignState value)? promptingBiometric,
    TResult Function(PromptingPinSignState value)? promptingPin,
    TResult Function(SubmittingSignState value)? submitting,
    TResult Function(SuccessSignState value)? success,
    TResult Function(ErrorSignState value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ErrorSignState implements SignState {
  const factory ErrorSignState({required final AppFailure failure}) =
      _$ErrorSignStateImpl;

  AppFailure get failure;

  /// Create a copy of SignState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorSignStateImplCopyWith<_$ErrorSignStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
