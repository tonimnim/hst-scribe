package extract

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"strings"
	"sync"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/nats-io/nats.go"

	"github.com/tonimnim/hst-scribe/backend/internal/contract"
	"github.com/tonimnim/hst-scribe/backend/internal/llm"
	"github.com/tonimnim/hst-scribe/backend/internal/uuidv7"
)

// SubjectTranscriptsPrefix is the NATS subject prefix we subscribe to.
// The asr-orchestrator publishes one final-transcript message per
// session under `transcripts.<session_id>` carrying a WSS Envelope
// (MsgTranscriptFinal). We filter is_final inside the handler because
// publishers may emit partials on the same subject in a later wave.
const SubjectTranscriptsPrefix = "transcripts"

// SubjectExtractedPrefix is the NATS subject prefix we publish onto.
// Per-session subject: `extracted.events.<session_id>`. The gateway's
// per-session fan-out reads from here and writes to the WSS client.
const SubjectExtractedPrefix = "extracted.events"

// SubjectAuditPrefix is the NATS subject prefix for audit emissions
// (per asc_id, not per session, because audit queries are ASC-scoped).
const SubjectAuditPrefix = "audit.events"

// windowDuration is the rolling transcript window the prompt builder
// includes for RAG. Matches FR17 ("last 5 min").
const windowDuration = 5 * time.Minute

// schemaBytes is the JSON-Schema payload passed to Provider.Extract.
// Kept minimal — the live Bedrock implementation will negotiate this
// shape against Claude's tool-use API. Here it's enough that the fake
// receives bytes and ignores them.
var schemaBytes = json.RawMessage(`{"name":"extract_events","description":"Extract structured chart events from a nurse utterance."}`)

// PatientContextFetcher loads the locked-at-session-start chart
// context for a session. Provided by the session-manager service in
// Wave 2; nil-safe so dev tests can run without it. Implementations
// MUST be safe for concurrent use.
type PatientContextFetcher interface {
	PatientContext(ctx context.Context, sessionID string) (*contract.PatientContext, error)
}

// Publisher abstracts the NATS publishing surface so tests can swap
// in an in-memory recorder. Only the two methods we call.
type Publisher interface {
	Publish(subject string, data []byte) error
}

// Service is the extraction-worker orchestration. Construct via
// NewService; the zero value is not usable.
type Service struct {
	logger    *slog.Logger
	llm       llm.Provider
	validator *EventValidator
	dedupe    *Dedupe
	pool      *pgxpool.Pool
	pub       Publisher
	pcFetch   PatientContextFetcher

	mu      sync.Mutex
	windows map[string]*sessionWindow // session_id -> rolling window + cached PC

	// now is the clock function — swappable for tests. Defaults to
	// time.Now in NewService.
	now func() time.Time
}

// sessionWindow holds the rolling transcript window and cached patient
// context for one active session.
type sessionWindow struct {
	mu         sync.Mutex
	patientCtx *contract.PatientContext
	transcripts []TranscriptWindowEntry
}

// Config captures the wiring options for NewService. All fields are
// optional except LLM, Validator, and Dedupe — those are required.
type Config struct {
	Logger    *slog.Logger
	LLM       llm.Provider
	Validator *EventValidator
	Dedupe    *Dedupe
	Pool      *pgxpool.Pool
	Publisher Publisher
	Fetcher   PatientContextFetcher
	Now       func() time.Time
}

// NewService validates required deps and returns a Service.
func NewService(cfg Config) (*Service, error) {
	if cfg.LLM == nil {
		return nil, errors.New("extract: LLM provider is required")
	}
	if cfg.Validator == nil {
		return nil, errors.New("extract: Validator is required")
	}
	if cfg.Dedupe == nil {
		return nil, errors.New("extract: Dedupe is required")
	}
	logger := cfg.Logger
	if logger == nil {
		logger = slog.Default()
	}
	now := cfg.Now
	if now == nil {
		now = time.Now
	}
	return &Service{
		logger:    logger,
		llm:       cfg.LLM,
		validator: cfg.Validator,
		dedupe:    cfg.Dedupe,
		pool:      cfg.Pool,
		pub:       cfg.Publisher,
		pcFetch:   cfg.Fetcher,
		windows:   map[string]*sessionWindow{},
		now:       now,
	}, nil
}

// HandleTranscriptEnvelope is the public ingest entry. The asr-
// orchestrator publishes wsv1 envelopes on `transcripts.<session_id>`.
// We accept the raw bytes here, decode, filter is_final, and run the
// extraction pipeline. Returns ErrSkipped (sentinel) when the message
// is intentionally ignored (partial / unknown type) — callers should
// not log as an error.
func (s *Service) HandleTranscriptEnvelope(ctx context.Context, data []byte) error {
	env, err := decodeEnvelope(data)
	if err != nil {
		return fmt.Errorf("decoding transcript envelope: %w", err)
	}
	if env.Type != contract.MsgTranscriptFinal {
		return ErrSkipped
	}
	var payload contract.TranscriptFinalPayload
	if err := json.Unmarshal(env.Payload, &payload); err != nil {
		return fmt.Errorf("decoding transcript_final payload: %w", err)
	}
	if strings.TrimSpace(payload.Text) == "" {
		return ErrSkipped
	}
	return s.HandleFinalTranscript(ctx, env.SessionID, env.TS, payload)
}

// ErrSkipped is returned for non-error skips (partial transcript,
// unknown message type, empty text). Callers use errors.Is to avoid
// noisy error logs.
var ErrSkipped = errors.New("transcript skipped")

// HandleFinalTranscript runs the full extraction pipeline for one
// final transcript. Public so tests can drive it directly without
// constructing a NATS envelope.
func (s *Service) HandleFinalTranscript(ctx context.Context, sessionID string, observedAt time.Time, t contract.TranscriptFinalPayload) error {
	if sessionID == "" {
		return errors.New("session_id is empty")
	}

	now := s.now()
	if observedAt.IsZero() {
		observedAt = now
	}

	window := s.windowFor(sessionID)
	pc := s.ensurePatientContext(ctx, sessionID, window)

	// Add to window AFTER snapshotting it for the prompt — we don't
	// want the current utterance echoed in its own RECENT list.
	recent := window.snapshotRecent(now)

	prompt := Build(PromptInput{
		Now:            now,
		PatientContext: pc,
		Recent:         recent,
		Utterance:      t.Text,
	})

	rawResp, err := s.llm.Extract(ctx, prompt, schemaBytes)
	if err != nil {
		// PHI rule: never log the utterance or response body — only
		// the session_id and a count.
		s.logger.Error("llm extract failed",
			slog.String("session_id", sessionID),
			slog.String("err", err.Error()),
		)
		return fmt.Errorf("llm extract: %w", err)
	}

	events, err := s.parseEvents(sessionID, t, observedAt, rawResp)
	if err != nil {
		s.logger.Error("parsing llm response failed",
			slog.String("session_id", sessionID),
			slog.String("err", err.Error()),
		)
		return fmt.Errorf("parsing extraction: %w", err)
	}

	// Record the transcript in the window AFTER extraction so future
	// utterances see this one as context.
	window.append(TranscriptWindowEntry{
		TS:      observedAt,
		Speaker: t.Speaker,
		Text:    t.Text,
	}, now)

	// Post-process: imperative drop, rxnorm cap, burst cap, dose sanity.
	events = s.validator.Validate(ctx, events)

	// Cross-window dedupe.
	events = s.dedupe.Filter(sessionID, now, events)

	if len(events) == 0 {
		return nil
	}

	if err := s.persist(ctx, events); err != nil {
		// Persistence failure is recoverable for the publish path —
		// we still want the UI to surface drafts. The audit trail
		// will reconcile later via the source_transcript_ids array.
		s.logger.Warn("persist extracted events failed",
			slog.String("session_id", sessionID),
			slog.Int("event_count", len(events)),
			slog.String("err", err.Error()),
		)
	}

	if err := s.publishEvents(sessionID, events); err != nil {
		s.logger.Error("publish extracted events failed",
			slog.String("session_id", sessionID),
			slog.Int("event_count", len(events)),
			slog.String("err", err.Error()),
		)
		return fmt.Errorf("publish: %w", err)
	}

	s.logger.Info("events extracted",
		slog.String("session_id", sessionID),
		slog.Int("event_count", len(events)),
	)
	return nil
}

// EventsOnly is a test helper that runs the pipeline up to validation
// and dedupe but skips persistence and publish. The eval test uses it
// to drive every seeded utterance through the same code path without
// needing Postgres / NATS.
func (s *Service) EventsOnly(ctx context.Context, sessionID string, t contract.TranscriptFinalPayload) ([]ExtractedEvent, error) {
	now := s.now()
	window := s.windowFor(sessionID)
	pc := s.ensurePatientContext(ctx, sessionID, window)

	recent := window.snapshotRecent(now)
	prompt := Build(PromptInput{
		Now:            now,
		PatientContext: pc,
		Recent:         recent,
		Utterance:      t.Text,
	})
	raw, err := s.llm.Extract(ctx, prompt, schemaBytes)
	if err != nil {
		return nil, fmt.Errorf("llm extract: %w", err)
	}
	events, err := s.parseEvents(sessionID, t, now, raw)
	if err != nil {
		return nil, fmt.Errorf("parse: %w", err)
	}
	window.append(TranscriptWindowEntry{TS: now, Speaker: t.Speaker, Text: t.Text}, now)
	events = s.validator.Validate(ctx, events)
	events = s.dedupe.Filter(sessionID, now, events)
	return events, nil
}

// ResetSession clears per-session state. Called on session_ended.
func (s *Service) ResetSession(sessionID string) {
	s.mu.Lock()
	delete(s.windows, sessionID)
	s.mu.Unlock()
	s.dedupe.Reset(sessionID)
}

// windowFor returns the per-session window, creating it on first use.
func (s *Service) windowFor(sessionID string) *sessionWindow {
	s.mu.Lock()
	defer s.mu.Unlock()
	w, ok := s.windows[sessionID]
	if !ok {
		w = &sessionWindow{}
		s.windows[sessionID] = w
	}
	return w
}

// ensurePatientContext returns the cached patient context for the
// session, fetching it lazily via the configured fetcher. Nil is a
// valid return — the prompt builder handles missing context.
func (s *Service) ensurePatientContext(ctx context.Context, sessionID string, w *sessionWindow) *contract.PatientContext {
	w.mu.Lock()
	pc := w.patientCtx
	w.mu.Unlock()
	if pc != nil || s.pcFetch == nil {
		return pc
	}
	fetched, err := s.pcFetch.PatientContext(ctx, sessionID)
	if err != nil {
		s.logger.Warn("patient context fetch failed",
			slog.String("session_id", sessionID),
			slog.String("err", err.Error()),
		)
		return nil
	}
	w.mu.Lock()
	w.patientCtx = fetched
	w.mu.Unlock()
	return fetched
}

func (s *Service) parseEvents(sessionID string, t contract.TranscriptFinalPayload, now time.Time, raw json.RawMessage) ([]ExtractedEvent, error) {
	resp, err := llm.DecodeResponse(raw)
	if err != nil {
		return nil, fmt.Errorf("decoding llm response: %w", err)
	}
	out := make([]ExtractedEvent, 0, len(resp.Events))
	for _, rawEv := range resp.Events {
		var wire contract.ExtractedEvent
		if err := json.Unmarshal(rawEv, &wire); err != nil {
			return nil, fmt.Errorf("decoding event: %w", err)
		}
		// Server-side bookkeeping the LLM does not provide.
		if wire.EventID == "" {
			wire.EventID = uuidv7.New()
		}
		if wire.SourceUtterance == "" {
			wire.SourceUtterance = t.Text
		}
		if len(wire.SourceTranscriptIDs) == 0 && t.TranscriptID != "" {
			wire.SourceTranscriptIDs = []string{t.TranscriptID}
		}
		if wire.Confidence == 0 {
			// LLMs that omit confidence get a conservative default.
			wire.Confidence = 0.75
		}
		ev := ExtractedEvent{
			ExtractedEvent: wire,
			SessionID:      sessionID,
			Status:         EventStatusDraft,
		}
		EnsureTimestamps(&ev, now)
		out = append(out, ev)
	}
	return out, nil
}

func (s *Service) publishEvents(sessionID string, events []ExtractedEvent) error {
	if s.pub == nil {
		return nil
	}
	subject := SubjectExtractedPrefix + "." + sessionID
	for _, e := range events {
		payload := contract.EventExtractedPayload{
			EventID:             e.EventID,
			EventType:           e.EventType,
			Fields:              e.Fields,
			Confidence:          e.Confidence,
			SourceTranscriptIDs: e.SourceTranscriptIDs,
			SourceUtterance:     e.SourceUtterance,
			ExtractedAt:         e.ExtractedAt,
			EventTime:           e.EventTime,
		}
		rawPayload, err := json.Marshal(payload)
		if err != nil {
			return fmt.Errorf("marshal event payload: %w", err)
		}
		env := contract.Envelope{
			Type:      contract.MsgEventExtracted,
			SessionID: sessionID,
			Seq:       0, // gateway re-stamps with per-direction seq
			TS:        e.ExtractedAt.UTC(),
			Payload:   rawPayload,
		}
		data, err := json.Marshal(env)
		if err != nil {
			return fmt.Errorf("marshal envelope: %w", err)
		}
		if err := s.pub.Publish(subject, data); err != nil {
			return fmt.Errorf("publish %s: %w", subject, err)
		}
	}
	return nil
}

func (s *Service) persist(ctx context.Context, events []ExtractedEvent) error {
	if s.pool == nil {
		return nil
	}
	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	committed := false
	defer func() {
		if !committed {
			_ = tx.Rollback(ctx)
		}
	}()

	const insertSQL = `
INSERT INTO extracted_events (
    id, session_id, event_type, fields, confidence,
    source_transcript_ids, source_utterance, status,
    needs_review, extracted_at, event_time
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
ON CONFLICT (id) DO NOTHING`

	for _, e := range events {
		fields := e.Fields
		if len(fields) == 0 {
			fields = json.RawMessage("{}")
		}
		_, err := tx.Exec(ctx, insertSQL,
			e.EventID,
			e.SessionID,
			string(e.EventType),
			fields,
			e.Confidence,
			e.SourceTranscriptIDs,
			e.SourceUtterance,
			string(e.Status),
			e.NeedsReview,
			e.ExtractedAt,
			e.EventTime,
		)
		if err != nil {
			return fmt.Errorf("inserting event %s: %w", e.EventID, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit: %w", err)
	}
	committed = true
	return nil
}

// --- sessionWindow helpers ---

// append adds an entry to the rolling window and evicts entries older
// than windowDuration. now anchors the cutoff.
func (w *sessionWindow) append(entry TranscriptWindowEntry, now time.Time) {
	w.mu.Lock()
	defer w.mu.Unlock()
	w.transcripts = append(w.transcripts, entry)
	cutoff := now.Add(-windowDuration)
	keep := w.transcripts[:0]
	for _, e := range w.transcripts {
		if e.TS.After(cutoff) {
			keep = append(keep, e)
		}
	}
	w.transcripts = keep
}

// snapshotRecent returns a copy of the window after evicting old
// entries. now anchors the cutoff.
func (w *sessionWindow) snapshotRecent(now time.Time) []TranscriptWindowEntry {
	w.mu.Lock()
	defer w.mu.Unlock()
	cutoff := now.Add(-windowDuration)
	out := make([]TranscriptWindowEntry, 0, len(w.transcripts))
	for _, e := range w.transcripts {
		if e.TS.After(cutoff) {
			out = append(out, e)
		}
	}
	return out
}

// --- NATS subscription glue ---

// NATSSubscriber bundles the bits needed to subscribe to NATS and
// dispatch into a Service. The asr-orchestrator does not yet exist in
// Wave 1 so this is the standalone subscription path used by both
// the cmd binary and integration tests.
type NATSSubscriber struct {
	logger  *slog.Logger
	conn    *nats.Conn
	service *Service
}

// NewNATSSubscriber wires the service to a live NATS connection.
func NewNATSSubscriber(logger *slog.Logger, conn *nats.Conn, svc *Service) *NATSSubscriber {
	if logger == nil {
		logger = slog.Default()
	}
	return &NATSSubscriber{logger: logger, conn: conn, service: svc}
}

// Subscribe registers an async subscription on `transcripts.>` and
// returns the subscription so callers can Unsubscribe at shutdown.
// Each message is handled on the NATS dispatcher goroutine with a
// derived context bound to parentCtx.
func (s *NATSSubscriber) Subscribe(parentCtx context.Context) (*nats.Subscription, error) {
	if s.conn == nil {
		return nil, errors.New("nats conn is nil")
	}
	sub, err := s.conn.Subscribe(SubjectTranscriptsPrefix+".>", func(msg *nats.Msg) {
		ctx, cancel := context.WithTimeout(parentCtx, 30*time.Second)
		defer cancel()
		if err := s.service.HandleTranscriptEnvelope(ctx, msg.Data); err != nil {
			if errors.Is(err, ErrSkipped) {
				return
			}
			s.logger.Error("handle transcript failed",
				slog.String("subject", msg.Subject),
				slog.String("err", err.Error()),
			)
		}
	})
	if err != nil {
		return nil, fmt.Errorf("subscribing transcripts.>: %w", err)
	}
	s.logger.Info("subscribed", slog.String("subject", SubjectTranscriptsPrefix+".>"))
	return sub, nil
}

// --- helpers ---

func decodeEnvelope(data []byte) (*contract.Envelope, error) {
	var env contract.Envelope
	if err := json.Unmarshal(data, &env); err != nil {
		return nil, err
	}
	if env.Type == "" {
		return nil, errors.New("envelope type missing")
	}
	return &env, nil
}
