-- 0003_transcripts: ASR-finalized utterances.
--
-- One row per `is_final=true` transcript. Partial transcripts are streamed
-- on NATS but not persisted (they churn too fast to be useful for audit and
-- the canonical record is the final). The asr-orchestrator service owns
-- writes to this table; consumers (extraction worker, compliance review)
-- read by (session_id, ts).
--
-- audio_chunk_ids is the provenance trail back to the audio bytes in S3.
-- A final transcript may span multiple chunks; the array preserves order.
--
-- speaker is one of {nurse, patient, surgeon, anesthesia, unknown}. The
-- column is TEXT rather than an enum so adding labels (e.g. observer) is
-- a value-only change, not a schema migration.
--
-- PHI note: `text` is the verbatim utterance. The column is part of the
-- clinical record and persists per tenant retention policy; access is
-- gated by tenant role. No transcript text is ever logged or emitted to
-- metrics — see internal/obs.redactedKeys.

CREATE TABLE transcripts (
  id              UUID PRIMARY KEY,
  session_id      UUID NOT NULL,
  audio_chunk_ids UUID[] NOT NULL DEFAULT '{}',
  speaker         TEXT NOT NULL DEFAULT 'unknown',
  text            TEXT NOT NULL,
  is_final        BOOLEAN NOT NULL,
  start_ms        BIGINT NOT NULL,
  end_ms          BIGINT NOT NULL,
  ts              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_transcripts_session_ts ON transcripts (session_id, ts);
