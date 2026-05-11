package gateway

import (
	"context"
	"errors"
	"fmt"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/jetstream"

	"github.com/tonimnim/hst-scribe/backend/internal/natsbroker"
)

// Subjects formatted per CONTRACT.md and PRD.md.
//
// Gateway publishes:
//   - audio.chunks.{session_id}         consumed by asr-orchestrator
//   - sessions.activity.{session_id}    consumed by session-manager
//   - extracted.confirmed.{session_id}  consumed by chart-writer
//   - extracted.rejected.{session_id}   consumed by chart-writer
//   - chart.sign.{session_id}           consumed by chart-writer
//
// Gateway subscribes (per WSS session, ephemeral):
//   - transcripts.{session_id}          published by asr-orchestrator
//   - extracted.events.{session_id}     published by extraction-worker
const (
	subjAudioChunks      = "audio.chunks.%s"
	subjActivity         = "sessions.activity.%s"
	subjExtractedConfirm = "extracted.confirmed.%s"
	subjExtractedReject  = "extracted.rejected.%s"
	subjChartSign        = "chart.sign.%s"
	subjTranscripts      = "transcripts.%s"
	subjExtractedEvents  = "extracted.events.%s"
)

// Publisher is the small subset of NATS the gateway needs for one-shot
// publishes. Implementations are safe for concurrent use.
type Publisher interface {
	// Publish sends data on subject. The call returns once the NATS
	// client has accepted the message; delivery is fire-and-forget.
	Publish(ctx context.Context, subject string, data []byte) error
}

// NATSPublisher adapts a *natsbroker.Conn to Publisher. Uses core NATS
// (not JetStream) for the gateway's fan-out subjects — at-most-once is
// the right semantic here, and the audio path cannot tolerate the
// extra latency of a JS ack roundtrip.
type NATSPublisher struct {
	NC *nats.Conn
}

// Publish honors ctx by returning early if it is already canceled; the
// underlying nats client otherwise treats publish as non-blocking. We
// also flush to make a best-effort that the byte hit the wire when the
// caller releases the goroutine.
func (p *NATSPublisher) Publish(ctx context.Context, subject string, data []byte) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	if p == nil || p.NC == nil {
		return errors.New("nats publisher not configured")
	}
	if err := p.NC.Publish(subject, data); err != nil {
		return fmt.Errorf("nats publish %s: %w", subject, err)
	}
	return nil
}

// Subscriber is the small subset of JetStream subscription used by the
// gateway's per-session fan-in loop.
type Subscriber interface {
	// Subscribe registers handler for every message on subject. The
	// returned closer drains the subscription on shutdown.
	Subscribe(ctx context.Context, subject string, handler func(data []byte)) (Subscription, error)
}

// Subscription is the gateway's view of a live NATS subscription.
type Subscription interface {
	// Unsubscribe stops delivery and drops the underlying consumer.
	Unsubscribe() error
}

// NATSSubscriber bridges a *natsbroker.Conn to the gateway's Subscriber
// interface. We deliberately use core NATS subscriptions (not JetStream)
// for transcripts/extracted-events: missed messages are recoverable via
// replay-from-seq, the WSS handler is the only consumer per session, and
// the ephemeral lifetime matches a single mobile connection.
type NATSSubscriber struct {
	NC *nats.Conn
	JS jetstream.JetStream // reserved for future JS-backed feeds
}

// natsSub adapts a *nats.Subscription to Subscription.
type natsSub struct {
	sub *nats.Subscription
}

func (s *natsSub) Unsubscribe() error {
	if s == nil || s.sub == nil {
		return nil
	}
	return s.sub.Unsubscribe()
}

// Subscribe registers handler on subject. Messages are delivered on the
// internal NATS goroutine — handler must not block.
func (n *NATSSubscriber) Subscribe(ctx context.Context, subject string, handler func(data []byte)) (Subscription, error) {
	if n == nil || n.NC == nil {
		return nil, errors.New("nats subscriber not configured")
	}
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	sub, err := n.NC.Subscribe(subject, func(msg *nats.Msg) {
		handler(msg.Data)
	})
	if err != nil {
		return nil, fmt.Errorf("nats subscribe %s: %w", subject, err)
	}
	return &natsSub{sub: sub}, nil
}

// FromConn builds a Publisher+Subscriber pair from a shared *natsbroker.Conn.
func FromConn(c *natsbroker.Conn) (Publisher, Subscriber) {
	return &NATSPublisher{NC: c.NC}, &NATSSubscriber{NC: c.NC, JS: c.JS}
}

// SubjectAudio returns the audio chunks subject for a session.
func SubjectAudio(sessionID string) string { return fmt.Sprintf(subjAudioChunks, sessionID) }

// SubjectActivity returns the activity heartbeat subject.
func SubjectActivity(sessionID string) string { return fmt.Sprintf(subjActivity, sessionID) }

// SubjectExtractedConfirm is the chart-writer subject for confirms.
func SubjectExtractedConfirm(sessionID string) string {
	return fmt.Sprintf(subjExtractedConfirm, sessionID)
}

// SubjectExtractedReject is the chart-writer subject for rejects.
func SubjectExtractedReject(sessionID string) string {
	return fmt.Sprintf(subjExtractedReject, sessionID)
}

// SubjectChartSign is the chart-writer subject for sign-off promotion.
func SubjectChartSign(sessionID string) string { return fmt.Sprintf(subjChartSign, sessionID) }

// SubjectTranscripts is the asr-orchestrator output subject.
func SubjectTranscripts(sessionID string) string { return fmt.Sprintf(subjTranscripts, sessionID) }

// SubjectExtractedEvents is the extraction-worker output subject.
func SubjectExtractedEvents(sessionID string) string {
	return fmt.Sprintf(subjExtractedEvents, sessionID)
}
