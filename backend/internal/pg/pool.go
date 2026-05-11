// Package pg wraps the construction of a *pgxpool.Pool with sensible
// defaults for HST Scribe services: bounded conn count, lifetime cap,
// healthcheck, and tracing-friendly logger plumbing.
//
// Callers should create exactly one Pool at startup and inject it.
package pg

import (
	"context"
	"fmt"
	"log/slog"
	"runtime"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/tonimnim/hst-scribe/backend/internal/config"
)

// Pool is an alias for *pgxpool.Pool so service code can import this
// package without also pulling in pgx directly when not needed.
type Pool = pgxpool.Pool

// NewPool builds a pgxpool.Pool from cfg. The pool is pinged once to
// fail fast on bad connection strings. The caller owns Close().
func NewPool(ctx context.Context, cfg *config.Config, logger *slog.Logger) (*Pool, error) {
	if cfg.PostgresDSN == "" {
		return nil, fmt.Errorf("POSTGRES_DSN is empty")
	}

	pcfg, err := pgxpool.ParseConfig(cfg.PostgresDSN)
	if err != nil {
		return nil, fmt.Errorf("parsing POSTGRES_DSN: %w", err)
	}

	// Derived defaults — caller can override via DSN params if needed.
	cpu := int32(runtime.NumCPU()) // #nosec G115 — small positive int
	if cpu < 2 {
		cpu = 2
	}
	pcfg.MaxConns = cpu * 4
	pcfg.MinConns = 2
	pcfg.MaxConnLifetime = 30 * time.Minute
	pcfg.MaxConnIdleTime = 5 * time.Minute
	pcfg.HealthCheckPeriod = 30 * time.Second

	pool, err := pgxpool.NewWithConfig(ctx, pcfg)
	if err != nil {
		return nil, fmt.Errorf("opening pgxpool: %w", err)
	}

	pingCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := pool.Ping(pingCtx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("pinging postgres: %w", err)
	}

	logger.Info("postgres pool ready",
		slog.Int("max_conns", int(pcfg.MaxConns)),
		slog.Int("min_conns", int(pcfg.MinConns)),
	)
	return pool, nil
}
