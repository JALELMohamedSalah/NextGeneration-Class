# 04. Glossary

This vocabulary is used in every document, in the code and in the UI. The client's first spec used Course, Lesson, Chapter, QCM, Quiz, Exercise, Series, Worksheet, Revision sheet, Homework, Assignment and Correction with overlapping meanings; this file fixes them.

| Term (UI label) | Code name | Definition |
|---|---|---|
| **Subject** (Matière) | `Subject` | Created by the teacher (e.g. Mathématiques, Lecture, Éveil scientifique). None predefined. |
| **Level** (Niveau) | `Level` | 1ère to 6ème année (Tunisian primary school). |
| **School year** (Année scolaire) | `SchoolYear` | September to June. Groups, sessions and grades belong to one school year. |
| **Group** (Groupe) | `ClassGroup` | Students following one subject together. Has a default weekly schedule and a default Meet link. |
| **Private lesson** (Cours particulier) | `ClassGroup` with `isPrivate` | A group of one student. Same features as any group. |
| **Session** (Séance) | `Session` | One dated lesson for a group, in person or online. May come from a recurring rule. |
| **Recurring rule** (Récurrence) | `RecurrenceRule` | "Every Tuesday 17:00 to 18:30" for a group, between two dates. Generates sessions. |
| **Attendance** (Présence) | `Attendance` | Présent, Absent or En retard, per student and session. |
| **Chapter** (Chapitre) | `Chapter` | A unit of a subject at a level, for example *Math 7ème > Fractions*. Replaces "Course" from v1. |
| **Content item** (Contenu) | `ContentItem` | Anything in the library: lesson, document, exercise, series, quiz, worksheet. |
| **Lesson** (Leçon) | `Lesson` | A page of text with formulas, images and attachments. |
| **Document** | `Document` | An uploaded file: PDF, image, scan, Word. |
| **Exercise** (Exercice) | `Exercise` | One problem: statement, optional image, difficulty, points, model answer. Reusable. |
| **Series** (Série) | `Series` | An ordered list of exercises built in the app. An uploaded series PDF is a Document tagged "Série". |
| **Quiz** | `Quiz` | An ordered list of questions, corrected automatically when possible. |
| **QCM** | `Quiz` with `mcqOnly` | A quiz whose questions are all multiple choice. Same builder, preset. |
| **Question** | `Question` | One quiz item: multiple choice, true/false, short answer, fill in the blank, open. |
| **Worksheet** (Fiche) | `Worksheet` | A printable PDF built from selected exercises or questions. A revision sheet is a worksheet. |
| **Share** (Partager) | `Share` | Makes a chapter or item visible to a group as course material. No deadline, no submission. |
| **Assignment** (Devoir) | `Assignment` | A content item given to a group, some students or one student, with a deadline. "Homework" means assignment. |
| **Submission** (Rendu) | `Submission` | A student's answer to an assignment: online answers and/or photos and files. |
| **Model answer** (Corrigé) | `modelAnswer` | The reference solution of an exercise or quiz question. |
| **Correction** | `Correction` | The teacher's grading of one submission: score, comment, optional corrected file. |
| **Evaluation** (Évaluation) | `Evaluation` | A grade recorded manually for work done on paper, such as an in-class test. |
| **Grade** (Note) | `Grade` | A score with its maximum, shown on /20. Comes from a correction, an auto-corrected quiz or an evaluation. |
| **Private note** (Note privée) | `PrivateNote` | Teacher-only note on a student or a session. |
| **Comment** (Commentaire) | `Comment` | Teacher feedback visible to the student and their parents. |
| **Announcement** (Annonce) | `Announcement` | One-way message from the teacher to a group, a student, or parents. |
| **Notification** | `Notification` | An in-app item, sometimes also sent as push or email. |
| **Correction queue** (À corriger) | | Every submission waiting for the teacher. |
| **Ma journée** | | The teacher's home screen. |

## How content is organized

```
Subject (Math)
└── Level (7ème)
    └── Chapter (Fractions)
        ├── Lesson         "Cours : les fractions"
        ├── Document       serie_fractions.pdf (tagged Série)
        ├── Series         "Série 01 : Fractions" ── Exercise 1..n
        ├── Quiz / QCM     "QCM Fractions" ── Question 1..n
        └── Worksheet      "Fiche de révision : Fractions" (PDF)
```

## How content reaches students

```
Library item ──Share──▶ Group            visible in "Cours", no deadline
Library item ──Assign─▶ Group / students  appears in "Devoirs", deadline, submission, grade
```

## Words not to use

| Avoid | Use instead |
|---|---|
| Course (for a chapter) | Chapter (Chapitre) |
| Homework / Assignment as two things | Assignment (Devoir) |
| Correction (for the solution) | Model answer (Corrigé) |
| QCM builder | Quiz builder, QCM preset |
| Toolkit, Library, Courses as three areas | Contenus |
| Class (for a group) | Group (Groupe). "Class" is reserved for the product name. |
