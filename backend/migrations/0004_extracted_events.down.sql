-- 0004_extracted_events.down.sql

DROP INDEX IF EXISTS idx_events_status;
DROP INDEX IF EXISTS idx_events_session_ts;
DROP TABLE IF EXISTS extracted_events;
DROP TYPE  IF EXISTS event_status;
