-- Release 2, step 3: homework (spec 06, without correction). A published document given to a group, or to
-- some pupils of a group, with a deadline. Everything belongs to the teacher's space through its group (V6).
create table assignments (
	id uuid primary key default gen_random_uuid(),
	teacher_id uuid not null references users (id),
	content_item_id uuid not null references content_items (id),
	group_id uuid not null references class_groups (id),
	title varchar(160) not null,
	instructions varchar(2000),
	deadline_at timestamptz not null,
	max_score integer not null default 20,
	-- FILE: photos or a PDF to send. NONE: something to read, no status counted.
	submission_mode varchar(8) not null check (submission_mode in ('FILE', 'NONE')),
	allow_late boolean not null default false,
	-- The whole group: a pupil who joins it before the deadline gets the homework too.
	whole_group boolean not null,
	closed_at timestamptz,
	created_at timestamptz not null default now()
);
create index assignments_teacher on assignments (teacher_id, deadline_at desc);
create index assignments_group on assignments (group_id);

-- One row per pupil. MISSING is set by a job a few minutes after the deadline.
create table assignment_recipients (
	id uuid primary key default gen_random_uuid(),
	assignment_id uuid not null references assignments (id) on delete cascade,
	student_id uuid not null references students (id),
	status varchar(10) not null check (status in ('TODO', 'SUBMITTED', 'LATE', 'MISSING', 'CORRECTED')),
	status_changed_at timestamptz not null default now(),
	unique (assignment_id, student_id)
);
create index assignment_recipients_student on assignment_recipients (student_id);

-- What a pupil (or a parent for the child) sent; a new one replaces the last until the deadline.
create table submissions (
	id uuid primary key default gen_random_uuid(),
	recipient_id uuid not null references assignment_recipients (id) on delete cascade,
	file_id uuid not null references file_assets (id),
	submitted_at timestamptz not null,
	is_late boolean not null,
	submitted_by uuid not null references users (id)
);
create index submissions_recipient on submissions (recipient_id, submitted_at desc);

-- New homework reaches the pupils and their parents like a changed session.
alter table notifications drop constraint notifications_type_check;
alter table notifications add constraint notifications_type_check
	check (type in ('SESSION_CANCELLED', 'SESSION_MOVED', 'SESSION_RESTORED', 'HOMEWORK_ASSIGNED'));
alter table notifications add column assignment_id uuid references assignments (id) on delete cascade;
alter table notifications add column title varchar(160);
