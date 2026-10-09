# Spec 07. Grades and progress

Priority: **M** (charts: S) · Release R2 (charts R4)

## User stories
- As the teacher, I see each student's average, completion and attendance per subject.
- As a student, I see my grades and how I am progressing.
- As a parent, I see my child's latest grades and average without needing to interpret anything.

## Where grades come from
1. Corrections of assignments (spec 06)
2. Auto-corrected quizzes
3. Evaluations recorded for paper tests

Every grade keeps its raw score and maximum (e.g. 7/10) and is shown on /20 (14/20) next to it. Formulas: `03-BUSINESS_RULES.md`.

## Indicators per student and subject

| Indicator | Shown as |
|---|---|
| Moyenne | 15,25 / 20 (simple mean of grades on /20, no coefficients, Q6) |
| Devoirs rendus | 88 % (assignments submitted out of assignments due) |
| Moyenne des quiz | 16,00 / 20 |
| Présence | 95 % |
| Chapitres vus | list of chapters covered in sessions |
| Tendance | arrow up, stable or down, comparing the last 3 grades with the previous ones |

Indicators are computed for the current school year; a selector shows past years.

## Charts (S, R4)
- Line chart: grades on /20 over time, one line per subject.
- Bars: completion % and attendance % per month.
- Nothing more in the MVP: no rankings, no class comparisons, no percentiles.

## Who sees what
| | Teacher | Student | Parent |
|---|---|---|---|
| Indicators | all students | own | child's |
| Group average and comparison | ✅ | never | never |
| Individual grades with comments | ✅ | own | child's |

## Acceptance criteria
- [ ] A 7/10 is shown as "7/10 (14,00/20)" and counts as 14 in the average.
- [ ] The teacher profile, the student results and the parent overview show identical numbers for the same student.
- [ ] A student with no grade yet sees "Pas encore de note" instead of 0.
- [ ] An `Absent` in an evaluation does not count as 0 in the average.
- [ ] Charts are readable on a 360 px wide phone.
