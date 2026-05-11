// Package config loads typed configuration from environment variables.
//
// All services share the same Config struct; service-specific overrides
// arrive through env vars (e.g. SERVICE_NAME, HTTP_ADDR). Config is loaded
// once at startup via Load() and passed by value to constructors.
package config

import (
	"errors"
	"fmt"

	"github.com/caarlos0/env/v11"
)

// Env identifies the deployment environment.
type Env string

// Env values recognized by HST Scribe services.
const (
	EnvDev     Env = "dev"
	EnvStaging Env = "staging"
	EnvProd    Env = "prod"
)

// Config is the typed runtime configuration for any HST Scribe service.
// All fields are populated from environment variables.
type Config struct {
	// ServiceName identifies the current service in logs/metrics/traces.
	ServiceName string `env:"SERVICE_NAME" envDefault:"gateway"`

	// Env is the deployment environment (dev|staging|prod).
	Env Env `env:"ENV" envDefault:"dev"`

	// LogLevel is one of debug|info|warn|error.
	LogLevel string `env:"LOG_LEVEL" envDefault:"info"`

	// HTTPAddr is the listen address for the service's HTTP server.
	HTTPAddr string `env:"HTTP_ADDR" envDefault:":8080"`

	// PostgresDSN is the libpq-style connection string for Postgres.
	PostgresDSN string `env:"POSTGRES_DSN" envDefault:"postgres://hst:hst@localhost:5432/hst_scribe?sslmode=disable"`

	// NATSURL is the NATS server URL.
	NATSURL string `env:"NATS_URL" envDefault:"nats://localhost:4222"`

	// JWTSecret is the HMAC secret for dev JWT validation. Empty means
	// auth is disabled (dev/local only). Production deployments must set
	// this to a long random value or switch to JWKS.
	JWTSecret string `env:"JWT_SECRET" envDefault:""`

	// ShutdownTimeoutSeconds caps graceful shutdown of HTTP servers.
	ShutdownTimeoutSeconds int `env:"SHUTDOWN_TIMEOUT_SECONDS" envDefault:"60"`
}

// Load reads configuration from the process environment and validates it.
func Load() (*Config, error) {
	var c Config
	if err := env.Parse(&c); err != nil {
		return nil, fmt.Errorf("parsing env: %w", err)
	}
	if err := c.validate(); err != nil {
		return nil, fmt.Errorf("validating config: %w", err)
	}
	return &c, nil
}

func (c *Config) validate() error {
	switch c.Env {
	case EnvDev, EnvStaging, EnvProd:
	default:
		return fmt.Errorf("invalid ENV %q (want dev|staging|prod)", c.Env)
	}

	switch c.LogLevel {
	case "debug", "info", "warn", "error":
	default:
		return fmt.Errorf("invalid LOG_LEVEL %q", c.LogLevel)
	}

	if c.ServiceName == "" {
		return errors.New("SERVICE_NAME must not be empty")
	}
	if c.HTTPAddr == "" {
		return errors.New("HTTP_ADDR must not be empty")
	}
	if c.ShutdownTimeoutSeconds <= 0 {
		return errors.New("SHUTDOWN_TIMEOUT_SECONDS must be positive")
	}

	// Production must have a real JWT secret. Dev may be empty for local
	// loopback testing; auth middleware will refuse all requests in that
	// case (fail-closed).
	if c.Env == EnvProd && c.JWTSecret == "" {
		return errors.New("JWT_SECRET is required when ENV=prod")
	}

	return nil
}

// IsDev reports whether the service is running in the dev environment.
func (c *Config) IsDev() bool { return c.Env == EnvDev }
