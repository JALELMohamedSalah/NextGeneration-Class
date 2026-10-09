# 05. Open questions for the client

Each question has a recommended default. If the client has no preference, the default is used and the question is closed.

| # | Question | Recommended default | Impact if the answer differs | Status |
|---|---|---|---|---|
| Q1 | Which devices do the teacher, students and parents use: Android, iPhone, laptop? | Teacher on web (laptop), students and parents on an Android app and the web | iPhone app adds 99 USD/year and an App Store review | Open |
| Q2 | Is the content in French only, or also in Arabic (primary school is mostly taught in Arabic)? | French UI, Arabic text allowed in all content fields | Arabic UI means translating every screen and right-to-left layouts | **Decided**: French and Arabic interface (see below) |
| Q3 | Do exercises and quizzes need math formulas (fractions, powers, roots, equations)? | Yes, with a formula editor with helper buttons | Without formulas, content is images only | Open |
| Q4 | How do students log in? Young students may not have an email. | Username or phone number + password, created by the teacher | Email or Google login changes account creation | **Decided** (see below) |
| Q5 | How many students today, and in one year? | Plan for up to 150 students | Sizing of hosting and storage | Open |
| Q6 | Are grades always on /20? Are there coefficients? | /20, simple mean, no coefficients | Weighted averages per evaluation type | Open |
| Q7 | Can students send photos of their paper work as homework? | Yes, several photos combined into one PDF | Online-only answers limit Math homework | Open |
| Q8 | Should parents get an alert when their child is absent? | Yes, a push notification the same day | | Open |
| Q9 | Are one-way announcements enough, or do parents and students need to reply in the app? | One-way in the MVP; replies through usual channels | Two-way messaging is a bigger module (moderation, notifications) | Open |
| Q10 | When do students see their grade and the model answer? | Grade as soon as it is corrected; model answer after the deadline | Batch publishing adds a "Publier les notes" step | Open |
| Q11 | Budget: strictly 0 €, or about 5 to 10 € per month plus a domain name? | Small monthly budget accepted, for reliability | Strict 0 € means Supabase free tier and its limits | Open |
| Q12 | Is there existing code or data to reuse (v1 mentions "the existing project")? | Start fresh; import the student list from Excel | Reusing code means auditing it first | Open |
| Q13 | Teacher name and contact to print on PDFs; who validates the logo? | Teacher validates the logo from the Gemini concepts | | Open |

## Decided

| Topic | Decision | Date |
|---|---|---|
| Product name | **NextGeneration Class** | 2026-10-05 |
| Languages (Q2) | Interface in **French and Arabic** (right to left), no English, no hardcoded text | 2026-10-05 |
| Session length | Users stay signed in **at least one year** (renewed on each use) | 2026-10-05 |
| UI design | Direction "Calme, clair, chaleureux" approved: `docs/00-brand/ui/` | 2026-10-05 |
| Fonts | Plus Jakarta Sans (Latin) and IBM Plex Sans Arabic | 2026-10-05 |
| Levels and audience | **Primary school**, 1ère to 6ème année, her own groups and private lessons | 2026-10-06 |
| Subjects | None predefined: **the teacher creates hers** (French name, optional Arabic, color) | 2026-10-06 |
| Child login (Q4) | **Optional**: a child is followed through the parents; the teacher opens a login when she wants | 2026-10-06 |
