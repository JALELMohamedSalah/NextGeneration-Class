# Spec 05. Builders and PDF worksheets

Priority: **M** (lessons: S) · Release R3

## User stories
- As the teacher, I write exercises with real math formulas without knowing LaTeX.
- As the teacher, I build a series from new or existing exercises.
- As the teacher, I build a quiz with several question types that corrects itself.
- As the teacher, I create a QCM quickly.
- As the teacher, I preview a quiz as a student before publishing it.
- As the teacher, I print a worksheet in a student version and a teacher version with answers.

## Formula editor (used by every builder)
- Every text field for statements, questions, choices, answers and model answers accepts text with formulas.
- Toolbar buttons insert templates: fraction, power, index, square root, root n, parentheses, ≤ ≥ ≠, ×, ÷, π, vector, angle, degree, system of equations.
- Formulas are stored in LaTeX and shown with a live preview under the field.
- Images can be inserted (figures, graphs). Arabic text is supported in fields (right to left).

## Lesson (S)
Title, chapter, body (text, formulas, images), attachments.

## Exercise

| Field | Note |
|---|---|
| Énoncé | required, text with formulas |
| Image | optional |
| Difficulté | `Facile`, `Moyen`, `Difficile` |
| Points | default 4 |
| Réponse attendue | optional, short |
| Corrigé | text with formulas, image or file |

Exercises live in the library and can be reused in several series and worksheets.

## Series
- Title (e.g. "Série 01 : Fractions"), chapter.
- Ordered list of exercises: `+ Nouvel exercice` or `+ Depuis la bibliothèque`; drag to reorder.
- Total points computed.
- An uploaded series PDF is a Document tagged "Série"; it is assigned the same way.

## Quiz

### Settings

| Setting | Default |
|---|---|
| Titre, chapitre, difficulté | |
| Durée | none (no timer) |
| Tentatives autorisées | 1 |
| Note retenue (if several attempts) | best attempt |
| Afficher les réponses | after the deadline (other options: right after submission, never) |
| Ordre des questions aléatoire | off |

Number of questions and total score are computed, never typed.

### Question types

| Type | Answer format | Correction |
|---|---|---|
| Choix multiple | 2 to 6 choices, one correct | automatic |
| Vrai / Faux | | automatic |
| Réponse courte | one or more accepted answers | automatic, see matching rules |
| Texte à trous | text with blanks, accepted answers per blank | automatic, points split between blanks |
| Question ouverte | free text and optional photo | manual, goes to "À corriger" |

Each question: text, optional image, points (default 1), optional explanation shown with the answers.

**Matching rules** for short answers and blanks: ignore case, accents, extra spaces and a final full stop; numbers accept `,` or `.` as decimal separator (`2,5` = `2.5`).

### Flow
1. `Brouillon`: edit freely.
2. `Aperçu élève`: take the quiz as a student would, nothing saved.
3. `Publier`: the quiz can be assigned.
4. Once a published quiz has a submission, its questions are locked. `Dupliquer` to make a new version.

### Taking a quiz (student side, summary)
- One question per screen on phones, all on one page on desktop.
- Answers are saved as the student goes; a lost connection does not lose answers.
- With a timer, the remaining time is visible and the quiz is submitted automatically at zero.

### QCM preset
`+ QCM` opens the quiz builder limited to multiple-choice questions, with a fast entry mode: type the question, type the choices one per line, click the correct one, `Entrée` for the next question.

## PDF worksheets ("Fiches")
- Pick a whole series or quiz, or individual exercises and questions from the library; reorder.
- Header: NextGeneration Class logo, title, subject, level, chapter, date, teacher name, a line for the student name.
- Two versions from the same selection: **Élève** (no answers) and **Enseignante** (with model answers and correct choices).
- Formulas and images render as on screen. A4 portrait.
- The generated PDF can be downloaded, printed, or saved to the library as a Fiche and then shared or assigned.
- A revision sheet is a worksheet with the title template "Fiche de révision : ...".

## Acceptance criteria
- [ ] A teacher who does not know LaTeX can write `3/4 + 1/2 = 5/4` as a real fraction using the toolbar.
- [ ] A 10-question QCM can be created in under 10 minutes with the fast entry mode.
- [ ] Short answers `2,5`, `2.5` and ` 2.5.` are all accepted when the expected answer is `2.5`.
- [ ] A quiz with 9 automatic questions and 1 open question shows a partial score to the teacher and goes to "À corriger".
- [ ] A timed quiz is submitted automatically when time runs out, even if the student closed the app (server checks the deadline).
- [ ] The student and teacher PDF versions of the same worksheet differ only by the answers.
- [ ] Formulas in the PDF are sharp when printed.
