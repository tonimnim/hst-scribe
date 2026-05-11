// Package config holds typed runtime configuration for the mock-asr service.
package config

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// Config is the typed startup configuration. Populated from env vars at startup
// and passed via DI; no package-level state lives here.
type Config struct {
	// Port the HTTP server listens on. PORT env var, default 8091.
	Port int
	// SeedPath is the filesystem path to utterances.json. SEED_PATH env var.
	// Defaults to /seed/utterances.json (the container mount); callers running
	// outside a container should set it explicitly.
	SeedPath string
	// EmitInterval is the cadence at which a new transcript_final is emitted
	// (measured from the prior final). EMIT_INTERVAL_MS env var, default 5s.
	EmitInterval time.Duration
	// PartialLeadIn is the delay after a final before the next partial is sent.
	// Not env-tunable; locked at 600ms per spec.
	PartialLeadIn time.Duration
	// PartialToFinal is the delay from partial to final. Locked at 400ms per spec.
	PartialToFinal time.Duration
}

// FromEnv reads configuration from environment variables, applying defaults.
// Returns an error if any required value cannot be parsed.
func FromEnv() (Config, error) {
	cfg := Config{
		Port:           8091,
		SeedPath:       "/seed/utterances.json",
		EmitInterval:   5 * time.Second,
		PartialLeadIn:  600 * time.Millisecond,
		PartialToFinal: 400 * time.Millisecond,
	}

	if v := os.Getenv("PORT"); v != "" {
		p, err := strconv.Atoi(v)
		if err != nil {
			return Config{}, fmt.Errorf("parsing PORT %q: %w", v, err)
		}
		if p <= 0 || p > 65535 {
			return Config{}, fmt.Errorf("PORT %d out of range", p)
		}
		cfg.Port = p
	}

	if v := os.Getenv("SEED_PATH"); v != "" {
		cfg.SeedPath = v
	}

	if v := os.Getenv("EMIT_INTERVAL_MS"); v != "" {
		ms, err := strconv.Atoi(v)
		if err != nil {
			return Config{}, fmt.Errorf("parsing EMIT_INTERVAL_MS %q: %w", v, err)
		}
		if ms <= 0 {
			return Config{}, fmt.Errorf("EMIT_INTERVAL_MS %d must be positive", ms)
		}
		cfg.EmitInterval = time.Duration(ms) * time.Millisecond
	}

	return cfg, nil
}
