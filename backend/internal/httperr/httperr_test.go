package httperr

import (
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestWriteJSON_ShapeAndStatus(t *testing.T) {
	t.Parallel()

	rec := httptest.NewRecorder()
	WriteJSON(rec, SessionNotFound("01931d80"))

	if got := rec.Code; got != http.StatusNotFound {
		t.Errorf("status = %d, want %d", got, http.StatusNotFound)
	}

	var body struct {
		Code    string         `json:"code"`
		Message string         `json:"message"`
		Details map[string]any `json:"details"`
	}
	if err := json.NewDecoder(rec.Body).Decode(&body); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if body.Code != "session_not_found" {
		t.Errorf("code = %q", body.Code)
	}
	if body.Details["session_id"] != "01931d80" {
		t.Errorf("details.session_id missing: %#v", body.Details)
	}
}

func TestFrom_WrappedError(t *testing.T) {
	t.Parallel()

	wrapped := errors.Join(errors.New("ctx"), AuthInvalid(""))
	got := From(wrapped)
	if got.Code != CodeAuthInvalid {
		t.Errorf("From did not unwrap Error: %v", got.Code)
	}
}

func TestFrom_UnknownErrorBecomesInternal(t *testing.T) {
	t.Parallel()

	got := From(errors.New("anything"))
	if got.Code != CodeInternal {
		t.Errorf("From(plain) = %v, want internal", got.Code)
	}
}

func TestErrorInterface(t *testing.T) {
	t.Parallel()

	e := PatientLocked("p1", "s1")
	if got := e.Error(); got == "" {
		t.Error("Error() empty")
	}
}
