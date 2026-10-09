-- Several teachers, each in her own space (user decision 2026-10-06). The owner of the platform
-- (ADMIN) adds them from the dashboard. A teacher's subjects, students, parents and groups belong
-- to her; sessions, series, notes and attendance follow through their group or student.

alter table users drop constraint users_role_check;
alter table users add constraint users_role_check check (role in ('ADMIN', 'TEACHER', 'STUDENT', 'PARENT'));
drop index users_single_teacher;

alter table subjects add column teacher_id uuid references users (id);
alter table students add column teacher_id uuid references users (id);
alter table parents add column teacher_id uuid references users (id);
alter table class_groups add column teacher_id uuid references users (id);

-- Everything created so far belongs to the one teacher there was.
update subjects set teacher_id = (select id from users where role = 'TEACHER' order by created_at limit 1);
update students set teacher_id = (select id from users where role = 'TEACHER' order by created_at limit 1);
update parents set teacher_id = (select id from users where role = 'TEACHER' order by created_at limit 1);
update class_groups set teacher_id = (select id from users where role = 'TEACHER' order by created_at limit 1);

alter table subjects alter column teacher_id set not null;
alter table students alter column teacher_id set not null;
alter table parents alter column teacher_id set not null;
alter table class_groups alter column teacher_id set not null;

-- Two teachers may both teach "Lecture": a subject name is unique per teacher.
alter table subjects drop constraint subjects_name_fr_key;
create unique index subjects_teacher_name on subjects (teacher_id, lower(name_fr));

create index students_teacher on students (teacher_id);
create index parents_teacher on parents (teacher_id);
create index class_groups_teacher on class_groups (teacher_id);
