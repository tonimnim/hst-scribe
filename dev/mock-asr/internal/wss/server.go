package wss

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"nhooyr.io/websocket"

	"github.com/tonimnim/hst-scribe/dev/mock-asr/internal/seed"
)

// Server is the mock ASR HTTP/WSS server. Construct via NewServer and call
// ListenAndServe; Shutdown closes the listener and drains in-flight sessions.
type Server struct {
	addr   string
	logger *slog.Logger

	emitInterval   time.Duration
	partialLeadIn  time.Duration
	partialToFinal time.Duration
	utterances     []seed.Utterance

	mu       sync.Mutex
	httpSrv  *http.Server
	sessions sync.WaitGroup
}

// Config bundles the values NewServer needs. Caller is responsible for
// loading these from env / disk.
type Config struct {
	Addr           string
	Logger         *slog.Logger
	EmitInterval   time.Duration
	PartialLeadIn  time.Duration
	PartialToFinal time.Duration
	Utterances     []seed.Utterance
}

// NewServer constructs a Server. It validates that utterances is non-empty —
// the mock has nothing to do otherwise.
func NewServer(cfg Config) (*Server, error) {
	if cfg.Logger == nil {
		return nil, errors.New("nil logger")
	}
	if len(cfg.Utterances) == 0 {
		return nil, errors.New("no utterances loaded")
	}
	if cfg.EmitInterval <= 0 {
		return nil, errors.New("emit interval must be positive")
	}

	return &Server{
		addr:           cfg.Addr,
		logger:         cfg.Logger,
		emitInterval:   cfg.EmitInterval,
		partialLeadIn:  cfg.PartialLeadIn,
		partialToFinal: cfg.PartialToFinal,
		utterances:     cfg.Utterances,
	}, nil
}

// Router builds the chi router. Exposed for tests that want to drive the
// server with httptest.
func (s *Server) Router() http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.Recoverer)

	r.Get("/healthz", s.handleHealthz)
	r.Get("/asr/v1/stream", s.handleStream)

	return r
}

// ListenAndServe blocks until ctx is canceled or the underlying server errors.
// On ctx cancel it gracefully shuts the HTTP server and waits for in-flight
// sessions to close.
func (s *Server) ListenAndServe(ctx context.Context) error {
	srv := &http.Server{
		Addr:              s.addr,
		Handler:           s.Router(),
		ReadHeaderTimeout: 5 * time.Second,
	}
	s.mu.Lock()
	s.httpSrv = srv
	s.mu.Unlock()

	errCh := make(chan error, 1)
	go func() {
		s.logger.Info("mock-asr listening", slog.String("addr", s.addr))
		errCh <- srv.ListenAndServe()
	}()

	select {
	case err := <-errCh:
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return fmt.Errorf("http server: %w", err)
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := srv.Shutdown(shutdownCtx); err != nil {
			s.logger.Warn("http shutdown error", slog.String("err", err.Error()))
		}
		s.sessions.Wait()
		return nil
	}
}

func (s *Server) handleHealthz(w http.ResponseWriter, _ *http.Request) {
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(`{"status":"ok"}`))
}

// handleStream upgrades to WSS and drives a session. Auth is a dev-only check:
// the header must be present and start with "Bearer ", but the token contents
// are not validated. Real ASR validates a JWT here.
func (s *Server) handleStream(w http.ResponseWriter, r *http.Request) {
	if !hasBearerAuth(r) {
		writeUnauthorized(w)
		return
	}

	conn, err := websocket.Accept(w, r, &websocket.AcceptOptions{
		// Dev-only — production sets an origin allowlist.
		InsecureSkipVerify: true,
	})
	if err != nil {
		s.logger.Warn("websocket accept failed", slog.String("err", err.Error()))
		return
	}

	s.sessions.Add(1)
	go func() {
		defer s.sessions.Done()
		defer func() {
			// Close codes: NormalClosure on clean exit, InternalError on panic
			// path (recovered by middleware before we get here, but be safe).
			_ = conn.Close(websocket.StatusNormalClosure, "session ended")
		}()

		// Detach from r.Context(): after handleStream returns, net/http cancels
		// the request context, which would tear down the upgraded WSS connection
		// immediately. The session owns its lifetime now — its read loop returns
		// when the client closes the socket or the OS connection drops.
		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()

		sess := newSession(conn, SessionConfig{
			EmitInterval:   s.emitInterval,
			PartialLeadIn:  s.partialLeadIn,
			PartialToFinal: s.partialToFinal,
			Utterances:     s.utterances,
		}, s.logger)

		s.logger.Info("session opened", slog.String("session_id", sess.sessionID))
		if err := sess.run(ctx); err != nil {
			s.logger.Warn("session ended with error",
				slog.String("session_id", sess.sessionID),
				slog.String("err", err.Error()),
			)
		} else {
			s.logger.Info("session closed cleanly", slog.String("session_id", sess.sessionID))
		}
	}()
}

func hasBearerAuth(r *http.Request) bool {
	h := r.Header.Get("Authorization")
	if h == "" {
		return false
	}
	return strings.HasPrefix(strings.ToLower(h), "bearer ")
}

func writeUnauthorized(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusUnauthorized)
	_, _ = w.Write([]byte(`{"code":"auth_invalid","message":"missing bearer token"}`))
}
