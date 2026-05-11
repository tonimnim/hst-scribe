package session

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/tonimnim/hst-scribe/backend/internal/obs"
	"github.com/tonimnim/hst-scribe/backend/internal/uuidv7"
)

// Defaults applied when the corresponding Service field is zero.
const (
	defaultSessionTTL      = 30 * time.Minute
	defaultIdleThreshold   = 30 * time.Minute
	defaultExpiryTickEvery = 60 * time.Second
)

// AuditAction is the action label emitted on every state change. The
// audit service consumes these from subject audit.events.{asc_id}.
type AuditAction string

// AuditAction values. New values require a contract conversation with
// the audit service team.
const (
	AuditSessionCreated AuditAction = "session_created"
	AuditSessionPaused  AuditAction = "session_paused"
	AuditSessionResumed AuditAction = "session_resumed"
	AuditSessionEnded   AuditAction = "session_ended"
	AuditSessionSigned  AuditAction = "session_signed"
	AuditSessionExpired AuditAction = "session_expired"
)

// AuditEvent is the JSON payload published to audit.events.{asc_id}. The
// shape mirrors columns on audit_log (migration 0006) so the audit
// service can persist it with minimal transformation.
type AuditEvent struct {
	ID          string         `json:"id"`
	SessionID   string         `json:"session_id"`
	ActorUserID string         `json:"actor_user_id,omitempty"`
	ASCID       string         `json:"asc_id"`
	Action      AuditAction    `json:"action"`
	TargetID    string         `json:"target_id,omitempty"`
	TargetType  string         `json:"target_type,omitempty"`
	Payload     map[string]any `json:"payload"`
	TS          time.Time      `json:"ts"`
}

// AuditPublisher is the audit emission seam. The NATS implementation
// lives in audit_nats.go; tests substitute an in-memory fake.
type AuditPublisher interface {
	Publish(ctx context.Context, ascID string, evt AuditEvent) error
}

// Service is the domain layer for sessions. It owns:
//
//   - Patient lock enforcement (DB does the hard guarantee; this layer
//     translates 23505 into 409 / idempotent return).
//   - Idempotency: a duplicate create by the same (asc, patient, user)
//     while a session is still active returns the existing row.
//   - State transitions: end, pause, resume, sign, expire.
//   - Audit emission on every transition.
//
// All methods take a context and return wrapped errors; the server layer
// maps domain errors to wire errors via internal/httperr.
type Service struct {
	repo         Repository
	audit        AuditPublisher
	logger       *slog.Logger
	now          func() time.Time
	sessionTTL   time.Duration
	idleAfter    time.Duration
	tickInterval time.Duration

	// expiryWG tracks the background expiry worker so Shutdown can wait
	// for the in-flight tick to complete.
	expiryWG sync.WaitGroup
}

// ServiceOption configures a Service at construction time. Reserved for
// test seams (clock injection, custom thresholds).
type ServiceOption func(*Service)

// WithClock overrides the wall clock. Useful for tests.
func WithClock(now func() time.Time) ServiceOption {
	return func(s *Service) { s.now = now }
}

// WithSessionTTL sets the absolute lifetime applied to new sessions.
func WithSessionTTL(d time.Duration) ServiceOption {
	return func(s *Service) {
		if d > 0 {
			s.sessionTTL = d
		}
	}
}

// WithIdleThreshold sets the inactivity threshold for the expiry worker.
func WithIdleThreshold(d time.Duration) ServiceOption {
	return func(s *Service) {
		if d > 0 {
			s.idleAfter = d
		}
	}
}

// WithExpiryTickInterval sets how often the expiry worker scans.
func WithExpiryTickInterval(d time.Duration) ServiceOption {
	return func(s *Service) {
		if d > 0 {
			s.tickInterval = d
		}
	}
}

// NewService builds a Service. repo and audit must be non-nil; logger
// defaults to slog.Default() when nil.
func NewService(repo Repository, audit AuditPublisher, logger *slog.Logger, opts ...ServiceOption) (*Service, error) {
	if repo == nil {
		return nil, errors.New("session.NewService: repo is nil")
	}
	if audit == nil {
		return nil, errors.New("session.NewService: audit is nil")
	}
	if logger == nil {
		logger = slog.Default()
	}
	s := &Service{
		repo:         repo,
		audit:        audit,
		logger:       logger,
		now:          time.Now,
		sessionTTL:   defaultSessionTTL,
		idleAfter:    defaultIdleThreshold,
		tickInterval: defaultExpiryTickEvery,
	}
	for _, opt := range opts {
		opt(s)
	}
	return s, nil
}

// CreateSessionInput is the service-layer input. ID is generated here so
// callers cannot influence it. Caller is responsible for validating UUID
// shape of ASCID/PatientID/UserID at the transport boundary.
type CreateSessionInput struct {
	ASCID        string
	PatientID    string
	UserID       string
	WorkflowType WorkflowType
}

// validate checks required fields. Returns a sentinel-ish error suitable
// for wrapping into a 400 by the handler.
func (in *CreateSessionInput) validate() error {
	if in.ASCID == "" {
		return errors.New("asc_id is required")
	}
	if in.PatientID == "" {
		return errors.New("patient_id is required")
	}
	if in.UserID == "" {
		return errors.New("user_id is required")
	}
	if !in.WorkflowType.Valid() {
		return fmt.Errorf("invalid workflow_type %q", in.WorkflowType)
	}
	return nil
}

// CreateSession is FR7+FR8: insert a session, enforce patient lock, and
// implement idempotent re-creation for the same (asc, patient, user).
//
// Return semantics:
//
//   - (session, nil)                  → newly created.
//   - (session, nil) with logged hint → idempotent: same user already has
//     an active session for this patient; we return the existing one.
//   - (existing, *PatientLockError)   → patient is locked by a DIFFERENT
//     user. Handler maps this to 409 patient_locked.
func (s *Service) CreateSession(ctx context.Context, in CreateSessionInput) (*Session, error) {
	if err := in.validate(); err != nil {
		return nil, fmt.Errorf("validating create input: %w", err)
	}

	now := s.now().UTC()
	args := CreateArgs{
		ID:           uuidv7.New(),
		ASCID:        in.ASCID,
		PatientID:    in.PatientID,
		UserID:       in.UserID,
		WorkflowType: in.WorkflowType,
		StartedAt:    now,
		ExpiresAt:    now.Add(s.sessionTTL),
	}

	created, err := s.repo.Create(ctx, args)
	if err == nil {
		// Newly created row — emit audit and return.
		s.emitAudit(ctx, created, AuditSessionCreated, in.UserID, map[string]any{
			"workflow_type": string(created.WorkflowType),
			"expires_at":    created.ExpiresAt.Format(time.RFC3339),
		})
		return created, nil
	}

	// Patient lock collision: either same user (idempotent) or different
	// user (real conflict).
	var lockErr *PatientLockError
	if errors.As(err, &lockErr) && lockErr.Existing != nil {
		existing := lockErr.Existing
		if existing.UserID == in.UserID {
			s.logger.Info("session create returning existing (idempotent)",
				slog.String("session_id", existing.ID),
				slog.String("asc_id", existing.ASCID),
				slog.String("patient_id", existing.PatientID),
				slog.String("user_id", existing.UserID),
			)
			return existing, nil
		}
		s.logger.Warn("patient locked by different user",
			slog.String("active_session_id", existing.ID),
			slog.String("asc_id", existing.ASCID),
			slog.String("patient_id", existing.PatientID),
		)
		return existing, lockErr
	}

	return nil, fmt.Errorf("creating session: %w", err)
}

// GetSession returns a session by id.
func (s *Service) GetSession(ctx context.Context, id string) (*Session, error) {
	sess, err := s.repo.Get(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("getting session %s: %w", id, err)
	}
	return sess, nil
}

// EndSession transitions the session to 'ended' with the given reason.
// `actorUserID` may be empty (e.g. when the expiry worker calls); when
// present it lands on the audit row.
func (s *Service) EndSession(ctx context.Context, id, actorUserID, reason string) (*Session, error) {
	updated, err := s.repo.UpdateStatus(ctx, id, StatusEnded, reason)
	if err != nil {
		return nil, fmt.Errorf("ending session %s: %w", id, err)
	}
	s.emitAudit(ctx, updated, AuditSessionEnded, actorUserID, map[string]any{
		"reason": reason,
	})
	return updated, nil
}

// PauseSession transitions active -> paused.
func (s *Service) PauseSession(ctx context.Context, id, actorUserID string) (*Session, error) {
	updated, err := s.repo.UpdateStatus(ctx, id, StatusPaused, "")
	if err != nil {
		return nil, fmt.Errorf("pausing session %s: %w", id, err)
	}
	s.emitAudit(ctx, updated, AuditSessionPaused, actorUserID, nil)
	return updated, nil
}

// ResumeSession transitions paused -> active.
func (s *Service) ResumeSession(ctx context.Context, id, actorUserID string) (*Session, error) {
	updated, err := s.repo.UpdateStatus(ctx, id, StatusActive, "")
	if err != nil {
		return nil, fmt.Errorf("resuming session %s: %w", id, err)
	}
	s.emitAudit(ctx, updated, AuditSessionResumed, actorUserID, nil)
	return updated, nil
}

// SignSession marks the session signed by signingUserID. Allowed from
// 'active' or 'ended' per ValidTransition.
func (s *Service) SignSession(ctx context.Context, id, signingUserID string) (*Session, error) {
	if signingUserID == "" {
		return nil, errors.New("sign session: user_id is required")
	}
	updated, err := s.repo.Sign(ctx, id, signingUserID, s.now().UTC())
	if err != nil {
		return nil, fmt.Errorf("signing session %s: %w", id, err)
	}
	s.emitAudit(ctx, updated, AuditSessionSigned, signingUserID, map[string]any{
		"signed_at": updated.SignedAt.Format(time.RFC3339),
	})
	return updated, nil
}

// RunExpiryWorker launches the background expiry loop and returns. It
// ticks every s.tickInterval, asking the repo to expire sessions whose
// last_activity_at is older than s.idleAfter. The loop exits when ctx
// is done; the in-flight tick (if any) finishes first.
//
// Safe to call exactly once per Service instance. Subsequent calls are
// no-ops.
func (s *Service) RunExpiryWorker(ctx context.Context) {
	s.expiryWG.Add(1)
	go func() {
		defer s.expiryWG.Done()
		ticker := time.NewTicker(s.tickInterval)
		defer ticker.Stop()

		// Tick once immediately at startup so a freshly-booted manager
		// doesn't leave a backlog of expired sessions sitting around for
		// the full interval.
		s.expireOnce(ctx)

		for {
			select {
			case <-ctx.Done():
				s.logger.Info("session expiry worker stopping",
					slog.String("reason", ctx.Err().Error()),
				)
				return
			case <-ticker.C:
				s.expireOnce(ctx)
			}
		}
	}()
}

// WaitExpiryWorker blocks until the expiry worker goroutine returns.
// Call after the worker's parent context has been cancelled.
func (s *Service) WaitExpiryWorker() { s.expiryWG.Wait() }

// expireOnce runs one expiry sweep. Errors are logged; the worker keeps
// running so a transient DB blip doesn't take down session expiry.
func (s *Service) expireOnce(ctx context.Context) {
	if err := ctx.Err(); err != nil {
		return
	}
	threshold := s.now().UTC().Add(-s.idleAfter)
	expired, err := s.repo.ExpireIdle(ctx, threshold)
	if err != nil {
		s.logger.Error("expiring idle sessions",
			slog.String("err", err.Error()),
		)
		return
	}
	for _, sess := range expired {
		s.emitAudit(ctx, sess, AuditSessionExpired, "", map[string]any{
			"reason":           "inactivity_timeout",
			"last_activity_at": sess.LastActivityAt.Format(time.RFC3339),
		})
	}
	if len(expired) > 0 {
		s.logger.Info("expired idle sessions",
			slog.Int("count", len(expired)),
			slog.String("threshold", threshold.Format(time.RFC3339)),
		)
	}
}

// emitAudit publishes one AuditEvent for sess on subject
// audit.events.{asc_id}. Errors are logged but never returned — audit
// must not break the user-visible path.
//
// NOTE: payload is intentionally narrow. We never include free-text or
// patient identifiers beyond IDs (see CLAUDE.md "No PHI in logs"). The
// audit_log table joins out to patient context if needed.
func (s *Service) emitAudit(ctx context.Context, sess *Session, action AuditAction, actorUserID string, payload map[string]any) {
	if sess == nil {
		return
	}
	if payload == nil {
		payload = map[string]any{}
	}
	evt := AuditEvent{
		ID:          uuidv7.New(),
		SessionID:   sess.ID,
		ActorUserID: actorUserID,
		ASCID:       sess.ASCID,
		Action:      action,
		TargetID:    sess.ID,
		TargetType:  "session",
		Payload:     payload,
		TS:          s.now().UTC(),
	}

	// Use a fresh context for the audit hop so handler-cancellation
	// (client disconnected after returning the response) doesn't
	// suppress audit. Bound it.
	pubCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 5*time.Second)
	defer cancel()

	if err := s.audit.Publish(pubCtx, sess.ASCID, evt); err != nil {
		obs.LoggerFromContext(ctx).Error("audit publish failed",
			slog.String("action", string(action)),
			slog.String("session_id", sess.ID),
			slog.String("asc_id", sess.ASCID),
			slog.String("err", err.Error()),
		)
	}
}

// MarshalAuditEvent is a small helper exported for tests / debug tools
// that want the canonical JSON encoding without reaching into json.
func MarshalAuditEvent(evt AuditEvent) ([]byte, error) {
	b, err := json.Marshal(evt)
	if err != nil {
		return nil, fmt.Errorf("marshalling audit event: %w", err)
	}
	return b, nil
}
