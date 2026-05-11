// Package httperr writes the standard {code, message, details} error envelope
// defined in contract/CONTRACT.md.
package httperr

import (
	"encoding/json"
	"log/slog"
	"net/http"
)

// Envelope is the on-the-wire error shape. Details is always non-nil on output
// so clients can `details.foo`-index without a nil guard.
type Envelope struct {
	Code    string         `json:"code"`
	Message string         `json:"message"`
	Details map[string]any `json:"details"`
}

// Write emits the error envelope at the given HTTP status. If details is nil,
// an empty object is sent so the contract shape is preserved.
//
// If JSON encoding fails (should be impossible for this shape), we log and let
// the client see a truncated response — better than panicking the goroutine.
func Write(w http.ResponseWriter, status int, code, message string, details map[string]any) {
	if details == nil {
		details = map[string]any{}
	}
	body := Envelope{Code: code, Message: message, Details: details}
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(body); err != nil {
		slog.Error("encoding error envelope", "err", err, "code", code)
	}
}
