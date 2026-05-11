package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Refresh-token rotation errors. Callers discriminate with errors.Is.
var (
	// ErrUnknownRefresh is returned when the presented token does not
	// match any stored hash. The token may have been issued by a
	// different deployment or already pruned.
	ErrUnknownRefresh = errors.New("unknown refresh token")

	// ErrExpired is returned when the presented token's expires_at has
	// passed. Family is not revoked — natural expiry is not a security
	// event.
	ErrExpired = errors.New("refresh token expired")

	// ErrReplayDetected is returned when the presented token was
	// already rotated. The entire token family is revoked: the
	// presenter is either an attacker or a client with a stale copy.
	// Either way the user must re-authenticate.
	ErrReplayDetected = errors.New("refresh token replay detected; family revoked")

	// ErrAlreadyRevoked is returned when the presented token (and its
	// family) was previously revoked by an explicit Revoke call.
	ErrAlreadyRevoked = errors.New("refresh token revoked")
)

// RefreshStore manages refresh-token rotation in Postgres. Tokens are
// hashed with SHA-256 before storage; the raw token bytes only ever
// exist on the wire and in the requesting client.
type RefreshStore struct {
	pool        *pgxpool.Pool
	ttl         time.Duration
	now         func() time.Time
	tokenLength int
}

// RefreshStoreOption configures NewRefreshStore.
type RefreshStoreOption func(*RefreshStore)

// WithRefreshTTL overrides the default refresh-token lifetime (30 days).
func WithRefreshTTL(ttl time.Duration) RefreshStoreOption {
	return func(s *RefreshStore) {
		if ttl > 0 {
			s.ttl = ttl
		}
	}
}

// WithClock overrides the clock used for issued_at/expires_at.
// Primarily for tests.
func WithClock(now func() time.Time) RefreshStoreOption {
	return func(s *RefreshStore) {
		if now != nil {
			s.now = now
		}
	}
}

// NewRefreshStore wires a RefreshStore over an existing pgxpool.Pool.
// The pool is owned by main(); the store does not close it.
func NewRefreshStore(pool *pgxpool.Pool, opts ...RefreshStoreOption) *RefreshStore {
	s := &RefreshStore{
		pool:        pool,
		ttl:         30 * 24 * time.Hour,
		now:         time.Now,
		tokenLength: 32, // 256 bits
	}
	for _, opt := range opts {
		opt(s)
	}
	return s
}

// IssuedToken is the result of Issue / Rotate. Token is the raw bearer
// returned to the client exactly once; it MUST NOT be logged or
// persisted server-side as plaintext.
type IssuedToken struct {
	Token     string
	ID        uuid.UUID
	FamilyID  uuid.UUID
	ExpiresAt time.Time
}

// Issue mints a new refresh token for userID and seeds a new family.
// The raw token is returned in IssuedToken.Token; only its sha256 hash
// is persisted.
func (s *RefreshStore) Issue(ctx context.Context, userID uuid.UUID) (IssuedToken, error) {
	if userID == uuid.Nil {
		return IssuedToken{}, errors.New("refresh: empty user_id")
	}
	familyID, err := uuid.NewV7()
	if err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: minting family id: %w", err)
	}
	return s.insert(ctx, userID, familyID)
}

// Rotate atomically:
//
//  1. Looks up the row matching sha256(presented).
//  2. If absent → ErrUnknownRefresh.
//  3. If expires_at past → ErrExpired (family not revoked).
//  4. If already revoked → reuse-detection. Revoke the entire family
//     and return ErrReplayDetected (or ErrAlreadyRevoked if it was an
//     explicit revoke).
//  5. Otherwise: mark revoked, mint a successor in the same family,
//     and return the new token.
//
// Steps 1–4 happen inside a single transaction at SERIALIZABLE
// isolation so concurrent rotations cannot both succeed against the
// same parent.
func (s *RefreshStore) Rotate(ctx context.Context, presented string) (IssuedToken, error) {
	if presented == "" {
		return IssuedToken{}, ErrUnknownRefresh
	}
	hash := hashToken(presented)

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.Serializable})
	if err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: begin tx: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	const lookupSQL = `
		SELECT id, user_id, family_id, expires_at, revoked_at, replaced_by
		  FROM auth_refresh_tokens
		 WHERE token_hash = $1
		 FOR UPDATE
	`
	var (
		id, userID, familyID uuid.UUID
		expiresAt            time.Time
		revokedAt            *time.Time
		replacedBy           *uuid.UUID
	)
	if err := tx.QueryRow(ctx, lookupSQL, hash).Scan(
		&id, &userID, &familyID, &expiresAt, &revokedAt, &replacedBy,
	); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return IssuedToken{}, ErrUnknownRefresh
		}
		return IssuedToken{}, fmt.Errorf("refresh: lookup: %w", err)
	}

	now := s.now()
	if !expiresAt.After(now) {
		// Natural expiry; no replay signal.
		return IssuedToken{}, ErrExpired
	}

	if revokedAt != nil {
		// Already revoked. If it has a replaced_by, this is a reuse of
		// a rotated parent — definitive replay. Revoke the whole
		// family (idempotent) and signal.
		if err := revokeFamilyTx(ctx, tx, familyID, now); err != nil {
			return IssuedToken{}, err
		}
		if err := tx.Commit(ctx); err != nil {
			return IssuedToken{}, fmt.Errorf("refresh: commit family revoke: %w", err)
		}
		if replacedBy != nil {
			return IssuedToken{}, ErrReplayDetected
		}
		return IssuedToken{}, ErrAlreadyRevoked
	}

	// Happy path: mint successor + revoke parent in the same tx.
	successorID, err := uuid.NewV7()
	if err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: minting successor id: %w", err)
	}
	rawToken, err := generateToken(s.tokenLength)
	if err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: generating token: %w", err)
	}
	successorHash := hashToken(rawToken)
	successorExp := now.Add(s.ttl)

	const insertSQL = `
		INSERT INTO auth_refresh_tokens
			(id, user_id, family_id, token_hash, issued_at, expires_at)
		VALUES
			($1, $2, $3, $4, $5, $6)
	`
	if _, err := tx.Exec(ctx, insertSQL,
		successorID, userID, familyID, successorHash, now.UTC(), successorExp.UTC(),
	); err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: insert successor: %w", err)
	}

	const revokeSQL = `
		UPDATE auth_refresh_tokens
		   SET revoked_at = $2,
		       replaced_by = $3
		 WHERE id = $1
	`
	if _, err := tx.Exec(ctx, revokeSQL, id, now.UTC(), successorID); err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: revoke parent: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: commit rotation: %w", err)
	}

	return IssuedToken{
		Token:     rawToken,
		ID:        successorID,
		FamilyID:  familyID,
		ExpiresAt: successorExp,
	}, nil
}

// Revoke marks every non-revoked refresh token for userID as revoked.
// Used by the admin "kick everyone out" flow and by user-initiated
// logout-everywhere.
func (s *RefreshStore) Revoke(ctx context.Context, userID uuid.UUID) error {
	if userID == uuid.Nil {
		return errors.New("refresh: empty user_id")
	}
	const q = `
		UPDATE auth_refresh_tokens
		   SET revoked_at = $2
		 WHERE user_id = $1
		   AND revoked_at IS NULL
	`
	if _, err := s.pool.Exec(ctx, q, userID, s.now().UTC()); err != nil {
		return fmt.Errorf("refresh: revoking user tokens: %w", err)
	}
	return nil
}

// RevokeFamily marks every non-revoked token in the given family as
// revoked. Exposed for testing the replay-detection behavior directly.
func (s *RefreshStore) RevokeFamily(ctx context.Context, familyID uuid.UUID) error {
	if familyID == uuid.Nil {
		return errors.New("refresh: empty family_id")
	}
	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("refresh: begin tx: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	if err := revokeFamilyTx(ctx, tx, familyID, s.now()); err != nil {
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("refresh: commit family revoke: %w", err)
	}
	return nil
}

// --- internals ---

func (s *RefreshStore) insert(ctx context.Context, userID, familyID uuid.UUID) (IssuedToken, error) {
	id, err := uuid.NewV7()
	if err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: minting id: %w", err)
	}
	raw, err := generateToken(s.tokenLength)
	if err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: generating token: %w", err)
	}
	now := s.now()
	exp := now.Add(s.ttl)

	const q = `
		INSERT INTO auth_refresh_tokens
			(id, user_id, family_id, token_hash, issued_at, expires_at)
		VALUES
			($1, $2, $3, $4, $5, $6)
	`
	if _, err := s.pool.Exec(ctx, q,
		id, userID, familyID, hashToken(raw), now.UTC(), exp.UTC(),
	); err != nil {
		return IssuedToken{}, fmt.Errorf("refresh: inserting: %w", err)
	}
	return IssuedToken{
		Token:     raw,
		ID:        id,
		FamilyID:  familyID,
		ExpiresAt: exp,
	}, nil
}

func revokeFamilyTx(ctx context.Context, tx pgx.Tx, familyID uuid.UUID, now time.Time) error {
	const q = `
		UPDATE auth_refresh_tokens
		   SET revoked_at = $2
		 WHERE family_id = $1
		   AND revoked_at IS NULL
	`
	if _, err := tx.Exec(ctx, q, familyID, now.UTC()); err != nil {
		return fmt.Errorf("refresh: revoking family: %w", err)
	}
	return nil
}

// generateToken returns a URL-safe random string with `n` bytes of
// entropy (so 32 → ~43 chars).
func generateToken(n int) (string, error) {
	buf := make([]byte, n)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

// hashToken returns the SHA-256 digest of the raw token. SHA-256 is
// adequate for this purpose: the raw token is already a 256-bit random
// secret, so a fast hash with constant-time comparison is the right
// trade-off — no per-row salt needed, no bcrypt latency on every
// refresh.
func hashToken(raw string) []byte {
	sum := sha256.Sum256([]byte(raw))
	return sum[:]
}
