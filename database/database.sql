create table degrees (
  id_degree serial primary key,
  name text not null unique
);

create table life_habits (
  id_life_habit serial primary key,
  name text not null unique
);

create table genres (
  id_genre serial primary key,
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

create table invitation_codes (
  id_invitation_code serial primary key,
  code text not null unique,

  is_used boolean default false,
  used_by uuid references users(id_user),
  used_at timestamp,

  created_at timestamp default now()
);

create table users (
  id_user uuid primary key references auth.users(id) on delete cascade,

  name text not null,
  age integer check (age >= 18),
  description text,

  instagram_user text,
  instagram_visible boolean default false,

  id_genre integer not null references genres(id_genre),
  id_degree integer not null references degrees(id_degree),
  id_looking_for integer not null references looking_for(id_looking_for),

  is_active boolean default true,
  profile_completed boolean default false,
  is_premium boolean default false,
  premium_until timestamp,

  created_at timestamp default now()
);

create table user_swipes (
  id_swipe bigint generated always as identity primary key,
  id_user uuid not null references users(id_user),
  swiped_at timestamp default now()
);

create table user_has_interests (
  id_user uuid references users(id_user) on delete cascade,
  id_interest integer references interests(id_interest),
  primary key (id_user, id_interest)
);

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
  unique (id_user_1, id_user_2)
);
