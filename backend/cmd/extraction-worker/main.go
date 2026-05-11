// Command extraction-worker consumes final transcripts from NATS,
// runs them through an LLM (fake in dev, Bedrock-Claude in prod) with
// patient-context RAG and RxNorm validation, dedupes across overlapping
// windows, and emits draft chart events to extracted.events.{session_id}.
//
// Subscribes:
//
//	transcripts.>          (filters is_final=true)
//
// Publishes:
//
//	extracted.events.{session_id}
//	audit.events.{asc_id}
//
// HTTP surface (defaults to :8083):
//
//	GET /healthz
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
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"

	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/extract"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/llm"
	"github.com/tonimnim/hst-scribe/backend/internal/natsbroker"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
	"github.com/tonimnim/hst-scribe/backend/internal/pg"
	"github.com/tonimnim/hst-scribe/backend/internal/vocab"
)

const (
	defaultAddr        = ":8083"
	defaultFakeLLMSeed = "/seed/utterances.json"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "extraction-worker: fatal: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}
	if os.Getenv("SERVICE_NAME") == "" {
		cfg.ServiceName = "extraction-worker"
	}
	if os.Getenv("HTTP_ADDR") == "" {
		cfg.HTTPAddr = defaultAddr
	}

	logger := obs.NewLogger(cfg)
	logger.Info("extraction-worker starting",
		slog.String("addr", cfg.HTTPAddr),
		slog.String("env", string(cfg.Env)),
	)

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

	llmProvider, err := buildLLMProvider(logger)
	if err != nil {
		return fmt.Errorf("llm provider: %w", err)
	}

	rxValidator := vocab.NewRxNormValidator()
	eventValidator := extract.NewEventValidator(rxValidator)
	dedupe := extract.NewDedupe()

	svc, err := extract.NewService(extract.Config{
		Logger:    logger,
		LLM:       llmProvider,
		Validator: eventValidator,
		Dedupe:    dedupe,
		Pool:      pool,
		Publisher: natsConn.NC, // *nats.Conn satisfies extract.Publisher
		// Fetcher is nil in Wave 1; session-manager will provide it in Wave 2.
	})
	if err != nil {
		return fmt.Errorf("extract service: %w", err)
	}

	r := chi.NewRouter()
	r.Use(chimw.RequestID)
	r.Use(obs.TracingMiddleware("extraction-worker"))
	r.Use(obs.LoggingMiddleware(logger))
	r.Use(obs.MetricsMiddleware("extraction-worker"))
	r.Use(httperr.Recoverer(logger))
	r.Get("/healthz", healthHandler)
	obs.MountMetrics(r)

	subCtx, cancelSub := context.WithCancel(context.Background())
	subscriber := extract.NewNATSSubscriber(logger, natsConn.NC, svc)
	sub, err := subscriber.Subscribe(subCtx)
	if err != nil {
		cancelSub()
		return fmt.Errorf("subscribing transcripts: %w", err)
	}

	httpSrv := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           r,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}
	httpErrCh := make(chan error, 1)
	go func() {
		logger.Info("http server listening", slog.String("addr", httpSrv.Addr))
		if err := httpSrv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			httpErrCh <- fmt.Errorf("listen: %w", err)
			return
		}
		httpErrCh <- nil
	}()

	select {
	case <-rootCtx.Done():
		logger.Info("shutdown signal received; draining")
	case err := <-httpErrCh:
		cancelSub()
		if uerr := sub.Unsubscribe(); uerr != nil {
			logger.Warn("unsubscribe error", slog.String("err", uerr.Error()))
		}
		return err
	}

	if err := sub.Unsubscribe(); err != nil {
		logger.Warn("unsubscribe error", slog.String("err", err.Error()))
	}
	cancelSub()

	shutdownTimeout := time.Duration(cfg.ShutdownTimeoutSeconds) * time.Second
	if shutdownTimeout <= 0 {
		shutdownTimeout = 30 * time.Second
	}
	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()
	if err := httpSrv.Shutdown(shutdownCtx); err != nil {
		logger.Warn("http shutdown error", slog.String("err", err.Error()))
	}
	if err := <-httpErrCh; err != nil {
		return err
	}

	logger.Info("extraction-worker stopped cleanly")
	return nil
}

func healthHandler(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(map[string]string{"status": "ok"}); err != nil {
		_ = err
	}
}

// buildLLMProvider selects the LLM backend via LLM_PROVIDER env. In dev
// the fake provider replays canned utterance→event mappings from the
// seed file at FAKE_LLM_SEED_PATH (default /seed/utterances.json).
func buildLLMProvider(logger *slog.Logger) (llm.Provider, error) {
	provider := os.Getenv("LLM_PROVIDER")
	if provider == "" {
		provider = "fake"
	}
	switch provider {
	case "fake":
		path := os.Getenv("FAKE_LLM_SEED_PATH")
		if path == "" {
			path = defaultFakeLLMSeed
		}
		fp, err := llm.NewFakeProvider(path)
		if err != nil {
			return nil, fmt.Errorf("fake provider: %w", err)
		}
		logger.Info("llm provider: fake", slog.String("seed_path", path))
		return fp, nil
	case "bedrock_claude":
		return nil, errors.New("bedrock_claude provider is not implemented in Wave 1; set LLM_PROVIDER=fake for dev")
	default:
		return nil, fmt.Errorf("unknown LLM_PROVIDER: %s", provider)
	}
}

func verifyMigrations(ctx context.Context, pool *pg.Pool) error {
	const q = `SELECT to_regclass('public.extracted_events')`
	var reg *string
	pingCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := pool.QueryRow(pingCtx, q).Scan(&reg); err != nil {
		return fmt.Errorf("querying extracted_events table: %w", err)
	}
	if reg == nil {
		return errors.New("extracted_events table missing — run migrations/0004_extracted_events.up.sql")
	}
	return nil
}
