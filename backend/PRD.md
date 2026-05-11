# PRD: HST Scribe Backend (Go)

## Overview

Service cluster that ingests streaming audio from the mobile app, performs ASR + clinical extraction, writes draft chart events to HST eChart, and pushes real-time updates back to the mobile client.

## Goals

- End-to-end latency p95 < 2s from utterance to event card on device
- 99.9% session-level reliability — no audio loss mid-session
- Per-tenant horizontal scalability (per-ASC isolation)
- Full audit trail of every audio chunk, transcript, extraction, edit, and chart write

## Non-goals (MVP)

- Self-hosted ASR (use AWS Transcribe Medical with BAA)
- Self-hosted LLM (use Claude via AWS Bedrock with BAA)
- Real-time clinical decision support (Phase 3)
- Auto-coding for billing (Phase 3)

## Architecture — services

| Service | Responsibility |
|---|---|
| Gateway | WSS endpoint, auth, session routing, REST API |
| Session manager | Patient context lock, lifecycle, audit emission |
| ASR orchestrator | Streams audio to ASR provider, merges diarization, emits transcripts |
| Extraction worker | Transcript → structured events via LLM with RAG |
| Chart writer | Posts draft events to HST eChart, handles sign promotion |
| Audit service | Append-only event log |
| Event broker | NATS JetStream connecting services asynchronously |

## Functional requirements

### Gateway
- **FR1** Accept WSS upgrade with OAuth2 Bearer JWT
- **FR2** Validate tenant, user, active session
- **FR3** Per-tenant rate limits (configurable)
- **FR4** Forward audio chunks to ASR orchestrator via NATS
- **FR5** Subscribe to per-session output topics and stream messages back to mobile
- **FR6** Serve REST API per `contract/CONTRACT.md`

### Session manager
- **FR7** Create session with `patient_id`, `user_id`, `workflow_type`, `asc_id`
- **FR8** Refuse start if patient already locked by another active session (`patient_locked` error)
- **FR9** Auto-close after 30 min inactivity; client warning at 25 min
- **FR10** Emit lifecycle events to audit

### ASR orchestrator
- **FR11** Maintain streaming ASR connection per active session
- **FR12** Reconnect without audio loss (5-second buffer)
- **FR13** Emit partial and final transcripts on broker
- **FR14** Attach speaker labels per segment (pyannote or ASR-native diarization)
- **FR15** Failover to backup ASR provider (Phase 1+)

### Extraction worker
- **FR16** Subscribe to final transcripts per session
- **FR17** Maintain rolling context: last 5 min transcript + patient chart context (fetched from eChart at session start, cached)
- **FR18** Call LLM with function-calling schema mirroring eChart fields (see `contract/schemas/event-schema.json`)
- **FR19** Deduplicate events across overlapping transcript windows (semantic match + time window)
- **FR20** Confidence score per field
- **FR21** Validate extracted entities against vocabularies — RxNorm (meds), SNOMED (conditions), LOINC (labs)
- **FR22** Flag or drop hallucinations (drug not in RxNorm, dose outside valid range)
- **FR23** Differentiate past-tense action from imperative intent — only the former produces events

### Chart writer
- **FR24** POST draft events to HST eChart `/draft-events` endpoint
- **FR25** Exponential backoff and DLQ on eChart API failures
- **FR26** On `POST /sessions/{id}/sign`: promote all `confirmed` drafts to final eChart entries atomically
- **FR27** Emit write-confirmation events back through broker → gateway → WSS

### Audit service
- **FR28** Append-only log of every chunk, transcript, extraction, edit, confirm, reject, sign
- **FR29** Every derived record carries source audio chunk ID hash
- **FR30** Tamper-evident (append-only storage or signed entries)
- **FR31** Queryable for compliance review by session, user, patient, time range

## API surface

External (mobile) and internal (eChart) surfaces are defined in `contract/CONTRACT.md`. Do not invent endpoints here — extend the contract.

## Data model — core tables

```
sessions            (id, asc_id, patient_id, user_id, workflow_type, status, started_at, ended_at, signed_at, expires_at)
audio_chunks        (id, session_id, seq, duration_ms, storage_key, received_at)   -- bytes in S3
transcripts         (id, session_id, audio_chunk_ids[], speaker, text, is_final, start_ms, end_ms, ts)
extracted_events    (id, session_id, event_type, fields jsonb, confidence, source_transcript_ids[], source_utterance, status, extracted_at, event_time)
audit_log           (id, session_id, actor_user_id, action, target_id, target_type, payload jsonb, ts)
chart_writes        (id, session_id, event_id, echart_entry_id, status, attempts, last_error, written_at)
```

All tables partitioned by `asc_id` for tenant isolation. UUIDv7 primary keys throughout.

## SLOs

| Metric | Target |
|---|---|
| Audio chunk ingest | p99 < 100ms |
| ASR partial transcript | p95 < 800ms |
| Event extraction | p95 < 1.5s after final transcript |
| End-to-end (utterance → event card) | p95 < 2s |
| Session reliability | 99.9% |

## Security & compliance

- mTLS between internal services
- AES-256 at rest with envelope encryption via KMS, per-tenant data keys
- Audio retained 30 days then auto-deleted; transcripts per-tenant policy
- All third-party services under BAA (AWS, ASR vendor, LLM vendor)
- HITRUST r2 controls extended to this pipeline
- No PHI in logs, metrics, or traces — ID references only
- Token refresh path uses rotation + replay detection

## Stack

| Concern | Choice |
|---|---|
| Language | Go 1.22+ |
| HTTP router | `chi` |
| WebSocket | `nhooyr.io/websocket` |
| Inter-service | gRPC |
| Broker | NATS JetStream |
| DB | Postgres (with `pgx`) |
| Object storage | S3-compatible |
| Logging | `slog` structured |
| Metrics | Prometheus |
| Tracing | OpenTelemetry |
| Container | Docker; Kubernetes/EKS in prod |
| IaC | Terraform |

See `backend/CONVENTIONS.md` for project layout and code-style rules.

## MVP scope (Phase 0)

- Gateway (REST + WSS)
- Session manager
- ASR orchestrator with AWS Transcribe Medical only
- Extraction worker with Claude (via Bedrock) only
- Chart writer (PACU fields only — vitals, meds, dispo)
- Audit service
- Single AWS region, single pilot ASC
- No failover, no edge inference, no caching layer beyond Postgres + NATS

Mock external dependencies during local dev — use `dev/mock-echart` and `dev/mock-asr`.

## Open questions

- Extraction worker in Go or Python? — Default Go for stack consistency. Switch only if a Python-only library proves required (e.g., specialized medical NER).
- NATS vs Kafka — NATS sufficient for MVP. Revisit at 10K msg/sec/tenant.
- HST eChart API contract — needs confirmation with the existing eChart team before locking the chart writer integration. Until then, use `dev/mock-echart` and a stable internal interface in `internal/echart/`.
