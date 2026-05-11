package gateway

import (
	"sync"
	"time"
)

// replayEntry is one buffered server→client frame, retained for reconnect.
type replayEntry struct {
	seq  uint64
	ts   time.Time
	data []byte
}

// ReplayBuffer is a bounded, time-windowed ring of server→client WSS
// frames per session. It supports replay-from-seq for reconnection.
//
// Sizing: per CONTRACT.md §5 the retention window is 5 minutes. At a
// peak of ~50 server messages/sec (partial transcripts + event extracts),
// 5 minutes is ~15K entries — but realistic peaks are far lower. We cap
// at maxEntries (1024) and additionally drop anything older than ttl;
// whichever bound hits first wins. On overflow the oldest entries are
// discarded silently — the client falls back to a fresh session_started
// after the on-reconnect catch-up gap, which the contract permits.
type ReplayBuffer struct {
	mu      sync.Mutex
	entries []replayEntry
	ttl     time.Duration
	max     int
}

// NewReplayBuffer returns a buffer with the configured retention. ttl
// and max must be positive; zero values fall back to defaults.
func NewReplayBuffer(ttl time.Duration, max int) *ReplayBuffer {
	if ttl <= 0 {
		ttl = 5 * time.Minute
	}
	if max <= 0 {
		max = 1024
	}
	return &ReplayBuffer{ttl: ttl, max: max}
}

// Append records one outgoing frame. The caller owns data after the
// call — the buffer takes a reference and assumes the bytes are
// immutable (we never mutate the slice).
func (b *ReplayBuffer) Append(seq uint64, ts time.Time, data []byte) {
	b.mu.Lock()
	defer b.mu.Unlock()

	b.entries = append(b.entries, replayEntry{seq: seq, ts: ts, data: data})
	b.evictLocked(time.Now())
}

// ReplayFrom returns a copy of all buffered entries with seq > afterSeq.
// The returned slice is safe to use without holding the buffer lock.
// Returns nil if there is nothing to replay.
func (b *ReplayBuffer) ReplayFrom(afterSeq uint64) [][]byte {
	b.mu.Lock()
	defer b.mu.Unlock()

	b.evictLocked(time.Now())
	if len(b.entries) == 0 {
		return nil
	}

	var out [][]byte
	for _, e := range b.entries {
		if e.seq > afterSeq {
			out = append(out, e.data)
		}
	}
	return out
}

// Len returns the current entry count. Test helper.
func (b *ReplayBuffer) Len() int {
	b.mu.Lock()
	defer b.mu.Unlock()
	return len(b.entries)
}

// evictLocked drops entries older than ttl and trims the buffer to max.
// Caller must hold b.mu.
func (b *ReplayBuffer) evictLocked(now time.Time) {
	if len(b.entries) == 0 {
		return
	}
	cutoff := now.Add(-b.ttl)
	idx := 0
	for idx < len(b.entries) && b.entries[idx].ts.Before(cutoff) {
		idx++
	}
	if idx > 0 {
		b.entries = b.entries[idx:]
	}
	if len(b.entries) > b.max {
		b.entries = b.entries[len(b.entries)-b.max:]
	}
}
