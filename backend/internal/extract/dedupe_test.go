package extract

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
)

func mkVital(t *testing.T, sessionID string, vt contract.VitalType, value float64, at time.Time) ExtractedEvent {
	t.Helper()
	fields, err := json.Marshal(map[string]any{
		"vital_type": string(vt),
		"value":      value,
		"unit":       "mmHg",
	})
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	return ExtractedEvent{
		ExtractedEvent: contract.ExtractedEvent{
			EventID:     "ev-" + sessionID + "-" + string(vt),
			EventType:   contract.EventTypeVitalSign,
			Fields:      fields,
			Confidence:  0.9,
			ExtractedAt: at,
			EventTime:   at,
		},
		SessionID: sessionID,
	}
}

func mkMed(t *testing.T, sessionID, code string, dose float64, unit, route string, at time.Time) ExtractedEvent {
	t.Helper()
	fields, err := json.Marshal(map[string]any{
		"medication_name": "Whatever",
		"rxnorm_code":     code,
		"dose_value":      dose,
		"dose_unit":       unit,
		"route":           route,
	})
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	return ExtractedEvent{
		ExtractedEvent: contract.ExtractedEvent{
			EventID:     "med-" + sessionID + "-" + code,
			EventType:   contract.EventTypeMedicationAdministered,
			Fields:      fields,
			Confidence:  0.9,
			ExtractedAt: at,
			EventTime:   at,
		},
		SessionID: sessionID,
	}
}

func TestDedupe_VitalsSameValueWithinWindow(t *testing.T) {
	t.Parallel()

	d := NewDedupe()
	t0 := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	first := mkVital(t, "s1", contract.VitalBPSystolic, 130, t0)
	second := mkVital(t, "s1", contract.VitalBPSystolic, 130, t0.Add(2*time.Second))

	got := d.Filter("s1", t0, []ExtractedEvent{first})
	if len(got) != 1 {
		t.Fatalf("first batch: got %d, want 1", len(got))
	}
	got = d.Filter("s1", t0.Add(2*time.Second), []ExtractedEvent{second})
	if len(got) != 0 {
		t.Fatalf("dup should be dropped, got %d", len(got))
	}
}

func TestDedupe_VitalsTolerance(t *testing.T) {
	t.Parallel()

	d := NewDedupe()
	t0 := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	first := mkVital(t, "s1", contract.VitalHeartRate, 80, t0)
	// 82 is within 5 % of 80 (diff/max = 2/82 ≈ 0.024). Should dedupe.
	within := mkVital(t, "s1", contract.VitalHeartRate, 82, t0.Add(time.Second))
	// 90 is outside 5 %. Should pass.
	outside := mkVital(t, "s1", contract.VitalHeartRate, 90, t0.Add(2*time.Second))

	d.Filter("s1", t0, []ExtractedEvent{first})
	if got := d.Filter("s1", t0.Add(time.Second), []ExtractedEvent{within}); len(got) != 0 {
		t.Errorf("within tolerance should dedupe, got %d", len(got))
	}
	if got := d.Filter("s1", t0.Add(2*time.Second), []ExtractedEvent{outside}); len(got) != 1 {
		t.Errorf("outside tolerance should pass, got %d", len(got))
	}
}

func TestDedupe_AfterWindow(t *testing.T) {
	t.Parallel()

	d := NewDedupe()
	t0 := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	first := mkVital(t, "s1", contract.VitalBPSystolic, 130, t0)
	// 15 s later — past the 10 s window. Even identical, should pass.
	later := mkVital(t, "s1", contract.VitalBPSystolic, 130, t0.Add(15*time.Second))

	d.Filter("s1", t0, []ExtractedEvent{first})
	got := d.Filter("s1", t0.Add(15*time.Second), []ExtractedEvent{later})
	if len(got) != 1 {
		t.Errorf("after window should pass, got %d", len(got))
	}
}

func TestDedupe_MedicationSemantic(t *testing.T) {
	t.Parallel()

	d := NewDedupe()
	t0 := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	a := mkMed(t, "s1", "26225", 4, "mg", "iv", t0)
	b := mkMed(t, "s1", "26225", 4, "mg", "iv", t0.Add(time.Second))
	c := mkMed(t, "s1", "26225", 8, "mg", "iv", t0.Add(2*time.Second)) // dose changed

	d.Filter("s1", t0, []ExtractedEvent{a})
	if got := d.Filter("s1", t0.Add(time.Second), []ExtractedEvent{b}); len(got) != 0 {
		t.Errorf("dup med should dedupe, got %d", len(got))
	}
	if got := d.Filter("s1", t0.Add(2*time.Second), []ExtractedEvent{c}); len(got) != 1 {
		t.Errorf("dose-changed med should pass, got %d", len(got))
	}
}

func TestDedupe_ResetSession(t *testing.T) {
	t.Parallel()

	d := NewDedupe()
	t0 := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	first := mkVital(t, "s1", contract.VitalBPSystolic, 130, t0)
	d.Filter("s1", t0, []ExtractedEvent{first})
	d.Reset("s1")
	// After reset the same event should pass again.
	if got := d.Filter("s1", t0.Add(time.Second), []ExtractedEvent{first}); len(got) != 1 {
		t.Errorf("after reset should pass, got %d", len(got))
	}
}
