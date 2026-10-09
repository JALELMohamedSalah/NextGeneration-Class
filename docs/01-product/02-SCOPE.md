# 02. Scope

Priority: **M** = must have in the MVP, **S** = should have (MVP if time allows).

## In the MVP

| Module | Content | Priority | Release |
|---|---|---|---|
| Accounts and roles | teacher, student, parent; accounts created by the teacher | M | R1 |
| Students and parents | add, edit, archive, link parents, profile | M | R1 |
| Groups | groups and private lessons (group of one) | M | R1 |
| Planning | calendar, recurring sessions, cancel and move | M | R1 |
| Google Meet | stored link per group or session, join buttons | M | R1 |
| Session mode | focused screen, one-tap attendance | M | R1 |
| Attendance | present, absent, late; statistics | M | R1 |
| Teacher home | "Ma journée", grows with every release | M | R1 to R4 |
| Private notes | teacher-only notes on students and sessions | M | R1 |
| Content library | chapters, uploads, camera scan, share with a group | M | R2 |
| Assignments | assign any content, deadlines, file submissions | M | R2 |
| Correction | correction queue, correction screen | M | R2 |
| Grades | from corrections and paper evaluations | M | R2 |
| Student space | home, courses, assignments, planning, results | M | R1 to R2 |
| Parent space | one-minute overview per child | M | R1 to R2 |
| In-app notifications | notification center | M | R2 |
| Formula editor | math in all content | M | R3 |
| Exercise and series builder | | M | R3 |
| Quiz builder | 5 question types, auto-correction, QCM preset | M | R3 |
| Duplicate content | | M | R3 |
| PDF worksheets | student and teacher versions | M | R3 |
| Lessons | rich text pages | S | R3 |
| Push and email reminders | with digest and quiet hours | M | R4 |
| Announcements | one-way, teacher to group, student or parents | M | R4 |
| End-of-session workflow | covered content, homework, next session | S | R4 |
| Students needing attention | rule-based list | M | R4 |
| Progress charts | simple charts | S | R4 |
| Weekly parent summary | email and in-app | S | R4 |
| Student import | from Excel/CSV | S | R2 |
| Notification preferences | mute categories | S | R4 |

## Never (out of scope by design)

| Not built | Why |
|---|---|
| Marketplace, public catalog, teacher discovery, teacher profiles | one teacher, private use |
| Multiple teachers | one teacher only; do not design for more |
| Any payment feature: Stripe, checkout, cart, subscriptions, payment history | students have already paid |
| Custom video conferencing | Google Meet links are enough and free |
| Social network, real-time chat | announcements cover the need; families keep their usual channels |
| Gamification | not a goal of this product |
| Excessive animations | simple and professional UI |

## Later (after the MVP)

| Feature | Note |
|---|---|
| AI assistant | optional, behind a setting, never auto-published (see spec 11) |
| OCR of scanned series | turn a scan into editable exercises |
| Google Calendar sync | automatic Meet links and calendar events |
| Two-way messaging | parents and students reply in the app |
| Advanced analytics and reports | beyond the simple progress view |
| Dark mode | |
| Offline mode | read last data without network |
| iOS store app | the web version covers iPhones at first |
