CREATE TABLE blogs(
  id serial4 primary key,
  title varchar(100),
  post_time timestamp,
  author varchar(30),
  tags varchar(50),
  content text
)


CREATE TABLE comments(
  id serial4 primary key,
  post_time timestamp,
  author varchar(30),
  content varchar(200),
  blog_id int4 references blogs(id)
)