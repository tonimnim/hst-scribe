# Go — Senior Engineering Rules

Read these BEFORE writing code: `CLAUDE.md` (root) → `backend/PRD.md` → `backend/CONVENTIONS.md` → this file.

Goal: code a senior Go engineer would merge without asking for a rewrite. Not "Tour of Go" Go. Production Go for a clinical platform.

---

## Hard rules

### Errors
- **Always check.** Never `_ = err`. Never silently swallow.
- Wrap with context: `fmt.Errorf("creating session %s: %w", id, err)`. Lowercase first letter, no trailing punctuation.
- Sentinel errors (`var ErrFoo = errors.New("foo")`) only for cross-package signaling. Otherwise wrapped errors.
- Define typed errors when callers need to discriminate beyond `errors.Is` / `errors.As`.
- **Don't log AND return.** Pick one. Returning is almost always right; logging happens at the top of a request handler.

### Context
- Every I/O or blocking function takes `ctx context.Context` as the first arg.
- Never store `ctx` in a struct.
- Hard deadlines on every external call: 5s for fast services, 30s for ASR / LLM.
- `ctx.Err()` check before expensive work inside a long-running loop.

### Logging
- `slog` only. Structured key-value. Never `fmt.Sprintf` into the message.
- **Never log PHI.** No transcript text, no `patient_name`, no DOB, no MRN. Field IDs only (`session_id`, `event_id`, `patient_id`).
- Logger passed via context or constructor — never a package-level singleton.
- Levels: `Debug` for verbose, `Info` for lifecycle, `Warn` for recoverable, `Error` for human-required failures.

### Concurrency
- Every goroutine has a clear exit path — deadline, cancellation, or completion. No `go func()` without thinking about cleanup.
- Channels for hand-off, `sync.Mutex` / `RWMutex` for state protection. Don't mix metaphors.
- `errgroup.Group` with `ctx` for parallel fan-out where any error cancels the rest.
- `sync.WaitGroup` for fire-and-wait. Verify all goroutines exit on shutdown.
- **No naked `panic`** in library code. `main()` may panic on init failure; nothing else should.
- `recover` only at well-defined boundaries (HTTP middleware, worker entry).

### Interfaces
- Small (1–3 methods). Defined at the **consumer** side, not the producer.
- "Accept interfaces, return structs."
- No `interface{}` / `any` unless the type is genuinely unknown at a boundary (JSON decode). Convert ASAP.
- Name by behavior: `Reader`, `SessionStore`, `EventPublisher`. No `I` prefix, no `Interface` suffix.

### Configuration & state
- All config from env vars at startup, validated into a typed `Config` struct. Passed to constructors.
- **No package-level mutable state.**
- No `init()` doing real work (only registering codecs / drivers).
- Singletons via DI, not via `var x = NewX()`.

### HTTP & WSS
- `chi` for HTTP. One router. Mounted middleware: request ID, structured logger, recoverer, auth.
- Handlers ≤ 30 lines. Real work in services, not handlers.
- Validate inputs at the handler boundary with a typed request struct. `DisallowUnknownFields` on the decoder.
- Standard error response: `{ code, message, details }`. Map error types → HTTP codes in one place (`internal/httperr`).
- WSS: `nhooyr.io/websocket`. Honor `ctx` for shutdown. Heartbeat with ping/pong. Reconnect resumes from `last_seq` per contract.

### Database
- `pgx` (v5+) — not `database/sql`. Parameterized queries only; **never** concatenate SQL.
- `pgxpool.Pool` created once at startup, passed via DI.
- Migrations numbered (`0001_xxx.up.sql` / `0001_xxx.down.sql`); never edited after merge.
- Hand-written queries with `pgx` until friction justifies `sqlc`. One style, not both.
- Multi-statement work in `pgx.Tx` with deferred `Rollback`. Explicit isolation when it matters.

### Testing
- Table-driven. `t.Run` subtests, `t.Parallel()` where safe.
- `t.Helper()` in helpers. `t.Cleanup()` over `defer` for teardown.
- Integration tests use the real Postgres + NATS from `dev/docker-compose`. No mocks for those.
- Mock only what you don't own (ASR provider, LLM provider) — through small, consumer-defined interfaces.
- Contract tests: every JSON message produced validates against `contract/schemas/*.json`.
- Eval tests: the extraction worker runs the `contract/samples/utterances.md` set in CI; regressions fail the build.

### Project hygiene
- `gofmt` + `goimports` + `golangci-lint` (strict config) on every commit.
- Public API has doc comments starting with the identifier name.
- Package names: short, lowercase, no underscores, no plurals (`session` not `sessions`).
- File names: `snake_case.go`.
- One responsibility per package. Two unrelated things → split.

### Observability
- Every request emits a structured log line: method, path, status, duration_ms, request_id, session_id when applicable.
- Prometheus metrics: RED (rate, errors, duration) on every external boundary.
- OpenTelemetry traces across service hops; propagate `ctx`.

---

## What "done" means

1. `make build` succeeds.
2. `make lint` is clean.
3. Tests added — happy path + one failure mode minimum.
4. If the wire changed: `contract/` updated in the same commit, generated types regenerated.
5. If PHI is touched: log scrubbing reviewed.
6. If a service-to-service call is added: timeout, retry, metric, trace span all wired.

---

## Anti-patterns — instant reject

- `panic` outside `main()`.
- Goroutine without an exit path.
- `context.Background()` inside a request flow (use the request's `ctx`).
- Channel without a chosen buffer size unless deliberate.
- `interface{}` / `any` as a glorified generic — use real generics.
- Package-level `var db *sql.DB` or similar globals.
- TODOs without a ticket reference or a "remove by" condition.
- `time.Sleep` as a synchronization mechanism.
- `recover` and continue silently outside the defined boundary.
- Log-and-return an error.
- Importing `internal/` from another module.
- Cyclic package dependencies.

---

## Pitfalls specific to HST Scribe

- **WSS dedupe** — `audio_chunk` carries `chunk_id`. Dedupe per session. Never write the same chunk twice.
- **Patient lock** — enforced at session manager BEFORE the ASR connection opens. Races here are catastrophic (cross-patient data).
- **Extraction dedupe** — overlapping transcript windows produce the same event twice. Dedupe by `(session_id, event_type, fields-semantic-match, time-window)`.
- **RxNorm validation** — hallucinated drug names must be flagged. If `rxnorm_code` is unresolved, cap confidence at 0.5 and mark `needs_review`. Never silently accept.
- **Idempotent session creation** — same `(asc_id, patient_id, user_id)` with an active session returns the existing session, never a duplicate.
- **Audio retention** — 30 days max. Auto-deletion job runs nightly; verify it in dev with a short TTL flag.
- **Sign-off semantics** — only `confirmed` events promote to final chart entries; drafts and rejects do not. The promote step is atomic per session.

---

## Module layout reminder (see CONVENTIONS.md for the full tree)

```
backend/
├── cmd/<service>/main.go     # thin entrypoint
├── internal/                 # shared packages, NOT importable outside this module
│   ├── contract/             # types matching contract/schemas
│   ├── auth/  obs/  pg/  nats/  audit/  echart/  asr/  llm/  vocab/
│   └── session/  extract/    # domain
├── migrations/               # numbered SQL
├── deploy/                   # Dockerfiles, k8s
└── Makefile
```

`cmd/<service>/main.go` is glue: read config → construct deps → start servers → wait for shutdown.

---

## Dependency baseline (pin in `go.mod`)

| Package | Why |
|---|---|
| `github.com/go-chi/chi/v5` | HTTP router |
| `nhooyr.io/websocket` | WSS |
| `github.com/jackc/pgx/v5` | Postgres |
| `github.com/nats-io/nats.go` + JetStream | broker |
| `log/slog` (stdlib) | logging |
| `github.com/prometheus/client_golang` | metrics |
| `go.opentelemetry.io/otel` | tracing |
| `github.com/google/uuid` (with UUIDv7 support) | IDs |
| `github.com/golang-jwt/jwt/v5` | JWT validation |
| `github.com/caarlos0/env/v11` | env config parsing |
| `github.com/stretchr/testify` | test assertions (limited use) |
| `github.com/aws/aws-sdk-go-v2/*` | Bedrock + Transcribe |

No package outside this list without written justification in the PR.

---

## Reading order for any task

1. `contract/CONTRACT.md` — what's on the wire?
2. `backend/PRD.md` — what service, what FRs?
3. This file + `CONVENTIONS.md` — how do we build it?
4. The closest existing service / internal package — what does precedent look like?

Then write code.
