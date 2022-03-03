-- Data insertion

INSERT INTO courses (code, name)
  VALUES ('RB101', 'Programming Foundations'),
         ('JS101', 'Programming Foundations with JavaScript'),
         ('RB120', 'Object Oriented Programming'),
         ('JS120', 'Object Oriented Programming with JavaScript'),
         ('RB130', 'Ruby Foundations: More Topics'),
         ('JS130', 'More JavaScript Foundations'),
         ('LS170', 'Networking Foundations'),
         ('RB175', 'Networked Applications'),
         ('JS175', 'Networked Applications with JavaScript'),
         ('LS180', 'Database Foundations'),
         ('RB185', 'Database Applications'),
         ('JS185', 'Database Applications with JavaScript'),
         ('LS202', 'HTML and CSS'),
         ('JS210', 'Fundamentals of JavaScript for Programmers'),
         ('LS215', 'Computational Thinking and Problem Solving'),
         ('JS225', 'Object Oriented JavaScript'),
         ('JS230', 'DOM and Asynchronous Programming with JavaScript');

INSERT INTO tracks (code, name)
  VALUES ('RB', 'Ruby'),
         ('JS', 'Javascript');

INSERT INTO timezones (code, name)
  VALUES ('GMT', 'Greenwich Mean Time'),
         ('UTC', 'Universal Coordinated Time'),
         ('EST', 'Eastern Standard Time'),
         ('PST', 'Pacific Standard Time'),
         ('CST', 'Central Standard Time'),
         ('ECT', 'European Central Time'),
         ('EET', 'Eastern European Time'),
         ('ART', '(Arabic) Egypt Standard Time'),
         ('EAT', 'Eastern African Time'),
         ('MET', 'Middle East Time'),
         ('NET', 'Near East Time'),
         ('PLT', 'Pakistan Lahore Time'),
         ('IST', 'India Standard Time'),
         ('BST', 'Bangladesh Standard Time'),
         ('VST', 'Vietnam Standard Time'),
         ('CTT', 'China Taiwan Time'),
         ('JST', 'Japan Standard Time'),
         ('ACT', 'Australia Central Time'),
         ('AET', 'Australia Eastern Time'),
         ('SST', 'Solomon Standard Time'),
         ('NST', 'New Zealand Standard Time'),
         ('MIT', 'Midway Islands Time'),
         ('HST', 'Hawaii Standard Time'),
         ('AST', 'Alaska Standard Time'),
         ('PNT', 'Phoenix Standard Time'),
         ('MST', 'Mountain Standard Time'),
         ('IET', 'Indiana Eastern Standard Time'),
         ('PRT', 'Puerto Rico and US Virgin Islands Time'),
         ('CNT', 'Canada Newfoundland Time'),
         ('AGT', 'Argentina Standard Time'),
         ('BET', 'Brazil Eastern Time'),
         ('CAT', 'Central African Time');

INSERT INTO preferences (preference, category)
  VALUES ('Preparing for a written assessment', 'Assessment preparation'),
         ('Preparing for an interview assessment', 'Assessment preparation'),
         ('Reviewing concepts', 'General study'),
         ('Practicing problem solving', 'Problem solving'),
         ('Working on a project', 'Project making');
