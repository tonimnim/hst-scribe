// Package wss implements the mock ASR's WebSocket protocol: envelope shape,
// payload types, and the per-connection session loop. Frames are wire-faithful
// to contract/CONTRACT.md §2.
package wss

import (
	"encoding/json"
	"time"
)

// Message types — see CONTRACT.md §2.
const (
	// Client → Server.
	TypeAudioChunk     = "audio_chunk"
	TypeSessionPause   = "session_pause"
	TypeSessionResume  = "session_resume"
	TypeSessionEnd     = "session_end"
	TypeVoiceCommand   = "voice_command"
	TypePing           = "ping"

	// Server → Client.
	TypeSessionStarted    = "session_started"
	TypeTranscriptPartial = "transcript_partial"
	TypeTranscriptFinal   = "transcript_final"
	TypeEventExtracted    = "event_extracted"
	TypeEventAck          = "event_ack"
	TypeSessionEnded      = "session_ended"
	TypeError             = "error"
	TypePong              = "pong"
)

// SpeakerNurse is the only speaker value the mock ever emits. Real ASR will
// use the full enum (nurse | patient | surgeon | anesthesia | unknown).
const SpeakerNurse = "nurse"

// Envelope is the outer shape carried by every WSS frame (both directions).
// payload is decoded lazily — handlers switch on Type and unmarshal as needed.
type Envelope struct {
	Type      string          `json:"type"`
	SessionID string          `json:"session_id"`
	Seq       int64           `json:"seq"`
	TS        string          `json:"ts"`
	Payload   json.RawMessage `json:"payload,omitempty"`
}

// PatientContext mirrors the contract's empty/filled shape. Mock-eChart fills
// this in the real flow; mock-asr leaves it zero-valued so the JSON renders
// as `{}` (omitempty on every field).
type PatientContext struct {
	PatientID           string            `json:"patient_id,omitempty"`
	DisplayNameInitials string            `json:"display_name_initials,omitempty"`
	MRNLast4            string            `json:"mrn_last4,omitempty"`
	Procedure           string            `json:"procedure,omitempty"`
	CurrentMedications  []Medication      `json:"current_medications,omitempty"`
	Allergies           []Allergy         `json:"allergies,omitempty"`
	Comorbidities       []string          `json:"comorbidities,omitempty"`
}

// Medication is the patient_context.current_medications shape.
type Medication struct {
	RxNormCode string `json:"rxnorm_code"`
	Name       string `json:"name"`
	Dose       string `json:"dose"`
	Route      string `json:"route"`
}

// Allergy is the patient_context.allergies shape.
type Allergy struct {
	Name     string `json:"name"`
	Severity string `json:"severity"`
}

// ServerCapabilities advertises which features this server supports.
type ServerCapabilities struct {
	VoiceCommands bool `json:"voice_commands"`
	Diarization   bool `json:"diarization"`
}

// SessionStartedPayload — server → client first frame after upgrade.
type SessionStartedPayload struct {
	ProtocolVersion    string             `json:"protocol_version"`
	PatientContext     PatientContext     `json:"patient_context"`
	ServerCapabilities ServerCapabilities `json:"server_capabilities"`
}

// TranscriptPartialPayload — in-flight ASR text.
type TranscriptPartialPayload struct {
	Text    string `json:"text"`
	Speaker string `json:"speaker"`
	StartMS int64  `json:"start_ms"`
	EndMS   int64  `json:"end_ms"`
}

// TranscriptFinalPayload — ASR-finalized utterance segment.
type TranscriptFinalPayload struct {
	TranscriptID   string   `json:"transcript_id"`
	Text           string   `json:"text"`
	Speaker        string   `json:"speaker"`
	StartMS        int64    `json:"start_ms"`
	EndMS          int64    `json:"end_ms"`
	AudioChunkIDs  []string `json:"audio_chunk_ids"`
}

// SessionEndedPayload — server confirms session close. Both fields optional.
type SessionEndedPayload struct {
	Reason   string `json:"reason,omitempty"`
	FinalSeq int64  `json:"final_seq,omitempty"`
}

// ErrorPayload — the standard error envelope used everywhere in the contract.
type ErrorPayload struct {
	Code    string                 `json:"code"`
	Message string                 `json:"message"`
	Details map[string]interface{} `json:"details,omitempty"`
}

// rfc3339 returns the canonical RFC3339-with-timezone timestamp string the
// contract requires. Nanosecond precision so two adjacent frames sort.
func rfc3339(t time.Time) string {
	return t.Format("2006-01-02T15:04:05.000Z07:00")
}
