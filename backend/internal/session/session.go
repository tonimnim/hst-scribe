// Package session owns the session lifecycle, patient lock, and
// idempotent creation semantics described in CONTRACT.md and
// PRD.md FR7–FR10.
//
// The package layers are:
//
//   - Session / Status / WorkflowType — domain types serialized over the
//     internal HTTP API between the gateway and this service.
//   - Repository — Postgres-backed persistence (see repository.go). The
//     interface lives here so consumers depend on the contract, not the
//     concrete pgx-backed impl.
//   - Service — domain logic enforcing patient lock, idempotency,
//     state transitions, and audit emission (see service.go).
//   - Server — HTTP handlers exposed under /internal/v1/sessions (see
//     server.go). The gateway is the sole intended caller.
package session

import (
	"context"
	"errors"
	"time"
)

// Status is the lifecycle state of a session. The set mirrors the
// session_status enum in migrations/0001_sessions.up.sql.
type Status string

// Status values. New values require a migration to extend the enum.
const (
	StatusActive  Status = "active"
	StatusPaused  Status = "paused"
	StatusEnded   Status = "ended"
	StatusSigned  Status = "signed"
	StatusExpired Status = "expired"
)

// IsTerminal reports whether s is a final state — a session in a terminal
// state never transitions again and no longer holds the patient lock.
func (s Status) IsTerminal() bool {
	switch s {
	case StatusEnded, StatusSigned, StatusExpired:
		return true
	default:
		return false
	}
}

// Valid reports whether s is one of the known enum values.
func (s Status) Valid() bool {
	switch s {
	case StatusActive, StatusPaused, StatusEnded, StatusSigned, StatusExpired:
		return true
	default:
		return false
	}
}

// WorkflowType identifies the clinical context the session captures.
// Mirrors the workflow_type enum.
type WorkflowType string

// WorkflowType values. MVP supports `pacu` only; preop and intraop are
// reserved for Phases 1 and 2 respectively. The session manager accepts
// all three so the contract is forward-compatible; product gating happens
// at the gateway.
const (
	WorkflowPACU    WorkflowType = "pacu"
	WorkflowPreop   WorkflowType = "preop"
	WorkflowIntraop WorkflowType = "intraop"
)

// Valid reports whether w is one of the known enum values.
func (w WorkflowType) Valid() bool {
	switch w {
	case WorkflowPACU, WorkflowPreop, WorkflowIntraop:
		return true
	default:
		return false
	}
}

// Session is the persistence + wire representation of a session row.
// JSON tags match the internal API exposed by server.go; the gateway
// composes the public CreateSessionResponse from this plus patient context.
type Session struct {
	ID             string       `json:"session_id"`
	ASCID          string       `json:"asc_id"`
	PatientID      string       `json:"patient_id"`
	UserID         string       `json:"user_id"`
	WorkflowType   WorkflowType `json:"workflow_type"`
	Status         Status       `json:"status"`
	Reason         string       `json:"reason,omitempty"`
	StartedAt      time.Time    `json:"started_at"`
	LastActivityAt time.Time    `json:"last_activity_at"`
	EndedAt        *time.Time   `json:"ended_at,omitempty"`
	SignedAt       *time.Time   `json:"signed_at,omitempty"`
	ExpiresAt      time.Time    `json:"expires_at"`
	SignedByUserID string       `json:"signed_by_user_id,omitempty"`
}

// CreateArgs is the input to Repository.Create / Service.CreateSession.
// All fields are required. IDs are validated as UUIDs upstream.
type CreateArgs struct {
	ID           string
	ASCID        string
	PatientID    string
	UserID       string
	WorkflowType WorkflowType
	StartedAt    time.Time
	ExpiresAt    time.Time
}

// Repository is the persistence contract for Session rows. The Postgres
// implementation lives in repository.go; tests may supply a fake.
//
// Methods that mutate state return the post-mutation row so callers can
// emit the canonical event payload without a second round-trip.
type Repository interface {
	// Create inserts a new session row. If a non-terminal session already
	// exists for (asc_id, patient_id), Create returns the existing row
	// along with ErrPatientLocked — the service layer decides whether
	// this is an idempotent hit (same user) or a real conflict (different
	// user).
	Create(ctx context.Context, args CreateArgs) (*Session, error)

	// Get returns the session by id, or ErrNotFound.
	Get(ctx context.Context, id string) (*Session, error)

	// UpdateStatus moves the session to a new status, optionally setting a
	// reason. Implementations enforce legal transitions (see ValidTransition).
	// Returns the post-update row.
	UpdateStatus(ctx context.Context, id string, status Status, reason string) (*Session, error)

	// Sign marks the session signed by user signedByUserID at signedAt.
	// Returns the post-update row.
	Sign(ctx context.Context, id string, signedByUserID string, signedAt time.Time) (*Session, error)

	// ListActiveByPatient returns any non-terminal sessions for the given
	// (asc, patient). Used by Service for the pre-flight lock check. In
	// practice the result has 0 or 1 elements due to the unique partial
	// index; we return a slice to keep the interface honest about the
	// contractual cardinality.
	ListActiveByPatient(ctx context.Context, ascID, patientID string) ([]*Session, error)

	// ExpireIdle marks every non-terminal session whose last_activity_at
	// is older than threshold as 'expired'. Returns the list of newly
	// expired sessions for audit emission.
	ExpireIdle(ctx context.Context, threshold time.Time) ([]*Session, error)
}

// --- Errors ---

// ErrNotFound is returned by Repository.Get when no row matches.
var ErrNotFound = errors.New("session not found")

// ErrPatientLocked is returned by Repository.Create when another
// non-terminal session holds the patient lock. The accompanying *Session
// (when wrapped with PatientLockError) carries the locking session id.
var ErrPatientLocked = errors.New("patient is locked to another active session")

// ErrInvalidTransition signals that a state transition is not legal.
var ErrInvalidTransition = errors.New("invalid session state transition")

// PatientLockError carries the locking session alongside ErrPatientLocked
// so callers can either return 409 or treat as idempotent.
type PatientLockError struct {
	Existing *Session
}

// Error implements the error interface.
func (e *PatientLockError) Error() string { return ErrPatientLocked.Error() }

// Unwrap allows errors.Is(err, ErrPatientLocked).
func (e *PatientLockError) Unwrap() error { return ErrPatientLocked }

// ValidTransition reports whether moving from -> to is allowed. The
// table mirrors the lifecycle described in PRD.md FR7–FR10:
//
//	active  -> paused | ended | signed | expired
//	paused  -> active | ended | expired
//	ended   -> signed              (post-end sign-off)
//	signed  -> (terminal)
//	expired -> (terminal)
func ValidTransition(from, to Status) bool {
	switch from {
	case StatusActive:
		return to == StatusPaused || to == StatusEnded || to == StatusSigned || to == StatusExpired
	case StatusPaused:
		return to == StatusActive || to == StatusEnded || to == StatusExpired
	case StatusEnded:
		return to == StatusSigned
	case StatusSigned, StatusExpired:
		return false
	default:
		return false
	}
}
