// Command asr-orchestrator drives streaming ASR for active sessions.
//
// Responsibilities:
//
//   - Subscribe to `audio.chunks.{session_id}` on NATS JetStream (durable
//     consumer `asr-orchestrator`).
//   - Maintain one streaming Provider connection per active session.
//   - Republish provider output on `transcripts.{session_id}` as
//     contract envelopes (transcript_partial / transcript_final).
//   - Persist `is_final=true` transcripts to Postgres.
//   - Tear down provider streams on `session_ended` (NATS
//     `sessions.events.{session_id}`) or on idle timeout.
//   - Emit `audit.events.*` on terminal provider failure.
//
// Provider is selected by env:
//
//	ASR_PROVIDER=mock                (default in dev — WSS to dev/mock-asr)
//	ASR_PROVIDER=transcribe_medical  (Phase 2 — returns ErrNotImplemented today)
//	ASR_PROVIDER=fake                (tests only)
//
// Health endpoint on :8082 by default (override with HTTP_ADDR).
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/caarlos0/env/v11"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"github.com/tonimnim/hst-scribe/backend/internal/asr"
	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/natsbroker"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
	"github.com/tonimnim/hst-scribe/backend/internal/pg"
)

const (
	serviceName     = "asr-orchestrator"
	defaultHTTPAddr = ":8082"
)

// providerConfig groups the env-driven provider selection knobs.
// Loaded once at startup, then frozen.
type providerConfig struct {
	// Provider is mock | transcribe_medical | fake. Default mock.
	Provider string `env:"ASR_PROVIDER" envDefault:"mock"`

	// MockURL is the WSS endpoint for the dev mock-asr. Default the
	// docker-compose port.
	MockURL string `env:"MOCK_ASR_URL" envDefault:"ws://localhost:8091/asr/v1/stream"`

	// MockAuthToken is sent as Authorization: Bearer on upgrade. The
	// mock accepts any non-empty value; "dev" is the convention.
	MockAuthToken string `env:"MOCK_ASR_TOKEN" envDefault:"dev"`

	// AWSRegion / Language / Specialty are reserved for Phase 2.
	AWSRegion       string `env:"AWS_REGION" envDefault:"us-east-1"`
	AWSLanguageCode string `env:"ASR_LANGUAGE_CODE" envDefault:"en-US"`
	AWSSpecialty    string `env:"ASR_SPECIALTY" envDefault:"PRIMARYCARE"`
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%s: %v\n", serviceName, err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}
	// Override defaults intended for the gateway binary.
	if os.Getenv("SERVICE_NAME") == "" {
		cfg.ServiceName = serviceName
	}
	if os.Getenv("HTTP_ADDR") == "" {
		cfg.HTTPAddr = defaultHTTPAddr
	}

	var pcfg providerConfig
	if err := env.Parse(&pcfg); err != nil {
		return fmt.Errorf("parsing provider config: %w", err)
	}

	logger := obs.NewLogger(cfg)
	logger.Info("service starting",
		slog.String("addr", cfg.HTTPAddr),
		slog.String("env", string(cfg.Env)),
		slog.String("provider", pcfg.Provider),
	)

	// Root context for the lifetime of the service. signal.NotifyContext
	// wires SIGTERM/SIGINT to ctx cancellation for graceful drain.
	rootCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	// Postgres pool.
	pool, err := pg.NewPool(rootCtx, cfg, logger)
	if err != nil {
		return fmt.Errorf("postgres pool: %w", err)
	}
	defer pool.Close()

	// NATS + JetStream.
	natsConn, err := natsbroker.NewConn(rootCtx, cfg, logger)
	if err != nil {
		return fmt.Errorf("nats connect: %w", err)
	}
	defer func() {
		if closeErr := natsConn.Close(); closeErr != nil {
			logger.Warn("nats close", slog.String("err", closeErr.Error()))
		}
	}()

	// Provider selection.
	provider, err := buildProvider(pcfg, logger)
	if err != nil {
		return fmt.Errorf("building provider: %w", err)
	}

	// Repository.
	repo, err := asr.NewPGRepository(pool)
	if err != nil {
		return fmt.Errorf("transcripts repository: %w", err)
	}

	// Service.
	service, err := asr.NewService(asr.ServiceConfig{
		Provider:   provider,
		Repository: repo,
		NATS:       natsConn.NC,
		JetStream:  natsConn.JS,
		Logger:     logger,
	})
	if err != nil {
		return fmt.Errorf("asr service: %w", err)
	}

	// Run the consumer on a background goroutine so the HTTP server can
	// answer /healthz in parallel.
	consumerErrCh := make(chan error, 1)
	go func() {
		consumerErrCh <- service.Run(rootCtx)
	}()

	// HTTP /healthz.
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(obs.LoggingMiddleware(logger))
	r.Use(httperr.Recoverer(logger))
	r.Get("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]string{
			"status":   "ok",
			"service":  serviceName,
			"provider": provider.Name(),
		})
	})

	srv := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           r,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	httpErrCh := make(chan error, 1)
	go func() {
		logger.Info("http server listening", slog.String("addr", srv.Addr))
		err := srv.ListenAndServe()
		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			httpErrCh <- fmt.Errorf("listen: %w", err)
			return
		}
		httpErrCh <- nil
	}()

	// Wait for shutdown signal or a fatal subsystem error.
	var firstErr error
	select {
	case <-rootCtx.Done():
		logger.Info("shutdown signal received")
	case err := <-consumerErrCh:
		if err != nil {
			logger.Error("consumer exited with error", slog.String("err", err.Error()))
			firstErr = err
		}
	case err := <-httpErrCh:
		if err != nil {
			logger.Error("http server exited with error", slog.String("err", err.Error()))
			firstErr = err
		}
	}

	// Drain. Fresh context so shutdown isn't aborted by the canceled root.
	shutdownTimeout := time.Duration(cfg.ShutdownTimeoutSeconds) * time.Second
	shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(rootCtx), shutdownTimeout)
	defer cancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		logger.Warn("http shutdown", slog.String("err", err.Error()))
	}
	service.Close()

	// Reap consumer goroutine if we exited via signal.
	select {
	case err := <-consumerErrCh:
		if err != nil && firstErr == nil {
			firstErr = err
		}
	case <-time.After(shutdownTimeout):
		logger.Warn("consumer did not exit within drain window")
	}

	logger.Info("service stopped")
	return firstErr
}

// buildProvider selects an ASR provider based on env config. Returns
// an error for unknown values rather than silently defaulting.
func buildProvider(pcfg providerConfig, logger *slog.Logger) (asr.Provider, error) {
	switch strings.ToLower(pcfg.Provider) {
	case "mock":
		return asr.NewMockProvider(asr.MockProviderConfig{
			URL:       pcfg.MockURL,
			AuthToken: pcfg.MockAuthToken,
		}, logger)
	case "transcribe_medical":
		return asr.NewTranscribeMedicalProvider(
			pcfg.AWSRegion,
			pcfg.AWSLanguageCode,
			pcfg.AWSSpecialty,
		), nil
	case "fake":
		// The fake provider is for tests; running it as a service
		// emits an empty script. We still allow it so harness scripts
		// can boot the service against a known-quiet provider.
		return asr.NewFakeProvider(nil), nil
	default:
		return nil, fmt.Errorf("unknown ASR_PROVIDER %q (mock|transcribe_medical|fake)", pcfg.Provider)
	}
}
