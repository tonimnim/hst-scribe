package contract

import (
	"encoding/json"
	"time"
)

// MessageType is the WSS envelope type discriminator.
type MessageType string

// MessageType values — Client → Server frames.
const (
	MsgAudioChunk    MessageType = "audio_chunk"
	MsgSessionPause  MessageType = "session_pause"
	MsgSessionResume MessageType = "session_resume"
	MsgSessionEnd    MessageType = "session_end"
	MsgVoiceCommand  MessageType = "voice_command"
	MsgPing          MessageType = "ping"
)

// MessageType values — Server → Client frames.
const (
	MsgSessionStarted    MessageType = "session_started"
	MsgTranscriptPartial MessageType = "transcript_partial"
	MsgTranscriptFinal   MessageType = "transcript_final"
	MsgEventExtracted    MessageType = "event_extracted"
	MsgEventAck          MessageType = "event_ack"
	MsgSessionEnded      MessageType = "session_ended"
	MsgError             MessageType = "error"
	MsgPong              MessageType = "pong"
)

// Envelope is the universal WSS frame, identical for both directions.
// Payload is held as json.RawMessage so callers can decode it into the
// per-type struct using DecodePayload.
type Envelope struct {
	Type      MessageType     `json:"type"`
	SessionID string          `json:"session_id"`
	Seq       uint64          `json:"seq"`
	TS        time.Time       `json:"ts"`
	Payload   json.RawMessage `json:"payload"`
}

// --- Client → Server payloads ---

// AudioFormat enumerates the audio codecs we accept on the wire.
type AudioFormat string

// AudioFormat values matching contract/CONTRACT.md §2.
const (
	AudioFormatPCM16 AudioFormat = "pcm16"
)

// AudioChunkPayload is a streamed audio frame.
type AudioChunkPayload struct {
	ChunkID    string      `json:"chunk_id"`
	AudioB64   string      `json:"audio_b64"`
	SampleRate int         `json:"sample_rate"`
	Format     AudioFormat `json:"format"`
	DurationMS int         `json:"duration_ms"`
}

// VoiceCommand is one of the recognized in-session voice commands.
type VoiceCommand string

// VoiceCommand values matching contract/CONTRACT.md §2.
const (
	VoiceCommandConfirmLast VoiceCommand = "confirm_last"
	VoiceCommandStrikeLast  VoiceCommand = "strike_last"
	VoiceCommandPause       VoiceCommand = "pause"
	VoiceCommandResume      VoiceCommand = "resume"
	VoiceCommandEndSession  VoiceCommand = "end_session"
)

// VoiceCommandPayload is the payload for a voice_command frame.
type VoiceCommandPayload struct {
	Command VoiceCommand `json:"command"`
}

// SessionPausePayload is intentionally empty; reserved for future fields.
type SessionPausePayload struct{}

// SessionResumePayload is intentionally empty; reserved for future fields.
type SessionResumePayload struct{}

// SessionEndPayload is intentionally empty; reserved for future fields.
type SessionEndPayload struct{}

// PingPayload is the keepalive payload (may be empty).
type PingPayload struct {
	Nonce string `json:"nonce,omitempty"`
}

// --- Server → Client payloads ---

// ServerCapabilities advertises optional features the server supports.
type ServerCapabilities struct {
	VoiceCommands bool `json:"voice_commands"`
	Diarization   bool `json:"diarization"`
}

// SessionStartedPayload is the first server frame on any new WSS session.
type SessionStartedPayload struct {
	ProtocolVersion    string             `json:"protocol_version"`
	PatientContext     PatientContext     `json:"patient_context"`
	ServerCapabilities ServerCapabilities `json:"server_capabilities"`
}

// Speaker labels for diarized transcripts.
type Speaker string

// Speaker values matching contract/CONTRACT.md §2.
const (
	SpeakerNurse      Speaker = "nurse"
	SpeakerPatient    Speaker = "patient"
	SpeakerSurgeon    Speaker = "surgeon"
	SpeakerAnesthesia Speaker = "anesthesia"
	SpeakerUnknown    Speaker = "unknown"
)

// TranscriptPartialPayload is an in-flight ASR result.
type TranscriptPartialPayload struct {
	Text    string  `json:"text"`
	Speaker Speaker `json:"speaker"`
	StartMS int64   `json:"start_ms"`
	EndMS   int64   `json:"end_ms"`
}

// TranscriptFinalPayload is a finalized ASR utterance.
type TranscriptFinalPayload struct {
	TranscriptID  string   `json:"transcript_id"`
	Text          string   `json:"text"`
	Speaker       Speaker  `json:"speaker"`
	StartMS       int64    `json:"start_ms"`
	EndMS         int64    `json:"end_ms"`
	AudioChunkIDs []string `json:"audio_chunk_ids"`
}

// EventExtractedPayload mirrors ExtractedEvent — the wire shape produced
// by the extractor. Fields are union-typed by event_type; consumers may
// decode them via DecodeEventFields.
type EventExtractedPayload struct {
	EventID             string          `json:"event_id"`
	EventType           EventType       `json:"event_type"`
	Fields              json.RawMessage `json:"fields"`
	Confidence          float64         `json:"confidence"`
	SourceTranscriptIDs []string        `json:"source_transcript_ids"`
	SourceUtterance     string          `json:"source_utterance"`
	ExtractedAt         time.Time       `json:"extracted_at"`
	EventTime           time.Time       `json:"event_time,omitempty"`
}

// EventAckPayload is the server ack of a client-initiated action.
type EventAckPayload struct {
	EventID string      `json:"event_id"`
	Status  EventStatus `json:"status"`
}

// SessionEndedPayload is sent right before the server closes the socket.
// FinalSeq is the last server-emitted seq the client should expect; used
// by clients to verify no messages were dropped before disconnect.
type SessionEndedPayload struct {
	Reason   string  `json:"reason,omitempty"`
	FinalSeq *uint64 `json:"final_seq,omitempty"`
}

// ErrorPayload mirrors the canonical error envelope so it can be carried
// inside a WSS Envelope payload.
type ErrorPayload struct {
	Code    string         `json:"code"`
	Message string         `json:"message"`
	Details map[string]any `json:"details,omitempty"`
}

// PongPayload is the keepalive response.
type PongPayload struct {
	Nonce string `json:"nonce,omitempty"`
}
