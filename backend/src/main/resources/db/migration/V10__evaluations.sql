-- Release 2, step 5: paper evaluations (spec 06 "Évaluations"). A test done in class on paper: the teacher
-- types the group's scores. They count in Résultats like a corrected homework; an absent pupil never as 0.
create table evaluations (
	id uuid primary key default gen_random_uuid(),
	teacher_id uuid not null references users (id),
	group_id uuid not null references class_groups (id),
	title varchar(160) not null,
	held_on date not null,
	max_score integer not null check (max_score between 1 and 100),
	chapter_id uuid references chapters (id) on delete set null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);
create index evaluations_teacher on evaluations (teacher_id, held_on desc);
create index evaluations_group on evaluations (group_id);

-- One row per pupil once something is typed: a score in half points, or absent; an optional comment.
create table evaluation_grades (
	evaluation_id uuid not null references evaluations (id) on delete cascade,
	student_id uuid not null references students (id) on delete cascade,
	score numeric(5, 2) check (score is null or score >= 0),
	absent boolean not null default false,
	comment varchar(2000),
	graded_at timestamptz not null default now(),
	primary key (evaluation_id, student_id),
	check (not (absent and score is not null))
);
create index evaluation_grades_student on evaluation_grades (student_id);

-- A new grade reaches the pupil and the parents ("Nouvelle note").
alter table notifications drop constraint notifications_type_check;
alter table notifications add constraint notifications_type_check
	check (type in ('SESSION_CANCELLED', 'SESSION_MOVED', 'SESSION_RESTORED', 'HOMEWORK_ASSIGNED', 'HOMEWORK_CORRECTED', 'EVALUATION_GRADED'));
alter table notifications add column evaluation_id uuid references evaluations (id) on delete cascade;
