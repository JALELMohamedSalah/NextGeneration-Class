# Delivery 04. Changes from the client's first spec (v1)

The original is kept unchanged in `99-source/client_spec_v1.md`.

## Merged or renamed
| v1 | v2 | Why |
|---|---|---|
| QCM builder and Quiz builder | one **Quiz** builder, QCM is a preset | a QCM is a quiz with only multiple-choice questions |
| Courses, Library, Toolkit | one **Contenus** area with `+ Créer` | three menus for the same content |
| Course | **Chapter** | v1 used "course" for a chapter ("Math > Fractions") |
| Homework and Assignment | **Assignment** (Devoir), one flow for every content type | they were the same thing |
| Correction | **Model answer** (Corrigé) and **Correction** (grading) | one word for two different things |
| "Individual Student" as a group example | **private lesson = group of one** | one model for groups and private students |
| Homework statuses: Not started, In progress, Submitted, Corrected, Late, Missing | À faire, Rendu, Rendu en retard, Manquant, Corrigé | "in progress" cannot be known for paper work; "late" is a kind of submission |
| Worksheet options: with correction, without, student, teacher | two versions: Élève, Enseignante | the four options were two |
| Quiz setting "number of questions", "score" | computed | they follow from the questions |
| Parent dashboard (§24) and parent experience (§29) | one parent space | duplicates |

## Priority changes
| Item | v1 | v2 |
|---|---|---|
| Session mode | Should | **Must** (attendance is taken there) |
| Teacher private notes | Should | **Must** (needed from Release 1) |
| Duplicate content | Should | **Must** (v1 calls it "a major productivity feature") |
| PDF worksheet export | Must, but in the last phase | Must, Release 3 |

## Contradictions resolved
- **Messaging**: v1 put "simple messages" in the MVP and "teacher to student/parent" later. v2: one-way announcements in the MVP, two-way messaging later.
- **Teacher notifications**: "homework submitted", "quiz completed" and "student absent" as pushes would spam the teacher (and she records absences herself). v2: dashboard items and a morning digest.
- **Phase order**: dashboard first with no data, student app after submissions. v2: four releases, each usable (`01-RELEASE_PLAN.md`).
- **"16 screens" vs the navigation list**: Toolkit, Library and Courses were separate. v2: 15 teacher screens, 5 student, 3 parent, sharing components.

## Added (missing from v1)
- Account creation and login for minors without email; parents with several children
- School year and year rollover
- Evaluations: grades for paper tests
- Math formula editor and rendering
- Arabic content support
- Thresholds for "students needing attention"
- Quiz details: matching rules, timer, attempts, when answers are shown, lock after submissions
- Upload limits, camera scan to PDF, Word preview limitation
- Recurring session edit scopes, cancellation reasons
- Notification timing, quiet hours, grouping
- Grade, completion and attendance formulas
- Privacy and security for minors' data
- Realistic cost table and budget scenarios
- Data model, API outline, architecture, user flows, wireframes
- Brand: name NextGeneration Class, colors, fonts, logo brief and Gemini prompts
- Open questions with recommended defaults

## Removed duplicates
v1 sections 3 and 33 (what not to build), 4 and 18 (Google Meet), 4 and 13 (uploads), 5, 21 and 34 (dashboard questions), 24 and 29 (parent space), 36 and 37 (development rules).
