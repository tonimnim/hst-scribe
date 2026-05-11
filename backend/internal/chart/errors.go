package chart

import "errors"

// Adapter-level sentinel errors. Concrete adapters wrap these when they
// surface conditions to callers via errors.Is. Callers MUST discriminate
// on these, not on adapter-specific sentinels.
//
// Discrimination matrix:
//
//   - ErrNotFound    — the requested resource does not exist (HTTP 404,
//     FHIR ResourceNotFound, etc.). Caller decides
//     whether this is fatal or expected.
//   - ErrValidation  — the request was malformed or rejected by the EHR
//     on schema grounds (HTTP 400/422). Not retryable.
//   - ErrTransport   — network, timeout, 5xx, retry exhaustion. The
//     adapter has already exhausted its internal retry
//     budget; caller should DLQ or escalate.
//   - ErrPermanent   — terminal failure that is neither validation nor
//     transport (e.g., adapter mis-configuration). Not
//     retryable.
var (
	ErrNotFound   = errors.New("chart: resource not found")
	ErrValidation = errors.New("chart: request rejected by ehr")
	ErrTransport  = errors.New("chart: transport failure")
	ErrPermanent  = errors.New("chart: permanent failure")
)
