-- HST Scribe — local dev Postgres bootstrap.
-- Real schema lives in backend/migrations/. This file only creates the dev DB
-- and enables extensions so the backend's migrations can run cleanly.

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tenant schemas are created on demand by the backend; nothing to seed here.
-- Seed data for patients is served by dev/mock-echart, not by Postgres.
