# Prompt for the next coding session

Copy everything inside the block into a new Claude Code session opened on `~/Desktop/NextGenerationClass`.

```text
You are continuing NextGeneration Class, a private platform for primary school teachers in Tunisia (1ère to 6ème année, their own groups and private lessons), their pupils and the parents. Several teachers can use it, each in her own space; the platform owner (admin) adds them from a dashboard. Monorepo at ~/Desktop/NextGenerationClass: Flutter app in app/, Spring Boot API in backend/, docs in docs/, infra in infra/.

Read first, in this order:
1. CLAUDE.md (rules that never bend)
2. docs/HANDOVER.md (status, how to run, decisions, next tasks, things to know)
3. docs/00-brand/UI_DESIGN_SPEC.md (how to build the approved design)
4. The mockups in docs/00-brand/ui/screens/r1/ and r2/, and the app screenshots in docs/00-brand/ui/flutter/r1/ and r2/

Where things stand: Release 0, Release 1 and Release 2 steps 1 to 5 are built and tested: students, groups, planning, attendance, notifications, Paramètres, the polished student space, several teachers each in her own space with the owner dashboard, every input with a hint, Contenus (the teacher's library: chapters, uploads, sharing, a full-screen viewer) with the Cours tab for pupils and parents, the camera scan of paper sheets into one PDF made on the device, and Devoirs (the teacher gives a published document to a group or some pupils with a deadline; the pupil, or a parent for the child, sends photos as one PDF or a file; "Manquant" after the deadline; the teacher opens each work), and correction (the "À corriger" queue, the correction screen with "Enregistrer et suivant", scores in half points, comments, corrected copies, Résultats for pupils and parents, Ma journée's "À corriger" and "Travail manquant"), and the follow-ups of 2026-10-08 (the Fiche élève Moyenne with the pupil's results, session mode's Contenu du jour, Créer › Importer from anywhere, the parent's Mot de l'enseignante), and the teacher's notifications (a bell with the unread count: work sent gathered by homework, each deadline with who did not send), and pupil and parent pages that fill a computer screen (cards two by two), paper evaluations (a fourth Devoirs tab, a keyboard score table, grades counted in Résultats, "Absent" never 0), importing a class from Excel or CSV (check every line, then all at once, login cards to print), the search of the top bar, and "Copier le lien" beside Meet links. Release 2 is complete (backend 55 integration tests, app 654 tests, all green; analyzer clean). The project is on GitHub (github.com/ramilaribi/NextGeneration-Class, branch main). Next, in this order:

1. Release 3 (docs/HANDOVER.md Task J). Step 1, formulas, exercises and series, is mocked AND approved (docs/00-brand/ui/screens/r3/): build it. Steps 2 to 4 (quizzes and QCM, pupils taking quizzes, PDF worksheets) each need a mockup and the user's yes first. Small leftover: one live-check homework in the local data (Tasks G and H), kept on purpose as graded demo data.
2. Still open: the user's look at the owner dashboard screenshots (docs/00-brand/ui/flutter/r1/admin_*.png), Task B hygiene (CI, the prod profile default), regenerating the R1 mockups with primary-school data.

How to work:
- Start the stack as the handover says (build the web app with --pwa-strategy=none so a browser never keeps an old build; after adding a plugin with a web part, delete app/.dart_tool/flutter_build/<hash> folders before building, see HANDOVER section 6): Docker Desktop running, docker compose dev DB on 5433, backend with mvn spring-boot:run (needs backend/.env), web build with --dart-define=API_BASE_URL=http://localhost:8080/api/v1 served on port 5050. The browser pane could not reach localhost before; use infra/dev-tools/cdp-screens.mjs for signed-in screenshots.
- Dev accounts (owner, teacher, student, parent): usernames in backend/src/main/resources/application-dev.yaml, passwords in backend/.env (git-ignored: the repository is public). Never paste or print them in chat, never commit them. Child and parent logins can also be made from the teacher's Fiche élève ("Créer un accès", "Réinitialiser le mot de passe").
- French and Arabic only, every string in both ARB files (French plurals need =0), server messages in messages*.properties. Directional layout only (no left/right). No long dashes in UI copy. Numbers in Arabic strings without spaces. A French name or free text inserted into an Arabic line goes through isolated() or keptTogether(), and a paragraph someone wrote (instructions, comments) gets textDirection: writtenDirection(text) (core/l10n/formatting.dart).
- Layers lib/data, lib/domain, lib/view with one Cubit per screen or panel, sl for DI, no logic in widgets. Backend: package per feature, tabs, Lombok, records, ApiException, Flyway, permission checks on the server.
- Every input shows a hint (an example or what to type) in both languages: hint is required on FormInput, AppTextField, PasswordField, SelectField and SearchBox; use expectEveryFieldHasAHint in tests of a new form.
- Every teacher query stays scoped to the signed-in teacher (another teacher's data answers 404); the owner sees accounts and counts only. Add an isolation check to OwnerDashboardTest for any new teacher endpoint.
- Loading, empty and error states on every screen. Every screen is responsive at every size (never call something "not responsive"): add each new screen to test/view/responsive_test.dart, and check French and Arabic from 320 px to 1440 px against the real API with screenshots for the user (cdp-screens.mjs "signin" step).
- Keep tests green: cd backend && mvn test (Docker needed); cd app && flutter analyze && flutter test. Add tests for what you build.
- No paid service or paid package. Commit and push only when the user asks (repo github.com/ramilaribi/NextGeneration-Class, public; account ramilaribi only). No deployment work: the project stays local until the very end.

When you finish, or if your context is about to run out: update docs/HANDOVER.md (sections 1, 4 and 5 and anything new in 6) and this prompt for the session after you.
```
