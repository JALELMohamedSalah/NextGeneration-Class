-- Release 2, step 1: the teacher's library (spec 04). Documents only (PDF, images, Word); lessons,
-- exercises and quizzes built in the app come with release 3. Everything belongs to one teacher (V6).

-- Subject > level > chapter. A document may have no chapter ("Sans chapitre").
create table chapters (
	id uuid primary key default gen_random_uuid(),
	teacher_id uuid not null references users (id),
	subject_id uuid not null references subjects (id),
	level_id uuid not null references levels (id),
	title varchar(120) not null,
	position integer not null,
	created_at timestamptz not null default now()
);
create unique index chapters_title on chapters (teacher_id, subject_id, level_id, lower(title));
create index chapters_teacher on chapters (teacher_id);

-- An uploaded file, stored under a random key (FileStorage). Never served by its key: only through a
-- short-lived signed link.
create table file_assets (
	id uuid primary key default gen_random_uuid(),
	teacher_id uuid not null references users (id),
	storage_key varchar(80) not null unique,
	mime_type varchar(100) not null,
	size_bytes bigint not null,
	original_name varchar(255) not null,
	page_count integer,
	created_at timestamptz not null default now()
);

create table content_items (
	id uuid primary key default gen_random_uuid(),
	teacher_id uuid not null references users (id),
	type varchar(20) not null default 'DOCUMENT' check (type in ('DOCUMENT')),
	title varchar(160) not null,
	subject_id uuid not null references subjects (id),
	level_id uuid not null references levels (id),
	chapter_id uuid references chapters (id) on delete set null,
	status varchar(20) not null check (status in ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
	tag varchar(20) not null check (tag in ('SERIE', 'COURS', 'CORRIGE', 'AUTRE')),
	file_id uuid not null references file_assets (id),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);
create index content_items_teacher on content_items (teacher_id);
create index content_items_chapter on content_items (chapter_id);

-- A document or a whole chapter shared with a group: its pupils (and their parents) see it in Cours.
-- A shared chapter also shows the documents added to it later.
create table content_shares (
	id uuid primary key default gen_random_uuid(),
	group_id uuid not null references class_groups (id) on delete cascade,
	content_item_id uuid references content_items (id) on delete cascade,
	chapter_id uuid references chapters (id) on delete cascade,
	shared_at timestamptz not null default now(),
	check ((content_item_id is null) <> (chapter_id is null))
);
create unique index content_shares_item on content_shares (group_id, content_item_id) where content_item_id is not null;
create unique index content_shares_chapter on content_shares (group_id, chapter_id) where chapter_id is not null;

-- Who opened what: "Nouveau" stays on a document until the pupil (or the parent) opens it.
create table content_views (
	content_item_id uuid not null references content_items (id) on delete cascade,
	user_id uuid not null references users (id) on delete cascade,
	viewed_at timestamptz not null default now(),
	primary key (content_item_id, user_id)
);
