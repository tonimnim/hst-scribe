// Package seed loads the canned utterance set the mock ASR replays.
package seed

import (
	"encoding/json"
	"fmt"
	"os"
)

// Utterance is one scripted line the mock cycles through. Only the fields the
// mock needs are decoded; expected_events and other eval metadata are ignored.
type Utterance struct {
	ID      string `json:"id"`
	Text    string `json:"text"`
	Speaker string `json:"speaker"`
}

// Load reads utterances.json from disk. Returns a non-empty slice or an error.
// Unknown fields (expected_events, etc.) are tolerated — this file is also the
// extractor eval set, so extra metadata is expected.
func Load(path string) ([]Utterance, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading seed file %s: %w", path, err)
	}

	var us []Utterance
	if err := json.Unmarshal(b, &us); err != nil {
		return nil, fmt.Errorf("decoding seed file %s: %w", path, err)
	}

	if len(us) == 0 {
		return nil, fmt.Errorf("seed file %s contained no utterances", path)
	}

	for i, u := range us {
		if u.ID == "" || u.Text == "" || u.Speaker == "" {
			return nil, fmt.Errorf("seed file %s utterance %d missing required field", path, i)
		}
	}

	return us, nil
}
