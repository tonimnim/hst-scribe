-- 0005_chart_writes: chart-writer persistence + idempotent draft/promote tracking.
--
-- The chart-writer service subscribes to extracted.confirmed.> and chart.sign.>
-- on NATS and translates each confirmed event into an HST eChart draft POST,
-- then atomically promotes drafts on session sign. This table is the local
-- ledger that powers idempotency and retry:
--
--   * `event_id` is UNIQUE — the same confirmed event re-delivered by NATS
--     never produces a duplicate POST to eChart.
--   * `status` walks pending -> written -> promoted on the happy path. Failed
--     writes land in 'failed' after retry exhaustion and feed the DLQ replay
--     job; rejections land in 'rejected' without any eChart call.
--   * `echart_entry_id` is populated on the successful draft POST and reused
--     by the sign-session call's event_ids array.
--   * `attempts` and `last_error` exist so operators can triage stuck rows
--     without grepping logs. `last_error` carries upstream HTTP detail, never
--     source_utterance / patient identifiers (chart-writer scrubs at the
--     boundary via internal/obs).

CREATE TYPE chart_write_status AS ENUM ('pending','written','failed','promoted','rejected');

CREATE TABLE chart_writes (
    id               UUID PRIMARY KEY,
    session_id       UUID NOT NULL,
    event_id         UUID NOT NULL UNIQUE,
    patient_id       UUID NOT NULL,
    echart_entry_id  UUID,
    status           chart_write_status NOT NULL DEFAULT 'pending',
    attempts         INT NOT NULL DEFAULT 0,
    last_error       TEXT,
    written_at       TIMESTAMPTZ,
    promoted_at      TIMESTAMPTZ
);

-- Session sign loads every 'written' row for a session in one query, so a
-- (session_id) index is the hot path. Status is included via the partial
-- index below for the operational "what's stuck?" lookup.
CREATE INDEX idx_chart_writes_session ON chart_writes (session_id);

-- Operational triage: which writes still need attention?
CREATE INDEX idx_chart_writes_status  ON chart_writes (status)
    WHERE status IN ('pending','failed');
