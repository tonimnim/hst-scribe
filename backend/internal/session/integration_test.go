package session

import (
	"context"
	"errors"
	"os"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/nats-io/nats.go"

	"github.com/tonimnim/hst-scribe/backend/internal/uuidv7"
)

// integrationDSN / integrationNATS pull dev-compose endpoints. Override via env.
const (
	defaultDSN  = "postgres://hst:hst@localhost:5432/hst_scribe?sslmode=disable"
	defaultNATS = "nats://localhost:4222"
)

func integrationDSN(t *testing.T) string {
	t.Helper()
	if v := os.Getenv("POSTGRES_DSN"); v != "" {
		return v
	}
	return defaultDSN
}

func integrationNATSURL(t *testing.T) string {
	t.Helper()
	if v := os.Getenv("NATS_URL"); v != "" {
		return v
	}
	return defaultNATS
}

// setupDB opens a pool, applies 0001_sessions migration in a temp schema,
// and registers cleanup. Returns the live pool + the schema name we
// installed the table under so the test can clean up by dropping it.
func setupDB(t *testing.T) *pgxpool.Pool {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, integrationDSN(t))
	if err != nil {
		t.Skipf("postgres unavailable: %v", err)
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		t.Skipf("postgres ping failed: %v", err)
	}

	// Apply migration if the sessions table is absent. We run idempotently
	// so the test is safe against prior runs.
	if _, err := pool.Exec(ctx, sessionsUpSQL); err != nil {
		// Already applied? Continue. Otherwise bail.
		if !isAlreadyExistsErr(err) {
			t.Fatalf("applying migration: %v", err)
		}
	}

	// Wipe any rows from prior runs scoped to our well-known test ASC.
	if _, err := pool.Exec(ctx, "DELETE FROM sessions WHERE asc_id = $1", ascA); err != nil {
		t.Fatalf("cleanup: %v", err)
	}

	t.Cleanup(func() {
		if _, err := pool.Exec(context.Background(), "DELETE FROM sessions WHERE asc_id = $1", ascA); err != nil {
			t.Logf("cleanup delete: %v", err)
		}
		pool.Close()
	})
	return pool
}

// isAlreadyExistsErr is a tolerant check — any error containing "already
// exists" is treated as benign so re-running tests doesn't fail on the
// idempotent migration replay.
func isAlreadyExistsErr(err error) bool {
	return err != nil && containsCI(err.Error(), "already exists")
}

func containsCI(s, sub string) bool {
	for i := 0; i+len(sub) <= len(s); i++ {
		match := true
		for j := 0; j < len(sub); j++ {
			a, b := s[i+j], sub[j]
			if a >= 'A' && a <= 'Z' {
				a += 'a' - 'A'
			}
			if b >= 'A' && b <= 'Z' {
				b += 'a' - 'A'
			}
			if a != b {
				match = false
				break
			}
		}
		if match {
			return true
		}
	}
	return false
}

// sessionsUpSQL mirrors migrations/0001_sessions.up.sql. Embedded as a
// string to keep this test self-contained (no fs walk) and to avoid
// having the test ever skip silently on a missing file.
const sessionsUpSQL = `
DO $$ BEGIN
    CREATE TYPE session_status AS ENUM ('active', 'paused', 'ended', 'signed', 'expired');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE workflow_type AS ENUM ('pacu', 'preop', 'intraop');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS sessions (
    id                  UUID PRIMARY KEY,
    asc_id              UUID NOT NULL,
    patient_id          UUID NOT NULL,
    user_id             UUID NOT NULL,
    workflow_type       workflow_type NOT NULL,
    status              session_status NOT NULL DEFAULT 'active',
    reason              TEXT,
    started_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_activity_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at            TIMESTAMPTZ,
    signed_at           TIMESTAMPTZ,
    expires_at          TIMESTAMPTZ NOT NULL,
    signed_by_user_id   UUID
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_session_patient_active
    ON sessions (asc_id, patient_id)
    WHERE status IN ('active', 'paused');

CREATE INDEX IF NOT EXISTS idx_session_user_ts
    ON sessions (user_id, started_at DESC);

CREATE INDEX IF NOT EXISTS idx_session_expiry
    ON sessions (expires_at)
    WHERE status IN ('active', 'paused');
`

// setupNATS dials NATS with a short timeout. Skips if unreachable.
func setupNATS(t *testing.T) *nats.Conn {
	t.Helper()
	nc, err := nats.Connect(integrationNATSURL(t),
		nats.Timeout(2*time.Second),
		nats.MaxReconnects(0),
	)
	if err != nil {
		t.Skipf("nats unavailable: %v", err)
	}
	t.Cleanup(func() { _ = nc.Drain() })
	return nc
}

// TestIntegration_PatientLockAtDB verifies the unique partial index
// enforces the lock even if two requests slip past the application-level
// pre-check at the same time.
func TestIntegration_PatientLockAtDB(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in -short")
	}
	pool := setupDB(t)
	repo, err := NewPostgresRepository(pool)
	if err != nil {
		t.Fatalf("repo: %v", err)
	}

	now := time.Now().UTC()
	first, err := repo.Create(context.Background(), CreateArgs{
		ID: uuidv7.New(), ASCID: ascA, PatientID: patient1, UserID: userAlice,
		WorkflowType: WorkflowPACU, StartedAt: now, ExpiresAt: now.Add(30 * time.Minute),
	})
	if err != nil {
		t.Fatalf("first create: %v", err)
	}
	if first.Status != StatusActive {
		t.Errorf("status = %s, want active", first.Status)
	}

	// Second create with same asc+patient -> lock error with the
	// existing row attached.
	_, err = repo.Create(context.Background(), CreateArgs{
		ID: uuidv7.New(), ASCID: ascA, PatientID: patient1, UserID: userBob,
		WorkflowType: WorkflowPACU, StartedAt: now, ExpiresAt: now.Add(30 * time.Minute),
	})
	var lockErr *PatientLockError
	if !errors.As(err, &lockErr) {
		t.Fatalf("second create: err = %v, want PatientLockError", err)
	}
	if lockErr.Existing == nil || lockErr.Existing.ID != first.ID {
		t.Errorf("lockErr.Existing = %+v, want id=%s", lockErr.Existing, first.ID)
	}
}

// TestIntegration_EndUnlocks verifies that ending a session removes it
// from the lock index (i.e. a new session for the same patient can be
// created).
func TestIntegration_EndUnlocks(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in -short")
	}
	pool := setupDB(t)
	repo, err := NewPostgresRepository(pool)
	if err != nil {
		t.Fatalf("repo: %v", err)
	}

	now := time.Now().UTC()
	first, err := repo.Create(context.Background(), CreateArgs{
		ID: uuidv7.New(), ASCID: ascA, PatientID: patient1, UserID: userAlice,
		WorkflowType: WorkflowPACU, StartedAt: now, ExpiresAt: now.Add(30 * time.Minute),
	})
	if err != nil {
		t.Fatalf("first: %v", err)
	}

	if _, err := repo.UpdateStatus(context.Background(), first.ID, StatusEnded, "client_requested"); err != nil {
		t.Fatalf("end: %v", err)
	}

	second, err := repo.Create(context.Background(), CreateArgs{
		ID: uuidv7.New(), ASCID: ascA, PatientID: patient1, UserID: userBob,
		WorkflowType: WorkflowPACU, StartedAt: now.Add(time.Second), ExpiresAt: now.Add(30 * time.Minute),
	})
	if err != nil {
		t.Fatalf("second after end: %v", err)
	}
	if second.ID == first.ID {
		t.Errorf("expected new id, got same")
	}
}

// TestIntegration_ExpireIdle inserts a session with an old last_activity_at
// and verifies the expiry sweep flips it to 'expired'.
func TestIntegration_ExpireIdle(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in -short")
	}
	pool := setupDB(t)
	repo, err := NewPostgresRepository(pool)
	if err != nil {
		t.Fatalf("repo: %v", err)
	}

	now := time.Now().UTC()
	s, err := repo.Create(context.Background(), CreateArgs{
		ID: uuidv7.New(), ASCID: ascA, PatientID: patient2, UserID: userAlice,
		WorkflowType: WorkflowPACU, StartedAt: now, ExpiresAt: now.Add(30 * time.Minute),
	})
	if err != nil {
		t.Fatalf("create: %v", err)
	}
	// Backdate last_activity_at directly.
	if _, err := pool.Exec(context.Background(),
		"UPDATE sessions SET last_activity_at = $1 WHERE id = $2",
		now.Add(-31*time.Minute), s.ID); err != nil {
		t.Fatalf("backdate: %v", err)
	}
	expired, err := repo.ExpireIdle(context.Background(), now.Add(-30*time.Minute))
	if err != nil {
		t.Fatalf("expire: %v", err)
	}
	if len(expired) != 1 || expired[0].ID != s.ID {
		t.Fatalf("expired = %+v, want one row %s", expired, s.ID)
	}
	if expired[0].Status != StatusExpired {
		t.Errorf("status = %s, want expired", expired[0].Status)
	}
}

// TestIntegration_NATSAuditPublish exercises the NATS path end-to-end:
// subscribe, fire a session_created event, receive it.
func TestIntegration_NATSAuditPublish(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in -short")
	}
	nc := setupNATS(t)

	pub, err := NewNATSAuditPublisher(nc)
	if err != nil {
		t.Fatalf("publisher: %v", err)
	}

	subject := "audit.events." + ascA
	ch := make(chan *nats.Msg, 1)
	sub, err := nc.ChanSubscribe(subject, ch)
	if err != nil {
		t.Fatalf("subscribe: %v", err)
	}
	defer func() { _ = sub.Unsubscribe() }()

	evt := AuditEvent{
		ID:          uuidv7.New(),
		SessionID:   uuidv7.New(),
		ActorUserID: userAlice,
		ASCID:       ascA,
		Action:      AuditSessionCreated,
		TS:          time.Now().UTC(),
		Payload:     map[string]any{"workflow_type": "pacu"},
	}
	if err := pub.Publish(context.Background(), ascA, evt); err != nil {
		t.Fatalf("publish: %v", err)
	}

	select {
	case m := <-ch:
		if len(m.Data) == 0 {
			t.Fatal("empty message body")
		}
	case <-time.After(2 * time.Second):
		t.Fatal("timed out waiting for audit message")
	}
}
