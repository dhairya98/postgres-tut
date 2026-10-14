-- To create a new table
create table users(
  id serial primary key,
  display_name text
)

-- Add entry
insert into users(display_name) values('Dhairya'),('Manjula')

-- Fetch 
select * from users order by id desc

-- Fetch Specific
select * from users order by id desc
select * from users where display_name = 'Manjula' order by id desc
select * from users where display_name like 'M%' order by id desc

-- Dopwnload a package
create extension if not exists pgcrypto

-- Alter Table
create extension if not exists pgcrypto;

alter table users add column new_id uuid default gen_random_uuid();
alter table users add column email text;
alter table users add column age int;
alter table users add column created_at timestamptz not null default now();

-- INSERT CLASSIC WAY with print as soon as success
INSERT INTO users (display_name, email, age)
VALUES 
  ('Alex Demko', 'alex.demko@example.com', 28),
  ('John Doe', 'john.doe@example.com', 35),
  ('Sarah Smith', 'sarah.smith@example.com', 22),
  ('Michael Scott', 'michael.s@example.com', 45)
RETURNING *;

-- Wipe out all entries
TRUNCATE TABLE users;

-- DELETE does NOT reset the counter
-- TRUNCATE resets the counter
-- DELETE FROM users; (Slow & Heavy)
-- TRUNCATE TABLE users;

-- Drop
alter table users drop constraint users_pkey;
alter table users drop column id;
alter table users rename column new_id to id;
alter table users add primary key (id);

-- Alter and Constraints
alter table users alter column display_name set not null;
alter table users alter column email set not null;
alter table users add constraint users_email_key unique (email);
alter table users add constraint users_age_check check (age >= 13);

-- Crete new table with foreign key
create table posts(
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  title text not null,
  body text,
  status text not null default 'draft'
    check (status in ('draft', 'published', 'archived')),
  published_at timestamptz,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
)

-- Create comments table

create table comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references posts(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

-- Data insert

-- 1. Create dummy users 
INSERT INTO users (display_name, email, age)
VALUES 
('Alice Johnson', 'alice@example.com', 25),
('Bob Smith', 'bob@example.com', 32),
('Charlie Brown', 'charlie@example.com', 19)

-- 2. Add dummy posts that automatically link to the real user UUIDs above
INSERT INTO posts (user_id, title, body, status)
VALUES
  ('a1b2c3d4-e5f6...', 'Getting Started with SQL', 'This is my first post!', 'published'),
  ('f8g9h0i1-j2k3...', 'Supabase Tips & Tricks', 'Constraints are awesome.', 'published');

-- Local level
WITH inserted_users AS (
  INSERT INTO users (display_name, email, age)
  VALUES 
    ('Alice Johnson', 'alice@example.com', 25),
    ('Bob Smith', 'bob@example.com', 32),
    ('Charlie Brown', 'charlie@example.com', 19)
  RETURNING id, display_name
)

INSERT INTO posts (user_id, title, body, status)
VALUES
  ((SELECT id FROM inserted_users WHERE display_name = 'Alice Johnson'), 
   'Getting Started with SQL', 'This is my very first post about databases!', 'published'),
   
  ((SELECT id FROM inserted_users WHERE display_name = 'Alice Johnson'), 
   'My Draft Idea', 'Thinking about writing a blog post here...', 'draft'),

  ((SELECT id FROM inserted_users WHERE display_name = 'Bob Smith'), 
   'Supabase Tips & Tricks', 'Always name your constraints to make debugging easy.', 'published'),

  ((SELECT id FROM inserted_users WHERE display_name = 'Charlie Brown'), 
   'Is Elasticsearch NoSQL?', 'Learning how inverted indices work behind the scenes.', 'published')
RETURNING *;

-- Add stuff in comments

INSERT INTO comments (user_id, post_id, body)
VALUES
  (
    (SELECT id FROM users WHERE email = 'alice@example.com'),
    (SELECT id FROM posts WHERE title = 'Supabase Tips & Tricks'),
    'Great article! Naming constraints has saved me hours of debugging.'
  ),
  (

    (SELECT id FROM users WHERE email = 'bob@example.com'),
    (SELECT id FROM posts WHERE title = 'Getting Started with SQL'),
    'Welcome to the database world, Alice! Great first post.'
  ),
  (
    (SELECT id FROM users WHERE email = 'charlie@example.com'),
    (SELECT id FROM posts WHERE title = 'Getting Started with SQL'),
    'Super clear explanation. Looking forward to the next one.'
  );

-- Inner Join
select u.display_name, p.title
from users u
inner join posts p on p.user_id = u.id;

-- Left Join
select u.display_name, p.title
from users u
left join posts p on p.user_id = u.id;

-- Right join
select u.display_name, p.title
from posts p
right join users u on p.user_id = u.id;

-- Full outer join
select u.display_name, p.title
from users u
full outer join posts p on p.user_id = u.id;

-- Cross Join
SELECT u.display_name, p.title
FROM users u
CROSS JOIN posts p;

-- Self Jpin
SELECT 
  employee.display_name AS employee_name,
  manager.display_name AS manager_name
FROM users employee
INNER JOIN users manager ON employee.manager_id = manager.id;
