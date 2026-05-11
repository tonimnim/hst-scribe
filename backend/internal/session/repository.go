package session

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/tonimnim/hst-scribe/backend/internal/pg"
)

// PostgresRepository is the pgx-backed Repository implementation. The
// pool must be non-nil; constructors validate this.
type PostgresRepository struct {
	pool *pg.Pool
}

// NewPostgresRepository builds a Repository backed by pool. The pool is
// owned by the caller; PostgresRepository never closes it.
func NewPostgresRepository(pool *pg.Pool) (*PostgresRepository, error) {
	if pool == nil {
		return nil, errors.New("session.NewPostgresRepository: pool is nil")
	}
	return &PostgresRepository{pool: pool}, nil
}

// sessionColumns is the canonical SELECT list. Used by every read path
// so column ordering for Scan stays in sync.
const sessionColumns = `id, asc_id, patient_id, user_id, workflow_type, status,
       COALESCE(reason, ''), started_at, last_activity_at, ended_at,
       signed_at, expires_at, signed_by_user_id`

// scanSession reads one row from rows into a *Session. rows.Scan errors
// are returned wrapped with context.
func scanSession(row pgx.Row) (*Session, error) {
	var (
		s        Session
		endedAt  *time.Time
		signedAt *time.Time
		signedBy *string
		workflow string
		status   string
	)
	if err := row.Scan(
		&s.ID, &s.ASCID, &s.PatientID, &s.UserID, &workflow, &status,
		&s.Reason, &s.StartedAt, &s.LastActivityAt, &endedAt,
		&signedAt, &s.ExpiresAt, &signedBy,
	); err != nil {
		return nil, err
	}
	s.WorkflowType = WorkflowType(workflow)
	s.Status = Status(status)
	s.EndedAt = endedAt
	s.SignedAt = signedAt
	if signedBy != nil {
		s.SignedByUserID = *signedBy
	}
	return &s, nil
}

// Create inserts a new session row. On unique-violation of the
// idx_session_patient_active partial index it returns *PatientLockError
// with the existing locking row attached so the service layer can decide
// between idempotent return and a 409.
func (r *PostgresRepository) Create(ctx context.Context, args CreateArgs) (*Session, error) {
	const insertSQL = `
INSERT INTO sessions (id, asc_id, patient_id, user_id, workflow_type, status,
                     started_at, last_activity_at, expires_at)
VALUES ($1, $2, $3, $4, $5::workflow_type, 'active',
        $6, $6, $7)
RETURNING ` + sessionColumns

	row := r.pool.QueryRow(ctx, insertSQL,
		args.ID, args.ASCID, args.PatientID, args.UserID,
		string(args.WorkflowType), args.StartedAt, args.ExpiresAt,
	)
	s, err := scanSession(row)
	if err == nil {
		return s, nil
	}

	// Unique-violation: someone else holds the patient lock. Look up the
	// existing row and surface it for idempotency handling upstream.
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		existing, lookupErr := r.findActiveByPatient(ctx, args.ASCID, args.PatientID)
		if lookupErr != nil {
			return nil, fmt.Errorf("looking up locking session after 23505: %w", lookupErr)
		}
		return existing, &PatientLockError{Existing: existing}
	}

	return nil, fmt.Errorf("inserting session %s: %w", args.ID, err)
}

// findActiveByPatient returns the single non-terminal session for
// (asc, patient) if any. Used only after a 23505 from Create — at most
// one row can exist by virtue of the unique partial index.
func (r *PostgresRepository) findActiveByPatient(ctx context.Context, ascID, patientID string) (*Session, error) {
	const q = `
SELECT ` + sessionColumns + `
FROM sessions
WHERE asc_id = $1 AND patient_id = $2 AND status IN ('active','paused')
LIMIT 1`
	row := r.pool.QueryRow(ctx, q, ascID, patientID)
	s, err := scanSession(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			// The unique-violation just happened; if the row is gone now
			// it was raced by an expiry/end. Surface as not-found so the
			// caller can retry.
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("querying active session: %w", err)
	}
	return s, nil
}

// Get returns the session by id or ErrNotFound.
func (r *PostgresRepository) Get(ctx context.Context, id string) (*Session, error) {
	const q = `SELECT ` + sessionColumns + ` FROM sessions WHERE id = $1`
	row := r.pool.QueryRow(ctx, q, id)
	s, err := scanSession(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, fmt.Errorf("selecting session %s: %w", id, err)
	}
	return s, nil
}

// UpdateStatus performs a read-validate-write within a single transaction
// to avoid TOCTOU. Returns ErrInvalidTransition if the new status is not
// reachable from the current one.
func (r *PostgresRepository) UpdateStatus(ctx context.Context, id string, status Status, reason string) (*Session, error) {
	if !status.Valid() {
		return nil, fmt.Errorf("update status: %w: %q", ErrInvalidTransition, status)
	}

	var out *Session
	err := pgx.BeginFunc(ctx, r.pool, func(tx pgx.Tx) error {
		const selectSQL = `SELECT ` + sessionColumns + ` FROM sessions WHERE id = $1 FOR UPDATE`
		current, err := scanSession(tx.QueryRow(ctx, selectSQL, id))
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return ErrNotFound
			}
			return fmt.Errorf("selecting session %s for update: %w", id, err)
		}

		if !ValidTransition(current.Status, status) {
			return fmt.Errorf("%w: %s -> %s", ErrInvalidTransition, current.Status, status)
		}

		// ended/expired/paused set their respective columns; sign is
		// handled by Sign(), not UpdateStatus.
		const updateSQL = `
UPDATE sessions
SET status   = $2::session_status,
    reason   = COALESCE(NULLIF($3, ''), reason),
    ended_at = CASE WHEN $2 IN ('ended','expired') THEN now() ELSE ended_at END
WHERE id = $1
RETURNING ` + sessionColumns

		row := tx.QueryRow(ctx, updateSQL, id, string(status), reason)
		out, err = scanSession(row)
		if err != nil {
			return fmt.Errorf("updating session %s: %w", id, err)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return out, nil
}

// Sign atomically promotes the session to 'signed', stamping
// signed_at + signed_by_user_id. Valid from 'active' or 'ended'.
func (r *PostgresRepository) Sign(ctx context.Context, id string, signedByUserID string, signedAt time.Time) (*Session, error) {
	var out *Session
	err := pgx.BeginFunc(ctx, r.pool, func(tx pgx.Tx) error {
		const selectSQL = `SELECT ` + sessionColumns + ` FROM sessions WHERE id = $1 FOR UPDATE`
		current, err := scanSession(tx.QueryRow(ctx, selectSQL, id))
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return ErrNotFound
			}
			return fmt.Errorf("selecting session %s for sign: %w", id, err)
		}

		if !ValidTransition(current.Status, StatusSigned) {
			return fmt.Errorf("%w: %s -> signed", ErrInvalidTransition, current.Status)
		}

		const updateSQL = `
UPDATE sessions
SET status            = 'signed',
    signed_at         = $2,
    signed_by_user_id = $3
WHERE id = $1
RETURNING ` + sessionColumns

		row := tx.QueryRow(ctx, updateSQL, id, signedAt, signedByUserID)
		out, err = scanSession(row)
		if err != nil {
			return fmt.Errorf("signing session %s: %w", id, err)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return out, nil
}

// ListActiveByPatient returns all non-terminal sessions for (asc, patient).
// In practice at most one row exists due to the unique partial index.
func (r *PostgresRepository) ListActiveByPatient(ctx context.Context, ascID, patientID string) ([]*Session, error) {
	const q = `
SELECT ` + sessionColumns + `
FROM sessions
WHERE asc_id = $1 AND patient_id = $2 AND status IN ('active','paused')
ORDER BY started_at ASC`
	rows, err := r.pool.Query(ctx, q, ascID, patientID)
	if err != nil {
		return nil, fmt.Errorf("listing active sessions: %w", err)
	}
	defer rows.Close()

	var out []*Session
	for rows.Next() {
		s, err := scanSession(rows)
		if err != nil {
			return nil, fmt.Errorf("scanning active session row: %w", err)
		}
		out = append(out, s)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating active sessions: %w", err)
	}
	return out, nil
}

// ExpireIdle marks every non-terminal session with last_activity_at older
// than threshold as 'expired'. Returns the newly expired rows so the
// caller can emit one audit event per session.
//
// The UPDATE ... RETURNING runs in a single round-trip and the partial
// index keeps the scan bounded to non-terminal sessions.
func (r *PostgresRepository) ExpireIdle(ctx context.Context, threshold time.Time) ([]*Session, error) {
	const q = `
UPDATE sessions
SET status   = 'expired',
    ended_at = now(),
    reason   = COALESCE(NULLIF(reason, ''), 'inactivity_timeout')
WHERE status IN ('active','paused')
  AND last_activity_at < $1
RETURNING ` + sessionColumns

	rows, err := r.pool.Query(ctx, q, threshold)
	if err != nil {
		return nil, fmt.Errorf("expiring idle sessions: %w", err)
	}
	defer rows.Close()

	var out []*Session
	for rows.Next() {
		s, err := scanSession(rows)
		if err != nil {
			return nil, fmt.Errorf("scanning expired session row: %w", err)
		}
		out = append(out, s)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating expired sessions: %w", err)
	}
	return out, nil
}

// Compile-time check that *PostgresRepository satisfies Repository.
var _ Repository = (*PostgresRepository)(nil)
