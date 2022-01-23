CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE courses (
  id serial PRIMARY KEY,
  code varchar(5) NOT NULL,
  name text
);

CREATE TABLE tracks (
  id serial PRIMARY KEY,
  code varchar(2) NOT NULL,
  name text
);

CREATE TABLE timezones (
  id serial PRIMARY KEY,
  code varchar(5) NOT NULL,
  name text,
  gmtoffset numeric(4,2)                                                                  -- Not in use for now
);

CREATE TABLE users (
  id uuid DEFAULT uuid_generate_v4 () PRIMARY KEY,
  email varchar(255) NOT NULL,
  password char(60) NOT NULL,                                                             -- it seems that BCrypt always generates 60 character hashes
  full_name varchar(25) NOT NULL,
  preferred_name varchar(25),
  slack_name varchar(25),
  track_id integer REFERENCES tracks(id) ON DELETE CASCADE,
  course_id integer REFERENCES courses(id) ON DELETE CASCADE,
  timezone_id integer REFERENCES timezones(id) ON DELETE CASCADE,
  about_me text,
  last_active timestamp,
  created_at timestamp NOT NULL DEFAULT NOW(),
  updated_at timestamp
);

CREATE TABLE preferences (
  id serial PRIMARY KEY,
  preference varchar(255),
  category varchar(150)
);

CREATE TABLE users_preferences (
  id serial PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  preference_id integer NOT NULL REFERENCES preferences(id) ON DELETE CASCADE
);
