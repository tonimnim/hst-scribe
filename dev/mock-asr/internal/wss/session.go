package wss

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/google/uuid"
	"nhooyr.io/websocket"
	"nhooyr.io/websocket/wsjson"

	"github.com/tonimnim/hst-scribe/dev/mock-asr/internal/seed"
)

// ProtocolVersion is what the mock advertises on session_started.
const ProtocolVersion = "v1"

// SessionConfig is the per-connection tuning passed in by the Server.
type SessionConfig struct {
	EmitInterval   time.Duration
	PartialLeadIn  time.Duration
	PartialToFinal time.Duration
	Utterances     []seed.Utterance
}

// session encapsulates one WSS connection's state. There is no shared state
// between sessions — each goroutine pair owns its own counter, pause flag,
// and utterance cursor.
type session struct {
	cfg       SessionConfig
	conn      *websocket.Conn
	sessionID string
	logger    *slog.Logger

	mu       sync.Mutex
	seq      int64 // server → client counter, monotonic per direction
	paused   bool
	pauseCh  chan struct{} // closed when paused, replaced on resume
	resumeCh chan struct{} // closed when resumed
}

// newSession constructs a session bound to a connection. session_id is taken
// from the first client frame if present; otherwise the server mints one so
// the envelope is always well-formed.
func newSession(conn *websocket.Conn, cfg SessionConfig, logger *slog.Logger) *session {
	sid, err := uuid.NewV7()
	if err != nil {
		// uuid.NewV7 only errors if the system clock is broken; fall back to
		// a v4 so the mock keeps running.
		sid = uuid.New()
	}
	s := &session{
		cfg:       cfg,
		conn:      conn,
		sessionID: sid.String(),
		logger:    logger.With(slog.String("session_id", sid.String())),
	}
	s.resumeCh = make(chan struct{})
	close(s.resumeCh) // initial state: not paused, "resumed" channel is closed
	return s
}

// run drives the connection until ctx is canceled, the client sends
// session_end, or the underlying socket errors. It owns two goroutines —
// the read loop and the emit loop — and returns once both exit.
func (s *session) run(ctx context.Context) error {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	if err := s.sendSessionStarted(ctx); err != nil {
		return fmt.Errorf("sending session_started: %w", err)
	}

	var wg sync.WaitGroup
	wg.Add(2)

	readErrCh := make(chan error, 1)
	go func() {
		defer wg.Done()
		readErrCh <- s.readLoop(ctx)
	}()

	emitErrCh := make(chan error, 1)
	go func() {
		defer wg.Done()
		emitErrCh <- s.emitLoop(ctx)
	}()

	// Whichever goroutine returns first cancels the other.
	var firstErr error
	select {
	case err := <-readErrCh:
		firstErr = err
	case err := <-emitErrCh:
		firstErr = err
	case <-ctx.Done():
		firstErr = ctx.Err()
	}
	cancel()
	wg.Wait()

	if firstErr != nil && !errors.Is(firstErr, context.Canceled) && !isClosed(firstErr) {
		return firstErr
	}
	return nil
}

func (s *session) sendSessionStarted(ctx context.Context) error {
	payload := SessionStartedPayload{
		ProtocolVersion: ProtocolVersion,
		PatientContext:  PatientContext{}, // empty — mock-echart fills this elsewhere
		ServerCapabilities: ServerCapabilities{
			VoiceCommands: false,
			Diarization:   true,
		},
	}
	return s.sendEnvelope(ctx, TypeSessionStarted, payload)
}

// readLoop services client → server frames. It runs until the socket closes
// or the client sends session_end. Frames it doesn't recognize are logged
// and ignored — strict rejection would couple the mock too tightly to client
// experiments.
func (s *session) readLoop(ctx context.Context) error {
	for {
		if err := ctx.Err(); err != nil {
			return err
		}

		var env Envelope
		if err := wsjson.Read(ctx, s.conn, &env); err != nil {
			return err
		}

		switch env.Type {
		case TypeAudioChunk:
			// ACK chunk receipt with a pong — see CONTRACT-aligned mock spec.
			if err := s.sendEnvelope(ctx, TypePong, map[string]any{"ack": "audio_chunk"}); err != nil {
				return err
			}
		case TypeSessionPause:
			s.pause()
			s.logger.Info("session paused")
		case TypeSessionResume:
			s.resume()
			s.logger.Info("session resumed")
		case TypeSessionEnd:
			s.logger.Info("session_end received from client")
			final := s.currentSeq()
			payload := SessionEndedPayload{
				Reason:   "client_requested",
				FinalSeq: final + 1, // the session_ended frame itself
			}
			if err := s.sendEnvelope(ctx, TypeSessionEnded, payload); err != nil {
				return err
			}
			// Graceful close — return a sentinel the run loop treats as clean.
			return errClientEnded
		case TypePing:
			if err := s.sendEnvelope(ctx, TypePong, map[string]any{}); err != nil {
				return err
			}
		case TypeVoiceCommand:
			// Mock advertises voice_commands=false; accept silently for forward-compat.
			s.logger.Debug("voice_command ignored (mock disables this capability)")
		default:
			s.logger.Warn("unknown frame type", slog.String("type", env.Type))
		}
	}
}

// errClientEnded signals a clean close initiated by the client.
var errClientEnded = errors.New("client requested session_end")

// emitLoop emits a partial-then-final pair for each cycled utterance, paced
// by the configured interval. It honors pause/resume by waiting on a channel
// the read loop closes/replaces.
func (s *session) emitLoop(ctx context.Context) error {
	idx := 0
	// Initial gap before the very first partial — same as the inter-utterance
	// cadence so the first emission isn't instantaneous on connect.
	if err := s.sleepRespectPause(ctx, s.cfg.EmitInterval); err != nil {
		return err
	}

	for {
		if err := ctx.Err(); err != nil {
			return err
		}

		u := s.cfg.Utterances[idx%len(s.cfg.Utterances)]
		idx++

		// Partial first.
		partial := TranscriptPartialPayload{
			Text:    partialPrefix(u.Text),
			Speaker: SpeakerNurse,
			StartMS: 0,
			EndMS:   400,
		}
		if err := s.sendEnvelope(ctx, TypeTranscriptPartial, partial); err != nil {
			return err
		}

		if err := s.sleepRespectPause(ctx, s.cfg.PartialToFinal); err != nil {
			return err
		}

		// Final.
		tid, err := uuid.NewV7()
		if err != nil {
			tid = uuid.New()
		}
		final := TranscriptFinalPayload{
			TranscriptID:  tid.String(),
			Text:          u.Text,
			Speaker:       SpeakerNurse,
			StartMS:       0,
			EndMS:         int64(s.cfg.PartialToFinal/time.Millisecond) + 400,
			AudioChunkIDs: []string{}, // mock doesn't track real chunk IDs
		}
		if err := s.sendEnvelope(ctx, TypeTranscriptFinal, final); err != nil {
			return err
		}
		// Note: we deliberately do NOT log the transcript text. Even mock content
		// is treated as if it were PHI to keep log discipline consistent.
		s.logger.Info("emitted transcript_final",
			slog.String("utterance_id", u.ID),
			slog.String("transcript_id", tid.String()),
		)

		// Inter-utterance gap to the NEXT partial.
		gap := s.cfg.EmitInterval - s.cfg.PartialToFinal
		if gap < s.cfg.PartialLeadIn {
			gap = s.cfg.PartialLeadIn
		}
		if err := s.sleepRespectPause(ctx, gap); err != nil {
			return err
		}
	}
}

// partialPrefix returns the first 2-3 words of text — the "in-flight" preview
// a real ASR would emit before finalization.
func partialPrefix(text string) string {
	count := 0
	for i := 0; i < len(text); i++ {
		if text[i] == ' ' {
			count++
			if count == 3 {
				return text[:i]
			}
		}
	}
	return text
}

// sleepRespectPause sleeps for d, but if the session is paused it waits for
// resume before counting the sleep down. The clock is frozen while paused.
func (s *session) sleepRespectPause(ctx context.Context, d time.Duration) error {
	if err := s.waitIfPaused(ctx); err != nil {
		return err
	}

	remaining := d
	for remaining > 0 {
		start := time.Now()
		timer := time.NewTimer(remaining)
		select {
		case <-ctx.Done():
			timer.Stop()
			return ctx.Err()
		case <-s.pausedCh():
			// Entered pause mid-sleep — credit time already elapsed and wait for resume.
			timer.Stop()
			remaining -= time.Since(start)
			if err := s.waitIfPaused(ctx); err != nil {
				return err
			}
			// Loop and re-arm with whatever's left.
		case <-timer.C:
			return nil
		}
	}
	return nil
}

func (s *session) pause() {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.paused {
		return
	}
	s.paused = true
	s.pauseCh = make(chan struct{})
	close(s.pauseCh) // signals "we are now paused" to any in-flight sleeper
}

func (s *session) resume() {
	s.mu.Lock()
	defer s.mu.Unlock()
	if !s.paused {
		return
	}
	s.paused = false
	// Replace resumeCh so future waitIfPaused calls proceed immediately.
	prev := s.resumeCh
	s.resumeCh = make(chan struct{})
	close(s.resumeCh)
	// Defensive: also drain any nil from prev.
	_ = prev
}

// waitIfPaused blocks until the session is not paused (or ctx is canceled).
// Safe to call when not paused — it returns immediately because resumeCh is
// closed in that state.
func (s *session) waitIfPaused(ctx context.Context) error {
	s.mu.Lock()
	ch := s.resumeCh
	paused := s.paused
	s.mu.Unlock()
	if !paused {
		return nil
	}
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-ch:
		return nil
	}
}

// pausedCh returns a channel that closes when the session enters paused state.
// While unpaused, it returns a never-closing channel so a select doesn't fire.
func (s *session) pausedCh() <-chan struct{} {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.paused {
		return s.pauseCh
	}
	// Allocate fresh so the caller's select can't accidentally fire.
	return make(chan struct{})
}

// sendEnvelope wraps payload in the standard envelope, increments the server
// seq counter, and writes the frame as JSON. JSON-marshal errors fail the
// session — they indicate a coding mistake, not a network issue.
func (s *session) sendEnvelope(ctx context.Context, msgType string, payload any) error {
	raw, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshaling %s payload: %w", msgType, err)
	}

	s.mu.Lock()
	s.seq++
	seq := s.seq
	s.mu.Unlock()

	env := Envelope{
		Type:      msgType,
		SessionID: s.sessionID,
		Seq:       seq,
		TS:        rfc3339(time.Now().UTC()),
		Payload:   raw,
	}

	if err := wsjson.Write(ctx, s.conn, env); err != nil {
		return fmt.Errorf("writing %s frame: %w", msgType, err)
	}
	return nil
}

func (s *session) currentSeq() int64 {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.seq
}

// isClosed returns true for the family of "remote went away" errors a clean
// shutdown can produce — nhooyr/websocket close errors and EOF-equivalents.
func isClosed(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, errClientEnded) {
		return true
	}
	var ce websocket.CloseError
	if errors.As(err, &ce) {
		return true
	}
	return false
}
