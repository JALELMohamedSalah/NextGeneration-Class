# Conception 06. API outline

REST, JSON, base path `/api/v1`. Authentication with a JWT access token and a refresh token. Every request carries `Accept-Language: fr` or `ar`; error messages come back in that language. Implemented today (R0): `/auth/login`, `/auth/refresh`, `/auth/logout`, `/me`, `/me/password`, `/me/language`, `/users/{id}/reset-password`, `/reference` (see `docs/HANDOVER.md`). Roles: **T** teacher, **S** student, **P** parent. "own" means the student's own data or the parent's children's data; the server checks it on every call.

## Auth and account

| Method | Path | Who | Purpose |
|---|---|---|---|
| POST | `/auth/login` | all | username or phone + password |
| POST | `/auth/refresh` | all | new access token |
| POST | `/auth/logout` | all | revoke refresh token |
| POST | `/me/password` | all | change own password |
| GET | `/me` | all | profile, role, children (parent) |
| PUT | `/me/language` | all | `fr` or `ar`, the language of server messages (also set at login) |
| PUT | `/me/notification-preferences` | all | mute categories |
| POST | `/me/devices` | all | register a push token |

## Dashboards (one call per home screen)

| Method | Path | Who | Returns |
|---|---|---|---|
| GET | `/dashboard/teacher` | T | today, toCorrect (count + 5), missing, attention, upcoming |
| GET | `/dashboard/student` | S | next session, todo, new documents, latest results, announcements |
| GET | `/dashboard/parent/{studentId}` | P own | next session, per-subject indicators, missing work, latest grades, comments |

## People and groups

| Method | Path | Who |
|---|---|---|
| GET, POST | `/students` | T |
| GET, PUT | `/students/{id}` | T (S own: limited view) |
| POST | `/students/{id}/archive`, `/students/{id}/restore` | T |
| POST | `/users/{id}/reset-password` | T (students and parents; returns a temporary password) |
| GET | `/reference` | all (subjects, levels, current school year, names in fr and ar) |
| POST | `/students/import` (CSV, preview then confirm) | T |
| GET, POST | `/parents`, PUT `/parents/{id}` | T |
| GET, POST, PUT | `/students/{id}/private-notes` | T only |
| GET, POST | `/students/{id}/comments` | T write, S/P own read |
| GET | `/students/{id}/progress?schoolYear=` | T, S own, P own |
| GET, POST | `/groups`, GET, PUT `/groups/{id}` | T (S/P: name and schedule of own groups) |
| PUT | `/groups/{id}/members` | T |
| GET, POST | `/school-years`, `/subjects`, `/levels` | T (read: all) |

## Planning

| Method | Path | Who |
|---|---|---|
| GET | `/sessions?from=&to=&groupId=` | T all, S/P own |
| POST | `/sessions` | T |
| PUT | `/sessions/{id}?scope=one` (or `following`) | T |
| POST | `/sessions/{id}/cancel?scope=one` (or `following`) | T |
| POST | `/sessions/{id}/start`, `/sessions/{id}/end` | T |
| PUT | `/sessions/{id}/attendance` | T |
| PUT | `/sessions/{id}/notes` | T |
| GET, POST, PUT, DELETE | `/groups/{id}/recurrence-rules` | T |

## Content

| Method | Path | Who |
|---|---|---|
| GET, POST | `/chapters`, PUT `/chapters/{id}` | T (S: shared only) |
| GET | `/content?type=&chapterId=&status=&q=` | T |
| POST | `/content` (lesson, exercise, series, quiz, worksheet) | T |
| GET, PUT | `/content/{id}` | T (S: if visible, without answers before release) |
| POST | `/content/{id}/publish`, `/duplicate`, `/archive` | T |
| POST | `/files` (multipart upload) | T, S (for submissions) |
| GET | `/files/{id}/url` (short-lived signed link) | anyone allowed to read the owner |
| GET, POST, DELETE | `/shares` | T |
| GET | `/me/courses` | S |

## Work

| Method | Path | Who |
|---|---|---|
| GET, POST | `/assignments` | T (S: `/me/assignments`) |
| GET, PUT | `/assignments/{id}` | T |
| POST | `/assignments/{id}/remind` | T |
| GET | `/me/assignments?status=` | S |
| POST | `/assignments/{id}/attempts` (start quiz) | S |
| PUT | `/submissions/{id}/answers` (autosave) | S own |
| POST | `/submissions/{id}/submit` | S own |
| GET | `/corrections/queue?groupId=&subjectId=` | T |
| GET | `/submissions/{id}` | T, S own |
| PUT | `/submissions/{id}/correction` | T |
| GET, POST | `/groups/{id}/evaluations`, PUT `/evaluations/{id}/grades` | T |
| GET | `/students/{id}/grades` | T, S own, P own |

## Communication

| Method | Path | Who |
|---|---|---|
| GET, POST | `/announcements` | T (S/P: `/me/announcements`) |
| GET | `/me/notifications?unread=` | all |
| POST | `/me/notifications/{id}/read`, `/me/notifications/read-all` | all |

## Conventions
- Pagination: `?page=&size=`, response `{ items, page, size, total }`.
- Errors: `{ code, message, details }`, message in French for display.
- Dates in ISO 8601 UTC; the app displays them in Africa/Tunis.
- Student and parent DTOs are separate classes from teacher DTOs, so private fields cannot leak by mistake.
