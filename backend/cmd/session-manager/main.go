// Command session-manager owns session lifecycle: patient lock,
// idempotent creation, expiry, and audit emission. Phase B fills it in.
package main

import "github.com/tonimnim/hst-scribe/backend/internal/obs"

func main() { obs.RunSkeleton("session-manager", ":8081") }
