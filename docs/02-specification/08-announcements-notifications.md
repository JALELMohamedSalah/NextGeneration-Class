# Spec 08. Announcements, comments and notifications

Priority: **M** (preferences and weekly summary: S) · In-app notifications R2, announcements R4

> **2026-10-09, user decision: no notifications and alerting for now.** Push notifications, email, reminders, the morning digest, quiet hours, absence alerts, "Relancer" and the weekly parent summary are not planned. The in-app notification centers already built stay; announcements stay planned (R4).

## User stories
- As the teacher, I send an announcement to a group, a student, or their parents.
- As a student, I am reminded of my sessions and deadlines without being spammed.
- As a parent, I am told when my child is absent, misses work or gets a new grade.
- As the teacher, I get one morning summary instead of a notification for every submission.

## Announcements
- Fields: title, text, recipients (a group, several groups, one student), audience (`Élèves`, `Parents`, `Élèves et parents`).
- One-way: no replies in the MVP (Q9). Families keep their usual channels for questions.
- Shown in the recipients' notification center and on their home screen for 7 days.
- The teacher sees the list of sent announcements and how many recipients have read each one.

## Comments
Teacher feedback attached to a student or to a submission. Visible to the student and their parents. Never confused with private notes (different screen area, different icon).

## Channels

| Channel | Who | Cost |
|---|---|---|
| In-app notification center | everyone | free |
| Push notification | Android app users; web users who allow it | free (Firebase Cloud Messaging) |
| Email | weekly parent summary, teacher digest if wanted | free within daily limits (SMTP) |
| SMS, WhatsApp API | **not used** | paid |

## Events

| Event | Teacher | Student | Parent | When |
|---|---|---|---|---|
| Session in 30 minutes | push | push | | 30 min before |
| Session cancelled or moved | | push | push | immediately |
| New assignment or quiz | | push | | on assignment |
| Deadline in 24 h, not submitted | | push | | 24 h before |
| New submission | dashboard + digest | | | |
| Assignment becomes `Manquant` | dashboard | push | push | at the deadline |
| Grade or correction saved | | push | in-app | on save |
| Absence recorded | | | push | on save |
| New document shared | | in-app | | on share |
| Announcement | | push | push if targeted | on send |
| Morning digest: today's sessions, to correct, missing | push (+ email if enabled) | | | 07:30 |
| Weekly summary (S) | | | email + in-app | Sunday 18:00 |

## Anti-spam rules
- The teacher gets a **digest**, not one push per submission.
- At most **one reminder per assignment per day** per student.
- **Quiet hours** 21:00 to 07:00: push notifications are queued until 07:00 (except a session starting before 07:30).
- Identical events are merged ("3 nouveaux devoirs" instead of three pushes).
- Each user can mute categories in settings (S); security messages cannot be muted.

## Weekly parent summary (S)
One message per child: sessions attended this week, assignments submitted and missing, new grades, next session, teacher comments. Plain French, no jargon, under 10 lines.

## Acceptance criteria
- [ ] A push is never sent between 21:00 and 07:00 Tunis time, except for a session starting before 07:30.
- [ ] A student with 3 new assignments at the same time gets one grouped push.
- [ ] Every push opens the right screen when tapped (deep link).
- [ ] The notification center shows unread items first and marks them read when opened.
- [ ] An announcement to "Parents" of a group is not visible to the students of that group.
