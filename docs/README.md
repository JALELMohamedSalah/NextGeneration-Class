# NextGeneration Class

**Private teaching platform for primary school teachers, their pupils and the pupils' parents.**
*Enseigner, suivre, progresser.*

| | |
|---|---|
| Status | Releases 0 to 2 built and tested; Release 3 next (see [HANDOVER.md](HANDOVER.md)) |
| Date | 2026-10-09 |
| Source | Client spec v1 (`99-source/client_spec_v1.md`, kept out of the public repository), refined and completed |
| UI language | French and Arabic (right to left) |

## The product in one paragraph

NextGeneration Class is a private app for primary school teachers in Tunisia (1ère to 6ème année, their own groups and private lessons). It tells the teacher what has to be done today, keeps the planning and attendance, stores and reuses the course material, sends homework and quizzes, and puts every correction in one queue. Students see their sessions, their work and their results. Parents see a one-minute summary of their child. There is no marketplace and no payment, running costs stay close to zero, and the app is fully useful without AI.

## How to read this folder

| Folder | For whom | Content |
|---|---|---|
| `00-brand/` | client, designer | name, colors, fonts, logo brief, Gemini prompts |
| `01-product/` | client, everyone | vision, scope, roles, glossary, open questions |
| `02-specification/` | client, developer | one file per module: user stories, rules, acceptance criteria |
| `03-conception/` | developer | architecture, data model, business rules, flows, screens, API |
| `04-delivery/` | client, developer | release plan, cost, development rules, changes from v1 |
| `99-source/` | reference | the original client spec, unchanged (local only, git-ignored) |

Start with `01-product/01-VISION.md`, then answer `01-product/05-OPEN_QUESTIONS.md` with the client. Developers and coding agents: start with [HANDOVER.md](HANDOVER.md).

## File index

**Brand**
- [BRAND.md](00-brand/BRAND.md): name, tagline, voice, colors, typography, logo system
- [LOGO_PROMPTS_GEMINI.md](00-brand/LOGO_PROMPTS_GEMINI.md): ready-to-paste Gemini prompts and the logo workflow
- [ui/](00-brand/ui/README.md): **approved UI design** (screenshots and mockups)
- [UI_DESIGN_SPEC.md](00-brand/UI_DESIGN_SPEC.md): how to build the approved design in Flutter

**Handover**
- [HANDOVER.md](HANDOVER.md): project status, how to run, decisions, next tasks
- [NEXT_AGENT_PROMPT.md](NEXT_AGENT_PROMPT.md): prompt to start the next coding session

**Product**
- [01-VISION.md](01-product/01-VISION.md): problem, product principle, success test, measurable goals
- [02-SCOPE.md](01-product/02-SCOPE.md): what is in the MVP, what is never built, what comes later
- [03-ROLES_PERMISSIONS.md](01-product/03-ROLES_PERMISSIONS.md): roles, accounts, permission matrix
- [04-GLOSSARY.md](01-product/04-GLOSSARY.md): the vocabulary everyone must use
- [05-OPEN_QUESTIONS.md](01-product/05-OPEN_QUESTIONS.md): questions for the client, with recommended defaults

**Specification**
- [01-teacher-home.md](02-specification/01-teacher-home.md): "Ma journée" dashboard
- [02-students-groups.md](02-specification/02-students-groups.md): students, parents, groups, private notes
- [03-planning-sessions-attendance.md](02-specification/03-planning-sessions-attendance.md): calendar, recurring sessions, Meet, session mode, attendance
- [04-content-library.md](02-specification/04-content-library.md): library, chapters, uploads, share, duplicate
- [05-builders-worksheets.md](02-specification/05-builders-worksheets.md): formula editor, lesson, exercise, series, quiz, QCM, PDF worksheets
- [06-assignments-correction.md](02-specification/06-assignments-correction.md): assignments, submissions, correction queue, evaluations
- [07-grades-progress.md](02-specification/07-grades-progress.md): grades, averages, progress
- [08-announcements-notifications.md](02-specification/08-announcements-notifications.md): announcements, comments, notifications, reminders
- [09-student-space.md](02-specification/09-student-space.md): what the student sees and does
- [10-parent-space.md](02-specification/10-parent-space.md): what the parent sees
- [11-ai-assistant.md](02-specification/11-ai-assistant.md): later, optional

**Conception**
- [01-ARCHITECTURE.md](03-conception/01-ARCHITECTURE.md): system overview, stack decision, Flutter and backend structure
- [02-DATA_MODEL.md](03-conception/02-DATA_MODEL.md): entities, fields, relationships
- [03-BUSINESS_RULES.md](03-conception/03-BUSINESS_RULES.md): statuses, formulas, visibility, edge cases
- [04-USER_FLOWS.md](03-conception/04-USER_FLOWS.md): the main flows as diagrams
- [05-SCREENS_NAVIGATION.md](03-conception/05-SCREENS_NAVIGATION.md): screen inventory, navigation, layouts
- [06-API_OUTLINE.md](03-conception/06-API_OUTLINE.md): REST resources and who can call them
- [07-NON_FUNCTIONAL.md](03-conception/07-NON_FUNCTIONAL.md): platforms, language, privacy, performance, backups

**Delivery**
- [01-RELEASE_PLAN.md](04-delivery/01-RELEASE_PLAN.md): four releases, each usable on its own
- [02-COST.md](04-delivery/02-COST.md): what is really free and what is not
- [03-DEV_RULES.md](04-delivery/03-DEV_RULES.md): rules for developers and coding agents, definition of done
- [04-CHANGES_FROM_V1.md](04-delivery/04-CHANGES_FROM_V1.md): what changed compared to the client's first spec

## Key decisions

1. Several teachers, each in a separate space, added by the owner from a small dashboard. Three roles inside a space: teacher, pupil, parent. A child's own login is optional.
2. No payments, no marketplace, no video conferencing (Google Meet links only).
3. One Flutter codebase: web for the teacher, Android and web for students and parents.
4. Backend: Spring Boot and PostgreSQL, to run on a small VPS. Everything stays local until the very last step.
5. Vocabulary is fixed in the glossary: Chapitre, Devoir, Quiz (a QCM is a quiz preset), Corrigé versus Correction.
6. Four releases, each one usable by the teacher on its own.
7. AI is a later, optional module. AI content is never published automatically.

13 questions are still open with the client: see [05-OPEN_QUESTIONS.md](01-product/05-OPEN_QUESTIONS.md).
