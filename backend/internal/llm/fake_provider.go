package llm

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"regexp"
	"strings"
	"sync"
)

// seedUtterance mirrors the shape of dev/seed/utterances.json. Only the
// fields the FakeProvider uses are decoded.
type seedUtterance struct {
	ID             string            `json:"id"`
	Text           string            `json:"text"`
	Speaker        string            `json:"speaker"`
	ExpectedEvents []json.RawMessage `json:"expected_events"`
}

// FakeProvider is a deterministic, offline LLM stand-in driven by the
// canned eval set at dev/seed/utterances.json.
//
// Lookup is loose: we normalize both the seeded utterance and the
// incoming transcript (lowercase, collapse whitespace, strip
// punctuation) and check whether either fully contains the other.
// That handles the realistic case where ASR adds or drops a fragment
// of trailing context relative to the seed example.
//
// FakeProvider is safe for concurrent use; the seed slice is read-only
// after construction.
type FakeProvider struct {
	mu    sync.RWMutex
	seeds []seedUtterance
}

// NewFakeProvider builds a FakeProvider from a JSON file with the
// shape of dev/seed/utterances.json. Returns an error if the file
// can't be read or decoded.
func NewFakeProvider(seedPath string) (*FakeProvider, error) {
	raw, err := os.ReadFile(seedPath) // #nosec G304 — operator-supplied path, dev only
	if err != nil {
		return nil, fmt.Errorf("reading seed %s: %w", seedPath, err)
	}
	return NewFakeProviderFromBytes(raw)
}

// NewFakeProviderFromBytes is the in-memory variant used by tests.
// raw must be a JSON array matching dev/seed/utterances.json.
func NewFakeProviderFromBytes(raw []byte) (*FakeProvider, error) {
	var seeds []seedUtterance
	if err := json.Unmarshal(raw, &seeds); err != nil {
		return nil, fmt.Errorf("decoding seed json: %w", err)
	}
	return &FakeProvider{seeds: seeds}, nil
}

// Seeds returns a copy of the loaded seed slice. Primarily so the
// eval-test in the extract package can drive the same fixtures the
// provider matches against without round-tripping through the file
// system again.
func (p *FakeProvider) Seeds() []seedUtterance {
	p.mu.RLock()
	defer p.mu.RUnlock()
	out := make([]seedUtterance, len(p.seeds))
	copy(out, p.seeds)
	return out
}

// SeedTextByID returns the verbatim text and expected events for the
// seed utterance with the given id, or ("", nil, false) on miss.
// Convenience for tests that loop over the canonical eval set.
func (p *FakeProvider) SeedTextByID(id string) (text string, expected []json.RawMessage, ok bool) {
	p.mu.RLock()
	defer p.mu.RUnlock()
	for _, s := range p.seeds {
		if s.ID == id {
			cp := make([]json.RawMessage, len(s.ExpectedEvents))
			copy(cp, s.ExpectedEvents)
			return s.Text, cp, true
		}
	}
	return "", nil, false
}

// Extract implements Provider. The prompt is expected to end with the
// new utterance to classify, surrounded by sentinel markers. We
// extract the utterance from the prompt, normalize it, and search the
// seed set for a loose match.
//
// If no seed matches, we return an empty events array — the same shape
// a real LLM would produce when nothing is extractable. The
// fact-vs-imperative rule is honored implicitly because the seed set
// already encodes it (utterance 004 has empty expected_events).
func (p *FakeProvider) Extract(_ context.Context, prompt string, _ json.RawMessage) (json.RawMessage, error) {
	utterance := extractUtteranceFromPrompt(prompt)
	if utterance == "" {
		// No utterance marker found — assume the entire prompt is the
		// utterance. That covers callers using FakeProvider directly
		// without going through prompt.Build.
		utterance = prompt
	}

	events := p.matchEvents(utterance)
	resp := ExtractResponse{Events: events}
	return json.Marshal(resp)
}

func (p *FakeProvider) matchEvents(utterance string) []json.RawMessage {
	target := normalize(utterance)
	if target == "" {
		return []json.RawMessage{}
	}

	p.mu.RLock()
	defer p.mu.RUnlock()

	for _, s := range p.seeds {
		seed := normalize(s.Text)
		if seed == "" {
			continue
		}
		if seed == target || strings.Contains(target, seed) || strings.Contains(seed, target) {
			out := make([]json.RawMessage, len(s.ExpectedEvents))
			copy(out, s.ExpectedEvents)
			return out
		}
	}
	return []json.RawMessage{}
}

// punctRE strips non-alphanumeric characters except spaces. Numbers
// matter (BP 130 over 82); commas and periods don't.
var punctRE = regexp.MustCompile(`[^a-z0-9\s]+`)

// wsRE collapses runs of whitespace into a single ASCII space.
var wsRE = regexp.MustCompile(`\s+`)

// normalize lowercases, strips punctuation, and collapses whitespace
// so utterance comparisons are robust to capitalization and trailing
// punctuation differences between the seed file and ASR output.
func normalize(s string) string {
	s = strings.ToLower(strings.TrimSpace(s))
	s = punctRE.ReplaceAllString(s, " ")
	s = wsRE.ReplaceAllString(s, " ")
	return strings.TrimSpace(s)
}

// utteranceMarkerStart and utteranceMarkerEnd bracket the utterance to
// classify inside the assembled prompt. Kept in sync with
// extract.prompt.Build.
const (
	utteranceMarkerStart = "<utterance>"
	utteranceMarkerEnd   = "</utterance>"
)

// extractUtteranceFromPrompt pulls the text between the
// <utterance>...</utterance> markers. Returns "" if either marker is
// missing.
func extractUtteranceFromPrompt(prompt string) string {
	startIdx := strings.LastIndex(prompt, utteranceMarkerStart)
	if startIdx < 0 {
		return ""
	}
	startIdx += len(utteranceMarkerStart)
	endIdx := strings.Index(prompt[startIdx:], utteranceMarkerEnd)
	if endIdx < 0 {
		return ""
	}
	return strings.TrimSpace(prompt[startIdx : startIdx+endIdx])
}
