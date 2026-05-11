// mock-echart is a stand-in for HST eChart used in local dev and CI.
//
// It serves canned patient context, accepts draft chart events, and
// promotes them on a sign-session call. State is in-memory and resets on
// restart. The wire shapes match contract/CONTRACT.md.
package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/config"
	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/seed"
	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/server"
	"github.com/tonimnim/hst-scribe/dev/mock-echart/internal/store"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	if err := run(logger); err != nil {
		logger.Error("fatal", "err", err)
		os.Exit(1)
	}
}

func run(logger *slog.Logger) error {
	cfg, err := config.FromEnv()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	patients, err := seed.LoadPatients(cfg.SeedPath)
	if err != nil {
		return fmt.Errorf("loading seed data: %w", err)
	}
	logger.Info("seed loaded",
		"path", cfg.SeedPath,
		"patient_count", len(patients),
	)

	st := store.NewStore()
	srv := server.New(patients, st, logger, nil, nil)

	httpSrv := &http.Server{
		Addr:              net.JoinHostPort("0.0.0.0", strconv.Itoa(cfg.Port)),
		Handler:           srv.Router(),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	rootCtx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	serveErr := make(chan error, 1)
	go func() {
		logger.Info("listening", "addr", httpSrv.Addr)
		if err := httpSrv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			serveErr <- err
			return
		}
		serveErr <- nil
	}()

	select {
	case err := <-serveErr:
		return err
	case <-rootCtx.Done():
		logger.Info("shutdown signal received")
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := httpSrv.Shutdown(shutdownCtx); err != nil {
		return fmt.Errorf("graceful shutdown: %w", err)
	}
	// Drain the goroutine result so we don't leak it.
	if err := <-serveErr; err != nil {
		return fmt.Errorf("serve: %w", err)
	}
	logger.Info("shutdown complete")
	return nil
}
