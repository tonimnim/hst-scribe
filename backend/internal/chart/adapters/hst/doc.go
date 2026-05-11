// Package hst is the chart.Adapter implementation for the HST eChart
// EHR — the only adapter shipping in Wave 2.
//
// Boundaries:
//
//   - The exported Adapter type satisfies chart.Adapter and is the only
//     symbol cmd/chart-writer and cmd/gateway construct.
//   - The Writer service (chart-writer's NATS subscriber) lives here for
//     now because the audit/DLQ/idempotency story is identical for HST
//     and FHIR; when FHIR lands we will lift the writer up to
//     internal/chart/ and parameterize it on chart.Adapter directly.
//   - The HTTP client (httpClient) and the chart_writes repository
//     (PGRepository) are HST-specific by virtue of HST's URL shape and
//     UUIDv7 echart_entry_id semantics, but they are exported for the
//     test boundary and re-use across the package.
//
// PHI guardrails: this package never logs source_utterance, fields, or
// transcript text. Identifiers (session_id, event_id, patient_id,
// echart_entry_id, asc_id) and operational fields (status, attempts)
// are the only attributes that appear in logs. The obs.NewLogger
// handler also scrubs these keys at the slog boundary.
//
// Migration note: this package was internal/echart through Wave 1. The
// rename to internal/chart/adapters/hst happens with no wire-format
// change — only the Go import path and a few type names move.
package hst
