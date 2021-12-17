-- Data insertion

INSERT INTO courses (course_code, course_name)
  VALUES ('RB185', 'Database applications'),
         ('JS230', 'DOM and Asynchronous Programming with JavaScript');

INSERT INTO tracks (track_code, track_name)
  VALUES ('RB', 'Ruby'),
         ('JS', 'Javascript');

INSERT INTO timezones (tzone_code, tzone_name, gmtoffset)
  VALUES ('EST', 'Eastern Standard Time', -5),
         ('CET', 'Central European Time', 1),
         ('PST', 'Pacific Standard Time', -8);

INSERT INTO users (firstname, lastname, slackname, email, password,
                   course_id, track_id, timezone_id, about_me)
  VALUES ('Scott', 'Graham', 'Scott', 'scttgrhm7@gmail.com', 'ldfgkj78%^&appdKO039*',
          2, 1, 3, 'Finishing LS and planning to do capstone in May. I like surfing and thick grey socks'),
         ('Alonso', 'Lobato', 'Alonso Lobato', 'alonzilj@gmail.com', 'ppdK78%^&aO039*ldfgkj',
          1, 1, 1, 'About to finish back-end portion of Ruby track. I like canadian Christmas trees');

INSERT INTO needs (need, class)
  VALUES ('Preparing for a written assessment', 'Assessment'),
         ('Preparing for an interview assessment', 'Assessment'),
         ('Reviewing concepts', 'Study'),
         ('Practicing problem solving', 'Problem solving'),
         ('Working on a project', 'Project');

INSERT INTO users_needs(user_id, need_id)
  VALUES ('1',5), -- user id is of type serial for development purposes, later it'll became  uuid
         ('1',4),
         ('2',2),
         ('2',4),
         ('2',5);

-- Querying Database

SELECT firstname, lastname, slackname, tracks.track_name, courses.course_code FROM users
  INNER JOIN courses ON courses.course_id = users.course_id
  INNER JOIN tracks ON tracks.track_id = users.track_id
  INNER JOIN users_needs ON users_needs.user_id = users.user_id
  INNER JOIN needs  ON needs.need_id = users_needs.need_id
  WHERE needs.class = 'Problem solving'
  ORDER BY last_active DESC;
