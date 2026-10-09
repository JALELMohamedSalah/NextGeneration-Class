# Spec 10. Parent space

Priority: **M** · Release R1 (planning, attendance), R2 (Cours, assignments, grades)

## Goal
A parent understands their child's situation **in less than one minute**, without learning the app.

## Navigation
`Aperçu` · `Cours` · `Planning` · `Notifications`. A child switcher at the top when the parent follows several children.

## Aperçu (one screen per child)

```
Ahmed · Math
Prochaine séance      Mardi 17:00, en ligne
Devoirs               3 rendus sur 4 · 1 manquant : "Série 02"
Dernière note         14/20 (Devoir Fractions), commentaire de l'enseignante
Moyenne               15,25 / 20  ↑
Présence              95 %  (1 absence ce mois-ci)
```

- One card per subject followed by the child.
- Tapping a card opens details: list of assignments with status, list of grades with comments, attendance history.
- Teacher comments and announcements for parents appear under the cards.

## Cours
User decision 2026-10-06: most pupils have no login of their own, so the parent opens the documents shared with the child's groups (the same list as the pupil's Cours, spec 09), reads them in the app and downloads or prints them. Opening a document takes "Nouveau" off for the parent only.

## Planning
The child's upcoming sessions, with cancellations and their reasons. No Meet links.

## Notifications
Absence, missing work, new grade, session cancelled or moved, announcements, weekly summary (S).

## Never shown to parents
- Private notes and session notes
- Other students (names, grades, rosters)
- The teacher's internal workflow: drafts, correction queue, unreleased model answers
- Meet links

## Acceptance criteria
- [ ] A parent with two children switches between them in one tap and never sees mixed data.
- [ ] The Aperçu fits on one phone screen per subject without horizontal scrolling.
- [ ] Every number matches what the teacher sees on the student profile.
- [ ] A parent account linked to an archived child no longer shows that child.
