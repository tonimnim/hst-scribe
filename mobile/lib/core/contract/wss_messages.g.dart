// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wss_messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AudioChunkPayloadImpl _$$AudioChunkPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$AudioChunkPayloadImpl(
  chunkId: json['chunk_id'] as String,
  audioB64: json['audio_b64'] as String,
  sampleRate: (json['sample_rate'] as num?)?.toInt() ?? 16000,
  format: json['format'] as String? ?? 'pcm16',
  durationMs: (json['duration_ms'] as num?)?.toInt() ?? 250,
);

Map<String, dynamic> _$$AudioChunkPayloadImplToJson(
  _$AudioChunkPayloadImpl instance,
) => <String, dynamic>{
  'chunk_id': instance.chunkId,
  'audio_b64': instance.audioB64,
  'sample_rate': instance.sampleRate,
  'format': instance.format,
  'duration_ms': instance.durationMs,
};

_$VoiceCommandPayloadImpl _$$VoiceCommandPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$VoiceCommandPayloadImpl(
  command: $enumDecode(_$VoiceCommandEnumMap, json['command']),
);

Map<String, dynamic> _$$VoiceCommandPayloadImplToJson(
  _$VoiceCommandPayloadImpl instance,
) => <String, dynamic>{'command': _$VoiceCommandEnumMap[instance.command]!};

const _$VoiceCommandEnumMap = {
  VoiceCommand.confirmLast: 'confirm_last',
  VoiceCommand.strikeLast: 'strike_last',
  VoiceCommand.pause: 'pause',
  VoiceCommand.resume: 'resume',
  VoiceCommand.endSession: 'end_session',
};

_$ServerCapabilitiesImpl _$$ServerCapabilitiesImplFromJson(
  Map<String, dynamic> json,
) => _$ServerCapabilitiesImpl(
  voiceCommands: json['voice_commands'] as bool? ?? false,
  diarization: json['diarization'] as bool? ?? false,
);

Map<String, dynamic> _$$ServerCapabilitiesImplToJson(
  _$ServerCapabilitiesImpl instance,
) => <String, dynamic>{
  'voice_commands': instance.voiceCommands,
  'diarization': instance.diarization,
};

_$SessionStartedPayloadImpl _$$SessionStartedPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$SessionStartedPayloadImpl(
  protocolVersion: json['protocol_version'] as String,
  patientContext: PatientContext.fromJson(
    json['patient_context'] as Map<String, dynamic>,
  ),
  serverCapabilities: ServerCapabilities.fromJson(
    json['server_capabilities'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$SessionStartedPayloadImplToJson(
  _$SessionStartedPayloadImpl instance,
) => <String, dynamic>{
  'protocol_version': instance.protocolVersion,
  'patient_context': instance.patientContext,
  'server_capabilities': instance.serverCapabilities,
};

_$TranscriptPartialPayloadImpl _$$TranscriptPartialPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$TranscriptPartialPayloadImpl(
  text: json['text'] as String,
  speaker:
      $enumDecodeNullable(_$SpeakerRoleEnumMap, json['speaker']) ??
      SpeakerRole.unknown,
  startMs: (json['start_ms'] as num).toInt(),
  endMs: (json['end_ms'] as num).toInt(),
);

Map<String, dynamic> _$$TranscriptPartialPayloadImplToJson(
  _$TranscriptPartialPayloadImpl instance,
) => <String, dynamic>{
  'text': instance.text,
  'speaker': _$SpeakerRoleEnumMap[instance.speaker]!,
  'start_ms': instance.startMs,
  'end_ms': instance.endMs,
};

const _$SpeakerRoleEnumMap = {
  SpeakerRole.nurse: 'nurse',
  SpeakerRole.patient: 'patient',
  SpeakerRole.surgeon: 'surgeon',
  SpeakerRole.anesthesia: 'anesthesia',
  SpeakerRole.unknown: 'unknown',
};

_$TranscriptFinalPayloadImpl _$$TranscriptFinalPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$TranscriptFinalPayloadImpl(
  transcriptId: json['transcript_id'] as String,
  text: json['text'] as String,
  speaker:
      $enumDecodeNullable(_$SpeakerRoleEnumMap, json['speaker']) ??
      SpeakerRole.unknown,
  startMs: (json['start_ms'] as num).toInt(),
  endMs: (json['end_ms'] as num).toInt(),
  audioChunkIds:
      (json['audio_chunk_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$$TranscriptFinalPayloadImplToJson(
  _$TranscriptFinalPayloadImpl instance,
) => <String, dynamic>{
  'transcript_id': instance.transcriptId,
  'text': instance.text,
  'speaker': _$SpeakerRoleEnumMap[instance.speaker]!,
  'start_ms': instance.startMs,
  'end_ms': instance.endMs,
  'audio_chunk_ids': instance.audioChunkIds,
};

_$EventAckPayloadImpl _$$EventAckPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$EventAckPayloadImpl(
  eventId: json['event_id'] as String,
  status: $enumDecode(_$EventAckStatusEnumMap, json['status']),
);

Map<String, dynamic> _$$EventAckPayloadImplToJson(
  _$EventAckPayloadImpl instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'status': _$EventAckStatusEnumMap[instance.status]!,
};

const _$EventAckStatusEnumMap = {
  EventAckStatus.confirmed: 'confirmed',
  EventAckStatus.rejected: 'rejected',
  EventAckStatus.draftEdited: 'draft_edited',
};

_$SessionEndedPayloadImpl _$$SessionEndedPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$SessionEndedPayloadImpl(
  reason: json['reason'] as String?,
  finalSeq: (json['final_seq'] as num?)?.toInt(),
);

Map<String, dynamic> _$$SessionEndedPayloadImplToJson(
  _$SessionEndedPayloadImpl instance,
) => <String, dynamic>{
  'reason': instance.reason,
  'final_seq': instance.finalSeq,
};
