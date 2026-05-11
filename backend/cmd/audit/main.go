// Command audit consumes lifecycle events from NATS and appends to the
// tamper-evident audit log. Phase B.
package main

import "github.com/tonimnim/hst-scribe/backend/internal/obs"

func main() { obs.RunSkeleton("audit", ":8085") }
