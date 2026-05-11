// Package natsbroker constructs a NATS connection with JetStream
// enabled. The package is named natsbroker to avoid collision with the
// nats import path.
package natsbroker

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/jetstream"

	"github.com/tonimnim/hst-scribe/backend/internal/config"
)

// Conn bundles a NATS connection and its JetStream context.
type Conn struct {
	NC *nats.Conn
	JS jetstream.JetStream
}

// Close drains and closes the underlying NATS connection. Returns the
// drain error if any; the connection is closed regardless.
func (c *Conn) Close() error {
	if c == nil || c.NC == nil {
		return nil
	}
	if err := c.NC.Drain(); err != nil {
		return fmt.Errorf("draining nats: %w", err)
	}
	return nil
}

// NewConn dials NATS and creates a JetStream handle. Reconnection
// events are logged through the provided logger.
func NewConn(ctx context.Context, cfg *config.Config, logger *slog.Logger) (*Conn, error) {
	if cfg.NATSURL == "" {
		return nil, fmt.Errorf("NATS_URL is empty")
	}

	opts := []nats.Option{
		nats.Name(cfg.ServiceName),
		nats.MaxReconnects(-1),
		nats.ReconnectWait(2 * time.Second),
		nats.Timeout(5 * time.Second),
		nats.DisconnectErrHandler(func(_ *nats.Conn, err error) {
			if err != nil {
				logger.Warn("nats disconnected", slog.String("err", err.Error()))
			}
		}),
		nats.ReconnectHandler(func(nc *nats.Conn) {
			logger.Info("nats reconnected", slog.String("server", nc.ConnectedUrl()))
		}),
		nats.ErrorHandler(func(_ *nats.Conn, sub *nats.Subscription, err error) {
			subject := ""
			if sub != nil {
				subject = sub.Subject
			}
			logger.Warn("nats async error",
				slog.String("subject", subject),
				slog.String("err", err.Error()),
			)
		}),
	}

	nc, err := nats.Connect(cfg.NATSURL, opts...)
	if err != nil {
		return nil, fmt.Errorf("connecting nats %s: %w", cfg.NATSURL, err)
	}

	// Respect context cancellation during connect: if ctx is already
	// done we still tear down the connection.
	if err := ctx.Err(); err != nil {
		nc.Close()
		return nil, fmt.Errorf("nats connect aborted: %w", err)
	}

	js, err := jetstream.New(nc)
	if err != nil {
		nc.Close()
		return nil, fmt.Errorf("creating jetstream: %w", err)
	}

	logger.Info("nats connected",
		slog.String("server", nc.ConnectedUrl()),
		slog.String("client_id", nc.Opts.Name),
	)
	return &Conn{NC: nc, JS: js}, nil
}
