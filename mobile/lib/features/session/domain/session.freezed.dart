// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Session {
  String get id => throw _privateConstructorUsedError;
  String get wssUrl => throw _privateConstructorUsedError;
  PatientContextModel get patientContext => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  SessionStatus get status => throw _privateConstructorUsedError;
  WorkflowType get workflowType => throw _privateConstructorUsedError;

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionCopyWith<Session> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionCopyWith<$Res> {
  factory $SessionCopyWith(Session value, $Res Function(Session) then) =
      _$SessionCopyWithImpl<$Res, Session>;
  @useResult
  $Res call({
    String id,
    String wssUrl,
    PatientContextModel patientContext,
    DateTime startedAt,
    DateTime expiresAt,
    SessionStatus status,
    WorkflowType workflowType,
  });

  $PatientContextModelCopyWith<$Res> get patientContext;
}

/// @nodoc
class _$SessionCopyWithImpl<$Res, $Val extends Session>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wssUrl = null,
    Object? patientContext = null,
    Object? startedAt = null,
    Object? expiresAt = null,
    Object? status = null,
    Object? workflowType = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            wssUrl: null == wssUrl
                ? _value.wssUrl
                : wssUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            patientContext: null == patientContext
                ? _value.patientContext
                : patientContext // ignore: cast_nullable_to_non_nullable
                      as PatientContextModel,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SessionStatus,
            workflowType: null == workflowType
                ? _value.workflowType
                : workflowType // ignore: cast_nullable_to_non_nullable
                      as WorkflowType,
          )
          as $Val,
    );
  }

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PatientContextModelCopyWith<$Res> get patientContext {
    return $PatientContextModelCopyWith<$Res>(_value.patientContext, (value) {
      return _then(_value.copyWith(patientContext: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SessionImplCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$$SessionImplCopyWith(
    _$SessionImpl value,
    $Res Function(_$SessionImpl) then,
  ) = __$$SessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String wssUrl,
    PatientContextModel patientContext,
    DateTime startedAt,
    DateTime expiresAt,
    SessionStatus status,
    WorkflowType workflowType,
  });

  @override
  $PatientContextModelCopyWith<$Res> get patientContext;
}

/// @nodoc
class __$$SessionImplCopyWithImpl<$Res>
    extends _$SessionCopyWithImpl<$Res, _$SessionImpl>
    implements _$$SessionImplCopyWith<$Res> {
  __$$SessionImplCopyWithImpl(
    _$SessionImpl _value,
    $Res Function(_$SessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wssUrl = null,
    Object? patientContext = null,
    Object? startedAt = null,
    Object? expiresAt = null,
    Object? status = null,
    Object? workflowType = null,
  }) {
    return _then(
      _$SessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        wssUrl: null == wssUrl
            ? _value.wssUrl
            : wssUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        patientContext: null == patientContext
            ? _value.patientContext
            : patientContext // ignore: cast_nullable_to_non_nullable
                  as PatientContextModel,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SessionStatus,
        workflowType: null == workflowType
            ? _value.workflowType
            : workflowType // ignore: cast_nullable_to_non_nullable
                  as WorkflowType,
      ),
    );
  }
}

/// @nodoc

class _$SessionImpl extends _Session {
  const _$SessionImpl({
    required this.id,
    required this.wssUrl,
    required this.patientContext,
    required this.startedAt,
    required this.expiresAt,
    required this.status,
    this.workflowType = WorkflowType.pacu,
  }) : super._();

  @override
  final String id;
  @override
  final String wssUrl;
  @override
  final PatientContextModel patientContext;
  @override
  final DateTime startedAt;
  @override
  final DateTime expiresAt;
  @override
  final SessionStatus status;
  @override
  @JsonKey()
  final WorkflowType workflowType;

  @override
  String toString() {
    return 'Session(id: $id, wssUrl: $wssUrl, patientContext: $patientContext, startedAt: $startedAt, expiresAt: $expiresAt, status: $status, workflowType: $workflowType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.wssUrl, wssUrl) || other.wssUrl == wssUrl) &&
            (identical(other.patientContext, patientContext) ||
                other.patientContext == patientContext) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.workflowType, workflowType) ||
                other.workflowType == workflowType));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    wssUrl,
    patientContext,
    startedAt,
    expiresAt,
    status,
    workflowType,
  );

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionImplCopyWith<_$SessionImpl> get copyWith =>
      __$$SessionImplCopyWithImpl<_$SessionImpl>(this, _$identity);
}

abstract class _Session extends Session {
  const factory _Session({
    required final String id,
    required final String wssUrl,
    required final PatientContextModel patientContext,
    required final DateTime startedAt,
    required final DateTime expiresAt,
    required final SessionStatus status,
    final WorkflowType workflowType,
  }) = _$SessionImpl;
  const _Session._() : super._();

  @override
  String get id;
  @override
  String get wssUrl;
  @override
  PatientContextModel get patientContext;
  @override
  DateTime get startedAt;
  @override
  DateTime get expiresAt;
  @override
  SessionStatus get status;
  @override
  WorkflowType get workflowType;

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionImplCopyWith<_$SessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
