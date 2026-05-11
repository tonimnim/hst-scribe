package session

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"sync"
	"testing"
	"time"
)

// --- fake repo + audit publisher ---

// fakeRepo is an in-memory Repository for unit tests. It enforces the
// patient-lock invariant exactly the way the partial unique index does.
type fakeRepo struct {
	mu       sync.Mutex
	sessions map[string]*Session // id -> session
	now      func() time.Time
}

func newFakeRepo() *fakeRepo {
	return &fakeRepo{
		sessions: make(map[string]*Session),
		now:      time.Now,
	}
}

func (r *fakeRepo) clone(s *Session) *Session {
	if s == nil {
		return nil
	}
	cp := *s
	return &cp
}

func (r *fakeRepo) Create(_ context.Context, args CreateArgs) (*Session, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, s := range r.sessions {
		if s.ASCID == args.ASCID && s.PatientID == args.PatientID && !s.Status.IsTerminal() {
			return r.clone(s), &PatientLockError{Existing: r.clone(s)}
		}
	}
	s := &Session{
		ID:             args.ID,
		ASCID:          args.ASCID,
		PatientID:      args.PatientID,
		UserID:         args.UserID,
		WorkflowType:   args.WorkflowType,
		Status:         StatusActive,
		StartedAt:      args.StartedAt,
		LastActivityAt: args.StartedAt,
		ExpiresAt:      args.ExpiresAt,
	}
	r.sessions[s.ID] = s
	return r.clone(s), nil
}

func (r *fakeRepo) Get(_ context.Context, id string) (*Session, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	s, ok := r.sessions[id]
	if !ok {
		return nil, ErrNotFound
	}
	return r.clone(s), nil
}

func (r *fakeRepo) UpdateStatus(_ context.Context, id string, status Status, reason string) (*Session, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	s, ok := r.sessions[id]
	if !ok {
		return nil, ErrNotFound
	}
	if !ValidTransition(s.Status, status) {
		return nil, ErrInvalidTransition
	}
	s.Status = status
	if reason != "" {
		s.Reason = reason
	}
	if status == StatusEnded || status == StatusExpired {
		t := r.now()
		s.EndedAt = &t
	}
	return r.clone(s), nil
}

func (r *fakeRepo) Sign(_ context.Context, id string, signedBy string, signedAt time.Time) (*Session, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	s, ok := r.sessions[id]
	if !ok {
		return nil, ErrNotFound
	}
	if !ValidTransition(s.Status, StatusSigned) {
		return nil, ErrInvalidTransition
	}
	s.Status = StatusSigned
	s.SignedAt = &signedAt
	s.SignedByUserID = signedBy
	return r.clone(s), nil
}

func (r *fakeRepo) ListActiveByPatient(_ context.Context, ascID, patientID string) ([]*Session, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []*Session
	for _, s := range r.sessions {
		if s.ASCID == ascID && s.PatientID == patientID && !s.Status.IsTerminal() {
			out = append(out, r.clone(s))
		}
	}
	return out, nil
}

func (r *fakeRepo) ExpireIdle(_ context.Context, threshold time.Time) ([]*Session, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var out []*Session
	for _, s := range r.sessions {
		if s.Status.IsTerminal() {
			continue
		}
		if s.LastActivityAt.Before(threshold) {
			s.Status = StatusExpired
			t := r.now()
			s.EndedAt = &t
			s.Reason = "inactivity_timeout"
			out = append(out, r.clone(s))
		}
	}
	return out, nil
}

// fakePub records all published audit events.
type fakePub struct {
	mu     sync.Mutex
	events []AuditEvent
	err    error
}

func (p *fakePub) Publish(_ context.Context, _ string, evt AuditEvent) error {
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.err != nil {
		return p.err
	}
	p.events = append(p.events, evt)
	return nil
}

func (p *fakePub) snapshot() []AuditEvent {
	p.mu.Lock()
	defer p.mu.Unlock()
	out := make([]AuditEvent, len(p.events))
	copy(out, p.events)
	return out
}

// quietLogger discards output so tests don't spam stdout.
func quietLogger() *slog.Logger {
	return slog.New(slog.NewTextHandler(io.Discard, &slog.HandlerOptions{Level: slog.LevelError}))
}

// fixedClock returns a clock function pinned at t.
func fixedClock(t time.Time) func() time.Time { return func() time.Time { return t } }

// newTestService is a small constructor used by every test below.
func newTestService(t *testing.T, now time.Time) (*Service, *fakeRepo, *fakePub) {
	t.Helper()
	repo := newFakeRepo()
	repo.now = fixedClock(now)
	pub := &fakePub{}
	svc, err := NewService(repo, pub, quietLogger(),
		WithClock(fixedClock(now)),
		WithSessionTTL(30*time.Minute),
		WithIdleThreshold(30*time.Minute),
		WithExpiryTickInterval(50*time.Millisecond),
	)
	if err != nil {
		t.Fatalf("NewService: %v", err)
	}
	return svc, repo, pub
}

// --- tests ---

const (
	ascA      = "01931e00-0000-7000-8000-00000000aaaa"
	patient1  = "01931e00-0000-7000-8000-000000000001"
	patient2  = "01931e00-0000-7000-8000-000000000002"
	userAlice = "01931e00-0000-7000-8000-000000000a01"
	userBob   = "01931e00-0000-7000-8000-000000000b02"
)

func TestCreateSession_HappyPath(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, _, pub := newTestService(t, now)

	got, err := svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU,
	})
	if err != nil {
		t.Fatalf("CreateSession: %v", err)
	}
	if got.Status != StatusActive {
		t.Errorf("status = %s, want active", got.Status)
	}
	if !got.ExpiresAt.Equal(now.Add(30 * time.Minute)) {
		t.Errorf("expires_at = %v, want now+30m", got.ExpiresAt)
	}
	evts := pub.snapshot()
	if len(evts) != 1 || evts[0].Action != AuditSessionCreated {
		t.Errorf("audit events = %+v, want one session_created", evts)
	}
}

func TestCreateSession_PatientLock(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)

	cases := []struct {
		name        string
		secondUser  string
		wantLockErr bool
		wantSameID  bool
	}{
		{
			name:        "same user is idempotent",
			secondUser:  userAlice,
			wantLockErr: false,
			wantSameID:  true,
		},
		{
			name:        "different user is locked",
			secondUser:  userBob,
			wantLockErr: true,
			wantSameID:  true, // we still return the existing row for context
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			svc, _, _ := newTestService(t, now)
			first, err := svc.CreateSession(context.Background(), CreateSessionInput{
				ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU,
			})
			if err != nil {
				t.Fatalf("first create: %v", err)
			}

			second, err := svc.CreateSession(context.Background(), CreateSessionInput{
				ASCID: ascA, PatientID: patient1, UserID: tc.secondUser, WorkflowType: WorkflowPACU,
			})

			var lockErr *PatientLockError
			gotLock := errors.As(err, &lockErr)
			if gotLock != tc.wantLockErr {
				t.Fatalf("lockErr = %v, err = %v, want lock=%v", gotLock, err, tc.wantLockErr)
			}
			if second == nil {
				t.Fatal("second session is nil")
			}
			if tc.wantSameID && second.ID != first.ID {
				t.Errorf("second.ID = %s, want existing %s", second.ID, first.ID)
			}
		})
	}
}

func TestCreateSession_DifferentPatientsAllowed(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, _, _ := newTestService(t, now)
	if _, err := svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU,
	}); err != nil {
		t.Fatalf("first: %v", err)
	}
	if _, err := svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient2, UserID: userAlice, WorkflowType: WorkflowPACU,
	}); err != nil {
		t.Fatalf("second different patient: %v", err)
	}
}

func TestCreateSession_AfterEnd_NewSessionAllowed(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, _, pub := newTestService(t, now)
	first, err := svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU,
	})
	if err != nil {
		t.Fatalf("first: %v", err)
	}
	if _, err := svc.EndSession(context.Background(), first.ID, userAlice, "client_requested"); err != nil {
		t.Fatalf("end: %v", err)
	}
	second, err := svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient1, UserID: userBob, WorkflowType: WorkflowPACU,
	})
	if err != nil {
		t.Fatalf("second after end: %v", err)
	}
	if second.ID == first.ID {
		t.Errorf("expected new session id, got same %s", first.ID)
	}
	actions := []AuditAction{}
	for _, e := range pub.snapshot() {
		actions = append(actions, e.Action)
	}
	wantContains := []AuditAction{AuditSessionCreated, AuditSessionEnded, AuditSessionCreated}
	if len(actions) != len(wantContains) {
		t.Fatalf("audit actions = %v, want %v", actions, wantContains)
	}
	for i := range actions {
		if actions[i] != wantContains[i] {
			t.Errorf("audit action[%d] = %s, want %s", i, actions[i], wantContains[i])
		}
	}
}

func TestStateTransitions(t *testing.T) {
	t.Parallel()
	cases := []struct {
		name string
		from Status
		to   Status
		ok   bool
	}{
		{"active->paused", StatusActive, StatusPaused, true},
		{"active->ended", StatusActive, StatusEnded, true},
		{"active->signed", StatusActive, StatusSigned, true},
		{"active->expired", StatusActive, StatusExpired, true},
		{"paused->active", StatusPaused, StatusActive, true},
		{"paused->ended", StatusPaused, StatusEnded, true},
		{"paused->expired", StatusPaused, StatusExpired, true},
		{"paused->signed (must end first)", StatusPaused, StatusSigned, false},
		{"ended->signed", StatusEnded, StatusSigned, true},
		{"ended->active (terminal-ish)", StatusEnded, StatusActive, false},
		{"signed->anything", StatusSigned, StatusEnded, false},
		{"expired->anything", StatusExpired, StatusActive, false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if got := ValidTransition(tc.from, tc.to); got != tc.ok {
				t.Errorf("ValidTransition(%s,%s) = %v, want %v", tc.from, tc.to, got, tc.ok)
			}
		})
	}
}

func TestSignSession_FromActive(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, _, pub := newTestService(t, now)
	created, err := svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU,
	})
	if err != nil {
		t.Fatalf("create: %v", err)
	}
	signed, err := svc.SignSession(context.Background(), created.ID, userAlice)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	if signed.Status != StatusSigned {
		t.Errorf("status = %s, want signed", signed.Status)
	}
	if signed.SignedAt == nil {
		t.Error("signed_at is nil")
	}
	if signed.SignedByUserID != userAlice {
		t.Errorf("signed_by_user_id = %s, want %s", signed.SignedByUserID, userAlice)
	}
	// Two events: created, signed.
	events := pub.snapshot()
	if len(events) != 2 {
		t.Fatalf("events = %d, want 2", len(events))
	}
	if events[1].Action != AuditSessionSigned {
		t.Errorf("last action = %s, want session_signed", events[1].Action)
	}
}

func TestEndSession_FromSignedRejected(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, _, _ := newTestService(t, now)
	created, _ := svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU,
	})
	if _, err := svc.SignSession(context.Background(), created.ID, userAlice); err != nil {
		t.Fatalf("sign: %v", err)
	}
	_, err := svc.EndSession(context.Background(), created.ID, userAlice, "after_sign")
	if !errors.Is(err, ErrInvalidTransition) {
		t.Fatalf("end after sign: err = %v, want ErrInvalidTransition", err)
	}
}

func TestExpiryWorker_MarksIdleSessions(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, repo, pub := newTestService(t, now)

	created, err := svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU,
	})
	if err != nil {
		t.Fatalf("create: %v", err)
	}

	// Force last_activity_at to be older than 30 minutes.
	repo.mu.Lock()
	repo.sessions[created.ID].LastActivityAt = now.Add(-31 * time.Minute)
	repo.mu.Unlock()

	// Run one tick synchronously instead of launching the goroutine, so
	// we avoid racing the test deadline.
	svc.expireOnce(context.Background())

	got, err := svc.GetSession(context.Background(), created.ID)
	if err != nil {
		t.Fatalf("get after expiry: %v", err)
	}
	if got.Status != StatusExpired {
		t.Errorf("status = %s, want expired", got.Status)
	}

	events := pub.snapshot()
	if len(events) < 2 || events[len(events)-1].Action != AuditSessionExpired {
		t.Errorf("last audit action = %v, want session_expired", events)
	}
}

func TestExpiryWorker_LeavesFreshSessionsAlone(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, _, _ := newTestService(t, now)
	created, err := svc.CreateSession(context.Background(), CreateSessionInput{
		ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU,
	})
	if err != nil {
		t.Fatalf("create: %v", err)
	}
	svc.expireOnce(context.Background())
	got, err := svc.GetSession(context.Background(), created.ID)
	if err != nil {
		t.Fatalf("get: %v", err)
	}
	if got.Status != StatusActive {
		t.Errorf("status = %s, want active", got.Status)
	}
}

func TestCreateSession_ValidationErrors(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 5, 11, 14, 30, 0, 0, time.UTC)
	svc, _, _ := newTestService(t, now)
	cases := []struct {
		name string
		in   CreateSessionInput
	}{
		{"missing asc_id", CreateSessionInput{PatientID: patient1, UserID: userAlice, WorkflowType: WorkflowPACU}},
		{"missing patient_id", CreateSessionInput{ASCID: ascA, UserID: userAlice, WorkflowType: WorkflowPACU}},
		{"missing user_id", CreateSessionInput{ASCID: ascA, PatientID: patient1, WorkflowType: WorkflowPACU}},
		{"bad workflow_type", CreateSessionInput{ASCID: ascA, PatientID: patient1, UserID: userAlice, WorkflowType: "garbage"}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			_, err := svc.CreateSession(context.Background(), tc.in)
			if err == nil {
				t.Fatal("err = nil, want validation error")
			}
		})
	}
}
