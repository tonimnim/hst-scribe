// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wire_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WireError _$WireErrorFromJson(Map<String, dynamic> json) {
  return _WireError.fromJson(json);
}

/// @nodoc
mixin _$WireError {
  String get code => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'details')
  Map<String, Object?>? get details => throw _privateConstructorUsedError;

  /// Serializes this WireError to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WireError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WireErrorCopyWith<WireError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WireErrorCopyWith<$Res> {
  factory $WireErrorCopyWith(WireError value, $Res Function(WireError) then) =
      _$WireErrorCopyWithImpl<$Res, WireError>;
  @useResult
  $Res call({
    String code,
    String message,
    @JsonKey(name: 'details') Map<String, Object?>? details,
  });
}

/// @nodoc
class _$WireErrorCopyWithImpl<$Res, $Val extends WireError>
    implements $WireErrorCopyWith<$Res> {
  _$WireErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WireError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            details: freezed == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as Map<String, Object?>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WireErrorImplCopyWith<$Res>
    implements $WireErrorCopyWith<$Res> {
  factory _$$WireErrorImplCopyWith(
    _$WireErrorImpl value,
    $Res Function(_$WireErrorImpl) then,
  ) = __$$WireErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String code,
    String message,
    @JsonKey(name: 'details') Map<String, Object?>? details,
  });
}

/// @nodoc
class __$$WireErrorImplCopyWithImpl<$Res>
    extends _$WireErrorCopyWithImpl<$Res, _$WireErrorImpl>
    implements _$$WireErrorImplCopyWith<$Res> {
  __$$WireErrorImplCopyWithImpl(
    _$WireErrorImpl _value,
    $Res Function(_$WireErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WireError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(
      _$WireErrorImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
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
@JsonSerializable()
class _$WireErrorImpl implements _WireError {
  const _$WireErrorImpl({
    required this.code,
    required this.message,
    @JsonKey(name: 'details') final Map<String, Object?>? details,
  }) : _details = details;

  factory _$WireErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$WireErrorImplFromJson(json);

  @override
  final String code;
  @override
  final String message;
  final Map<String, Object?>? _details;
  @override
  @JsonKey(name: 'details')
  Map<String, Object?>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'WireError(code: $code, message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WireErrorImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    message,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of WireError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WireErrorImplCopyWith<_$WireErrorImpl> get copyWith =>
      __$$WireErrorImplCopyWithImpl<_$WireErrorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WireErrorImplToJson(this);
  }
}

abstract class _WireError implements WireError {
  const factory _WireError({
    required final String code,
    required final String message,
    @JsonKey(name: 'details') final Map<String, Object?>? details,
  }) = _$WireErrorImpl;

  factory _WireError.fromJson(Map<String, dynamic> json) =
      _$WireErrorImpl.fromJson;

  @override
  String get code;
  @override
  String get message;
  @override
  @JsonKey(name: 'details')
  Map<String, Object?>? get details;

  /// Create a copy of WireError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WireErrorImplCopyWith<_$WireErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
