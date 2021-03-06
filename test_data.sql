-- Data insertion

INSERT INTO users (id, email, password, full_name, preferred_name, slack_name,
                   track_id, course_id, timezone_id, about_me)
  VALUES ('fc10b881-d9a0-4ab1-a6fd-a102db188f49', 'scttgrhm7+test@gmail.com', 'ldfgkj78%^&appdKO039*', 'Scott Graham', 'Scott', 'Scott Graham',
          1, 2, 3, 'Finishing LS and planning to do capstone in May. I like surfing and thick grey socks'),
         ('fc10b881-d9a0-4ab1-a6fd-a102db188f50', 'alonzilj+test@gmail.com', 'ppdK78%^&aO039*ldfgkj', 'Alonso Lobato', 'Alobato', 'Alonso Lobato',
          1, 1, 1, 'Finished back-end portion of Ruby track! I like canadian Christmas trees');

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
