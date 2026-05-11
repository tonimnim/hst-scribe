# HST Scribe

AI scribing for ASC (Ambulatory Surgery Center) nurses. Nurses speak naturally during pre-op / PACU / intra-op; an AI listens, extracts structured chart events, and writes them as drafts into HST eChart for nurse review and sign-off.

## Layout

- `contract/` — shared protocol, schemas, eval set. **SOURCE OF TRUTH.** Any wire change updates here first.
- `backend/` — Go services. See `backend/PRD.md`, `backend/CONVENTIONS.md`, and **`backend/AGENTS.md`** (senior-eng rules — read before coding).
- `mobile/` — Flutter app (iPad-first, phone-capable). See `mobile/PRD.md`, `mobile/CONVENTIONS.md`, and **`mobile/AGENTS.md`** (senior-eng rules — read before coding).
- `dev/` — mock eChart, mock ASR, seed data, docker-compose for local dev. See `dev/README.md`.

## Rules (apply to every session)

- **Contract first.** Any change to a WSS message, REST endpoint, or extracted-event schema updates `contract/CONTRACT.md` BEFORE either app changes.
- **Wire format:** snake_case JSON fields. RFC3339 timestamps with timezone (never naive). UUIDv7 IDs, server-generated.
- **Error shape (everywhere):** `{ "code": "...", "message": "...", "details": {...} }`.
- **No PHI in logs, metrics, traces, crash reports, or analytics.** ID references only. This is the catastrophic-failure guardrail.
- **Patient context is locked at session start.** Audio capture is impossible without a confirmed patient ID. Never infer patient identity from audio content.
- **Nurse owns the chart.** AI produces drafts. Confirmed events are promoted on sign. Audit every step.
- **Confidence is mandatory.** Every extracted field carries a confidence score. UI surfaces it. Low-confidence events are flagged, never auto-confirmed.

## Pre-decided stack

| Concern | Choice |
|---|---|
| Mobile framework | Flutter (Dart) |
| Mobile state | Riverpod |
| Backend language | Go 1.22+ |
| HTTP router | chi |
| WebSocket lib | nhooyr.io/websocket |
| Broker | NATS JetStream |
| Database | Postgres |
| Object storage | S3-compatible (audio bytes) |
| ASR (MVP) | AWS Transcribe Medical |
| LLM (MVP) | Claude via AWS Bedrock |
| Auth | OAuth2 + PKCE, JWT bearer |
| Logging | slog (Go), structured |
| Config | env vars |
| Container orchestration | Docker Compose (dev), Kubernetes/EKS (prod) |

## Phases

- **Phase 0 (MVP):** PACU workflow only. Push-to-talk only. iPad only. Vitals + meds + dispo. 1 pilot ASC. Mock eChart and mock ASR for local dev; real AWS services for pilot.
- **Phase 1:** Pre-op workflow. Ambient capture. Bluetooth wearable mic option. 10–20 pilot sites. BAA/HITRUST audit extensions. Begin building consented audio corpus.
- **Phase 2:** Intra-op (OR). Custom fine-tuned ASR + extraction. Edge inference. GA across all HST ASCs.
- **Phase 3:** Closed-loop intelligence — scribe data feeds case duration prediction, auto-coding, decision support.

## Working agreements with Claude Code

- Commit per coherent feature, not per session. Small, reversible commits.
- Read auth, encryption, audit logging, and anything touching PHI before accepting.
- Test the seams (WSS boundary, REST boundary, contract conformance). Don't waste cycles on internal unit tests that won't catch contract drift.
- Use mocks in `dev/` for everything you don't own yet (eChart, ASR in offline mode).
- If you change the contract, the commit must include `contract/` + both apps in one logical change.
