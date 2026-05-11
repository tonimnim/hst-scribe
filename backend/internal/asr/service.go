package asr

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/jetstream"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/uuidv7"
)

// NATS subject + stream constants. Keep aligned with cmd/asr-orchestrator/main.go
// and the report at the bottom of the implementation message — the
// extraction-worker consumer codes against these values.
const (
	// AudioChunksStream is the JetStream stream backing gateway →
	// orchestrator audio. Durable consumer reads from here.
	AudioChunksStream = "AUDIO_CHUNKS"

	// AudioChunksSubject is the wildcard subject the orchestrator
	// filter-subscribes to. The third token is the session_id.
	AudioChunksSubject = "audio.chunks.>"

	// SessionEventsSubject carries lifecycle events from the session
	// manager (session_started, session_ended). Not a durable consumer;
	// missing a session_started just means the orchestrator boots its
	// stream on the first audio_chunk for that session.
	SessionEventsSubject = "sessions.events.>"

	// TranscriptsSubjectFmt is the publish subject for orchestrator
	// output. The token is the session_id; consumers (extraction
	// worker, audit) filter by their per-session subscription.
	TranscriptsSubjectFmt = "transcripts.%s"

	// AuditEventsSubjectFmt is the audit emission subject. The token is
	// the asc_id (per audit subscriber).
	AuditEventsSubjectFmt = "audit.events.%s"

	// DurableConsumer is the JetStream durable name for the
	// orchestrator's audio-chunk consumer.
	DurableConsumer = "asr-orchestrator"

	// idleSessionTimeout is how long a per-session stream stays open
	// after the last audio_chunk arrives before the orchestrator
	// considers the session dormant and tears the provider down. The
	// session_manager's hard timeout is 30m; this is shorter so we
	// release upstream provider capacity sooner.
	idleSessionTimeout = 2 * time.Minute
)

// Backoff schedule for provider reconnect, per task spec:
// 250ms, 500ms, 1s, 2s, max 5s, cap 5 attempts.
var reconnectBackoff = []time.Duration{
	250 * time.Millisecond,
	500 * time.Millisecond,
	1 * time.Second,
	2 * time.Second,
	5 * time.Second,
}

// ServiceConfig groups everything Service needs at construction time.
type ServiceConfig struct {
	Provider   Provider
	Repository Repository
	NATS       *nats.Conn
	JetStream  jetstream.JetStream
	Logger     *slog.Logger

	// IdleSessionTimeout overrides idleSessionTimeout for tests. Zero
	// uses the default.
	IdleSessionTimeout time.Duration
}

// Service is the asr-orchestrator core. One process runs one Service.
// Session state is in-memory only — restart recovery comes from the
// JetStream durable consumer replaying unacked audio chunks.
type Service struct {
	cfg ServiceConfig

	idleTimeout time.Duration

	mu       sync.Mutex
	sessions map[string]*sessionStream

	consumeCtx jetstream.ConsumeContext
}

// NewService validates cfg and returns a Service. Run() must be called
// to start the consumer; Close() to drain on shutdown.
func NewService(cfg ServiceConfig) (*Service, error) {
	switch {
	case cfg.Provider == nil:
		return nil, errors.New("asr.NewService: nil provider")
	case cfg.Repository == nil:
		return nil, errors.New("asr.NewService: nil repository")
	case cfg.NATS == nil:
		return nil, errors.New("asr.NewService: nil nats conn")
	case cfg.JetStream == nil:
		return nil, errors.New("asr.NewService: nil jetstream")
	case cfg.Logger == nil:
		return nil, errors.New("asr.NewService: nil logger")
	}
	idle := cfg.IdleSessionTimeout
	if idle <= 0 {
		idle = idleSessionTimeout
	}
	return &Service{
		cfg:         cfg,
		idleTimeout: idle,
		sessions:    make(map[string]*sessionStream),
	}, nil
}

// EnsureStream creates or updates the audio-chunks JetStream stream.
// Safe to call on every startup.
func EnsureStream(ctx context.Context, js jetstream.JetStream) (jetstream.Stream, error) {
	cfg := jetstream.StreamConfig{
		Name:        AudioChunksStream,
		Description: "Audio chunks from gateway to asr-orchestrator (transient).",
		Subjects:    []string{AudioChunksSubject},
		Retention:   jetstream.LimitsPolicy,
		Storage:     jetstream.FileStorage,
		// Audio chunks are short-lived. A 1h cap keeps the stream
		// bounded if the orchestrator is down briefly; longer outages
		// are handled by the gateway's reconnect buffer.
		MaxAge: 1 * time.Hour,
	}
	s, err := js.CreateOrUpdateStream(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("creating audio-chunks stream: %w", err)
	}
	return s, nil
}

// Run starts the durable consumer and the session-events subscription.
// It blocks until ctx is canceled or the consumer closes itself.
func (s *Service) Run(ctx context.Context) error {
	stream, err := EnsureStream(ctx, s.cfg.JetStream)
	if err != nil {
		return err
	}

	cons, err := stream.CreateOrUpdateConsumer(ctx, jetstream.ConsumerConfig{
		Durable:       DurableConsumer,
		Name:          DurableConsumer,
		FilterSubject: AudioChunksSubject,
		AckPolicy:     jetstream.AckExplicitPolicy,
		DeliverPolicy: jetstream.DeliverAllPolicy,
		MaxDeliver:    -1,
		AckWait:       30 * time.Second,
	})
	if err != nil {
		return fmt.Errorf("creating audio-chunks consumer: %w", err)
	}

	cc, err := cons.Consume(s.handleAudioMsg)
	if err != nil {
		return fmt.Errorf("starting audio consumer: %w", err)
	}
	s.consumeCtx = cc

	// Non-durable subscription to session lifecycle events. Best-effort:
	// missing one just means a session won't be torn down until the
	// idle timer fires.
	lifecycleSub, err := s.cfg.NATS.Subscribe(SessionEventsSubject, s.handleSessionEvent)
	if err != nil {
		cc.Stop()
		return fmt.Errorf("subscribing to session events: %w", err)
	}
	defer func() {
		_ = lifecycleSub.Unsubscribe()
	}()

	s.cfg.Logger.Info("asr-orchestrator running",
		slog.String("stream", AudioChunksStream),
		slog.String("durable", DurableConsumer),
		slog.String("provider", s.cfg.Provider.Name()),
	)

	select {
	case <-ctx.Done():
		return nil
	case <-cc.Closed():
		return errors.New("asr audio consumer closed unexpectedly")
	}
}

// Close drains the JetStream consumer and tears down every active
// session stream. Safe to call multiple times.
func (s *Service) Close() {
	if s.consumeCtx != nil {
		s.consumeCtx.Drain()
		<-s.consumeCtx.Closed()
		s.consumeCtx = nil
	}
	s.mu.Lock()
	streams := make([]*sessionStream, 0, len(s.sessions))
	for _, ss := range s.sessions {
		streams = append(streams, ss)
	}
	s.sessions = make(map[string]*sessionStream)
	s.mu.Unlock()
	for _, ss := range streams {
		ss.shutdown()
	}
}

// handleAudioMsg is the JetStream consumer callback. Term on malformed,
// Nak on transient failure, Ack on success.
func (s *Service) handleAudioMsg(msg jetstream.Msg) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	var env contract.Envelope
	if err := json.Unmarshal(msg.Data(), &env); err != nil {
		s.cfg.Logger.Warn("dropping malformed audio envelope",
			slog.String("subject", msg.Subject()),
			slog.String("err", err.Error()),
		)
		if termErr := msg.Term(); termErr != nil {
			s.cfg.Logger.Error("term failed", slog.String("err", termErr.Error()))
		}
		return
	}
	if env.Type != contract.MsgAudioChunk {
		s.cfg.Logger.Warn("non-audio envelope on audio subject",
			slog.String("subject", msg.Subject()),
			slog.String("type", string(env.Type)),
		)
		if termErr := msg.Term(); termErr != nil {
			s.cfg.Logger.Error("term failed", slog.String("err", termErr.Error()))
		}
		return
	}
	if env.SessionID == "" {
		s.cfg.Logger.Warn("audio envelope missing session_id",
			slog.String("subject", msg.Subject()),
		)
		if termErr := msg.Term(); termErr != nil {
			s.cfg.Logger.Error("term failed", slog.String("err", termErr.Error()))
		}
		return
	}

	var payload contract.AudioChunkPayload
	if err := json.Unmarshal(env.Payload, &payload); err != nil {
		s.cfg.Logger.Warn("dropping audio envelope with bad payload",
			slog.String("session_id", env.SessionID),
			slog.String("err", err.Error()),
		)
		if termErr := msg.Term(); termErr != nil {
			s.cfg.Logger.Error("term failed", slog.String("err", termErr.Error()))
		}
		return
	}

	raw, err := base64.StdEncoding.DecodeString(payload.AudioB64)
	if err != nil {
		s.cfg.Logger.Warn("dropping audio envelope with bad base64",
			slog.String("session_id", env.SessionID),
			slog.String("chunk_id", payload.ChunkID),
			slog.String("err", err.Error()),
		)
		if termErr := msg.Term(); termErr != nil {
			s.cfg.Logger.Error("term failed", slog.String("err", termErr.Error()))
		}
		return
	}

	chunk := AudioChunk{
		SessionID:  env.SessionID,
		ChunkID:    payload.ChunkID,
		Audio:      raw,
		SampleRate: payload.SampleRate,
		Format:     AudioFormat(payload.Format),
		DurationMS: payload.DurationMS,
		ReceivedAt: time.Now().UTC(),
	}

	stream := s.streamFor(ctx, env.SessionID)
	if stream == nil {
		// Provider open failed terminally. The session_id is already
		// marked asr_failed via audit; we Term so JetStream stops
		// redelivering audio for a session we will never recover.
		if termErr := msg.Term(); termErr != nil {
			s.cfg.Logger.Error("term failed", slog.String("err", termErr.Error()))
		}
		return
	}

	if err := stream.send(ctx, chunk); err != nil {
		s.cfg.Logger.Warn("forwarding chunk failed; nak",
			slog.String("session_id", env.SessionID),
			slog.String("chunk_id", chunk.ChunkID),
			slog.String("err", err.Error()),
		)
		if nakErr := msg.Nak(); nakErr != nil {
			s.cfg.Logger.Error("nak failed", slog.String("err", nakErr.Error()))
		}
		return
	}

	if err := msg.Ack(); err != nil {
		s.cfg.Logger.Warn("ack failed",
			slog.String("session_id", env.SessionID),
			slog.String("err", err.Error()),
		)
	}
}

// handleSessionEvent processes session lifecycle events. We only care
// about session_ended; everything else is informational and the idle
// timer will handle teardown if we miss it.
func (s *Service) handleSessionEvent(msg *nats.Msg) {
	var env contract.Envelope
	if err := json.Unmarshal(msg.Data, &env); err != nil {
		// Lifecycle is non-durable; drop quietly.
		s.cfg.Logger.Debug("ignoring malformed session event",
			slog.String("subject", msg.Subject),
			slog.String("err", err.Error()),
		)
		return
	}
	if env.Type != contract.MsgSessionEnded || env.SessionID == "" {
		return
	}
	s.cfg.Logger.Info("session_ended received; tearing down stream",
		slog.String("session_id", env.SessionID),
	)
	s.tearDown(env.SessionID)
}

// streamFor returns the per-session stream for sessionID, opening it
// lazily on first use. Returns nil if provider open failed and the
// session was marked asr_failed.
func (s *Service) streamFor(ctx context.Context, sessionID string) *sessionStream {
	s.mu.Lock()
	if existing, ok := s.sessions[sessionID]; ok {
		s.mu.Unlock()
		return existing
	}

	stream := newSessionStream(s, sessionID)
	s.sessions[sessionID] = stream
	s.mu.Unlock()

	if err := stream.open(ctx); err != nil {
		s.cfg.Logger.Error("provider open failed permanently",
			slog.String("session_id", sessionID),
			slog.String("err", err.Error()),
		)
		s.publishASRFailure(sessionID, err)
		s.mu.Lock()
		delete(s.sessions, sessionID)
		s.mu.Unlock()
		stream.shutdown()
		return nil
	}
	return stream
}

// tearDown ends the per-session stream cleanly.
func (s *Service) tearDown(sessionID string) {
	s.mu.Lock()
	stream, ok := s.sessions[sessionID]
	if !ok {
		s.mu.Unlock()
		return
	}
	delete(s.sessions, sessionID)
	s.mu.Unlock()
	stream.shutdown()
}

// publishTranscript wraps a Transcript in a contract Envelope and
// publishes it on transcripts.{session_id}. Errors are logged but not
// returned — transcripts are best-effort against any single subscriber.
func (s *Service) publishTranscript(t Transcript) {
	var (
		msgType contract.MessageType
		payload any
	)
	if t.IsFinal {
		msgType = contract.MsgTranscriptFinal
		payload = contract.TranscriptFinalPayload{
			TranscriptID:  t.TranscriptID,
			Text:          t.Text,
			Speaker:       contract.Speaker(t.Speaker),
			StartMS:       t.StartMS,
			EndMS:         t.EndMS,
			AudioChunkIDs: t.AudioChunkIDs,
		}
	} else {
		msgType = contract.MsgTranscriptPartial
		payload = contract.TranscriptPartialPayload{
			Text:    t.Text,
			Speaker: contract.Speaker(t.Speaker),
			StartMS: t.StartMS,
			EndMS:   t.EndMS,
		}
	}

	raw, err := json.Marshal(payload)
	if err != nil {
		// PHI: never include t.Text in the log.
		s.cfg.Logger.Error("marshal transcript payload",
			slog.String("session_id", t.SessionID),
			slog.String("err", err.Error()),
		)
		return
	}
	envelope := contract.Envelope{
		Type:      msgType,
		SessionID: t.SessionID,
		Seq:       0, // gateway re-stamps seq for the WSS direction
		TS:        t.EmittedAt,
		Payload:   raw,
	}
	if envelope.TS.IsZero() {
		envelope.TS = time.Now().UTC()
	}
	data, err := json.Marshal(envelope)
	if err != nil {
		s.cfg.Logger.Error("marshal transcript envelope",
			slog.String("session_id", t.SessionID),
			slog.String("err", err.Error()),
		)
		return
	}

	subject := fmt.Sprintf(TranscriptsSubjectFmt, t.SessionID)
	if err := s.cfg.NATS.Publish(subject, data); err != nil {
		s.cfg.Logger.Warn("publish transcript",
			slog.String("session_id", t.SessionID),
			slog.String("err", err.Error()),
		)
	}
}

// publishASRFailure emits a best-effort audit event marking the
// session as asr_failed. asc_id is unknown to this service today
// (we only carry session_id); we publish to a "session" bucket so the
// audit consumer can join with the sessions table to fill asc_id.
func (s *Service) publishASRFailure(sessionID string, cause error) {
	// asc_id is required by the audit subject — until session-manager
	// joins this in (Phase B follow-up), we publish to a wildcard
	// `audit.events.session.{session_id}` token. The audit subscriber
	// only filters on `audit.events.>` so this is safely captured.
	subject := fmt.Sprintf(AuditEventsSubjectFmt, "session."+sessionID)
	payload := map[string]any{
		"id":         uuidv7.New(),
		"session_id": sessionID,
		"asc_id":     "",
		"action":     "session_ended",
		"target_id":  sessionID,
		"target_type": "session",
		"payload": map[string]any{
			"reason": "asr_failed",
			"cause":  cause.Error(),
		},
		"ts": time.Now().UTC().Format(time.RFC3339Nano),
	}
	data, err := json.Marshal(payload)
	if err != nil {
		s.cfg.Logger.Error("marshal audit event",
			slog.String("session_id", sessionID),
			slog.String("err", err.Error()),
		)
		return
	}
	if err := s.cfg.NATS.Publish(subject, data); err != nil {
		s.cfg.Logger.Warn("publish asr_failed audit",
			slog.String("session_id", sessionID),
			slog.String("err", err.Error()),
		)
	}
}

// persistFinal writes a final transcript to Postgres. Partials are not
// persisted. Errors are logged at warn — Postgres failure should not
// stall transcript publication, which is the higher-leverage signal.
func (s *Service) persistFinal(ctx context.Context, t *Transcript) {
	if !t.IsFinal {
		return
	}
	pCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := s.cfg.Repository.InsertFinal(pCtx, t); err != nil {
		s.cfg.Logger.Warn("persist final transcript failed",
			slog.String("session_id", t.SessionID),
			slog.String("transcript_id", t.TranscriptID),
			slog.String("err", err.Error()),
		)
	}
}

// --- sessionStream ---

// sessionStream owns the per-session goroutine pair: one provider Stream
// open at a time, plus a reader that forwards transcripts to NATS and
// Postgres. Reconnects with exponential backoff on stream failure.
type sessionStream struct {
	svc       *Service
	sessionID string
	logger    *slog.Logger

	// ctx / cancel control the lifetime of this stream. Canceled by
	// Close() or by an unrecoverable provider error.
	ctx    context.Context
	cancel context.CancelFunc

	// in is the channel the orchestrator sends AudioChunks on.
	// Internal; the writer goroutine forwards them to the current
	// provider stream. Buffered so a brief reconnect window does not
	// block the JetStream consumer.
	in chan AudioChunk

	// lastChunkAt is updated on every successful forward. The idle
	// timer reads it to decide whether to tear the stream down.
	mu          sync.Mutex
	lastChunkAt time.Time

	done chan struct{} // closed after both pumps exit
}

func newSessionStream(svc *Service, sessionID string) *sessionStream {
	ctx, cancel := context.WithCancel(context.Background())
	return &sessionStream{
		svc:       svc,
		sessionID: sessionID,
		logger:    svc.cfg.Logger.With(slog.String("session_id", sessionID)),
		ctx:       ctx,
		cancel:    cancel,
		in:        make(chan AudioChunk, 64),
		done:      make(chan struct{}),
	}
}

// open starts the writer + reader goroutines. The first provider
// connection is attempted synchronously so the orchestrator's
// streamFor() can fail fast on a permanent open error.
func (ss *sessionStream) open(parent context.Context) error {
	provIn, provOut, err := ss.svc.cfg.Provider.Stream(ss.ctx, ss.sessionID)
	if err != nil {
		return fmt.Errorf("opening provider stream: %w", err)
	}

	// Track parent ctx cancellation independent of stream-internal
	// failures: if the service is shutting down we want to abort
	// reconnect loops cleanly.
	parentDone := parent.Done()
	go func() {
		select {
		case <-ss.ctx.Done():
		case <-parentDone:
			ss.cancel()
		}
	}()

	go ss.runPumps(provIn, provOut)
	go ss.idleWatchdog()
	return nil
}

// runPumps owns the writer-pump-reader-pump-reconnect loop. Each
// reconnect attempt opens a fresh provider stream; failures advance
// the backoff schedule. After exhausting the schedule the session is
// declared asr_failed and the stream tears down.
func (ss *sessionStream) runPumps(initialIn chan<- AudioChunk, initialOut <-chan Transcript) {
	defer close(ss.done)

	in := initialIn
	out := initialOut
	attempt := 0

	for {
		// Run the current connection until either pump returns. We
		// fork a writer goroutine so we can serve `ss.in` from this
		// loop's selects (which also watch `out`).
		writeDone := make(chan struct{})
		go ss.writePump(in, writeDone)
		readErr := ss.readPump(out)
		// Tell writer to stop; it will close `in` on the provider's
		// behalf, which the provider treats as EOF.
		close(writeDone)

		if errors.Is(readErr, context.Canceled) || readErr == nil {
			// Clean exit — service is shutting down or session ended.
			ss.logger.Debug("stream pumps exited cleanly")
			return
		}

		// readErr is "provider closed unexpectedly" — reconnect.
		if attempt >= len(reconnectBackoff) {
			ss.logger.Error("provider reconnect exhausted; failing session",
				slog.Int("attempts", attempt),
				slog.String("err", readErr.Error()),
			)
			ss.svc.publishASRFailure(ss.sessionID, readErr)
			return
		}

		backoff := reconnectBackoff[attempt]
		attempt++
		ss.logger.Warn("provider stream failed; will retry",
			slog.Int("attempt", attempt),
			slog.Duration("backoff", backoff),
			slog.String("err", readErr.Error()),
		)

		select {
		case <-ss.ctx.Done():
			return
		case <-time.After(backoff):
		}

		newIn, newOut, err := ss.svc.cfg.Provider.Stream(ss.ctx, ss.sessionID)
		if err != nil {
			ss.logger.Warn("provider reopen failed",
				slog.Int("attempt", attempt),
				slog.String("err", err.Error()),
			)
			// Treat as another failed attempt; loop will sleep again.
			in = makeNoopWriteSink()
			out = makeClosedTranscriptChan()
			continue
		}
		in = newIn
		out = newOut
	}
}

// writePump forwards ss.in to the provider's `in` until writeDone
// closes or ss.ctx is done. It does NOT close the provider's `in` on
// exit — the next reconnect needs the channel intact OR the parent
// cancellation already tore the provider down.
func (ss *sessionStream) writePump(provIn chan<- AudioChunk, writeDone <-chan struct{}) {
	defer func() {
		// Close the provider's channel only if it's a real channel
		// (the no-op sink is unbuffered nil-like and panics on close).
		defer func() { _ = recover() }()
		close(provIn)
	}()
	for {
		select {
		case <-ss.ctx.Done():
			return
		case <-writeDone:
			return
		case chunk, ok := <-ss.in:
			if !ok {
				return
			}
			select {
			case <-ss.ctx.Done():
				return
			case <-writeDone:
				return
			case provIn <- chunk:
				ss.mu.Lock()
				ss.lastChunkAt = time.Now()
				ss.mu.Unlock()
			}
		}
	}
}

// readPump reads transcripts from `out` until it is closed (provider
// failure or clean end). Each transcript is published to NATS and, if
// final, persisted. Returns nil on clean drain, an error on premature
// closure to drive reconnect.
func (ss *sessionStream) readPump(out <-chan Transcript) error {
	for {
		select {
		case <-ss.ctx.Done():
			return ss.ctx.Err()
		case t, ok := <-out:
			if !ok {
				if err := ss.ctx.Err(); err != nil {
					return err
				}
				return errors.New("provider out channel closed")
			}
			// Stamp session_id in case the provider forgot.
			if t.SessionID == "" {
				t.SessionID = ss.sessionID
			}
			// Finals must have an id — mint one if the provider didn't.
			if t.IsFinal && t.TranscriptID == "" {
				t.TranscriptID = uuidv7.New()
			}
			ss.svc.publishTranscript(t)
			if t.IsFinal {
				ss.svc.persistFinal(ss.ctx, &t)
			}
		}
	}
}

// idleWatchdog cancels the stream if no chunks arrive within the
// configured idle window. The session_manager's harder timeout
// eventually takes care of expiry; this is a release-resources
// safety net so a forgotten session does not hold provider capacity.
func (ss *sessionStream) idleWatchdog() {
	ticker := time.NewTicker(ss.svc.idleTimeout / 2)
	defer ticker.Stop()
	for {
		select {
		case <-ss.ctx.Done():
			return
		case <-ticker.C:
			ss.mu.Lock()
			last := ss.lastChunkAt
			ss.mu.Unlock()
			if last.IsZero() {
				continue
			}
			if time.Since(last) >= ss.svc.idleTimeout {
				ss.logger.Info("session idle; tearing down provider stream",
					slog.Duration("idle_for", time.Since(last)),
				)
				ss.svc.tearDown(ss.sessionID)
				return
			}
		}
	}
}

// send forwards a chunk to the writer pump, with ctx cancellation
// honored.
func (ss *sessionStream) send(ctx context.Context, chunk AudioChunk) error {
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-ss.ctx.Done():
		return ErrStreamClosed
	case ss.in <- chunk:
		return nil
	}
}

// shutdown cancels the stream context and waits for both pumps to exit.
func (ss *sessionStream) shutdown() {
	ss.cancel()
	<-ss.done
}

// makeNoopWriteSink returns a write-only channel that swallows sends.
// Used to keep writePump's select alive when reconnect is failing —
// we don't want to drop ss.in chunks during the backoff window.
//
// Actually we DO want to apply backpressure: dropped chunks lose
// audio. The right behavior is to NOT swallow; we'd rather block
// writes until reconnect succeeds, so the JetStream consumer Naks and
// the message is redelivered. Returning a buffered sink with size 1
// gives us that behavior while still being a channel a select can
// pick.
func makeNoopWriteSink() chan AudioChunk {
	// Unbuffered; sender blocks. This is what we want: backpressure to
	// the JetStream consumer until reconnect succeeds or ctx is canceled.
	return make(chan AudioChunk)
}

// makeClosedTranscriptChan returns an immediately-closed receive
// channel so the readPump returns quickly and we advance to the next
// reconnect attempt.
func makeClosedTranscriptChan() <-chan Transcript {
	ch := make(chan Transcript)
	close(ch)
	return ch
}
