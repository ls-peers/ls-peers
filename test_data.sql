-- Data insertion

INSERT INTO courses (code, name)
  VALUES ('RB185', 'Database applications'),
         ('JS230', 'DOM and Asynchronous Programming with JavaScript');

INSERT INTO tracks (code, name)
  VALUES ('RB', 'Ruby'),
         ('JS', 'Javascript');

INSERT INTO timezones (code, name, gmtoffset)
  VALUES ('EST', 'Eastern Standard Time', -5),
         ('CET', 'Central European Time', 1),
         ('PST', 'Pacific Standard Time', -8);

INSERT INTO users (firstname, lastname, slackname, email, password,
                   course_id, track_id, timezone_id, about_me)
  VALUES ('Scott', 'Graham', 'Scott', 'scttgrhm7@gmail.com', 'ldfgkj78%^&appdKO039*',
          2, 1, 3, 'Finishing LS and planning to do capstone in May. I like surfing and thick grey socks'),
         ('Alonso', 'Lobato', 'Alonso Lobato', 'alonzilj@gmail.com', 'ppdK78%^&aO039*ldfgkj',
          1, 1, 1, 'About to finish back-end portion of Ruby track. I like canadian Christmas trees');

INSERT INTO preferences (preference, category)
  VALUES ('Preparing for a written assessment', 'Assessment'),
         ('Preparing for an interview assessment', 'Assessment'),
         ('Reviewing concepts', 'Study'),
         ('Practicing problem solving', 'Problem solving'),
         ('Working on a project', 'Project');

INSERT INTO users_preferences(user_id, preference_id)
  VALUES ('1',5), -- user id is of type serial for development purposes, later it'll became  uuid
         ('1',4),
         ('2',2),
         ('2',4),
         ('2',5);

-- Querying Database

SELECT firstname, lastname, slackname, tracks.name, courses.code FROM users
  INNER JOIN courses ON courses.id = users.course_id
  INNER JOIN tracks ON tracks.id = users.track_id
  INNER JOIN users_preferences ON users_preferences.user_id = users.id
  INNER JOIN preferences  ON preferences.id = users_preferences.preference_id
  WHERE preferences.category = 'Problem solving'
  ORDER BY last_active DESC;
