package session

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"
)

// newTestServer builds a Server backed by the in-memory fake repo + pub
// and mounts it on a fresh chi router. internalToken is left empty so
// tests don't need to set the header.
func newTestServer(t *testing.T, now time.Time) (*Server, *fakeRepo, *fakePub, http.Handler) {
	t.Helper()
	svc, repo, pub := newTestService(t, now)
	srv, err := NewServer(svc, quietLogger(), "")
	if err != nil {
		t.Fatalf("NewServer: %v", err)
	}
	r := chi.NewRouter()
	srv.Mount(r)
	return srv, repo, pub, r
}

func doJSON(t *testing.T, h http.Handler, method, path string, body any) *httptest.ResponseRecorder {
	t.Helper()
	var rdr *bytes.Buffer
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			t.Fatalf("marshal: %v", err)
		}
		rdr = bytes.NewBuffer(b)
	} else {
		rdr = bytes.NewBuffer(nil)
	}
	req := httptest.NewRequest(method, path, rdr)
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func TestServer_Health(t *testing.T) {
	t.Parallel()
	_, _, _, h := newTestServer(t, time.Now())
	rec := doJSON(t, h, http.MethodGet, "/healthz", nil)
	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want 200", rec.Code)
	}
}

func TestServer_CreateThenLockThenEndThenCreate(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	_, _, _, h := newTestServer(t, now)

	// 1. Create
	rec := doJSON(t, h, http.MethodPost, "/internal/v1/sessions/", map[string]string{
		"asc_id":        ascA,
		"patient_id":    patient1,
		"user_id":       userAlice,
		"workflow_type": "pacu",
	})
	if rec.Code != http.StatusCreated {
		t.Fatalf("create status = %d, body = %s", rec.Code, rec.Body.String())
	}
	var created Session
	if err := json.Unmarshal(rec.Body.Bytes(), &created); err != nil {
		t.Fatalf("decode create: %v", err)
	}
	if created.Status != StatusActive {
		t.Errorf("status = %s, want active", created.Status)
	}

	// 2. Duplicate by another user -> 409 patient_locked
	rec = doJSON(t, h, http.MethodPost, "/internal/v1/sessions/", map[string]string{
		"asc_id":        ascA,
		"patient_id":    patient1,
		"user_id":       userBob,
		"workflow_type": "pacu",
	})
	if rec.Code != http.StatusConflict {
		t.Fatalf("dup status = %d, want 409. body=%s", rec.Code, rec.Body.String())
	}
	var errBody struct {
		Code    string         `json:"code"`
		Details map[string]any `json:"details"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &errBody); err != nil {
		t.Fatalf("decode err: %v", err)
	}
	if errBody.Code != "patient_locked" {
		t.Errorf("err code = %s, want patient_locked", errBody.Code)
	}
	if got, _ := errBody.Details["active_session_id"].(string); got != created.ID {
		t.Errorf("details.active_session_id = %q, want %q", got, created.ID)
	}

	// 3. Same user retry -> 201 with same id (idempotent)
	rec = doJSON(t, h, http.MethodPost, "/internal/v1/sessions/", map[string]string{
		"asc_id":        ascA,
		"patient_id":    patient1,
		"user_id":       userAlice,
		"workflow_type": "pacu",
	})
	if rec.Code != http.StatusCreated {
		t.Fatalf("idempotent status = %d, body=%s", rec.Code, rec.Body.String())
	}
	var same Session
	_ = json.Unmarshal(rec.Body.Bytes(), &same)
	if same.ID != created.ID {
		t.Errorf("idempotent id = %s, want %s", same.ID, created.ID)
	}

	// 4. End the session
	rec = doJSON(t, h, http.MethodPost, "/internal/v1/sessions/"+created.ID+"/end", map[string]string{
		"user_id": userAlice,
		"reason":  "client_requested",
	})
	if rec.Code != http.StatusOK {
		t.Fatalf("end status = %d, body=%s", rec.Code, rec.Body.String())
	}
	var ended Session
	_ = json.Unmarshal(rec.Body.Bytes(), &ended)
	if ended.Status != StatusEnded {
		t.Errorf("status = %s, want ended", ended.Status)
	}

	// 5. New session for the same patient now succeeds.
	rec = doJSON(t, h, http.MethodPost, "/internal/v1/sessions/", map[string]string{
		"asc_id":        ascA,
		"patient_id":    patient1,
		"user_id":       userBob,
		"workflow_type": "pacu",
	})
	if rec.Code != http.StatusCreated {
		t.Fatalf("post-end status = %d, body=%s", rec.Code, rec.Body.String())
	}
	var fresh Session
	_ = json.Unmarshal(rec.Body.Bytes(), &fresh)
	if fresh.ID == created.ID {
		t.Errorf("post-end id = %s, want new", fresh.ID)
	}
}

func TestServer_Get(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, _, _, h := newTestServer(t, now)
	created, err := svc.svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU,
	})
	if err != nil {
		t.Fatalf("create: %v", err)
	}
	rec := doJSON(t, h, http.MethodGet, "/internal/v1/sessions/"+created.ID, nil)
	if rec.Code != http.StatusOK {
		t.Fatalf("get status = %d", rec.Code)
	}
}

func TestServer_BadRequest(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	_, _, _, h := newTestServer(t, now)

	cases := []struct {
		name string
		body map[string]string
	}{
		{"missing asc_id", map[string]string{"patient_id": patient1, "user_id": userAlice, "workflow_type": "pacu"}},
		{"bad uuid", map[string]string{"asc_id": "not-a-uuid", "patient_id": patient1, "user_id": userAlice, "workflow_type": "pacu"}},
		{"bad workflow", map[string]string{"asc_id": ascA, "patient_id": patient1, "user_id": userAlice, "workflow_type": "garbage"}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			rec := doJSON(t, h, http.MethodPost, "/internal/v1/sessions/", tc.body)
			if rec.Code != http.StatusBadRequest {
				t.Errorf("status = %d, want 400. body=%s", rec.Code, strings.TrimSpace(rec.Body.String()))
			}
		})
	}
}

func TestServer_InternalToken(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, _, _ := newTestService(t, now)
	srv, _ := NewServer(svc, quietLogger(), "secret")
	r := chi.NewRouter()
	srv.Mount(r)

	// Health is not protected.
	rec := httptest.NewRecorder()
	r.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/healthz", nil))
	if rec.Code != http.StatusOK {
		t.Errorf("health = %d", rec.Code)
	}

	// Internal endpoint without token -> 401.
	rec = httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/internal/v1/sessions/01931e00-0000-7000-8000-000000000001", nil)
	r.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("no token = %d, want 401", rec.Code)
	}

	// With wrong token -> 401.
	rec = httptest.NewRecorder()
	req = httptest.NewRequest(http.MethodGet, "/internal/v1/sessions/01931e00-0000-7000-8000-000000000001", nil)
	req.Header.Set("X-Internal-Token", "wrong")
	r.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("wrong token = %d, want 401", rec.Code)
	}
}
