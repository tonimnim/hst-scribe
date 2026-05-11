-- 0006_audit_log: append-only audit log.
--
-- Tamper-evidence rests on three things:
--   1. No UPDATE or DELETE statements anywhere in the application code (audit
--      service issues INSERT ... ON CONFLICT (id) DO NOTHING only).
--   2. The service role's grants are revoked from UPDATE/DELETE on this table
--      at deploy time (see deploy/sql/grants.sql — Phase B operator step).
--   3. UUIDv7 ids are produced by the publisher, so dedupe is idempotent and
--      replay never overwrites earlier rows.
--
-- Indices target the three compliance queries we support:
--   - all events for a session (idx_audit_session)
--   - everything an actor did in a window (idx_audit_user_ts)
--   - tenant-wide review by an ASC compliance officer (idx_audit_asc_ts)

CREATE TABLE audit_log (
    id            UUID PRIMARY KEY,
    session_id    UUID,
    actor_user_id UUID,
    asc_id        UUID NOT NULL,
    action        TEXT NOT NULL,
    target_id     UUID,
    target_type   TEXT,
    payload       JSONB NOT NULL DEFAULT '{}'::jsonb,
    ts            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_session ON audit_log (session_id, ts);
CREATE INDEX idx_audit_user_ts ON audit_log (actor_user_id, ts);
CREATE INDEX idx_audit_asc_ts  ON audit_log (asc_id, ts);

-- Tamper-evidence: revoke UPDATE/DELETE for the service role at deploy time.
