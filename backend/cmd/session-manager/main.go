// Command session-manager owns session lifecycle: patient lock,
// idempotent creation, expiry, and audit emission.
//
// Endpoints (all under :8081 by default):
//
//	GET  /healthz
//	POST /internal/v1/sessions               (X-Internal-Token required)
//	GET  /internal/v1/sessions/{id}          (X-Internal-Token required)
//	POST /internal/v1/sessions/{id}/end      (X-Internal-Token required)
//	POST /internal/v1/sessions/{id}/sign     (X-Internal-Token required)
//
// The gateway is the sole intended caller of /internal/v1 endpoints.
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
	chimw "github.com/go-chi/chi/v5/middleware"

	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/natsbroker"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
	"github.com/tonimnim/hst-scribe/backend/internal/pg"
	"github.com/tonimnim/hst-scribe/backend/internal/session"
)

// defaultAddr is used when HTTP_ADDR is not set.
const defaultAddr = ":8081"

// internalTokenEnv is the env var carrying the shared inter-service token.
const internalTokenEnv = "INTERNAL_SVC_TOKEN"

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "session-manager: fatal: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}
	// SERVICE_NAME defaults to "gateway" in config.Load; rebrand if the
	// operator did not override it explicitly.
	if os.Getenv("SERVICE_NAME") == "" {
		cfg.ServiceName = "session-manager"
	}
	if os.Getenv("HTTP_ADDR") == "" {
		cfg.HTTPAddr = defaultAddr
	}

	logger := obs.NewLogger(cfg)
	logger.Info("session-manager starting",
		slog.String("addr", cfg.HTTPAddr),
		slog.String("env", string(cfg.Env)),
	)

	// Lifecycle context covers the boot phase and propagates through to
	// the expiry worker. SIGINT/SIGTERM cancel it.
	rootCtx, stopSig := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stopSig()

	tracingCfg := obs.TracingConfig{ServiceName: cfg.ServiceName, Env: string(cfg.Env)}
	shutdownTracing, err := obs.InitTracing(rootCtx, tracingCfg)
	if err != nil {
		return fmt.Errorf("init tracing: %w", err)
	}
	obs.LogTracingInit(logger, tracingCfg)
	defer func() {
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := shutdownTracing(shutdownCtx); err != nil {
			logger.Warn("tracing shutdown", slog.String("err", err.Error()))
		}
	}()

	// --- dependencies ---
	pool, err := pg.NewPool(rootCtx, cfg, logger)
	if err != nil {
		return fmt.Errorf("postgres pool: %w", err)
	}
	defer pool.Close()

	if err := verifyMigrations(rootCtx, pool); err != nil {
		return fmt.Errorf("verifying migrations: %w", err)
	}

	natsConn, err := natsbroker.NewConn(rootCtx, cfg, logger)
	if err != nil {
		return fmt.Errorf("nats connect: %w", err)
	}
	defer func() {
		if err := natsConn.Close(); err != nil {
			logger.Warn("nats close error", slog.String("err", err.Error()))
		}
	}()

	repo, err := session.NewPostgresRepository(pool)
	if err != nil {
		return fmt.Errorf("session repo: %w", err)
	}

	auditPub, err := session.NewNATSAuditPublisher(natsConn.NC)
	if err != nil {
		return fmt.Errorf("audit publisher: %w", err)
	}

	svc, err := session.NewService(repo, auditPub, logger)
	if err != nil {
		return fmt.Errorf("session service: %w", err)
	}

	internalToken := os.Getenv(internalTokenEnv)
	if internalToken == "" && cfg.Env != config.EnvDev {
		return errors.New(internalTokenEnv + " is required outside dev")
	}
	if internalToken == "" {
		logger.Warn("INTERNAL_SVC_TOKEN unset; allowing all callers (dev only)")
	}

	srv, err := session.NewServer(svc, logger, internalToken)
	if err != nil {
		return fmt.Errorf("session server: %w", err)
	}

	// --- router ---
	r := chi.NewRouter()
	r.Use(chimw.RequestID)
	r.Use(obs.TracingMiddleware("session-manager"))
	r.Use(obs.LoggingMiddleware(logger))
	r.Use(obs.MetricsMiddleware("session-manager"))
	r.Use(httperr.Recoverer(logger))
	obs.MountMetrics(r)
	srv.Mount(r)

	// --- background expiry worker ---
	// workerCtx lives for the life of the process; cancelled on shutdown
	// signal so the tick loop returns cleanly.
	workerCtx, cancelWorker := context.WithCancel(context.Background())
	svc.RunExpiryWorker(workerCtx)

	// --- HTTP server with graceful shutdown ---
	httpSrv := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           r,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	errCh := make(chan error, 1)
	go func() {
		logger.Info("http server listening", slog.String("addr", httpSrv.Addr))
		if err := httpSrv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- fmt.Errorf("listen: %w", err)
			return
		}
		errCh <- nil
	}()

	select {
	case <-rootCtx.Done():
		logger.Info("shutdown signal received; draining")
	case err := <-errCh:
		cancelWorker()
		svc.WaitExpiryWorker()
		return err
	}

	// Order:
	//   1. Stop expiry worker; wait for its in-flight tick to finish.
	//   2. http.Server.Shutdown drains in-flight requests up to
	//      cfg.ShutdownTimeoutSeconds.
	//   3. NATS Drain / pool Close are handled by the deferreds above.
	cancelWorker()
	svc.WaitExpiryWorker()

	shutdownTimeout := time.Duration(cfg.ShutdownTimeoutSeconds) * time.Second
	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()
	if err := httpSrv.Shutdown(shutdownCtx); err != nil {
		return fmt.Errorf("http shutdown: %w", err)
	}
	if err := <-errCh; err != nil {
		return err
	}

	logger.Info("session-manager stopped cleanly")
	return nil
}

// verifyMigrations runs a lightweight sanity check that 0001_sessions
// has been applied. We don't run migrations automatically here — that's
// the migrate-up tooling's job — but we fail fast if the schema isn't
// in place so the operator sees a clear error instead of a 500 storm on
// the first request.
func verifyMigrations(ctx context.Context, pool *pg.Pool) error {
	const q = `SELECT to_regclass('public.sessions')`
	var reg *string
	pingCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := pool.QueryRow(pingCtx, q).Scan(&reg); err != nil {
		return fmt.Errorf("querying sessions table: %w", err)
	}
	if reg == nil {
		return errors.New("sessions table missing — run migrations/0001_sessions.up.sql")
	}
	return nil
}
