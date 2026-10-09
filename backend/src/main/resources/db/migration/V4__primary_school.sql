-- The teacher teaches primary school (1ère to 6ème année) in her own groups and private lessons.
-- She creates her subjects herself; a child's own login is optional (user decisions, 2026-10-06).

-- Levels: Tunisian primary school. The secondary levels of V2 go, unless something already uses them.
delete from levels l
where not exists (select 1 from students s where s.level_id = l.id)
	and not exists (select 1 from class_groups g where g.level_id = l.id);

insert into levels (id, name_fr, name_ar, position) values
	(gen_random_uuid(), '1ère année', 'السنة الأولى ابتدائي', 1),
	(gen_random_uuid(), '2ème année', 'السنة الثانية ابتدائي', 2),
	(gen_random_uuid(), '3ème année', 'السنة الثالثة ابتدائي', 3),
	(gen_random_uuid(), '4ème année', 'السنة الرابعة ابتدائي', 4),
	(gen_random_uuid(), '5ème année', 'السنة الخامسة ابتدائي', 5),
	(gen_random_uuid(), '6ème année', 'السنة السادسة ابتدائي', 6)
on conflict (name_fr) do nothing;

-- Old levels still in use come after the primary ones.
update levels set position = position + 100 where name_fr not like '%année';

-- Subjects: none are predefined any more. The V2 ones go, unless a group already uses them.
delete from subjects s where not exists (select 1 from class_groups g where g.subject_id = s.id);

-- A child may exist without signing in: parents follow everything. The teacher opens the child's
-- access later if she wants (a username and a temporary password are created then).
alter table users add column login_enabled boolean not null default true;
