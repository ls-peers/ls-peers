CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE courses (
  course_id serial PRIMARY KEY,
  course_code varchar(5) NOT NULL,
  course_name text
);

CREATE TABLE tracks (
  track_id serial PRIMARY KEY,
  track_code varchar(2) NOT NULL,
  track_name text
);

CREATE TABLE timezones (
  tzone_id serial PRIMARY KEY,
  tzone_code varchar(5) NOT NULL,          -- e.g EST, CET, MIT,
  tzone_name text,                         -- e.g Eastern Standard Time, Central European Time, Marquesas Islands Time
  gmtoffset numeric(4,2) NOT NULL          -- e.g -5, 1, -9.50
);


CREATE TABLE users (
  user_id serial, -- change datatype from serial to uuid DEFAULT uuid_generate_v4 ()
  firstname text NOT NULL CHECK (LENGTH(TRIM(BOTH ' ' FROM firstname)) > 0), -- should we use the checks in the form instead of here?
  lastname text,
  slackname text NOT NULL,
  email varchar(255) NOT NULL,
  password text NOT NULL,
  course_id integer NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
  track_id integer NOT NULL REFERENCES tracks(track_id) ON DELETE CASCADE,
  timezone_id integer NOT NULL REFERENCES timezones(tzone_id) ON DELETE CASCADE,
  about_me text,
  last_active timestamp,
  created_at timestamp NOT NULL DEFAULT NOW(),
  updated_at timestamp,
  PRIMARY KEY (user_id)
);

CREATE TABLE needs (
  need_id serial PRIMARY KEY,
  need text,                         -- e.g 'Preparing for interview assessment', 'Reviewing concepts', etc
  class text                         -- e.g 'Study', 'Project', 'Assessment', etc
);

CREATE TABLE users_needs (
  id serial PRIMARY KEY,
  user_id integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE, -- change datatype from integer to uuid
  need_id integer NOT NULL REFERENCES needs(need_id) ON DELETE CASCADE
);
