package chart

import (
	"context"
	"encoding/json"
	"time"
)

// NATS subjects this package's consumers bind to. Hard-coded because
// they are part of the inter-service contract: gateway publishes confirms
// / rejections, session-manager publishes sign signals, and any adapter's
// writer subscribes to all three.
const (
	// SubjectExtractedConfirmed is the NATS subject pattern published
	// by the gateway when the nurse confirms a draft event. Tail
	// token is the session_id.
	SubjectExtractedConfirmed = "extracted.confirmed.>"

	// SubjectExtractedRejected is the rejection counterpart.
	SubjectExtractedRejected = "extracted.rejected.>"

	// SubjectChartSign is the NATS subject pattern published by the
	// session-manager when the nurse signs a session. Tail token is
	// the session_id.
	SubjectChartSign = "chart.sign.>"

	// SubjectDeadLetter is where the chart-writer routes events after
	// retry exhaustion or unrecoverable errors. A separate service
	// (or the replay worker) reads from here.
	SubjectDeadLetter = "chart.dead-letter"

	// StreamName is the JetStream stream every chart-writer durable
	// consumer binds to. The stream config must include the three
	// input subject patterns above.
	StreamName = "CHART_INPUT"

	// DurableName is the durable consumer name shared across input
	// subjects. Re-using one durable keeps replay semantics simple
	// and matches the "subscriptions are durable" PRD requirement.
	DurableName = "chart-writer"
)

// ConfirmedEvent is the NATS payload on extracted.confirmed.<session_id>.
//
// This is the contract between gateway/extraction-worker (publisher)
// and chart-writer (subscriber). Producers MUST emit this exact shape;
// additive fields are tolerated (json decoder ignores unknowns), but
// removing or renaming a field is a breaking change that requires
// coordinated rollout.
type ConfirmedEvent struct {
	EventID             string          `json:"event_id"`
	SessionID           string          `json:"session_id"`
	PatientID           string          `json:"patient_id"`
	ASCID               string          `json:"asc_id"`
	ActorUserID         string          `json:"actor_user_id,omitempty"`
	EventType           string          `json:"event_type"`
	Fields              json.RawMessage `json:"fields"`
	Confidence          float64         `json:"confidence"`
	SourceUtterance     string          `json:"source_utterance"`
	SourceTranscriptIDs []string        `json:"source_transcript_ids,omitempty"`
	ExtractedAt         time.Time       `json:"extracted_at"`
	EventTime           time.Time       `json:"event_time,omitempty"`
}

// RejectedEvent is the payload on extracted.rejected.<session_id>. The
// chart-writer records it in the ledger but never POSTs to the EHR.
type RejectedEvent struct {
	EventID     string    `json:"event_id"`
	SessionID   string    `json:"session_id"`
	PatientID   string    `json:"patient_id"`
	ASCID       string    `json:"asc_id"`
	ActorUserID string    `json:"actor_user_id,omitempty"`
	Reason      string    `json:"reason,omitempty"`
	RejectedAt  time.Time `json:"rejected_at"`
}

// SignEvent is the payload on chart.sign.<session_id>. Published by the
// session-manager after a successful POST /sessions/{id}/sign so the
// chart-writer can atomically promote all 'written' drafts.
type SignEvent struct {
	SessionID   string    `json:"session_id"`
	PatientID   string    `json:"patient_id"`
	ASCID       string    `json:"asc_id"`
	ActorUserID string    `json:"actor_user_id,omitempty"`
	SignedAt    time.Time `json:"signed_at"`
}

// AuditEvent is the on-wire shape published to audit.events.{asc_id}.
// Matches session.AuditEvent — duplicated here so this package does not
// import internal/session. The audit subscriber validates Action against
// internal/audit.Action.IsValid; chart-writer emits chart_write_attempted
// / chart_write_succeeded / chart_write_failed.
type AuditEvent struct {
	ID          string         `json:"id"`
	SessionID   string         `json:"session_id"`
	ActorUserID string         `json:"actor_user_id,omitempty"`
	ASCID       string         `json:"asc_id"`
	Action      string         `json:"action"`
	TargetID    string         `json:"target_id,omitempty"`
	TargetType  string         `json:"target_type,omitempty"`
	Payload     map[string]any `json:"payload"`
	TS          time.Time      `json:"ts"`
}

// IDGen mints UUIDv7 ids. Injected so tests can pin values.
type IDGen func() string

// AuditPublisher emits AuditEvent values to the audit subject. Concrete
// adapters' writers accept an implementation; tests substitute a fake.
type AuditPublisher interface {
	Publish(ctx context.Context, ascID string, evt AuditEvent) error
}

// DeadLetterPublisher emits raw bytes to chart.dead-letter. Separated
// from AuditPublisher so each implementation can keep its own subject
// and serialization concerns.
type DeadLetterPublisher interface {
	Publish(ctx context.Context, body []byte) error
}
