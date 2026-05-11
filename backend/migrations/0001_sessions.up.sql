-- 0001_sessions: session lifecycle persistence + patient lock.
--
-- Notes:
--   * Patient lock is enforced at the database level via a UNIQUE partial
--     index covering only sessions in non-terminal states (active|paused).
--     This is the second of two defenses; the session-manager service does
--     a transactional pre-check, but races at the application layer would
--     still surface here as a unique-violation (SQLSTATE 23505).
--   * UUIDv7 ids are minted by the application — Postgres-side gen is not
--     used, so we deliberately do not DEFAULT id from a uuid extension.
--   * `last_activity_at` is updated by the gateway on each audio chunk
--     arrival (Wave 2 wires this). The inactivity-expiry worker reads it
--     to decide which sessions to mark expired.
--   * `expires_at` is the absolute upper bound — defense in depth against
--     long-lived runaway sessions. Set at session create by the service.

CREATE TYPE session_status AS ENUM ('active', 'paused', 'ended', 'signed', 'expired');
CREATE TYPE workflow_type  AS ENUM ('pacu', 'preop', 'intraop');

CREATE TABLE sessions (
    id                  UUID PRIMARY KEY,
    asc_id              UUID NOT NULL,
    patient_id          UUID NOT NULL,
    user_id             UUID NOT NULL,
    workflow_type       workflow_type NOT NULL,
    status              session_status NOT NULL DEFAULT 'active',
    reason              TEXT,
    started_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_activity_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at            TIMESTAMPTZ,
    signed_at           TIMESTAMPTZ,
    expires_at          TIMESTAMPTZ NOT NULL,
    signed_by_user_id   UUID
);

-- Patient lock: at most one non-terminal session per (asc_id, patient_id).
-- Terminal states (ended|signed|expired) drop out of the index so a new
-- session can be created once the previous one wraps up.
CREATE UNIQUE INDEX idx_session_patient_active
    ON sessions (asc_id, patient_id)
    WHERE status IN ('active', 'paused');

-- User session history lookup (compliance + "my sessions today").
CREATE INDEX idx_session_user_ts
    ON sessions (user_id, started_at DESC);

-- Expiry sweep target: bounded scan over non-terminal sessions only.
CREATE INDEX idx_session_expiry
    ON sessions (expires_at)
    WHERE status IN ('active', 'paused');
