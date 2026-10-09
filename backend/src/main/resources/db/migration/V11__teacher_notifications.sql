-- The teacher's notifications (Release 2, spec 08; mockups screens/r2/NotificationsEnseignante*.png).
-- WORK_SUBMITTED: work sent by a pupil or a parent. One unread row per homework gathers everyone who sent
-- since the teacher last read it ("3 travaux rendus"), so created_at moves to the latest work.
-- DEADLINE_PASSED: at each homework's deadline, who did not send (or nobody).
alter table notifications drop constraint notifications_type_check;
alter table notifications add constraint notifications_type_check
	check (type in ('SESSION_CANCELLED', 'SESSION_MOVED', 'SESSION_RESTORED', 'HOMEWORK_ASSIGNED', 'HOMEWORK_CORRECTED',
		'EVALUATION_GRADED', 'WORK_SUBMITTED', 'DEADLINE_PASSED'));
-- The pupils it names, in order: [{"id", "firstName", "lastName"}]. Kept as written then, like the group name.
alter table notifications add column pupils jsonb not null default '[]';
-- WORK_SUBMITTED: at least one of the works arrived after the deadline.
alter table notifications add column late boolean not null default false;
create index notifications_merge on notifications (user_id, assignment_id) where read_at is null and type = 'WORK_SUBMITTED';

-- Each homework tells its teacher once that its deadline passed; a later deadline asks again.
-- Deadlines already past are not announced now.
alter table assignments add column deadline_notified_at timestamptz;
update assignments set deadline_notified_at = now() where deadline_at <= now();
create index assignments_deadline_due on assignments (deadline_at) where deadline_notified_at is null;
