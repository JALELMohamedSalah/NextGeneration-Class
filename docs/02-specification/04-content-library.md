# Spec 04. Content library: "Contenus"

Priority: **M** · Release R2 (builders in R3, see spec 05)

## Goal
One place for all the teacher's material, organized by chapter, easy to find, reuse and share. The client's "Courses", "Library" and "Toolkit" are this single area.

## User stories
- As the teacher, I upload a series I already have (PDF, Word, photo) instead of rewriting it.
- As the teacher, I scan paper sheets with my phone camera and get one clean PDF.
- As the teacher, I organize my material by subject, level and chapter.
- As the teacher, I find an item in seconds with search and filters.
- As the teacher, I share a chapter or a document with a group so students can read it.
- As the teacher, I duplicate an old series or quiz and edit the copy.

## Organization
- Subject > Level > Chapter. Chapters are ordered within a level.
- An item belongs to zero or one chapter ("Sans chapitre" otherwise).
- Item types: Leçon, Document, Exercice, Série, Quiz, Fiche.
- Item status: `Brouillon`, `Publié`, `Archivé`. Only published items can be shared or assigned.

## Library screen
- Left (desktop) or top (phone): subject, level and chapter tree.
- Filters: type, status, "Partagé avec", "Assigné". Search by title.
- Each row: type icon, title, chapter, status, last edit, number of groups it is shared with.
- `+ Créer`: Leçon, Exercice, Série, Quiz, QCM, Fiche, Importer un document.

## Item actions

| Action | Rule |
|---|---|
| Ouvrir | PDF and images open in the in-app viewer; Word files are downloaded |
| Modifier | builders for lessons, exercises, series, quizzes; title, chapter and tag for documents |
| Dupliquer | creates a draft copy named "Titre (copie)", not shared, not assigned |
| Partager | pick one or more groups; the item appears in their "Cours" tab |
| Assigner | opens the assignment form (spec 06) |
| Exporter en PDF | for series, quizzes and worksheets (spec 05) |
| Archiver | hidden from the library and from new shares; still visible inside past assignments |

A whole chapter can also be shared: every published item of the chapter becomes visible, including items added later.

## Uploads
- Accepted: PDF, JPG, PNG, HEIC (converted to JPG), DOCX. Maximum 20 MB per file.
- Images are compressed on the device before upload (longest side 1600 px, JPEG quality around 75).
- **Camera scan**: take several photos in a row, reorder or delete pages, crop, then the pages are combined into one PDF on the device.
- On upload, the teacher sets: title (default: file name), chapter, tag (`Série`, `Cours`, `Corrigé`, `Autre`).
- Word files have no in-app preview in the MVP (it needs a paid or heavy conversion service). The app suggests exporting to PDF from Word for a better student experience.

## Acceptance criteria
- [ ] Uploading `serie_fractions.pdf` to chapter "Fractions" takes under 30 seconds on 4G and it can then be shared or assigned.
- [ ] Scanning 4 pages produces one PDF with the pages in the chosen order.
- [ ] A file over 20 MB or of an unsupported type is refused with a clear message before upload.
- [ ] Duplicating a quiz copies all questions, choices and settings, and the copy is a draft.
- [ ] Archived items are hidden by default and still open from old assignments.
- [ ] Students see only items shared with their groups or assigned to them; drafts are never visible to them.
- [ ] Search finds an item by any word of its title, ignoring accents and case.
