package audit

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"

	"github.com/nats-io/nats.go/jetstream"
)

// NATS configuration constants. These are intentionally hard-coded —
// audit ingest is a fixed contract between producers (Phase B services)
// and this writer. Changing them is a coordinated rollout, not a knob.
const (
	// StreamName is the JetStream stream that captures every audit event.
	StreamName = "AUDIT_EVENTS"

	// SubjectFilter is the NATS subject pattern producers publish on.
	// The third token is the asc_id, used by the consumer for sharding
	// in a future revision (single-consumer today).
	SubjectFilter = "audit.events.>"

	// DurableName is the JetStream durable consumer name. Stable across
	// service restarts so we resume from the last ack instead of
	// re-reading the entire history.
	DurableName = "audit-writer"
)

// redactedPayloadKeys MUST stay aligned with internal/obs.redactedKeys.
// This file does not import obs because the obs list is unexported (it
// is a privileged-access decision) — duplicating with a documented sync
// requirement is the lesser evil. Reviewers: if obs.redactedKeys
// changes, update this list in the same commit.
var redactedPayloadKeys = map[string]struct{}{
	// Transcripts and source utterances (ASR / extractor)
	"transcript":       {},
	"text":             {},
	"note_text":        {},
	"notes":            {},
	"source_utterance": {},
	"audio_b64":        {},

	// Identifiers
	"patient_name":          {},
	"full_name":             {},
	"first_name":            {},
	"last_name":             {},
	"mrn":                   {},
	"medical_record_number": {},
	"dob":                   {},
	"date_of_birth":         {},
	"ssn":                   {},
	"phone":                 {},
	"phone_number":          {},
	"address":               {},
	"email":                 {},

	// Clinical values that read as PHI in narrative form
	"allergies":           {},
	"comorbidities":       {},
	"current_medications": {},
	"medications":         {},
	"indication":          {},
}

// Subscriber owns the JetStream consumer for the audit-writer durable.
// One Subscriber instance corresponds to one running audit service.
type Subscriber struct {
	js     jetstream.JetStream
	repo   Repository
	logger *slog.Logger

	// consumeCtx is non-nil while Run is active. It is captured so
	// Close can drain in-flight messages on shutdown.
	consumeCtx jetstream.ConsumeContext
}

// NewSubscriber constructs a Subscriber. The caller is responsible for
// calling Run (blocking or background) and Close on shutdown.
func NewSubscriber(js jetstream.JetStream, repo Repository, logger *slog.Logger) *Subscriber {
	return &Subscriber{js: js, repo: repo, logger: logger}
}

// EnsureStream creates or updates the JetStream stream that backs the
// audit subject. It is safe to call on every startup; JetStream returns
// the existing stream if the config already matches.
func EnsureStream(ctx context.Context, js jetstream.JetStream) (jetstream.Stream, error) {
	cfg := jetstream.StreamConfig{
		Name:        StreamName,
		Description: "HST Scribe audit log feed (append-only).",
		Subjects:    []string{SubjectFilter},
		Retention:   jetstream.LimitsPolicy,
		Storage:     jetstream.FileStorage,
		// Producers send UUIDv7 ids. Setting MaxAge to a year is
		// belt-and-suspenders — the canonical record is Postgres.
		MaxAge: 0,
	}
	s, err := js.CreateOrUpdateStream(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("creating audit stream: %w", err)
	}
	return s, nil
}

// Run starts the consumer. It blocks until ctx is canceled OR the
// underlying ConsumeContext fails. Returns nil on a clean ctx.Done shutdown.
func (s *Subscriber) Run(ctx context.Context) error {
	stream, err := EnsureStream(ctx, s.js)
	if err != nil {
		return err
	}

	cons, err := stream.CreateOrUpdateConsumer(ctx, jetstream.ConsumerConfig{
		Durable:       DurableName,
		Name:          DurableName,
		FilterSubject: SubjectFilter,
		AckPolicy:     jetstream.AckExplicitPolicy,
		DeliverPolicy: jetstream.DeliverAllPolicy,
		MaxDeliver:    -1, // retry forever; idempotent INSERT handles dupes
	})
	if err != nil {
		return fmt.Errorf("creating audit consumer: %w", err)
	}

	cc, err := cons.Consume(s.handle)
	if err != nil {
		return fmt.Errorf("starting consume: %w", err)
	}
	s.consumeCtx = cc

	s.logger.Info("audit subscriber running",
		slog.String("stream", StreamName),
		slog.String("durable", DurableName),
		slog.String("subject", SubjectFilter),
	)

	// Block until parent ctx is done OR the consumer closes itself.
	select {
	case <-ctx.Done():
		return nil
	case <-cc.Closed():
		return errors.New("audit consumer closed unexpectedly")
	}
}

// Close drains in-flight messages (their handlers will complete) and
// stops the consumer. Safe to call multiple times.
func (s *Subscriber) Close() {
	if s.consumeCtx == nil {
		return
	}
	s.consumeCtx.Drain()
	<-s.consumeCtx.Closed()
	s.consumeCtx = nil
}

// handle is the per-message callback. It must Ack, Nak, or Term every
// message; leaving a message un-acked stalls the consumer.
func (s *Subscriber) handle(msg jetstream.Msg) {
	// The consumer callback has no ctx — synthesize one bounded to the
	// JetStream ack-wait window (default 30s). We don't tie it to the
	// service shutdown ctx because Drain() will already block until
	// every in-flight handler returns.
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	subj := msg.Subject()
	meta, _ := msg.Metadata()

	e, err := decodeEnvelope(msg.Data())
	if err != nil {
		s.logger.Warn("dropping malformed audit event",
			slog.String("subject", subj),
			slog.String("err", err.Error()),
		)
		// Term: don't redeliver; the payload is unparseable forever.
		if termErr := msg.Term(); termErr != nil {
			s.logger.Error("term failed", slog.String("err", termErr.Error()))
		}
		return
	}

	if reason, ok := containsPHIKey(e.Payload); ok {
		s.logger.Warn("dropping audit event with PHI key",
			slog.String("event_id", e.ID),
			slog.String("asc_id", e.ASCID),
			slog.String("action", string(e.Action)),
			slog.String("phi_key", reason),
		)
		if termErr := msg.Term(); termErr != nil {
			s.logger.Error("term failed", slog.String("err", termErr.Error()))
		}
		return
	}

	if err := s.repo.Append(ctx, e); err != nil {
		if errors.Is(err, ErrInvalidEvent) {
			s.logger.Warn("dropping invalid audit event",
				slog.String("event_id", e.ID),
				slog.String("err", err.Error()),
			)
			if termErr := msg.Term(); termErr != nil {
				s.logger.Error("term failed", slog.String("err", termErr.Error()))
			}
			return
		}
		s.logger.Error("audit append failed; nak",
			slog.String("event_id", e.ID),
			slog.String("err", err.Error()),
		)
		// Nak triggers redelivery after the consumer's backoff.
		if nakErr := msg.Nak(); nakErr != nil {
			s.logger.Error("nak failed", slog.String("err", nakErr.Error()))
		}
		return
	}

	if err := msg.Ack(); err != nil {
		// We already wrote to Postgres; an Ack failure means the
		// message will redeliver and dedupe on the primary key. Log
		// loud but don't fail the handler.
		s.logger.Warn("ack failed",
			slog.String("event_id", e.ID),
			slog.String("err", err.Error()),
		)
	}

	if meta != nil {
		s.logger.Debug("audit appended",
			slog.String("event_id", e.ID),
			slog.String("action", string(e.Action)),
			slog.Uint64("stream_seq", meta.Sequence.Stream),
			slog.Uint64("consumer_seq", meta.Sequence.Consumer),
		)
	}
}

// decodeEnvelope parses the on-the-wire audit envelope and validates
// the minimum required fields. The returned *Event is safe to pass to
// the repository.
func decodeEnvelope(raw []byte) (*Event, error) {
	if len(raw) == 0 {
		return nil, fmt.Errorf("%w: empty body", ErrInvalidEvent)
	}
	var e Event
	dec := json.NewDecoder(bytes.NewReader(raw))
	// We do NOT call DisallowUnknownFields here: producers in Phase B
	// may add fields ahead of audit-service redeploys (additive contract
	// changes per CONTRACT.md §6). Unknown fields are ignored.
	if err := dec.Decode(&e); err != nil {
		return nil, fmt.Errorf("%w: decode: %s", ErrInvalidEvent, err.Error())
	}
	if e.ID == "" {
		return nil, fmt.Errorf("%w: missing id", ErrInvalidEvent)
	}
	if e.ASCID == "" {
		return nil, fmt.Errorf("%w: missing asc_id", ErrInvalidEvent)
	}
	if !e.Action.IsValid() {
		return nil, fmt.Errorf("%w: unknown action %q", ErrInvalidEvent, e.Action)
	}
	if e.TS.IsZero() {
		return nil, fmt.Errorf("%w: missing ts", ErrInvalidEvent)
	}
	return &e, nil
}

// containsPHIKey recursively scans the payload for any redacted key.
// Returns the offending key (for the warn log) and a bool. The check
// is conservative: any string match anywhere in the tree trips the drop.
func containsPHIKey(payload map[string]any) (string, bool) {
	if payload == nil {
		return "", false
	}
	for k, v := range payload {
		if _, bad := redactedPayloadKeys[k]; bad {
			return k, true
		}
		switch child := v.(type) {
		case map[string]any:
			if k2, ok := containsPHIKey(child); ok {
				return k2, true
			}
		case []any:
			for _, item := range child {
				if m, ok := item.(map[string]any); ok {
					if k2, found := containsPHIKey(m); found {
						return k2, true
					}
				}
			}
		}
	}
	return "", false
}
