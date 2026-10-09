-- Release 2, step 4: correction (spec 06). One correction per pupil and homework, kept on its recipient row:
-- a score out of the homework's max_score (half points), a comment for the pupil and the parents, and an
-- optional corrected copy (the teacher's photo or file).
alter table assignment_recipients add column score numeric(5, 2) check (score is null or score >= 0);
alter table assignment_recipients add column comment varchar(2000);
alter table assignment_recipients add column corrected_at timestamptz;
alter table assignment_recipients add column correction_file_id uuid references file_assets (id);

-- A corrected homework reaches the pupil and the parents like a new one.
alter table notifications drop constraint notifications_type_check;
alter table notifications add constraint notifications_type_check
	check (type in ('SESSION_CANCELLED', 'SESSION_MOVED', 'SESSION_RESTORED', 'HOMEWORK_ASSIGNED', 'HOMEWORK_CORRECTED'));
