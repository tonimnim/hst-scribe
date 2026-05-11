package server_test

import (
	"bytes"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/seed"
	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/server"
	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/store"
)

// fixedClock returns the same instant every call. Used to pin timestamps
// in assertions and to keep the request log deterministic.
func fixedClock(t time.Time) server.Clock {
	return func() time.Time { return t }
}

// sequentialIDGen returns predictable ids id-1, id-2, ... so tests can
// assert exact response bodies.
func sequentialIDGen() server.IDGen {
	var n int64
	return func() (string, error) {
		v := atomic.AddInt64(&n, 1)
		return "id-" + strings.Repeat("0", 0) + itoa(int(v)), nil
	}
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	var b [20]byte
	pos := len(b)
	for n > 0 {
		pos--
		b[pos] = byte('0' + n%10)
		n /= 10
	}
	return string(b[pos:])
}

// testServer assembles a Server with a small synthetic patient set and a
// silenced logger. Returns the chi-mounted httptest server; caller must Close.
func testServer(t *testing.T) (*httptest.Server, *store.Store) {
	t.Helper()

	patients := []seed.Patient{
		{
			PatientID:           "01931e00-0000-7000-8000-000000000001",
			MRN:                 "HST00004821",
			DisplayNameInitials: "J.D.",
			MRNLast4:            "4821",
			FullName:            "Jane Doe",
			DateOfBirth:         "1968-03-14",
			Sex:                 "female",
			Procedure:           "Right knee arthroscopy",
			ASCID:               "01931e00-0000-7000-8000-00000000aaaa",
			CurrentMedications: []seed.Medication{
				{RxNormCode: "26225", Name: "Ondansetron", Dose: "4 mg", Route: "iv"},
			},
			Allergies:     []seed.Allergy{{Name: "Penicillin", Severity: "severe"}},
			Comorbidities: []string{"diabetes_type_2"},
		},
		{
			PatientID:           "01931e00-0000-7000-8000-000000000003",
			MRN:                 "HST00009122",
			DisplayNameInitials: "L.K.",
			MRNLast4:            "9122",
			FullName:            "Linda King",
			DateOfBirth:         "1982-07-25",
			Sex:                 "female",
			Procedure:           "Cataract extraction, left eye",
			ASCID:               "01931e00-0000-7000-8000-00000000aaaa",
		},
	}

	st := store.NewStore()
	logger := slog.New(slog.NewJSONHandler(io.Discard, nil))
	frozen := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)

	s := server.New(patients, st, logger, fixedClock(frozen), sequentialIDGen())
	ts := httptest.NewServer(s.Router())
	t.Cleanup(ts.Close)
	return ts, st
}

func doJSON(t *testing.T, method, url string, body any) *http.Response {
	t.Helper()
	var rdr io.Reader
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			t.Fatalf("marshal request body: %v", err)
		}
		rdr = bytes.NewReader(b)
	}
	req, err := http.NewRequest(method, url, rdr)
	if err != nil {
		t.Fatalf("new request: %v", err)
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("http do: %v", err)
	}
	return resp
}

func decode[T any](t *testing.T, resp *http.Response) T {
	t.Helper()
	defer resp.Body.Close()
	var v T
	if err := json.NewDecoder(resp.Body).Decode(&v); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	return v
}

// --- /healthz -----------------------------------------------------------

func TestHealthz(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	resp := doJSON(t, http.MethodGet, ts.URL+"/healthz", nil)
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	body := decode[map[string]string](t, resp)
	if body["status"] != "ok" {
		t.Errorf("status field = %q, want ok", body["status"])
	}
}

// --- GET /patients/{id}/context -----------------------------------------

func TestGetPatientContext_Success(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	resp := doJSON(t, http.MethodGet,
		ts.URL+"/api/echart/v1/patients/01931e00-0000-7000-8000-000000000001/context", nil)
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	body := decode[map[string]any](t, resp)

	if body["patient_id"] != "01931e00-0000-7000-8000-000000000001" {
		t.Errorf("patient_id = %v", body["patient_id"])
	}
	if body["display_name_initials"] != "J.D." {
		t.Errorf("display_name_initials = %v", body["display_name_initials"])
	}
	if body["mrn_last4"] != "4821" {
		t.Errorf("mrn_last4 = %v", body["mrn_last4"])
	}
	if body["procedure"] != "Right knee arthroscopy" {
		t.Errorf("procedure = %v", body["procedure"])
	}
	// PHI must not leak
	for _, banned := range []string{"full_name", "mrn", "date_of_birth", "sex", "asc_id"} {
		if _, found := body[banned]; found {
			t.Errorf("response leaks PHI field %q", banned)
		}
	}
	// Lists must be present (not null) even when empty for the other patient
	if _, ok := body["current_medications"].([]any); !ok {
		t.Errorf("current_medications = %T, want []any", body["current_medications"])
	}
}

func TestGetPatientContext_EmptyListsSerializedNotNull(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	resp := doJSON(t, http.MethodGet,
		ts.URL+"/api/echart/v1/patients/01931e00-0000-7000-8000-000000000003/context", nil)
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	raw, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("read body: %v", err)
	}
	resp.Body.Close()

	for _, listField := range []string{
		`"current_medications":[]`,
		`"allergies":[]`,
		`"comorbidities":[]`,
	} {
		if !bytes.Contains(raw, []byte(listField)) {
			t.Errorf("body missing %s; got %s", listField, raw)
		}
	}
}

func TestGetPatientContext_NotFound(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	resp := doJSON(t, http.MethodGet,
		ts.URL+"/api/echart/v1/patients/does-not-exist/context", nil)
	if resp.StatusCode != http.StatusNotFound {
		t.Fatalf("status = %d, want 404", resp.StatusCode)
	}
	body := decode[map[string]any](t, resp)
	if body["code"] != "patient_not_found" {
		t.Errorf("code = %v, want patient_not_found", body["code"])
	}
	if _, ok := body["details"].(map[string]any); !ok {
		t.Errorf("details = %T, want object", body["details"])
	}
	if _, ok := body["message"].(string); !ok {
		t.Errorf("message missing or wrong type")
	}
}

// --- POST /charts/{id}/draft-events -------------------------------------

func TestPostDraftEvent_Success(t *testing.T) {
	t.Parallel()
	ts, st := testServer(t)

	reqBody := map[string]any{
		"event_type": "vital_sign",
		"fields": map[string]any{
			"vital_type": "blood_pressure_systolic",
			"value":      130,
			"unit":       "mmHg",
		},
		"confidence":       0.94,
		"source_utterance": "BP one thirty over eighty two",
		"extracted_at":     "2026-05-11T14:32:19.502-04:00",
	}
	resp := doJSON(t, http.MethodPost,
		ts.URL+"/api/echart/v1/charts/01931e00-0000-7000-8000-000000000001/draft-events",
		reqBody)
	if resp.StatusCode != http.StatusCreated {
		t.Fatalf("status = %d, want 201", resp.StatusCode)
	}
	body := decode[map[string]any](t, resp)
	id, _ := body["chart_entry_id"].(string)
	if id == "" {
		t.Fatal("chart_entry_id missing")
	}
	if body["status"] != "draft" {
		t.Errorf("status = %v, want draft", body["status"])
	}
	if _, ok := body["created_at"].(string); !ok {
		t.Errorf("created_at missing")
	}

	stored, ok := st.Get(id)
	if !ok {
		t.Fatal("entry not in store")
	}
	if stored.Status != "draft" {
		t.Errorf("stored status = %v, want draft", stored.Status)
	}
	if stored.EventType != "vital_sign" {
		t.Errorf("stored event_type = %v", stored.EventType)
	}
}

func TestPostDraftEvent_PatientNotFound(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	resp := doJSON(t, http.MethodPost,
		ts.URL+"/api/echart/v1/charts/nope/draft-events",
		map[string]any{"event_type": "note"})
	if resp.StatusCode != http.StatusNotFound {
		t.Fatalf("status = %d, want 404", resp.StatusCode)
	}
	body := decode[map[string]any](t, resp)
	if body["code"] != "patient_not_found" {
		t.Errorf("code = %v", body["code"])
	}
}

func TestPostDraftEvent_InvalidJSON(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	req, err := http.NewRequest(http.MethodPost,
		ts.URL+"/api/echart/v1/charts/01931e00-0000-7000-8000-000000000001/draft-events",
		strings.NewReader(`{not json`))
	if err != nil {
		t.Fatalf("new request: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("http do: %v", err)
	}
	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", resp.StatusCode)
	}
	body := decode[map[string]any](t, resp)
	if body["code"] != "invalid_request" {
		t.Errorf("code = %v", body["code"])
	}
}

func TestPostDraftEvent_RejectsUnknownFields(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	resp := doJSON(t, http.MethodPost,
		ts.URL+"/api/echart/v1/charts/01931e00-0000-7000-8000-000000000001/draft-events",
		map[string]any{
			"event_type":  "note",
			"surprise":    "this field is not in the contract",
			"extracted_at": "2026-05-11T14:32:19.502-04:00",
		})
	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", resp.StatusCode)
	}
}

func TestPostDraftEvent_MissingEventType(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	resp := doJSON(t, http.MethodPost,
		ts.URL+"/api/echart/v1/charts/01931e00-0000-7000-8000-000000000001/draft-events",
		map[string]any{"confidence": 0.5})
	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", resp.StatusCode)
	}
}

// --- POST /charts/{id}/sign-session -------------------------------------

func TestSignSession_PromotesDrafts(t *testing.T) {
	t.Parallel()
	ts, st := testServer(t)

	patientID := "01931e00-0000-7000-8000-000000000001"

	// seed two draft events
	var ids []string
	for i := 0; i < 2; i++ {
		resp := doJSON(t, http.MethodPost,
			ts.URL+"/api/echart/v1/charts/"+patientID+"/draft-events",
			map[string]any{
				"event_type":   "note",
				"confidence":   0.9,
				"extracted_at": "2026-05-11T14:32:19-04:00",
			})
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("seed draft #%d status = %d", i, resp.StatusCode)
		}
		b := decode[map[string]any](t, resp)
		ids = append(ids, b["chart_entry_id"].(string))
	}

	resp := doJSON(t, http.MethodPost,
		ts.URL+"/api/echart/v1/charts/"+patientID+"/sign-session",
		map[string]any{
			"session_id": "01931d80-0000-7000-8000-000000000099",
			"event_ids":  ids,
		})
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	body := decode[map[string]any](t, resp)
	if int(body["events_written"].(float64)) != 2 {
		t.Errorf("events_written = %v, want 2", body["events_written"])
	}
	if int(body["events_rejected"].(float64)) != 0 {
		t.Errorf("events_rejected = %v, want 0", body["events_rejected"])
	}
	if _, ok := body["signed_at"].(string); !ok {
		t.Errorf("signed_at missing or wrong type")
	}

	for _, id := range ids {
		e, ok := st.Get(id)
		if !ok {
			t.Fatalf("entry %s gone from store", id)
		}
		if e.Status != "final" {
			t.Errorf("entry %s status = %v, want final", id, e.Status)
		}
		if e.SignedAt == nil {
			t.Errorf("entry %s signed_at not set", id)
		}
	}
}

func TestSignSession_UnknownEventIDsAreRejected(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	patientID := "01931e00-0000-7000-8000-000000000001"
	resp := doJSON(t, http.MethodPost,
		ts.URL+"/api/echart/v1/charts/"+patientID+"/sign-session",
		map[string]any{
			"session_id": "01931d80-0000-7000-8000-000000000099",
			"event_ids":  []string{"unknown-1", "unknown-2"},
		})
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	body := decode[map[string]any](t, resp)
	if int(body["events_written"].(float64)) != 0 {
		t.Errorf("events_written = %v", body["events_written"])
	}
	if int(body["events_rejected"].(float64)) != 2 {
		t.Errorf("events_rejected = %v", body["events_rejected"])
	}
}

func TestSignSession_PatientNotFound(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	resp := doJSON(t, http.MethodPost,
		ts.URL+"/api/echart/v1/charts/nope/sign-session",
		map[string]any{
			"session_id": "01931d80-0000-7000-8000-000000000099",
			"event_ids":  []string{},
		})
	if resp.StatusCode != http.StatusNotFound {
		t.Fatalf("status = %d, want 404", resp.StatusCode)
	}
}

func TestSignSession_MissingSessionID(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	patientID := "01931e00-0000-7000-8000-000000000001"
	resp := doJSON(t, http.MethodPost,
		ts.URL+"/api/echart/v1/charts/"+patientID+"/sign-session",
		map[string]any{"event_ids": []string{}})
	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", resp.StatusCode)
	}
}

// --- GET /vocabularies/rxnorm/{code} ------------------------------------

func TestRxNorm_Known(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	cases := []struct {
		code string
		name string
	}{
		{"26225", "Ondansetron"},
		{"4337", "Fentanyl"},
		{"6960", "Midazolam"},
		{"7052", "Morphine"},
		{"8782", "Propofol"},
		{"6387", "Lidocaine"},
		{"6130", "Ketamine"},
		{"7806", "Oxygen"},
	}
	for _, tc := range cases {
		tc := tc
		t.Run(tc.code, func(t *testing.T) {
			t.Parallel()
			resp := doJSON(t, http.MethodGet,
				ts.URL+"/api/echart/v1/vocabularies/rxnorm/"+tc.code, nil)
			if resp.StatusCode != http.StatusOK {
				t.Fatalf("status = %d, want 200", resp.StatusCode)
			}
			body := decode[map[string]any](t, resp)
			if body["rxnorm_code"] != tc.code {
				t.Errorf("rxnorm_code = %v, want %s", body["rxnorm_code"], tc.code)
			}
			if body["name"] != tc.name {
				t.Errorf("name = %v, want %s", body["name"], tc.name)
			}
			if body["valid"] != true {
				t.Errorf("valid = %v, want true", body["valid"])
			}
		})
	}
}

func TestRxNorm_Unknown(t *testing.T) {
	t.Parallel()
	ts, _ := testServer(t)

	resp := doJSON(t, http.MethodGet,
		ts.URL+"/api/echart/v1/vocabularies/rxnorm/99999", nil)
	if resp.StatusCode != http.StatusNotFound {
		t.Fatalf("status = %d, want 404", resp.StatusCode)
	}
	body := decode[map[string]any](t, resp)
	if body["code"] != "rxnorm_not_found" {
		t.Errorf("code = %v", body["code"])
	}
}
