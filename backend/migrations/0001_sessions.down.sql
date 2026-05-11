-- 0001_sessions: tear-down. Reverse order: indexes -> table -> enum types.

DROP INDEX IF EXISTS idx_session_expiry;
DROP INDEX IF EXISTS idx_session_user_ts;
DROP INDEX IF EXISTS idx_session_patient_active;

DROP TABLE IF EXISTS sessions;

DROP TYPE IF EXISTS workflow_type;
DROP TYPE IF EXISTS session_status;
