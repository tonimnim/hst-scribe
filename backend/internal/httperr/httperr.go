// Package httperr defines the wire-shape HTTP/WSS error envelope and
// provides constructors for every error code listed in
// contract/CONTRACT.md. The wire shape is:
//
//	{ "code": "...", "message": "...", "details": {...} }
//
// Mapping Go errors to HTTP responses lives in WriteJSON; mapping from
// internal sentinel/typed errors to a wire error lives in From.
package httperr

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
)

// Code is the stable wire error code. New codes require a contract change.
type Code string

// Code values listed in contract/CONTRACT.md §2 plus
// not_implemented/bad_request/internal for transport-level concerns.
const (
	CodeAuthInvalid            Code = "auth_invalid"
	CodeAuthForbidden          Code = "auth_forbidden"
	CodeSessionNotFound        Code = "session_not_found"
	CodeSessionExpired         Code = "session_expired"
	CodePatientLocked          Code = "patient_locked"
	CodeAudioFormatUnsupported Code = "audio_format_unsupported"
	CodeChunkOutOfOrder        Code = "chunk_out_of_order"
	CodeRateLimited            Code = "rate_limited"
	CodeExtractorFailed        Code = "extractor_failed"
	CodeNotImplemented         Code = "not_implemented"
	CodeBadRequest             Code = "bad_request"
	CodeInternal               Code = "internal"
)

// Error is the canonical wire envelope used by REST and WSS. It also
// implements the error interface so service code can return it directly.
type Error struct {
	Code    Code           `json:"code"`
	Message string         `json:"message"`
	Details map[string]any `json:"details,omitempty"`

	// httpStatus is the HTTP status used by WriteJSON; not serialized.
	httpStatus int
}

// Error implements the error interface.
func (e *Error) Error() string {
	return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

// HTTPStatus returns the HTTP status WriteJSON will use for this error.
func (e *Error) HTTPStatus() int {
	if e.httpStatus == 0 {
		return http.StatusInternalServerError
	}
	return e.httpStatus
}

// WithDetails returns a copy of e with details set/merged.
func (e *Error) WithDetails(details map[string]any) *Error {
	cp := *e
	if cp.Details == nil {
		cp.Details = make(map[string]any, len(details))
	}
	for k, v := range details {
		cp.Details[k] = v
	}
	return &cp
}

// WriteJSON writes err as the canonical error envelope with the
// appropriate HTTP status. It never panics; if encoding fails it falls
// back to a plain-text 500.
func WriteJSON(w http.ResponseWriter, err *Error) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(err.HTTPStatus())
	if encErr := json.NewEncoder(w).Encode(err); encErr != nil {
		// Last resort: at this point headers are written, so we cannot
		// recover. Best effort fallback to a static body.
		_, _ = w.Write([]byte(`{"code":"internal","message":"failed to encode error"}`))
	}
}

// From maps an arbitrary error to a wire Error. *Error values pass
// through unchanged. Unknown errors become a generic CodeInternal with
// the underlying message hidden — callers should log the original.
func From(err error) *Error {
	if err == nil {
		return nil
	}
	var werr *Error
	if errors.As(err, &werr) {
		return werr
	}
	return Internal("unexpected error")
}

// --- Constructors per CONTRACT.md error code ---

// AuthInvalid is returned when the bearer token is missing, malformed,
// or expired.
func AuthInvalid(msg string) *Error {
	if msg == "" {
		msg = "authentication token is missing or invalid"
	}
	return &Error{Code: CodeAuthInvalid, Message: msg, httpStatus: http.StatusUnauthorized}
}

// AuthForbidden is returned when the token is valid but lacks scope for
// the requested resource.
func AuthForbidden(msg string) *Error {
	if msg == "" {
		msg = "token does not grant access to this resource"
	}
	return &Error{Code: CodeAuthForbidden, Message: msg, httpStatus: http.StatusForbidden}
}

// SessionNotFound is returned when a session_id does not exist.
func SessionNotFound(sessionID string) *Error {
	return &Error{
		Code:       CodeSessionNotFound,
		Message:    "session not found",
		Details:    map[string]any{"session_id": sessionID},
		httpStatus: http.StatusNotFound,
	}
}

// SessionExpired is returned when a session is past expires_at or
// already signed.
func SessionExpired(sessionID string) *Error {
	return &Error{
		Code:       CodeSessionExpired,
		Message:    "session is expired or already signed",
		Details:    map[string]any{"session_id": sessionID},
		httpStatus: http.StatusGone,
	}
}

// PatientLocked is returned when another active session has this patient.
func PatientLocked(patientID, activeSessionID string) *Error {
	return &Error{
		Code:    CodePatientLocked,
		Message: "patient is locked to another active session",
		Details: map[string]any{
			"patient_id":        patientID,
			"active_session_id": activeSessionID,
		},
		httpStatus: http.StatusConflict,
	}
}

// AudioFormatUnsupported is returned when an audio chunk has a bad codec
// or sample rate.
func AudioFormatUnsupported(detail string) *Error {
	return &Error{
		Code:       CodeAudioFormatUnsupported,
		Message:    "audio format not supported",
		Details:    map[string]any{"detail": detail},
		httpStatus: http.StatusUnsupportedMediaType,
	}
}

// ChunkOutOfOrder is returned when seq regresses on the WSS stream.
func ChunkOutOfOrder(expected, got uint64) *Error {
	return &Error{
		Code:       CodeChunkOutOfOrder,
		Message:    "sequence number regressed",
		Details:    map[string]any{"expected": expected, "got": got},
		httpStatus: http.StatusBadRequest,
	}
}

// RateLimited is returned when a tenant or session rate limit is hit.
func RateLimited(scope string) *Error {
	return &Error{
		Code:       CodeRateLimited,
		Message:    "rate limit exceeded",
		Details:    map[string]any{"scope": scope},
		httpStatus: http.StatusTooManyRequests,
	}
}

// ExtractorFailed is returned when the downstream extractor errored in
// a recoverable way.
func ExtractorFailed(reason string) *Error {
	return &Error{
		Code:       CodeExtractorFailed,
		Message:    "extraction failed",
		Details:    map[string]any{"reason": reason},
		httpStatus: http.StatusBadGateway,
	}
}

// NotImplemented marks an endpoint that is not yet wired up.
func NotImplemented(msg string) *Error {
	if msg == "" {
		msg = "not implemented"
	}
	return &Error{Code: CodeNotImplemented, Message: msg, httpStatus: http.StatusNotImplemented}
}

// BadRequest is the generic 400.
func BadRequest(msg string, details map[string]any) *Error {
	if msg == "" {
		msg = "bad request"
	}
	return &Error{Code: CodeBadRequest, Message: msg, Details: details, httpStatus: http.StatusBadRequest}
}

// Internal is the generic 500.
func Internal(msg string) *Error {
	if msg == "" {
		msg = "internal error"
	}
	return &Error{Code: CodeInternal, Message: msg, httpStatus: http.StatusInternalServerError}
}
