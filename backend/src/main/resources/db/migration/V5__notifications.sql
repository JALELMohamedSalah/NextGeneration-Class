-- In-app notifications (Release 1): a session cancelled, moved or restored reaches the parents of the group's
-- children and the children who have their own login. One row per person and child; one teacher action
-- (for example "cancel this session and the following") gives one row, with the number of sessions.
-- The row keeps what it says (group name, times, reason), so it stays true if the session changes again.
-- The app words it in French or Arabic from these fields: no sentence is stored.
create table notifications (
	id uuid primary key,
	user_id uuid not null references users (id) on delete cascade,
	type varchar(24) not null check (type in ('SESSION_CANCELLED', 'SESSION_MOVED', 'SESSION_RESTORED')),
	-- The child it is about: parents with several children see the first name on each notification.
	student_id uuid references students (id) on delete cascade,
	child_first_name varchar(80),
	group_id uuid references class_groups (id) on delete set null,
	group_name varchar(80) not null,
	-- The first session concerned, to open the planning on its day.
	session_id uuid references sessions (id) on delete set null,
	starts_at timestamptz not null,
	-- For a moved session: when it was before.
	previous_starts_at timestamptz,
	session_count integer not null default 1,
	reason varchar(300),
	created_at timestamptz not null default now(),
	read_at timestamptz
);

create index notifications_user_created on notifications (user_id, created_at desc);
create index notifications_user_unread on notifications (user_id) where read_at is null;
