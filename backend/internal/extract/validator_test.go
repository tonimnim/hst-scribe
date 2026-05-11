package extract

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/vocab"
)

func TestIsImperative(t *testing.T) {
	t.Parallel()
	cases := []struct {
		in   string
		want bool
	}{
		{"Give her 4 of Zofran IV", true},
		{"Hold the next dose of Zofran", true},
		{"start the antibiotic", true},
		{"Stop the drip", true},
		{"Just gave her 4 of Zofran IV", false},
		{"BP one thirty over eighty two", false},
		{"", false},
	}
	for _, tc := range cases {
		t.Run(tc.in, func(t *testing.T) {
			t.Parallel()
			if got := IsImperative(tc.in); got != tc.want {
				t.Errorf("IsImperative(%q) = %v, want %v", tc.in, got, tc.want)
			}
		})
	}
}

func mkMedEvent(t *testing.T, code, name string, dose float64, unit, utterance string) ExtractedEvent {
	t.Helper()
	fields, err := json.Marshal(map[string]any{
		"medication_name": name,
		"rxnorm_code":     code,
		"dose_value":      dose,
		"dose_unit":       unit,
		"route":           "iv",
	})
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	return ExtractedEvent{
		ExtractedEvent: contract.ExtractedEvent{
			EventID:         "ev1",
			EventType:       contract.EventTypeMedicationAdministered,
			Fields:          fields,
			Confidence:      0.95,
			SourceUtterance: utterance,
		},
	}
}

func TestValidator_DropsImperative(t *testing.T) {
	t.Parallel()
	v := NewEventValidator(vocab.NewRxNormValidator())

	ev := mkMedEvent(t, "26225", "Zofran", 4, "mg", "Give 4 of Zofran IV")
	got := v.Validate(context.Background(), []ExtractedEvent{ev})
	if len(got) != 0 {
		t.Errorf("imperative should be dropped, got %d", len(got))
	}
}

func TestValidator_BackfillsRxNorm(t *testing.T) {
	t.Parallel()
	v := NewEventValidator(vocab.NewRxNormValidator())

	ev := mkMedEvent(t, "", "Zofran", 4, "mg", "Just gave 4 of Zofran")
	got := v.Validate(context.Background(), []ExtractedEvent{ev})
	if len(got) != 1 {
		t.Fatalf("got %d events, want 1", len(got))
	}
	fields, err := got[0].FieldsMap()
	if err != nil {
		t.Fatalf("FieldsMap: %v", err)
	}
	if fields["rxnorm_code"] != "26225" {
		t.Errorf("expected rxnorm_code backfilled to 26225, got %v", fields["rxnorm_code"])
	}
	if got[0].Confidence != 0.95 {
		t.Errorf("confidence should not be capped when resolved, got %v", got[0].Confidence)
	}
}

func TestValidator_CapsUnresolvedRxNorm(t *testing.T) {
	t.Parallel()
	v := NewEventValidator(vocab.NewRxNormValidator())

	ev := mkMedEvent(t, "999999", "Madeupinol", 4, "mg", "Just gave 4 of madeupinol")
	got := v.Validate(context.Background(), []ExtractedEvent{ev})
	if len(got) != 1 {
		t.Fatalf("got %d events, want 1", len(got))
	}
	if got[0].Confidence > ConfidenceUnresolvedRxNorm {
		t.Errorf("expected confidence capped to %.2f, got %v", ConfidenceUnresolvedRxNorm, got[0].Confidence)
	}
	if !got[0].NeedsReview {
		t.Error("expected NeedsReview true")
	}
}

func TestValidator_DoseSanity(t *testing.T) {
	t.Parallel()
	v := NewEventValidator(vocab.NewRxNormValidator())

	// Morphine 75 mg is way past the sane 50 mg ceiling.
	ev := mkMedEvent(t, "7052", "Morphine", 75, "mg", "Just gave 75 mg of morphine")
	got := v.Validate(context.Background(), []ExtractedEvent{ev})
	if len(got) != 1 {
		t.Fatalf("got %d events, want 1", len(got))
	}
	if !got[0].NeedsReview {
		t.Error("expected NeedsReview true for out-of-range dose")
	}
	if got[0].Confidence > ConfidenceUnresolvedRxNorm {
		t.Errorf("expected confidence capped for out-of-range dose, got %v", got[0].Confidence)
	}
}

func TestValidator_BurstCap(t *testing.T) {
	t.Parallel()
	v := NewEventValidator(vocab.NewRxNormValidator())

	mk := func(name string) ExtractedEvent {
		f, _ := json.Marshal(map[string]any{
			"vital_type": "heart_rate",
			"value":      72,
			"unit":       "bpm",
		})
		return ExtractedEvent{
			ExtractedEvent: contract.ExtractedEvent{
				EventID:         "ev-" + name,
				EventType:       contract.EventTypeVitalSign,
				Fields:          f,
				Confidence:      0.95,
				SourceUtterance: "vitals " + name,
			},
		}
	}

	batch := []ExtractedEvent{mk("a"), mk("b"), mk("c"), mk("d"), mk("e")}
	got := v.Validate(context.Background(), batch)
	if len(got) != 5 {
		t.Fatalf("got %d events, want 5", len(got))
	}
	for _, e := range got {
		if e.Confidence > ConfidenceBurstCap {
			t.Errorf("burst cap not applied: %v", e.Confidence)
		}
	}
}
