package gateway

import (
	"sync"
)

// SessionRegistry tracks active WSS sessions for graceful shutdown and
// for sharing replay buffers across reconnects within the same process.
//
// Reconnection note: the contract calls for replay from last_seq+1 if
// the client reconnects within the retention window. To make that work
// across the brief disconnect, the buffer must outlive the original
// *sessionConn. We keep the buffer indexed by session_id here and only
// drop it when the session is signed/ended explicitly. (The chart-sign
// path is responsible for calling Drop; otherwise a sweeper would be
// needed — out of scope for Wave 1.)
type SessionRegistry struct {
	mu      sync.Mutex
	buffers map[string]*ReplayBuffer
	live    map[string]*sessionConn
}

// NewSessionRegistry returns an empty registry.
func NewSessionRegistry() *SessionRegistry {
	return &SessionRegistry{
		buffers: make(map[string]*ReplayBuffer),
		live:    make(map[string]*sessionConn),
	}
}

// BufferFor returns the replay buffer for sessionID, creating one with
// default sizing on first use.
func (r *SessionRegistry) BufferFor(sessionID string) *ReplayBuffer {
	r.mu.Lock()
	defer r.mu.Unlock()
	b, ok := r.buffers[sessionID]
	if !ok {
		b = NewReplayBuffer(0, 0)
		r.buffers[sessionID] = b
	}
	return b
}

// SetLive marks sessionID as currently connected to conn. Any prior
// live connection for the same id is returned to the caller for
// orderly close (the caller is the new handler that just accepted).
func (r *SessionRegistry) SetLive(sessionID string, conn *sessionConn) *sessionConn {
	r.mu.Lock()
	defer r.mu.Unlock()
	prev := r.live[sessionID]
	r.live[sessionID] = conn
	return prev
}

// ClearLive clears the live entry if and only if it is still pointing
// at conn — avoids racing with a later reconnect that already replaced
// the entry.
func (r *SessionRegistry) ClearLive(sessionID string, conn *sessionConn) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.live[sessionID] == conn {
		delete(r.live, sessionID)
	}
}

// Drop removes both the live connection and the replay buffer for
// sessionID. Called when the session is signed or ended.
func (r *SessionRegistry) Drop(sessionID string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	delete(r.buffers, sessionID)
	delete(r.live, sessionID)
}

// Snapshot returns a copy of all currently-live connections. Used by
// the graceful-shutdown path to send session_ended frames in parallel.
func (r *SessionRegistry) Snapshot() []*sessionConn {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := make([]*sessionConn, 0, len(r.live))
	for _, c := range r.live {
		out = append(out, c)
	}
	return out
}
