package echart

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync/atomic"
	"testing"
	"time"
)

// newTestLogger returns a quiet slog.Logger suitable for tests.
func newTestLogger() *slog.Logger {
	return slog.New(slog.NewTextHandler(io.Discard, &slog.HandlerOptions{Level: slog.LevelError}))
}

// newTestClient returns an HTTPClient wired to srv with retry disabled
// and zero-duration backoff so tests don't block.
func newTestClient(t *testing.T, srv *httptest.Server, maxAttempts int) *HTTPClient {
	t.Helper()
	c := NewHTTPClient(HTTPClientConfig{
		BaseURL:           srv.URL,
		ServiceToken:      "test-token",
		PerAttemptTimeout: 2 * time.Second,
		ConnectTimeout:    1 * time.Second,
		MaxAttempts:       maxAttempts,
		Backoff:           func(int) time.Duration { return 0 },
	}, newTestLogger())
	// Replace sleep with a no-op so retry doesn't pause.
	c.sleep = func(context.Context, time.Duration) error { return nil }
	return c
}

// --- GetPatientContext ---

func TestHTTPClient_GetPatientContext_OK(t *testing.T) {
	t.Parallel()

	wantPID := "01931d7e-1234-7000-8000-000000000001"
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if got, want := r.URL.Path, "/api/echart/v1/patients/"+wantPID+"/context"; got != want {
			t.Errorf("path = %q, want %q", got, want)
		}
		if got := r.Header.Get("Authorization"); got != "Bearer test-token" {
			t.Errorf("auth header = %q", got)
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(PatientContext{
			PatientID:           wantPID,
			DisplayNameInitials: "J.D.",
			MRNLast4:            "4821",
			Procedure:           "Knee arthroscopy",
			CurrentMedications:  []Medication{{RxNormCode: "26225", Name: "Ondansetron"}},
			Allergies:           []Allergy{{Name: "Penicillin", Severity: "severe"}},
			Comorbidities:       []string{"diabetes_type_2"},
		})
	}))
	defer srv.Close()

	c := newTestClient(t, srv, 5)
	got, err := c.GetPatientContext(context.Background(), wantPID)
	if err != nil {
		t.Fatalf("GetPatientContext: %v", err)
	}
	if got.PatientID != wantPID || got.MRNLast4 != "4821" {
		t.Errorf("unexpected context: %#v", got)
	}
}

func TestHTTPClient_GetPatientContext_NotFound(t *testing.T) {
	t.Parallel()

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusNotFound)
		_ = json.NewEncoder(w).Encode(ErrorResponse{Code: "patient_not_found", Message: "nope"})
	}))
	defer srv.Close()

	c := newTestClient(t, srv, 5)
	_, err := c.GetPatientContext(context.Background(), "missing")
	if !errors.Is(err, ErrPatientNotFound) {
		t.Fatalf("err = %v, want ErrPatientNotFound", err)
	}
}

// --- PostDraftEvent ---

func TestHTTPClient_PostDraftEvent_OK(t *testing.T) {
	t.Parallel()

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			t.Errorf("method = %s", r.Method)
		}
		var req DraftEventRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Fatalf("decode: %v", err)
		}
		if req.EventType != "vital_sign" {
			t.Errorf("event_type = %q", req.EventType)
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		_ = json.NewEncoder(w).Encode(DraftEventResponse{
			ChartEntryID: "01931d83-aaaa-7000-8000-000000000001",
			Status:       "draft",
			CreatedAt:    time.Now().UTC(),
		})
	}))
	defer srv.Close()

	c := newTestClient(t, srv, 5)
	resp, err := c.PostDraftEvent(context.Background(), "pid", DraftEventRequest{
		EventType:       "vital_sign",
		Fields:          map[string]any{"vital_type": "heart_rate", "value": 72},
		Confidence:      0.94,
		SourceUtterance: "HR 72",
		ExtractedAt:     time.Now(),
	})
	if err != nil {
		t.Fatalf("PostDraftEvent: %v", err)
	}
	if resp.ChartEntryID == "" {
		t.Errorf("missing chart_entry_id")
	}
}

func TestHTTPClient_PostDraftEvent_RetryThenSucceed(t *testing.T) {
	t.Parallel()

	var attempts int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		n := atomic.AddInt32(&attempts, 1)
		if n < 3 {
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		_ = json.NewEncoder(w).Encode(DraftEventResponse{
			ChartEntryID: "ok",
			Status:       "draft",
			CreatedAt:    time.Now().UTC(),
		})
	}))
	defer srv.Close()

	c := newTestClient(t, srv, 5)
	_, err := c.PostDraftEvent(context.Background(), "pid", DraftEventRequest{EventType: "note"})
	if err != nil {
		t.Fatalf("PostDraftEvent: %v", err)
	}
	if got := atomic.LoadInt32(&attempts); got != 3 {
		t.Errorf("attempts = %d, want 3", got)
	}
}

func TestHTTPClient_PostDraftEvent_RetryExhausted(t *testing.T) {
	t.Parallel()

	var attempts int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		atomic.AddInt32(&attempts, 1)
		w.WriteHeader(http.StatusBadGateway)
	}))
	defer srv.Close()

	c := newTestClient(t, srv, 5)
	_, err := c.PostDraftEvent(context.Background(), "pid", DraftEventRequest{EventType: "note"})
	if !errors.Is(err, ErrRetryExhausted) {
		t.Fatalf("err = %v, want ErrRetryExhausted", err)
	}
	if got := atomic.LoadInt32(&attempts); got != 5 {
		t.Errorf("attempts = %d, want 5", got)
	}
}

func TestHTTPClient_PostDraftEvent_4xxDoesNotRetry(t *testing.T) {
	t.Parallel()

	var attempts int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		atomic.AddInt32(&attempts, 1)
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(w).Encode(ErrorResponse{Code: "invalid_request", Message: "missing event_type"})
	}))
	defer srv.Close()

	c := newTestClient(t, srv, 5)
	_, err := c.PostDraftEvent(context.Background(), "pid", DraftEventRequest{})
	var apiErr *APIError
	if !errors.As(err, &apiErr) {
		t.Fatalf("err = %v, want *APIError", err)
	}
	if apiErr.Status != http.StatusBadRequest {
		t.Errorf("status = %d", apiErr.Status)
	}
	if got := atomic.LoadInt32(&attempts); got != 1 {
		t.Errorf("attempts = %d, want 1 (no retry)", got)
	}
}

// --- SignSession ---

func TestHTTPClient_SignSession_OK(t *testing.T) {
	t.Parallel()

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !strings.HasSuffix(r.URL.Path, "/sign-session") {
			t.Errorf("path = %q", r.URL.Path)
		}
		var req SignSessionRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			t.Fatalf("decode: %v", err)
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(SignSessionResponse{
			EventsWritten:  len(req.EventIDs),
			EventsRejected: 0,
			SignedAt:       time.Now().UTC(),
		})
	}))
	defer srv.Close()

	c := newTestClient(t, srv, 5)
	resp, err := c.SignSession(context.Background(), "pid", SignSessionRequest{
		SessionID: "sess",
		EventIDs:  []string{"e1", "e2"},
	})
	if err != nil {
		t.Fatalf("SignSession: %v", err)
	}
	if resp.EventsWritten != 2 {
		t.Errorf("events_written = %d", resp.EventsWritten)
	}
}

// --- ValidateRxNorm ---

func TestHTTPClient_ValidateRxNorm_OK(t *testing.T) {
	t.Parallel()

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !strings.HasSuffix(r.URL.Path, "/rxnorm/26225") {
			t.Errorf("path = %q", r.URL.Path)
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = fmt.Fprintf(w, `{"rxnorm_code":"26225","name":"Ondansetron","class":"antiemetic"}`)
	}))
	defer srv.Close()

	c := newTestClient(t, srv, 5)
	entry, err := c.ValidateRxNorm(context.Background(), "26225")
	if err != nil {
		t.Fatalf("ValidateRxNorm: %v", err)
	}
	if entry.Name != "Ondansetron" {
		t.Errorf("name = %q", entry.Name)
	}
	if len(entry.Raw) == 0 {
		t.Errorf("Raw is empty")
	}
}

func TestHTTPClient_ValidateRxNorm_NotFound(t *testing.T) {
	t.Parallel()

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNotFound)
	}))
	defer srv.Close()

	c := newTestClient(t, srv, 5)
	_, err := c.ValidateRxNorm(context.Background(), "00000")
	if !errors.Is(err, ErrRxNormNotFound) {
		t.Fatalf("err = %v, want ErrRxNormNotFound", err)
	}
}

// --- backoff schedule ---

func TestDefaultBackoff_Schedule(t *testing.T) {
	t.Parallel()

	want := []time.Duration{
		250 * time.Millisecond,
		500 * time.Millisecond,
		1 * time.Second,
		2 * time.Second,
		5 * time.Second,
	}
	for i, w := range want {
		if got := defaultBackoff(i + 1); got != w {
			t.Errorf("defaultBackoff(%d) = %v, want %v", i+1, got, w)
		}
	}
	// Out of range clamps to last value.
	if got := defaultBackoff(99); got != 5*time.Second {
		t.Errorf("defaultBackoff(99) = %v", got)
	}
}
