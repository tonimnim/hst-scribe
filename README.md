# HST Scribe

Ambient AI scribing for Ambulatory Surgery Center nurses. Voice in, structured chart events out, nurse reviews and signs.

## Quick start

```powershell
# Local dev environment (Postgres + NATS + mocks)
cd dev
docker compose up -d

# Backend (after scaffolding)
cd ..\backend
make run

# Mobile (after scaffolding)
cd ..\mobile
flutter run -d <device>
```

## Repos

| Folder | What | Owner doc |
|---|---|---|
| `contract/` | Wire protocol, JSON schemas, eval set | `contract/CONTRACT.md` |
| `backend/` | Go services | `backend/PRD.md` |
| `mobile/` | Flutter app | `mobile/PRD.md` |
| `dev/` | Mock services and seed data | `dev/README.md` |

See `CLAUDE.md` at the root for project-wide conventions.

## Status

Greenfield. Phase 0 (MVP) targets the PACU workflow on iPad with push-to-talk.
