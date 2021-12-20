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
  code varchar(5) NOT NULL,          -- e.g EST, CET, MIT,
  name text,                         -- e.g Eastern Standard Time, Central European Time, Marquesas Islands Time
  gmtoffset numeric(4,2) NOT NULL          -- e.g -5, 1, -9.50
);


CREATE TABLE users (
  id serial, -- change datatype from serial to: uuid DEFAULT uuid_generate_v4 ()
  firstname varchar(25) NOT NULL CHECK (LENGTH(TRIM(BOTH ' ' FROM firstname)) > 0), -- should we use the checks in the form instead of here?
  lastname varchar(25),
  slackname varchar(25) NOT NULL,
  email varchar(255) NOT NULL,
  password char(60) NOT NULL, -- it seems that BCrypt always generates 60 character hashes
  course_id integer NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  track_id integer NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
  timezone_id integer NOT NULL REFERENCES timezones(id) ON DELETE CASCADE,
  about_me text,
  last_active timestamp,
  created_at timestamp NOT NULL DEFAULT NOW(),
  updated_at timestamp,
  PRIMARY KEY (id)
);

CREATE TABLE preferences (
  id serial PRIMARY KEY,
  preference varchar(255),                   -- e.g 'Preparing for interview assessment', 'Reviewing concepts', etc
  category varchar(150)                      -- e.g 'Study', 'Project', 'Assessment', etc
);

CREATE TABLE users_preferences (
  id serial PRIMARY KEY,
  user_id integer NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- change datatype from integer to uuid
  preference_id integer NOT NULL REFERENCES preferences(id) ON DELETE CASCADE
);
