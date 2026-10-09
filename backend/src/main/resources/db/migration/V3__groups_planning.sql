-- Release 1 "Organize my week": groups, private lessons, notes, planning and attendance
-- (docs/03-conception/02-DATA_MODEL.md).

create table class_groups (
	id uuid primary key,
	school_year_id uuid not null references school_years (id),
	subject_id uuid not null references subjects (id),
	level_id uuid not null references levels (id),
	name varchar(80) not null,
	-- A private lesson is a group of one student.
	is_private boolean not null default false,
	default_meet_url varchar(500),
	color varchar(7) not null,
	archived_at timestamptz,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);
create index class_groups_year on class_groups (school_year_id) where archived_at is null;

-- Current members have left_at null; leaving keeps the history (attendance, grades).
create table group_members (
	group_id uuid not null references class_groups (id) on delete cascade,
	student_id uuid not null references students (id) on delete cascade,
	joined_at timestamptz not null default now(),
	left_at timestamptz,
	primary key (group_id, student_id)
);
create index group_members_student on group_members (student_id) where left_at is null;

-- Teacher only: never returned by a student or parent endpoint.
create table private_notes (
	id uuid primary key,
	student_id uuid not null references students (id) on delete cascade,
	body text not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);
create index private_notes_student on private_notes (student_id, created_at desc);

-- Feedback the student and their parents can read.
create table comments (
	id uuid primary key,
	student_id uuid not null references students (id) on delete cascade,
	body text not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);
create index comments_student on comments (student_id, created_at desc);

-- A weekly schedule; sessions are generated from it and can then be edited one by one.
create table recurrence_rules (
	id uuid primary key,
	group_id uuid not null references class_groups (id) on delete cascade,
	weekday integer not null check (weekday between 1 and 7),
	start_time time not null,
	end_time time not null,
	mode varchar(12) not null check (mode in ('IN_PERSON', 'ONLINE')),
	location varchar(120),
	meet_url varchar(500),
	starts_on date not null,
	ends_on date not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	check (end_time > start_time),
	check (ends_on >= starts_on)
);

create table sessions (
	id uuid primary key,
	group_id uuid not null references class_groups (id) on delete cascade,
	recurrence_rule_id uuid references recurrence_rules (id) on delete set null,
	starts_at timestamptz not null,
	ends_at timestamptz not null,
	mode varchar(12) not null check (mode in ('IN_PERSON', 'ONLINE')),
	location varchar(120),
	-- Null: the group's default link is used.
	meet_url varchar(500),
	status varchar(12) not null default 'PLANNED' check (status in ('PLANNED', 'IN_PROGRESS', 'DONE', 'CANCELLED')),
	cancel_reason varchar(300),
	prep_note text,
	quick_note text,
	session_note text,
	-- Changed on this date only (time, place, link): later edits of the whole series leave it alone.
	is_exception boolean not null default false,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	check (ends_at > starts_at)
);
create index sessions_group_start on sessions (group_id, starts_at);
create index sessions_start on sessions (starts_at);
create index sessions_rule on sessions (recurrence_rule_id, starts_at);

create table attendance (
	session_id uuid not null references sessions (id) on delete cascade,
	student_id uuid not null references students (id) on delete cascade,
	status varchar(8) not null check (status in ('PRESENT', 'ABSENT', 'LATE')),
	marked_at timestamptz not null default now(),
	primary key (session_id, student_id)
);
create index attendance_student on attendance (student_id);
