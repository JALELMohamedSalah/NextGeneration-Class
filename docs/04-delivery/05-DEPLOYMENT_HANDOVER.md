# Delivery 05. Deployment handover

Last update: 2026-10-20 · Written for the next agent working on the **deployment track** (environment, CI, CD, server). The product track (features, Release 3) keeps using `docs/HANDOVER.md` and `docs/NEXT_AGENT_PROMPT.md`.

## 1. Who and what

- **Owner of the repo**: `ramilaribi` (github.com/ramilaribi/NextGeneration-Class, public).
- **Person doing the deployment**: Mohamed, helping the owner. He is learning deployment through this project: explain every command in one short sentence (what it does and why), go step by step, and answer the "why" questions.
- **Goal set by the owner**, in this order:
  1. Install the environment and run the project locally. **Done.**
  2. Run a CI/CD pipeline. **CI done** (on a branch, see 4). CD not started.
  3. Deploy to a server, free if possible (`docs/04-delivery/02-COST.md`, principle "free first").
- **His machine**: Windows 11, MSI laptop, French locale. Uses **PowerShell** (admin) and sometimes **Git Bash**. No WSL distro of his own, only what Docker Desktop installed.

## 2. What is installed on his machine

| Tool | Version | Notes |
|---|---|---|
| Java | **21 Temurin** (21.0.12) via `winget install EclipseAdoptium.Temurin.21.JDK` | `JAVA_HOME` = `C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot`. Its `bin` was moved **above** `C:\Program Files\Common Files\Oracle\Java\javapath` in the system Path. **Oracle Java 25 is also installed**: if `java --version` ever shows 25 again, the Path order changed. |
| Maven | 3.10.0 (zip, manual) | `...\apache-maven-3.10.0\bin` in the system Path. No `mvnw` in the repo. |
| Flutter | **3.44.8** stable (zip, manual) | The project is built with **3.38** (Dart ^3.10). 3.44 works, but `flutter pub get` rewrites `app/pubspec.lock` (8 dependencies changed). **Never commit that lock file change**: `git restore app/pubspec.lock` before committing. `flutter doctor`: Flutter and Chrome OK; Android toolchain and Visual Studio missing, both ignored (web only for now). |
| Docker Desktop | via winget | Needed **Virtual Machine Platform** and **WSL** enabled (`Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All`, same for `Microsoft-Windows-Subsystem-Linux`), a full Windows restart and `wsl --update`. `docker run hello-world` works. |
| pgAdmin 4 | via winget (`PostgreSQL.pgAdmin`) | Connects to the dev DB: `localhost`, port **5433**, db `ngclass`, user `ngclass`, password from `DB_PASSWORD` in `backend/.env`. PostgreSQL itself is **not** installed on Windows: it runs in Docker. |
| Chrome, Git, Git Bash | already there | `openssl` exists only in Git Bash (`C:\Program Files\Git\usr\bin\openssl.exe`), not in PowerShell. |

**Project location**: `C:\Users\User\OneDrive - ESPRIT\Bureau\Projects\Deployment\NextGeneration-Class`. OneDrive (school account) had redirected the Desktop; its sync is now stopped (signed out). Moving the project to `C:\dev\projects\` and the tools to `C:\dev\tools\` was proposed but **not confirmed done**: ask before assuming a path.

## 3. Running the project locally (works, checked 2026-10-17)

From the project root, three terminals:

1. Database: `docker compose -f infra/docker-compose.dev.yml up -d` → container `ngclass-dev-db-1`, `postgres:16-alpine`, healthy, `127.0.0.1:5433->5432`.
2. API: `backend/.env` created from `backend/.env.example` (git-ignored). Filled: `JWT_SECRET` and the four dev passwords. Then `cd backend; mvn spring-boot:run` → Flyway applies 11 migrations (v11), Tomcat on 8080, seeders create `admin`, `enseignante`, `eleve.demo`, `parent.demo` (phone `20000001`), a demo group and a demo document.
3. App: `cd app; flutter pub get; flutter run -d chrome`. Login as `enseignante` works.

Tests, both **green on his machine** (2026-10-17): `cd backend; mvn test` (Testcontainers, Docker must run) and `cd app; flutter analyze; flutter test --concurrency=4`.

Things that went wrong and how they were fixed (useful if they come back):
- `java --version` showed Oracle 25: Temurin's `bin` was not in Path in the old terminal, then not first. Fixed by Path order + new terminal.
- Docker `500 Internal Server Error ... dockerDesktopLinuxEngine/_ping`: engine not running because Virtual Machine Platform was off. Fixed as in section 2.
- `openssl` not found in PowerShell: use Git Bash, or `$b = New-Object byte[] 48; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b); [Convert]::ToBase64String($b)`.
- Login refused: the username field was left empty (the grey text is a hint), and **the JWT secret had been pasted as all four dev passwords**. To give the accounts real passwords: set them in `backend/.env`, stop the API, `docker compose -f infra/docker-compose.dev.yml down -v` (wipes the dev DB), `up -d`, run the API again (seeders only create accounts on the first start). **Not confirmed whether he did this reset.**
- `flutter test` → "Test directory not found": run Flutter commands from `app/`, Maven from `backend/`, Compose from the root.
- The dev JWT secret appeared in screenshots shared in chat: fine for local dev, but production **must** get a new secret generated on the server.

## 4. CI (GitHub Actions)

Decision: **GitHub Actions** (the owner's choice; `act` to run it locally was dropped in favour of pushing a branch).

- File: `.github/workflows/ci.yml`. Triggers: `push`, `pull_request`, `workflow_dispatch`. `concurrency` cancels an older run on the same branch.
  - Job **backend**: checkout → `setup-java` Temurin 21 with Maven cache → `mvn -B verify` (in `backend/`). Works without `backend/.env`: all 10 test classes use `@ActiveProfiles("test")` (`application-test.yaml` has its own JWT secret and no seeded accounts) and `@Testcontainers` + `@ServiceConnection`.
  - Job **app**: checkout → `subosito/flutter-action@v2` stable `3.38.x` with cache → `flutter pub get` → `flutter analyze` → `flutter test --concurrency=4` → `flutter build web --release --pwa-strategy=none --dart-define=API_BASE_URL=/api/v1` (only checks that the release build compiles).
- Git: branch **`ci/github-actions`**, commit `16f23c7` "Add GitHub Actions CI: backend tests and Flutter analyze, test, web build", **pushed** to `origin` (tracks `origin/ci/github-actions`). `main` is untouched (`1f4a332`).
- **Not known yet**: whether the first Actions run was green, and whether a pull request was opened. Check the Actions tab first.
- This is Task B.1 of `docs/HANDOVER.md`, done exactly as planned there.

Possible tweaks, not done on purpose:
- `push` + `pull_request` on every branch runs the pipeline twice for a branch with an open PR. Common fix: `push` only on `main` + `pull_request`. Decide with the owner.

## 5. Production setup already in the repo (read before CD)

- `infra/docker-compose.prod.yml`: `db` (postgres:16-alpine, volume `db-data`), `api` (built from `backend/Dockerfile`: Maven + Temurin 21 build stage, Temurin 21 JRE alpine run stage, non-root user, files in volume `files`), `caddy` (ports 80/443, automatic Let's Encrypt for `${DOMAIN}`, serves `../app/build/web`, proxies `/api/*` to `api:8080`, security headers).
- `infra/.env.example` → `infra/.env` on the server: `DOMAIN`, `DB_PASSWORD`, `JWT_SECRET`, `TEACHER_*` (first teacher, must change password at first login). No admin or demo accounts in prod.
- `infra/backup.sh`: nightly `pg_dump` + files tarball, 30 days kept, meant for cron.
- There is **no Dockerfile for the Flutter web app**: `flutter build web` must run before `docker compose up` (or in CI), and the result is mounted into Caddy.
- `ALLOWED_ORIGINS` is set to `https://${DOMAIN}` by the compose file.

## 6. Decisions and opinions so far

- CI: GitHub Actions. (Owner's choice.)
- Hosting: the docs recommend a small VPS (5 to 8 € per month). Mohamed wants **free**. Suggested: a free-tier VM that runs the compose file unchanged (Oracle Cloud Always Free was named as the usual pick). **Check the current free-tier terms on the day**, they change. Not decided.
- Domain: Caddy needs one for HTTPS. A free subdomain (DuckDNS or similar) was suggested. Not decided.
- Supabase (the docs' "strict 0 €" option) was judged a bad fit: it would mean rewriting the Spring backend.

## 7. Known issues to handle before production

1. Startup log shows `Using generated security password` (Spring's `UserDetailsServiceAutoConfiguration` fallback). Harmless for the app (JWT login), but should be removed before production (exclude the auto-configuration or declare the project's own `UserDetailsService`).
2. New `JWT_SECRET` and `DB_PASSWORD` generated **on the server**, never pasted in chat or committed.
3. CD job (deploy only from `main`, only after both CI jobs pass) not written yet.
4. `app/pubspec.lock` modified locally by Flutter 3.44: keep it out of commits.

## 8. Next steps, in order

1. Check the first CI run on `ci/github-actions` (Actions tab). Fix any red step. Then the pull request into `main` for the owner to review and merge.
2. **CD rehearsal on his PC**: fill `infra/.env` with throwaway values and `DOMAIN=localhost` (Caddy then uses its own local certificate), `flutter build web --release --pwa-strategy=none --dart-define=API_BASE_URL=/api/v1`, then `docker compose -f infra/docker-compose.prod.yml up -d --build` from `infra/`. Check the app at https://localhost and the API behind `/api`. Stop the dev DB first if ports clash (prod DB is not published, so it should not).
3. Fix the issues in section 7 that block production (the generated password warning at least).
4. Choose the server and the domain with the owner; create the VM, install Docker, clone, `infra/.env`, build, `up -d`, cron for `backup.sh`, a copy of the backups somewhere else.
5. Add the CD job to the workflow (build the web app, deploy to the server over SSH with a GitHub secret), only after the manual deployment works.

Update this file at the end of each step.
