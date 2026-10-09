-- Accounts: one teacher, students and parents (docs/01-product/03-ROLES_PERMISSIONS.md).
create table users (
	id uuid primary key,
	role varchar(16) not null check (role in ('TEACHER', 'STUDENT', 'PARENT')),
	username varchar(64) not null unique,
	phone varchar(20) unique,
	email varchar(254),
	password_hash varchar(100) not null,
	first_name varchar(80) not null,
	last_name varchar(80) not null,
	-- Last language used in the app: server messages (push, email) are written in it.
	language varchar(2) not null default 'fr' check (language in ('fr', 'ar')),
	active boolean not null default true,
	must_change_password boolean not null default false,
	failed_login_attempts integer not null default 0,
	locked_until timestamptz,
	last_login_at timestamptz,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

-- The product has exactly one teacher: the database refuses a second one.
create unique index users_single_teacher on users (role) where role = 'TEACHER';

-- Opaque refresh tokens, stored hashed, rotated on every use.
create table refresh_tokens (
	id uuid primary key,
	token_hash varchar(64) not null unique,
	user_id uuid not null references users (id) on delete cascade,
	expires_at timestamptz not null,
	revoked boolean not null default false,
	created_at timestamptz not null default now()
);
create index refresh_tokens_user_revoked on refresh_tokens (user_id, revoked);

-- Reference data is shown in French or Arabic: both names are stored.
create table subjects (
	id uuid primary key,
	name_fr varchar(60) not null unique,
	name_ar varchar(60) not null,
	color varchar(7) not null,
	position integer not null
);

create table levels (
	id uuid primary key,
	name_fr varchar(40) not null unique,
	name_ar varchar(60) not null,
	position integer not null
);

create table school_years (
	id uuid primary key,
	label varchar(9) not null unique,
	starts_on date not null,
	ends_on date not null,
	is_current boolean not null default false
);
create unique index school_years_single_current on school_years (is_current) where is_current;

create table students (
	id uuid primary key,
	user_id uuid not null unique references users (id),
	level_id uuid not null references levels (id),
	archived_at timestamptz,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create table parents (
	id uuid primary key,
	user_id uuid not null unique references users (id),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create table parent_students (
	parent_id uuid not null references parents (id) on delete cascade,
	student_id uuid not null references students (id) on delete cascade,
	relation varchar(20),
	primary key (parent_id, student_id)
);
create index parent_students_student on parent_students (student_id);
