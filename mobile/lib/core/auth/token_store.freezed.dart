// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TokenBundle {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;

  /// Server `exp` claim as a local DateTime in UTC.
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Server-issued user ID. Safe to log (UUID, not PHI).
  String get userId => throw _privateConstructorUsedError;

  /// Server-issued ASC tenant ID. Safe to log.
  String get ascId => throw _privateConstructorUsedError;

  /// Role / scope claim string. Safe to log.
  String get role => throw _privateConstructorUsedError;

  /// Create a copy of TokenBundle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenBundleCopyWith<TokenBundle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenBundleCopyWith<$Res> {
  factory $TokenBundleCopyWith(
    TokenBundle value,
    $Res Function(TokenBundle) then,
  ) = _$TokenBundleCopyWithImpl<$Res, TokenBundle>;
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    DateTime expiresAt,
    String userId,
    String ascId,
    String role,
  });
}

/// @nodoc
class _$TokenBundleCopyWithImpl<$Res, $Val extends TokenBundle>
    implements $TokenBundleCopyWith<$Res> {
  _$TokenBundleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenBundle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
    Object? userId = null,
    Object? ascId = null,
    Object? role = null,
  }) {
    return _then(
      _value.copyWith(
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            ascId: null == ascId
                ? _value.ascId
                : ascId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TokenBundleImplCopyWith<$Res>
    implements $TokenBundleCopyWith<$Res> {
  factory _$$TokenBundleImplCopyWith(
    _$TokenBundleImpl value,
    $Res Function(_$TokenBundleImpl) then,
  ) = __$$TokenBundleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    DateTime expiresAt,
    String userId,
    String ascId,
    String role,
  });
}

/// @nodoc
class __$$TokenBundleImplCopyWithImpl<$Res>
    extends _$TokenBundleCopyWithImpl<$Res, _$TokenBundleImpl>
    implements _$$TokenBundleImplCopyWith<$Res> {
  __$$TokenBundleImplCopyWithImpl(
    _$TokenBundleImpl _value,
    $Res Function(_$TokenBundleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TokenBundle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
    Object? userId = null,
    Object? ascId = null,
    Object? role = null,
  }) {
    return _then(
      _$TokenBundleImpl(
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        ascId: null == ascId
            ? _value.ascId
            : ascId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TokenBundleImpl implements _TokenBundle {
  const _$TokenBundleImpl({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
    required this.ascId,
    required this.role,
  });

  @override
  final String accessToken;
  @override
  final String refreshToken;

  /// Server `exp` claim as a local DateTime in UTC.
  @override
  final DateTime expiresAt;

  /// Server-issued user ID. Safe to log (UUID, not PHI).
  @override
  final String userId;

  /// Server-issued ASC tenant ID. Safe to log.
  @override
  final String ascId;

  /// Role / scope claim string. Safe to log.
  @override
  final String role;

  @override
  String toString() {
    return 'TokenBundle(accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt, userId: $userId, ascId: $ascId, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenBundleImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.ascId, ascId) || other.ascId == ascId) &&
            (identical(other.role, role) || other.role == role));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    accessToken,
    refreshToken,
    expiresAt,
    userId,
    ascId,
    role,
  );

  /// Create a copy of TokenBundle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenBundleImplCopyWith<_$TokenBundleImpl> get copyWith =>
      __$$TokenBundleImplCopyWithImpl<_$TokenBundleImpl>(this, _$identity);
}

abstract class _TokenBundle implements TokenBundle {
  const factory _TokenBundle({
    required final String accessToken,
    required final String refreshToken,
    required final DateTime expiresAt,
    required final String userId,
    required final String ascId,
    required final String role,
  }) = _$TokenBundleImpl;

  @override
  String get accessToken;
  @override
  String get refreshToken;

  /// Server `exp` claim as a local DateTime in UTC.
  @override
  DateTime get expiresAt;

  /// Server-issued user ID. Safe to log (UUID, not PHI).
  @override
  String get userId;

  /// Server-issued ASC tenant ID. Safe to log.
  @override
  String get ascId;

  /// Role / scope claim string. Safe to log.
  @override
  String get role;

  /// Create a copy of TokenBundle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenBundleImplCopyWith<_$TokenBundleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
