package echart

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/jetstream"
)

// NATS subjects this package subscribes to and publishes on. Hard-coded
// because they are part of the inter-service contract that gateway,
// extraction-worker, session-manager, and audit all coordinate on.
const (
	// SubjectExtractedConfirmed is the NATS subject pattern published by
	// the gateway when the nurse confirms a draft event (REST
	// POST /events/{id}/confirm or voice command). Tail token is the
	// session_id.
	SubjectExtractedConfirmed = "extracted.confirmed.>"

	// SubjectExtractedRejected is the rejection counterpart of confirmed.
	SubjectExtractedRejected = "extracted.rejected.>"

	// SubjectChartSign is the NATS subject pattern published by the
	// session-manager when the nurse signs a session via
	// POST /sessions/{id}/sign. Tail token is the session_id.
	SubjectChartSign = "chart.sign.>"

	// SubjectDeadLetter is where chart-writer routes events after retry
	// exhaustion or unrecoverable errors. A separate service (or this
	// one's replay worker) reads from here.
	SubjectDeadLetter = "chart.dead-letter"

	// StreamName is the JetStream stream the chart-writer service binds
	// its durable consumers to. The stream config must include the
	// three input subject patterns above.
	StreamName = "CHART_INPUT"

	// DurableName is the durable consumer used across all input
	// subjects. Re-using one durable keeps replay semantics simple and
	// matches the "subscriptions are durable" PRD requirement.
	DurableName = "chart-writer"
)

// ConfirmedEvent is the NATS payload chart-writer expects on
// extracted.confirmed.<session_id>. This is the contract between
// gateway/extraction-worker (publisher) and chart-writer (subscriber).
// Producers MUST emit this exact shape — additive fields are fine
// (json decoder ignores unknowns), removing fields is a breaking change
// that requires coordination.
type ConfirmedEvent struct {
	EventID             string          `json:"event_id"`
	SessionID           string          `json:"session_id"`
	PatientID           string          `json:"patient_id"`
	ASCID               string          `json:"asc_id"`
	ActorUserID         string          `json:"actor_user_id,omitempty"`
	EventType           string          `json:"event_type"`
	Fields              json.RawMessage `json:"fields"`
	Confidence          float64         `json:"confidence"`
	SourceUtterance     string          `json:"source_utterance"`
	SourceTranscriptIDs []string        `json:"source_transcript_ids,omitempty"`
	ExtractedAt         time.Time       `json:"extracted_at"`
	EventTime           time.Time       `json:"event_time,omitempty"`
}

// RejectedEvent is the payload on extracted.rejected.<session_id>. The
// chart-writer records it in the ledger but never POSTs to eChart.
type RejectedEvent struct {
	EventID     string    `json:"event_id"`
	SessionID   string    `json:"session_id"`
	PatientID   string    `json:"patient_id"`
	ASCID       string    `json:"asc_id"`
	ActorUserID string    `json:"actor_user_id,omitempty"`
	Reason      string    `json:"reason,omitempty"`
	RejectedAt  time.Time `json:"rejected_at"`
}

// SignEvent is the payload on chart.sign.<session_id>. Published by the
// session-manager after a successful POST /sessions/{id}/sign so the
// chart-writer can atomically promote all 'written' drafts.
type SignEvent struct {
	SessionID   string    `json:"session_id"`
	PatientID   string    `json:"patient_id"`
	ASCID       string    `json:"asc_id"`
	ActorUserID string    `json:"actor_user_id,omitempty"`
	SignedAt    time.Time `json:"signed_at"`
}

// AuditEvent is the on-wire shape published to audit.events.{asc_id}.
// Matches session.AuditEvent — duplicated here so this package does not
// import internal/session. The audit subscriber validates Action against
// internal/audit.Action.IsValid; chart-writer uses chart_write_attempted
// / chart_write_succeeded / chart_write_failed.
type AuditEvent struct {
	ID          string         `json:"id"`
	SessionID   string         `json:"session_id"`
	ActorUserID string         `json:"actor_user_id,omitempty"`
	ASCID       string         `json:"asc_id"`
	Action      string         `json:"action"`
	TargetID    string         `json:"target_id,omitempty"`
	TargetType  string         `json:"target_type,omitempty"`
	Payload     map[string]any `json:"payload"`
	TS          time.Time      `json:"ts"`
}

// IDGen mints UUIDv7 ids. Injected so tests can pin values.
type IDGen func() string

// AuditPublisher emits AuditEvent values to the audit subject. The
// chart-writer constructor accepts an implementation; tests substitute a
// fake.
type AuditPublisher interface {
	Publish(ctx context.Context, ascID string, evt AuditEvent) error
}

// DeadLetterPublisher emits raw bytes to chart.dead-letter. Separated
// from AuditPublisher so each implementation can keep its own subject
// and serialization concerns.
type DeadLetterPublisher interface {
	Publish(ctx context.Context, body []byte) error
}

// WriterConfig captures the runtime knobs. Defaults are filled in by
// NewWriter when zero.
type WriterConfig struct {
	// DLQReplayInterval controls how often the background replay job
	// inspects chart.dead-letter. 30s default per PRD.
	DLQReplayInterval time.Duration

	// DLQReplayMinAge is the minimum dwell time before a dead-letter
	// message is eligible for replay. 60s default per PRD.
	DLQReplayMinAge time.Duration
}

// Writer is the chart-writer domain service. It subscribes to the three
// input subjects, persists state to chart_writes, calls Client for the
// eChart round-trip, and emits audit + DLQ events.
//
// Lifecycle:
//
//   - NewWriter constructs the service (no I/O).
//   - Run starts JetStream consumers and the background DLQ replay job.
//     Blocks until ctx is canceled.
//   - Close drains in-flight handlers.
type Writer struct {
	cfg    WriterConfig
	client Client
	repo   Repository
	js     jetstream.JetStream
	audit  AuditPublisher
	dlq    DeadLetterPublisher
	logger *slog.Logger
	now    func() time.Time
	newID  IDGen

	// consumeCtx is non-nil while Run is active.
	consumeCtxMu sync.Mutex
	consumeCtx   jetstream.ConsumeContext

	// inFlight tracks in-flight handler goroutines for graceful shutdown.
	inFlight sync.WaitGroup
}

// WriterOption configures a Writer at construction.
type WriterOption func(*Writer)

// WithClock injects a clock for tests.
func WithClock(now func() time.Time) WriterOption {
	return func(w *Writer) { w.now = now }
}

// WithIDGen injects a UUID generator for tests.
func WithIDGen(g IDGen) WriterOption {
	return func(w *Writer) { w.newID = g }
}

// NewWriter constructs a Writer. All dependencies must be non-nil except
// js (may be nil for tests that drive handlers directly).
func NewWriter(
	cfg WriterConfig,
	client Client,
	repo Repository,
	js jetstream.JetStream,
	audit AuditPublisher,
	dlq DeadLetterPublisher,
	logger *slog.Logger,
	newID IDGen,
	opts ...WriterOption,
) (*Writer, error) {
	if client == nil {
		return nil, errors.New("echart.NewWriter: client is nil")
	}
	if repo == nil {
		return nil, errors.New("echart.NewWriter: repo is nil")
	}
	if audit == nil {
		return nil, errors.New("echart.NewWriter: audit is nil")
	}
	if dlq == nil {
		return nil, errors.New("echart.NewWriter: dlq is nil")
	}
	if logger == nil {
		return nil, errors.New("echart.NewWriter: logger is nil")
	}
	if newID == nil {
		return nil, errors.New("echart.NewWriter: newID is nil")
	}
	if cfg.DLQReplayInterval <= 0 {
		cfg.DLQReplayInterval = 30 * time.Second
	}
	if cfg.DLQReplayMinAge <= 0 {
		cfg.DLQReplayMinAge = 60 * time.Second
	}
	w := &Writer{
		cfg:    cfg,
		client: client,
		repo:   repo,
		js:     js,
		audit:  audit,
		dlq:    dlq,
		logger: logger,
		now:    time.Now,
		newID:  newID,
	}
	for _, opt := range opts {
		opt(w)
	}
	return w, nil
}

// EnsureStream creates or updates the JetStream stream that captures
// the chart-writer input subjects. Idempotent; safe on every startup.
func EnsureStream(ctx context.Context, js jetstream.JetStream) (jetstream.Stream, error) {
	if js == nil {
		return nil, errors.New("echart.EnsureStream: js is nil")
	}
	cfg := jetstream.StreamConfig{
		Name:        StreamName,
		Description: "HST Scribe chart-writer input feed (confirmed/rejected events + sign signals).",
		Subjects: []string{
			SubjectExtractedConfirmed,
			SubjectExtractedRejected,
			SubjectChartSign,
		},
		Retention: jetstream.LimitsPolicy,
		Storage:   jetstream.FileStorage,
		MaxAge:    0,
	}
	s, err := js.CreateOrUpdateStream(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("creating chart-writer stream: %w", err)
	}
	return s, nil
}

// Run starts the JetStream consumer and the DLQ replay job. Blocks
// until ctx is canceled or the consumer closes unexpectedly. Returns
// nil on a clean shutdown.
func (w *Writer) Run(ctx context.Context) error {
	stream, err := EnsureStream(ctx, w.js)
	if err != nil {
		return err
	}

	cons, err := stream.CreateOrUpdateConsumer(ctx, jetstream.ConsumerConfig{
		Durable: DurableName,
		Name:    DurableName,
		FilterSubjects: []string{
			SubjectExtractedConfirmed,
			SubjectExtractedRejected,
			SubjectChartSign,
		},
		AckPolicy:     jetstream.AckExplicitPolicy,
		DeliverPolicy: jetstream.DeliverAllPolicy,
		MaxDeliver:    -1, // chart_writes UNIQUE makes replay safe.
	})
	if err != nil {
		return fmt.Errorf("creating chart-writer consumer: %w", err)
	}

	cc, err := cons.Consume(w.handleMsg)
	if err != nil {
		return fmt.Errorf("starting consume: %w", err)
	}
	w.consumeCtxMu.Lock()
	w.consumeCtx = cc
	w.consumeCtxMu.Unlock()

	w.logger.Info("chart-writer running",
		slog.String("stream", StreamName),
		slog.String("durable", DurableName),
	)

	// Background DLQ replay tick. Returns when ctx is done.
	replayDone := make(chan struct{})
	go func() {
		defer close(replayDone)
		w.dlqReplayLoop(ctx)
	}()

	select {
	case <-ctx.Done():
		w.Close()
		<-replayDone
		return nil
	case <-cc.Closed():
		<-replayDone
		return errors.New("chart-writer consumer closed unexpectedly")
	}
}

// Close drains in-flight handlers and stops the consumer. Safe to call
// multiple times.
func (w *Writer) Close() {
	w.consumeCtxMu.Lock()
	cc := w.consumeCtx
	w.consumeCtx = nil
	w.consumeCtxMu.Unlock()
	if cc != nil {
		cc.Drain()
		<-cc.Closed()
	}
	w.inFlight.Wait()
}

// handleMsg dispatches a NATS message based on its subject. Every code
// path Ack/Nak/Terms exactly once. Errors that should not redeliver are
// Term'd; transient errors are Nak'd so JetStream retries.
func (w *Writer) handleMsg(msg jetstream.Msg) {
	w.inFlight.Add(1)
	defer w.inFlight.Done()

	// Synthesize a per-message ctx bounded to the JetStream ack-wait
	// (default 30s) — handler-side retry is the Client's responsibility.
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	subj := msg.Subject()
	switch {
	case isExtractedConfirmed(subj):
		w.dispatchConfirmed(ctx, msg)
	case isExtractedRejected(subj):
		w.dispatchRejected(ctx, msg)
	case isChartSign(subj):
		w.dispatchSign(ctx, msg)
	default:
		w.logger.Warn("dropping unexpected subject",
			slog.String("subject", subj),
		)
		w.termOrLog(msg)
	}
}

func isExtractedConfirmed(s string) bool { return hasPrefix(s, "extracted.confirmed.") }
func isExtractedRejected(s string) bool  { return hasPrefix(s, "extracted.rejected.") }
func isChartSign(s string) bool          { return hasPrefix(s, "chart.sign.") }

func hasPrefix(s, p string) bool { return len(s) >= len(p) && s[:len(p)] == p }

// --- confirmed ---

func (w *Writer) dispatchConfirmed(ctx context.Context, msg jetstream.Msg) {
	var ev ConfirmedEvent
	if err := json.Unmarshal(msg.Data(), &ev); err != nil {
		w.logger.Warn("dropping malformed confirmed event",
			slog.String("subject", msg.Subject()),
			slog.String("err", err.Error()),
		)
		w.termOrLog(msg)
		return
	}
	if err := validateConfirmed(&ev); err != nil {
		w.logger.Warn("dropping invalid confirmed event",
			slog.String("event_id", ev.EventID),
			slog.String("session_id", ev.SessionID),
			slog.String("err", err.Error()),
		)
		w.termOrLog(msg)
		return
	}

	if err := w.HandleConfirmed(ctx, ev); err != nil {
		// Persistence or transient infra error — Nak so JetStream
		// redelivers. APIError / ErrRetryExhausted are already handled
		// inside HandleConfirmed (DLQ + status=failed).
		w.logger.Error("confirmed handler nak",
			slog.String("event_id", ev.EventID),
			slog.String("session_id", ev.SessionID),
			slog.String("err", err.Error()),
		)
		w.nakOrLog(msg)
		return
	}
	w.ackOrLog(msg)
}

// HandleConfirmed is the public entrypoint for one confirmed event —
// exported so tests can drive it directly without a JetStream server.
// Returns an error only when the failure is infra-level (DB, audit
// publish) and merits a NATS redelivery; eChart API failures are
// terminal and routed to DLQ + status=failed within this method.
func (w *Writer) HandleConfirmed(ctx context.Context, ev ConfirmedEvent) error {
	insertErr := w.repo.InsertPending(ctx, ChartWrite{
		ID:        w.newID(),
		SessionID: ev.SessionID,
		EventID:   ev.EventID,
		PatientID: ev.PatientID,
	})
	if errors.Is(insertErr, ErrDuplicateEventID) {
		w.logger.Info("duplicate confirmed event ignored",
			slog.String("event_id", ev.EventID),
			slog.String("session_id", ev.SessionID),
		)
		return nil
	}
	if insertErr != nil {
		return fmt.Errorf("inserting pending: %w", insertErr)
	}

	// Audit: attempt is recorded before the POST so a crash mid-write
	// still leaves a tamper-evident trail.
	w.emitAudit(ctx, AuditEvent{
		ID:          w.newID(),
		SessionID:   ev.SessionID,
		ActorUserID: ev.ActorUserID,
		ASCID:       ev.ASCID,
		Action:      "chart_write_attempted",
		TargetID:    ev.EventID,
		TargetType:  "extracted_event",
		Payload: map[string]any{
			"event_type": ev.EventType,
		},
		TS: w.now().UTC(),
	})

	// Decode Fields into the freeform map eChart expects.
	var fields map[string]any
	if len(ev.Fields) > 0 {
		if err := json.Unmarshal(ev.Fields, &fields); err != nil {
			w.markAndDLQ(ctx, ev, 1, fmt.Errorf("decoding fields: %w", err))
			return nil
		}
	}

	req := DraftEventRequest{
		EventType:       ev.EventType,
		Fields:          fields,
		Confidence:      ev.Confidence,
		SourceUtterance: ev.SourceUtterance,
		ExtractedAt:     ev.ExtractedAt,
	}

	// Client already retries internally per the PRD schedule; one call
	// here covers all 5 attempts and returns ErrRetryExhausted or an
	// APIError on terminal failure.
	resp, err := w.client.PostDraftEvent(ctx, ev.PatientID, req)
	if err != nil {
		// attempts=Client.MaxAttempts is the worst case; we approximate
		// as 5 to match the default schedule. This is a status field
		// for operators, not a hard count.
		w.markAndDLQ(ctx, ev, 5, err)
		return nil
	}

	writtenAt := w.now().UTC()
	if err := w.repo.MarkWritten(ctx, ev.EventID, resp.ChartEntryID, 1, writtenAt); err != nil {
		// We've already POSTed to eChart; redelivery is safe because
		// the chart-writer dedupes on event_id (chart_writes UNIQUE),
		// and the second POST will be skipped by InsertPending below.
		// Surface as infra error so the message is Nak'd and we retry
		// the DB update only.
		return fmt.Errorf("mark written: %w", err)
	}

	w.logger.Info("draft event written",
		slog.String("event_id", ev.EventID),
		slog.String("session_id", ev.SessionID),
		slog.String("patient_id", ev.PatientID),
		slog.String("echart_entry_id", resp.ChartEntryID),
	)
	w.emitAudit(ctx, AuditEvent{
		ID:          w.newID(),
		SessionID:   ev.SessionID,
		ActorUserID: ev.ActorUserID,
		ASCID:       ev.ASCID,
		Action:      "chart_write_succeeded",
		TargetID:    ev.EventID,
		TargetType:  "extracted_event",
		Payload: map[string]any{
			"echart_entry_id": resp.ChartEntryID,
			"phase":           "written",
		},
		TS: writtenAt,
	})
	return nil
}

// markAndDLQ records a terminal failure in chart_writes + audit and
// publishes the original payload to the dead-letter subject. Errors
// inside this function are logged but not returned — we're already on
// the failure path.
func (w *Writer) markAndDLQ(ctx context.Context, ev ConfirmedEvent, attempts int, cause error) {
	errMsg := cause.Error()

	if err := w.repo.MarkFailed(ctx, ev.EventID, attempts, errMsg); err != nil {
		w.logger.Error("mark failed update errored",
			slog.String("event_id", ev.EventID),
			slog.String("err", err.Error()),
		)
	}

	dlqPayload := struct {
		Reason     string         `json:"reason"`
		Attempts   int            `json:"attempts"`
		EnqueuedAt time.Time      `json:"enqueued_at"`
		Original   ConfirmedEvent `json:"original"`
	}{
		Reason:     errMsg,
		Attempts:   attempts,
		EnqueuedAt: w.now().UTC(),
		Original:   ev,
	}
	// If Fields is malformed JSON (the failure mode that landed us here in
	// the first place), json.Marshal would refuse to encode the whole DLQ
	// envelope. Replace it with a quoted string so DLQ delivery still
	// succeeds — that IS the point of DLQ.
	if len(dlqPayload.Original.Fields) > 0 && !json.Valid(dlqPayload.Original.Fields) {
		if q, qErr := json.Marshal(string(dlqPayload.Original.Fields)); qErr == nil {
			dlqPayload.Original.Fields = q
		} else {
			dlqPayload.Original.Fields = json.RawMessage(`null`)
		}
	}
	body, mErr := json.Marshal(dlqPayload)
	if mErr != nil {
		w.logger.Error("dlq marshal failed",
			slog.String("event_id", ev.EventID),
			slog.String("err", mErr.Error()),
		)
		return
	}
	if err := w.dlq.Publish(ctx, body); err != nil {
		w.logger.Error("dlq publish failed",
			slog.String("event_id", ev.EventID),
			slog.String("err", err.Error()),
		)
	}

	w.logger.Error("chart write failed; dlq routed",
		slog.String("event_id", ev.EventID),
		slog.String("session_id", ev.SessionID),
		slog.String("patient_id", ev.PatientID),
		slog.Int("attempts", attempts),
		slog.String("err", errMsg),
	)
	w.emitAudit(ctx, AuditEvent{
		ID:          w.newID(),
		SessionID:   ev.SessionID,
		ActorUserID: ev.ActorUserID,
		ASCID:       ev.ASCID,
		Action:      "chart_write_failed",
		TargetID:    ev.EventID,
		TargetType:  "extracted_event",
		Payload: map[string]any{
			"attempts": attempts,
			// Note: we deliberately omit the raw err detail from the
			// audit payload because it may include URL paths or
			// upstream messages we don't want to ingest into the
			// audit trail. The chart_writes.last_error column carries
			// the operational detail for triage.
		},
		TS: w.now().UTC(),
	})
}

func validateConfirmed(e *ConfirmedEvent) error {
	if e.EventID == "" {
		return errors.New("event_id is required")
	}
	if e.SessionID == "" {
		return errors.New("session_id is required")
	}
	if e.PatientID == "" {
		return errors.New("patient_id is required")
	}
	if e.ASCID == "" {
		return errors.New("asc_id is required")
	}
	if e.EventType == "" {
		return errors.New("event_type is required")
	}
	return nil
}

// --- rejected ---

func (w *Writer) dispatchRejected(ctx context.Context, msg jetstream.Msg) {
	var ev RejectedEvent
	if err := json.Unmarshal(msg.Data(), &ev); err != nil {
		w.logger.Warn("dropping malformed rejected event",
			slog.String("subject", msg.Subject()),
			slog.String("err", err.Error()),
		)
		w.termOrLog(msg)
		return
	}
	if err := w.HandleRejected(ctx, ev); err != nil {
		w.logger.Error("rejected handler nak",
			slog.String("event_id", ev.EventID),
			slog.String("session_id", ev.SessionID),
			slog.String("err", err.Error()),
		)
		w.nakOrLog(msg)
		return
	}
	w.ackOrLog(msg)
}

// HandleRejected records a rejection in chart_writes. No eChart call.
func (w *Writer) HandleRejected(ctx context.Context, ev RejectedEvent) error {
	if ev.EventID == "" || ev.SessionID == "" || ev.PatientID == "" {
		// Validation errors are dropped silently — there is nothing to
		// audit because we have no event_id to anchor.
		w.logger.Warn("dropping invalid rejected event",
			slog.String("event_id", ev.EventID),
			slog.String("session_id", ev.SessionID),
		)
		return nil
	}
	err := w.repo.InsertRejected(ctx, ChartWrite{
		ID:        w.newID(),
		SessionID: ev.SessionID,
		EventID:   ev.EventID,
		PatientID: ev.PatientID,
	})
	if errors.Is(err, ErrDuplicateEventID) {
		return nil
	}
	if err != nil {
		return fmt.Errorf("insert rejected: %w", err)
	}

	w.logger.Info("event rejection recorded",
		slog.String("event_id", ev.EventID),
		slog.String("session_id", ev.SessionID),
		slog.String("patient_id", ev.PatientID),
	)
	return nil
}

// --- sign ---

func (w *Writer) dispatchSign(ctx context.Context, msg jetstream.Msg) {
	var ev SignEvent
	if err := json.Unmarshal(msg.Data(), &ev); err != nil {
		w.logger.Warn("dropping malformed sign event",
			slog.String("subject", msg.Subject()),
			slog.String("err", err.Error()),
		)
		w.termOrLog(msg)
		return
	}
	if err := w.HandleSign(ctx, ev); err != nil {
		w.logger.Error("sign handler nak",
			slog.String("session_id", ev.SessionID),
			slog.String("err", err.Error()),
		)
		w.nakOrLog(msg)
		return
	}
	w.ackOrLog(msg)
}

// HandleSign promotes all 'written' rows for a session to 'promoted'
// via a single SignSession call against eChart.
//
// Semantics on partial failure: if SignSession returns an error, the
// chart_writes rows stay in 'written' (event isn't lost, just not
// finalized) and an audit row with action=chart_write_failed is
// emitted. The next sign retry can pick them up. Operationally this
// means the nurse must re-tap "sign" — surfaced via the gateway.
func (w *Writer) HandleSign(ctx context.Context, ev SignEvent) error {
	if ev.SessionID == "" || ev.PatientID == "" || ev.ASCID == "" {
		w.logger.Warn("dropping invalid sign event",
			slog.String("session_id", ev.SessionID),
		)
		return nil
	}

	rows, err := w.repo.ListWrittenBySession(ctx, ev.SessionID)
	if err != nil {
		return fmt.Errorf("list written by session: %w", err)
	}
	if len(rows) == 0 {
		w.logger.Info("sign received with no written rows",
			slog.String("session_id", ev.SessionID),
		)
		return nil
	}

	eventIDs := make([]string, 0, len(rows))
	for _, r := range rows {
		eventIDs = append(eventIDs, r.EventID)
	}

	resp, err := w.client.SignSession(ctx, ev.PatientID, SignSessionRequest{
		SessionID: ev.SessionID,
		EventIDs:  eventIDs,
	})
	if err != nil {
		w.logger.Error("sign-session call failed",
			slog.String("session_id", ev.SessionID),
			slog.String("patient_id", ev.PatientID),
			slog.Int("event_count", len(eventIDs)),
			slog.String("err", err.Error()),
		)
		w.emitAudit(ctx, AuditEvent{
			ID:          w.newID(),
			SessionID:   ev.SessionID,
			ActorUserID: ev.ActorUserID,
			ASCID:       ev.ASCID,
			Action:      "chart_write_failed",
			TargetType:  "session_sign",
			TargetID:    ev.SessionID,
			Payload: map[string]any{
				"event_count": len(eventIDs),
				"phase":       "sign",
			},
			TS: w.now().UTC(),
		})
		return nil // not redeliverable: writes are intact
	}

	promotedAt := w.now().UTC()
	if err := w.repo.MarkPromoted(ctx, eventIDs, promotedAt); err != nil {
		return fmt.Errorf("mark promoted: %w", err)
	}

	w.logger.Info("session signed and promoted",
		slog.String("session_id", ev.SessionID),
		slog.String("patient_id", ev.PatientID),
		slog.Int("events_written", resp.EventsWritten),
		slog.Int("events_rejected", resp.EventsRejected),
	)
	w.emitAudit(ctx, AuditEvent{
		ID:          w.newID(),
		SessionID:   ev.SessionID,
		ActorUserID: ev.ActorUserID,
		ASCID:       ev.ASCID,
		Action:      "chart_write_succeeded",
		TargetType:  "session_sign",
		TargetID:    ev.SessionID,
		Payload: map[string]any{
			"events_written":  resp.EventsWritten,
			"events_rejected": resp.EventsRejected,
			"phase":           "promoted",
		},
		TS: promotedAt,
	})
	return nil
}

// --- DLQ replay ---

// dlqReplayLoop runs every cfg.DLQReplayInterval. For Wave 1 the only
// action is logging that the DLQ tick fired; actual replay logic
// (re-queue to extracted.confirmed.* with attempts reset, or escalate
// to ops alerting) is deferred to Wave 2.
func (w *Writer) dlqReplayLoop(ctx context.Context) {
	t := time.NewTicker(w.cfg.DLQReplayInterval)
	defer t.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-t.C:
			w.logger.Debug("dlq replay tick",
				slog.Duration("interval", w.cfg.DLQReplayInterval),
				slog.Duration("min_age", w.cfg.DLQReplayMinAge),
			)
		}
	}
}

// --- helpers ---

func (w *Writer) emitAudit(ctx context.Context, evt AuditEvent) {
	if err := w.audit.Publish(ctx, evt.ASCID, evt); err != nil {
		w.logger.Warn("audit publish failed",
			slog.String("session_id", evt.SessionID),
			slog.String("action", evt.Action),
			slog.String("err", err.Error()),
		)
	}
}

func (w *Writer) ackOrLog(msg jetstream.Msg) {
	if err := msg.Ack(); err != nil {
		w.logger.Warn("ack failed", slog.String("err", err.Error()))
	}
}

func (w *Writer) nakOrLog(msg jetstream.Msg) {
	if err := msg.Nak(); err != nil {
		w.logger.Warn("nak failed", slog.String("err", err.Error()))
	}
}

func (w *Writer) termOrLog(msg jetstream.Msg) {
	if err := msg.Term(); err != nil {
		w.logger.Warn("term failed", slog.String("err", err.Error()))
	}
}

// --- AuditPublisher / DLQ implementations backed by NATS ---

// NATSAuditPublisher publishes to audit.events.{asc_id} via core NATS.
// Mirrors session.NATSAuditPublisher to keep packages independent.
type NATSAuditPublisher struct {
	nc *nats.Conn
}

// NewNATSAuditPublisher constructs the audit publisher.
func NewNATSAuditPublisher(nc *nats.Conn) (*NATSAuditPublisher, error) {
	if nc == nil {
		return nil, errors.New("echart.NewNATSAuditPublisher: nc is nil")
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
	body, err := json.Marshal(evt)
	if err != nil {
		return fmt.Errorf("marshalling audit event: %w", err)
	}
	subject := "audit.events." + ascID
	if err := p.nc.Publish(subject, body); err != nil {
		return fmt.Errorf("publishing to %s: %w", subject, err)
	}
	if err := p.nc.FlushWithContext(ctx); err != nil {
		return fmt.Errorf("flushing nats: %w", err)
	}
	return nil
}

// NATSDeadLetterPublisher publishes to chart.dead-letter via core NATS.
type NATSDeadLetterPublisher struct {
	nc *nats.Conn
}

// NewNATSDeadLetterPublisher constructs the DLQ publisher.
func NewNATSDeadLetterPublisher(nc *nats.Conn) (*NATSDeadLetterPublisher, error) {
	if nc == nil {
		return nil, errors.New("echart.NewNATSDeadLetterPublisher: nc is nil")
	}
	return &NATSDeadLetterPublisher{nc: nc}, nil
}

// Publish implements DeadLetterPublisher.
func (p *NATSDeadLetterPublisher) Publish(ctx context.Context, body []byte) error {
	if err := ctx.Err(); err != nil {
		return fmt.Errorf("dlq publish ctx: %w", err)
	}
	if err := p.nc.Publish(SubjectDeadLetter, body); err != nil {
		return fmt.Errorf("publishing to %s: %w", SubjectDeadLetter, err)
	}
	if err := p.nc.FlushWithContext(ctx); err != nil {
		return fmt.Errorf("flushing dlq: %w", err)
	}
	return nil
}

// Compile-time checks.
var (
	_ AuditPublisher      = (*NATSAuditPublisher)(nil)
	_ DeadLetterPublisher = (*NATSDeadLetterPublisher)(nil)
)
