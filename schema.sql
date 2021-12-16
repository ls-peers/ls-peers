CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
  pkey UUID NOT NULL DEFAULT uuid_generate_v1(),
  firstname text NOT NULL CHECK (LENGTH(TRIM(FROM firstname)) > 0),
  lastname text,
  -- TODO: ADD REMAINING COLUMNS
  created_at timestamp DEFAULT NOW()
);

-- TODO: ADD REMAINING TABLES
