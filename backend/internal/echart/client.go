package echart

import (
	"context"
	"encoding/json"
	"errors"
	"time"
)

// Client is the consumer-side interface to HST eChart. The HTTP
// implementation lives in httpclient.go; tests pass a fake.
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
	GetPatientContext(ctx context.Context, patientID string) (*PatientContext, error)
	PostDraftEvent(ctx context.Context, patientID string, req DraftEventRequest) (*DraftEventResponse, error)
	SignSession(ctx context.Context, patientID string, req SignSessionRequest) (*SignSessionResponse, error)
	ValidateRxNorm(ctx context.Context, code string) (*RxNormEntry, error)
}

// PatientContext mirrors the contract-safe projection returned by eChart.
// Full name, MRN, and DOB are intentionally absent — eChart enforces the
// contract on its side.
type PatientContext struct {
	PatientID           string       `json:"patient_id"`
	DisplayNameInitials string       `json:"display_name_initials"`
	MRNLast4            string       `json:"mrn_last4"`
	Procedure           string       `json:"procedure"`
	CurrentMedications  []Medication `json:"current_medications"`
	Allergies           []Allergy    `json:"allergies"`
	Comorbidities       []string     `json:"comorbidities"`
}

// Medication is a structured medication reference, matching the wire
// shape mock-echart returns.
type Medication struct {
	RxNormCode string `json:"rxnorm_code"`
	Name       string `json:"name"`
	Dose       string `json:"dose,omitempty"`
	Route      string `json:"route,omitempty"`
}

// Allergy is a structured allergy reference.
type Allergy struct {
	Name     string `json:"name"`
	Severity string `json:"severity,omitempty"`
}

// DraftEventRequest is the body of POST /charts/{patient_id}/draft-events.
//
// Fields is held as a map[string]any because the per-event_type field set
// is part of the contract/CONTRACT.md §3 schema — the chart-writer passes
// it through unchanged. SourceUtterance is required by the contract; the
// chart-writer logs treat it as PHI and never emit it.
type DraftEventRequest struct {
	EventType       string         `json:"event_type"`
	Fields          map[string]any `json:"fields"`
	Confidence      float64        `json:"confidence"`
	SourceUtterance string         `json:"source_utterance"`
	ExtractedAt     time.Time      `json:"extracted_at"`
}

// DraftEventResponse is the 201 body returned by mock-echart.
type DraftEventResponse struct {
	ChartEntryID string    `json:"chart_entry_id"`
	Status       string    `json:"status"`
	CreatedAt    time.Time `json:"created_at"`
}

// SignSessionRequest is the body of POST /charts/{patient_id}/sign-session.
type SignSessionRequest struct {
	SessionID string   `json:"session_id"`
	EventIDs  []string `json:"event_ids"`
}

// SignSessionResponse is the 200 body returned by eChart.
type SignSessionResponse struct {
	EventsWritten  int       `json:"events_written"`
	EventsRejected int       `json:"events_rejected"`
	SignedAt       time.Time `json:"signed_at"`
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
	// ErrPatientNotFound is returned by GetPatientContext when eChart has
	// no record for the given patient_id (HTTP 404).
	ErrPatientNotFound = errors.New("echart: patient not found")

	// ErrRxNormNotFound is returned by ValidateRxNorm when the code is
	// not in eChart's bundled vocabulary (HTTP 404).
	ErrRxNormNotFound = errors.New("echart: rxnorm code not found")

	// ErrRetryExhausted is returned by httpClient when every retry
	// attempt failed with a retryable status / network error. The
	// chart-writer routes these to the DLQ.
	ErrRetryExhausted = errors.New("echart: retry attempts exhausted")
)
