package extract

import (
	"context"
	"encoding/json"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/llm"
	"github.com/tonimnim/hst-scribe/backend/internal/vocab"
)

// recordingPublisher captures publish() calls for assertion.
type recordingPublisher struct {
	mu       sync.Mutex
	messages []publishedMessage
}

type publishedMessage struct {
	Subject string
	Data    []byte
}

func (p *recordingPublisher) Publish(subject string, data []byte) error {
	p.mu.Lock()
	defer p.mu.Unlock()
	cp := make([]byte, len(data))
	copy(cp, data)
	p.messages = append(p.messages, publishedMessage{Subject: subject, Data: cp})
	return nil
}

func (p *recordingPublisher) snapshot() []publishedMessage {
	p.mu.Lock()
	defer p.mu.Unlock()
	out := make([]publishedMessage, len(p.messages))
	copy(out, p.messages)
	return out
}

const sampleSeed = `[
  {
    "id": "utt-001",
    "text": "BP one thirty over eighty two",
    "speaker": "nurse",
    "expected_events": [
      { "event_type": "vital_sign", "fields": { "vital_type": "blood_pressure_systolic", "value": 130, "unit": "mmHg" } },
      { "event_type": "vital_sign", "fields": { "vital_type": "blood_pressure_diastolic", "value": 82, "unit": "mmHg" } }
    ]
  }
]`

func newTestService(t *testing.T, pub Publisher) *Service {
	t.Helper()
	fake, err := llm.NewFakeProviderFromBytes([]byte(sampleSeed))
	if err != nil {
		t.Fatalf("NewFakeProvider: %v", err)
	}
	svc, err := NewService(Config{
		LLM:       fake,
		Validator: NewEventValidator(vocab.NewRxNormValidator()),
		Dedupe:    NewDedupe(),
		Publisher: pub,
		Now:       func() time.Time { return time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC) },
	})
	if err != nil {
		t.Fatalf("NewService: %v", err)
	}
	return svc
}

func TestService_HandleFinalTranscript_PublishesEvents(t *testing.T) {
	t.Parallel()

	pub := &recordingPublisher{}
	svc := newTestService(t, pub)
	t0 := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)

	err := svc.HandleFinalTranscript(context.Background(), "test-session", t0, contract.TranscriptFinalPayload{
		TranscriptID: "tr-001",
		Text:         "BP one thirty over eighty two",
		Speaker:      contract.SpeakerNurse,
	})
	if err != nil {
		t.Fatalf("HandleFinalTranscript: %v", err)
	}

	msgs := pub.snapshot()
	if len(msgs) != 2 {
		t.Fatalf("got %d messages, want 2", len(msgs))
	}
	for _, m := range msgs {
		if m.Subject != "extracted.events.test-session" {
			t.Errorf("subject = %q, want extracted.events.test-session", m.Subject)
		}
		var env contract.Envelope
		if err := json.Unmarshal(m.Data, &env); err != nil {
			t.Fatalf("unmarshal envelope: %v", err)
		}
		if env.Type != contract.MsgEventExtracted {
			t.Errorf("envelope.Type = %v, want event_extracted", env.Type)
		}
	}
}

func TestService_HandleTranscriptEnvelope_SkipsPartials(t *testing.T) {
	t.Parallel()

	pub := &recordingPublisher{}
	svc := newTestService(t, pub)

	env := contract.Envelope{
		Type:      contract.MsgTranscriptPartial,
		SessionID: "test-session",
		TS:        time.Now().UTC(),
		Payload:   json.RawMessage(`{"text":"BP one"}`),
	}
	data, err := json.Marshal(env)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	if err := svc.HandleTranscriptEnvelope(context.Background(), data); err == nil || !strings.Contains(err.Error(), "skipped") {
		// HandleTranscriptEnvelope returns ErrSkipped for non-final messages.
		if err != ErrSkipped { //nolint:errorlint — sentinel ID compare is fine
			t.Errorf("expected ErrSkipped, got %v", err)
		}
	}
	if got := pub.snapshot(); len(got) != 0 {
		t.Errorf("partial should not publish, got %d", len(got))
	}
}

func TestService_HandleFinalTranscript_DedupesAcrossCalls(t *testing.T) {
	t.Parallel()

	pub := &recordingPublisher{}
	svc := newTestService(t, pub)
	t0 := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)

	// Call twice with the same utterance within 10 s.
	if err := svc.HandleFinalTranscript(context.Background(), "test-session", t0, contract.TranscriptFinalPayload{
		TranscriptID: "tr-001",
		Text:         "BP one thirty over eighty two",
	}); err != nil {
		t.Fatal(err)
	}
	if err := svc.HandleFinalTranscript(context.Background(), "test-session", t0.Add(2*time.Second), contract.TranscriptFinalPayload{
		TranscriptID: "tr-002",
		Text:         "BP one thirty over eighty two",
	}); err != nil {
		t.Fatal(err)
	}
	// First call should publish 2; second should publish 0 (dupes).
	if got := pub.snapshot(); len(got) != 2 {
		t.Errorf("expected 2 published events across both calls, got %d", len(got))
	}
}
