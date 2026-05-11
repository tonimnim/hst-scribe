package echart

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

// WriteStatus mirrors the chart_write_status enum in migration 0005.
type WriteStatus string

// WriteStatus values.
const (
	StatusPending  WriteStatus = "pending"
	StatusWritten  WriteStatus = "written"
	StatusFailed   WriteStatus = "failed"
	StatusPromoted WriteStatus = "promoted"
	StatusRejected WriteStatus = "rejected"
)

// ChartWrite is one row of the chart_writes ledger.
type ChartWrite struct {
	ID            string
	SessionID     string
	EventID       string
	PatientID     string
	EChartEntryID *string
	Status        WriteStatus
	Attempts      int
	LastError     *string
	WrittenAt     *time.Time
	PromotedAt    *time.Time
}

// Repository is the consumer-side persistence interface for chart_writes.
// Implemented by PGRepository; tests substitute an in-memory fake.
type Repository interface {
	// InsertPending creates the ledger row in 'pending' state. Returns
	// ErrDuplicateEventID when (event_id) already exists — the caller
	// (Writer.handleConfirmed) treats this as an idempotent re-delivery
	// and skips the POST.
	InsertPending(ctx context.Context, w ChartWrite) error

	// InsertRejected creates the ledger row in 'rejected' state. Same
	// duplicate-key semantics as InsertPending.
	InsertRejected(ctx context.Context, w ChartWrite) error

	// MarkWritten records a successful draft POST: status='written',
	// echart_entry_id set, written_at=now, attempts incremented.
	MarkWritten(ctx context.Context, eventID, echartEntryID string, attempts int, writtenAt time.Time) error

	// MarkFailed records terminal failure after retry exhaustion:
	// status='failed', last_error set, attempts incremented.
	MarkFailed(ctx context.Context, eventID string, attempts int, lastError string) error

	// ListWrittenBySession returns every chart_writes row for a session
	// in 'written' state. Used at sign time to assemble the event_ids
	// array for SignSession.
	ListWrittenBySession(ctx context.Context, sessionID string) ([]ChartWrite, error)

	// MarkPromoted moves a set of rows from 'written' to 'promoted'
	// atomically. eventIDs are filtered server-side to only update
	// rows still in 'written' — re-running the promotion is a no-op.
	MarkPromoted(ctx context.Context, eventIDs []string, promotedAt time.Time) error
}

// ErrDuplicateEventID is returned by InsertPending / InsertRejected when
// the row already exists (event_id is UNIQUE in 0005). Callers treat
// this as idempotent dedupe, not a failure.
var ErrDuplicateEventID = errors.New("chart_writes: event_id already exists")

// PGRepository is the pgx-backed implementation of Repository.
type PGRepository struct {
	pool *pgxpool.Pool
}

// NewPGRepository constructs a PGRepository. pool must be non-nil.
func NewPGRepository(pool *pgxpool.Pool) (*PGRepository, error) {
	if pool == nil {
		return nil, errors.New("echart.NewPGRepository: pool is nil")
	}
	return &PGRepository{pool: pool}, nil
}

const insertPendingSQL = `
INSERT INTO chart_writes (id, session_id, event_id, patient_id, status, attempts)
VALUES ($1, $2, $3, $4, 'pending', 0)
`

// InsertPending implements Repository.
func (r *PGRepository) InsertPending(ctx context.Context, w ChartWrite) error {
	_, err := r.pool.Exec(ctx, insertPendingSQL, w.ID, w.SessionID, w.EventID, w.PatientID)
	if err != nil {
		if isUniqueViolation(err) {
			return ErrDuplicateEventID
		}
		return fmt.Errorf("inserting pending chart_write: %w", err)
	}
	return nil
}

const insertRejectedSQL = `
INSERT INTO chart_writes (id, session_id, event_id, patient_id, status, attempts)
VALUES ($1, $2, $3, $4, 'rejected', 0)
`

// InsertRejected implements Repository.
func (r *PGRepository) InsertRejected(ctx context.Context, w ChartWrite) error {
	_, err := r.pool.Exec(ctx, insertRejectedSQL, w.ID, w.SessionID, w.EventID, w.PatientID)
	if err != nil {
		if isUniqueViolation(err) {
			return ErrDuplicateEventID
		}
		return fmt.Errorf("inserting rejected chart_write: %w", err)
	}
	return nil
}

const markWrittenSQL = `
UPDATE chart_writes
   SET status = 'written',
       echart_entry_id = $2,
       attempts = $3,
       written_at = $4,
       last_error = NULL
 WHERE event_id = $1
`

// MarkWritten implements Repository.
func (r *PGRepository) MarkWritten(ctx context.Context, eventID, echartEntryID string, attempts int, writtenAt time.Time) error {
	tag, err := r.pool.Exec(ctx, markWrittenSQL, eventID, echartEntryID, attempts, writtenAt)
	if err != nil {
		return fmt.Errorf("mark written %s: %w", eventID, err)
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("mark written %s: no row updated", eventID)
	}
	return nil
}

const markFailedSQL = `
UPDATE chart_writes
   SET status = 'failed',
       attempts = $2,
       last_error = $3
 WHERE event_id = $1
`

// MarkFailed implements Repository.
func (r *PGRepository) MarkFailed(ctx context.Context, eventID string, attempts int, lastError string) error {
	tag, err := r.pool.Exec(ctx, markFailedSQL, eventID, attempts, lastError)
	if err != nil {
		return fmt.Errorf("mark failed %s: %w", eventID, err)
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("mark failed %s: no row updated", eventID)
	}
	return nil
}

const listWrittenSQL = `
SELECT id, session_id, event_id, patient_id, echart_entry_id, status, attempts, last_error, written_at, promoted_at
  FROM chart_writes
 WHERE session_id = $1 AND status = 'written'
 ORDER BY written_at ASC NULLS LAST
`

// ListWrittenBySession implements Repository.
func (r *PGRepository) ListWrittenBySession(ctx context.Context, sessionID string) ([]ChartWrite, error) {
	rows, err := r.pool.Query(ctx, listWrittenSQL, sessionID)
	if err != nil {
		return nil, fmt.Errorf("list written by session %s: %w", sessionID, err)
	}
	defer rows.Close()

	var out []ChartWrite
	for rows.Next() {
		var w ChartWrite
		if err := rows.Scan(
			&w.ID, &w.SessionID, &w.EventID, &w.PatientID,
			&w.EChartEntryID, &w.Status, &w.Attempts, &w.LastError,
			&w.WrittenAt, &w.PromotedAt,
		); err != nil {
			return nil, fmt.Errorf("scanning chart_write row: %w", err)
		}
		out = append(out, w)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterating chart_write rows: %w", err)
	}
	return out, nil
}

const markPromotedSQL = `
UPDATE chart_writes
   SET status = 'promoted',
       promoted_at = $2
 WHERE event_id = ANY($1::uuid[])
   AND status = 'written'
`

// MarkPromoted implements Repository.
func (r *PGRepository) MarkPromoted(ctx context.Context, eventIDs []string, promotedAt time.Time) error {
	if len(eventIDs) == 0 {
		return nil
	}
	_, err := r.pool.Exec(ctx, markPromotedSQL, eventIDs, promotedAt)
	if err != nil {
		return fmt.Errorf("mark promoted: %w", err)
	}
	return nil
}

// isUniqueViolation reports whether err is a Postgres unique-key violation
// (SQLSTATE 23505). The chart_writes table has UNIQUE on event_id; this is
// the only constraint we care about for idempotency.
func isUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		return pgErr.Code == "23505"
	}
	return false
}

// Compile-time check.
var (
	_ Repository = (*PGRepository)(nil)
	_           = pgx.ErrNoRows // keep import for future read-path methods
)
