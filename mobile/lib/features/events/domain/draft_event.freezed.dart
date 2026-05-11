// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DraftEvent {
  ExtractedEvent get event => throw _privateConstructorUsedError;
  DraftEventStatus get status => throw _privateConstructorUsedError;
  DateTime get arrivedAt => throw _privateConstructorUsedError;

  /// Most recent failure for this card. UI shows a retry affordance
  /// when set. Cleared on the next successful mutation.
  String? get lastError => throw _privateConstructorUsedError;

  /// Create a copy of DraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DraftEventCopyWith<DraftEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DraftEventCopyWith<$Res> {
  factory $DraftEventCopyWith(
    DraftEvent value,
    $Res Function(DraftEvent) then,
  ) = _$DraftEventCopyWithImpl<$Res, DraftEvent>;
  @useResult
  $Res call({
    ExtractedEvent event,
    DraftEventStatus status,
    DateTime arrivedAt,
    String? lastError,
  });

  $ExtractedEventCopyWith<$Res> get event;
}

/// @nodoc
class _$DraftEventCopyWithImpl<$Res, $Val extends DraftEvent>
    implements $DraftEventCopyWith<$Res> {
  _$DraftEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
    Object? status = null,
    Object? arrivedAt = null,
    Object? lastError = freezed,
  }) {
    return _then(
      _value.copyWith(
            event:
                null == event
                    ? _value.event
                    : event // ignore: cast_nullable_to_non_nullable
                        as ExtractedEvent,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as DraftEventStatus,
            arrivedAt:
                null == arrivedAt
                    ? _value.arrivedAt
                    : arrivedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            lastError:
                freezed == lastError
                    ? _value.lastError
                    : lastError // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of DraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExtractedEventCopyWith<$Res> get event {
    return $ExtractedEventCopyWith<$Res>(_value.event, (value) {
      return _then(_value.copyWith(event: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DraftEventImplCopyWith<$Res>
    implements $DraftEventCopyWith<$Res> {
  factory _$$DraftEventImplCopyWith(
    _$DraftEventImpl value,
    $Res Function(_$DraftEventImpl) then,
  ) = __$$DraftEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ExtractedEvent event,
    DraftEventStatus status,
    DateTime arrivedAt,
    String? lastError,
  });

  @override
  $ExtractedEventCopyWith<$Res> get event;
}

/// @nodoc
class __$$DraftEventImplCopyWithImpl<$Res>
    extends _$DraftEventCopyWithImpl<$Res, _$DraftEventImpl>
    implements _$$DraftEventImplCopyWith<$Res> {
  __$$DraftEventImplCopyWithImpl(
    _$DraftEventImpl _value,
    $Res Function(_$DraftEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
    Object? status = null,
    Object? arrivedAt = null,
    Object? lastError = freezed,
  }) {
    return _then(
      _$DraftEventImpl(
        event:
            null == event
                ? _value.event
                : event // ignore: cast_nullable_to_non_nullable
                    as ExtractedEvent,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as DraftEventStatus,
        arrivedAt:
            null == arrivedAt
                ? _value.arrivedAt
                : arrivedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        lastError:
            freezed == lastError
                ? _value.lastError
                : lastError // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$DraftEventImpl extends _DraftEvent {
  const _$DraftEventImpl({
    required this.event,
    required this.status,
    required this.arrivedAt,
    this.lastError,
  }) : super._();

  @override
  final ExtractedEvent event;
  @override
  final DraftEventStatus status;
  @override
  final DateTime arrivedAt;

  /// Most recent failure for this card. UI shows a retry affordance
  /// when set. Cleared on the next successful mutation.
  @override
  final String? lastError;

  @override
  String toString() {
    return 'DraftEvent(event: $event, status: $status, arrivedAt: $arrivedAt, lastError: $lastError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DraftEventImpl &&
            (identical(other.event, event) || other.event == event) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.arrivedAt, arrivedAt) ||
                other.arrivedAt == arrivedAt) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, event, status, arrivedAt, lastError);

  /// Create a copy of DraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DraftEventImplCopyWith<_$DraftEventImpl> get copyWith =>
      __$$DraftEventImplCopyWithImpl<_$DraftEventImpl>(this, _$identity);
}

abstract class _DraftEvent extends DraftEvent {
  const factory _DraftEvent({
    required final ExtractedEvent event,
    required final DraftEventStatus status,
    required final DateTime arrivedAt,
    final String? lastError,
  }) = _$DraftEventImpl;
  const _DraftEvent._() : super._();

  @override
  ExtractedEvent get event;
  @override
  DraftEventStatus get status;
  @override
  DateTime get arrivedAt;

  /// Most recent failure for this card. UI shows a retry affordance
  /// when set. Cleared on the next successful mutation.
  @override
  String? get lastError;

  /// Create a copy of DraftEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DraftEventImplCopyWith<_$DraftEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
