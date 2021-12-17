-- Delete all data from all the tables. Keep this order
DELETE FROM users_needs;
DELETE FROM needs;
DELETE FROM users;
DELETE FROM courses;
DELETE FROM tracks;
DELETE FROM timezones;

-- Delete all tables from database
DROP TABLE users_needs;
DROP TABLE needs;
DROP TABLE users;
DROP TABLE courses;
DROP TABLE tracks;
DROP TABLE timezones;
