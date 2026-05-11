package audit

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/tonimnim/hst-scribe/backend/internal/auth"
	"github.com/tonimnim/hst-scribe/backend/internal/config"
	"github.com/tonimnim/hst-scribe/backend/internal/uuidv7"
)

// integrationDSN is the connection string for the dev/docker-compose
// Postgres. Override via AUDIT_TEST_DSN to point at a different instance.
const defaultIntegrationDSN = "postgres://hst:hst@localhost:5432/hst_scribe?sslmode=disable"

// pgPoolForTest connects to Postgres and applies the audit_log schema
// onto a private schema so tests are isolated from each other and from
// any production-shaped data.
//
// Skips the test (via t.Skip) when the database is unreachable — that
// way `go test ./...` from a clean checkout still passes on a developer
// machine without docker compose running.
func pgPoolForTest(t *testing.T) *pgxpool.Pool {
	t.Helper()

	dsn := os.Getenv("AUDIT_TEST_DSN")
	if dsn == "" {
		dsn = defaultIntegrationDSN
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	// Pre-flight ping with a temporary admin pool. If the database is
	// down we skip; if it's up we create our test schema and then
	// reopen the real pool with search_path baked into the DSN so every
	// pooled connection sees the same private namespace.
	adminPool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		t.Skipf("postgres not available (%s): %v", dsn, err)
	}
	if err := adminPool.Ping(ctx); err != nil {
		adminPool.Close()
		t.Skipf("postgres ping failed (%s): %v — start dev/docker-compose first", dsn, err)
	}

	schema := fmt.Sprintf("audit_test_%d", time.Now().UnixNano())
	if _, err := adminPool.Exec(ctx, fmt.Sprintf(`CREATE SCHEMA %q`, schema)); err != nil {
		adminPool.Close()
		t.Fatalf("create schema: %v", err)
	}
	if _, err := adminPool.Exec(ctx, fmt.Sprintf(`SET search_path TO %q`, schema)); err != nil {
		adminPool.Close()
		t.Fatalf("set search_path: %v", err)
	}
	const ddl = `
		CREATE TABLE audit_log (
		    id            UUID PRIMARY KEY,
		    session_id    UUID,
		    actor_user_id UUID,
		    asc_id        UUID NOT NULL,
		    action        TEXT NOT NULL,
		    target_id     UUID,
		    target_type   TEXT,
		    payload       JSONB NOT NULL DEFAULT '{}'::jsonb,
		    ts            TIMESTAMPTZ NOT NULL DEFAULT now()
		);
		CREATE INDEX idx_audit_session ON audit_log (session_id, ts);
		CREATE INDEX idx_audit_user_ts ON audit_log (actor_user_id, ts);
		CREATE INDEX idx_audit_asc_ts  ON audit_log (asc_id, ts);
	`
	if _, err := adminPool.Exec(ctx, ddl); err != nil {
		adminPool.Close()
		t.Fatalf("apply ddl: %v", err)
	}
	adminPool.Close()

	cfgURL, err := url.Parse(dsn)
	if err != nil {
		t.Fatalf("parse dsn: %v", err)
	}
	// pgx supports the "search_path" runtime parameter via the
	// "options" libpq DSN parameter.
	q := cfgURL.Query()
	q.Set("search_path", schema)
	cfgURL.RawQuery = q.Encode()

	pool, err := pgxpool.New(ctx, cfgURL.String())
	if err != nil {
		t.Fatalf("reopen pool: %v", err)
	}

	t.Cleanup(func() {
		cleanupCtx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		// Reopen an admin pool for cleanup (the test pool is search_path
		// scoped and DROP SCHEMA needs to run from outside it).
		clean, err := pgxpool.New(cleanupCtx, dsn)
		if err != nil {
			t.Logf("cleanup pool: %v", err)
			pool.Close()
			return
		}
		defer clean.Close()
		if _, err := clean.Exec(cleanupCtx, fmt.Sprintf(`DROP SCHEMA %q CASCADE`, schema)); err != nil {
			t.Logf("schema cleanup failed: %v", err)
		}
		pool.Close()
	})

	return pool
}

func TestRepository_AppendAndList(t *testing.T) {
	pool := pgPoolForTest(t)
	repo := NewPGRepository(pool)
	ctx := context.Background()

	ascID := uuidv7.New()
	sessionID := uuidv7.New()
	userID := uuidv7.New()

	base := time.Date(2026, 5, 11, 14, 0, 0, 0, time.UTC)
	events := []Event{
		{
			ID:          uuidv7.New(),
			SessionID:   &sessionID,
			ActorUserID: &userID,
			ASCID:       ascID,
			Action:      ActionSessionCreated,
			Payload:     map[string]any{"workflow_type": "pacu"},
			TS:          base,
		},
		{
			ID:          uuidv7.New(),
			SessionID:   &sessionID,
			ActorUserID: &userID,
			ASCID:       ascID,
			Action:      ActionEventExtracted,
			Payload:     map[string]any{"event_id": "evt-1"},
			TS:          base.Add(1 * time.Second),
		},
		{
			ID:          uuidv7.New(),
			SessionID:   &sessionID,
			ActorUserID: &userID,
			ASCID:       ascID,
			Action:      ActionSessionSigned,
			Payload:     map[string]any{"events_written": float64(7)},
			TS:          base.Add(2 * time.Second),
		},
	}

	for _, e := range events {
		e := e
		if err := repo.Append(ctx, &e); err != nil {
			t.Fatalf("Append: %v", err)
		}
	}

	// Idempotent: replaying the first event must not error and must not
	// insert a second row.
	if err := repo.Append(ctx, &events[0]); err != nil {
		t.Fatalf("Append (replay): %v", err)
	}

	got, err := repo.ListBySession(ctx, sessionID)
	if err != nil {
		t.Fatalf("ListBySession: %v", err)
	}
	if len(got) != 3 {
		t.Fatalf("want 3 rows, got %d", len(got))
	}
	// Verify ordering by ts ASC.
	for i := 1; i < len(got); i++ {
		if got[i].TS.Before(got[i-1].TS) {
			t.Errorf("rows not ordered ascending: %v", got)
		}
	}
	// Payload survived round-trip.
	if got[0].Payload["workflow_type"] != "pacu" {
		t.Errorf("payload not round-tripped: %#v", got[0].Payload)
	}
}

func TestRepository_RejectsInvalid(t *testing.T) {
	pool := pgPoolForTest(t)
	repo := NewPGRepository(pool)
	ctx := context.Background()

	cases := map[string]Event{
		"empty id":     {ASCID: "asc-1", Action: ActionSessionCreated},
		"empty asc":    {ID: uuidv7.New(), Action: ActionSessionCreated},
		"empty action": {ID: uuidv7.New(), ASCID: uuidv7.New()},
		"bad action":   {ID: uuidv7.New(), ASCID: uuidv7.New(), Action: Action("nope")},
	}
	for name, e := range cases {
		e := e
		t.Run(name, func(t *testing.T) {
			if err := repo.Append(ctx, &e); err == nil {
				t.Errorf("expected error for %s", name)
			}
		})
	}
}

func TestRepository_ListByUser_Pagination(t *testing.T) {
	pool := pgPoolForTest(t)
	repo := NewPGRepository(pool)
	ctx := context.Background()

	ascID := uuidv7.New()
	userID := uuidv7.New()
	otherUser := uuidv7.New()
	base := time.Date(2026, 5, 11, 14, 0, 0, 0, time.UTC)

	// Insert 7 events for our user and 3 for a different user.
	for i := 0; i < 7; i++ {
		e := Event{
			ID:          uuidv7.New(),
			ActorUserID: &userID,
			ASCID:       ascID,
			Action:      ActionEventConfirmed,
			TS:          base.Add(time.Duration(i) * time.Second),
		}
		if err := repo.Append(ctx, &e); err != nil {
			t.Fatalf("seed: %v", err)
		}
	}
	for i := 0; i < 3; i++ {
		e := Event{
			ID:          uuidv7.New(),
			ActorUserID: &otherUser,
			ASCID:       ascID,
			Action:      ActionEventConfirmed,
			TS:          base.Add(time.Duration(i) * time.Second),
		}
		if err := repo.Append(ctx, &e); err != nil {
			t.Fatalf("seed other: %v", err)
		}
	}

	// First page, limit 3.
	page1, cursor1, err := repo.ListByUser(ctx, UserQuery{
		ActorUserID: userID,
		From:        base.Add(-1 * time.Hour),
		To:          base.Add(1 * time.Hour),
		Limit:       3,
	})
	if err != nil {
		t.Fatalf("page1: %v", err)
	}
	if len(page1) != 3 || cursor1 == "" {
		t.Fatalf("want 3 rows + cursor, got %d rows / cursor=%q", len(page1), cursor1)
	}

	// Second page.
	page2, cursor2, err := repo.ListByUser(ctx, UserQuery{
		ActorUserID: userID,
		From:        base.Add(-1 * time.Hour),
		To:          base.Add(1 * time.Hour),
		Limit:       3,
		Cursor:      cursor1,
	})
	if err != nil {
		t.Fatalf("page2: %v", err)
	}
	if len(page2) != 3 || cursor2 == "" {
		t.Fatalf("want 3 rows + cursor, got %d / %q", len(page2), cursor2)
	}

	// Third page — only one row left, no cursor.
	page3, cursor3, err := repo.ListByUser(ctx, UserQuery{
		ActorUserID: userID,
		From:        base.Add(-1 * time.Hour),
		To:          base.Add(1 * time.Hour),
		Limit:       3,
		Cursor:      cursor2,
	})
	if err != nil {
		t.Fatalf("page3: %v", err)
	}
	if len(page3) != 1 || cursor3 != "" {
		t.Fatalf("want 1 row + empty cursor, got %d / %q", len(page3), cursor3)
	}

	// No duplication / drift across pages.
	seen := make(map[string]struct{})
	for _, p := range [][]Event{page1, page2, page3} {
		for _, e := range p {
			if _, dup := seen[e.ID]; dup {
				t.Errorf("duplicate event across pages: %s", e.ID)
			}
			seen[e.ID] = struct{}{}
			if e.ActorUserID == nil || *e.ActorUserID != userID {
				t.Errorf("wrong user in result set: %v", e.ActorUserID)
			}
		}
	}
}

func TestServer_RoundTrip(t *testing.T) {
	pool := pgPoolForTest(t)
	repo := NewPGRepository(pool)

	const secret = "test-secret-must-be-long-enough-for-hs256-validation"
	cfg := &config.Config{JWTSecret: secret}
	validator, err := auth.NewHMACValidator(cfg)
	if err != nil {
		t.Fatalf("validator: %v", err)
	}

	server := NewServer(repo, validator, testLogger(t))
	ts := httptest.NewServer(server.Routes())
	t.Cleanup(ts.Close)

	// Seed an event.
	ascID := uuidv7.New()
	sessionID := uuidv7.New()
	userID := uuidv7.New()
	eventID := uuidv7.New()
	if err := repo.Append(context.Background(), &Event{
		ID:          eventID,
		SessionID:   &sessionID,
		ActorUserID: &userID,
		ASCID:       ascID,
		Action:      ActionSessionCreated,
		Payload:     map[string]any{"workflow_type": "pacu"},
		TS:          time.Now().UTC(),
	}); err != nil {
		t.Fatalf("seed: %v", err)
	}

	// Mint a token with the compliance role.
	complianceToken := mintTokenForTest(t, secret, "compliance", userID, ascID)
	nurseToken := mintTokenForTest(t, secret, "nurse", userID, ascID)

	t.Run("session lookup happy path", func(t *testing.T) {
		req, _ := http.NewRequest(http.MethodGet, ts.URL+"/api/v1/audit/sessions/"+sessionID, nil)
		req.Header.Set("Authorization", "Bearer "+complianceToken)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatalf("GET: %v", err)
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			body, _ := io.ReadAll(resp.Body)
			t.Fatalf("status = %d: %s", resp.StatusCode, body)
		}
		var body listResponse
		if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
			t.Fatalf("decode: %v", err)
		}
		if len(body.Events) != 1 || body.Events[0].ID != eventID {
			t.Errorf("unexpected body: %#v", body)
		}
	})

	t.Run("nurse role forbidden", func(t *testing.T) {
		req, _ := http.NewRequest(http.MethodGet, ts.URL+"/api/v1/audit/sessions/"+sessionID, nil)
		req.Header.Set("Authorization", "Bearer "+nurseToken)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatalf("GET: %v", err)
		}
		defer resp.Body.Close()
		if resp.StatusCode != http.StatusForbidden {
			t.Errorf("status = %d, want 403", resp.StatusCode)
		}
	})

	t.Run("missing auth", func(t *testing.T) {
		req, _ := http.NewRequest(http.MethodGet, ts.URL+"/api/v1/audit/sessions/"+sessionID, nil)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatalf("GET: %v", err)
		}
		defer resp.Body.Close()
		if resp.StatusCode != http.StatusUnauthorized {
			t.Errorf("status = %d, want 401", resp.StatusCode)
		}
	})

	t.Run("user lookup with paging", func(t *testing.T) {
		from := time.Now().Add(-24 * time.Hour).UTC().Format(time.RFC3339)
		to := time.Now().Add(24 * time.Hour).UTC().Format(time.RFC3339)
		u := fmt.Sprintf("%s/api/v1/audit/users/%s?from=%s&to=%s&limit=10",
			ts.URL, userID, url.QueryEscape(from), url.QueryEscape(to))
		req, _ := http.NewRequest(http.MethodGet, u, nil)
		req.Header.Set("Authorization", "Bearer "+complianceToken)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatalf("GET: %v", err)
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			body, _ := io.ReadAll(resp.Body)
			t.Fatalf("status = %d: %s", resp.StatusCode, body)
		}
		var body listResponse
		if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
			t.Fatalf("decode: %v", err)
		}
		if len(body.Events) != 1 {
			t.Errorf("want 1 event, got %d", len(body.Events))
		}
	})

	t.Run("healthz", func(t *testing.T) {
		resp, err := http.Get(ts.URL + "/healthz")
		if err != nil {
			t.Fatalf("GET: %v", err)
		}
		defer resp.Body.Close()
		if resp.StatusCode != http.StatusOK {
			t.Errorf("healthz status = %d", resp.StatusCode)
		}
	})
}

// --- test helpers ---

func mintTokenForTest(t *testing.T, secret, role, userID, ascID string) string {
	t.Helper()
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":     userID,
		"user_id": userID,
		"asc_id":  ascID,
		"role":    role,
		"exp":     time.Now().Add(15 * time.Minute).Unix(),
	})
	signed, err := tok.SignedString([]byte(secret))
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	return signed
}

// testLogger returns a *slog.Logger that writes to io.Discard so test
// runs stay quiet but every call site we care about is exercised.
func testLogger(t *testing.T) *slog.Logger {
	t.Helper()
	return slog.New(slog.NewTextHandler(io.Discard, nil))
}
