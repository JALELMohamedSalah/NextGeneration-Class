# Delivery 03. Rules for developers and coding agents

## Before writing code
1. Read `README.md`, the glossary and the spec file of the module you work on.
2. Inspect the existing code and respect its architecture.
3. Reuse existing components and services before creating new ones.
4. Do not rewrite existing business logic without a reason written in the PR.

## Product rules (never break)
1. Several teachers, each in her own space (user decision 2026-10-06, `V6__teachers.sql`). Every teacher query is scoped to the signed-in teacher; another teacher's data answers 404. The owner (admin) adds teachers and sees accounts and counts only, never inside a space.
2. No payment feature of any kind.
3. No marketplace, no public catalog.
4. No custom video conferencing: Meet links only.
5. AI stays optional; AI output is never published or assigned automatically.
6. No paid service or paid-license package without written approval (`02-COST.md`).
7. Private notes never reach a student or parent account.
8. Use the glossary vocabulary in code, UI and documents.
9. No hardcoded user-facing text: French and Arabic come from the ARB files (app) and `messages*.properties` (server). Layouts must work right to left.
10. Design first: new screens are mocked in the approved style (`docs/00-brand/ui/`) and approved by the user before they are coded.
11. Every input shows a hint (an example or what to type), in French and Arabic. Never an empty box (user rule 2026-10-06).

## Technical rules
- Flutter structure: `data/` (dto, remote, repository), `domain/` (model, repositories), `view/` (stateManager, screens, widgets). See `03-conception/01-ARCHITECTURE.md`.
- State with Cubit. No business logic in widgets; widgets never call the API directly.
- Business rules (statuses, scores, averages, visibility) live on the server; the app displays them.
- Permission checks on the server in every service method.
- Separate DTOs for teacher, student and parent responses.
- Database changes only through Flyway migrations.
- Times stored in UTC, shown in Africa/Tunis.
- All UI strings in localization files, in French and Arabic (same keys).
- Avoid unnecessary dependencies; check license and maintenance before adding one.

## UI rules
- Simple and professional; teacher productivity first.
- Common actions in one tap; creation in modals or side panels.
- Look and components from `00-brand/UI_DESIGN_SPEC.md` (approved design); colors and fonts from `00-brand/BRAND.md`.
- Copy: short plain French sentences, "vous", verbs on buttons, no long dashes.
- No excessive animations.

## Workflow
- Build one release at a time, in the order of `01-RELEASE_PLAN.md`.
- One feature per pull request, with screenshots for UI changes.
- Each release ends with a demo and real use before the next one starts.

## Definition of done
A feature is done only when:
- [ ] The UI is implemented on the target platforms (desktop for teacher screens, phone for student and parent screens)
- [ ] The business logic works and follows `03-BUSINESS_RULES.md`
- [ ] Loading, empty and error states exist
- [ ] Validation exists where needed, with clear French messages
- [ ] Role permissions are enforced on the server and tested
- [ ] Data is persisted correctly
- [ ] The architecture is respected
- [ ] No unapproved paid dependency was added
- [ ] The acceptance criteria of the spec file are checked
- [ ] The teacher's workflow stays short (count the clicks)
