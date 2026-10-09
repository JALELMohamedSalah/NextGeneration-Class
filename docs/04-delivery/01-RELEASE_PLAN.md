# Delivery 01. Release plan

Four releases. Each one is usable by the teacher on its own, and the home screen grows with each release.

Why not the client's v1 order: v1 built the dashboard first, before anything could feed it, and built the student app in phase 5 while submissions came in phase 3 (they cannot be used or tested without students).

Effort is indicative, for one experienced Flutter and Spring Boot developer, and depends on the answers to the open questions.

## Release 0: Foundations (about 1 week)
- Repositories, CI, Flutter project with brand theme (colors, fonts, logo), router and three role shells
- Spring Boot project, PostgreSQL, Flyway, Docker Compose, Caddy HTTPS on the VPS
- Auth: login, refresh, roles, password reset by the teacher
- Seed: teacher account, subjects, levels, current school year

## Release 1: "Organize my week" (about 3 weeks)
**Scope**
- Students, parents, groups, private lessons, login details card
- Private notes and comments on students
- Planning: day and week views, recurring sessions, edit and cancel with scope
- Meet links, `Rejoindre` and `Démarrer` buttons
- Session mode with one-tap attendance, attendance statistics
- Ma journée v1: today, tomorrow
- Student: Accueil (next session), Planning
- Parent: Aperçu (next session, attendance), Planning
- In-app notifications for cancelled or moved sessions

**Demo at the end**: the teacher enters her real groups and schedule, runs a week of sessions with attendance, and parents see attendance.

## Release 2: "Share and collect work" (about 4 to 5 weeks)
**Scope**
- Content library: chapters, uploads, camera scan to PDF, PDF viewer, share with a group
- Assignments with file submissions, statuses, `Manquant` job
- Correction queue and correction screen, evaluations, grades on /20
- Student: Cours, Devoirs, Résultats
- Parent: assignments, grades, comments
- Ma journée v2: À corriger, Travail manquant, deadlines
- Notification center for all roles
- CSV student import (S)

**Demo at the end**: the teacher uploads an existing series, assigns it, students send photos, she corrects them in a row, parents see the grade.

## Release 3: "Create faster" (about 4 weeks)
**Scope**
- Formula editor and rendering
- Exercise and series builder, lessons (S)
- Quiz builder with 5 question types, auto-correction, QCM preset with fast entry, student preview
- Quiz player for students (autosave, timer)
- Duplicate content
- PDF worksheets, student and teacher versions

**Demo at the end**: the teacher creates a 10-question QCM with fractions in under 10 minutes, students take it, scores appear automatically; she prints a revision sheet.

## Release 4: "Communication" (trimmed 2026-10-09, user decision)
**Scope**
- Announcements
- End-of-session workflow (covered content, homework, next session)
- Progress charts (S)
- Android release build and store listing (if Q1 confirms Android)

**Not now** (user decision 2026-10-09: "no notifications and alerting for now"): push notifications (FCM) and email, reminders, quiet hours, grouping, morning digest, "À surveiller" rules and card, "Relancer", absence alerts, weekly parent summary, notification preferences. The in-app notification centers already built (families' bell and tab, the teacher's bell) stay.

**Demo at the end**: a full week where the teacher only uses the app: sessions, homework, quizzes, corrections, announcements.

## Later
AI assistant (content help only: drafts of series, QCM and corrigés, never published by itself; user decision 2026-10-09), OCR, Google Calendar sync, two-way messaging, advanced reports, iOS store app, dark mode, offline mode.

## Summary

| Release | Theme | Indicative effort |
|---|---|---|
| R0 | Foundations | 1 week |
| R1 | Organize my week | 3 weeks |
| R2 | Share and collect work | 4 to 5 weeks |
| R3 | Create faster | 4 weeks |
| R4 | The assistant | 2 to 3 weeks |
| **Total MVP** | | **about 14 to 16 weeks** |

Each release ends with a demo to the client and a short test period with real use before the next one starts.
