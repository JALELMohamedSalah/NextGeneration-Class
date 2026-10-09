# Brand: NextGeneration Class

## 1. Name

| | |
|---|---|
| Full name | **NextGeneration Class** |
| Spelling | "NextGeneration" in one word with capital N and G, then a space, then "Class" |
| Short name | **NG Class** (app icon label, 12 characters max on a phone home screen) |
| Monogram | **NG** |
| App id suggestion | `com.<company>.ngclass` |

Before the name is final, check that it is free: a trademark search at INNORPI (Tunisia), a web and app store search, and the domain you want (for example `ngclass.tn` or `nextgenerationclass.com`). "NextGen" is a common prefix, so a close match in education is possible.

## 2. Tagline

| Option | Note |
|---|---|
| **Enseigner, suivre, progresser.** | Recommended. Covers the three roles: teacher, follow-up, student progress. |
| Votre classe, toujours organisée. | Focus on the teacher's comfort. |
| Chaque élève, un pas plus loin. | Focus on students and parents. |

## 3. Personality and voice

**Personality**: organized, calm, modern, trustworthy. Friendly without being childish: users go from 11-year-olds in 6ème to Bac students and their parents.

**Voice rules for UI copy**
- Short, plain French sentences. One idea per sentence.
- "Vous" everywhere, for consistency across teacher, students and parents.
- Verbs on buttons: `Démarrer la séance`, `Rejoindre`, `Corriger`, `Assigner`, `Importer`.
- No long dashes in copy. Use a full stop or a comma instead.
- Empty states encourage, they do not blame: "Rien à corriger. Bonne journée !" rather than "Aucune donnée".
- The app speaks like a calm assistant, never like a school report.

## 4. Colors

### Brand palette

| Role | Name | Hex | Use |
|---|---|---|---|
| Primary | Indigo Nuit | `#2B3990` | logo, app bar, primary buttons, links |
| Secondary | Turquoise Progrès | `#12A39A` | progress, "Class" in the wordmark, positive highlights |
| Accent | Jaune Étincelle | `#FFB020` | the logo spark, small highlights, badges. Never for text on white. |
| Ink | Encre | `#1A1D3A` | body text, icons |
| Surface | Craie | `#F6F7FB` | page background |
| White | Blanc | `#FFFFFF` | cards, sheets |
| Muted | Gris Ardoise | `#6B7090` | secondary text, borders (borders at 20% opacity) |

Contrast: Indigo Nuit and Encre pass WCAG AA on white for all text sizes. Turquoise and Jaune are for shapes, icons and large text only; text placed on Jaune must be Encre.

### Status colors (used everywhere: chips, calendar, tables)

| Status | Color | Hex |
|---|---|---|
| À faire, Prévue | Blue | `#3B5BDB` |
| Rendu, Présent | Green | `#2F9E44` |
| Rendu en retard, En retard | Orange | `#E8590C` |
| Manquant, Absent, Annulée | Red | `#E03131` |
| Corrigé, Terminée | Turquoise | `#12A39A` |
| Brouillon, Archivé | Grey | `#868E96` |

Status is never shown by color alone: every chip has a label, and icons are added where space is short.

### Subject colors (calendar)
Default: Math `#2B3990`, Physique `#7048E8`. The teacher can change them in settings.

## 5. Typography

All fonts are free (Google Fonts, Open Font License).

| Use | Font | Weights |
|---|---|---|
| Headings, wordmark, UI and body text | **Plus Jakarta Sans** | 400 to 800 |
| Arabic interface and content | **IBM Plex Sans Arabic** | 400 to 700 |
| Math | KaTeX fonts, bundled with the formula renderer | |

Sizes (mobile): title 22, section 18, body 15, caption 13. Desktop adds 1 to 2 points. Minimum touch target 48 x 48.

The approved interface design (colors, components, screens) is in `ui/` and `UI_DESIGN_SPEC.md`. Inter was dropped on 2026-10-05: Plus Jakarta Sans covers all Latin text.

## 6. Logo

### Recommended concept: "NG Rising"
A geometric monogram where the letters **N** and **G** share one continuous stroke. The bar of the G extends to the right and becomes an **upward arrow**, the idea of moving to the next level. A small **amber spark** sits at the arrow tip, the moment a student understands.

- Indigo Nuit for the letters, Turquoise Progrès for the arrow, Jaune Étincelle for the spark.
- Flat, no gradient, no shadow. Thick enough strokes to read at 16 px.

Alternative concepts (prompts in `LOGO_PROMPTS_GEMINI.md`):
- **Rising book**: an open book whose pages form three steps going up.
- **Three chevrons**: three stacked chevrons growing in size, like three generations or three levels.
- **NG badge**: the NG monogram inside a rounded square, app icon first.

### Logo system to deliver

| Version | Use |
|---|---|
| Horizontal lockup: symbol + "NextGeneration Class" | web header, PDF header, login screen |
| Stacked lockup: symbol above the wordmark | splash screen, square spaces |
| Symbol alone | app icon, favicon, avatar |
| One color Indigo, one color white | dark backgrounds, printing, stamps |

**Wordmark**: Plus Jakarta Sans ExtraBold for "NextGeneration" in Indigo Nuit, Plus Jakarta Sans Medium for "Class" in Turquoise Progrès. The wordmark is set with the real font, never copied from an AI image.

**Clear space**: at least the height of the "N" on every side.
**Minimum size**: symbol 16 px (favicon); horizontal lockup 120 px wide on screen, 30 mm in print.

**Don't**: stretch, rotate, add shadows or outlines, change the colors, put the color logo on a busy photo, rewrite the name in another font.

### Files to produce

| File | Spec |
|---|---|
| `logo-horizontal.svg`, `logo-stacked.svg`, `symbol.svg` | vector masters |
| `logo-white.svg`, `logo-indigo.svg` | one-color versions |
| `app-icon-1024.png` | 1024 x 1024, no transparency (iOS), symbol on Indigo Nuit |
| Android adaptive icon | foreground PNG 432 x 432 with the symbol inside the central 66%, background color `#2B3990` |
| Web | `favicon.ico` (16, 32), `icon-192.png`, `icon-512.png`, `icon-512-maskable.png` |

In Flutter, generate all launcher icons with the free `flutter_launcher_icons` package from `app-icon-1024.png` and the adaptive foreground.

### Workflow
1. Generate concepts with Gemini (`LOGO_PROMPTS_GEMINI.md`).
2. Pick one with the client. Check it at 16 px, 48 px and in one color.
3. Check it does not look like an existing brand (Google reverse image search).
4. Vectorize it: redraw in Figma (free plan) or trace in Inkscape (free, Path > Trace Bitmap), then clean the curves.
5. Add the wordmark with Plus Jakarta Sans.
6. Export the files listed above.
