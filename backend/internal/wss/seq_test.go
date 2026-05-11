package wss

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
)

func TestSeqCounter_Monotonic(t *testing.T) {
	t.Parallel()
	var c SeqCounter
	if got := c.Next(); got != 1 {
		t.Errorf("first Next = %d, want 1", got)
	}
	if got := c.Next(); got != 2 {
		t.Errorf("second Next = %d, want 2", got)
	}
}

func TestIncomingTracker_RejectsRegression(t *testing.T) {
	t.Parallel()
	tr := NewIncomingTracker()
	if err := tr.Observe(&contract.Envelope{Seq: 1}); err != nil {
		t.Fatalf("observe 1: %v", err)
	}
	if err := tr.Observe(&contract.Envelope{Seq: 2}); err != nil {
		t.Fatalf("observe 2: %v", err)
	}
	if err := tr.Observe(&contract.Envelope{Seq: 2}); err == nil {
		t.Error("repeat seq should be rejected")
	}
	if err := tr.Observe(&contract.Envelope{Seq: 1}); err == nil {
		t.Error("regression should be rejected")
	}
}

func TestIncomingTracker_DedupesChunks(t *testing.T) {
	t.Parallel()
	tr := NewIncomingTracker()
	if !tr.SeenChunk("a") {
		t.Error("first sight should be true")
	}
	if tr.SeenChunk("a") {
		t.Error("repeat should be false")
	}
}

func TestEncodeDecode_RoundTrip(t *testing.T) {
	t.Parallel()

	payload := contract.PingPayload{Nonce: "abc"}
	out, err := Encode(contract.MsgPing, "01931d80", 7, time.Now(), payload)
	if err != nil {
		t.Fatalf("encode: %v", err)
	}

	env, err := Decode(out)
	if err != nil {
		t.Fatalf("decode: %v", err)
	}
	if env.Type != contract.MsgPing || env.Seq != 7 {
		t.Errorf("envelope off: %#v", env)
	}

	var got contract.PingPayload
	if err := json.Unmarshal(env.Payload, &got); err != nil {
		t.Fatalf("unmarshal payload: %v", err)
	}
	if got.Nonce != "abc" {
		t.Errorf("payload nonce = %q", got.Nonce)
	}
}
