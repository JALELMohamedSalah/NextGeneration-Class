# Spec 06. Assignments, submissions, correction and evaluations

Priority: **M** · Release R2 (quiz assignments in R3)

## User stories
- As the teacher, I give any content to a whole group, some students or one student, with a deadline.
- As a student, I see what I have to do, do it, and send photos of my paper work or answer online.
- As the teacher, I find every submission waiting for me in one queue and correct them one after the other.
- As the teacher, I record grades of a test done on paper in class.
- As a student or parent, I see the grade and the teacher's comment.

## Assign
`Assigner` from any published library item, from the home quick action, or from the end of a session.

| Field | Default |
|---|---|
| Contenu | the chosen item (title can be overridden) |
| Destinataires | a group, selected students of a group, or one student |
| Date limite | date and time, required |
| Barème | from the content, else 20 |
| Consignes | optional text |
| Mode de rendu | `Fichier` (photos or PDF), `En ligne` (quizzes), `Aucun` (read only) |
| Retard accepté | no |

Students who join a group before the deadline receive the group's open assignments.

## Student submission
- Open the assignment: instructions, content (PDF viewer, series, quiz), deadline, status.
- `Fichier` mode: take photos (several pages) or pick files; pages are combined into one PDF on the device; `Envoyer`.
- `En ligne` mode: the quiz player (spec 05).
- The student can replace the submission until the deadline or until it is corrected, whichever comes first.
- After the deadline, `Envoyer` is available only if late submission is accepted; the submission is marked late.

## Statuses (per student and assignment)

| Status | Meaning |
|---|---|
| `À faire` | assigned, not submitted, deadline not passed |
| `Rendu` | submitted on time |
| `Rendu en retard` | submitted after the deadline (if accepted) |
| `Manquant` | deadline passed, nothing submitted |
| `Corrigé` | graded by the teacher, or fully auto-corrected |

`Aucun` mode assignments have no status (read only) and do not count in completion. State machine: `03-BUSINESS_RULES.md`.

## Assignment detail (teacher)
- Header: content, recipients, deadline, counts per status.
- Table: one row per student with status, submission time, score, `Corriger`.
- Actions: change the deadline, remind students who have not submitted (one push, at most once a day), close the assignment.

## Correction queue ("À corriger")
- Every submission waiting for the teacher: `Rendu` and `Rendu en retard` in file mode, and quizzes with open questions.
- Grouped by assignment, oldest first. Filters: group, subject.

## Correction screen
- Left (desktop) or top (phone): the submission, zoomable and pageable; for quizzes, each answer with the automatic result.
- Right or bottom: score (for quizzes, the automatic part is pre-filled and open questions are scored one by one), comment, optional corrected file (for example the teacher's annotated photo).
- `Enregistrer et suivant`: saves and opens the next submission of the same assignment.
- The grade and comment are visible to the student and parents as soon as they are saved (Q10).
- The model answer becomes visible to students after the deadline, if the content has one.

## Evaluations (paper tests)
- `+ Évaluation` from a group: title, date, scale (default 20), optional chapter.
- A quick table of the group's students: type a score, `Tab` to the next, `Absent` checkbox, optional comment.
- Evaluation grades count in averages like any other grade.

## Acceptance criteria
- [ ] Assigning to a group of 8 creates 8 student statuses `À faire`, and each student gets a notification.
- [ ] A student's 3 photos arrive as one 3-page PDF in the right order.
- [ ] At the deadline, unsubmitted statuses switch to `Manquant` within 5 minutes (scheduled job).
- [ ] Correcting 8 submissions in a row needs no navigation besides `Enregistrer et suivant`.
- [ ] A fully automatic quiz never appears in "À corriger" and is `Corrigé` on submission.
- [ ] Entering an evaluation for 8 students takes under a minute with the keyboard.
- [ ] A student never sees another student's submission, grade or comment.
