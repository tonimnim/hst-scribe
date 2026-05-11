// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wss_envelope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WssEnvelope {
  WssMessageType get type => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  int get seq => throw _privateConstructorUsedError;
  DateTime get ts => throw _privateConstructorUsedError;
  WssPayload get payload => throw _privateConstructorUsedError;

  /// Create a copy of WssEnvelope
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WssEnvelopeCopyWith<WssEnvelope> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WssEnvelopeCopyWith<$Res> {
  factory $WssEnvelopeCopyWith(
    WssEnvelope value,
    $Res Function(WssEnvelope) then,
  ) = _$WssEnvelopeCopyWithImpl<$Res, WssEnvelope>;
  @useResult
  $Res call({
    WssMessageType type,
    String sessionId,
    int seq,
    DateTime ts,
    WssPayload payload,
  });

  $WssPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class _$WssEnvelopeCopyWithImpl<$Res, $Val extends WssEnvelope>
    implements $WssEnvelopeCopyWith<$Res> {
  _$WssEnvelopeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WssEnvelope
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sessionId = null,
    Object? seq = null,
    Object? ts = null,
    Object? payload = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as WssMessageType,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            seq: null == seq
                ? _value.seq
                : seq // ignore: cast_nullable_to_non_nullable
                      as int,
            ts: null == ts
                ? _value.ts
                : ts // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            payload: null == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as WssPayload,
          )
          as $Val,
    );
  }

  /// Create a copy of WssEnvelope
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WssPayloadCopyWith<$Res> get payload {
    return $WssPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WssEnvelopeImplCopyWith<$Res>
    implements $WssEnvelopeCopyWith<$Res> {
  factory _$$WssEnvelopeImplCopyWith(
    _$WssEnvelopeImpl value,
    $Res Function(_$WssEnvelopeImpl) then,
  ) = __$$WssEnvelopeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    WssMessageType type,
    String sessionId,
    int seq,
    DateTime ts,
    WssPayload payload,
  });

  @override
  $WssPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class __$$WssEnvelopeImplCopyWithImpl<$Res>
    extends _$WssEnvelopeCopyWithImpl<$Res, _$WssEnvelopeImpl>
    implements _$$WssEnvelopeImplCopyWith<$Res> {
  __$$WssEnvelopeImplCopyWithImpl(
    _$WssEnvelopeImpl _value,
    $Res Function(_$WssEnvelopeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssEnvelope
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? sessionId = null,
    Object? seq = null,
    Object? ts = null,
    Object? payload = null,
  }) {
    return _then(
      _$WssEnvelopeImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as WssMessageType,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        seq: null == seq
            ? _value.seq
            : seq // ignore: cast_nullable_to_non_nullable
                  as int,
        ts: null == ts
            ? _value.ts
            : ts // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        payload: null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as WssPayload,
      ),
    );
  }
}

/// @nodoc

class _$WssEnvelopeImpl extends _WssEnvelope {
  const _$WssEnvelopeImpl({
    required this.type,
    required this.sessionId,
    required this.seq,
    required this.ts,
    required this.payload,
  }) : super._();

  @override
  final WssMessageType type;
  @override
  final String sessionId;
  @override
  final int seq;
  @override
  final DateTime ts;
  @override
  final WssPayload payload;

  @override
  String toString() {
    return 'WssEnvelope(type: $type, sessionId: $sessionId, seq: $seq, ts: $ts, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WssEnvelopeImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.seq, seq) || other.seq == seq) &&
            (identical(other.ts, ts) || other.ts == ts) &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, type, sessionId, seq, ts, payload);

  /// Create a copy of WssEnvelope
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WssEnvelopeImplCopyWith<_$WssEnvelopeImpl> get copyWith =>
      __$$WssEnvelopeImplCopyWithImpl<_$WssEnvelopeImpl>(this, _$identity);
}

abstract class _WssEnvelope extends WssEnvelope {
  const factory _WssEnvelope({
    required final WssMessageType type,
    required final String sessionId,
    required final int seq,
    required final DateTime ts,
    required final WssPayload payload,
  }) = _$WssEnvelopeImpl;
  const _WssEnvelope._() : super._();

  @override
  WssMessageType get type;
  @override
  String get sessionId;
  @override
  int get seq;
  @override
  DateTime get ts;
  @override
  WssPayload get payload;

  /// Create a copy of WssEnvelope
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WssEnvelopeImplCopyWith<_$WssEnvelopeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
