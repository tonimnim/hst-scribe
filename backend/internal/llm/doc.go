// Package llm defines the LLM provider abstraction used by the
// extraction worker.
//
// A Provider takes a fully-assembled prompt plus a JSON schema and
// returns a JSON document conforming to that schema. The schema is the
// extracted-event schema (contract/schemas/event-schema.json); the
// envelope returned is { "events": [...] }.
//
// Two implementations live here:
//
//   - FakeProvider — reads dev/seed/utterances.json and returns the
//     pre-canned expected_events for any utterance that loosely matches
//     a seeded one. Used for unit tests, the eval-test, and local dev.
//   - BedrockClaudeProvider — Claude 3.5 Sonnet via AWS Bedrock.
//     Skeleton only in Wave 1; the AWS SDK is intentionally not pulled
//     in until Phase 2 wiring.
//
// Provider is small so a real implementation lives next to the fake,
// and so the extract package never imports the AWS SDK transitively.
package llm
