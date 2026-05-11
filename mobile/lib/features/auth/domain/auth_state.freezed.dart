// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthClaims {
  String get userId => throw _privateConstructorUsedError;
  String get ascId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Create a copy of AuthClaims
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthClaimsCopyWith<AuthClaims> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthClaimsCopyWith<$Res> {
  factory $AuthClaimsCopyWith(
    AuthClaims value,
    $Res Function(AuthClaims) then,
  ) = _$AuthClaimsCopyWithImpl<$Res, AuthClaims>;
  @useResult
  $Res call({String userId, String ascId, String role, DateTime expiresAt});
}

/// @nodoc
class _$AuthClaimsCopyWithImpl<$Res, $Val extends AuthClaims>
    implements $AuthClaimsCopyWith<$Res> {
  _$AuthClaimsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthClaims
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? ascId = null,
    Object? role = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
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
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthClaimsImplCopyWith<$Res>
    implements $AuthClaimsCopyWith<$Res> {
  factory _$$AuthClaimsImplCopyWith(
    _$AuthClaimsImpl value,
    $Res Function(_$AuthClaimsImpl) then,
  ) = __$$AuthClaimsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String ascId, String role, DateTime expiresAt});
}

/// @nodoc
class __$$AuthClaimsImplCopyWithImpl<$Res>
    extends _$AuthClaimsCopyWithImpl<$Res, _$AuthClaimsImpl>
    implements _$$AuthClaimsImplCopyWith<$Res> {
  __$$AuthClaimsImplCopyWithImpl(
    _$AuthClaimsImpl _value,
    $Res Function(_$AuthClaimsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthClaims
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? ascId = null,
    Object? role = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$AuthClaimsImpl(
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
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$AuthClaimsImpl extends _AuthClaims {
  const _$AuthClaimsImpl({
    required this.userId,
    required this.ascId,
    required this.role,
    required this.expiresAt,
  }) : super._();

  @override
  final String userId;
  @override
  final String ascId;
  @override
  final String role;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'AuthClaims(userId: $userId, ascId: $ascId, role: $role, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthClaimsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.ascId, ascId) || other.ascId == ascId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, ascId, role, expiresAt);

  /// Create a copy of AuthClaims
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthClaimsImplCopyWith<_$AuthClaimsImpl> get copyWith =>
      __$$AuthClaimsImplCopyWithImpl<_$AuthClaimsImpl>(this, _$identity);
}

abstract class _AuthClaims extends AuthClaims {
  const factory _AuthClaims({
    required final String userId,
    required final String ascId,
    required final String role,
    required final DateTime expiresAt,
  }) = _$AuthClaimsImpl;
  const _AuthClaims._() : super._();

  @override
  String get userId;
  @override
  String get ascId;
  @override
  String get role;
  @override
  DateTime get expiresAt;

  /// Create a copy of AuthClaims
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthClaimsImplCopyWith<_$AuthClaimsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AppFailure? failure) unauthenticated,
    required TResult Function(AuthClaims claims) authenticated,
    required TResult Function(AuthClaims previousClaims) refreshing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AppFailure? failure)? unauthenticated,
    TResult? Function(AuthClaims claims)? authenticated,
    TResult? Function(AuthClaims previousClaims)? refreshing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AppFailure? failure)? unauthenticated,
    TResult Function(AuthClaims claims)? authenticated,
    TResult Function(AuthClaims previousClaims)? refreshing,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UnauthenticatedAuthState value) unauthenticated,
    required TResult Function(AuthenticatedAuthState value) authenticated,
    required TResult Function(RefreshingAuthState value) refreshing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UnauthenticatedAuthState value)? unauthenticated,
    TResult? Function(AuthenticatedAuthState value)? authenticated,
    TResult? Function(RefreshingAuthState value)? refreshing,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UnauthenticatedAuthState value)? unauthenticated,
    TResult Function(AuthenticatedAuthState value)? authenticated,
    TResult Function(RefreshingAuthState value)? refreshing,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$UnauthenticatedAuthStateImplCopyWith<$Res> {
  factory _$$UnauthenticatedAuthStateImplCopyWith(
    _$UnauthenticatedAuthStateImpl value,
    $Res Function(_$UnauthenticatedAuthStateImpl) then,
  ) = __$$UnauthenticatedAuthStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AppFailure? failure});

  $AppFailureCopyWith<$Res>? get failure;
}

/// @nodoc
class __$$UnauthenticatedAuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$UnauthenticatedAuthStateImpl>
    implements _$$UnauthenticatedAuthStateImplCopyWith<$Res> {
  __$$UnauthenticatedAuthStateImplCopyWithImpl(
    _$UnauthenticatedAuthStateImpl _value,
    $Res Function(_$UnauthenticatedAuthStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? failure = freezed}) {
    return _then(
      _$UnauthenticatedAuthStateImpl(
        failure: freezed == failure
            ? _value.failure
            : failure // ignore: cast_nullable_to_non_nullable
                  as AppFailure?,
      ),
    );
  }

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppFailureCopyWith<$Res>? get failure {
    if (_value.failure == null) {
      return null;
    }

    return $AppFailureCopyWith<$Res>(_value.failure!, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }
}

/// @nodoc

class _$UnauthenticatedAuthStateImpl implements UnauthenticatedAuthState {
  const _$UnauthenticatedAuthStateImpl({this.failure});

  @override
  final AppFailure? failure;

  @override
  String toString() {
    return 'AuthState.unauthenticated(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthenticatedAuthStateImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthenticatedAuthStateImplCopyWith<_$UnauthenticatedAuthStateImpl>
  get copyWith =>
      __$$UnauthenticatedAuthStateImplCopyWithImpl<
        _$UnauthenticatedAuthStateImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AppFailure? failure) unauthenticated,
    required TResult Function(AuthClaims claims) authenticated,
    required TResult Function(AuthClaims previousClaims) refreshing,
  }) {
    return unauthenticated(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AppFailure? failure)? unauthenticated,
    TResult? Function(AuthClaims claims)? authenticated,
    TResult? Function(AuthClaims previousClaims)? refreshing,
  }) {
    return unauthenticated?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AppFailure? failure)? unauthenticated,
    TResult Function(AuthClaims claims)? authenticated,
    TResult Function(AuthClaims previousClaims)? refreshing,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UnauthenticatedAuthState value) unauthenticated,
    required TResult Function(AuthenticatedAuthState value) authenticated,
    required TResult Function(RefreshingAuthState value) refreshing,
  }) {
    return unauthenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UnauthenticatedAuthState value)? unauthenticated,
    TResult? Function(AuthenticatedAuthState value)? authenticated,
    TResult? Function(RefreshingAuthState value)? refreshing,
  }) {
    return unauthenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UnauthenticatedAuthState value)? unauthenticated,
    TResult Function(AuthenticatedAuthState value)? authenticated,
    TResult Function(RefreshingAuthState value)? refreshing,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(this);
    }
    return orElse();
  }
}

abstract class UnauthenticatedAuthState implements AuthState {
  const factory UnauthenticatedAuthState({final AppFailure? failure}) =
      _$UnauthenticatedAuthStateImpl;

  AppFailure? get failure;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnauthenticatedAuthStateImplCopyWith<_$UnauthenticatedAuthStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthenticatedAuthStateImplCopyWith<$Res> {
  factory _$$AuthenticatedAuthStateImplCopyWith(
    _$AuthenticatedAuthStateImpl value,
    $Res Function(_$AuthenticatedAuthStateImpl) then,
  ) = __$$AuthenticatedAuthStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AuthClaims claims});

  $AuthClaimsCopyWith<$Res> get claims;
}

/// @nodoc
class __$$AuthenticatedAuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthenticatedAuthStateImpl>
    implements _$$AuthenticatedAuthStateImplCopyWith<$Res> {
  __$$AuthenticatedAuthStateImplCopyWithImpl(
    _$AuthenticatedAuthStateImpl _value,
    $Res Function(_$AuthenticatedAuthStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? claims = null}) {
    return _then(
      _$AuthenticatedAuthStateImpl(
        claims: null == claims
            ? _value.claims
            : claims // ignore: cast_nullable_to_non_nullable
                  as AuthClaims,
      ),
    );
  }

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthClaimsCopyWith<$Res> get claims {
    return $AuthClaimsCopyWith<$Res>(_value.claims, (value) {
      return _then(_value.copyWith(claims: value));
    });
  }
}

/// @nodoc

class _$AuthenticatedAuthStateImpl implements AuthenticatedAuthState {
  const _$AuthenticatedAuthStateImpl({required this.claims});

  @override
  final AuthClaims claims;

  @override
  String toString() {
    return 'AuthState.authenticated(claims: $claims)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticatedAuthStateImpl &&
            (identical(other.claims, claims) || other.claims == claims));
  }

  @override
  int get hashCode => Object.hash(runtimeType, claims);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticatedAuthStateImplCopyWith<_$AuthenticatedAuthStateImpl>
  get copyWith =>
      __$$AuthenticatedAuthStateImplCopyWithImpl<_$AuthenticatedAuthStateImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AppFailure? failure) unauthenticated,
    required TResult Function(AuthClaims claims) authenticated,
    required TResult Function(AuthClaims previousClaims) refreshing,
  }) {
    return authenticated(claims);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AppFailure? failure)? unauthenticated,
    TResult? Function(AuthClaims claims)? authenticated,
    TResult? Function(AuthClaims previousClaims)? refreshing,
  }) {
    return authenticated?.call(claims);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AppFailure? failure)? unauthenticated,
    TResult Function(AuthClaims claims)? authenticated,
    TResult Function(AuthClaims previousClaims)? refreshing,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(claims);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UnauthenticatedAuthState value) unauthenticated,
    required TResult Function(AuthenticatedAuthState value) authenticated,
    required TResult Function(RefreshingAuthState value) refreshing,
  }) {
    return authenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UnauthenticatedAuthState value)? unauthenticated,
    TResult? Function(AuthenticatedAuthState value)? authenticated,
    TResult? Function(RefreshingAuthState value)? refreshing,
  }) {
    return authenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UnauthenticatedAuthState value)? unauthenticated,
    TResult Function(AuthenticatedAuthState value)? authenticated,
    TResult Function(RefreshingAuthState value)? refreshing,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(this);
    }
    return orElse();
  }
}

abstract class AuthenticatedAuthState implements AuthState {
  const factory AuthenticatedAuthState({required final AuthClaims claims}) =
      _$AuthenticatedAuthStateImpl;

  AuthClaims get claims;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthenticatedAuthStateImplCopyWith<_$AuthenticatedAuthStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RefreshingAuthStateImplCopyWith<$Res> {
  factory _$$RefreshingAuthStateImplCopyWith(
    _$RefreshingAuthStateImpl value,
    $Res Function(_$RefreshingAuthStateImpl) then,
  ) = __$$RefreshingAuthStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AuthClaims previousClaims});

  $AuthClaimsCopyWith<$Res> get previousClaims;
}

/// @nodoc
class __$$RefreshingAuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$RefreshingAuthStateImpl>
    implements _$$RefreshingAuthStateImplCopyWith<$Res> {
  __$$RefreshingAuthStateImplCopyWithImpl(
    _$RefreshingAuthStateImpl _value,
    $Res Function(_$RefreshingAuthStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? previousClaims = null}) {
    return _then(
      _$RefreshingAuthStateImpl(
        previousClaims: null == previousClaims
            ? _value.previousClaims
            : previousClaims // ignore: cast_nullable_to_non_nullable
                  as AuthClaims,
      ),
    );
  }

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthClaimsCopyWith<$Res> get previousClaims {
    return $AuthClaimsCopyWith<$Res>(_value.previousClaims, (value) {
      return _then(_value.copyWith(previousClaims: value));
    });
  }
}

/// @nodoc

class _$RefreshingAuthStateImpl implements RefreshingAuthState {
  const _$RefreshingAuthStateImpl({required this.previousClaims});

  @override
  final AuthClaims previousClaims;

  @override
  String toString() {
    return 'AuthState.refreshing(previousClaims: $previousClaims)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshingAuthStateImpl &&
            (identical(other.previousClaims, previousClaims) ||
                other.previousClaims == previousClaims));
  }

  @override
  int get hashCode => Object.hash(runtimeType, previousClaims);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefreshingAuthStateImplCopyWith<_$RefreshingAuthStateImpl> get copyWith =>
      __$$RefreshingAuthStateImplCopyWithImpl<_$RefreshingAuthStateImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AppFailure? failure) unauthenticated,
    required TResult Function(AuthClaims claims) authenticated,
    required TResult Function(AuthClaims previousClaims) refreshing,
  }) {
    return refreshing(previousClaims);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AppFailure? failure)? unauthenticated,
    TResult? Function(AuthClaims claims)? authenticated,
    TResult? Function(AuthClaims previousClaims)? refreshing,
  }) {
    return refreshing?.call(previousClaims);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AppFailure? failure)? unauthenticated,
    TResult Function(AuthClaims claims)? authenticated,
    TResult Function(AuthClaims previousClaims)? refreshing,
    required TResult orElse(),
  }) {
    if (refreshing != null) {
      return refreshing(previousClaims);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UnauthenticatedAuthState value) unauthenticated,
    required TResult Function(AuthenticatedAuthState value) authenticated,
    required TResult Function(RefreshingAuthState value) refreshing,
  }) {
    return refreshing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UnauthenticatedAuthState value)? unauthenticated,
    TResult? Function(AuthenticatedAuthState value)? authenticated,
    TResult? Function(RefreshingAuthState value)? refreshing,
  }) {
    return refreshing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UnauthenticatedAuthState value)? unauthenticated,
    TResult Function(AuthenticatedAuthState value)? authenticated,
    TResult Function(RefreshingAuthState value)? refreshing,
    required TResult orElse(),
  }) {
    if (refreshing != null) {
      return refreshing(this);
    }
    return orElse();
  }
}

abstract class RefreshingAuthState implements AuthState {
  const factory RefreshingAuthState({
    required final AuthClaims previousClaims,
  }) = _$RefreshingAuthStateImpl;

  AuthClaims get previousClaims;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefreshingAuthStateImplCopyWith<_$RefreshingAuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
