-- Subjects and levels of the Tunisian system, in French and Arabic
-- (editable later from the teacher's settings).
insert into subjects (id, name_fr, name_ar, color, position) values
	(gen_random_uuid(), 'Math', 'رياضيات', '#2B3990', 1),
	(gen_random_uuid(), 'Physique', 'علوم فيزيائية', '#7048E8', 2);

insert into levels (id, name_fr, name_ar, position) values
	(gen_random_uuid(), '6ème', 'السنة السادسة أساسي', 1),
	(gen_random_uuid(), '7ème', 'السنة السابعة أساسي', 2),
	(gen_random_uuid(), '8ème', 'السنة الثامنة أساسي', 3),
	(gen_random_uuid(), '9ème', 'السنة التاسعة أساسي', 4),
	(gen_random_uuid(), '1ère', 'السنة الأولى ثانوي', 5),
	(gen_random_uuid(), '2ème', 'السنة الثانية ثانوي', 6),
	(gen_random_uuid(), '3ème', 'السنة الثالثة ثانوي', 7),
	(gen_random_uuid(), '4ème (Bac)', 'السنة الرابعة ثانوي (باكالوريا)', 8);
