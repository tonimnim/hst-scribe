package llm

import (
	"context"
	"encoding/json"
	"strings"
	"testing"
)

const seedJSON = `[
  {
    "id": "utt-001",
    "text": "BP one thirty over eighty two",
    "speaker": "nurse",
    "expected_events": [
      { "event_type": "vital_sign", "fields": { "vital_type": "blood_pressure_systolic", "value": 130, "unit": "mmHg" } },
      { "event_type": "vital_sign", "fields": { "vital_type": "blood_pressure_diastolic", "value": 82, "unit": "mmHg" } }
    ]
  },
  {
    "id": "utt-004",
    "text": "Give her 4 of Zofran IV",
    "speaker": "nurse",
    "expected_events": []
  }
]`

func TestFakeProvider_ExactMatch(t *testing.T) {
	t.Parallel()

	p, err := NewFakeProviderFromBytes([]byte(seedJSON))
	if err != nil {
		t.Fatalf("NewFakeProviderFromBytes: %v", err)
	}

	prompt := "system blah\n" + utteranceMarkerStart + "BP one thirty over eighty two" + utteranceMarkerEnd
	out, err := p.Extract(context.Background(), prompt, nil)
	if err != nil {
		t.Fatalf("Extract: %v", err)
	}
	resp, err := DecodeResponse(out)
	if err != nil {
		t.Fatalf("DecodeResponse: %v", err)
	}
	if len(resp.Events) != 2 {
		t.Fatalf("got %d events, want 2", len(resp.Events))
	}
}

func TestFakeProvider_ImperativeReturnsEmpty(t *testing.T) {
	t.Parallel()

	p, err := NewFakeProviderFromBytes([]byte(seedJSON))
	if err != nil {
		t.Fatalf("NewFakeProviderFromBytes: %v", err)
	}

	prompt := utteranceMarkerStart + "Give her 4 of Zofran IV" + utteranceMarkerEnd
	out, err := p.Extract(context.Background(), prompt, nil)
	if err != nil {
		t.Fatalf("Extract: %v", err)
	}
	resp, err := DecodeResponse(out)
	if err != nil {
		t.Fatalf("DecodeResponse: %v", err)
	}
	if len(resp.Events) != 0 {
		t.Errorf("expected zero events for imperative, got %d", len(resp.Events))
	}
}

func TestFakeProvider_UnknownReturnsEmpty(t *testing.T) {
	t.Parallel()

	p, err := NewFakeProviderFromBytes([]byte(seedJSON))
	if err != nil {
		t.Fatalf("NewFakeProviderFromBytes: %v", err)
	}

	prompt := utteranceMarkerStart + "something totally unrelated about lunch" + utteranceMarkerEnd
	out, err := p.Extract(context.Background(), prompt, nil)
	if err != nil {
		t.Fatalf("Extract: %v", err)
	}
	resp, err := DecodeResponse(out)
	if err != nil {
		t.Fatalf("DecodeResponse: %v", err)
	}
	if len(resp.Events) != 0 {
		t.Errorf("expected zero events for unknown, got %d", len(resp.Events))
	}
}

func TestFakeProvider_LooseMatch(t *testing.T) {
	t.Parallel()

	p, err := NewFakeProviderFromBytes([]byte(seedJSON))
	if err != nil {
		t.Fatalf("NewFakeProviderFromBytes: %v", err)
	}

	// ASR-style: extra punctuation and trailing filler.
	prompt := utteranceMarkerStart + "Bp One Thirty Over Eighty Two." + utteranceMarkerEnd
	out, err := p.Extract(context.Background(), prompt, nil)
	if err != nil {
		t.Fatalf("Extract: %v", err)
	}
	resp, err := DecodeResponse(out)
	if err != nil {
		t.Fatalf("DecodeResponse: %v", err)
	}
	if len(resp.Events) != 2 {
		t.Errorf("expected 2 events on loose match, got %d", len(resp.Events))
	}
}

func TestBedrockClaude_NotImplemented(t *testing.T) {
	t.Parallel()

	p, err := NewBedrockClaudeProvider(BedrockClaudeConfig{
		Region:  "us-east-1",
		ModelID: "anthropic.claude-3-5-sonnet-20241022-v2:0",
	})
	if err != nil {
		t.Fatalf("constructor: %v", err)
	}
	if _, err := p.Extract(context.Background(), "anything", json.RawMessage(`{}`)); err == nil {
		t.Fatal("expected ErrNotImplemented")
	} else if !strings.Contains(err.Error(), "not implemented") {
		t.Errorf("error %q does not mention not implemented", err.Error())
	}

	// Constructor must reject missing region/model.
	if _, err := NewBedrockClaudeProvider(BedrockClaudeConfig{ModelID: "x"}); err == nil {
		t.Error("expected error for missing region")
	}
	if _, err := NewBedrockClaudeProvider(BedrockClaudeConfig{Region: "us-east-1"}); err == nil {
		t.Error("expected error for missing model")
	}
}
