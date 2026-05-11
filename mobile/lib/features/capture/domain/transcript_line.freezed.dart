// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transcript_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TranscriptLine {
  String get text => throw _privateConstructorUsedError;
  SpeakerRole get speaker => throw _privateConstructorUsedError;

  /// Server `transcript_id`. Null for partials (partials have no id on
  /// the wire). Used to dedupe and to swap a final in place of its
  /// preceding partial.
  String? get transcriptId => throw _privateConstructorUsedError;
  bool get isFinal => throw _privateConstructorUsedError;
  DateTime get receivedAt => throw _privateConstructorUsedError;

  /// Create a copy of TranscriptLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranscriptLineCopyWith<TranscriptLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranscriptLineCopyWith<$Res> {
  factory $TranscriptLineCopyWith(
    TranscriptLine value,
    $Res Function(TranscriptLine) then,
  ) = _$TranscriptLineCopyWithImpl<$Res, TranscriptLine>;
  @useResult
  $Res call({
    String text,
    SpeakerRole speaker,
    String? transcriptId,
    bool isFinal,
    DateTime receivedAt,
  });
}

/// @nodoc
class _$TranscriptLineCopyWithImpl<$Res, $Val extends TranscriptLine>
    implements $TranscriptLineCopyWith<$Res> {
  _$TranscriptLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranscriptLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? speaker = null,
    Object? transcriptId = freezed,
    Object? isFinal = null,
    Object? receivedAt = null,
  }) {
    return _then(
      _value.copyWith(
            text:
                null == text
                    ? _value.text
                    : text // ignore: cast_nullable_to_non_nullable
                        as String,
            speaker:
                null == speaker
                    ? _value.speaker
                    : speaker // ignore: cast_nullable_to_non_nullable
                        as SpeakerRole,
            transcriptId:
                freezed == transcriptId
                    ? _value.transcriptId
                    : transcriptId // ignore: cast_nullable_to_non_nullable
                        as String?,
            isFinal:
                null == isFinal
                    ? _value.isFinal
                    : isFinal // ignore: cast_nullable_to_non_nullable
                        as bool,
            receivedAt:
                null == receivedAt
                    ? _value.receivedAt
                    : receivedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TranscriptLineImplCopyWith<$Res>
    implements $TranscriptLineCopyWith<$Res> {
  factory _$$TranscriptLineImplCopyWith(
    _$TranscriptLineImpl value,
    $Res Function(_$TranscriptLineImpl) then,
  ) = __$$TranscriptLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String text,
    SpeakerRole speaker,
    String? transcriptId,
    bool isFinal,
    DateTime receivedAt,
  });
}

/// @nodoc
class __$$TranscriptLineImplCopyWithImpl<$Res>
    extends _$TranscriptLineCopyWithImpl<$Res, _$TranscriptLineImpl>
    implements _$$TranscriptLineImplCopyWith<$Res> {
  __$$TranscriptLineImplCopyWithImpl(
    _$TranscriptLineImpl _value,
    $Res Function(_$TranscriptLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TranscriptLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? speaker = null,
    Object? transcriptId = freezed,
    Object? isFinal = null,
    Object? receivedAt = null,
  }) {
    return _then(
      _$TranscriptLineImpl(
        text:
            null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                    as String,
        speaker:
            null == speaker
                ? _value.speaker
                : speaker // ignore: cast_nullable_to_non_nullable
                    as SpeakerRole,
        transcriptId:
            freezed == transcriptId
                ? _value.transcriptId
                : transcriptId // ignore: cast_nullable_to_non_nullable
                    as String?,
        isFinal:
            null == isFinal
                ? _value.isFinal
                : isFinal // ignore: cast_nullable_to_non_nullable
                    as bool,
        receivedAt:
            null == receivedAt
                ? _value.receivedAt
                : receivedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$TranscriptLineImpl implements _TranscriptLine {
  const _$TranscriptLineImpl({
    required this.text,
    required this.speaker,
    this.transcriptId,
    required this.isFinal,
    required this.receivedAt,
  });

  @override
  final String text;
  @override
  final SpeakerRole speaker;

  /// Server `transcript_id`. Null for partials (partials have no id on
  /// the wire). Used to dedupe and to swap a final in place of its
  /// preceding partial.
  @override
  final String? transcriptId;
  @override
  final bool isFinal;
  @override
  final DateTime receivedAt;

  @override
  String toString() {
    return 'TranscriptLine(text: $text, speaker: $speaker, transcriptId: $transcriptId, isFinal: $isFinal, receivedAt: $receivedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptLineImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.transcriptId, transcriptId) ||
                other.transcriptId == transcriptId) &&
            (identical(other.isFinal, isFinal) || other.isFinal == isFinal) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    text,
    speaker,
    transcriptId,
    isFinal,
    receivedAt,
  );

  /// Create a copy of TranscriptLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptLineImplCopyWith<_$TranscriptLineImpl> get copyWith =>
      __$$TranscriptLineImplCopyWithImpl<_$TranscriptLineImpl>(
        this,
        _$identity,
      );
}

abstract class _TranscriptLine implements TranscriptLine {
  const factory _TranscriptLine({
    required final String text,
    required final SpeakerRole speaker,
    final String? transcriptId,
    required final bool isFinal,
    required final DateTime receivedAt,
  }) = _$TranscriptLineImpl;

  @override
  String get text;
  @override
  SpeakerRole get speaker;

  /// Server `transcript_id`. Null for partials (partials have no id on
  /// the wire). Used to dedupe and to swap a final in place of its
  /// preceding partial.
  @override
  String? get transcriptId;
  @override
  bool get isFinal;
  @override
  DateTime get receivedAt;

  /// Create a copy of TranscriptLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranscriptLineImplCopyWith<_$TranscriptLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
