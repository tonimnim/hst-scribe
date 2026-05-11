// Package chart is the EHR-system abstraction for HST Scribe. Every
// concrete EHR backend — HST eChart, FHIR, Epic, vendor-specific — is
// implemented as a chart.Adapter under internal/chart/adapters/. The
// chart-writer and gateway services depend on this package and never on
// a concrete adapter.
//
// Wave 2 ships HST as the only adapter; FHIR is the second to land. The
// Registry abstraction selects the adapter for a given asc_id so the
// fleet can run mixed-EHR.
package chart

import (
	"context"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
)

// Adapter is the EHR-system abstraction. Every concrete EHR (HST, FHIR,
// Epic, etc.) implements this. The chart-writer and gateway services
// depend on this interface and never on a concrete adapter.
//
// Concurrency: implementations MUST be safe for use from multiple
// goroutines. The chart-writer fans out per-message handler goroutines
// that share a single adapter instance.
//
// Error semantics:
//
//   - Adapter methods return the package-typed errors defined in
//     errors.go (ErrNotFound, ErrValidation, ErrTransport, ErrPermanent)
//     where the caller needs to discriminate. Wrapped errors retain the
//     sentinel via errors.Is.
//   - ErrRetryExhausted (an adapter-side concern) is wrapped to
//     ErrTransport from the caller's perspective; retry policy is the
//     adapter's responsibility.
type Adapter interface {
	// Name returns a stable identifier for this adapter
	// implementation ("hst", "fhir", ...). Used in metrics, logs,
	// and registry routing — never on the wire.
	Name() string

	// GetPatientContext fetches the locked patient snapshot used at
	// session start. Read-only.
	GetPatientContext(ctx context.Context, patientID string) (*contract.PatientContext, error)

	// PostDraftEvent records one confirmed extraction event as a
	// draft entry on the patient's chart. Idempotency is the
	// caller's responsibility — chart-writer dedupes via the
	// chart_writes ledger.
	PostDraftEvent(ctx context.Context, patientID string, req DraftEventRequest) (*DraftEventResponse, error)

	// SignSession promotes every supplied event id to a final entry
	// in a single atomic call. Partial success is surfaced via the
	// EventsWritten / EventsRejected counts on the response, not
	// via an error.
	SignSession(ctx context.Context, req SignSessionRequest) (*SignSessionResponse, error)

	// ValidateRxNorm resolves an RxNorm code against the EHR's
	// bundled vocabulary. Returns (canonical, true, nil) on a hit,
	// ("", false, nil) on a miss, and (_, _, err) on transport
	// failure. The boolean (not an error) signals miss so callers
	// don't have to errors.Is on the hot path.
	ValidateRxNorm(ctx context.Context, code string) (canonical string, ok bool, err error)
}

// DraftEventRequest is the EHR-agnostic body for a draft-event write.
//
// Fields is the per-event_type schema defined in contract/CONTRACT.md §3
// — the chart-writer passes it through unchanged. SourceUtterance is
// PHI; adapters MUST NOT log it.
type DraftEventRequest struct {
	EventType       string         `json:"event_type"`
	Fields          map[string]any `json:"fields"`
	Confidence      float64        `json:"confidence"`
	SourceUtterance string         `json:"source_utterance"`
	ExtractedAt     time.Time      `json:"extracted_at"`
}

// DraftEventResponse is the EHR-agnostic response after a draft write.
//
// ChartEntryID is the EHR-side identifier — opaque to chart-writer.
// HST emits a UUIDv7; FHIR will emit a resource URL; both fit a string.
type DraftEventResponse struct {
	ChartEntryID string    `json:"chart_entry_id"`
	Status       string    `json:"status"`
	CreatedAt    time.Time `json:"created_at"`
}

// SignSessionRequest is the EHR-agnostic sign payload.
//
// PatientID is carried in the struct (rather than as a separate method
// parameter) so the adapter has everything it needs in one value and the
// chart-writer's call site stays uniform across adapters. It is
// json:"-" because some EHRs route the patient via URL path, not body.
type SignSessionRequest struct {
	PatientID string   `json:"-"`
	SessionID string   `json:"session_id"`
	EventIDs  []string `json:"event_ids"`
}

// SignSessionResponse is the EHR-agnostic sign response.
type SignSessionResponse struct {
	EventsWritten  int       `json:"events_written"`
	EventsRejected int       `json:"events_rejected"`
	SignedAt       time.Time `json:"signed_at"`
}
