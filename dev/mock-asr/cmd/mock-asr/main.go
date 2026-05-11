// Command mock-asr is a local-dev stand-in for AWS Transcribe Medical. It
// serves a WSS endpoint that replays canned utterances from a seed file in
// the same envelope shape the real ASR backend will use.
//
// NOT for production. No PHI safeguards beyond log discipline; no audio
// decoding; no real ASR billing. Auth is "any bearer token accepted."
package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/tonimnim/hst-scribe/dev/mock-asr/internal/config"
	"github.com/tonimnim/hst-scribe/dev/mock-asr/internal/seed"
	"github.com/tonimnim/hst-scribe/dev/mock-asr/internal/wss"
)

func main() {
	if err := run(); err != nil {
		// main is the one place we exit non-zero. Everything below returns errors.
		fmt.Fprintf(os.Stderr, "mock-asr: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))

	cfg, err := config.FromEnv()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}
	logger.Info("config loaded",
		slog.Int("port", cfg.Port),
		slog.String("seed_path", cfg.SeedPath),
		slog.Duration("emit_interval", cfg.EmitInterval),
	)

	utterances, err := seed.Load(cfg.SeedPath)
	if err != nil {
		return fmt.Errorf("loading seed: %w", err)
	}
	logger.Info("seed loaded", slog.Int("utterance_count", len(utterances)))

	srv, err := wss.NewServer(wss.Config{
		Addr:           fmt.Sprintf(":%d", cfg.Port),
		Logger:         logger,
		EmitInterval:   cfg.EmitInterval,
		PartialLeadIn:  cfg.PartialLeadIn,
		PartialToFinal: cfg.PartialToFinal,
		Utterances:     utterances,
	})
	if err != nil {
		return fmt.Errorf("constructing server: %w", err)
	}

	// Standard signal trap → context cancel pattern.
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	if err := srv.ListenAndServe(ctx); err != nil {
		return fmt.Errorf("server: %w", err)
	}
	logger.Info("mock-asr shutdown complete")
	return nil
}
