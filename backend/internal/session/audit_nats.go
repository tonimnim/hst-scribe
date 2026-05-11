package session

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/nats-io/nats.go"
)

// NATSAuditPublisher publishes AuditEvent values to subject
// audit.events.{asc_id}. Phase B uses core NATS Publish (best-effort
// at-least-once is the audit service's responsibility on the consumer
// side via JetStream); the upgrade to direct JetStream publish lives in
// the audit service, not here.
type NATSAuditPublisher struct {
	nc *nats.Conn
}

// NewNATSAuditPublisher constructs a publisher backed by nc. nc must be
// non-nil and connected.
func NewNATSAuditPublisher(nc *nats.Conn) (*NATSAuditPublisher, error) {
	if nc == nil {
		return nil, errors.New("session.NewNATSAuditPublisher: nats conn is nil")
	}
	return &NATSAuditPublisher{nc: nc}, nil
}

// Publish implements AuditPublisher.
func (p *NATSAuditPublisher) Publish(ctx context.Context, ascID string, evt AuditEvent) error {
	if ascID == "" {
		return errors.New("audit publish: asc_id is empty")
	}
	if err := ctx.Err(); err != nil {
		return fmt.Errorf("audit publish ctx: %w", err)
	}
	body, err := MarshalAuditEvent(evt)
	if err != nil {
		return err
	}
	subject := "audit.events." + ascID
	if err := p.nc.Publish(subject, body); err != nil {
		return fmt.Errorf("publishing to %s: %w", subject, err)
	}
	// Flush so we don't drop audit on a sudden process exit. The nats
	// client buffers writes otherwise. FlushWithContext requires a
	// deadline; if the caller's ctx has none we add a 2s bound.
	flushCtx := ctx
	if _, ok := ctx.Deadline(); !ok {
		var cancel context.CancelFunc
		flushCtx, cancel = context.WithTimeout(ctx, 2*time.Second)
		defer cancel()
	}
	if err := p.nc.FlushWithContext(flushCtx); err != nil {
		return fmt.Errorf("flushing nats: %w", err)
	}
	return nil
}

// Compile-time check.
var _ AuditPublisher = (*NATSAuditPublisher)(nil)
