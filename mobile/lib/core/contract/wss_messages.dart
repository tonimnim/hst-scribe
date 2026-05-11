import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/contract/extracted_event.dart';
import 'package:hst_scribe/core/contract/patient_context.dart';
import 'package:hst_scribe/core/contract/wire_error.dart';

part 'wss_messages.freezed.dart';
part 'wss_messages.g.dart';

/// `type` value on every WSS message per CONTRACT.md §2.
enum WssMessageType {
  // client -> server
  @JsonValue('audio_chunk')
  audioChunk,
  @JsonValue('session_pause')
  sessionPause,
  @JsonValue('session_resume')
  sessionResume,
  @JsonValue('session_end')
  sessionEnd,
  @JsonValue('voice_command')
  voiceCommand,
  @JsonValue('ping')
  ping,

  // server -> client
  @JsonValue('session_started')
  sessionStarted,
  @JsonValue('transcript_partial')
  transcriptPartial,
  @JsonValue('transcript_final')
  transcriptFinal,
  @JsonValue('event_extracted')
  eventExtracted,
  @JsonValue('event_ack')
  eventAck,
  @JsonValue('session_ended')
  sessionEnded,
  @JsonValue('error')
  error,
  @JsonValue('pong')
  pong,
}

extension WssMessageTypeX on WssMessageType {
  String get wireValue {
    switch (this) {
      case WssMessageType.audioChunk:
        return 'audio_chunk';
      case WssMessageType.sessionPause:
        return 'session_pause';
      case WssMessageType.sessionResume:
        return 'session_resume';
      case WssMessageType.sessionEnd:
        return 'session_end';
      case WssMessageType.voiceCommand:
        return 'voice_command';
      case WssMessageType.ping:
        return 'ping';
      case WssMessageType.sessionStarted:
        return 'session_started';
      case WssMessageType.transcriptPartial:
        return 'transcript_partial';
      case WssMessageType.transcriptFinal:
        return 'transcript_final';
      case WssMessageType.eventExtracted:
        return 'event_extracted';
      case WssMessageType.eventAck:
        return 'event_ack';
      case WssMessageType.sessionEnded:
        return 'session_ended';
      case WssMessageType.error:
        return 'error';
      case WssMessageType.pong:
        return 'pong';
    }
  }

  static WssMessageType? fromWire(String? raw) {
    switch (raw) {
      case 'audio_chunk':
        return WssMessageType.audioChunk;
      case 'session_pause':
        return WssMessageType.sessionPause;
      case 'session_resume':
        return WssMessageType.sessionResume;
      case 'session_end':
        return WssMessageType.sessionEnd;
      case 'voice_command':
        return WssMessageType.voiceCommand;
      case 'ping':
        return WssMessageType.ping;
      case 'session_started':
        return WssMessageType.sessionStarted;
      case 'transcript_partial':
        return WssMessageType.transcriptPartial;
      case 'transcript_final':
        return WssMessageType.transcriptFinal;
      case 'event_extracted':
        return WssMessageType.eventExtracted;
      case 'event_ack':
        return WssMessageType.eventAck;
      case 'session_ended':
        return WssMessageType.sessionEnded;
      case 'error':
        return WssMessageType.error;
      case 'pong':
        return WssMessageType.pong;
      default:
        return null;
    }
  }
}

enum SpeakerRole {
  @JsonValue('nurse')
  nurse,
  @JsonValue('patient')
  patient,
  @JsonValue('surgeon')
  surgeon,
  @JsonValue('anesthesia')
  anesthesia,
  @JsonValue('unknown')
  unknown,
}

enum VoiceCommand {
  @JsonValue('confirm_last')
  confirmLast,
  @JsonValue('strike_last')
  strikeLast,
  @JsonValue('pause')
  pause,
  @JsonValue('resume')
  resume,
  @JsonValue('end_session')
  endSession,
}

enum EventAckStatus {
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('rejected')
  rejected,
  @JsonValue('draft_edited')
  draftEdited,
}

// ---------- Client -> Server payloads ----------

@freezed
class AudioChunkPayload with _$AudioChunkPayload {
  const factory AudioChunkPayload({
    @JsonKey(name: 'chunk_id') required String chunkId,

    /// Base-64 of one 250ms frame of 16kHz mono PCM16.
    @JsonKey(name: 'audio_b64') required String audioB64,
    @JsonKey(name: 'sample_rate') @Default(16000) int sampleRate,
    @Default('pcm16') String format,
    @JsonKey(name: 'duration_ms') @Default(250) int durationMs,
  }) = _AudioChunkPayload;

  factory AudioChunkPayload.fromJson(Map<String, Object?> json) =>
      _$AudioChunkPayloadFromJson(json);
}

@freezed
class VoiceCommandPayload with _$VoiceCommandPayload {
  const factory VoiceCommandPayload({required VoiceCommand command}) =
      _VoiceCommandPayload;

  factory VoiceCommandPayload.fromJson(Map<String, Object?> json) =>
      _$VoiceCommandPayloadFromJson(json);
}

// ---------- Server -> Client payloads ----------

@freezed
class ServerCapabilities with _$ServerCapabilities {
  const factory ServerCapabilities({
    @JsonKey(name: 'voice_commands') @Default(false) bool voiceCommands,
    @Default(false) bool diarization,
  }) = _ServerCapabilities;

  factory ServerCapabilities.fromJson(Map<String, Object?> json) =>
      _$ServerCapabilitiesFromJson(json);
}

@freezed
class SessionStartedPayload with _$SessionStartedPayload {
  const factory SessionStartedPayload({
    @JsonKey(name: 'protocol_version') required String protocolVersion,
    @JsonKey(name: 'patient_context') required PatientContext patientContext,
    @JsonKey(name: 'server_capabilities')
    required ServerCapabilities serverCapabilities,
  }) = _SessionStartedPayload;

  factory SessionStartedPayload.fromJson(Map<String, Object?> json) =>
      _$SessionStartedPayloadFromJson(json);
}

@freezed
class TranscriptPartialPayload with _$TranscriptPartialPayload {
  const factory TranscriptPartialPayload({
    required String text,
    @Default(SpeakerRole.unknown) SpeakerRole speaker,
    @JsonKey(name: 'start_ms') required int startMs,
    @JsonKey(name: 'end_ms') required int endMs,
  }) = _TranscriptPartialPayload;

  factory TranscriptPartialPayload.fromJson(Map<String, Object?> json) =>
      _$TranscriptPartialPayloadFromJson(json);
}

@freezed
class TranscriptFinalPayload with _$TranscriptFinalPayload {
  const factory TranscriptFinalPayload({
    @JsonKey(name: 'transcript_id') required String transcriptId,
    required String text,
    @Default(SpeakerRole.unknown) SpeakerRole speaker,
    @JsonKey(name: 'start_ms') required int startMs,
    @JsonKey(name: 'end_ms') required int endMs,
    @JsonKey(name: 'audio_chunk_ids')
    @Default(<String>[])
    List<String> audioChunkIds,
  }) = _TranscriptFinalPayload;

  factory TranscriptFinalPayload.fromJson(Map<String, Object?> json) =>
      _$TranscriptFinalPayloadFromJson(json);
}

/// `event_extracted` payload wraps the contract's [ExtractedEvent].
/// Discrimination on `event_type` happens inside [ExtractedEvent.fromJson]
/// (freezed-generated using `unionKey: 'event_type'`).
@immutable
class EventExtractedPayload {
  const EventExtractedPayload({required this.event});

  factory EventExtractedPayload.fromJson(Map<String, Object?> json) {
    return EventExtractedPayload(event: ExtractedEvent.fromJson(json));
  }

  final ExtractedEvent event;

  Map<String, Object?> toJson() => event.toContractJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventExtractedPayload && other.event == event;

  @override
  int get hashCode => event.hashCode;
}

@freezed
class EventAckPayload with _$EventAckPayload {
  const factory EventAckPayload({
    @JsonKey(name: 'event_id') required String eventId,
    required EventAckStatus status,
  }) = _EventAckPayload;

  factory EventAckPayload.fromJson(Map<String, Object?> json) =>
      _$EventAckPayloadFromJson(json);
}

@freezed
class SessionEndedPayload with _$SessionEndedPayload {
  const factory SessionEndedPayload({
    @JsonKey(name: 'reason') String? reason,
    @JsonKey(name: 'final_seq') int? finalSeq,
  }) = _SessionEndedPayload;

  factory SessionEndedPayload.fromJson(Map<String, Object?> json) =>
      _$SessionEndedPayloadFromJson(json);
}

/// Sealed union of every payload shape we receive or send.
/// `WssEnvelope.parsedPayload` produces one of these, or `unknown` for
/// forwards-compatibility (new server message types must not crash old clients).
@freezed
sealed class WssPayload with _$WssPayload {
  const factory WssPayload.audioChunk(AudioChunkPayload payload) =
      AudioChunkWssPayload;
  const factory WssPayload.voiceCommand(VoiceCommandPayload payload) =
      VoiceCommandWssPayload;
  const factory WssPayload.sessionStarted(SessionStartedPayload payload) =
      SessionStartedWssPayload;
  const factory WssPayload.transcriptPartial(TranscriptPartialPayload payload) =
      TranscriptPartialWssPayload;
  const factory WssPayload.transcriptFinal(TranscriptFinalPayload payload) =
      TranscriptFinalWssPayload;
  const factory WssPayload.eventExtracted(EventExtractedPayload payload) =
      EventExtractedWssPayload;
  const factory WssPayload.eventAck(EventAckPayload payload) =
      EventAckWssPayload;
  const factory WssPayload.sessionEnded(SessionEndedPayload payload) =
      SessionEndedWssPayload;
  const factory WssPayload.error(WireError payload) = ErrorWssPayload;

  /// Marker variants — no body fields.
  const factory WssPayload.sessionPause() = SessionPauseWssPayload;
  const factory WssPayload.sessionResume() = SessionResumeWssPayload;
  const factory WssPayload.sessionEnd() = SessionEndWssPayload;
  const factory WssPayload.ping() = PingWssPayload;
  const factory WssPayload.pong() = PongWssPayload;

  /// Forwards-compat: server adds a new `type`; keep the raw JSON so a
  /// future agent can map it without bumping the protocol.
  const factory WssPayload.unknown(String type, Map<String, Object?> raw) =
      UnknownWssPayload;
}
