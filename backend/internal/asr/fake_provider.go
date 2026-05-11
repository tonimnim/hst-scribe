package asr

import (
	"context"
	"sync"
)

// FakeProvider is a deterministic, in-memory Provider for tests. It
// emits a scripted list of transcripts and records every AudioChunk it
// received, so test cases can assert both directions without spinning
// up the mock-asr WSS server.
//
// FakeProvider is goroutine-safe across multiple concurrent Stream
// calls — each call produces its own goroutine reading from its own
// `in` channel and emitting the same scripted output. Recorded chunks
// are appended to a shared, mutex-guarded slice; tests that care about
// order should use one stream at a time.
type FakeProvider struct {
	// Script is the list of transcripts every Stream call emits. Each
	// stream emits the full script once, in order, then closes `out`.
	// Tests can leave SessionID empty on script entries — the provider
	// stamps the active sessionID before delivery.
	Script []Transcript

	// EmitDelay is an optional per-transcript delay. Default zero means
	// "emit immediately"; non-zero is useful for testing backpressure
	// and reconnect logic.
	EmitDelay func(i int) // optional hook

	// FailAfter, if > 0, closes `out` after this many script entries
	// have been emitted — simulating a mid-stream provider failure.
	// Zero means "emit the full script then close cleanly".
	FailAfter int

	mu       sync.Mutex
	received [][]AudioChunk // one slice per Stream call, in call order
}

// NewFakeProvider constructs a FakeProvider whose Stream emits script.
func NewFakeProvider(script []Transcript) *FakeProvider {
	return &FakeProvider{Script: script}
}

// Name implements Provider.
func (f *FakeProvider) Name() string { return "fake" }

// Stream implements Provider. The returned `in` channel is buffered
// generously so tests don't deadlock when the script is short — the
// goroutine reading `in` runs until the caller closes it.
func (f *FakeProvider) Stream(ctx context.Context, sessionID string) (chan<- AudioChunk, <-chan Transcript, error) {
	in := make(chan AudioChunk, 32)
	out := make(chan Transcript, len(f.Script)+1)

	streamIdx := f.newStreamSlot()

	go f.drain(ctx, streamIdx, in)
	go f.emit(ctx, sessionID, out)

	return in, out, nil
}

// drain reads chunks until ctx is canceled or the caller closes `in`,
// recording each into the per-stream slot for test assertions.
func (f *FakeProvider) drain(ctx context.Context, streamIdx int, in <-chan AudioChunk) {
	for {
		select {
		case <-ctx.Done():
			return
		case chunk, ok := <-in:
			if !ok {
				return
			}
			f.recordChunk(streamIdx, chunk)
		}
	}
}

// emit walks the script, stamping sessionID on each entry, and closes
// `out` when complete or after FailAfter emissions.
func (f *FakeProvider) emit(ctx context.Context, sessionID string, out chan<- Transcript) {
	defer close(out)
	for i, t := range f.Script {
		if err := ctx.Err(); err != nil {
			return
		}
		if f.EmitDelay != nil {
			f.EmitDelay(i)
		}
		t.SessionID = sessionID
		select {
		case <-ctx.Done():
			return
		case out <- t:
		}
		if f.FailAfter > 0 && i+1 >= f.FailAfter {
			return
		}
	}
}

func (f *FakeProvider) newStreamSlot() int {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.received = append(f.received, nil)
	return len(f.received) - 1
}

func (f *FakeProvider) recordChunk(streamIdx int, c AudioChunk) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.received[streamIdx] = append(f.received[streamIdx], c)
}

// Received returns a defensive copy of all chunks received across every
// Stream call, in call order then in-stream order.
func (f *FakeProvider) Received() [][]AudioChunk {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := make([][]AudioChunk, len(f.received))
	for i, s := range f.received {
		cp := make([]AudioChunk, len(s))
		copy(cp, s)
		out[i] = cp
	}
	return out
}

// Compile-time check that *FakeProvider satisfies Provider.
var _ Provider = (*FakeProvider)(nil)
