-- Data insertion

INSERT INTO courses (code, name)
  VALUES ('RB101', 'Programming Foundations'), 
         ('RB120', 'Object Oriented Programming'),
         ('RB130', 'Ruby Foundations: More Topics'),
         ('LS170', 'Networking Foundations'),
         ('RB175', 'Networked Applications'),
         ('LS180', 'Database Foundations'),
         ('RB185', 'Database Applications'),
         ('JS202', 'HTML and CSS'),
         ('JS210', 'Fundamentals of JavaScript for Programmers'),
         ('JS215', 'Computational Thinking and Problem Solving'),
         ('JS225', 'Object Oriented JavaScript'),
         ('JS230', 'DOM and Asynchronous Programming with JavaScript');

INSERT INTO tracks (code, name)
  VALUES ('RB', 'Ruby'),
         ('JS', 'Javascript');

INSERT INTO timezones (code, name)
  VALUES ('EST', 'Eastern Standard Time'),
         ('CET', 'Central European Time'),
         ('PST', 'Pacific Standard Time');

INSERT INTO preferences (preference, category)
  VALUES ('Preparing for a written assessment', 'Assessment preparation'),
         ('Preparing for an interview assessment', 'Assessment preparation'),
         ('Reviewing concepts', 'General study'),
         ('Practicing problem solving', 'Problem solving'),
         ('Working on a project', 'Project making');
