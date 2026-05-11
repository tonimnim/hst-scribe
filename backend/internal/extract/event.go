package extract

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
)

// ExtractedEvent is the in-pipeline shape: the wire ExtractedEvent
// plus a small amount of bookkeeping (session id, draft status,
// needs_review flag) that the wire schema does not carry but every
// downstream consumer needs.
//
// We deliberately do not duplicate contract.ExtractedEvent — the wire
// shape IS the domain here. Status / NeedsReview live on the row in
// Postgres and are surfaced to the UI via separate channels.
type ExtractedEvent struct {
	contract.ExtractedEvent

	SessionID   string      `json:"-"`
	Status      EventStatus `json:"-"`
	NeedsReview bool        `json:"-"`
}

// EventStatus mirrors the Postgres `event_status` enum from
// migrations/0004_extracted_events.up.sql.
type EventStatus string

// EventStatus values.
const (
	EventStatusDraft     EventStatus = "draft"
	EventStatusConfirmed EventStatus = "confirmed"
	EventStatusRejected  EventStatus = "rejected"
	EventStatusSigned    EventStatus = "signed"
	EventStatusEdited    EventStatus = "edited"
)

// FieldsMap decodes the raw fields object into a map[string]any. Used
// by dedupe (canonical match) and validator (RxNorm lookup, sanity
// checks) — both need property-level access without committing to a
// specific typed shape.
func (e *ExtractedEvent) FieldsMap() (map[string]any, error) {
	if len(e.Fields) == 0 {
		return map[string]any{}, nil
	}
	m := map[string]any{}
	if err := json.Unmarshal(e.Fields, &m); err != nil {
		return nil, fmt.Errorf("decoding fields: %w", err)
	}
	return m, nil
}

// SetFields re-marshals an updated fields map back into e.Fields.
// Returns an error if the map contains non-serializable values.
func (e *ExtractedEvent) SetFields(m map[string]any) error {
	raw, err := json.Marshal(m)
	if err != nil {
		return fmt.Errorf("marshaling fields: %w", err)
	}
	e.Fields = raw
	return nil
}

// CloneEvent returns a deep-ish copy of e — independent SourceTranscriptIDs
// slice and Fields bytes — so dedupe / validator transformations
// cannot accidentally mutate a shared upstream value.
func CloneEvent(e ExtractedEvent) ExtractedEvent {
	cp := e
	if len(e.Fields) > 0 {
		fcp := make(json.RawMessage, len(e.Fields))
		copy(fcp, e.Fields)
		cp.Fields = fcp
	}
	if len(e.SourceTranscriptIDs) > 0 {
		ids := make([]string, len(e.SourceTranscriptIDs))
		copy(ids, e.SourceTranscriptIDs)
		cp.SourceTranscriptIDs = ids
	}
	return cp
}

// EnsureTimestamps fills ExtractedAt and EventTime defaults if unset.
// EventTime defaults to ExtractedAt because for live transcripts the
// clinical action time IS the extraction time absent an override.
func EnsureTimestamps(e *ExtractedEvent, now time.Time) {
	if e.ExtractedAt.IsZero() {
		e.ExtractedAt = now
	}
	if e.EventTime.IsZero() {
		e.EventTime = e.ExtractedAt
	}
}
