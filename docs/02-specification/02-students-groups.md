# Spec 02. Students, parents and groups

Priority: **M** · Release R1 (CSV import: S, R2)

## User stories
- As the teacher, I add a student and their parents in one form and get their login details to send them.
- As the teacher, I put a student in one or more groups.
- As the teacher, I create a private lesson for one student.
- As the teacher, I open a student's profile and see everything about them on one screen.
- As the teacher, I write private notes about a student that nobody else can read.
- As the teacher, I archive a student who stopped, without losing their history.

## Student form

| Field | Required | Note |
|---|---|---|
| Prénom, Nom | yes | |
| Niveau | yes | from the level list |
| Téléphone | no | can be used as login |
| Identifiant | yes | generated as `prenom.nom`, editable, unique |
| Groupes | no | multi-select |
| Parents | no | pick existing parents or add new ones (up to 2) |

## Parent form

| Field | Required | Note |
|---|---|---|
| Prénom, Nom | yes | |
| Téléphone | yes | used as login by default |
| Email | no | needed only for the weekly summary email |
| Enfants | yes | at least one student |

## Login details
After saving, a card shows each new account's username and temporary password with `Copier` and `Copier le message` (a ready-to-send French text with the app link). The password is never shown again. `Réinitialiser le mot de passe` on the profile creates a new temporary one.

## Groups

| Field | Note |
|---|---|
| Nom | e.g. "4ème année · Maths" |
| Matière, Niveau | required |
| Élèves | multi-select |
| Horaire habituel | optional weekly rule; creates recurring sessions (spec 03) |
| Lien Meet par défaut | optional, used by every online session of the group |
| Couleur | for the calendar, defaults to the subject color |

**Private lessons**: on a student profile, `Créer un cours particulier` asks only for the subject and schedule and creates a group named "Prénom Nom · Matière" marked as private. Private groups are listed under a separate "Cours particuliers" filter.

## Student profile

| Section | Content |
|---|---|
| Header | name, level, groups, parents with phone numbers, `Modifier`, `Archiver` |
| Résumé | per subject: average /20, assignment completion %, attendance % |
| Prochaines séances | next 3 sessions |
| Devoirs | assignments with status, filter by status |
| Notes | latest grades, link to all |
| Présences | last 10 sessions with status, totals |
| Commentaires | feedback visible to student and parents, `Ajouter` |
| Notes privées | teacher only, dated, newest first, `Ajouter` |
| Activité récente | last submissions, logins, attendance changes |

## Private notes
- Free text, dated, editable and deletable by the teacher.
- Shown with a lock icon and the label "Visible par vous uniquement".
- Never returned by any student or parent API.

## Archive
- Archived students cannot log in, disappear from lists and assignment targets, and keep all their data.
- Filter `Archivés` shows them; `Restaurer` brings them back.
- A parent account is disabled when all of its children are archived.
- Hard delete is not offered in the UI.

## CSV import (S)
Columns: prénom, nom, niveau, téléphone, groupe, parent prénom, parent nom, parent téléphone. A preview shows each row as OK or with its error before anything is created. At the end, a list of all login details can be copied or printed.

## Acceptance criteria
- [ ] Creating a student with one new parent creates two accounts and shows both login details once.
- [ ] Usernames are unique; a duplicate gets a suffix (`prenom.nom2`) and the teacher can edit it.
- [ ] A student can be in several groups; a group can be private (one student) or normal.
- [ ] The profile shows the same averages and percentages as the parent space (same formulas, `03-BUSINESS_RULES.md`).
- [ ] Private notes never appear in a student or parent response (checked by an API test).
- [ ] Archiving asks for confirmation and can be undone.
