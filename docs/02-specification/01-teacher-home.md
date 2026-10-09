# Spec 01. Teacher home: "Ma journée"

Priority: **M** · Built in steps: v1 in R1, v2 in R2, v3 in R4

## Goal
Answer *"What do I need to do today?"* in a few seconds, and let the teacher act in one click. This is the most important screen of the product.

## User stories
- As the teacher, I see today's sessions in time order, so I know what comes next.
- As the teacher, I join or start a session from the home screen.
- As the teacher, I see how many submissions wait for correction and open one in one click.
- As the teacher, I see which students have not submitted an assignment that is past its deadline.
- As the teacher, I see which students need attention, and why.
- As the teacher, I see tomorrow's sessions and the deadlines of the next 7 days.
- As the teacher, I create a session, an assignment, a quiz, a series or a student, or upload a document, without leaving the home screen.

## Layout, top to bottom

| # | Block | Content | Release |
|---|---|---|---|
| 1 | **Aujourd'hui** | today's sessions: time, subject, group, mode, status, `Rejoindre` (Meet), `Démarrer la séance` | R1 |
| 2 | **À corriger** | count, then the 5 oldest items ("Devoir Fractions · Ahmed"), `Tout voir` | R2 |
| 3 | **Travail manquant** | assignments past their deadline, with the names of students who did not submit | R2 |
| 4 | ~~**À surveiller**~~ | removed 2026-10-09 (user decision: no alerting for now) | |
| 5 | **À venir** | tomorrow's sessions (R1), deadlines and quizzes of the next 7 days (R2) | R1, R2 |

On desktop, blocks 1 and 2 sit side by side at the top. On a phone, they stack in the order above.

## Quick actions
`+ Séance`, `+ Devoir`, `+ Quiz`, `+ Série`, `+ Élève`, `Importer un document`.
- Desktop: a row of buttons under the greeting.
- Phone: one floating `+ Créer` button that opens the same list.
- Each action opens a **modal or side panel**. After saving, the teacher stays on Ma journée and the blocks refresh.

## "À surveiller" rules (defaults, adjustable later)

| Rule | Default threshold | Reason chip |
|---|---|---|
| Missing work | 2 or more assignments "Manquant" in the last 30 days | "2 devoirs manquants" |
| Absences | 2 or more absences in the student's last 5 sessions | "2 absences récentes" |
| Grades dropping | average of the last 3 grades at least 3 points (/20) below the average of the grades before them, in the same subject | "Notes en baisse en Math" |

A student can show several chips. Clicking a student opens their profile.

## Empty states (copy)

| Block | Text |
|---|---|
| Aujourd'hui | "Aucune séance aujourd'hui." + `Planifier une séance` |
| À corriger | "Rien à corriger. Bonne journée !" |
| Travail manquant | "Tous les devoirs sont rendus." |
| À surveiller | "Aucun élève à surveiller pour le moment." |
| À venir | "Rien de prévu dans les 7 prochains jours." |

## Acceptance criteria
- [ ] Today's sessions are sorted by start time. Finished sessions are shown dimmed with their status; cancelled ones are struck through.
- [ ] `Rejoindre` appears only for online sessions with a link, from 15 minutes before the start until the end.
- [ ] `Démarrer la séance` opens session mode for that session (spec 03).
- [ ] Clicking an "À corriger" item opens the correction screen on that exact submission.
- [ ] After a correction is saved and the teacher comes back, the count is updated without a manual refresh.
- [ ] "Travail manquant" lists each assignment once, with its missing students underneath.
- [ ] Every block has loading, empty and error states; an error in one block does not hide the others.
- [ ] The screen loads in under 2 seconds on 4G with 150 students (one aggregated API call, see `06-API_OUTLINE.md`).
