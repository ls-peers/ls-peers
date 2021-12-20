-- Delete all data from all the tables. Keep this order
DELETE FROM users_preferences;
DELETE FROM preferences;
DELETE FROM users;
DELETE FROM courses;
DELETE FROM tracks;
DELETE FROM timezones;

-- Delete all tables from database
DROP TABLE users_preferences;
DROP TABLE preferences;
DROP TABLE users;
DROP TABLE courses;
DROP TABLE tracks;
DROP TABLE timezones;
