// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppFailure {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )
    wire,
    required TResult Function(String message, Object? cause) network,
    required TResult Function(String message) unauthenticated,
    required TResult Function(String message, String? code) platform,
    required TResult Function(
      String message,
      Object? cause,
      StackTrace? stackTrace,
    )
    unexpected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult? Function(String message, Object? cause)? network,
    TResult? Function(String message)? unauthenticated,
    TResult? Function(String message, String? code)? platform,
    TResult? Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult Function(String message, Object? cause)? network,
    TResult Function(String message)? unauthenticated,
    TResult Function(String message, String? code)? platform,
    TResult Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WireAppFailure value) wire,
    required TResult Function(NetworkAppFailure value) network,
    required TResult Function(UnauthenticatedAppFailure value) unauthenticated,
    required TResult Function(PlatformAppFailure value) platform,
    required TResult Function(UnexpectedAppFailure value) unexpected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WireAppFailure value)? wire,
    TResult? Function(NetworkAppFailure value)? network,
    TResult? Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult? Function(PlatformAppFailure value)? platform,
    TResult? Function(UnexpectedAppFailure value)? unexpected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WireAppFailure value)? wire,
    TResult Function(NetworkAppFailure value)? network,
    TResult Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult Function(PlatformAppFailure value)? platform,
    TResult Function(UnexpectedAppFailure value)? unexpected,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppFailureCopyWith<AppFailure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppFailureCopyWith<$Res> {
  factory $AppFailureCopyWith(
    AppFailure value,
    $Res Function(AppFailure) then,
  ) = _$AppFailureCopyWithImpl<$Res, AppFailure>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AppFailureCopyWithImpl<$Res, $Val extends AppFailure>
    implements $AppFailureCopyWith<$Res> {
  _$AppFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WireAppFailureImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$WireAppFailureImplCopyWith(
    _$WireAppFailureImpl value,
    $Res Function(_$WireAppFailureImpl) then,
  ) = __$$WireAppFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    WireErrorCode code,
    String message,
    Map<String, Object?>? details,
  });
}

/// @nodoc
class __$$WireAppFailureImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$WireAppFailureImpl>
    implements _$$WireAppFailureImplCopyWith<$Res> {
  __$$WireAppFailureImplCopyWithImpl(
    _$WireAppFailureImpl _value,
    $Res Function(_$WireAppFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(
      _$WireAppFailureImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as WireErrorCode,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, Object?>?,
      ),
    );
  }
}

/// @nodoc

class _$WireAppFailureImpl implements WireAppFailure {
  const _$WireAppFailureImpl({
    required this.code,
    required this.message,
    final Map<String, Object?>? details,
  }) : _details = details;

  @override
  final WireErrorCode code;
  @override
  final String message;
  final Map<String, Object?>? _details;
  @override
  Map<String, Object?>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppFailure.wire(code: $code, message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WireAppFailureImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    message,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WireAppFailureImplCopyWith<_$WireAppFailureImpl> get copyWith =>
      __$$WireAppFailureImplCopyWithImpl<_$WireAppFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )
    wire,
    required TResult Function(String message, Object? cause) network,
    required TResult Function(String message) unauthenticated,
    required TResult Function(String message, String? code) platform,
    required TResult Function(
      String message,
      Object? cause,
      StackTrace? stackTrace,
    )
    unexpected,
  }) {
    return wire(code, message, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult? Function(String message, Object? cause)? network,
    TResult? Function(String message)? unauthenticated,
    TResult? Function(String message, String? code)? platform,
    TResult? Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
  }) {
    return wire?.call(code, message, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult Function(String message, Object? cause)? network,
    TResult Function(String message)? unauthenticated,
    TResult Function(String message, String? code)? platform,
    TResult Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
    required TResult orElse(),
  }) {
    if (wire != null) {
      return wire(code, message, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WireAppFailure value) wire,
    required TResult Function(NetworkAppFailure value) network,
    required TResult Function(UnauthenticatedAppFailure value) unauthenticated,
    required TResult Function(PlatformAppFailure value) platform,
    required TResult Function(UnexpectedAppFailure value) unexpected,
  }) {
    return wire(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WireAppFailure value)? wire,
    TResult? Function(NetworkAppFailure value)? network,
    TResult? Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult? Function(PlatformAppFailure value)? platform,
    TResult? Function(UnexpectedAppFailure value)? unexpected,
  }) {
    return wire?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WireAppFailure value)? wire,
    TResult Function(NetworkAppFailure value)? network,
    TResult Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult Function(PlatformAppFailure value)? platform,
    TResult Function(UnexpectedAppFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (wire != null) {
      return wire(this);
    }
    return orElse();
  }
}

abstract class WireAppFailure implements AppFailure {
  const factory WireAppFailure({
    required final WireErrorCode code,
    required final String message,
    final Map<String, Object?>? details,
  }) = _$WireAppFailureImpl;

  WireErrorCode get code;
  @override
  String get message;
  Map<String, Object?>? get details;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WireAppFailureImplCopyWith<_$WireAppFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NetworkAppFailureImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$NetworkAppFailureImplCopyWith(
    _$NetworkAppFailureImpl value,
    $Res Function(_$NetworkAppFailureImpl) then,
  ) = __$$NetworkAppFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? cause});
}

/// @nodoc
class __$$NetworkAppFailureImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$NetworkAppFailureImpl>
    implements _$$NetworkAppFailureImplCopyWith<$Res> {
  __$$NetworkAppFailureImplCopyWithImpl(
    _$NetworkAppFailureImpl _value,
    $Res Function(_$NetworkAppFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? cause = freezed}) {
    return _then(
      _$NetworkAppFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        cause: freezed == cause ? _value.cause : cause,
      ),
    );
  }
}

/// @nodoc

class _$NetworkAppFailureImpl implements NetworkAppFailure {
  const _$NetworkAppFailureImpl({required this.message, this.cause});

  @override
  final String message;
  @override
  final Object? cause;

  @override
  String toString() {
    return 'AppFailure.network(message: $message, cause: $cause)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkAppFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.cause, cause));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(cause),
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkAppFailureImplCopyWith<_$NetworkAppFailureImpl> get copyWith =>
      __$$NetworkAppFailureImplCopyWithImpl<_$NetworkAppFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )
    wire,
    required TResult Function(String message, Object? cause) network,
    required TResult Function(String message) unauthenticated,
    required TResult Function(String message, String? code) platform,
    required TResult Function(
      String message,
      Object? cause,
      StackTrace? stackTrace,
    )
    unexpected,
  }) {
    return network(message, cause);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult? Function(String message, Object? cause)? network,
    TResult? Function(String message)? unauthenticated,
    TResult? Function(String message, String? code)? platform,
    TResult? Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
  }) {
    return network?.call(message, cause);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult Function(String message, Object? cause)? network,
    TResult Function(String message)? unauthenticated,
    TResult Function(String message, String? code)? platform,
    TResult Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, cause);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WireAppFailure value) wire,
    required TResult Function(NetworkAppFailure value) network,
    required TResult Function(UnauthenticatedAppFailure value) unauthenticated,
    required TResult Function(PlatformAppFailure value) platform,
    required TResult Function(UnexpectedAppFailure value) unexpected,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WireAppFailure value)? wire,
    TResult? Function(NetworkAppFailure value)? network,
    TResult? Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult? Function(PlatformAppFailure value)? platform,
    TResult? Function(UnexpectedAppFailure value)? unexpected,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WireAppFailure value)? wire,
    TResult Function(NetworkAppFailure value)? network,
    TResult Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult Function(PlatformAppFailure value)? platform,
    TResult Function(UnexpectedAppFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkAppFailure implements AppFailure {
  const factory NetworkAppFailure({
    required final String message,
    final Object? cause,
  }) = _$NetworkAppFailureImpl;

  @override
  String get message;
  Object? get cause;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkAppFailureImplCopyWith<_$NetworkAppFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthenticatedAppFailureImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$UnauthenticatedAppFailureImplCopyWith(
    _$UnauthenticatedAppFailureImpl value,
    $Res Function(_$UnauthenticatedAppFailureImpl) then,
  ) = __$$UnauthenticatedAppFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnauthenticatedAppFailureImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$UnauthenticatedAppFailureImpl>
    implements _$$UnauthenticatedAppFailureImplCopyWith<$Res> {
  __$$UnauthenticatedAppFailureImplCopyWithImpl(
    _$UnauthenticatedAppFailureImpl _value,
    $Res Function(_$UnauthenticatedAppFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$UnauthenticatedAppFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UnauthenticatedAppFailureImpl implements UnauthenticatedAppFailure {
  const _$UnauthenticatedAppFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AppFailure.unauthenticated(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthenticatedAppFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthenticatedAppFailureImplCopyWith<_$UnauthenticatedAppFailureImpl>
  get copyWith =>
      __$$UnauthenticatedAppFailureImplCopyWithImpl<
        _$UnauthenticatedAppFailureImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )
    wire,
    required TResult Function(String message, Object? cause) network,
    required TResult Function(String message) unauthenticated,
    required TResult Function(String message, String? code) platform,
    required TResult Function(
      String message,
      Object? cause,
      StackTrace? stackTrace,
    )
    unexpected,
  }) {
    return unauthenticated(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult? Function(String message, Object? cause)? network,
    TResult? Function(String message)? unauthenticated,
    TResult? Function(String message, String? code)? platform,
    TResult? Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
  }) {
    return unauthenticated?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult Function(String message, Object? cause)? network,
    TResult Function(String message)? unauthenticated,
    TResult Function(String message, String? code)? platform,
    TResult Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WireAppFailure value) wire,
    required TResult Function(NetworkAppFailure value) network,
    required TResult Function(UnauthenticatedAppFailure value) unauthenticated,
    required TResult Function(PlatformAppFailure value) platform,
    required TResult Function(UnexpectedAppFailure value) unexpected,
  }) {
    return unauthenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WireAppFailure value)? wire,
    TResult? Function(NetworkAppFailure value)? network,
    TResult? Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult? Function(PlatformAppFailure value)? platform,
    TResult? Function(UnexpectedAppFailure value)? unexpected,
  }) {
    return unauthenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WireAppFailure value)? wire,
    TResult Function(NetworkAppFailure value)? network,
    TResult Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult Function(PlatformAppFailure value)? platform,
    TResult Function(UnexpectedAppFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(this);
    }
    return orElse();
  }
}

abstract class UnauthenticatedAppFailure implements AppFailure {
  const factory UnauthenticatedAppFailure({required final String message}) =
      _$UnauthenticatedAppFailureImpl;

  @override
  String get message;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnauthenticatedAppFailureImplCopyWith<_$UnauthenticatedAppFailureImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PlatformAppFailureImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$PlatformAppFailureImplCopyWith(
    _$PlatformAppFailureImpl value,
    $Res Function(_$PlatformAppFailureImpl) then,
  ) = __$$PlatformAppFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$PlatformAppFailureImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$PlatformAppFailureImpl>
    implements _$$PlatformAppFailureImplCopyWith<$Res> {
  __$$PlatformAppFailureImplCopyWithImpl(
    _$PlatformAppFailureImpl _value,
    $Res Function(_$PlatformAppFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$PlatformAppFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PlatformAppFailureImpl implements PlatformAppFailure {
  const _$PlatformAppFailureImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'AppFailure.platform(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlatformAppFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlatformAppFailureImplCopyWith<_$PlatformAppFailureImpl> get copyWith =>
      __$$PlatformAppFailureImplCopyWithImpl<_$PlatformAppFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )
    wire,
    required TResult Function(String message, Object? cause) network,
    required TResult Function(String message) unauthenticated,
    required TResult Function(String message, String? code) platform,
    required TResult Function(
      String message,
      Object? cause,
      StackTrace? stackTrace,
    )
    unexpected,
  }) {
    return platform(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult? Function(String message, Object? cause)? network,
    TResult? Function(String message)? unauthenticated,
    TResult? Function(String message, String? code)? platform,
    TResult? Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
  }) {
    return platform?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult Function(String message, Object? cause)? network,
    TResult Function(String message)? unauthenticated,
    TResult Function(String message, String? code)? platform,
    TResult Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
    required TResult orElse(),
  }) {
    if (platform != null) {
      return platform(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WireAppFailure value) wire,
    required TResult Function(NetworkAppFailure value) network,
    required TResult Function(UnauthenticatedAppFailure value) unauthenticated,
    required TResult Function(PlatformAppFailure value) platform,
    required TResult Function(UnexpectedAppFailure value) unexpected,
  }) {
    return platform(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WireAppFailure value)? wire,
    TResult? Function(NetworkAppFailure value)? network,
    TResult? Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult? Function(PlatformAppFailure value)? platform,
    TResult? Function(UnexpectedAppFailure value)? unexpected,
  }) {
    return platform?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WireAppFailure value)? wire,
    TResult Function(NetworkAppFailure value)? network,
    TResult Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult Function(PlatformAppFailure value)? platform,
    TResult Function(UnexpectedAppFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (platform != null) {
      return platform(this);
    }
    return orElse();
  }
}

abstract class PlatformAppFailure implements AppFailure {
  const factory PlatformAppFailure({
    required final String message,
    final String? code,
  }) = _$PlatformAppFailureImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlatformAppFailureImplCopyWith<_$PlatformAppFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnexpectedAppFailureImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$UnexpectedAppFailureImplCopyWith(
    _$UnexpectedAppFailureImpl value,
    $Res Function(_$UnexpectedAppFailureImpl) then,
  ) = __$$UnexpectedAppFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? cause, StackTrace? stackTrace});
}

/// @nodoc
class __$$UnexpectedAppFailureImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$UnexpectedAppFailureImpl>
    implements _$$UnexpectedAppFailureImplCopyWith<$Res> {
  __$$UnexpectedAppFailureImplCopyWithImpl(
    _$UnexpectedAppFailureImpl _value,
    $Res Function(_$UnexpectedAppFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? cause = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(
      _$UnexpectedAppFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        cause: freezed == cause ? _value.cause : cause,
        stackTrace: freezed == stackTrace
            ? _value.stackTrace
            : stackTrace // ignore: cast_nullable_to_non_nullable
                  as StackTrace?,
      ),
    );
  }
}

/// @nodoc

class _$UnexpectedAppFailureImpl implements UnexpectedAppFailure {
  const _$UnexpectedAppFailureImpl({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  @override
  final String message;
  @override
  final Object? cause;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'AppFailure.unexpected(message: $message, cause: $cause, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnexpectedAppFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.cause, cause) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(cause),
    stackTrace,
  );

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnexpectedAppFailureImplCopyWith<_$UnexpectedAppFailureImpl>
  get copyWith =>
      __$$UnexpectedAppFailureImplCopyWithImpl<_$UnexpectedAppFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )
    wire,
    required TResult Function(String message, Object? cause) network,
    required TResult Function(String message) unauthenticated,
    required TResult Function(String message, String? code) platform,
    required TResult Function(
      String message,
      Object? cause,
      StackTrace? stackTrace,
    )
    unexpected,
  }) {
    return unexpected(message, cause, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult? Function(String message, Object? cause)? network,
    TResult? Function(String message)? unauthenticated,
    TResult? Function(String message, String? code)? platform,
    TResult? Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
  }) {
    return unexpected?.call(message, cause, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      WireErrorCode code,
      String message,
      Map<String, Object?>? details,
    )?
    wire,
    TResult Function(String message, Object? cause)? network,
    TResult Function(String message)? unauthenticated,
    TResult Function(String message, String? code)? platform,
    TResult Function(String message, Object? cause, StackTrace? stackTrace)?
    unexpected,
    required TResult orElse(),
  }) {
    if (unexpected != null) {
      return unexpected(message, cause, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WireAppFailure value) wire,
    required TResult Function(NetworkAppFailure value) network,
    required TResult Function(UnauthenticatedAppFailure value) unauthenticated,
    required TResult Function(PlatformAppFailure value) platform,
    required TResult Function(UnexpectedAppFailure value) unexpected,
  }) {
    return unexpected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WireAppFailure value)? wire,
    TResult? Function(NetworkAppFailure value)? network,
    TResult? Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult? Function(PlatformAppFailure value)? platform,
    TResult? Function(UnexpectedAppFailure value)? unexpected,
  }) {
    return unexpected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WireAppFailure value)? wire,
    TResult Function(NetworkAppFailure value)? network,
    TResult Function(UnauthenticatedAppFailure value)? unauthenticated,
    TResult Function(PlatformAppFailure value)? platform,
    TResult Function(UnexpectedAppFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (unexpected != null) {
      return unexpected(this);
    }
    return orElse();
  }
}

abstract class UnexpectedAppFailure implements AppFailure {
  const factory UnexpectedAppFailure({
    required final String message,
    final Object? cause,
    final StackTrace? stackTrace,
  }) = _$UnexpectedAppFailureImpl;

  @override
  String get message;
  Object? get cause;
  StackTrace? get stackTrace;

  /// Create a copy of AppFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnexpectedAppFailureImplCopyWith<_$UnexpectedAppFailureImpl>
  get copyWith => throw _privateConstructorUsedError;
}
