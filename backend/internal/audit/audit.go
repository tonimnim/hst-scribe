// Package audit implements the append-only audit log: a NATS JetStream
// consumer that persists clinical lifecycle events into Postgres, plus
// an HTTP query API for compliance lookups.
//
// Tamper-evidence comes from three layers stacked on top of each other:
//
//  1. Every write is INSERT ... ON CONFLICT (id) DO NOTHING. There is no
//     UPDATE or DELETE statement in this package anywhere.
//  2. Event ids are UUIDv7 minted by the publisher, so replays after a
//     NATS redelivery dedupe naturally on the primary key.
//  3. The Postgres role used by this service has UPDATE/DELETE revoked on
//     audit_log at deploy time (see migrations/0006_audit_log.up.sql).
//
// PHI never enters the audit row. Payload may carry source ids (chunk_id,
// transcript_id, event_id) but free-text and patient-identifying fields
// are rejected at the subscriber boundary using the obs redacted-key set.
package audit

import (
	"context"
	"errors"
	"time"
)

// Action is the closed enumeration of audit actions recognized by the
// service. Anything outside this set is rejected by the subscriber to
// prevent producers from polluting the compliance trail with ad-hoc
// strings.
type Action string

// Action values. Keep aligned with backend/PRD.md FR28.
const (
	ActionSessionCreated       Action = "session_created"
	ActionSessionEnded         Action = "session_ended"
	ActionSessionSigned        Action = "session_signed"
	ActionEventExtracted       Action = "event_extracted"
	ActionEventConfirmed       Action = "event_confirmed"
	ActionEventRejected        Action = "event_rejected"
	ActionEventEdited          Action = "event_edited"
	ActionChunkReceived        Action = "chunk_received"
	ActionTranscriptFinal      Action = "transcript_final"
	ActionChartWriteAttempted  Action = "chart_write_attempted"
	ActionChartWriteSucceeded  Action = "chart_write_succeeded"
	ActionChartWriteFailed     Action = "chart_write_failed"
)

// IsValid reports whether a is one of the recognized Action values.
func (a Action) IsValid() bool {
	switch a {
	case ActionSessionCreated,
		ActionSessionEnded,
		ActionSessionSigned,
		ActionEventExtracted,
		ActionEventConfirmed,
		ActionEventRejected,
		ActionEventEdited,
		ActionChunkReceived,
		ActionTranscriptFinal,
		ActionChartWriteAttempted,
		ActionChartWriteSucceeded,
		ActionChartWriteFailed:
		return true
	}
	return false
}

// Event is the canonical audit record persisted to Postgres and returned
// by the query API. Snake_case JSON tags match the wire envelope shape
// described in cmd/audit/main.go header comment.
//
// Optional fields use pointers (SessionID, ActorUserID, TargetID,
// TargetType) so we can distinguish "explicitly null" from "field absent"
// during decode and so the SQL layer can map nil to a real SQL NULL.
type Event struct {
	ID          string         `json:"id"`
	SessionID   *string        `json:"session_id,omitempty"`
	ActorUserID *string        `json:"actor_user_id,omitempty"`
	ASCID       string         `json:"asc_id"`
	Action      Action         `json:"action"`
	TargetID    *string        `json:"target_id,omitempty"`
	TargetType  *string        `json:"target_type,omitempty"`
	Payload     map[string]any `json:"payload,omitempty"`
	TS          time.Time      `json:"ts"`
}

// Repository is the persistence boundary. Defined on the consumer side
// per CONVENTIONS — the subscriber and HTTP server depend on this
// interface, the Postgres implementation in repository.go satisfies it,
// and tests can substitute a fake.
type Repository interface {
	// Append persists e idempotently. Duplicate id is not an error.
	Append(ctx context.Context, e *Event) error

	// ListBySession returns every event for sessionID ordered by ts ASC.
	// Compliance lookups for one session are bounded by session length
	// (minutes), so no pagination is needed here.
	ListBySession(ctx context.Context, sessionID string) ([]Event, error)

	// ListByUser returns up to limit events for actorUserID between from
	// and to, ordered by ts ASC. cursor is an opaque value previously
	// returned by this method (or empty for the first page). The returned
	// nextCursor is empty when no more pages remain.
	ListByUser(ctx context.Context, q UserQuery) ([]Event, string, error)
}

// UserQuery groups the inputs to Repository.ListByUser. Keeping it as a
// struct lets the HTTP layer evolve filters (e.g. action filter) without
// rewriting every implementation signature.
type UserQuery struct {
	ActorUserID string
	From        time.Time
	To          time.Time
	Limit       int
	Cursor      string
}

// ErrInvalidEvent is returned by validators (subscriber, repository) when
// an envelope fails the basic shape contract. Wrapped errors carry the
// original cause; the sentinel exists so the subscriber can distinguish
// "drop and warn-log" cases from infrastructure failures.
var ErrInvalidEvent = errors.New("invalid audit event")

// ErrInvalidCursor is returned by the repository when a paging cursor
// cannot be decoded. The HTTP layer maps this to a 400.
var ErrInvalidCursor = errors.New("invalid pagination cursor")
