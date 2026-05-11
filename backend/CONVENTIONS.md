# backend/ Conventions

## Project layout

```
backend/
├── cmd/
│   ├── gateway/           # main.go for gateway service
│   ├── session-manager/
│   ├── asr-orchestrator/
│   ├── extraction-worker/
│   ├── chart-writer/
│   └── audit/
├── internal/
│   ├── auth/              # JWT validation, OAuth2 refresh
│   ├── contract/          # generated structs matching contract/ JSON shapes
│   ├── wss/               # WebSocket envelope, seq, reconnection
│   ├── nats/              # broker helpers
│   ├── pg/                # Postgres helpers (pgx wrappers)
│   ├── obs/               # logging, metrics, tracing
│   ├── audit/             # audit emitters
│   ├── echart/            # HST eChart client (uses mock in dev)
│   ├── asr/               # ASR provider abstraction (Transcribe, Deepgram impls)
│   ├── llm/               # LLM provider abstraction (Bedrock-Claude impl)
│   ├── vocab/             # RxNorm / SNOMED / LOINC validators
│   ├── session/           # session lifecycle, patient lock
│   └── extract/           # prompt assembly, dedup, confidence scoring
├── pkg/                   # only for things meant to be importable externally (rare)
├── deploy/                # Dockerfiles, k8s manifests
├── migrations/            # SQL migrations (numbered)
├── Makefile
├── go.mod
└── go.sum
```

- `cmd/<service>/main.go` is the thin entrypoint. All logic lives in `internal/`.
- Service-specific code that won't be shared lives in `internal/<service>/`.

## Code style

- Run `gofmt` and `golangci-lint` on every commit (pre-commit hook).
- Errors: wrap with `fmt.Errorf("doing X: %w", err)`. Sentinel errors only for cross-package signaling.
- Context: every public function that does I/O takes `ctx context.Context` as the first arg.
- Logging: `slog` only, structured KV. Never log PHI fields. Use field IDs (`session_id`, `event_id`) instead.
- Config: env vars. No flag parsing for runtime config. `internal/config` reads everything at startup; pass `config.Config` to constructors.
- JSON: tags in snake_case to match the wire. Generate via `internal/contract` and treat as authoritative.

## Testing

- Table tests for pure logic.
- Integration tests at the WSS and REST boundaries — spin up the gateway against a real Postgres + NATS via `dev/docker-compose.yml`.
- Contract tests: validate every produced JSON message against `contract/schemas/*.json`.
- Eval tests: run the extraction worker against `contract/samples/utterances.md`; CI fails on regression.

## Concurrency rules

- One goroutine per session per stage. Channels for fan-out.
- Hard deadlines on every outbound call. Default: 5s for non-AI, 30s for ASR/LLM.
- Graceful shutdown: services drain in-flight sessions for up to 60s on SIGTERM.

## Migrations

- `migrations/` numbered `0001_xxx.up.sql` / `0001_xxx.down.sql`.
- Apply via `make migrate-up`. Idempotent.
- Never edit a merged migration; add a new one.

## "Done" for a backend feature

1. Code compiles with `make build`.
2. `make lint` clean.
3. Table or integration test covers the happy path and at least one failure mode.
4. If it changes the wire: `contract/` updated in the same commit.
5. If it touches PHI: explicit log scrubbing review.
6. If it adds a new service-to-service call: timeout, retry, and observability added.
