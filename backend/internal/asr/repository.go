package asr

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Repository is the persistence boundary for finalized transcripts.
// Consumer-defined here so service.go depends on the interface, not on
// pgx. Tests substitute an in-memory implementation.
type Repository interface {
	// InsertFinal persists a final transcript. Implementations MUST be
	// idempotent on the primary key — JetStream and provider retry
	// paths can both replay the same final.
	InsertFinal(ctx context.Context, t *Transcript) error
}

// ErrInvalidTranscript is returned by Repository.InsertFinal when a
// transcript fails the basic shape contract (missing id, missing
// session_id, not a final). Callers Term the source message rather
// than retrying — these errors are deterministic.
var ErrInvalidTranscript = errors.New("invalid transcript")

// PGRepository is the pgx-backed Repository. The pool is owned by
// main(); the repository never closes it.
type PGRepository struct {
	pool *pgxpool.Pool
}

// NewPGRepository constructs the Postgres-backed repository.
func NewPGRepository(pool *pgxpool.Pool) (*PGRepository, error) {
	if pool == nil {
		return nil, errors.New("asr.NewPGRepository: pool is nil")
	}
	return &PGRepository{pool: pool}, nil
}

// InsertFinal writes one row to transcripts. Idempotent on the primary
// key — a redelivery from JetStream is a no-op. Only is_final=true
// transcripts may pass this boundary; partials are caught and rejected
// so a bug elsewhere does not pollute the table.
func (r *PGRepository) InsertFinal(ctx context.Context, t *Transcript) error {
	if t == nil {
		return fmt.Errorf("%w: nil transcript", ErrInvalidTranscript)
	}
	if !t.IsFinal {
		return fmt.Errorf("%w: refusing to persist partial transcript", ErrInvalidTranscript)
	}
	if t.TranscriptID == "" {
		return fmt.Errorf("%w: missing transcript_id", ErrInvalidTranscript)
	}
	if t.SessionID == "" {
		return fmt.Errorf("%w: missing session_id", ErrInvalidTranscript)
	}

	speaker := string(t.Speaker)
	if speaker == "" {
		speaker = string(SpeakerUnknown)
	}

	// audio_chunk_ids is a UUID[] in Postgres. pgx accepts []string for
	// it when every element parses as a UUID, which is exactly our
	// invariant (publisher-minted UUIDv7s).
	chunkIDs := t.AudioChunkIDs
	if chunkIDs == nil {
		chunkIDs = []string{}
	}

	ts := t.EmittedAt
	if ts.IsZero() {
		// Fall back to now() via SQL default. Passing nil here would
		// trip pgx's type inference, so we use the simple two-statement
		// branch instead.
		const q = `
INSERT INTO transcripts
    (id, session_id, audio_chunk_ids, speaker, text, is_final, start_ms, end_ms)
VALUES
    ($1, $2, $3, $4, $5, true, $6, $7)
ON CONFLICT (id) DO NOTHING`
		if _, err := r.pool.Exec(ctx, q,
			t.TranscriptID,
			t.SessionID,
			chunkIDs,
			speaker,
			t.Text,
			t.StartMS,
			t.EndMS,
		); err != nil {
			return fmt.Errorf("inserting transcript %s: %w", t.TranscriptID, err)
		}
		return nil
	}

	const q = `
INSERT INTO transcripts
    (id, session_id, audio_chunk_ids, speaker, text, is_final, start_ms, end_ms, ts)
VALUES
    ($1, $2, $3, $4, $5, true, $6, $7, $8)
ON CONFLICT (id) DO NOTHING`
	if _, err := r.pool.Exec(ctx, q,
		t.TranscriptID,
		t.SessionID,
		chunkIDs,
		speaker,
		t.Text,
		t.StartMS,
		t.EndMS,
		ts.UTC(),
	); err != nil {
		return fmt.Errorf("inserting transcript %s: %w", t.TranscriptID, err)
	}
	return nil
}

// Compile-time check that *PGRepository satisfies Repository.
var _ Repository = (*PGRepository)(nil)
