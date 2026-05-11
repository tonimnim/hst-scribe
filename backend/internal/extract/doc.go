// Package extract owns the transcript-to-event pipeline:
//
//   - prompt assembly (system + patient context + recent transcripts +
//     the new utterance) — see prompt.go
//   - calling the configured llm.Provider
//   - post-processing the raw LLM JSON into typed
//     contract.ExtractedEvent values
//   - imperative-vs-fact safety net (validator.go)
//   - RxNorm validation and confidence capping (validator.go)
//   - semantic dedupe across overlapping transcript windows (dedupe.go)
//   - persistence to Postgres and republish onto NATS (service.go)
//
// The package boundary is intentionally narrow: callers wire a
// Service with concrete dependencies and call HandleTranscript per
// final transcript. Everything else is internal.
package extract
