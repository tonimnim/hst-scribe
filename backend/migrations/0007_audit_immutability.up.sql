-- 0007_audit_immutability: Postgres-enforced tamper-evidence on audit_log.
--
-- 0006 documented append-only as a convention (revoke UPDATE/DELETE at
-- deploy time). 0007 promotes that convention into a hard guarantee:
-- triggers reject every UPDATE and DELETE at the row level, so even a
-- DB user with table-level UPDATE/DELETE privileges cannot mutate
-- existing rows. Application code keeps issuing the same
-- `INSERT ... ON CONFLICT (id) DO NOTHING` and is unaffected.
--
-- The migration is safe to apply over an existing audit_log table with
-- data:
--   * The function is CREATE OR REPLACE.
--   * The triggers fire only on UPDATE / DELETE, which the audit
--     service never issues; existing rows are untouched.
--   * The hash-chain columns are ADD COLUMN nullable; existing rows
--     stay NULL until the application backfills them or new inserts
--     populate them going forward.
--
-- Hash chain (optional, application-computed):
--   row_hash  = sha256(prev_hash || canonical_json(row_without_hashes))
--   prev_hash = the row_hash of the previous row by (asc_id, ts, id)
--
-- Tampering with a row breaks the chain at that row and every row
-- after it — even if the offender also disabled the triggers.

CREATE OR REPLACE FUNCTION audit_log_immutable()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'audit_log is append-only (rejected % on row %)',
        TG_OP, COALESCE(OLD.id::text, '<none>');
END;
$$;

DROP TRIGGER IF EXISTS audit_log_no_update ON audit_log;
CREATE TRIGGER audit_log_no_update
    BEFORE UPDATE ON audit_log
    FOR EACH ROW EXECUTE FUNCTION audit_log_immutable();

DROP TRIGGER IF EXISTS audit_log_no_delete ON audit_log;
CREATE TRIGGER audit_log_no_delete
    BEFORE DELETE ON audit_log
    FOR EACH ROW EXECUTE FUNCTION audit_log_immutable();

-- TRUNCATE is technically distinct from DELETE in Postgres; cover it
-- too so a privileged operator cannot wipe the table with one command.
DROP TRIGGER IF EXISTS audit_log_no_truncate ON audit_log;
CREATE TRIGGER audit_log_no_truncate
    BEFORE TRUNCATE ON audit_log
    FOR EACH STATEMENT EXECUTE FUNCTION audit_log_immutable();

-- Optional hash-chain columns. NULL on existing rows; the application
-- populates them on INSERT for new rows (see
-- internal/audit/repository.go::Append).
ALTER TABLE audit_log
    ADD COLUMN IF NOT EXISTS prev_hash BYTEA,
    ADD COLUMN IF NOT EXISTS row_hash  BYTEA;
