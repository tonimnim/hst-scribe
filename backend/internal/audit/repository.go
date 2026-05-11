package audit

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// pgRepository is the Postgres-backed Repository. Append uses a single
// INSERT ... ON CONFLICT DO NOTHING — no transaction is needed.
type pgRepository struct {
	pool *pgxpool.Pool
}

// NewPGRepository wires a Repository over an already-initialized
// *pgxpool.Pool. The pool is owned by main(); the repository does not
// close it.
func NewPGRepository(pool *pgxpool.Pool) Repository {
	return &pgRepository{pool: pool}
}

// Append inserts e idempotently. The primary key is the publisher-minted
// UUIDv7, so re-delivery from JetStream is a no-op.
func (r *pgRepository) Append(ctx context.Context, e *Event) error {
	if e == nil {
		return fmt.Errorf("%w: nil event", ErrInvalidEvent)
	}
	if e.ID == "" || e.ASCID == "" || e.Action == "" {
		return fmt.Errorf("%w: missing required fields", ErrInvalidEvent)
	}
	if !e.Action.IsValid() {
		return fmt.Errorf("%w: unknown action %q", ErrInvalidEvent, e.Action)
	}

	payload, err := marshalPayload(e.Payload)
	if err != nil {
		return fmt.Errorf("marshaling payload for %s: %w", e.ID, err)
	}

	const q = `
		INSERT INTO audit_log
			(id, session_id, actor_user_id, asc_id, action, target_id, target_type, payload, ts)
		VALUES
			($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (id) DO NOTHING
	`
	if _, err := r.pool.Exec(ctx, q,
		e.ID,
		nullableString(e.SessionID),
		nullableString(e.ActorUserID),
		e.ASCID,
		string(e.Action),
		nullableString(e.TargetID),
		nullableString(e.TargetType),
		payload,
		e.TS.UTC(),
	); err != nil {
		return fmt.Errorf("inserting audit row %s: %w", e.ID, err)
	}
	return nil
}

// ListBySession returns every event for sessionID, oldest first. The
// query is indexed by (session_id, ts).
func (r *pgRepository) ListBySession(ctx context.Context, sessionID string) ([]Event, error) {
	if sessionID == "" {
		return nil, fmt.Errorf("%w: empty session_id", ErrInvalidEvent)
	}
	const q = `
		SELECT id, session_id, actor_user_id, asc_id, action,
		       target_id, target_type, payload, ts
		  FROM audit_log
		 WHERE session_id = $1
		 ORDER BY ts ASC, id ASC
	`
	rows, err := r.pool.Query(ctx, q, sessionID)
	if err != nil {
		return nil, fmt.Errorf("querying audit by session: %w", err)
	}
	defer rows.Close()

	out, err := scanEvents(rows)
	if err != nil {
		return nil, fmt.Errorf("scanning audit rows: %w", err)
	}
	return out, nil
}

// ListByUser pages through events for q.ActorUserID between q.From and
// q.To. Pagination is keyset on (ts, id) so insertions during paging do
// not cause skips or duplicates.
func (r *pgRepository) ListByUser(ctx context.Context, q UserQuery) ([]Event, string, error) {
	if q.ActorUserID == "" {
		return nil, "", fmt.Errorf("%w: empty actor_user_id", ErrInvalidEvent)
	}
	if q.Limit <= 0 {
		return nil, "", fmt.Errorf("%w: limit must be positive", ErrInvalidEvent)
	}
	if q.From.IsZero() || q.To.IsZero() {
		return nil, "", fmt.Errorf("%w: from/to required", ErrInvalidEvent)
	}
	if q.To.Before(q.From) {
		return nil, "", fmt.Errorf("%w: to before from", ErrInvalidEvent)
	}

	cursorTS, cursorID, err := decodeCursor(q.Cursor)
	if err != nil {
		return nil, "", err
	}

	// We fetch limit+1 to know whether another page exists without a
	// second COUNT query.
	//
	// When the cursor is empty we use a sentinel that sorts before any
	// real row: ts = -infinity, id = '00000000-...'. This keeps the
	// SQL identical between first-page and subsequent-page calls so
	// Postgres can reuse the same query plan.
	var (
		curTSArg any
		curIDArg any
	)
	if q.Cursor == "" {
		curTSArg = pgxMinusInfinity
		curIDArg = uuidZero
	} else {
		curTSArg = cursorTS
		curIDArg = cursorID
	}

	const sql = `
		SELECT id, session_id, actor_user_id, asc_id, action,
		       target_id, target_type, payload, ts
		  FROM audit_log
		 WHERE actor_user_id = $1
		   AND ts >= $2
		   AND ts <  $3
		   AND (ts, id) > ($4, $5)
		 ORDER BY ts ASC, id ASC
		 LIMIT $6
	`
	rows, err := r.pool.Query(ctx, sql,
		q.ActorUserID,
		q.From.UTC(),
		q.To.UTC(),
		curTSArg,
		curIDArg,
		q.Limit+1,
	)
	if err != nil {
		return nil, "", fmt.Errorf("querying audit by user: %w", err)
	}
	defer rows.Close()

	events, err := scanEvents(rows)
	if err != nil {
		return nil, "", fmt.Errorf("scanning audit rows: %w", err)
	}

	var nextCursor string
	if len(events) > q.Limit {
		// drop the sentinel row and encode the cursor from the LAST row
		// of the returned page.
		events = events[:q.Limit]
		last := events[len(events)-1]
		nextCursor = encodeCursor(last.TS, last.ID)
	}
	return events, nextCursor, nil
}

// --- scanning helpers ---

func scanEvents(rows pgx.Rows) ([]Event, error) {
	out := make([]Event, 0, 32)
	for rows.Next() {
		var (
			e           Event
			sessionID   *string
			actorUserID *string
			targetID    *string
			targetType  *string
			payloadRaw  []byte
		)
		if err := rows.Scan(
			&e.ID,
			&sessionID,
			&actorUserID,
			&e.ASCID,
			&e.Action,
			&targetID,
			&targetType,
			&payloadRaw,
			&e.TS,
		); err != nil {
			return nil, fmt.Errorf("scan row: %w", err)
		}
		e.SessionID = sessionID
		e.ActorUserID = actorUserID
		e.TargetID = targetID
		e.TargetType = targetType
		if len(payloadRaw) > 0 {
			var p map[string]any
			if err := json.Unmarshal(payloadRaw, &p); err != nil {
				return nil, fmt.Errorf("decoding payload for %s: %w", e.ID, err)
			}
			e.Payload = p
		}
		out = append(out, e)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows iteration: %w", err)
	}
	return out, nil
}

// marshalPayload always returns a JSONB-compatible byte slice. nil
// payload becomes the literal {} so the column never sees a SQL NULL.
func marshalPayload(p map[string]any) ([]byte, error) {
	if p == nil {
		return []byte(`{}`), nil
	}
	b, err := json.Marshal(p)
	if err != nil {
		return nil, fmt.Errorf("marshal payload: %w", err)
	}
	return b, nil
}

// nullableString converts a *string to interface{} suitable for pgx
// parameter binding: nil pointer → SQL NULL, otherwise the dereferenced
// value. We use any rather than sql.Null* to keep pgx happy with native
// JSONB serialization elsewhere.
func nullableString(s *string) any {
	if s == nil {
		return nil
	}
	return *s
}

// --- cursor encoding ---
//
// The cursor is "<rfc3339nano>|<uuid>" base64-url encoded. RFC3339Nano
// preserves the full timestamp precision Postgres stores, and the uuid
// disambiguates rows with identical ts. Base64 keeps it URL-safe.

const cursorSep = "|"

// pgxMinusInfinity is the wire sentinel for a timestamp earlier than any
// real row. Postgres parses the bare literal -infinity into the
// timestamp's minus-infinity special value. We send it as a string so
// pgx doesn't try to map it through time.Time (which has no -infinity
// representation).
const pgxMinusInfinity = "-infinity"

// uuidZero is the lowest sortable UUID, used as a paging sentinel for
// the very first page request (when no real cursor exists yet).
const uuidZero = "00000000-0000-0000-0000-000000000000"

func encodeCursor(ts time.Time, id string) string {
	raw := ts.UTC().Format(time.RFC3339Nano) + cursorSep + id
	return base64.RawURLEncoding.EncodeToString([]byte(raw))
}

func decodeCursor(c string) (time.Time, string, error) {
	if c == "" {
		// Epoch + empty id sorts before any real row.
		return time.Time{}, "", nil
	}
	raw, err := base64.RawURLEncoding.DecodeString(c)
	if err != nil {
		return time.Time{}, "", fmt.Errorf("%w: %s", ErrInvalidCursor, err.Error())
	}
	parts := splitOnce(string(raw), cursorSep)
	if len(parts) != 2 {
		return time.Time{}, "", fmt.Errorf("%w: malformed", ErrInvalidCursor)
	}
	ts, err := time.Parse(time.RFC3339Nano, parts[0])
	if err != nil {
		return time.Time{}, "", fmt.Errorf("%w: bad ts", ErrInvalidCursor)
	}
	if parts[1] == "" {
		return time.Time{}, "", fmt.Errorf("%w: empty id", ErrInvalidCursor)
	}
	return ts, parts[1], nil
}

func splitOnce(s, sep string) []string {
	for i := 0; i+len(sep) <= len(s); i++ {
		if s[i:i+len(sep)] == sep {
			return []string{s[:i], s[i+len(sep):]}
		}
	}
	return []string{s}
}
