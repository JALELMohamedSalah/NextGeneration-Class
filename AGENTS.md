# NextGeneration Class · rules for coding agents

Private platform for one **primary school** teacher in Tunisia (1ère to 6ème année, her own groups and private lessons), her pupils and their parents. She creates her subjects herself; a child's own login is optional (parents follow). Several teachers can use it, each in her own space: the platform owner (admin) adds them from the dashboard and only sees accounts and counts. Flutter app + Spring Boot API + PostgreSQL.

**Start here**: `docs/HANDOVER.md` (status, how to run, decisions, next tasks). For any UI work: `docs/00-brand/UI_DESIGN_SPEC.md` and `docs/00-brand/ui/screens/`.

## Never
- Payments, marketplace, custom video (Meet links only).
- A teacher reaching another teacher's data: every teacher query is scoped to the signed-in teacher (V6), and the owner never sees inside a space.
- Hardcoded user-facing text. The app speaks **French and Arabic only**: strings in `app/lib/l10n/app_fr.arb` + `app_ar.arb` (same keys), server messages in `backend/src/main/resources/i18n/messages*.properties` (keys `error.<code>`), reference data with `name_fr` / `name_ar`.
- `left` / `right` in Flutter layout: use directional insets and alignments (Arabic is right to left).
- Long dashes in UI copy.
- A paid service or paid-license package without the user's written approval (`docs/04-delivery/02-COST.md`).
- Publishing AI output automatically (AI is a later, optional module).
- Committing or pushing without the user asking. Repository: github.com/ramilaribi/NextGeneration-Class (public: no secret ever goes in). GitHub account: **ramilaribi** only.
- Shortening sessions: refresh tokens last 365 days, extended on use (user decision).

## Always
- Design first: a new screen family is mocked in the approved style and approved by the user before Flutter code.
- Flutter: `lib/data` (dto, remote, repository) · `lib/domain` (model, repositories) · `lib/view` (stateManager = Cubits, screens, widgets). No business logic or API calls in widgets. DI through `sl` in `core/di/injection.dart`.
- Backend: package per feature (`auth`, `people`, `school`, ...), tabs for indentation, Lombok entities, records for DTOs, `ApiException(status, code, args...)` for refusals, Flyway for every schema change, permission checks on the server.
- Loading, empty and error states on every screen; check French and Arabic, desktop and phone.
- Every input shows a hint (an example or what to type), never an empty box: `hint` is required on `FormInput`, `AppTextField`, `PasswordField`, `SelectField`, `SearchBox`.
- Tests stay green: `cd backend && mvn test` (Docker needed), `cd app && flutter analyze && flutter test`.
- Update `docs/HANDOVER.md` at the end of each task.

## Commands
```bash
docker compose -f infra/docker-compose.dev.yml up -d   # DB on 5433
cd backend && mvn spring-boot:run                       # API on 8080 (needs backend/.env, see .env.example)
cd app && flutter run -d chrome
```
Dev test accounts: usernames in `backend/src/main/resources/application-dev.yaml`, passwords in `backend/.env` (git-ignored; never paste them in chat, never commit them).
