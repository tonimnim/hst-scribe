// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wss_messages.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AudioChunkPayload _$AudioChunkPayloadFromJson(Map<String, dynamic> json) {
  return _AudioChunkPayload.fromJson(json);
}

/// @nodoc
mixin _$AudioChunkPayload {
  @JsonKey(name: 'chunk_id')
  String get chunkId => throw _privateConstructorUsedError;

  /// Base-64 of one 250ms frame of 16kHz mono PCM16.
  @JsonKey(name: 'audio_b64')
  String get audioB64 => throw _privateConstructorUsedError;
  @JsonKey(name: 'sample_rate')
  int get sampleRate => throw _privateConstructorUsedError;
  String get format => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_ms')
  int get durationMs => throw _privateConstructorUsedError;

  /// Serializes this AudioChunkPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AudioChunkPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioChunkPayloadCopyWith<AudioChunkPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioChunkPayloadCopyWith<$Res> {
  factory $AudioChunkPayloadCopyWith(
    AudioChunkPayload value,
    $Res Function(AudioChunkPayload) then,
  ) = _$AudioChunkPayloadCopyWithImpl<$Res, AudioChunkPayload>;
  @useResult
  $Res call({
    @JsonKey(name: 'chunk_id') String chunkId,
    @JsonKey(name: 'audio_b64') String audioB64,
    @JsonKey(name: 'sample_rate') int sampleRate,
    String format,
    @JsonKey(name: 'duration_ms') int durationMs,
  });
}

/// @nodoc
class _$AudioChunkPayloadCopyWithImpl<$Res, $Val extends AudioChunkPayload>
    implements $AudioChunkPayloadCopyWith<$Res> {
  _$AudioChunkPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioChunkPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkId = null,
    Object? audioB64 = null,
    Object? sampleRate = null,
    Object? format = null,
    Object? durationMs = null,
  }) {
    return _then(
      _value.copyWith(
            chunkId: null == chunkId
                ? _value.chunkId
                : chunkId // ignore: cast_nullable_to_non_nullable
                      as String,
            audioB64: null == audioB64
                ? _value.audioB64
                : audioB64 // ignore: cast_nullable_to_non_nullable
                      as String,
            sampleRate: null == sampleRate
                ? _value.sampleRate
                : sampleRate // ignore: cast_nullable_to_non_nullable
                      as int,
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as String,
            durationMs: null == durationMs
                ? _value.durationMs
                : durationMs // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AudioChunkPayloadImplCopyWith<$Res>
    implements $AudioChunkPayloadCopyWith<$Res> {
  factory _$$AudioChunkPayloadImplCopyWith(
    _$AudioChunkPayloadImpl value,
    $Res Function(_$AudioChunkPayloadImpl) then,
  ) = __$$AudioChunkPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'chunk_id') String chunkId,
    @JsonKey(name: 'audio_b64') String audioB64,
    @JsonKey(name: 'sample_rate') int sampleRate,
    String format,
    @JsonKey(name: 'duration_ms') int durationMs,
  });
}

/// @nodoc
class __$$AudioChunkPayloadImplCopyWithImpl<$Res>
    extends _$AudioChunkPayloadCopyWithImpl<$Res, _$AudioChunkPayloadImpl>
    implements _$$AudioChunkPayloadImplCopyWith<$Res> {
  __$$AudioChunkPayloadImplCopyWithImpl(
    _$AudioChunkPayloadImpl _value,
    $Res Function(_$AudioChunkPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AudioChunkPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkId = null,
    Object? audioB64 = null,
    Object? sampleRate = null,
    Object? format = null,
    Object? durationMs = null,
  }) {
    return _then(
      _$AudioChunkPayloadImpl(
        chunkId: null == chunkId
            ? _value.chunkId
            : chunkId // ignore: cast_nullable_to_non_nullable
                  as String,
        audioB64: null == audioB64
            ? _value.audioB64
            : audioB64 // ignore: cast_nullable_to_non_nullable
                  as String,
        sampleRate: null == sampleRate
            ? _value.sampleRate
            : sampleRate // ignore: cast_nullable_to_non_nullable
                  as int,
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as String,
        durationMs: null == durationMs
            ? _value.durationMs
            : durationMs // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioChunkPayloadImpl implements _AudioChunkPayload {
  const _$AudioChunkPayloadImpl({
    @JsonKey(name: 'chunk_id') required this.chunkId,
    @JsonKey(name: 'audio_b64') required this.audioB64,
    @JsonKey(name: 'sample_rate') this.sampleRate = 16000,
    this.format = 'pcm16',
    @JsonKey(name: 'duration_ms') this.durationMs = 250,
  });

  factory _$AudioChunkPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioChunkPayloadImplFromJson(json);

  @override
  @JsonKey(name: 'chunk_id')
  final String chunkId;

  /// Base-64 of one 250ms frame of 16kHz mono PCM16.
  @override
  @JsonKey(name: 'audio_b64')
  final String audioB64;
  @override
  @JsonKey(name: 'sample_rate')
  final int sampleRate;
  @override
  @JsonKey()
  final String format;
  @override
  @JsonKey(name: 'duration_ms')
  final int durationMs;

  @override
  String toString() {
    return 'AudioChunkPayload(chunkId: $chunkId, audioB64: $audioB64, sampleRate: $sampleRate, format: $format, durationMs: $durationMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioChunkPayloadImpl &&
            (identical(other.chunkId, chunkId) || other.chunkId == chunkId) &&
            (identical(other.audioB64, audioB64) ||
                other.audioB64 == audioB64) &&
            (identical(other.sampleRate, sampleRate) ||
                other.sampleRate == sampleRate) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    chunkId,
    audioB64,
    sampleRate,
    format,
    durationMs,
  );

  /// Create a copy of AudioChunkPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioChunkPayloadImplCopyWith<_$AudioChunkPayloadImpl> get copyWith =>
      __$$AudioChunkPayloadImplCopyWithImpl<_$AudioChunkPayloadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioChunkPayloadImplToJson(this);
  }
}

abstract class _AudioChunkPayload implements AudioChunkPayload {
  const factory _AudioChunkPayload({
    @JsonKey(name: 'chunk_id') required final String chunkId,
    @JsonKey(name: 'audio_b64') required final String audioB64,
    @JsonKey(name: 'sample_rate') final int sampleRate,
    final String format,
    @JsonKey(name: 'duration_ms') final int durationMs,
  }) = _$AudioChunkPayloadImpl;

  factory _AudioChunkPayload.fromJson(Map<String, dynamic> json) =
      _$AudioChunkPayloadImpl.fromJson;

  @override
  @JsonKey(name: 'chunk_id')
  String get chunkId;

  /// Base-64 of one 250ms frame of 16kHz mono PCM16.
  @override
  @JsonKey(name: 'audio_b64')
  String get audioB64;
  @override
  @JsonKey(name: 'sample_rate')
  int get sampleRate;
  @override
  String get format;
  @override
  @JsonKey(name: 'duration_ms')
  int get durationMs;

  /// Create a copy of AudioChunkPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioChunkPayloadImplCopyWith<_$AudioChunkPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VoiceCommandPayload _$VoiceCommandPayloadFromJson(Map<String, dynamic> json) {
  return _VoiceCommandPayload.fromJson(json);
}

/// @nodoc
mixin _$VoiceCommandPayload {
  VoiceCommand get command => throw _privateConstructorUsedError;

  /// Serializes this VoiceCommandPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceCommandPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceCommandPayloadCopyWith<VoiceCommandPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceCommandPayloadCopyWith<$Res> {
  factory $VoiceCommandPayloadCopyWith(
    VoiceCommandPayload value,
    $Res Function(VoiceCommandPayload) then,
  ) = _$VoiceCommandPayloadCopyWithImpl<$Res, VoiceCommandPayload>;
  @useResult
  $Res call({VoiceCommand command});
}

/// @nodoc
class _$VoiceCommandPayloadCopyWithImpl<$Res, $Val extends VoiceCommandPayload>
    implements $VoiceCommandPayloadCopyWith<$Res> {
  _$VoiceCommandPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceCommandPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? command = null}) {
    return _then(
      _value.copyWith(
            command: null == command
                ? _value.command
                : command // ignore: cast_nullable_to_non_nullable
                      as VoiceCommand,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VoiceCommandPayloadImplCopyWith<$Res>
    implements $VoiceCommandPayloadCopyWith<$Res> {
  factory _$$VoiceCommandPayloadImplCopyWith(
    _$VoiceCommandPayloadImpl value,
    $Res Function(_$VoiceCommandPayloadImpl) then,
  ) = __$$VoiceCommandPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VoiceCommand command});
}

/// @nodoc
class __$$VoiceCommandPayloadImplCopyWithImpl<$Res>
    extends _$VoiceCommandPayloadCopyWithImpl<$Res, _$VoiceCommandPayloadImpl>
    implements _$$VoiceCommandPayloadImplCopyWith<$Res> {
  __$$VoiceCommandPayloadImplCopyWithImpl(
    _$VoiceCommandPayloadImpl _value,
    $Res Function(_$VoiceCommandPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VoiceCommandPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? command = null}) {
    return _then(
      _$VoiceCommandPayloadImpl(
        command: null == command
            ? _value.command
            : command // ignore: cast_nullable_to_non_nullable
                  as VoiceCommand,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceCommandPayloadImpl implements _VoiceCommandPayload {
  const _$VoiceCommandPayloadImpl({required this.command});

  factory _$VoiceCommandPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceCommandPayloadImplFromJson(json);

  @override
  final VoiceCommand command;

  @override
  String toString() {
    return 'VoiceCommandPayload(command: $command)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceCommandPayloadImpl &&
            (identical(other.command, command) || other.command == command));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, command);

  /// Create a copy of VoiceCommandPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceCommandPayloadImplCopyWith<_$VoiceCommandPayloadImpl> get copyWith =>
      __$$VoiceCommandPayloadImplCopyWithImpl<_$VoiceCommandPayloadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceCommandPayloadImplToJson(this);
  }
}

abstract class _VoiceCommandPayload implements VoiceCommandPayload {
  const factory _VoiceCommandPayload({required final VoiceCommand command}) =
      _$VoiceCommandPayloadImpl;

  factory _VoiceCommandPayload.fromJson(Map<String, dynamic> json) =
      _$VoiceCommandPayloadImpl.fromJson;

  @override
  VoiceCommand get command;

  /// Create a copy of VoiceCommandPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceCommandPayloadImplCopyWith<_$VoiceCommandPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ServerCapabilities _$ServerCapabilitiesFromJson(Map<String, dynamic> json) {
  return _ServerCapabilities.fromJson(json);
}

/// @nodoc
mixin _$ServerCapabilities {
  @JsonKey(name: 'voice_commands')
  bool get voiceCommands => throw _privateConstructorUsedError;
  bool get diarization => throw _privateConstructorUsedError;

  /// Serializes this ServerCapabilities to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServerCapabilitiesCopyWith<ServerCapabilities> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerCapabilitiesCopyWith<$Res> {
  factory $ServerCapabilitiesCopyWith(
    ServerCapabilities value,
    $Res Function(ServerCapabilities) then,
  ) = _$ServerCapabilitiesCopyWithImpl<$Res, ServerCapabilities>;
  @useResult
  $Res call({
    @JsonKey(name: 'voice_commands') bool voiceCommands,
    bool diarization,
  });
}

/// @nodoc
class _$ServerCapabilitiesCopyWithImpl<$Res, $Val extends ServerCapabilities>
    implements $ServerCapabilitiesCopyWith<$Res> {
  _$ServerCapabilitiesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? voiceCommands = null, Object? diarization = null}) {
    return _then(
      _value.copyWith(
            voiceCommands: null == voiceCommands
                ? _value.voiceCommands
                : voiceCommands // ignore: cast_nullable_to_non_nullable
                      as bool,
            diarization: null == diarization
                ? _value.diarization
                : diarization // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServerCapabilitiesImplCopyWith<$Res>
    implements $ServerCapabilitiesCopyWith<$Res> {
  factory _$$ServerCapabilitiesImplCopyWith(
    _$ServerCapabilitiesImpl value,
    $Res Function(_$ServerCapabilitiesImpl) then,
  ) = __$$ServerCapabilitiesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'voice_commands') bool voiceCommands,
    bool diarization,
  });
}

/// @nodoc
class __$$ServerCapabilitiesImplCopyWithImpl<$Res>
    extends _$ServerCapabilitiesCopyWithImpl<$Res, _$ServerCapabilitiesImpl>
    implements _$$ServerCapabilitiesImplCopyWith<$Res> {
  __$$ServerCapabilitiesImplCopyWithImpl(
    _$ServerCapabilitiesImpl _value,
    $Res Function(_$ServerCapabilitiesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? voiceCommands = null, Object? diarization = null}) {
    return _then(
      _$ServerCapabilitiesImpl(
        voiceCommands: null == voiceCommands
            ? _value.voiceCommands
            : voiceCommands // ignore: cast_nullable_to_non_nullable
                  as bool,
        diarization: null == diarization
            ? _value.diarization
            : diarization // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServerCapabilitiesImpl implements _ServerCapabilities {
  const _$ServerCapabilitiesImpl({
    @JsonKey(name: 'voice_commands') this.voiceCommands = false,
    this.diarization = false,
  });

  factory _$ServerCapabilitiesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServerCapabilitiesImplFromJson(json);

  @override
  @JsonKey(name: 'voice_commands')
  final bool voiceCommands;
  @override
  @JsonKey()
  final bool diarization;

  @override
  String toString() {
    return 'ServerCapabilities(voiceCommands: $voiceCommands, diarization: $diarization)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerCapabilitiesImpl &&
            (identical(other.voiceCommands, voiceCommands) ||
                other.voiceCommands == voiceCommands) &&
            (identical(other.diarization, diarization) ||
                other.diarization == diarization));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, voiceCommands, diarization);

  /// Create a copy of ServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerCapabilitiesImplCopyWith<_$ServerCapabilitiesImpl> get copyWith =>
      __$$ServerCapabilitiesImplCopyWithImpl<_$ServerCapabilitiesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServerCapabilitiesImplToJson(this);
  }
}

abstract class _ServerCapabilities implements ServerCapabilities {
  const factory _ServerCapabilities({
    @JsonKey(name: 'voice_commands') final bool voiceCommands,
    final bool diarization,
  }) = _$ServerCapabilitiesImpl;

  factory _ServerCapabilities.fromJson(Map<String, dynamic> json) =
      _$ServerCapabilitiesImpl.fromJson;

  @override
  @JsonKey(name: 'voice_commands')
  bool get voiceCommands;
  @override
  bool get diarization;

  /// Create a copy of ServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerCapabilitiesImplCopyWith<_$ServerCapabilitiesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionStartedPayload _$SessionStartedPayloadFromJson(
  Map<String, dynamic> json,
) {
  return _SessionStartedPayload.fromJson(json);
}

/// @nodoc
mixin _$SessionStartedPayload {
  @JsonKey(name: 'protocol_version')
  String get protocolVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'patient_context')
  PatientContext get patientContext => throw _privateConstructorUsedError;
  @JsonKey(name: 'server_capabilities')
  ServerCapabilities get serverCapabilities =>
      throw _privateConstructorUsedError;

  /// Serializes this SessionStartedPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionStartedPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionStartedPayloadCopyWith<SessionStartedPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionStartedPayloadCopyWith<$Res> {
  factory $SessionStartedPayloadCopyWith(
    SessionStartedPayload value,
    $Res Function(SessionStartedPayload) then,
  ) = _$SessionStartedPayloadCopyWithImpl<$Res, SessionStartedPayload>;
  @useResult
  $Res call({
    @JsonKey(name: 'protocol_version') String protocolVersion,
    @JsonKey(name: 'patient_context') PatientContext patientContext,
    @JsonKey(name: 'server_capabilities') ServerCapabilities serverCapabilities,
  });

  $PatientContextCopyWith<$Res> get patientContext;
  $ServerCapabilitiesCopyWith<$Res> get serverCapabilities;
}

/// @nodoc
class _$SessionStartedPayloadCopyWithImpl<
  $Res,
  $Val extends SessionStartedPayload
>
    implements $SessionStartedPayloadCopyWith<$Res> {
  _$SessionStartedPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionStartedPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? protocolVersion = null,
    Object? patientContext = null,
    Object? serverCapabilities = null,
  }) {
    return _then(
      _value.copyWith(
            protocolVersion: null == protocolVersion
                ? _value.protocolVersion
                : protocolVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            patientContext: null == patientContext
                ? _value.patientContext
                : patientContext // ignore: cast_nullable_to_non_nullable
                      as PatientContext,
            serverCapabilities: null == serverCapabilities
                ? _value.serverCapabilities
                : serverCapabilities // ignore: cast_nullable_to_non_nullable
                      as ServerCapabilities,
          )
          as $Val,
    );
  }

  /// Create a copy of SessionStartedPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PatientContextCopyWith<$Res> get patientContext {
    return $PatientContextCopyWith<$Res>(_value.patientContext, (value) {
      return _then(_value.copyWith(patientContext: value) as $Val);
    });
  }

  /// Create a copy of SessionStartedPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ServerCapabilitiesCopyWith<$Res> get serverCapabilities {
    return $ServerCapabilitiesCopyWith<$Res>(_value.serverCapabilities, (
      value,
    ) {
      return _then(_value.copyWith(serverCapabilities: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SessionStartedPayloadImplCopyWith<$Res>
    implements $SessionStartedPayloadCopyWith<$Res> {
  factory _$$SessionStartedPayloadImplCopyWith(
    _$SessionStartedPayloadImpl value,
    $Res Function(_$SessionStartedPayloadImpl) then,
  ) = __$$SessionStartedPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'protocol_version') String protocolVersion,
    @JsonKey(name: 'patient_context') PatientContext patientContext,
    @JsonKey(name: 'server_capabilities') ServerCapabilities serverCapabilities,
  });

  @override
  $PatientContextCopyWith<$Res> get patientContext;
  @override
  $ServerCapabilitiesCopyWith<$Res> get serverCapabilities;
}

/// @nodoc
class __$$SessionStartedPayloadImplCopyWithImpl<$Res>
    extends
        _$SessionStartedPayloadCopyWithImpl<$Res, _$SessionStartedPayloadImpl>
    implements _$$SessionStartedPayloadImplCopyWith<$Res> {
  __$$SessionStartedPayloadImplCopyWithImpl(
    _$SessionStartedPayloadImpl _value,
    $Res Function(_$SessionStartedPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionStartedPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? protocolVersion = null,
    Object? patientContext = null,
    Object? serverCapabilities = null,
  }) {
    return _then(
      _$SessionStartedPayloadImpl(
        protocolVersion: null == protocolVersion
            ? _value.protocolVersion
            : protocolVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        patientContext: null == patientContext
            ? _value.patientContext
            : patientContext // ignore: cast_nullable_to_non_nullable
                  as PatientContext,
        serverCapabilities: null == serverCapabilities
            ? _value.serverCapabilities
            : serverCapabilities // ignore: cast_nullable_to_non_nullable
                  as ServerCapabilities,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionStartedPayloadImpl implements _SessionStartedPayload {
  const _$SessionStartedPayloadImpl({
    @JsonKey(name: 'protocol_version') required this.protocolVersion,
    @JsonKey(name: 'patient_context') required this.patientContext,
    @JsonKey(name: 'server_capabilities') required this.serverCapabilities,
  });

  factory _$SessionStartedPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionStartedPayloadImplFromJson(json);

  @override
  @JsonKey(name: 'protocol_version')
  final String protocolVersion;
  @override
  @JsonKey(name: 'patient_context')
  final PatientContext patientContext;
  @override
  @JsonKey(name: 'server_capabilities')
  final ServerCapabilities serverCapabilities;

  @override
  String toString() {
    return 'SessionStartedPayload(protocolVersion: $protocolVersion, patientContext: $patientContext, serverCapabilities: $serverCapabilities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionStartedPayloadImpl &&
            (identical(other.protocolVersion, protocolVersion) ||
                other.protocolVersion == protocolVersion) &&
            (identical(other.patientContext, patientContext) ||
                other.patientContext == patientContext) &&
            (identical(other.serverCapabilities, serverCapabilities) ||
                other.serverCapabilities == serverCapabilities));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    protocolVersion,
    patientContext,
    serverCapabilities,
  );

  /// Create a copy of SessionStartedPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionStartedPayloadImplCopyWith<_$SessionStartedPayloadImpl>
  get copyWith =>
      __$$SessionStartedPayloadImplCopyWithImpl<_$SessionStartedPayloadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionStartedPayloadImplToJson(this);
  }
}

abstract class _SessionStartedPayload implements SessionStartedPayload {
  const factory _SessionStartedPayload({
    @JsonKey(name: 'protocol_version') required final String protocolVersion,
    @JsonKey(name: 'patient_context')
    required final PatientContext patientContext,
    @JsonKey(name: 'server_capabilities')
    required final ServerCapabilities serverCapabilities,
  }) = _$SessionStartedPayloadImpl;

  factory _SessionStartedPayload.fromJson(Map<String, dynamic> json) =
      _$SessionStartedPayloadImpl.fromJson;

  @override
  @JsonKey(name: 'protocol_version')
  String get protocolVersion;
  @override
  @JsonKey(name: 'patient_context')
  PatientContext get patientContext;
  @override
  @JsonKey(name: 'server_capabilities')
  ServerCapabilities get serverCapabilities;

  /// Create a copy of SessionStartedPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionStartedPayloadImplCopyWith<_$SessionStartedPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TranscriptPartialPayload _$TranscriptPartialPayloadFromJson(
  Map<String, dynamic> json,
) {
  return _TranscriptPartialPayload.fromJson(json);
}

/// @nodoc
mixin _$TranscriptPartialPayload {
  String get text => throw _privateConstructorUsedError;
  SpeakerRole get speaker => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_ms')
  int get startMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_ms')
  int get endMs => throw _privateConstructorUsedError;

  /// Serializes this TranscriptPartialPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TranscriptPartialPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranscriptPartialPayloadCopyWith<TranscriptPartialPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranscriptPartialPayloadCopyWith<$Res> {
  factory $TranscriptPartialPayloadCopyWith(
    TranscriptPartialPayload value,
    $Res Function(TranscriptPartialPayload) then,
  ) = _$TranscriptPartialPayloadCopyWithImpl<$Res, TranscriptPartialPayload>;
  @useResult
  $Res call({
    String text,
    SpeakerRole speaker,
    @JsonKey(name: 'start_ms') int startMs,
    @JsonKey(name: 'end_ms') int endMs,
  });
}

/// @nodoc
class _$TranscriptPartialPayloadCopyWithImpl<
  $Res,
  $Val extends TranscriptPartialPayload
>
    implements $TranscriptPartialPayloadCopyWith<$Res> {
  _$TranscriptPartialPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranscriptPartialPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? speaker = null,
    Object? startMs = null,
    Object? endMs = null,
  }) {
    return _then(
      _value.copyWith(
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            speaker: null == speaker
                ? _value.speaker
                : speaker // ignore: cast_nullable_to_non_nullable
                      as SpeakerRole,
            startMs: null == startMs
                ? _value.startMs
                : startMs // ignore: cast_nullable_to_non_nullable
                      as int,
            endMs: null == endMs
                ? _value.endMs
                : endMs // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TranscriptPartialPayloadImplCopyWith<$Res>
    implements $TranscriptPartialPayloadCopyWith<$Res> {
  factory _$$TranscriptPartialPayloadImplCopyWith(
    _$TranscriptPartialPayloadImpl value,
    $Res Function(_$TranscriptPartialPayloadImpl) then,
  ) = __$$TranscriptPartialPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String text,
    SpeakerRole speaker,
    @JsonKey(name: 'start_ms') int startMs,
    @JsonKey(name: 'end_ms') int endMs,
  });
}

/// @nodoc
class __$$TranscriptPartialPayloadImplCopyWithImpl<$Res>
    extends
        _$TranscriptPartialPayloadCopyWithImpl<
          $Res,
          _$TranscriptPartialPayloadImpl
        >
    implements _$$TranscriptPartialPayloadImplCopyWith<$Res> {
  __$$TranscriptPartialPayloadImplCopyWithImpl(
    _$TranscriptPartialPayloadImpl _value,
    $Res Function(_$TranscriptPartialPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TranscriptPartialPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? speaker = null,
    Object? startMs = null,
    Object? endMs = null,
  }) {
    return _then(
      _$TranscriptPartialPayloadImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        speaker: null == speaker
            ? _value.speaker
            : speaker // ignore: cast_nullable_to_non_nullable
                  as SpeakerRole,
        startMs: null == startMs
            ? _value.startMs
            : startMs // ignore: cast_nullable_to_non_nullable
                  as int,
        endMs: null == endMs
            ? _value.endMs
            : endMs // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TranscriptPartialPayloadImpl implements _TranscriptPartialPayload {
  const _$TranscriptPartialPayloadImpl({
    required this.text,
    this.speaker = SpeakerRole.unknown,
    @JsonKey(name: 'start_ms') required this.startMs,
    @JsonKey(name: 'end_ms') required this.endMs,
  });

  factory _$TranscriptPartialPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranscriptPartialPayloadImplFromJson(json);

  @override
  final String text;
  @override
  @JsonKey()
  final SpeakerRole speaker;
  @override
  @JsonKey(name: 'start_ms')
  final int startMs;
  @override
  @JsonKey(name: 'end_ms')
  final int endMs;

  @override
  String toString() {
    return 'TranscriptPartialPayload(text: $text, speaker: $speaker, startMs: $startMs, endMs: $endMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptPartialPayloadImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.startMs, startMs) || other.startMs == startMs) &&
            (identical(other.endMs, endMs) || other.endMs == endMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, speaker, startMs, endMs);

  /// Create a copy of TranscriptPartialPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptPartialPayloadImplCopyWith<_$TranscriptPartialPayloadImpl>
  get copyWith =>
      __$$TranscriptPartialPayloadImplCopyWithImpl<
        _$TranscriptPartialPayloadImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TranscriptPartialPayloadImplToJson(this);
  }
}

abstract class _TranscriptPartialPayload implements TranscriptPartialPayload {
  const factory _TranscriptPartialPayload({
    required final String text,
    final SpeakerRole speaker,
    @JsonKey(name: 'start_ms') required final int startMs,
    @JsonKey(name: 'end_ms') required final int endMs,
  }) = _$TranscriptPartialPayloadImpl;

  factory _TranscriptPartialPayload.fromJson(Map<String, dynamic> json) =
      _$TranscriptPartialPayloadImpl.fromJson;

  @override
  String get text;
  @override
  SpeakerRole get speaker;
  @override
  @JsonKey(name: 'start_ms')
  int get startMs;
  @override
  @JsonKey(name: 'end_ms')
  int get endMs;

  /// Create a copy of TranscriptPartialPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranscriptPartialPayloadImplCopyWith<_$TranscriptPartialPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TranscriptFinalPayload _$TranscriptFinalPayloadFromJson(
  Map<String, dynamic> json,
) {
  return _TranscriptFinalPayload.fromJson(json);
}

/// @nodoc
mixin _$TranscriptFinalPayload {
  @JsonKey(name: 'transcript_id')
  String get transcriptId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  SpeakerRole get speaker => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_ms')
  int get startMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_ms')
  int get endMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'audio_chunk_ids')
  List<String> get audioChunkIds => throw _privateConstructorUsedError;

  /// Serializes this TranscriptFinalPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TranscriptFinalPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranscriptFinalPayloadCopyWith<TranscriptFinalPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranscriptFinalPayloadCopyWith<$Res> {
  factory $TranscriptFinalPayloadCopyWith(
    TranscriptFinalPayload value,
    $Res Function(TranscriptFinalPayload) then,
  ) = _$TranscriptFinalPayloadCopyWithImpl<$Res, TranscriptFinalPayload>;
  @useResult
  $Res call({
    @JsonKey(name: 'transcript_id') String transcriptId,
    String text,
    SpeakerRole speaker,
    @JsonKey(name: 'start_ms') int startMs,
    @JsonKey(name: 'end_ms') int endMs,
    @JsonKey(name: 'audio_chunk_ids') List<String> audioChunkIds,
  });
}

/// @nodoc
class _$TranscriptFinalPayloadCopyWithImpl<
  $Res,
  $Val extends TranscriptFinalPayload
>
    implements $TranscriptFinalPayloadCopyWith<$Res> {
  _$TranscriptFinalPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranscriptFinalPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transcriptId = null,
    Object? text = null,
    Object? speaker = null,
    Object? startMs = null,
    Object? endMs = null,
    Object? audioChunkIds = null,
  }) {
    return _then(
      _value.copyWith(
            transcriptId: null == transcriptId
                ? _value.transcriptId
                : transcriptId // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            speaker: null == speaker
                ? _value.speaker
                : speaker // ignore: cast_nullable_to_non_nullable
                      as SpeakerRole,
            startMs: null == startMs
                ? _value.startMs
                : startMs // ignore: cast_nullable_to_non_nullable
                      as int,
            endMs: null == endMs
                ? _value.endMs
                : endMs // ignore: cast_nullable_to_non_nullable
                      as int,
            audioChunkIds: null == audioChunkIds
                ? _value.audioChunkIds
                : audioChunkIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TranscriptFinalPayloadImplCopyWith<$Res>
    implements $TranscriptFinalPayloadCopyWith<$Res> {
  factory _$$TranscriptFinalPayloadImplCopyWith(
    _$TranscriptFinalPayloadImpl value,
    $Res Function(_$TranscriptFinalPayloadImpl) then,
  ) = __$$TranscriptFinalPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'transcript_id') String transcriptId,
    String text,
    SpeakerRole speaker,
    @JsonKey(name: 'start_ms') int startMs,
    @JsonKey(name: 'end_ms') int endMs,
    @JsonKey(name: 'audio_chunk_ids') List<String> audioChunkIds,
  });
}

/// @nodoc
class __$$TranscriptFinalPayloadImplCopyWithImpl<$Res>
    extends
        _$TranscriptFinalPayloadCopyWithImpl<$Res, _$TranscriptFinalPayloadImpl>
    implements _$$TranscriptFinalPayloadImplCopyWith<$Res> {
  __$$TranscriptFinalPayloadImplCopyWithImpl(
    _$TranscriptFinalPayloadImpl _value,
    $Res Function(_$TranscriptFinalPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TranscriptFinalPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transcriptId = null,
    Object? text = null,
    Object? speaker = null,
    Object? startMs = null,
    Object? endMs = null,
    Object? audioChunkIds = null,
  }) {
    return _then(
      _$TranscriptFinalPayloadImpl(
        transcriptId: null == transcriptId
            ? _value.transcriptId
            : transcriptId // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        speaker: null == speaker
            ? _value.speaker
            : speaker // ignore: cast_nullable_to_non_nullable
                  as SpeakerRole,
        startMs: null == startMs
            ? _value.startMs
            : startMs // ignore: cast_nullable_to_non_nullable
                  as int,
        endMs: null == endMs
            ? _value.endMs
            : endMs // ignore: cast_nullable_to_non_nullable
                  as int,
        audioChunkIds: null == audioChunkIds
            ? _value._audioChunkIds
            : audioChunkIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TranscriptFinalPayloadImpl implements _TranscriptFinalPayload {
  const _$TranscriptFinalPayloadImpl({
    @JsonKey(name: 'transcript_id') required this.transcriptId,
    required this.text,
    this.speaker = SpeakerRole.unknown,
    @JsonKey(name: 'start_ms') required this.startMs,
    @JsonKey(name: 'end_ms') required this.endMs,
    @JsonKey(name: 'audio_chunk_ids')
    final List<String> audioChunkIds = const <String>[],
  }) : _audioChunkIds = audioChunkIds;

  factory _$TranscriptFinalPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranscriptFinalPayloadImplFromJson(json);

  @override
  @JsonKey(name: 'transcript_id')
  final String transcriptId;
  @override
  final String text;
  @override
  @JsonKey()
  final SpeakerRole speaker;
  @override
  @JsonKey(name: 'start_ms')
  final int startMs;
  @override
  @JsonKey(name: 'end_ms')
  final int endMs;
  final List<String> _audioChunkIds;
  @override
  @JsonKey(name: 'audio_chunk_ids')
  List<String> get audioChunkIds {
    if (_audioChunkIds is EqualUnmodifiableListView) return _audioChunkIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_audioChunkIds);
  }

  @override
  String toString() {
    return 'TranscriptFinalPayload(transcriptId: $transcriptId, text: $text, speaker: $speaker, startMs: $startMs, endMs: $endMs, audioChunkIds: $audioChunkIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptFinalPayloadImpl &&
            (identical(other.transcriptId, transcriptId) ||
                other.transcriptId == transcriptId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.startMs, startMs) || other.startMs == startMs) &&
            (identical(other.endMs, endMs) || other.endMs == endMs) &&
            const DeepCollectionEquality().equals(
              other._audioChunkIds,
              _audioChunkIds,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    transcriptId,
    text,
    speaker,
    startMs,
    endMs,
    const DeepCollectionEquality().hash(_audioChunkIds),
  );

  /// Create a copy of TranscriptFinalPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptFinalPayloadImplCopyWith<_$TranscriptFinalPayloadImpl>
  get copyWith =>
      __$$TranscriptFinalPayloadImplCopyWithImpl<_$TranscriptFinalPayloadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TranscriptFinalPayloadImplToJson(this);
  }
}

abstract class _TranscriptFinalPayload implements TranscriptFinalPayload {
  const factory _TranscriptFinalPayload({
    @JsonKey(name: 'transcript_id') required final String transcriptId,
    required final String text,
    final SpeakerRole speaker,
    @JsonKey(name: 'start_ms') required final int startMs,
    @JsonKey(name: 'end_ms') required final int endMs,
    @JsonKey(name: 'audio_chunk_ids') final List<String> audioChunkIds,
  }) = _$TranscriptFinalPayloadImpl;

  factory _TranscriptFinalPayload.fromJson(Map<String, dynamic> json) =
      _$TranscriptFinalPayloadImpl.fromJson;

  @override
  @JsonKey(name: 'transcript_id')
  String get transcriptId;
  @override
  String get text;
  @override
  SpeakerRole get speaker;
  @override
  @JsonKey(name: 'start_ms')
  int get startMs;
  @override
  @JsonKey(name: 'end_ms')
  int get endMs;
  @override
  @JsonKey(name: 'audio_chunk_ids')
  List<String> get audioChunkIds;

  /// Create a copy of TranscriptFinalPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranscriptFinalPayloadImplCopyWith<_$TranscriptFinalPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

EventAckPayload _$EventAckPayloadFromJson(Map<String, dynamic> json) {
  return _EventAckPayload.fromJson(json);
}

/// @nodoc
mixin _$EventAckPayload {
  @JsonKey(name: 'event_id')
  String get eventId => throw _privateConstructorUsedError;
  EventAckStatus get status => throw _privateConstructorUsedError;

  /// Serializes this EventAckPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventAckPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventAckPayloadCopyWith<EventAckPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventAckPayloadCopyWith<$Res> {
  factory $EventAckPayloadCopyWith(
    EventAckPayload value,
    $Res Function(EventAckPayload) then,
  ) = _$EventAckPayloadCopyWithImpl<$Res, EventAckPayload>;
  @useResult
  $Res call({@JsonKey(name: 'event_id') String eventId, EventAckStatus status});
}

/// @nodoc
class _$EventAckPayloadCopyWithImpl<$Res, $Val extends EventAckPayload>
    implements $EventAckPayloadCopyWith<$Res> {
  _$EventAckPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventAckPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? eventId = null, Object? status = null}) {
    return _then(
      _value.copyWith(
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EventAckStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventAckPayloadImplCopyWith<$Res>
    implements $EventAckPayloadCopyWith<$Res> {
  factory _$$EventAckPayloadImplCopyWith(
    _$EventAckPayloadImpl value,
    $Res Function(_$EventAckPayloadImpl) then,
  ) = __$$EventAckPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'event_id') String eventId, EventAckStatus status});
}

/// @nodoc
class __$$EventAckPayloadImplCopyWithImpl<$Res>
    extends _$EventAckPayloadCopyWithImpl<$Res, _$EventAckPayloadImpl>
    implements _$$EventAckPayloadImplCopyWith<$Res> {
  __$$EventAckPayloadImplCopyWithImpl(
    _$EventAckPayloadImpl _value,
    $Res Function(_$EventAckPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventAckPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? eventId = null, Object? status = null}) {
    return _then(
      _$EventAckPayloadImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EventAckStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventAckPayloadImpl implements _EventAckPayload {
  const _$EventAckPayloadImpl({
    @JsonKey(name: 'event_id') required this.eventId,
    required this.status,
  });

  factory _$EventAckPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventAckPayloadImplFromJson(json);

  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  final EventAckStatus status;

  @override
  String toString() {
    return 'EventAckPayload(eventId: $eventId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventAckPayloadImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, eventId, status);

  /// Create a copy of EventAckPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventAckPayloadImplCopyWith<_$EventAckPayloadImpl> get copyWith =>
      __$$EventAckPayloadImplCopyWithImpl<_$EventAckPayloadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventAckPayloadImplToJson(this);
  }
}

abstract class _EventAckPayload implements EventAckPayload {
  const factory _EventAckPayload({
    @JsonKey(name: 'event_id') required final String eventId,
    required final EventAckStatus status,
  }) = _$EventAckPayloadImpl;

  factory _EventAckPayload.fromJson(Map<String, dynamic> json) =
      _$EventAckPayloadImpl.fromJson;

  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  EventAckStatus get status;

  /// Create a copy of EventAckPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventAckPayloadImplCopyWith<_$EventAckPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionEndedPayload _$SessionEndedPayloadFromJson(Map<String, dynamic> json) {
  return _SessionEndedPayload.fromJson(json);
}

/// @nodoc
mixin _$SessionEndedPayload {
  @JsonKey(name: 'reason')
  String? get reason => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_seq')
  int? get finalSeq => throw _privateConstructorUsedError;

  /// Serializes this SessionEndedPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionEndedPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionEndedPayloadCopyWith<SessionEndedPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionEndedPayloadCopyWith<$Res> {
  factory $SessionEndedPayloadCopyWith(
    SessionEndedPayload value,
    $Res Function(SessionEndedPayload) then,
  ) = _$SessionEndedPayloadCopyWithImpl<$Res, SessionEndedPayload>;
  @useResult
  $Res call({
    @JsonKey(name: 'reason') String? reason,
    @JsonKey(name: 'final_seq') int? finalSeq,
  });
}

/// @nodoc
class _$SessionEndedPayloadCopyWithImpl<$Res, $Val extends SessionEndedPayload>
    implements $SessionEndedPayloadCopyWith<$Res> {
  _$SessionEndedPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionEndedPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = freezed, Object? finalSeq = freezed}) {
    return _then(
      _value.copyWith(
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            finalSeq: freezed == finalSeq
                ? _value.finalSeq
                : finalSeq // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionEndedPayloadImplCopyWith<$Res>
    implements $SessionEndedPayloadCopyWith<$Res> {
  factory _$$SessionEndedPayloadImplCopyWith(
    _$SessionEndedPayloadImpl value,
    $Res Function(_$SessionEndedPayloadImpl) then,
  ) = __$$SessionEndedPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'reason') String? reason,
    @JsonKey(name: 'final_seq') int? finalSeq,
  });
}

/// @nodoc
class __$$SessionEndedPayloadImplCopyWithImpl<$Res>
    extends _$SessionEndedPayloadCopyWithImpl<$Res, _$SessionEndedPayloadImpl>
    implements _$$SessionEndedPayloadImplCopyWith<$Res> {
  __$$SessionEndedPayloadImplCopyWithImpl(
    _$SessionEndedPayloadImpl _value,
    $Res Function(_$SessionEndedPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionEndedPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = freezed, Object? finalSeq = freezed}) {
    return _then(
      _$SessionEndedPayloadImpl(
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        finalSeq: freezed == finalSeq
            ? _value.finalSeq
            : finalSeq // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionEndedPayloadImpl implements _SessionEndedPayload {
  const _$SessionEndedPayloadImpl({
    @JsonKey(name: 'reason') this.reason,
    @JsonKey(name: 'final_seq') this.finalSeq,
  });

  factory _$SessionEndedPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionEndedPayloadImplFromJson(json);

  @override
  @JsonKey(name: 'reason')
  final String? reason;
  @override
  @JsonKey(name: 'final_seq')
  final int? finalSeq;

  @override
  String toString() {
    return 'SessionEndedPayload(reason: $reason, finalSeq: $finalSeq)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionEndedPayloadImpl &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.finalSeq, finalSeq) ||
                other.finalSeq == finalSeq));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reason, finalSeq);

  /// Create a copy of SessionEndedPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionEndedPayloadImplCopyWith<_$SessionEndedPayloadImpl> get copyWith =>
      __$$SessionEndedPayloadImplCopyWithImpl<_$SessionEndedPayloadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionEndedPayloadImplToJson(this);
  }
}

abstract class _SessionEndedPayload implements SessionEndedPayload {
  const factory _SessionEndedPayload({
    @JsonKey(name: 'reason') final String? reason,
    @JsonKey(name: 'final_seq') final int? finalSeq,
  }) = _$SessionEndedPayloadImpl;

  factory _SessionEndedPayload.fromJson(Map<String, dynamic> json) =
      _$SessionEndedPayloadImpl.fromJson;

  @override
  @JsonKey(name: 'reason')
  String? get reason;
  @override
  @JsonKey(name: 'final_seq')
  int? get finalSeq;

  /// Create a copy of SessionEndedPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionEndedPayloadImplCopyWith<_$SessionEndedPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WssPayload {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WssPayloadCopyWith<$Res> {
  factory $WssPayloadCopyWith(
    WssPayload value,
    $Res Function(WssPayload) then,
  ) = _$WssPayloadCopyWithImpl<$Res, WssPayload>;
}

/// @nodoc
class _$WssPayloadCopyWithImpl<$Res, $Val extends WssPayload>
    implements $WssPayloadCopyWith<$Res> {
  _$WssPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AudioChunkWssPayloadImplCopyWith<$Res> {
  factory _$$AudioChunkWssPayloadImplCopyWith(
    _$AudioChunkWssPayloadImpl value,
    $Res Function(_$AudioChunkWssPayloadImpl) then,
  ) = __$$AudioChunkWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AudioChunkPayload payload});

  $AudioChunkPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class __$$AudioChunkWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$AudioChunkWssPayloadImpl>
    implements _$$AudioChunkWssPayloadImplCopyWith<$Res> {
  __$$AudioChunkWssPayloadImplCopyWithImpl(
    _$AudioChunkWssPayloadImpl _value,
    $Res Function(_$AudioChunkWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? payload = null}) {
    return _then(
      _$AudioChunkWssPayloadImpl(
        null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as AudioChunkPayload,
      ),
    );
  }

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AudioChunkPayloadCopyWith<$Res> get payload {
    return $AudioChunkPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value));
    });
  }
}

/// @nodoc

class _$AudioChunkWssPayloadImpl implements AudioChunkWssPayload {
  const _$AudioChunkWssPayloadImpl(this.payload);

  @override
  final AudioChunkPayload payload;

  @override
  String toString() {
    return 'WssPayload.audioChunk(payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioChunkWssPayloadImpl &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payload);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioChunkWssPayloadImplCopyWith<_$AudioChunkWssPayloadImpl>
  get copyWith =>
      __$$AudioChunkWssPayloadImplCopyWithImpl<_$AudioChunkWssPayloadImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return audioChunk(payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return audioChunk?.call(payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (audioChunk != null) {
      return audioChunk(payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return audioChunk(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return audioChunk?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (audioChunk != null) {
      return audioChunk(this);
    }
    return orElse();
  }
}

abstract class AudioChunkWssPayload implements WssPayload {
  const factory AudioChunkWssPayload(final AudioChunkPayload payload) =
      _$AudioChunkWssPayloadImpl;

  AudioChunkPayload get payload;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioChunkWssPayloadImplCopyWith<_$AudioChunkWssPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VoiceCommandWssPayloadImplCopyWith<$Res> {
  factory _$$VoiceCommandWssPayloadImplCopyWith(
    _$VoiceCommandWssPayloadImpl value,
    $Res Function(_$VoiceCommandWssPayloadImpl) then,
  ) = __$$VoiceCommandWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VoiceCommandPayload payload});

  $VoiceCommandPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class __$$VoiceCommandWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$VoiceCommandWssPayloadImpl>
    implements _$$VoiceCommandWssPayloadImplCopyWith<$Res> {
  __$$VoiceCommandWssPayloadImplCopyWithImpl(
    _$VoiceCommandWssPayloadImpl _value,
    $Res Function(_$VoiceCommandWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? payload = null}) {
    return _then(
      _$VoiceCommandWssPayloadImpl(
        null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as VoiceCommandPayload,
      ),
    );
  }

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VoiceCommandPayloadCopyWith<$Res> get payload {
    return $VoiceCommandPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value));
    });
  }
}

/// @nodoc

class _$VoiceCommandWssPayloadImpl implements VoiceCommandWssPayload {
  const _$VoiceCommandWssPayloadImpl(this.payload);

  @override
  final VoiceCommandPayload payload;

  @override
  String toString() {
    return 'WssPayload.voiceCommand(payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceCommandWssPayloadImpl &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payload);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceCommandWssPayloadImplCopyWith<_$VoiceCommandWssPayloadImpl>
  get copyWith =>
      __$$VoiceCommandWssPayloadImplCopyWithImpl<_$VoiceCommandWssPayloadImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return voiceCommand(payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return voiceCommand?.call(payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (voiceCommand != null) {
      return voiceCommand(payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return voiceCommand(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return voiceCommand?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (voiceCommand != null) {
      return voiceCommand(this);
    }
    return orElse();
  }
}

abstract class VoiceCommandWssPayload implements WssPayload {
  const factory VoiceCommandWssPayload(final VoiceCommandPayload payload) =
      _$VoiceCommandWssPayloadImpl;

  VoiceCommandPayload get payload;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceCommandWssPayloadImplCopyWith<_$VoiceCommandWssPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionStartedWssPayloadImplCopyWith<$Res> {
  factory _$$SessionStartedWssPayloadImplCopyWith(
    _$SessionStartedWssPayloadImpl value,
    $Res Function(_$SessionStartedWssPayloadImpl) then,
  ) = __$$SessionStartedWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SessionStartedPayload payload});

  $SessionStartedPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class __$$SessionStartedWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$SessionStartedWssPayloadImpl>
    implements _$$SessionStartedWssPayloadImplCopyWith<$Res> {
  __$$SessionStartedWssPayloadImplCopyWithImpl(
    _$SessionStartedWssPayloadImpl _value,
    $Res Function(_$SessionStartedWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? payload = null}) {
    return _then(
      _$SessionStartedWssPayloadImpl(
        null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as SessionStartedPayload,
      ),
    );
  }

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionStartedPayloadCopyWith<$Res> get payload {
    return $SessionStartedPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value));
    });
  }
}

/// @nodoc

class _$SessionStartedWssPayloadImpl implements SessionStartedWssPayload {
  const _$SessionStartedWssPayloadImpl(this.payload);

  @override
  final SessionStartedPayload payload;

  @override
  String toString() {
    return 'WssPayload.sessionStarted(payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionStartedWssPayloadImpl &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payload);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionStartedWssPayloadImplCopyWith<_$SessionStartedWssPayloadImpl>
  get copyWith =>
      __$$SessionStartedWssPayloadImplCopyWithImpl<
        _$SessionStartedWssPayloadImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return sessionStarted(payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return sessionStarted?.call(payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (sessionStarted != null) {
      return sessionStarted(payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return sessionStarted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return sessionStarted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (sessionStarted != null) {
      return sessionStarted(this);
    }
    return orElse();
  }
}

abstract class SessionStartedWssPayload implements WssPayload {
  const factory SessionStartedWssPayload(final SessionStartedPayload payload) =
      _$SessionStartedWssPayloadImpl;

  SessionStartedPayload get payload;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionStartedWssPayloadImplCopyWith<_$SessionStartedWssPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TranscriptPartialWssPayloadImplCopyWith<$Res> {
  factory _$$TranscriptPartialWssPayloadImplCopyWith(
    _$TranscriptPartialWssPayloadImpl value,
    $Res Function(_$TranscriptPartialWssPayloadImpl) then,
  ) = __$$TranscriptPartialWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TranscriptPartialPayload payload});

  $TranscriptPartialPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class __$$TranscriptPartialWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$TranscriptPartialWssPayloadImpl>
    implements _$$TranscriptPartialWssPayloadImplCopyWith<$Res> {
  __$$TranscriptPartialWssPayloadImplCopyWithImpl(
    _$TranscriptPartialWssPayloadImpl _value,
    $Res Function(_$TranscriptPartialWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? payload = null}) {
    return _then(
      _$TranscriptPartialWssPayloadImpl(
        null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as TranscriptPartialPayload,
      ),
    );
  }

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TranscriptPartialPayloadCopyWith<$Res> get payload {
    return $TranscriptPartialPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value));
    });
  }
}

/// @nodoc

class _$TranscriptPartialWssPayloadImpl implements TranscriptPartialWssPayload {
  const _$TranscriptPartialWssPayloadImpl(this.payload);

  @override
  final TranscriptPartialPayload payload;

  @override
  String toString() {
    return 'WssPayload.transcriptPartial(payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptPartialWssPayloadImpl &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payload);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptPartialWssPayloadImplCopyWith<_$TranscriptPartialWssPayloadImpl>
  get copyWith =>
      __$$TranscriptPartialWssPayloadImplCopyWithImpl<
        _$TranscriptPartialWssPayloadImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return transcriptPartial(payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return transcriptPartial?.call(payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (transcriptPartial != null) {
      return transcriptPartial(payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return transcriptPartial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return transcriptPartial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (transcriptPartial != null) {
      return transcriptPartial(this);
    }
    return orElse();
  }
}

abstract class TranscriptPartialWssPayload implements WssPayload {
  const factory TranscriptPartialWssPayload(
    final TranscriptPartialPayload payload,
  ) = _$TranscriptPartialWssPayloadImpl;

  TranscriptPartialPayload get payload;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranscriptPartialWssPayloadImplCopyWith<_$TranscriptPartialWssPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TranscriptFinalWssPayloadImplCopyWith<$Res> {
  factory _$$TranscriptFinalWssPayloadImplCopyWith(
    _$TranscriptFinalWssPayloadImpl value,
    $Res Function(_$TranscriptFinalWssPayloadImpl) then,
  ) = __$$TranscriptFinalWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TranscriptFinalPayload payload});

  $TranscriptFinalPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class __$$TranscriptFinalWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$TranscriptFinalWssPayloadImpl>
    implements _$$TranscriptFinalWssPayloadImplCopyWith<$Res> {
  __$$TranscriptFinalWssPayloadImplCopyWithImpl(
    _$TranscriptFinalWssPayloadImpl _value,
    $Res Function(_$TranscriptFinalWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? payload = null}) {
    return _then(
      _$TranscriptFinalWssPayloadImpl(
        null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as TranscriptFinalPayload,
      ),
    );
  }

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TranscriptFinalPayloadCopyWith<$Res> get payload {
    return $TranscriptFinalPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value));
    });
  }
}

/// @nodoc

class _$TranscriptFinalWssPayloadImpl implements TranscriptFinalWssPayload {
  const _$TranscriptFinalWssPayloadImpl(this.payload);

  @override
  final TranscriptFinalPayload payload;

  @override
  String toString() {
    return 'WssPayload.transcriptFinal(payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptFinalWssPayloadImpl &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payload);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptFinalWssPayloadImplCopyWith<_$TranscriptFinalWssPayloadImpl>
  get copyWith =>
      __$$TranscriptFinalWssPayloadImplCopyWithImpl<
        _$TranscriptFinalWssPayloadImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return transcriptFinal(payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return transcriptFinal?.call(payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (transcriptFinal != null) {
      return transcriptFinal(payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return transcriptFinal(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return transcriptFinal?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (transcriptFinal != null) {
      return transcriptFinal(this);
    }
    return orElse();
  }
}

abstract class TranscriptFinalWssPayload implements WssPayload {
  const factory TranscriptFinalWssPayload(
    final TranscriptFinalPayload payload,
  ) = _$TranscriptFinalWssPayloadImpl;

  TranscriptFinalPayload get payload;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranscriptFinalWssPayloadImplCopyWith<_$TranscriptFinalWssPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EventExtractedWssPayloadImplCopyWith<$Res> {
  factory _$$EventExtractedWssPayloadImplCopyWith(
    _$EventExtractedWssPayloadImpl value,
    $Res Function(_$EventExtractedWssPayloadImpl) then,
  ) = __$$EventExtractedWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({EventExtractedPayload payload});
}

/// @nodoc
class __$$EventExtractedWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$EventExtractedWssPayloadImpl>
    implements _$$EventExtractedWssPayloadImplCopyWith<$Res> {
  __$$EventExtractedWssPayloadImplCopyWithImpl(
    _$EventExtractedWssPayloadImpl _value,
    $Res Function(_$EventExtractedWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? payload = null}) {
    return _then(
      _$EventExtractedWssPayloadImpl(
        null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as EventExtractedPayload,
      ),
    );
  }
}

/// @nodoc

class _$EventExtractedWssPayloadImpl implements EventExtractedWssPayload {
  const _$EventExtractedWssPayloadImpl(this.payload);

  @override
  final EventExtractedPayload payload;

  @override
  String toString() {
    return 'WssPayload.eventExtracted(payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventExtractedWssPayloadImpl &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payload);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventExtractedWssPayloadImplCopyWith<_$EventExtractedWssPayloadImpl>
  get copyWith =>
      __$$EventExtractedWssPayloadImplCopyWithImpl<
        _$EventExtractedWssPayloadImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return eventExtracted(payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return eventExtracted?.call(payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (eventExtracted != null) {
      return eventExtracted(payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return eventExtracted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return eventExtracted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (eventExtracted != null) {
      return eventExtracted(this);
    }
    return orElse();
  }
}

abstract class EventExtractedWssPayload implements WssPayload {
  const factory EventExtractedWssPayload(final EventExtractedPayload payload) =
      _$EventExtractedWssPayloadImpl;

  EventExtractedPayload get payload;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventExtractedWssPayloadImplCopyWith<_$EventExtractedWssPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EventAckWssPayloadImplCopyWith<$Res> {
  factory _$$EventAckWssPayloadImplCopyWith(
    _$EventAckWssPayloadImpl value,
    $Res Function(_$EventAckWssPayloadImpl) then,
  ) = __$$EventAckWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({EventAckPayload payload});

  $EventAckPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class __$$EventAckWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$EventAckWssPayloadImpl>
    implements _$$EventAckWssPayloadImplCopyWith<$Res> {
  __$$EventAckWssPayloadImplCopyWithImpl(
    _$EventAckWssPayloadImpl _value,
    $Res Function(_$EventAckWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? payload = null}) {
    return _then(
      _$EventAckWssPayloadImpl(
        null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as EventAckPayload,
      ),
    );
  }

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EventAckPayloadCopyWith<$Res> get payload {
    return $EventAckPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value));
    });
  }
}

/// @nodoc

class _$EventAckWssPayloadImpl implements EventAckWssPayload {
  const _$EventAckWssPayloadImpl(this.payload);

  @override
  final EventAckPayload payload;

  @override
  String toString() {
    return 'WssPayload.eventAck(payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventAckWssPayloadImpl &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payload);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventAckWssPayloadImplCopyWith<_$EventAckWssPayloadImpl> get copyWith =>
      __$$EventAckWssPayloadImplCopyWithImpl<_$EventAckWssPayloadImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return eventAck(payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return eventAck?.call(payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (eventAck != null) {
      return eventAck(payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return eventAck(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return eventAck?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (eventAck != null) {
      return eventAck(this);
    }
    return orElse();
  }
}

abstract class EventAckWssPayload implements WssPayload {
  const factory EventAckWssPayload(final EventAckPayload payload) =
      _$EventAckWssPayloadImpl;

  EventAckPayload get payload;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventAckWssPayloadImplCopyWith<_$EventAckWssPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionEndedWssPayloadImplCopyWith<$Res> {
  factory _$$SessionEndedWssPayloadImplCopyWith(
    _$SessionEndedWssPayloadImpl value,
    $Res Function(_$SessionEndedWssPayloadImpl) then,
  ) = __$$SessionEndedWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SessionEndedPayload payload});

  $SessionEndedPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class __$$SessionEndedWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$SessionEndedWssPayloadImpl>
    implements _$$SessionEndedWssPayloadImplCopyWith<$Res> {
  __$$SessionEndedWssPayloadImplCopyWithImpl(
    _$SessionEndedWssPayloadImpl _value,
    $Res Function(_$SessionEndedWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? payload = null}) {
    return _then(
      _$SessionEndedWssPayloadImpl(
        null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as SessionEndedPayload,
      ),
    );
  }

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionEndedPayloadCopyWith<$Res> get payload {
    return $SessionEndedPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value));
    });
  }
}

/// @nodoc

class _$SessionEndedWssPayloadImpl implements SessionEndedWssPayload {
  const _$SessionEndedWssPayloadImpl(this.payload);

  @override
  final SessionEndedPayload payload;

  @override
  String toString() {
    return 'WssPayload.sessionEnded(payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionEndedWssPayloadImpl &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payload);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionEndedWssPayloadImplCopyWith<_$SessionEndedWssPayloadImpl>
  get copyWith =>
      __$$SessionEndedWssPayloadImplCopyWithImpl<_$SessionEndedWssPayloadImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return sessionEnded(payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return sessionEnded?.call(payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (sessionEnded != null) {
      return sessionEnded(payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return sessionEnded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return sessionEnded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (sessionEnded != null) {
      return sessionEnded(this);
    }
    return orElse();
  }
}

abstract class SessionEndedWssPayload implements WssPayload {
  const factory SessionEndedWssPayload(final SessionEndedPayload payload) =
      _$SessionEndedWssPayloadImpl;

  SessionEndedPayload get payload;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionEndedWssPayloadImplCopyWith<_$SessionEndedWssPayloadImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorWssPayloadImplCopyWith<$Res> {
  factory _$$ErrorWssPayloadImplCopyWith(
    _$ErrorWssPayloadImpl value,
    $Res Function(_$ErrorWssPayloadImpl) then,
  ) = __$$ErrorWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({WireError payload});

  $WireErrorCopyWith<$Res> get payload;
}

/// @nodoc
class __$$ErrorWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$ErrorWssPayloadImpl>
    implements _$$ErrorWssPayloadImplCopyWith<$Res> {
  __$$ErrorWssPayloadImplCopyWithImpl(
    _$ErrorWssPayloadImpl _value,
    $Res Function(_$ErrorWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? payload = null}) {
    return _then(
      _$ErrorWssPayloadImpl(
        null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as WireError,
      ),
    );
  }

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WireErrorCopyWith<$Res> get payload {
    return $WireErrorCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value));
    });
  }
}

/// @nodoc

class _$ErrorWssPayloadImpl implements ErrorWssPayload {
  const _$ErrorWssPayloadImpl(this.payload);

  @override
  final WireError payload;

  @override
  String toString() {
    return 'WssPayload.error(payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorWssPayloadImpl &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, payload);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorWssPayloadImplCopyWith<_$ErrorWssPayloadImpl> get copyWith =>
      __$$ErrorWssPayloadImplCopyWithImpl<_$ErrorWssPayloadImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return error(payload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return error?.call(payload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(payload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ErrorWssPayload implements WssPayload {
  const factory ErrorWssPayload(final WireError payload) =
      _$ErrorWssPayloadImpl;

  WireError get payload;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorWssPayloadImplCopyWith<_$ErrorWssPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionPauseWssPayloadImplCopyWith<$Res> {
  factory _$$SessionPauseWssPayloadImplCopyWith(
    _$SessionPauseWssPayloadImpl value,
    $Res Function(_$SessionPauseWssPayloadImpl) then,
  ) = __$$SessionPauseWssPayloadImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SessionPauseWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$SessionPauseWssPayloadImpl>
    implements _$$SessionPauseWssPayloadImplCopyWith<$Res> {
  __$$SessionPauseWssPayloadImplCopyWithImpl(
    _$SessionPauseWssPayloadImpl _value,
    $Res Function(_$SessionPauseWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SessionPauseWssPayloadImpl implements SessionPauseWssPayload {
  const _$SessionPauseWssPayloadImpl();

  @override
  String toString() {
    return 'WssPayload.sessionPause()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionPauseWssPayloadImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return sessionPause();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return sessionPause?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (sessionPause != null) {
      return sessionPause();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return sessionPause(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return sessionPause?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (sessionPause != null) {
      return sessionPause(this);
    }
    return orElse();
  }
}

abstract class SessionPauseWssPayload implements WssPayload {
  const factory SessionPauseWssPayload() = _$SessionPauseWssPayloadImpl;
}

/// @nodoc
abstract class _$$SessionResumeWssPayloadImplCopyWith<$Res> {
  factory _$$SessionResumeWssPayloadImplCopyWith(
    _$SessionResumeWssPayloadImpl value,
    $Res Function(_$SessionResumeWssPayloadImpl) then,
  ) = __$$SessionResumeWssPayloadImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SessionResumeWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$SessionResumeWssPayloadImpl>
    implements _$$SessionResumeWssPayloadImplCopyWith<$Res> {
  __$$SessionResumeWssPayloadImplCopyWithImpl(
    _$SessionResumeWssPayloadImpl _value,
    $Res Function(_$SessionResumeWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SessionResumeWssPayloadImpl implements SessionResumeWssPayload {
  const _$SessionResumeWssPayloadImpl();

  @override
  String toString() {
    return 'WssPayload.sessionResume()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionResumeWssPayloadImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return sessionResume();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return sessionResume?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (sessionResume != null) {
      return sessionResume();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return sessionResume(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return sessionResume?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (sessionResume != null) {
      return sessionResume(this);
    }
    return orElse();
  }
}

abstract class SessionResumeWssPayload implements WssPayload {
  const factory SessionResumeWssPayload() = _$SessionResumeWssPayloadImpl;
}

/// @nodoc
abstract class _$$SessionEndWssPayloadImplCopyWith<$Res> {
  factory _$$SessionEndWssPayloadImplCopyWith(
    _$SessionEndWssPayloadImpl value,
    $Res Function(_$SessionEndWssPayloadImpl) then,
  ) = __$$SessionEndWssPayloadImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SessionEndWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$SessionEndWssPayloadImpl>
    implements _$$SessionEndWssPayloadImplCopyWith<$Res> {
  __$$SessionEndWssPayloadImplCopyWithImpl(
    _$SessionEndWssPayloadImpl _value,
    $Res Function(_$SessionEndWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SessionEndWssPayloadImpl implements SessionEndWssPayload {
  const _$SessionEndWssPayloadImpl();

  @override
  String toString() {
    return 'WssPayload.sessionEnd()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionEndWssPayloadImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return sessionEnd();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return sessionEnd?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (sessionEnd != null) {
      return sessionEnd();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return sessionEnd(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return sessionEnd?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (sessionEnd != null) {
      return sessionEnd(this);
    }
    return orElse();
  }
}

abstract class SessionEndWssPayload implements WssPayload {
  const factory SessionEndWssPayload() = _$SessionEndWssPayloadImpl;
}

/// @nodoc
abstract class _$$PingWssPayloadImplCopyWith<$Res> {
  factory _$$PingWssPayloadImplCopyWith(
    _$PingWssPayloadImpl value,
    $Res Function(_$PingWssPayloadImpl) then,
  ) = __$$PingWssPayloadImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PingWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$PingWssPayloadImpl>
    implements _$$PingWssPayloadImplCopyWith<$Res> {
  __$$PingWssPayloadImplCopyWithImpl(
    _$PingWssPayloadImpl _value,
    $Res Function(_$PingWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PingWssPayloadImpl implements PingWssPayload {
  const _$PingWssPayloadImpl();

  @override
  String toString() {
    return 'WssPayload.ping()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PingWssPayloadImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return ping();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return ping?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (ping != null) {
      return ping();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return ping(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return ping?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (ping != null) {
      return ping(this);
    }
    return orElse();
  }
}

abstract class PingWssPayload implements WssPayload {
  const factory PingWssPayload() = _$PingWssPayloadImpl;
}

/// @nodoc
abstract class _$$PongWssPayloadImplCopyWith<$Res> {
  factory _$$PongWssPayloadImplCopyWith(
    _$PongWssPayloadImpl value,
    $Res Function(_$PongWssPayloadImpl) then,
  ) = __$$PongWssPayloadImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PongWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$PongWssPayloadImpl>
    implements _$$PongWssPayloadImplCopyWith<$Res> {
  __$$PongWssPayloadImplCopyWithImpl(
    _$PongWssPayloadImpl _value,
    $Res Function(_$PongWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PongWssPayloadImpl implements PongWssPayload {
  const _$PongWssPayloadImpl();

  @override
  String toString() {
    return 'WssPayload.pong()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PongWssPayloadImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return pong();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return pong?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (pong != null) {
      return pong();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return pong(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return pong?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (pong != null) {
      return pong(this);
    }
    return orElse();
  }
}

abstract class PongWssPayload implements WssPayload {
  const factory PongWssPayload() = _$PongWssPayloadImpl;
}

/// @nodoc
abstract class _$$UnknownWssPayloadImplCopyWith<$Res> {
  factory _$$UnknownWssPayloadImplCopyWith(
    _$UnknownWssPayloadImpl value,
    $Res Function(_$UnknownWssPayloadImpl) then,
  ) = __$$UnknownWssPayloadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String type, Map<String, Object?> raw});
}

/// @nodoc
class __$$UnknownWssPayloadImplCopyWithImpl<$Res>
    extends _$WssPayloadCopyWithImpl<$Res, _$UnknownWssPayloadImpl>
    implements _$$UnknownWssPayloadImplCopyWith<$Res> {
  __$$UnknownWssPayloadImplCopyWithImpl(
    _$UnknownWssPayloadImpl _value,
    $Res Function(_$UnknownWssPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? raw = null}) {
    return _then(
      _$UnknownWssPayloadImpl(
        null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        null == raw
            ? _value._raw
            : raw // ignore: cast_nullable_to_non_nullable
                  as Map<String, Object?>,
      ),
    );
  }
}

/// @nodoc

class _$UnknownWssPayloadImpl implements UnknownWssPayload {
  const _$UnknownWssPayloadImpl(this.type, final Map<String, Object?> raw)
    : _raw = raw;

  @override
  final String type;
  final Map<String, Object?> _raw;
  @override
  Map<String, Object?> get raw {
    if (_raw is EqualUnmodifiableMapView) return _raw;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_raw);
  }

  @override
  String toString() {
    return 'WssPayload.unknown(type: $type, raw: $raw)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownWssPayloadImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._raw, _raw));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, type, const DeepCollectionEquality().hash(_raw));

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownWssPayloadImplCopyWith<_$UnknownWssPayloadImpl> get copyWith =>
      __$$UnknownWssPayloadImplCopyWithImpl<_$UnknownWssPayloadImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AudioChunkPayload payload) audioChunk,
    required TResult Function(VoiceCommandPayload payload) voiceCommand,
    required TResult Function(SessionStartedPayload payload) sessionStarted,
    required TResult Function(TranscriptPartialPayload payload)
    transcriptPartial,
    required TResult Function(TranscriptFinalPayload payload) transcriptFinal,
    required TResult Function(EventExtractedPayload payload) eventExtracted,
    required TResult Function(EventAckPayload payload) eventAck,
    required TResult Function(SessionEndedPayload payload) sessionEnded,
    required TResult Function(WireError payload) error,
    required TResult Function() sessionPause,
    required TResult Function() sessionResume,
    required TResult Function() sessionEnd,
    required TResult Function() ping,
    required TResult Function() pong,
    required TResult Function(String type, Map<String, Object?> raw) unknown,
  }) {
    return unknown(type, raw);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkPayload payload)? audioChunk,
    TResult? Function(VoiceCommandPayload payload)? voiceCommand,
    TResult? Function(SessionStartedPayload payload)? sessionStarted,
    TResult? Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult? Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult? Function(EventExtractedPayload payload)? eventExtracted,
    TResult? Function(EventAckPayload payload)? eventAck,
    TResult? Function(SessionEndedPayload payload)? sessionEnded,
    TResult? Function(WireError payload)? error,
    TResult? Function()? sessionPause,
    TResult? Function()? sessionResume,
    TResult? Function()? sessionEnd,
    TResult? Function()? ping,
    TResult? Function()? pong,
    TResult? Function(String type, Map<String, Object?> raw)? unknown,
  }) {
    return unknown?.call(type, raw);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AudioChunkPayload payload)? audioChunk,
    TResult Function(VoiceCommandPayload payload)? voiceCommand,
    TResult Function(SessionStartedPayload payload)? sessionStarted,
    TResult Function(TranscriptPartialPayload payload)? transcriptPartial,
    TResult Function(TranscriptFinalPayload payload)? transcriptFinal,
    TResult Function(EventExtractedPayload payload)? eventExtracted,
    TResult Function(EventAckPayload payload)? eventAck,
    TResult Function(SessionEndedPayload payload)? sessionEnded,
    TResult Function(WireError payload)? error,
    TResult Function()? sessionPause,
    TResult Function()? sessionResume,
    TResult Function()? sessionEnd,
    TResult Function()? ping,
    TResult Function()? pong,
    TResult Function(String type, Map<String, Object?> raw)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(type, raw);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AudioChunkWssPayload value) audioChunk,
    required TResult Function(VoiceCommandWssPayload value) voiceCommand,
    required TResult Function(SessionStartedWssPayload value) sessionStarted,
    required TResult Function(TranscriptPartialWssPayload value)
    transcriptPartial,
    required TResult Function(TranscriptFinalWssPayload value) transcriptFinal,
    required TResult Function(EventExtractedWssPayload value) eventExtracted,
    required TResult Function(EventAckWssPayload value) eventAck,
    required TResult Function(SessionEndedWssPayload value) sessionEnded,
    required TResult Function(ErrorWssPayload value) error,
    required TResult Function(SessionPauseWssPayload value) sessionPause,
    required TResult Function(SessionResumeWssPayload value) sessionResume,
    required TResult Function(SessionEndWssPayload value) sessionEnd,
    required TResult Function(PingWssPayload value) ping,
    required TResult Function(PongWssPayload value) pong,
    required TResult Function(UnknownWssPayload value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AudioChunkWssPayload value)? audioChunk,
    TResult? Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult? Function(SessionStartedWssPayload value)? sessionStarted,
    TResult? Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult? Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult? Function(EventExtractedWssPayload value)? eventExtracted,
    TResult? Function(EventAckWssPayload value)? eventAck,
    TResult? Function(SessionEndedWssPayload value)? sessionEnded,
    TResult? Function(ErrorWssPayload value)? error,
    TResult? Function(SessionPauseWssPayload value)? sessionPause,
    TResult? Function(SessionResumeWssPayload value)? sessionResume,
    TResult? Function(SessionEndWssPayload value)? sessionEnd,
    TResult? Function(PingWssPayload value)? ping,
    TResult? Function(PongWssPayload value)? pong,
    TResult? Function(UnknownWssPayload value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AudioChunkWssPayload value)? audioChunk,
    TResult Function(VoiceCommandWssPayload value)? voiceCommand,
    TResult Function(SessionStartedWssPayload value)? sessionStarted,
    TResult Function(TranscriptPartialWssPayload value)? transcriptPartial,
    TResult Function(TranscriptFinalWssPayload value)? transcriptFinal,
    TResult Function(EventExtractedWssPayload value)? eventExtracted,
    TResult Function(EventAckWssPayload value)? eventAck,
    TResult Function(SessionEndedWssPayload value)? sessionEnded,
    TResult Function(ErrorWssPayload value)? error,
    TResult Function(SessionPauseWssPayload value)? sessionPause,
    TResult Function(SessionResumeWssPayload value)? sessionResume,
    TResult Function(SessionEndWssPayload value)? sessionEnd,
    TResult Function(PingWssPayload value)? ping,
    TResult Function(PongWssPayload value)? pong,
    TResult Function(UnknownWssPayload value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownWssPayload implements WssPayload {
  const factory UnknownWssPayload(
    final String type,
    final Map<String, Object?> raw,
  ) = _$UnknownWssPayloadImpl;

  String get type;
  Map<String, Object?> get raw;

  /// Create a copy of WssPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownWssPayloadImplCopyWith<_$UnknownWssPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
