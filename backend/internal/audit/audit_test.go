package audit

import (
	"encoding/json"
	"strings"
	"testing"
	"time"
)

func TestAction_IsValid(t *testing.T) {
	t.Parallel()

	cases := []struct {
		in   Action
		want bool
	}{
		{ActionSessionCreated, true},
		{ActionSessionSigned, true},
		{ActionEventConfirmed, true},
		{ActionChartWriteFailed, true},
		{Action(""), false},
		{Action("rm_rf"), false},
		{Action("session_DELETED"), false},
	}
	for _, c := range cases {
		c := c
		t.Run(string(c.in), func(t *testing.T) {
			t.Parallel()
			if got := c.in.IsValid(); got != c.want {
				t.Errorf("%q IsValid = %v, want %v", c.in, got, c.want)
			}
		})
	}
}

func TestDecodeEnvelope_HappyPath(t *testing.T) {
	t.Parallel()

	body := []byte(`{
		"id":            "01931d80-aaaa-7bbb-cccc-000000000001",
		"session_id":    "01931d80-aaaa-7bbb-cccc-000000000002",
		"actor_user_id": "01931d80-aaaa-7bbb-cccc-000000000003",
		"asc_id":        "01931d80-aaaa-7bbb-cccc-000000000004",
		"action":        "session_created",
		"target_id":     "01931d80-aaaa-7bbb-cccc-000000000005",
		"target_type":   "session",
		"payload":       {"workflow_type": "pacu"},
		"ts":            "2026-05-11T14:32:18.123-04:00"
	}`)
	e, err := decodeEnvelope(body)
	if err != nil {
		t.Fatalf("decodeEnvelope: %v", err)
	}
	if e.ID == "" || e.ASCID == "" || e.Action != ActionSessionCreated {
		t.Errorf("decoded fields off: %#v", e)
	}
	if e.Payload["workflow_type"] != "pacu" {
		t.Errorf("payload not decoded: %#v", e.Payload)
	}
}

func TestDecodeEnvelope_Rejects(t *testing.T) {
	t.Parallel()

	cases := map[string]string{
		"empty body":     ``,
		"missing id":     `{"asc_id":"a","action":"session_created","ts":"2026-05-11T14:32:18Z"}`,
		"missing asc_id": `{"id":"x","action":"session_created","ts":"2026-05-11T14:32:18Z"}`,
		"missing ts":     `{"id":"x","asc_id":"a","action":"session_created"}`,
		"unknown action": `{"id":"x","asc_id":"a","action":"obliterate","ts":"2026-05-11T14:32:18Z"}`,
		"invalid json":   `{not json`,
	}
	for name, body := range cases {
		body := body
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			if _, err := decodeEnvelope([]byte(body)); err == nil {
				t.Errorf("expected error for %s", name)
			}
		})
	}
}

func TestContainsPHIKey(t *testing.T) {
	t.Parallel()

	cases := map[string]struct {
		payload map[string]any
		wantKey string
		wantHit bool
	}{
		"clean":           {map[string]any{"workflow_type": "pacu"}, "", false},
		"top-level mrn":   {map[string]any{"mrn": "1234"}, "mrn", true},
		"nested name":     {map[string]any{"patient": map[string]any{"patient_name": "Jane"}}, "patient_name", true},
		"transcript text": {map[string]any{"transcript": "BP 130 over 82"}, "transcript", true},
		"list of names": {map[string]any{
			"events": []any{
				map[string]any{"event_id": "ok"},
				map[string]any{"full_name": "Jane Doe"},
			},
		}, "full_name", true},
		"nil payload": {nil, "", false},
	}
	for name, c := range cases {
		c := c
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			got, hit := containsPHIKey(c.payload)
			if hit != c.wantHit {
				t.Errorf("hit = %v, want %v", hit, c.wantHit)
			}
			if got != c.wantKey {
				t.Errorf("key = %q, want %q", got, c.wantKey)
			}
		})
	}
}

func TestCursor_RoundTrip(t *testing.T) {
	t.Parallel()

	ts := time.Date(2026, 5, 11, 14, 32, 18, 123_000_000, time.UTC)
	id := "01931d80-aaaa-7bbb-cccc-000000000001"
	c := encodeCursor(ts, id)
	if c == "" {
		t.Fatal("empty cursor")
	}
	gotTS, gotID, err := decodeCursor(c)
	if err != nil {
		t.Fatalf("decodeCursor: %v", err)
	}
	if !gotTS.Equal(ts) || gotID != id {
		t.Errorf("round-trip mismatch: got %v/%s want %v/%s", gotTS, gotID, ts, id)
	}
}

func TestCursor_Invalid(t *testing.T) {
	t.Parallel()

	if _, _, err := decodeCursor("not-base64!!"); err == nil {
		t.Error("expected invalid cursor error")
	}
	if _, _, err := decodeCursor("aGVsbG8"); err == nil {
		t.Error("expected invalid cursor error for malformed body")
	}
}

func TestEventJSON_RoundTrip(t *testing.T) {
	t.Parallel()

	sessionID := "session-1"
	e := Event{
		ID:        "id-1",
		SessionID: &sessionID,
		ASCID:     "asc-1",
		Action:    ActionSessionCreated,
		Payload:   map[string]any{"workflow_type": "pacu"},
		TS:        time.Date(2026, 5, 11, 14, 32, 18, 0, time.UTC),
	}
	b, err := json.Marshal(e)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	if !strings.Contains(string(b), `"action":"session_created"`) {
		t.Errorf("missing action field: %s", b)
	}

	var got Event
	if err := json.Unmarshal(b, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got.Action != ActionSessionCreated || got.ASCID != "asc-1" {
		t.Errorf("round-trip: %#v", got)
	}
}
