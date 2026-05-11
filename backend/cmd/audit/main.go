// Command audit consumes lifecycle events from NATS JetStream and
// appends them to the tamper-evident audit_log Postgres table, while
// also serving a query API for compliance lookups.
//
// NATS subject convention (consumed):
//
//	audit.events.{asc_id}
//
// Envelope (JSON, snake_case):
//
//	{
//	  "id":            "<uuidv7>",
//	  "session_id":    "...",            // optional
//	  "actor_user_id": "...",            // optional
//	  "asc_id":        "...",            // required
//	  "action":        "session_created",
//	  "target_id":     "...",            // optional
//	  "target_type":   "session",        // optional
//	  "payload":       {},               // optional, MUST NOT contain PHI keys
//	  "ts":            "2026-05-11T14:32:18.123-04:00"
//	}
//
// HTTP query API (port 8085 by default, override via HTTP_ADDR):
//
//	GET /healthz
//	GET /api/v1/audit/sessions/{session_id}              (compliance/admin role)
//	GET /api/v1/audit/users/{user_id}?from=...&to=...    (compliance/admin role)
package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"github.com/tonimnim/hst-scribe/backend/internal/audit"
	"github.com/tonimnim/hst-scribe/backend/internal/auth"
	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/natsbroker"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
	"github.com/tonimnim/hst-scribe/backend/internal/pg"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "audit: fatal: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}
	if os.Getenv("SERVICE_NAME") == "" {
		cfg.ServiceName = "audit"
	}
	if os.Getenv("HTTP_ADDR") == "" {
		cfg.HTTPAddr = ":8085"
	}

	logger := obs.NewLogger(cfg)
	logger.Info("audit starting",
		slog.String("env", string(cfg.Env)),
		slog.String("addr", cfg.HTTPAddr),
	)

	// Root context lives for the lifetime of the process. We cancel on
	// SIGINT/SIGTERM; subordinate timeouts apply to individual calls.
	rootCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	pool, err := pg.NewPool(rootCtx, cfg, logger)
	if err != nil {
		return fmt.Errorf("postgres: %w", err)
	}
	defer pool.Close()

	if err := verifyMigrations(rootCtx, pool); err != nil {
		return fmt.Errorf("migration check: %w", err)
	}

	nc, err := natsbroker.NewConn(rootCtx, cfg, logger)
	if err != nil {
		return fmt.Errorf("nats: %w", err)
	}
	defer func() {
		if closeErr := nc.Close(); closeErr != nil {
			logger.Warn("nats close error", slog.String("err", closeErr.Error()))
		}
	}()

	validator, err := auth.NewHMACValidator(cfg)
	if err != nil {
		return fmt.Errorf("building auth validator: %w", err)
	}

	repo := audit.NewPGRepository(pool)
	apiServer := audit.NewServer(repo, validator, logger)
	subscriber := audit.NewSubscriber(nc.JS, repo, logger)

	// Run the NATS subscriber in its own goroutine. Errors propagate
	// through subErrCh so main can decide whether to abort startup or
	// shut down cleanly.
	subErrCh := make(chan error, 1)
	go func() {
		if subErr := subscriber.Run(rootCtx); subErr != nil {
			subErrCh <- subErr
			return
		}
		subErrCh <- nil
	}()

	// Build the HTTP router around the audit Server, with the standard
	// observability stack mounted as cross-cutting middleware.
	root := chi.NewRouter()
	root.Use(middleware.RequestID)
	root.Use(obs.LoggingMiddleware(logger))
	root.Use(httperr.Recoverer(logger))
	root.Mount("/", apiServer.Routes())

	srv := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           root,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	// Run the HTTP server in its own goroutine so we can race it with
	// rootCtx and subErrCh.
	httpErrCh := make(chan error, 1)
	go func() {
		logger.Info("http listening", slog.String("addr", srv.Addr))
		if listenErr := srv.ListenAndServe(); listenErr != nil && !errors.Is(listenErr, http.ErrServerClosed) {
			httpErrCh <- fmt.Errorf("http listen: %w", listenErr)
			return
		}
		httpErrCh <- nil
	}()

	// Wait for shutdown signal OR a fatal subsystem error.
	select {
	case <-rootCtx.Done():
		logger.Info("shutdown signal received; draining")
	case err := <-httpErrCh:
		if err != nil {
			return err
		}
	case err := <-subErrCh:
		if err != nil {
			logger.Error("subscriber stopped", slog.String("err", err.Error()))
			// Fall through to graceful HTTP shutdown.
		}
	}

	// Drain HTTP, then NATS. We give HTTP shutdownTimeout seconds; NATS
	// drain is bounded by the consumer's ack-wait window.
	shutdownTimeout := time.Duration(cfg.ShutdownTimeoutSeconds) * time.Second
	shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(rootCtx), shutdownTimeout)
	defer cancel()
	if shutdownErr := srv.Shutdown(shutdownCtx); shutdownErr != nil {
		logger.Warn("http shutdown error", slog.String("err", shutdownErr.Error()))
	}

	subscriber.Close()
	logger.Info("audit stopped cleanly")
	return nil
}

// verifyMigrations sanity-checks that 0006_audit_log has been applied
// before we start consuming. We do NOT run migrations here — Makefile
// owns `goose up`. This is a fail-fast guard so an operator who forgot
// to migrate sees the error at startup instead of in production traffic.
func verifyMigrations(ctx context.Context, pool *pg.Pool) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	const q = `SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_log'`
	var n int
	if err := pool.QueryRow(ctx, q).Scan(&n); err != nil {
		return fmt.Errorf("audit_log table not present (run migrations): %w", err)
	}
	return nil
}
