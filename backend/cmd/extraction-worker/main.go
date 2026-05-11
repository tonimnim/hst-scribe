// Command extraction-worker consumes final transcripts and emits draft
// chart events via the LLM extractor (Claude on Bedrock). Phase B.
package main

import "github.com/tonimnim/hst-scribe/backend/internal/obs"

func main() { obs.RunSkeleton("extraction-worker", ":8083") }
