# dev/

Local development environment. Run this before touching `backend/` or `mobile/`.

## What's here

| Folder / file | Purpose |
|---|---|
| `docker-compose.yml` | Postgres + NATS JetStream + mock services |
| `mock-echart/` | Fake HST eChart server (canned patient context, accepts draft events) — placeholder |
| `mock-asr/` | Fake ASR that replays canned transcripts from seed utterances — placeholder |
| `seed/patients.json` | 5 fake patients with realistic charts |
| `seed/utterances.json` | Canned audio→transcript mapping for offline iteration |

`mock-echart/` and `mock-asr/` are scaffolded later in their own Claude Code sessions. The compose file references them but they don't have to exist yet for Postgres + NATS to come up.

## Quick start

```powershell
cd dev
docker compose up -d postgres nats
docker compose ps
```

Postgres: `localhost:5432`, user `hst`, password `hst`, db `hst_scribe`.
NATS: `localhost:4222` (client), `localhost:8222` (monitoring UI).

Once the mock services exist:

```powershell
docker compose up -d
```

## Seed data

- All patient IDs are UUIDv7. All timestamps RFC3339 with timezone.
- Patient names are fictional. **Never replace with real PHI even for testing.**
- Utterances in `seed/utterances.json` mirror `contract/samples/utterances.md` and include base64-encoded synthetic audio (TTS-generated) for end-to-end mock playback.

## Resetting state

```powershell
docker compose down -v
docker compose up -d
```

`down -v` drops volumes. Postgres reseeds on next boot from `seed/*.sql`.

## Why mocks at all

We don't have HST eChart access yet. We don't want to burn AWS Transcribe Medical credits while iterating prompts. Mocks let both Claude Code sessions build end-to-end flows offline. Swap to real services per environment via env vars when ready.
