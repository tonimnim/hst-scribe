// Package config holds typed runtime configuration for the mock-echart service.
package config

import (
	"fmt"
	"os"
	"strconv"
)

// Config is the typed startup configuration. Populated from env vars at startup
// and passed via DI; no package-level state lives here.
type Config struct {
	// Port the HTTP server listens on. PORT env var, default 8090.
	Port int
	// SeedPath is the filesystem path to patients.json. SEED_PATH env var.
	// Defaults to /seed/patients.json (the container mount); callers running
	// outside a container should set it explicitly.
	SeedPath string
}

// FromEnv reads configuration from environment variables, applying defaults.
// Returns an error if any required value cannot be parsed.
func FromEnv() (Config, error) {
	cfg := Config{
		Port:     8090,
		SeedPath: "/seed/patients.json",
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

	return cfg, nil
}
