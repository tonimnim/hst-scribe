# HST Scribe — Wire Contract

**Single source of truth for the protocol between `mobile/` and `backend/`.**
Any change here is made BEFORE either app changes. Bump version on breaking changes.

- **Current version:** `v1` (sent on `session_started`)
- **Style:** snake_case JSON, RFC3339 timestamps with timezone, UUIDv7 IDs (server-generated).
- **Error envelope (everywhere):** `{ "code": "...", "message": "...", "details": {...} }`

---

## 1. REST API

Base path: `/api/v1`
Auth: `Authorization: Bearer <jwt>` on every request.

### `POST /sessions`
Create a session and lock to a patient.

**Request**
```json
{
  "patient_id": "01931d7e-...-uuid7",
  "workflow_type": "pacu",
  "asc_id": "01931d7e-...-uuid7"
}
```

`workflow_type` ∈ `pacu | preop | intraop` (MVP supports `pacu` only).

**Response `201`**
```json
{
  "session_id": "01931d80-...-uuid7",
  "wss_url": "wss://api.hst-scribe.example/api/v1/sessions/01931d80-.../stream",
  "patient_context": {
    "patient_id": "01931d7e-...",
    "display_name_initials": "J.D.",
    "mrn_last4": "4821",
    "procedure": "Right knee arthroscopy",
    "current_medications": [
      { "rxnorm_code": "26225", "name": "Ondansetron", "dose": "4 mg", "route": "iv" }
    ],
    "allergies": [{ "name": "Penicillin", "severity": "severe" }],
    "comorbidities": ["diabetes_type_2"]
  },
  "started_at": "2026-05-11T14:30:00-04:00",
  "expires_at": "2026-05-11T15:00:00-04:00"
}
```

`display_name_initials` and `mrn_last4` are the only patient identifiers ever shown in app logs. Full name/MRN stays server-side.

Idempotent: if an active session for `(asc_id, patient_id, user_id)` exists, returns it.

### `PATCH /sessions/{id}/events/{event_id}`
Edit fields on a draft event.

**Request**
```json
{ "fields": { "dose_value": 8 } }
```

**Response `200`**
```json
{ "event_id": "...", "status": "draft_edited", "fields": { ...full event... } }
```

### `POST /sessions/{id}/events/{event_id}/confirm`
Promote a draft event to a chart-write candidate.

**Response `200`**
```json
{ "event_id": "...", "status": "confirmed" }
```

### `POST /sessions/{id}/events/{event_id}/reject`
Reject a draft event. Does not write to chart.

**Response `200`**
```json
{ "event_id": "...", "status": "rejected" }
```

### `POST /sessions/{id}/sign`
Sign the session. All `confirmed` events are written to eChart as final entries.

**Request**
```json
{ "auth_method": "biometric", "auth_token": "..." }
```

`auth_method` ∈ `biometric | pin`.

**Response `200`**
```json
{
  "session_id": "...",
  "status": "signed",
  "signed_at": "2026-05-11T14:58:12-04:00",
  "events_written": 14,
  "events_rejected": 2
}
```

### `GET /sessions/{id}`
Session summary including all events and current statuses.

### `POST /auth/refresh`
Standard OAuth2 refresh-token exchange. Returns a new access token.

---

## 2. WebSocket Protocol

**URL:** `wss://{host}/api/v1/sessions/{session_id}/stream`
**Auth:** `Authorization: Bearer <jwt>` header on upgrade.

### Envelope (every message, both directions)

```json
{
  "type": "...",
  "session_id": "01931d80-...",
  "seq": 42,
  "ts": "2026-05-11T14:32:18.123-04:00",
  "payload": { ... }
}
```

- `seq` is monotonic per direction. Client and server keep independent counters.
- `ts` is the sender's timestamp.

### Client → Server messages

| `type` | Purpose |
|---|---|
| `audio_chunk` | Stream audio bytes |
| `session_pause` | Pause capture (server stops ASR billing) |
| `session_resume` | Resume capture |
| `session_end` | Graceful end (server waits for last extractions, then closes) |
| `voice_command` | Nurse spoke "confirm last" / "strike that" / etc. |
| `ping` | Keepalive |

**`audio_chunk` payload**
```json
{
  "chunk_id": "01931d81-...-uuid7",
  "audio_b64": "<base64 of 250ms 16kHz mono PCM16>",
  "sample_rate": 16000,
  "format": "pcm16",
  "duration_ms": 250
}
```

**`voice_command` payload**
```json
{ "command": "confirm_last" }
```
Commands ∈ `confirm_last | strike_last | pause | resume | end_session`.

### Server → Client messages

| `type` | Purpose |
|---|---|
| `session_started` | First message; includes protocol version and patient context snapshot |
| `transcript_partial` | In-flight ASR text (not yet final) |
| `transcript_final` | ASR-finalized utterance segment |
| `event_extracted` | New draft event from extractor |
| `event_ack` | Server ack of a client-initiated action (confirm/reject/edit) |
| `session_ended` | Server confirms session close |
| `error` | Error envelope |
| `pong` | Keepalive response |

**`session_started` payload**
```json
{
  "protocol_version": "v1",
  "patient_context": { ...same shape as REST response... },
  "server_capabilities": { "voice_commands": true, "diarization": true }
}
```

**`transcript_partial` payload**
```json
{
  "text": "BP one thirty over",
  "speaker": "nurse",
  "start_ms": 1450,
  "end_ms": 2100
}
```

**`transcript_final` payload**
```json
{
  "transcript_id": "01931d82-...-uuid7",
  "text": "BP one thirty over eighty two",
  "speaker": "nurse",
  "start_ms": 1450,
  "end_ms": 2680,
  "audio_chunk_ids": ["01931d81-..."]
}
```

`speaker` ∈ `nurse | patient | surgeon | anesthesia | unknown`.

**`event_extracted` payload**
```json
{
  "event_id": "01931d83-...-uuid7",
  "event_type": "vital_sign",
  "fields": {
    "vital_type": "blood_pressure_systolic",
    "value": 130,
    "unit": "mmHg"
  },
  "confidence": 0.94,
  "source_transcript_ids": ["01931d82-..."],
  "source_utterance": "BP one thirty over eighty two",
  "extracted_at": "2026-05-11T14:32:19.502-04:00"
}
```

**`event_ack` payload**
```json
{ "event_id": "...", "status": "confirmed" }
```
`status` ∈ `confirmed | rejected | draft_edited`.

**`session_ended` payload**
```json
{
  "reason": "client_requested",
  "final_seq": 4173
}
```
Both fields optional. `reason` ∈ `client_requested | inactivity_timeout | server_shutdown | error` (free-form string allowed for future codes). `final_seq` is the last server-emitted `seq` the client should expect; useful for reconcile-on-reconnect to confirm no messages were dropped.

### Error codes

| `code` | Meaning |
|---|---|
| `auth_invalid` | Bearer token missing/expired/invalid |
| `auth_forbidden` | Token valid but lacks scope for this resource |
| `session_not_found` | No such session_id |
| `session_expired` | Session is past `expires_at` or already signed |
| `patient_locked` | Another active session has this patient |
| `audio_format_unsupported` | Bad sample rate, codec, etc. |
| `chunk_out_of_order` | `seq` regression |
| `rate_limited` | Tenant or session rate limit exceeded |
| `extractor_failed` | Downstream extraction error (recoverable) |
| `internal` | Anything else |

---

## 3. Extracted Event Schema

Schema the LLM extractor produces via function calling. JSON Schemas live next to this file in `schemas/`.

### Common fields (every event)

| Field | Type | Notes |
|---|---|---|
| `event_id` | UUIDv7 | server-generated |
| `event_type` | enum | see below |
| `fields` | object | shape varies by `event_type` |
| `confidence` | number 0–1 | extractor confidence |
| `source_utterance` | string | verbatim from transcript |
| `source_transcript_ids` | UUIDv7[] | provenance |
| `extracted_at` | RFC3339 | server time |
| `event_time` | RFC3339 | clinical time (may differ from `extracted_at`) |

### `vital_sign`
```json
{
  "vital_type": "blood_pressure_systolic",
  "value": 130,
  "unit": "mmHg"
}
```
`vital_type` ∈ `blood_pressure_systolic | blood_pressure_diastolic | heart_rate | spo2 | respiratory_rate | temperature_c | temperature_f | pain_score`.
Pain score 0–10 integer.

### `medication_administered`
```json
{
  "medication_name": "Ondansetron",
  "rxnorm_code": "26225",
  "dose_value": 4,
  "dose_unit": "mg",
  "route": "iv",
  "indication": "nausea"
}
```
`route` ∈ `iv | im | po | sublingual | topical | inhaled | intranasal | rectal | subcutaneous`.
`dose_unit` ∈ `mg | mcg | g | ml | unit`.
Extractor MUST resolve `rxnorm_code`; if unresolved, event is flagged `needs_review` with `confidence` capped at `0.5`.

### `dispo` (disposition)
```json
{
  "disposition_type": "discharge_home",
  "discharge_criteria_met": true,
  "notes": "Tolerating PO fluids, pain 2/10, ambulating."
}
```
`disposition_type` ∈ `discharge_home | transfer_to_hospital | admit_observation | transfer_to_floor`.

### `note`
Free-text fallback when nothing structured matches.
```json
{
  "note_text": "Patient reports mild itching at IV site, no rash.",
  "tags": ["iv_site", "skin"]
}
```

---

## 4. Auth Flow

1. Mobile starts OAuth2 + PKCE against HST IdP.
2. Receives `access_token` (JWT, ~15 min) and `refresh_token` (long-lived, secure-storage only).
3. Access token claims: `sub` (user_id), `asc_id`, `role`, `exp`.
4. All REST calls and WSS upgrade carry `Authorization: Bearer <access_token>`.
5. On 401, mobile calls `POST /auth/refresh` and retries once.
6. Tokens live only in iOS Keychain / Android Keystore. Never in shared preferences, never in logs.

---

## 5. Idempotency & Reconnection

- `audio_chunk` carries `chunk_id`; backend dedupes within a session.
- Mobile keeps a rolling 30-second local audio buffer.
- On WSS disconnect, mobile reconnects to the same URL and includes `?last_seq=<n>` in the upgrade query.
- Server replays unacked server→client messages from `last_seq+1` (retained 5 minutes).
- Mobile resends any unacked client→server `audio_chunk`s from the local buffer.
- After 5 minutes of disconnection, the session enters `paused` state and must be explicitly resumed.

---

## 6. Versioning Policy

- **Additive change** (new optional field, new message type): minor bump `v1.1`. No client change required.
- **Breaking change** (removed/renamed field, changed semantics): major bump `v2`. Both apps update in lockstep; server supports both versions during rollout window.
- Server advertises supported versions on `session_started`. Mobile compares and refuses to start if unsupported.

---

## 7. Out of scope for `v1`

- Multi-patient ambient capture (one patient per session, hard locked).
- Real-time decision support / alerts (separate channel, future).
- Chart write-back to non-HST EHRs.
- Offline-first capture (only short reconnection buffer).
