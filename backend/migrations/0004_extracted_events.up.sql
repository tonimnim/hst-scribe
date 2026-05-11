-- 0004_extracted_events.up.sql
-- Owned by: extraction-worker
-- Stores the structured chart events the LLM extractor produces from
-- final transcripts. status drives the chart-writer state machine.

CREATE TYPE event_status AS ENUM ('draft','confirmed','rejected','signed','edited');

CREATE TABLE extracted_events (
    id                    UUID PRIMARY KEY,
    session_id            UUID NOT NULL,
    event_type            TEXT NOT NULL,
    fields                JSONB NOT NULL DEFAULT '{}'::jsonb,
    confidence            REAL NOT NULL,
    source_transcript_ids UUID[] NOT NULL DEFAULT '{}',
    source_utterance      TEXT NOT NULL,
    status                event_status NOT NULL DEFAULT 'draft',
    needs_review          BOOLEAN NOT NULL DEFAULT FALSE,
    extracted_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    event_time            TIMESTAMPTZ
);

CREATE INDEX idx_events_session_ts ON extracted_events (session_id, extracted_at);
CREATE INDEX idx_events_status     ON extracted_events (status) WHERE status IN ('draft','confirmed');
