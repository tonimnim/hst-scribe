// Command chart-writer consumes confirmed/rejected extracted events
// and session-sign signals from NATS, persists state to chart_writes,
// and pushes the round-trip to eChart (mock in dev, real in prod).
//
// Subscribes (durable consumer "chart-writer"):
//
//	extracted.confirmed.>
//	extracted.rejected.>
//	chart.sign.>
//
// Publishes:
//
//	audit.events.{asc_id}
//	chart.dead-letter   (DLQ for retry exhaustion)
//
// HTTP surface (defaults to :8084):
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
	"github.com/tonimnim/hst-scribe/backend/internal/echart"
	"github.com/tonimnim/hst-scribe/backend/internal/httperr"
	"github.com/tonimnim/hst-scribe/backend/internal/natsbroker"
	"github.com/tonimnim/hst-scribe/backend/internal/obs"
	"github.com/tonimnim/hst-scribe/backend/internal/pg"
	"github.com/tonimnim/hst-scribe/backend/internal/uuidv7"
)

const defaultAddr = ":8084"

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "chart-writer: fatal: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}
	if os.Getenv("SERVICE_NAME") == "" {
		cfg.ServiceName = "chart-writer"
	}
	if os.Getenv("HTTP_ADDR") == "" {
		cfg.HTTPAddr = defaultAddr
	}

	logger := obs.NewLogger(cfg)
	logger.Info("chart-writer starting",
		slog.String("addr", cfg.HTTPAddr),
		slog.String("env", string(cfg.Env)),
	)

	rootCtx, stopSig := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stopSig()

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

	echartCfg := echart.LoadHTTPClientConfigFromEnv()
	echartClient := echart.NewHTTPClient(echartCfg, logger)

	repo, err := echart.NewPGRepository(pool)
	if err != nil {
		return fmt.Errorf("chart_writes repo: %w", err)
	}

	auditPub, err := echart.NewNATSAuditPublisher(natsConn.NC)
	if err != nil {
		return fmt.Errorf("audit publisher: %w", err)
	}

	dlqPub, err := echart.NewNATSDeadLetterPublisher(natsConn.NC)
	if err != nil {
		return fmt.Errorf("dlq publisher: %w", err)
	}

	writer, err := echart.NewWriter(
		echart.WriterConfig{},
		echartClient,
		repo,
		natsConn.JS,
		auditPub,
		dlqPub,
		logger,
		uuidv7.New,
	)
	if err != nil {
		return fmt.Errorf("chart writer: %w", err)
	}

	r := chi.NewRouter()
	r.Use(chimw.RequestID)
	r.Use(obs.LoggingMiddleware(logger))
	r.Use(httperr.Recoverer(logger))
	r.Get("/healthz", healthHandler)

	writerCtx, cancelWriter := context.WithCancel(context.Background())
	writerErrCh := make(chan error, 1)
	go func() {
		writerErrCh <- writer.Run(writerCtx)
	}()

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
	case err := <-writerErrCh:
		cancelWriter()
		_ = httpSrv.Close()
		return fmt.Errorf("writer stopped early: %w", err)
	case err := <-httpErrCh:
		cancelWriter()
		return err
	}

	cancelWriter()

	shutdownTimeout := time.Duration(cfg.ShutdownTimeoutSeconds) * time.Second
	if shutdownTimeout <= 0 {
		shutdownTimeout = 30 * time.Second
	}
	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()
	if err := httpSrv.Shutdown(shutdownCtx); err != nil {
		logger.Warn("http shutdown error", slog.String("err", err.Error()))
	}
	if err := <-writerErrCh; err != nil && !errors.Is(err, context.Canceled) {
		logger.Warn("writer error during shutdown", slog.String("err", err.Error()))
	}

	logger.Info("chart-writer stopped cleanly")
	return nil
}

func healthHandler(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(map[string]string{"status": "ok"}); err != nil {
		_ = err
	}
}

func verifyMigrations(ctx context.Context, pool *pg.Pool) error {
	const q = `SELECT to_regclass('public.chart_writes')`
	var reg *string
	pingCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := pool.QueryRow(pingCtx, q).Scan(&reg); err != nil {
		return fmt.Errorf("querying chart_writes table: %w", err)
	}
	if reg == nil {
		return errors.New("chart_writes table missing — run migrations/0005_chart_writes.up.sql")
	}
	return nil
}
