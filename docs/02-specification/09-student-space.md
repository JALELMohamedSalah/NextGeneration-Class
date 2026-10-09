# Spec 09. Student space

Priority: **M** · Release R1 (Accueil, Planning), R2 (Cours, Devoirs, Résultats)

## Goal
A student opens the app and knows what to do next. Simple enough for a 7-year-old reading with a parent, not childish for a 12-year-old. Most pupils have no login: their parents follow.

## Navigation
`Accueil` · `Cours` · `Devoirs` · `Planning` · `Résultats` (bottom bar on phones, side rail on desktop). Notifications from a bell icon in the top bar.

## Screens

**Accueil**
- Next session card: day, time, subject, group, `Rejoindre la séance` when online and within 15 minutes of the start.
- `À faire`: assignments sorted by deadline, deadline shown as "Demain 18:00" or "Dans 3 jours", red when overdue.
- New documents shared since the last visit.
- Latest results (3).
- Latest announcements.

**Cours**
- Subjects, then chapters shared with the student's groups, then items (lessons, documents, worksheets).
- PDF viewer and lesson reader in the app; download button.

**Devoirs**
- Tabs `À faire`, `Rendus`, `Corrigés`.
- Assignment screen: instructions, content, deadline, status, submission (photos/files) or quiz player.
- After correction: score, comment, corrected file, and the model answer once released.

**Planning**
- Upcoming sessions as a list grouped by day; cancelled sessions shown with the reason.

**Résultats**
- Per subject: average, completion, attendance, trend, list of grades with comments.
- Simple grade chart (R4).

## Rules
- The student sees only their own data and items shared with or assigned to them.
- No private notes, and no other students: students never see a group roster, names or grades of classmates.
- Settings: change password, notification preferences (S), log out.

## Acceptance criteria
- [ ] From the home screen, a student reaches the submission screen of their most urgent assignment in 1 tap.
- [ ] Photo submission works with the phone camera and the gallery.
- [ ] A lost connection during a quiz does not lose the answers given so far.
- [ ] The whole space is usable on a 360 px wide Android phone.
