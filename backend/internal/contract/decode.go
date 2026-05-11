package contract

import (
	"encoding/json"
	"fmt"
)

// DecodePayload decodes the envelope's Payload into the per-type struct
// matching env.Type. The returned any holds a value (not pointer) for
// the appropriate payload struct. Callers may type-switch on it.
//
// Unknown message types return an error rather than nil — the caller
// must decide whether to drop or close on unknown frames.
func DecodePayload(env *Envelope) (any, error) {
	switch env.Type {
	// Client → Server
	case MsgAudioChunk:
		return decodeAs[AudioChunkPayload](env.Payload, "audio_chunk")
	case MsgSessionPause:
		return decodeAs[SessionPausePayload](env.Payload, "session_pause")
	case MsgSessionResume:
		return decodeAs[SessionResumePayload](env.Payload, "session_resume")
	case MsgSessionEnd:
		return decodeAs[SessionEndPayload](env.Payload, "session_end")
	case MsgVoiceCommand:
		return decodeAs[VoiceCommandPayload](env.Payload, "voice_command")
	case MsgPing:
		return decodeAs[PingPayload](env.Payload, "ping")
	// Server → Client
	case MsgSessionStarted:
		return decodeAs[SessionStartedPayload](env.Payload, "session_started")
	case MsgTranscriptPartial:
		return decodeAs[TranscriptPartialPayload](env.Payload, "transcript_partial")
	case MsgTranscriptFinal:
		return decodeAs[TranscriptFinalPayload](env.Payload, "transcript_final")
	case MsgEventExtracted:
		return decodeAs[EventExtractedPayload](env.Payload, "event_extracted")
	case MsgEventAck:
		return decodeAs[EventAckPayload](env.Payload, "event_ack")
	case MsgSessionEnded:
		return decodeAs[SessionEndedPayload](env.Payload, "session_ended")
	case MsgError:
		return decodeAs[ErrorPayload](env.Payload, "error")
	case MsgPong:
		return decodeAs[PongPayload](env.Payload, "pong")
	default:
		return nil, fmt.Errorf("unknown message type %q", env.Type)
	}
}

func decodeAs[T any](raw json.RawMessage, name string) (T, error) {
	var zero T
	if len(raw) == 0 {
		return zero, nil
	}
	var v T
	if err := json.Unmarshal(raw, &v); err != nil {
		return zero, fmt.Errorf("decoding %s payload: %w", name, err)
	}
	return v, nil
}
