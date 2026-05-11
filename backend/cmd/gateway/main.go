// Command gateway is the public-facing HST Scribe ingress: REST API +
// WebSocket session stream. Phase 0 wiring is REST scaffolding + health
// + auth; the WSS handler arrives in Phase B.
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"github.com/tonimnim/hst-scribe/backend/internal/auth"
	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
)

func main() {
	if err := run(); err != nil {
		// We cannot rely on a structured logger if config load failed,
		// so fall back to stderr. This is the one place in the binary
		// allowed to use stdlib fmt for output.
		fmt.Fprintf(os.Stderr, "gateway: fatal: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}
	if cfg.ServiceName == "gateway" || cfg.ServiceName == "" {
		cfg.ServiceName = "gateway"
	}

	logger := obs.NewLogger(cfg)
	logger.Info("gateway starting", slog.String("env", string(cfg.Env)))

	validator, err := auth.NewHMACValidator(cfg)
	if err != nil {
		return fmt.Errorf("building auth validator: %w", err)
	}

	r := buildRouter(logger, validator)

	srv := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           r,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	shutdownTimeout := time.Duration(cfg.ShutdownTimeoutSeconds) * time.Second
	return obs.RunHTTPServer(context.Background(), logger, srv, shutdownTimeout)
}

func buildRouter(logger *slog.Logger, validator auth.Validator) http.Handler {
	r := chi.NewRouter()

	// Global middleware — order matters.
	r.Use(middleware.RequestID)
	r.Use(obs.LoggingMiddleware(logger))
	r.Use(httperr.Recoverer(logger))

	// Public health endpoint — no auth.
	r.Get("/healthz", healthHandler)

	// Authenticated API surface.
	r.Route("/api/v1", func(r chi.Router) {
		r.Use(auth.Authenticator(validator))
		r.Post("/sessions", createSessionHandler)
	})

	return r
}

func healthHandler(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(map[string]string{"status": "ok"}); err != nil {
		// Headers are already written; nothing useful to do.
		_ = err
	}
}

// createSessionHandler is a Phase-B stub. It validates the request body
// shape (catches obvious client bugs early) and then returns 501.
func createSessionHandler(w http.ResponseWriter, r *http.Request) {
	logger := obs.LoggerFromContext(r.Context())

	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()

	var req contract.CreateSessionRequest
	if err := dec.Decode(&req); err != nil && !errors.Is(err, io.EOF) {
		httperr.WriteJSON(w, httperr.BadRequest("invalid request body", map[string]any{
			"err": err.Error(),
		}))
		return
	}

	logger.Info("session create requested (stub)",
		slog.String("workflow_type", string(req.WorkflowType)),
		slog.String("asc_id", req.ASCID),
		slog.String("patient_id", req.PatientID),
	)
	httperr.WriteJSON(w, httperr.NotImplemented("session creation not yet implemented"))
}
