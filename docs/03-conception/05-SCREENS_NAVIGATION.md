# Conception 05. Screens and navigation

Target: about 15 teacher screens and a student/parent app that share components. Creation and quick edits use **modals** (phone: full-screen sheets) or **side panels** (desktop).

## Teacher

Navigation (side rail on desktop, bottom bar with 5 items + "Plus" on phone):
`Ma journée` · `Planning` · `Élèves` · `Contenus` · `Devoirs` · `Annonces` · `Paramètres`

| # | Screen | Main content | Main actions | Spec |
|---|---|---|---|---|
| T1 | Connexion | username or phone, password | Se connecter | 03 roles |
| T2 | Ma journée | today, to correct, missing, attention, coming up | quick actions | 01 |
| T3 | Planning | day/week calendar | + Séance, edit, cancel | 03 |
| T4 | Séance | detail, session mode, end-of-session form | Démarrer, Terminer, présences | 03 |
| T5 | Élèves | students list, tabs Groupes and Cours particuliers | + Élève, + Groupe, import | 02 |
| T6 | Fiche élève | profile sections | Modifier, Archiver, note privée, commentaire, réinitialiser | 02 |
| T7 | Groupe | members, schedule, Meet link, shared content, assignments, evaluations | + Évaluation, Partager, Assigner | 02 |
| T8 | Contenus | chapter tree, filters, search | + Créer, Importer | 04 |
| T9 | Détail contenu | viewer and metadata | Partager, Assigner, Dupliquer, PDF, Archiver | 04 |
| T10 | Éditeur | one editor: lesson, exercise, series, quiz/QCM | Aperçu, Publier | 05 |
| T11 | Fiche PDF | selection, order, version | Générer, Enregistrer | 05 |
| T12 | Devoirs | assignments list; detail with per-student table; evaluations | Relancer, Modifier la date | 06 |
| T13 | Correction | queue and correction view | Enregistrer et suivant | 06 |
| T14 | Annonces | sent announcements, notification center | + Annonce | 08 |
| T15 | Paramètres | profile, subjects, levels, school year, thresholds, notifications, PDF header | | |

**Modals and side panels**: + Séance, + Élève, + Groupe, Assigner, Importer / Scanner, + Évaluation, + Annonce, Terminer la séance, Identifiants.

## Student

`Accueil` · `Cours` · `Devoirs` · `Planning` · `Résultats` (bell icon for notifications, avatar for settings)

| # | Screen | Spec |
|---|---|---|
| S1 | Accueil | 09 |
| S2 | Cours: subjects > chapters > items, viewer | 09 |
| S3 | Devoirs: list and assignment screen (submission, quiz player, correction) | 09, 06 |
| S4 | Planning | 09 |
| S5 | Résultats | 09, 07 |

## Parent

`Aperçu` · `Planning` · `Notifications` (child switcher at the top)

| # | Screen | Spec |
|---|---|---|
| P1 | Aperçu, with subject details | 10 |
| P2 | Planning | 10 |
| P3 | Notifications | 08 |

Shared with students: session list, grade list, status chips, notification center, settings, login.

## Wireframe: Ma journée (desktop)

```
┌──────────┬──────────────────────────────────────────────────────────────┐
│ [logo]   │  Bonjour Mme X · Mardi 6 octobre                              │
│          │  [+ Séance] [+ Devoir] [+ Quiz] [+ Série] [+ Élève] [Importer]│
│ Ma       ├───────────────────────────────┬──────────────────────────────┤
│ journée  │ AUJOURD'HUI                   │ À CORRIGER (7)               │
│ Planning │ 10:00 Math · Groupe A  [▶]   │ Devoir Fractions · Ahmed  ›  │
│ Élèves   │ 14:00 Physique · Sara   [Meet]│ Série 3 · Sara            ›  │
│ Contenus │ 17:00 Math · Groupe B  [▶]   │ Quiz Équations · Youssef  ›  │
│ Devoirs  │                               │ Tout voir                    │
│ Annonces ├───────────────────────────────┼──────────────────────────────┤
│          │ TRAVAIL MANQUANT              │ À SURVEILLER                 │
│          │ Série 02 (Groupe A): 3 élèves │ Amine  [2 devoirs manquants] │
│ Param.   │                               │ Lina   [Notes en baisse Math]│
│          ├───────────────────────────────┴──────────────────────────────┤
│          │ À VENIR: demain 3 séances · 2 dates limites cette semaine     │
└──────────┴──────────────────────────────────────────────────────────────┘
```

## Wireframe: session mode (tablet)

```
┌──────────────────────────────────────────────────────────┐
│ Groupe A · Math 7ème · 10:00-11:30      [Ouvrir Meet]   │
├───────────────────────────┬──────────────────────────────┤
│ PRÉSENCES (8)             │ CONTENU DU JOUR              │
│ ● Ahmed       Présent     │ Fractions › Série 01  [Ouvrir]│
│ ● Sara        Présent     │ QCM Fractions         [Ouvrir]│
│ ○ Amine       Absent      │                              │
│ ◐ Lina        En retard   │ DERNIÈRE SÉANCE              │
│ ...                       │ "Revoir la simplification"   │
│                           │ NOTE RAPIDE                  │
│                           │ [____________________]       │
├───────────────────────────┴──────────────────────────────┤
│                                   [Terminer la séance]   │
└──────────────────────────────────────────────────────────┘
```

## Layout rules
- Breakpoints: under 600 px phone, 600 to 1024 px tablet, over 1024 px desktop.
- The teacher space is designed for desktop and tablet first, and stays usable on a phone.
- The student and parent spaces are designed for phones first.
- Every list and block has loading, empty and error states.
- Status is always a chip with a label and a color (`00-brand/BRAND.md`).
