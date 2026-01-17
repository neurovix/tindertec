create table degrees (
  id_degree serial primary key,
  name text not null unique
);

create table life_habits (
  id_life_habit serial primary key,
  name text not null unique
);

create table genders (
  id_gender serial primary key,
  name text not null unique
);

create table interests (
  id_interest serial primary key,
  name text not null unique
);

create table looking_for (
  id_looking_for serial primary key,
  name text not null unique
);

create table users (
  id_user uuid primary key references auth.users(id) on delete cascade,

  name text not null,
  age integer check (age >= 18),
  description text,

  instagram_user text,

  id_gender integer not null references genders(id_gender),

  id_degree integer not null references degrees(id_degree),
  custom_degree text null,

  id_looking_for integer not null references looking_for(id_looking_for),
  id_interest integer not null references interests(id_interest),

  profile_completed boolean default false,

  is_premium boolean default false,
  premium_until timestamp,

  created_at timestamp default now()
);

create table user_swipes (
  id uuid default gen_random_uuid() primary key,
  id_user uuid references users(id_user),
  swipe_count int default 0,
  swipe_date date default current_date,
  created_at timestamp default now()
);

create index idx_user_swipes_user_date
on user_swipes (id_user, swiped_at);

create table user_has_life_habits (
  id_user uuid references users(id_user) on delete cascade,
  id_life_habit integer references life_habits(id_life_habit),
  primary key (id_user, id_life_habit)
);

create table user_photos (
  id_photo serial primary key,
  id_user uuid not null references users(id_user) on delete cascade,
  url text not null,
  order_index integer default 0,
  is_main boolean default false
);

create table user_likes (
  id_like serial primary key,
  id_user_from uuid not null references users(id_user) on delete cascade,
  id_user_to uuid not null references users(id_user) on delete cascade,
  created_at timestamp default now(),
  unique (id_user_from, id_user_to)
);

create table matches (
  id_match serial primary key,
  id_user_1 uuid not null references users(id_user) on delete cascade,
  id_user_2 uuid not null references users(id_user) on delete cascade,
  matched_at timestamp default now(),
  unique (id_user_1, id_user_2),
  check (id_user_1 < id_user_2)
);

create index idx_matches_user1 on matches (id_user_1);
create index idx_matches_user2 on matches (id_user_2);

CREATE INDEX idx_matches_lookup
ON matches (id_user_1, id_user_2);
