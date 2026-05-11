// Command chart-writer pushes confirmed events into HST eChart on sign
// and handles the draft-event endpoint round-trip. Phase B.
package main

import "github.com/tonimnim/hst-scribe/backend/internal/obs"

func main() { obs.RunSkeleton("chart-writer", ":8084") }
