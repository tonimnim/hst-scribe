package hst

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/tonimnim/hst-scribe/backend/internal/chart"
	"github.com/tonimnim/hst-scribe/backend/internal/contract"
)

// Client is the consumer-side interface to HST eChart used by the
// chart-writer Writer. It is intentionally narrower than chart.Adapter —
// it carries the patientID/SignSession ergonomics the writer is built
// against. The package-level New(...) constructor returns a chart.Adapter
// that wraps an HTTPClient.
//
// Method semantics:
//
//   - GetPatientContext fetches the locked patient snapshot used by the
//     extractor at session start. Read-only.
//   - PostDraftEvent records one confirmed extraction event as a draft
//     entry on the patient's chart. Idempotency is the caller's
//     responsibility — chart-writer dedupes via the chart_writes table.
//   - SignSession promotes every supplied event_id to a final entry in a
//     single atomic call. Partial success is surfaced via the EventsWritten
//     / EventsRejected counts on the response, not via an error.
//   - ValidateRxNorm resolves an RxNorm code against the eChart-bundled
//     vocabulary. Returns ErrRxNormNotFound for an unknown code.
type Client interface {
	GetPatientContext(ctx context.Context, patientID string) (*contract.PatientContext, error)
	PostDraftEvent(ctx context.Context, patientID string, req chart.DraftEventRequest) (*chart.DraftEventResponse, error)
	SignSession(ctx context.Context, patientID string, req chart.SignSessionRequest) (*chart.SignSessionResponse, error)
	ValidateRxNorm(ctx context.Context, code string) (*RxNormEntry, error)
}

// RxNormEntry is the projection returned by /vocabularies/rxnorm/{code}.
// The exact field set varies by vocabulary; we keep it open and pass the
// raw bytes through for callers that want to read more than name.
type RxNormEntry struct {
	RxNormCode string          `json:"rxnorm_code"`
	Name       string          `json:"name"`
	Raw        json.RawMessage `json:"-"`
}

// ErrorResponse is the canonical {code,message,details} envelope eChart
// returns on a 4xx/5xx. Carried inside APIError.
type ErrorResponse struct {
	Code    string         `json:"code"`
	Message string         `json:"message"`
	Details map[string]any `json:"details,omitempty"`
}

// APIError is returned by httpClient when eChart responds with a non-2xx
// status. Status is the HTTP status code; Body is the parsed envelope
// when the response was JSON-decodable, otherwise nil.
type APIError struct {
	Status int
	Body   *ErrorResponse
}

// Error implements error.
func (e *APIError) Error() string {
	if e.Body != nil && e.Body.Message != "" {
		return e.Body.Message
	}
	return "echart api error"
}

// Retryable reports whether an HTTP status code merits a retry attempt.
// 408 (timeout), 429 (rate limit), and 5xx are retried; 4xx other than
// 408/429 are terminal — the caller's request is wrong, retrying won't
// fix it.
func (e *APIError) Retryable() bool {
	switch e.Status {
	case 408, 429:
		return true
	}
	return e.Status >= 500
}

// Sentinel errors. Callers can use errors.Is to discriminate.
var (
	// ErrPatientNotFound is returned by GetPatientContext when eChart
	// has no record for the given patient_id (HTTP 404). Maps to
	// chart.ErrNotFound at the adapter boundary.
	ErrPatientNotFound = errors.New("hst: patient not found")

	// ErrRxNormNotFound is returned by ValidateRxNorm when the code
	// is not in eChart's bundled vocabulary (HTTP 404).
	ErrRxNormNotFound = errors.New("hst: rxnorm code not found")

	// ErrRetryExhausted is returned by httpClient when every retry
	// attempt failed with a retryable status / network error. The
	// chart-writer routes these to the DLQ. Maps to chart.ErrTransport
	// at the adapter boundary.
	ErrRetryExhausted = errors.New("hst: retry attempts exhausted")
)
