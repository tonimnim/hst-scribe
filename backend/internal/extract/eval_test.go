package extract

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/llm"
	"github.com/tonimnim/hst-scribe/backend/internal/vocab"
)

// evalUtterance mirrors dev/seed/utterances.json.
type evalUtterance struct {
	ID             string                   `json:"id"`
	Text           string                   `json:"text"`
	Speaker        string                   `json:"speaker"`
	ExpectedEvents []map[string]interface{} `json:"expected_events"`
}

// resolveSeedPath returns an absolute path to dev/seed/utterances.json,
// walking up from this test's directory. CI may run from any depth.
func resolveSeedPath(t *testing.T) string {
	t.Helper()
	wd, err := os.Getwd()
	if err != nil {
		t.Fatalf("os.Getwd: %v", err)
	}
	dir := wd
	for i := 0; i < 6; i++ {
		candidate := filepath.Join(dir, "dev", "seed", "utterances.json")
		if _, err := os.Stat(candidate); err == nil {
			return candidate
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			break
		}
		dir = parent
	}
	t.Fatalf("could not locate dev/seed/utterances.json starting from %s", wd)
	return ""
}

// TestEval runs every utterance in the seed file through the
// FakeProvider + extract pipeline and reports per-utterance pass/fail
// plus an overall coverage percentage.
//
// This is the regression canary called out in CLAUDE.md and
// AGENTS.md. A drop in coverage fails the build.
//
// Semantics:
//   - Each seeded utterance is run through HandleFinalTranscript-like
//     EventsOnly call (no DB, no NATS).
//   - The produced events are matched against expected_events by
//     event_type + fields-subset. Extra fields on the produced event
//     (e.g. confidence, source_utterance) are not part of the match.
//   - An utterance passes iff every expected event has at least one
//     matching produced event AND no extra non-matching events were
//     produced (strict-but-set-based: |produced| == |expected| with
//     each expected covered).
func TestEval(t *testing.T) {
	seedPath := resolveSeedPath(t)

	raw, err := os.ReadFile(seedPath)
	if err != nil {
		t.Fatalf("read seed: %v", err)
	}
	var seeds []evalUtterance
	if err := json.Unmarshal(raw, &seeds); err != nil {
		t.Fatalf("decode seed: %v", err)
	}
	if len(seeds) == 0 {
		t.Fatal("seed file is empty")
	}

	provider, err := llm.NewFakeProvider(seedPath)
	if err != nil {
		t.Fatalf("NewFakeProvider: %v", err)
	}

	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	passed := 0
	type failure struct {
		ID     string
		Reason string
	}
	var failures []failure

	for _, s := range seeds {
		// Each utterance gets its own session so dedupe state never
		// leaks between cases.
		svc, err := NewService(Config{
			LLM:       provider,
			Validator: NewEventValidator(vocab.NewRxNormValidator()),
			Dedupe:    NewDedupe(),
			Now:       func() time.Time { return now },
		})
		if err != nil {
			t.Fatalf("NewService: %v", err)
		}

		events, err := svc.EventsOnly(context.Background(), "eval-"+s.ID, contract.TranscriptFinalPayload{
			TranscriptID: "tr-" + s.ID,
			Text:         s.Text,
			Speaker:      contract.Speaker(s.Speaker),
		})
		if err != nil {
			failures = append(failures, failure{ID: s.ID, Reason: "extract error: " + err.Error()})
			continue
		}

		if reason, ok := matchExpected(events, s.ExpectedEvents); !ok {
			failures = append(failures, failure{ID: s.ID, Reason: reason})
			continue
		}
		passed++
	}

	coverage := float64(passed) / float64(len(seeds)) * 100
	t.Logf("EVAL COVERAGE: %d/%d utterances passed (%.1f%%)", passed, len(seeds), coverage)
	for _, f := range failures {
		t.Errorf("  FAIL %s: %s", f.ID, f.Reason)
	}
	if passed != len(seeds) {
		t.Errorf("eval regression: %d/%d passed (%.1f%%)", passed, len(seeds), coverage)
	}
}

// matchExpected reports whether produced events match the expected set
// for an utterance. The check is "set-equality on (event_type, fields-
// subset)": every expected event must be covered by at least one
// produced event, and the produced count must equal the expected count
// so we catch extra hallucinated events.
//
// Returns a human-readable reason when match fails.
func matchExpected(produced []ExtractedEvent, expected []map[string]interface{}) (string, bool) {
	if len(produced) != len(expected) {
		return fmt.Sprintf("event count: produced=%d expected=%d (produced types=%s)",
			len(produced), len(expected), summarizeTypes(produced)), false
	}

	used := make([]bool, len(produced))
	for i, want := range expected {
		wantType, _ := want["event_type"].(string)
		wantFields, _ := want["fields"].(map[string]interface{})

		matchIdx := -1
		for j, p := range produced {
			if used[j] {
				continue
			}
			if string(p.EventType) != wantType {
				continue
			}
			gotFields, err := p.FieldsMap()
			if err != nil {
				continue
			}
			if !fieldsSubset(wantFields, gotFields) {
				continue
			}
			matchIdx = j
			break
		}
		if matchIdx < 0 {
			return fmt.Sprintf("expected[%d] not matched: type=%s fields=%v (produced=%s)",
				i, wantType, wantFields, summarizeProduced(produced)), false
		}
		used[matchIdx] = true
	}
	return "", true
}

// fieldsSubset reports whether every key/value in want has an equal
// value in got. Used so an utterance can specify only the fields that
// matter for the assertion (e.g. just vital_type + value) without
// pinning unit, indication, etc. that may legitimately vary.
func fieldsSubset(want, got map[string]interface{}) bool {
	for k, v := range want {
		gv, ok := got[k]
		if !ok {
			return false
		}
		if !looseEqual(v, gv) {
			return false
		}
	}
	return true
}

// looseEqual compares two values with JSON-decode quirks accounted for
// (numbers always arrive as float64; ints in the seed file decode the
// same way, so direct == works).
func looseEqual(a, b interface{}) bool {
	switch av := a.(type) {
	case float64:
		bv, ok := b.(float64)
		return ok && av == bv
	case string:
		bv, ok := b.(string)
		return ok && av == bv
	case bool:
		bv, ok := b.(bool)
		return ok && av == bv
	case nil:
		return b == nil
	default:
		// Fall back to JSON-string compare for slices/maps in fields.
		ab, errA := json.Marshal(a)
		bb, errB := json.Marshal(b)
		if errA != nil || errB != nil {
			return false
		}
		return string(ab) == string(bb)
	}
}

func summarizeTypes(events []ExtractedEvent) string {
	types := make([]string, 0, len(events))
	for _, e := range events {
		types = append(types, string(e.EventType))
	}
	out, _ := json.Marshal(types)
	return string(out)
}

func summarizeProduced(events []ExtractedEvent) string {
	out := make([]map[string]interface{}, 0, len(events))
	for _, e := range events {
		f, _ := e.FieldsMap()
		out = append(out, map[string]interface{}{
			"event_type": string(e.EventType),
			"fields":     f,
		})
	}
	b, _ := json.Marshal(out)
	return string(b)
}
