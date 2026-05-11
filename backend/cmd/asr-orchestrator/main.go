// Command asr-orchestrator streams audio chunks to the upstream ASR
// provider and republishes partial/final transcripts on NATS. Phase B.
package main

import "github.com/tonimnim/hst-scribe/backend/internal/obs"

func main() { obs.RunSkeleton("asr-orchestrator", ":8082") }
