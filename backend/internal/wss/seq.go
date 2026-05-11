// Package wss provides protocol-layer helpers for the WebSocket
// session stream. Transport (nhooyr.io/websocket) lives in the gateway
// — this package owns envelope encoding/decoding and the per-direction
// sequence counters described in contract/CONTRACT.md §5.
package wss

import (
	"encoding/json"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
)

// SeqCounter is a monotonic uint64 counter shared by the writer
// goroutine. Reads are lock-free; the zero value is ready to use.
type SeqCounter struct {
	n atomic.Uint64
}

// Next returns the next sequence value, starting at 1.
func (c *SeqCounter) Next() uint64 { return c.n.Add(1) }

// Current returns the last issued value (0 before first Next).
func (c *SeqCounter) Current() uint64 { return c.n.Load() }

// IncomingTracker enforces monotonic sequence on the receive side and
// dedupes audio chunks by chunk_id per session. Methods are safe for
// concurrent use.
type IncomingTracker struct {
	mu      sync.Mutex
	last    uint64
	seenIDs map[string]struct{}
}

// NewIncomingTracker returns a tracker primed with a starting sequence
// of 0 (so the first valid incoming seq is 1).
func NewIncomingTracker() *IncomingTracker {
	return &IncomingTracker{seenIDs: make(map[string]struct{})}
}

// Observe records a new incoming envelope and returns an error if the
// sequence regressed. Equal sequence is treated as a replay and also
// rejected; the client is expected to use last_seq+1 on reconnect.
func (t *IncomingTracker) Observe(env *contract.Envelope) error {
	t.mu.Lock()
	defer t.mu.Unlock()
	if env.Seq <= t.last {
		return httperr.ChunkOutOfOrder(t.last+1, env.Seq)
	}
	t.last = env.Seq
	return nil
}

// SeenChunk reports whether the given audio chunk_id has been seen in
// this session and records it. Returns true on first sight, false on
// duplicate.
func (t *IncomingTracker) SeenChunk(chunkID string) (firstTime bool) {
	t.mu.Lock()
	defer t.mu.Unlock()
	if _, dup := t.seenIDs[chunkID]; dup {
		return false
	}
	t.seenIDs[chunkID] = struct{}{}
	return true
}

// Last returns the highest observed seq.
func (t *IncomingTracker) Last() uint64 {
	t.mu.Lock()
	defer t.mu.Unlock()
	return t.last
}

// --- envelope helpers ---

// Encode builds a JSON envelope around payload. The caller supplies seq
// and timestamp; this keeps the writer goroutine the single owner of
// sequence allocation.
func Encode(msgType contract.MessageType, sessionID string, seq uint64, ts time.Time, payload any) ([]byte, error) {
	var raw json.RawMessage
	if payload != nil {
		b, err := json.Marshal(payload)
		if err != nil {
			return nil, fmt.Errorf("marshal %s payload: %w", msgType, err)
		}
		raw = b
	}
	env := contract.Envelope{
		Type:      msgType,
		SessionID: sessionID,
		Seq:       seq,
		TS:        ts.UTC(),
		Payload:   raw,
	}
	out, err := json.Marshal(env)
	if err != nil {
		return nil, fmt.Errorf("marshal envelope: %w", err)
	}
	return out, nil
}

// Decode unmarshals a JSON envelope. Payload decoding into per-type
// structs is the caller's job (contract.DecodePayload).
func Decode(raw []byte) (*contract.Envelope, error) {
	var env contract.Envelope
	if err := json.Unmarshal(raw, &env); err != nil {
		return nil, fmt.Errorf("decode envelope: %w", err)
	}
	if env.Type == "" {
		return nil, fmt.Errorf("envelope missing type")
	}
	return &env, nil
}
