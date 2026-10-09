# Spec 03. Planning, sessions, Google Meet and attendance

Priority: **M** · Release R1 (end-of-session workflow: S, R4)

## User stories
- As the teacher, I set a group's weekly schedule once and the sessions appear for the whole year.
- As the teacher, I cancel or move one session without breaking the rest.
- As the teacher, I paste a Meet link once per group.
- As the teacher, I start a session and take attendance in a few seconds.
- As the teacher, I end a session by noting what was covered and, if needed, giving homework.
- As a student, I see my next sessions and join the online ones with one tap.
- As a parent, I see my child's next session and their attendance.

## Session

| Field | Note |
|---|---|
| Groupe | required (a private lesson is a group) |
| Date, heure de début, heure de fin | required |
| Mode | `Présentiel` or `En ligne` |
| Lieu | for in-person sessions, optional |
| Lien visio | for online sessions; pre-filled from the group; any `https://` link is accepted (Meet by default) |
| Notes de préparation | private |
| Statut | `Prévue`, `En cours`, `Terminée`, `Annulée` |

## Recurring sessions
- Rule: weekday, start time, end time, mode, start date, end date (default: end of the school year).
- Sessions are generated from the rule and can be changed one by one.
- Editing a recurring session asks: `Cette séance uniquement` or `Cette séance et les suivantes`.
- Cancelling works the same way, with an optional reason shown to students and parents.
- Changing the group's default Meet link updates future sessions that do not have their own link.
- Overlapping sessions show a warning but are allowed.

## Calendar views
- Day and week views (month view: S).
- Sessions colored by subject or group, status shown by style (dimmed when finished, struck through when cancelled).
- Click on an empty slot opens `+ Séance` pre-filled with that time.

## Google Meet
No video feature is built. The app stores the link and opens it in the browser or the Meet app.
- Teacher sees `Démarrer la séance` (opens session mode) and `Ouvrir Meet`.
- Student sees `Rejoindre la séance` from 15 minutes before the start until the end.
- Parents do not see the link.

## Session mode (`Démarrer la séance`)
A focused screen, usable on a laptop next to Meet or on a tablet in class:
- **Présences**: the roster of the group, everyone `Présent` by default. One tap switches a student to `Absent`, a second tap to `En retard`, a third back to `Présent`.
- **Contenu du jour**: the chapter and items planned for this session, open in one click (PDF viewer, lesson, quiz).
- **Dernière séance**: the note written at the end of the previous session of this group.
- **Note rapide**: a text field saved automatically.
- **Lien Meet** for online sessions.
- `Terminer la séance`.
The session status becomes `En cours` when the screen opens and `Terminée` when it ends.

## End of session (S, R4)
One short form after `Terminer la séance`:
1. Confirm attendance (pre-filled)
2. `Ce qui a été vu`: pick a chapter and items (used for the student's "Cours" and the session history)
3. `Note de séance`: private
4. Optional `Donner un devoir`: opens the assignment form pre-filled with the group and today's chapter
5. Optional `Planifier la prochaine séance`: hidden when the session is recurring

Before R4, `Terminer la séance` only confirms attendance and the note.

## Attendance
- Values: `Présent`, `Absent`, `En retard`.
- Can be edited later from the session detail.
- Statistics per student: attendance %, number of absences, number of late arrivals (formulas in `03-BUSINESS_RULES.md`).
- When attendance is saved, parents of absent students receive a notification (Q8).

## Notifications triggered
- Session in 30 minutes: teacher and students.
- Session cancelled or moved: students and parents, immediately.
- Absence recorded: parents.

## Acceptance criteria
- [ ] A weekly rule from today to the end of the school year creates every session at the right local time (Africa/Tunis).
- [ ] Editing "this session only" changes one session; "this and following" changes all future ones and keeps past ones.
- [ ] Cancelling a session notifies the students and parents of the group and shows the reason.
- [ ] Attendance for a group of 8 with 1 absent student takes 2 taps after opening session mode.
- [ ] A student never sees the Meet link of a group they are not in.
- [ ] The `Rejoindre` button appears and disappears at the right times.
- [ ] Session mode works side by side with a Meet window on a 1366 x 768 laptop screen.
