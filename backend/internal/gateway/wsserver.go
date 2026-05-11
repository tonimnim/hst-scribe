package gateway

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"github.com/go-chi/chi/v5"
	"golang.org/x/sync/errgroup"
	"nhooyr.io/websocket"

	"github.com/tonimnim/hst-scribe/backend/internal/auth"
	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
	wssproto "github.com/tonimnim/hst-scribe/backend/internal/wss"
)

const (
	// audioIdleTimeout is the sanity-check inactivity bound on the WSS
	// audio stream. The session-manager owns the canonical 30-min
	// session-level timeout (PRD FR9); this catches stuck connections
	// where the client stopped sending but kept the socket open.
	audioIdleTimeout = 30 * time.Second

	// wsReadLimit caps a single WSS frame. 1 MiB is comfortable headroom
	// for a 250 ms PCM16 chunk (~8 KB) base64-encoded.
	wsReadLimit = 1 << 20

	// wsWriteTimeout caps the time we will block writing a single frame
	// before giving up on the client.
	wsWriteTimeout = 10 * time.Second
)

// WSServer is the gateway WSS handler. It depends on small interfaces
// so tests can swap NATS for an in-memory bus.
type WSServer struct {
	Logger         *slog.Logger
	SessionClient  *SessionManagerClient
	EChartClient   *EChartClient
	Publisher      Publisher
	Subscriber     Subscriber
	Validator      auth.Validator
	Registry       *SessionRegistry
	Capabilities   contract.ServerCapabilities
	OriginPatterns []string
}

// sessionConn is one active WSS session — produced on Accept, torn
// down by either loop exiting.
type sessionConn struct {
	sessionID string
	userID    string
	conn      *websocket.Conn

	logger *slog.Logger

	// outSeq is the server-side outbound counter (envelope.seq).
	outSeq wssproto.SeqCounter
	// inTrack enforces inbound seq monotonicity + chunk_id dedupe.
	inTrack *wssproto.IncomingTracker

	// replay is shared via SessionRegistry so reconnects can re-stream.
	replay *ReplayBuffer

	// writeMu protects writes against concurrent goroutines (reader
	// emits pong/error frames; main writer fans out NATS messages;
	// shutdown sends session_ended).
	writeMu sync.Mutex

	// lastAudio is the UnixNano of the most recent audio_chunk. Stored
	// as int64 to avoid the pointer dance of atomic.Pointer[time.Time].
	lastAudio atomic.Int64

	// closed is set when either loop has decided to tear down.
	closed atomic.Bool
}

// HandleStream is the chi handler for GET /api/v1/sessions/{session_id}/stream.
// The handler does the upgrade then hands off to runSession.
func (s *WSServer) HandleStream(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	logger := obs.LoggerFromContext(ctx)

	sessionID := chi.URLParam(r, "session_id")
	if sessionID == "" {
		httperr.WriteJSON(w, httperr.BadRequest("session_id is required", nil))
		return
	}

	// Auth: prefer Authorization header (set by the route middleware);
	// fall back to ?token= for clients that cannot set headers on
	// upgrade (some mobile WSS stacks).
	claims := auth.ClaimsFromContext(ctx)
	if claims == nil {
		token := r.URL.Query().Get("token")
		if token == "" {
			httperr.WriteJSON(w, httperr.AuthInvalid(""))
			return
		}
		c, err := s.Validator.Validate(ctx, token)
		if err != nil {
			var werr *httperr.Error
			if errors.As(err, &werr) {
				httperr.WriteJSON(w, werr)
				return
			}
			httperr.WriteJSON(w, httperr.AuthInvalid(""))
			return
		}
		claims = c
	}

	// Verify the session exists and belongs to this user before
	// upgrading. The session-manager enforces ASC + user binding.
	summary, err := s.SessionClient.GetSession(ctx, sessionID)
	if err != nil {
		writeWireError(w, logger, err)
		return
	}
	if summary.UserID != "" && summary.UserID != claims.UserID {
		httperr.WriteJSON(w, httperr.AuthForbidden("session does not belong to user"))
		return
	}
	if summary.Status == "signed" || summary.Status == "ended" {
		httperr.WriteJSON(w, httperr.SessionExpired(sessionID))
		return
	}

	patientCtx, err := s.EChartClient.GetPatientContext(ctx, summary.PatientID)
	if err != nil {
		writeWireError(w, logger, err)
		return
	}

	// Optional reconnection support via ?last_seq=<n>.
	var lastSeq uint64
	if v := r.URL.Query().Get("last_seq"); v != "" {
		n, err := strconv.ParseUint(v, 10, 64)
		if err != nil {
			httperr.WriteJSON(w, httperr.BadRequest("invalid last_seq", map[string]any{
				"last_seq": v,
			}))
			return
		}
		lastSeq = n
	}

	conn, err := websocket.Accept(w, r, &websocket.AcceptOptions{
		Subprotocols:   []string{"hst-scribe.v1"},
		OriginPatterns: s.OriginPatterns,
		// CompressionDisabled is the safe default for streamed PCM
		// envelopes — JSON is already small and the audio_b64 chunk
		// is incompressible. Avoids the CRIME-style risks of
		// per-message-deflate on a long-lived bidi stream.
	})
	if err != nil {
		// Accept already wrote a response header.
		logger.Warn("wss accept failed",
			slog.String("session_id", sessionID),
			slog.String("err", err.Error()),
		)
		return
	}
	conn.SetReadLimit(wsReadLimit)

	sc := &sessionConn{
		sessionID: sessionID,
		userID:    claims.UserID,
		conn:      conn,
		logger: logger.With(
			slog.String("session_id", sessionID),
			slog.String("user_id", claims.UserID),
		),
		inTrack: wssproto.NewIncomingTracker(),
		replay:  s.Registry.BufferFor(sessionID),
	}
	sc.lastAudio.Store(time.Now().UnixNano())

	if prev := s.Registry.SetLive(sessionID, sc); prev != nil {
		// A previous live connection exists — close it gracefully.
		// The contract permits at most one live WSS per session_id.
		prev.gracefulClose(ctx, "client_reconnected")
	}
	defer s.Registry.ClearLive(sessionID, sc)

	s.runSession(r.Context(), sc, patientCtx, lastSeq)
}

// runSession owns the lifecycle of one accepted WSS connection.
func (s *WSServer) runSession(parent context.Context, sc *sessionConn, patientCtx *contract.PatientContext, lastSeq uint64) {
	// Independent ctx so we can cancel internally without dragging the
	// HTTP request's ctx down.
	ctx, cancel := context.WithCancel(parent)
	defer cancel()

	// 1. session_started
	startedPayload := contract.SessionStartedPayload{
		ProtocolVersion:    contract.ProtocolVersion,
		PatientContext:     *patientCtx,
		ServerCapabilities: s.Capabilities,
	}
	if err := sc.send(ctx, contract.MsgSessionStarted, startedPayload); err != nil {
		sc.logger.Warn("send session_started failed", slog.String("err", err.Error()))
		_ = sc.conn.Close(websocket.StatusInternalError, "session start failed")
		return
	}

	// 2. Replay buffered frames if the client reconnected.
	if lastSeq > 0 {
		for _, raw := range sc.replay.ReplayFrom(lastSeq) {
			if err := sc.writeRaw(ctx, raw); err != nil {
				sc.logger.Warn("replay write failed", slog.String("err", err.Error()))
				_ = sc.conn.Close(websocket.StatusInternalError, "replay failed")
				return
			}
		}
	}

	// 3. Subscribe to per-session output topics.
	transcriptCh := make(chan []byte, 64)
	eventCh := make(chan []byte, 64)
	subTranscripts, err := s.Subscriber.Subscribe(ctx, SubjectTranscripts(sc.sessionID), func(data []byte) {
		select {
		case transcriptCh <- data:
		default:
			// Drop oldest by skipping — the client can recover via
			// replay or by reissuing the session. We do NOT block
			// the NATS callback goroutine.
		}
	})
	if err != nil {
		sc.logger.Warn("subscribe transcripts failed", slog.String("err", err.Error()))
		_ = sc.conn.Close(websocket.StatusInternalError, "broker subscribe failed")
		return
	}
	defer func() { _ = subTranscripts.Unsubscribe() }()

	subEvents, err := s.Subscriber.Subscribe(ctx, SubjectExtractedEvents(sc.sessionID), func(data []byte) {
		select {
		case eventCh <- data:
		default:
		}
	})
	if err != nil {
		sc.logger.Warn("subscribe events failed", slog.String("err", err.Error()))
		_ = sc.conn.Close(websocket.StatusInternalError, "broker subscribe failed")
		return
	}
	defer func() { _ = subEvents.Unsubscribe() }()

	// 4. Run reader + writer + idle watchdog. Cancellation of any
	// tears down the rest via errgroup.
	g, gctx := errgroup.WithContext(ctx)
	g.Go(func() error { return s.readLoop(gctx, sc) })
	g.Go(func() error { return s.writeLoop(gctx, sc, transcriptCh, eventCh) })
	g.Go(func() error { return s.idleLoop(gctx, sc) })

	if err := g.Wait(); err != nil && !errors.Is(err, context.Canceled) {
		sc.logger.Info("wss session ended with error", slog.String("err", err.Error()))
	}
	sc.closed.Store(true)
}

// readLoop consumes inbound frames until ctx is done or the client closes.
func (s *WSServer) readLoop(ctx context.Context, sc *sessionConn) error {
	for {
		mtype, raw, err := sc.conn.Read(ctx)
		if err != nil {
			// Normal close paths return *CloseError; treat them as nil.
			if isNormalClose(err) {
				return context.Canceled
			}
			return fmt.Errorf("ws read: %w", err)
		}
		if mtype != websocket.MessageText {
			sc.sendError(ctx, httperr.BadRequest("expected text frame", nil))
			continue
		}

		env, err := wssproto.Decode(raw)
		if err != nil {
			sc.sendError(ctx, httperr.BadRequest("invalid envelope", map[string]any{
				"err": err.Error(),
			}))
			continue
		}

		if err := sc.inTrack.Observe(env); err != nil {
			var werr *httperr.Error
			if errors.As(err, &werr) {
				sc.sendError(ctx, werr)
			} else {
				sc.sendError(ctx, httperr.BadRequest("seq error", nil))
			}
			continue
		}

		if err := s.dispatch(ctx, sc, env); err != nil {
			sc.logger.Warn("dispatch failed",
				slog.String("type", string(env.Type)),
				slog.String("err", err.Error()),
			)
			var werr *httperr.Error
			if errors.As(err, &werr) {
				sc.sendError(ctx, werr)
			} else {
				sc.sendError(ctx, httperr.Internal("dispatch failed"))
			}
		}
	}
}

// dispatch routes one inbound envelope to the right side-effect.
func (s *WSServer) dispatch(ctx context.Context, sc *sessionConn, env *contract.Envelope) error {
	switch env.Type {
	case contract.MsgAudioChunk:
		var p contract.AudioChunkPayload
		if err := json.Unmarshal(env.Payload, &p); err != nil {
			return httperr.BadRequest("invalid audio_chunk payload", nil)
		}
		if p.ChunkID == "" {
			return httperr.BadRequest("audio_chunk missing chunk_id", nil)
		}
		if p.Format != contract.AudioFormatPCM16 {
			return httperr.AudioFormatUnsupported(fmt.Sprintf("format %q", p.Format))
		}
		if p.SampleRate != 16000 {
			return httperr.AudioFormatUnsupported(fmt.Sprintf("sample_rate %d", p.SampleRate))
		}
		if !sc.inTrack.SeenChunk(p.ChunkID) {
			// Duplicate — ack via inactivity refresh but do NOT
			// re-publish to ASR. The client's resend buffer is
			// expected and dedupe is the gateway's job.
			sc.lastAudio.Store(time.Now().UnixNano())
			return nil
		}
		// Publish the *original envelope* — ASR orchestrator
		// expects the full contract envelope, not a stripped payload.
		raw, err := json.Marshal(env)
		if err != nil {
			return fmt.Errorf("re-marshal audio envelope: %w", err)
		}
		if err := s.Publisher.Publish(ctx, SubjectAudio(sc.sessionID), raw); err != nil {
			return httperr.Internal("publish audio chunk")
		}
		// Fire-and-forget activity heartbeat. Failures are warned
		// but do not affect the WSS stream.
		go func(sessionID string) {
			actCtx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
			defer cancel()
			if err := s.Publisher.Publish(actCtx, SubjectActivity(sessionID), []byte("{}")); err != nil {
				sc.logger.Debug("activity publish failed", slog.String("err", err.Error()))
			}
		}(sc.sessionID)
		sc.lastAudio.Store(time.Now().UnixNano())
		return nil

	case contract.MsgSessionPause, contract.MsgSessionResume:
		// Forward as activity events so the session-manager can
		// adjust its ASR billing state. Payload is empty by contract.
		raw, _ := json.Marshal(env)
		return s.Publisher.Publish(ctx, SubjectActivity(sc.sessionID), raw)

	case contract.MsgSessionEnd:
		raw, _ := json.Marshal(env)
		_ = s.Publisher.Publish(ctx, SubjectActivity(sc.sessionID), raw)
		// Send session_ended back and close the socket.
		final := sc.outSeq.Current()
		if err := sc.send(ctx, contract.MsgSessionEnded, contract.SessionEndedPayload{
			Reason:   "client_requested",
			FinalSeq: &final,
		}); err != nil {
			sc.logger.Warn("send session_ended failed", slog.String("err", err.Error()))
		}
		_ = sc.conn.Close(websocket.StatusNormalClosure, "client requested end")
		return context.Canceled

	case contract.MsgVoiceCommand:
		var p contract.VoiceCommandPayload
		if err := json.Unmarshal(env.Payload, &p); err != nil {
			return httperr.BadRequest("invalid voice_command payload", nil)
		}
		raw, _ := json.Marshal(env)
		return s.Publisher.Publish(ctx, SubjectActivity(sc.sessionID), raw)

	case contract.MsgPing:
		var p contract.PingPayload
		if len(env.Payload) > 0 {
			_ = json.Unmarshal(env.Payload, &p)
		}
		return sc.send(ctx, contract.MsgPong, contract.PongPayload{Nonce: p.Nonce})
	}
	return httperr.BadRequest(fmt.Sprintf("unsupported client message type %q", env.Type), nil)
}

// writeLoop fans broker messages out to the WSS client.
func (s *WSServer) writeLoop(ctx context.Context, sc *sessionConn, transcripts, events <-chan []byte) error {
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case data := <-transcripts:
			if err := sc.forward(ctx, data); err != nil {
				return err
			}
		case data := <-events:
			if err := sc.forward(ctx, data); err != nil {
				return err
			}
		}
	}
}

// idleLoop closes the connection if no audio_chunk has been received
// within audioIdleTimeout. This is a sanity check; the canonical
// inactivity policy lives in session-manager.
func (s *WSServer) idleLoop(ctx context.Context, sc *sessionConn) error {
	ticker := time.NewTicker(audioIdleTimeout / 2)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			if time.Since(time.Unix(0, sc.lastAudio.Load())) <= audioIdleTimeout {
				continue
			}
			sc.logger.Info("wss idle timeout — closing session")
			final := sc.outSeq.Current()
			_ = sc.send(ctx, contract.MsgSessionEnded, contract.SessionEndedPayload{
				Reason:   "inactivity_timeout",
				FinalSeq: &final,
			})
			_ = sc.conn.Close(websocket.StatusGoingAway, "idle timeout")
			return context.Canceled
		}
	}
}

// gracefulClose tells the client we are shutting down and closes the
// socket. Safe to call multiple times.
func (sc *sessionConn) gracefulClose(ctx context.Context, reason string) {
	if sc.closed.Swap(true) {
		return
	}
	final := sc.outSeq.Current()
	wctx, cancel := context.WithTimeout(ctx, wsWriteTimeout)
	defer cancel()
	_ = sc.send(wctx, contract.MsgSessionEnded, contract.SessionEndedPayload{
		Reason:   reason,
		FinalSeq: &final,
	})
	_ = sc.conn.Close(websocket.StatusGoingAway, reason)
}

// send marshals payload into an envelope, appends to the replay buffer,
// and writes to the socket.
func (sc *sessionConn) send(ctx context.Context, msgType contract.MessageType, payload any) error {
	seq := sc.outSeq.Next()
	now := time.Now().UTC()
	raw, err := wssproto.Encode(msgType, sc.sessionID, seq, now, payload)
	if err != nil {
		return fmt.Errorf("encode %s: %w", msgType, err)
	}
	sc.replay.Append(seq, now, raw)
	return sc.writeRaw(ctx, raw)
}

// forward replays a broker-originated envelope into the WSS stream,
// rewriting its seq to the next server-side value. The broker producers
// (asr-orchestrator, extraction-worker) emit envelopes with a placeholder
// seq=0 because they have no view of the gateway's outbound counter.
func (sc *sessionConn) forward(ctx context.Context, raw []byte) error {
	env, err := wssproto.Decode(raw)
	if err != nil {
		return fmt.Errorf("decode broker frame: %w", err)
	}
	// Re-marshal with our seq/ts so the client sees a monotonic stream.
	seq := sc.outSeq.Next()
	now := time.Now().UTC()
	out, err := wssproto.Encode(env.Type, sc.sessionID, seq, now, json.RawMessage(env.Payload))
	if err != nil {
		return fmt.Errorf("re-encode broker frame: %w", err)
	}
	sc.replay.Append(seq, now, out)
	return sc.writeRaw(ctx, out)
}

// writeRaw writes raw to the WSS connection under the write mutex.
func (sc *sessionConn) writeRaw(ctx context.Context, raw []byte) error {
	sc.writeMu.Lock()
	defer sc.writeMu.Unlock()
	wctx, cancel := context.WithTimeout(ctx, wsWriteTimeout)
	defer cancel()
	if err := sc.conn.Write(wctx, websocket.MessageText, raw); err != nil {
		return fmt.Errorf("ws write: %w", err)
	}
	return nil
}

// sendError pushes a wire-error envelope to the client. Failures are
// logged but never escalated — we are already in an error path.
func (sc *sessionConn) sendError(ctx context.Context, werr *httperr.Error) {
	payload := contract.ErrorPayload{
		Code:    string(werr.Code),
		Message: werr.Message,
		Details: werr.Details,
	}
	if err := sc.send(ctx, contract.MsgError, payload); err != nil {
		sc.logger.Debug("send error frame failed", slog.String("err", err.Error()))
	}
}

// isNormalClose reports whether err is a normal/graceful WSS close.
func isNormalClose(err error) bool {
	if err == nil {
		return true
	}
	if errors.Is(err, context.Canceled) {
		return true
	}
	status := websocket.CloseStatus(err)
	switch status {
	case websocket.StatusNormalClosure, websocket.StatusGoingAway, websocket.StatusNoStatusRcvd:
		return true
	}
	return false
}

// writeWireError serializes a *httperr.Error or maps an arbitrary error
// to one before writing.
func writeWireError(w http.ResponseWriter, logger *slog.Logger, err error) {
	var werr *httperr.Error
	if errors.As(err, &werr) {
		httperr.WriteJSON(w, werr)
		return
	}
	logger.Warn("downstream error", slog.String("err", err.Error()))
	httperr.WriteJSON(w, httperr.Internal("upstream service error"))
}

// CloseAll sends session_ended to every live WSS session. Used by the
// server's graceful-shutdown hook.
func (s *WSServer) CloseAll(ctx context.Context) {
	conns := s.Registry.Snapshot()
	var wg sync.WaitGroup
	for _, c := range conns {
		wg.Add(1)
		go func(c *sessionConn) {
			defer wg.Done()
			c.gracefulClose(ctx, "server_shutdown")
		}(c)
	}
	wg.Wait()
}
