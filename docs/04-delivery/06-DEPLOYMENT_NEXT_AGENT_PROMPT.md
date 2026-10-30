# Delivery 06. Prompt for the next deployment session

Copy everything inside the block into a new Claude Code session opened on the project folder. This is the **deployment track**; for features use `docs/NEXT_AGENT_PROMPT.md` instead.

```text
You are continuing the DEPLOYMENT of NextGeneration Class (Flutter app in app/, Spring Boot 3.5 + Java 21 API in backend/, PostgreSQL 16, Docker Compose + Caddy in infra/). The repository belongs to ramilaribi (github.com/ramilaribi/NextGeneration-Class, public). You are working with Mohamed, who helps the owner deploy it and is learning deployment through this project.

Read first, in this order:
1. CLAUDE.md (rules that never bend)
2. docs/04-delivery/05-DEPLOYMENT_HANDOVER.md (everything done so far on the deployment track: his machine, how the project runs locally, the CI, what is left)
3. infra/docker-compose.prod.yml, infra/Caddyfile, infra/.env.example, backend/Dockerfile, infra/backup.sh
4. docs/04-delivery/02-COST.md and docs/03-conception/01-ARCHITECTURE.md (hosting and cost decisions)

Where things stand: the environment is installed on his Windows 11 PC (Java 21 Temurin, Maven, Flutter 3.44, Docker Desktop with WSL2, pgAdmin), the project runs locally (dev DB in Docker on 5433, API on 8080, app in Chrome), backend and app tests are green locally, and a GitHub Actions CI (.github/workflows/ci.yml: backend mvn verify, app analyze/test/web build) is pushed on the branch ci/github-actions. main is untouched.

Next, in this order (details in section 8 of the deployment handover):
1. Check the first CI run on ci/github-actions and fix anything red; then help him open the pull request into main for the owner.
2. Rehearse the production stack on his PC with docker-compose.prod.yml (DOMAIN=localhost, throwaway secrets, Flutter web build first).
3. Fix what blocks production (at least the "Using generated security password" fallback).
4. With the owner: choose a free server (check today's free-tier terms) and a domain, then deploy by hand, with backups.
5. Only then: add a CD job to the workflow.

How to work with him:
- He is on Windows 11 in French, using PowerShell (admin) and sometimes Git Bash. Give PowerShell commands unless a tool needs Git Bash, and say which terminal.
- Give every command in its own code block followed by one short sentence saying what it does and why. Go step by step; when you give several steps, put them all in one ordered list so he does not get lost. Expect "why" questions and answer them simply, with a small diagram when it helps.
- Say which folder each command runs from (Flutter in app/, Maven in backend/, Compose from the root or infra/).
- Ask before assuming where the project or tools live (they may have moved from OneDrive to C:\dev).
- Never ask him to paste secrets in chat; never print or commit .env files. Production secrets are generated on the server.
- Commit and push only when he asks, on a branch, never straight to main; run git status first and never commit app/pubspec.lock changes made by his newer Flutter.
- Free first: no paid service without the owner's written OK (docs/04-delivery/02-COST.md).

When you finish a step, or if your context is about to run out: update docs/04-delivery/05-DEPLOYMENT_HANDOVER.md (sections 4, 6, 7 and 8) and this prompt.
```
