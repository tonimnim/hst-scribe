// Package uuidv7 provides a thin wrapper around github.com/google/uuid
// that mints UUIDv7 (time-ordered) identifiers. All HST Scribe primary
// keys are UUIDv7 — they sort lexically by creation time and play well
// as Postgres b-tree keys.
package uuidv7

import (
	"fmt"

	"github.com/google/uuid"
)

// New returns a new UUIDv7 string. It panics only if the operating
// system's random number generator fails, which is treated as a fatal
// process condition — callers should not see this in practice.
func New() string {
	id, err := uuid.NewV7()
	if err != nil {
		// crypto/rand failure is unrecoverable; mint will be retried by
		// the caller's process supervisor after a panic in main.
		panic(fmt.Errorf("uuidv7: %w", err))
	}
	return id.String()
}

// Parse parses a UUID string and returns an error if it is not a valid
// UUID. Versions other than v7 are accepted (we ingest IDs from
// external sources too).
func Parse(s string) (uuid.UUID, error) {
	id, err := uuid.Parse(s)
	if err != nil {
		return uuid.Nil, fmt.Errorf("parsing uuid %q: %w", s, err)
	}
	return id, nil
}
