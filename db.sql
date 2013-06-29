CREATE TABLE blogs(
  id serial4 primary key,
  title varchar(100),
  post_time timestamp,
  author varchar(30),
  tags varchar(50),
  content text
)