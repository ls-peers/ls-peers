-- Data insertion

INSERT INTO courses (code, name)
  VALUES ('RB185', 'Database applications'),
         ('JS230', 'DOM and Asynchronous Programming with JavaScript');

INSERT INTO tracks (code, name)
  VALUES ('RB', 'Ruby'),
         ('JS', 'Javascript');

INSERT INTO timezones (code, name)
  VALUES ('EST', 'Eastern Standard Time'),
         ('CET', 'Central European Time'),
         ('PST', 'Pacific Standard Time');

INSERT INTO users (id, email, password, full_name, preferred_name, slack_name,
                   course_id, track_id, timezone_id, about_me)
  VALUES ('fc10b881-d9a0-4ab1-a6fd-a102db188f49', 'scttgrhm7@gmail.com', 'ldfgkj78%^&appdKO039*', 'Scott Graham', 'Scott', 'Scott Graham',
          2, 1, 3, 'Finishing LS and planning to do capstone in May. I like surfing and thick grey socks'),
         ('fc10b881-d9a0-4ab1-a6fd-a102db188f50', 'alonzilj@gmail.com', 'ppdK78%^&aO039*ldfgkj', 'Alonso Lobato', 'Alobato', 'Alonso Lobato',
          1, 1, 1, 'Finished back-end portion of Ruby track! I like canadian Christmas trees');

INSERT INTO preferences (preference, category)
  VALUES ('Preparing for a written assessment', 'Assessment'),
         ('Preparing for an interview assessment', 'Assessment'),
         ('Reviewing concepts', 'Study'),
         ('Practicing problem solving', 'Problem solving'),
         ('Working on a project', 'Project');

INSERT INTO users_preferences(user_id, preference_id)
  VALUES ('fc10b881-d9a0-4ab1-a6fd-a102db188f49',5),
         ('fc10b881-d9a0-4ab1-a6fd-a102db188f49',4),
         ('fc10b881-d9a0-4ab1-a6fd-a102db188f50',2),
         ('fc10b881-d9a0-4ab1-a6fd-a102db188f50',4),
         ('fc10b881-d9a0-4ab1-a6fd-a102db188f50',5);

-- Querying Database

SELECT preferred_name, slack_name, tracks.name, courses.code
  FROM users
    INNER JOIN courses ON courses.id = users.course_id
    INNER JOIN tracks ON tracks.id = users.track_id
    INNER JOIN users_preferences ON users_preferences.user_id = users.id
    INNER JOIN preferences  ON preferences.id = users_preferences.preference_id
  WHERE preferences.category = 'Problem solving'
  ORDER BY last_active DESC;
