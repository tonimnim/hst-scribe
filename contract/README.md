# contract/

Source of truth for the protocol between mobile and backend.

| File | Purpose |
|---|---|
| `CONTRACT.md` | Wire protocol — REST, WSS, event schema, auth, reconnection |
| `schemas/event-schema.json` | JSON Schema for extracted events (use to validate both sides) |
| `samples/utterances.md` | Eval set — 20+ sample utterances with expected extracted events |

## Workflow

1. Want to change a wire-level shape? Edit `CONTRACT.md` first.
2. Update `schemas/*.json` to match.
3. Add or update a sample utterance in `samples/utterances.md` if the change affects extraction.
4. Then update both `backend/` and `mobile/` in the same commit.

Never let an app diverge from this folder. Drift kills the project.
