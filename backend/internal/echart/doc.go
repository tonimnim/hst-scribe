// Package echart implements the chart-writer service: a NATS consumer that
// posts confirmed extraction events to HST eChart as drafts, persists their
// state in Postgres, and atomically promotes them on session sign.
//
// The package is intentionally self-contained for the chart-writer binary —
// it owns the HTTP client to eChart (mock in dev, real in prod), the
// JetStream durable consumers for the extracted.* and chart.sign.* subjects,
// the chart_writes ledger queries, and the dead-letter / audit emission
// plumbing. Other services depend on the eChart contract, not on this
// package.
//
// Files:
//
//   - client.go      — Client interface, request/response types, sentinel errors.
//   - httpclient.go  — HTTP implementation of Client with retry + DLQ routing.
//   - repository.go  — chart_writes table accessor (pgx).
//   - writer.go      — NATS-driven Writer service: handlers for confirmed,
//     rejected, and sign subjects; idempotency; audit + DLQ.
//
// PHI guardrails: this package never logs source_utterance, fields, or
// transcript text. Identifiers (session_id, event_id, patient_id,
// echart_entry_id, asc_id) and operational fields (status, attempts) are
// the only attributes that appear in logs. The obs.NewLogger handler also
// scrubs these keys at the slog boundary.
package echart
