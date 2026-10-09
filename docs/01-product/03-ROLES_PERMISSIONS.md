# 03. Roles and permissions

## Roles

Four roles. Since 2026-10-06 (user decision) **several teachers** can use the platform, each in her own space; the **owner** of the platform adds them.

| Role | Who | Main device (to confirm, Q1) |
|---|---|---|
| **Owner** (Administrateur) | the platform owner: adds teachers, resets their password, closes or reopens their access; sees accounts and counts only, never inside a space | laptop (web) |
| **Teacher** (Enseignante) | runs her own space: her subjects, groups, pupils and parents | laptop (web), tablet |
| **Student** (Élève) | enrolled pupils, 1ère to 6ème année; own login optional (the teacher opens it) | Android phone, web (often the parent's) |
| **Parent** | one or two parents per student | Android phone, web |

## Accounts

- **No self sign-up.** The owner creates every teacher account; each teacher creates her own students and parents.
- Login with **username or phone number + password**. Young students often have no email address, so email is never required for students. *(Q4)*
- After creating an account, the app shows the username and a temporary password once, with a `Copier` button. The teacher sends them through her usual channel (WhatsApp, paper). No SMS is sent by the app (SMS is paid).
- The teacher can reset any password (a new temporary password is generated).
- First login asks the user to choose a new password (S).
- A parent can follow **several children** and switches between them.
- A child can have **up to two parents**.
- A student can belong to **several groups** (for example a Maths group and a private reading lesson).
- **Archiving** a student disables their login and keeps their history. A parent account is disabled when all of its children are archived.

## Permission matrix

| Capability | Teacher | Student | Parent |
|---|---|---|---|
| Manage students, parents, groups | ✅ | | |
| Reset passwords | ✅ | | |
| Create, edit, cancel sessions | ✅ | | |
| See sessions | all | own groups | child's groups |
| Join an online session | ✅ | ✅ | |
| Mark attendance | ✅ | | |
| See attendance | all | own | child's |
| Create, edit, duplicate, archive content | ✅ | | |
| Share content, assign work | ✅ | | |
| See shared content and documents | all | own groups | |
| Submit work, take quizzes | | ✅ | |
| See the correction queue | ✅ | | |
| Correct and grade, record evaluations | ✅ | | |
| See grades and corrections | all | own | child's |
| See model answers (corrigés) | all | when released | |
| See progress | all | own | child's |
| Write comments (feedback) | ✅ | | |
| Read comments | all | own | child's |
| **Private notes** | ✅ | **never** | **never** |
| Send announcements | ✅ | | |
| Read announcements | all | targeted | targeted |
| See other students | ✅ | **never** | **never** |
| See drafts, archived items, the correction queue | ✅ | never | never |
| Settings | all settings | own password, notification preferences | own password, notification preferences |

## Enforcement rules

- Permissions are checked **on the server** for every request. Hiding a button in the UI is not a permission.
- A student or parent request only ever returns data linked to that student (or to the parent's children).
- Private notes and teacher-only fields (drafts, session notes, quiz correct answers before release) are **never** included in student or parent responses, not even hidden.
- Files are downloaded through short-lived links generated after a permission check.
