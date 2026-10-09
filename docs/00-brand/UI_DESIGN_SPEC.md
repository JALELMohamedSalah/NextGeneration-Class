# UI design spec: from the approved mockups to Flutter

Status: design approved by the user on 2026-10-05. R0 screens implemented in Flutter on 2026-10-05 (screenshots in `ui/flutter/`); components used only by filled states come with their releases.
Look at `ui/screens/*.png` first, then read the exact values in `ui/mockups/*.html` (inline styles). When this spec and a mockup disagree, the mockup wins; tell the user.

Direction name: **Calme, clair, chaleureux.** Each screen answers the question of the day first, then gets out of the way.

## 0. Rules that never bend

1. **Two languages, no hardcoded text.** Every visible string comes from `app/lib/l10n/app_fr.arb` and `app_ar.arb` (same keys in both). Server messages arrive already translated (Accept-Language). Brand name "NextGeneration Class" and "NG Class" are also ARB keys.
2. **Right to left is a first-class layout**, not a mirror afterthought (section 5).
3. **No long dashes in copy.** Use a full stop, a comma or a middle dot "·".
4. **One strong color for the main action: indigo.** Amber is a marker (badges, the spark, "now"), never a big surface except the session-mode "Terminer" button.
5. **Status is always color + word.** Never color alone.
6. **No default Material look.** Every surface, button and chip below has explicit values. Material widgets are fine underneath, restyled.

## 1. Foundations

### 1.1 Colors

Already in `app/lib/core/theme/brand_colors.dart` (`BrandColors`, `StatusColors`, `Accent`, `AppRadii`, `AppShadows`): extend it to this table.

| Token | Hex | Use |
|---|---|---|
| indigo | `#2B3990` | primary buttons, active nav, links, teacher hero |
| indigoDeep | `#1C2566` | parent hero, session-mode header, selected day tile |
| indigoSoft | `#EEF0FA` | active nav pill, tonal buttons, current timeline row, login brand panel |
| turquoise | `#12A39A` | progress fills, "Class" in the wordmark |
| turquoiseDeep | `#0B7C75` | student hero (white text passes contrast) |
| amber | `#FFB020` | spark, badges, bell dot, session-mode end button |
| ink | `#1A1D3A` | main text |
| body | `#4A4F72` | paragraphs, secondary row text, inactive nav labels |
| slate | `#6B7090` | captions, meta, placeholders |
| line | `#E6E8F0` | card borders, input borders |
| rowDivider | `#F0F1F6` | dividers between list rows, progress track |
| chalk | `#F6F7FB` | page background, input fill, info notes |
| onDarkAmber | `#FFD27A` | "dans 1 h 20" on indigo |
| onDarkTeal | `#7FE3DA` | positive chip text on dark heroes |

**Accent families** (strong / soft background / text on soft):

| Accent | Strong | Soft | Text on soft | Used for |
|---|---|---|---|---|
| indigo | `#2B3990` | `#EEF0FA` | `#2B3990` | sessions, navigation, "Corriger" |
| turquoise | `#12A39A` | `#E3F6F4` | `#0B6E68` | series, attendance, progress |
| amber | `#FFB020` | `#FFF4DC` | `#9A6300` | to correct, homework |
| violet | `#7048E8` | `#F1ECFD` | `#5B34D6` | quizzes, students to watch, private lessons |
| blue | `#3B5BDB` | `#EAF0FF` | `#2F4AC0` | à faire, prévue, lessons, import |
| red | `#E03131` | `#FDECEC` | `#B42525` | manquant, absent |
| orange | `#E8590C` | `#FDEEE4` | `#B5440A` | en retard, grades dropping |
| green | `#2F9E44` | `#E7F6EA` | `#237A35` | rendu, présent, terminée |

**Status chips**: À faire = blue, Rendu = green, Rendu en retard / En retard = orange, Manquant / Absent = red, Corrigé = turquoise, Terminée = green, Prévue = blue, Prochaine = solid indigo with white text, Brouillon = grey `#868E96` on `#F1F3F5`.

**Group colors** (sidebar squares, calendar): indigo, turquoise, amber (text ink), violet, blue, orange; assigned in order of creation, editable later.

### 1.2 Typography

| Script | Font | Package |
|---|---|---|
| Latin (French, names, numbers) | **Plus Jakarta Sans** 400 to 800 | replaces Inter everywhere |
| Arabic | **IBM Plex Sans Arabic** 400 to 700 | also used for Latin inside Arabic screens |

Today `app_theme.dart` loads both through `google_fonts` (runtime download). Before the first release, bundle the TTF files as assets (both are OFL) and set `GoogleFonts.config.allowRuntimeFetching = false`, so the app works offline and sends nothing to Google.

| Role | Size / weight / letter spacing (French) | Example |
|---|---|---|
| heroTime | 76 / 800 / -3 (phone 52) | "14:00" |
| heroNumber | 56 / 800 / -2 | "15,25" |
| loginHeadline | 52 / 800 / -1.5 | "Enseigner, suivre, progresser." |
| pageTitle | 38 / 800 / -1 (phone 22 to 24) | "Bonjour Ines" |
| loginTitle | 36 / 800 / -0.8 | "Bon retour" |
| statValue | 34 / 800 / -1 (phone tiles 20) | "7", "94 %" |
| heroSubject | 22 / 700 | "Physique · Sara Ben Amor" |
| sectionTitle | 18 / 800 (phone 16 / 700) | "À corriger" |
| body | 15 / 500 to 700 | row titles 15 / 700 |
| small | 13 / 600 | row subtitles, chips |
| caption | 12 / 700 | stat captions, meta |
| overline | 11 to 12 / 700, uppercase, spacing 1 to 1.4 | "PROCHAINE SÉANCE", "MES GROUPES" |

**Arabic**: same sizes, weights capped at 700, **letter spacing always 0** (spacing breaks letter joining) and **never uppercase**. Overlines keep their color and size only.

Numbers: use tabular figures (`FontFeature.tabularFigures()`) for times, grades and counters so they do not jump.

### 1.3 Shape, spacing, elevation

| Token | Value |
|---|---|
| Radius | 7 group square, 8 small badge, 10 to 12 icon badge and small buttons, 14 inputs and main buttons, 16 to 18 rows and tiles, 20 stat tiles, 24 section cards, 28 hero, pill 999 |
| Page padding | desktop 32, phone 18 |
| Card padding | section card 24, stat tile 20, phone cards 14 to 16 |
| Gaps | between sections 24, between tiles 16 (phone 10), inside rows 12 to 14 |
| Borders | cards: 1 px `line`, **no shadow** |
| Shadows | hero: 0 18 40 rgba(28,37,102,0.22); login primary button: 0 10 24 rgba(43,57,144,0.25); language toggle active pill: 0 1 3 rgba(26,29,58,0.12) |
| Touch targets | at least 44 px; buttons 38 (row action) to 56 (login) |

### 1.4 Icons

Lucide style: 24 viewBox, 2 px stroke, round caps. Recommended package: `lucide_icons_flutter` (ISC license). Check license and maintenance first (docs/04-delivery/03-DEV_RULES.md); if it does not fit, use Material Symbols Rounded outlined at weight 400.

Icons used: calendar, calendar-check (Ma journée), users (Élèves), folder (Contenus), clipboard (Devoirs), megaphone (Annonces), sliders-horizontal (Paramètres), bell, search, plus, video (Meet), play, pencil (to correct), triangle-alert (missing), eye (to watch), circle-check (attendance), clock, map-pin, upload, list-checks (QCM / quiz), layers (series), house, book-open (lessons / Cours), chart-column (Résultats), layout-dashboard (Aperçu), chevron-down, arrow-right, arrow-left, send (Relancer), lock, user, info.

## 2. Components

Put shared components in `app/lib/view/widgets/` (one file per component or small family). Names are suggestions; keep them consistent.

| Component | Spec (from the mockups) |
|---|---|
| `BrandWordmark` | symbol image (`assets/brand/symbol.png`) + "NextGeneration" (800, indigo) + "Class" (500, turquoise), set in Plus Jakarta Sans, never an image of text. Sizes: sidebar 34 px symbol / 17 px text on two lines; login 40 / 21 on one line. |
| `AppSidebar` | width 264 (≥ 1024 px), compact 88 icons only with tooltips (600 to 1024). White, end border `line`, padding 24 / 16, gaps 28. Blocks: wordmark, nav items, "MES GROUPES" (R1, hidden while there are no groups), user card at the bottom. |
| `SidebarNavItem` | height 44, radius 12, gap 12, icon 20. Active: `indigoSoft` background, indigo text 700. Inactive: `body` text 600. Optional count badge at the end: amber, 22 px, ink text 800 (Devoirs = to-correct count, R2). |
| `SidebarGroupItem` | height 40, colored square 24 (radius 7) with 2-letter code, name, member count in `slate`. |
| `SidebarUserCard` | border `line`, radius 16, padding 12: avatar 40 indigo with initials, name 14/700, role 12 slate, chevron-down. Opens the account menu (language, change password, logout). |
| `AppTopBar` | height 72, white, bottom border. Search field (R2, hidden before), spacer, compact language toggle "FR · ع" (h40, radius 12, border), bell button 44 with amber dot when unread (R2), primary "Créer" button (h44, indigo, plus icon) opening the quick-action menu. |
| `PhoneHeader` (student/parent) | wordmark short (symbol 30 + "NG Class" 15/700 indigo) or greeting block, bell 40 with amber dot, avatar. No fake status bar. |
| `PhoneBottomNav` | height 72, white, top border; items: icon 20 inside a 52 to 56 × 30 pill (`indigoSoft` when active), label 11 (active 800 indigo, inactive 600 slate); count badge amber 16 px. |
| `HeroCard` | radius 28 (phone 24), padding 30 / 32 (phone 20), solid color, white text, `ChevronPattern` behind content. Variants: `teacher` indigo + shadow, `parent` indigoDeep, `student` turquoiseDeep. |
| `ChevronPattern` (CustomPainter) | geometry from the mockup SVG (viewBox 300): chevron 1 `M40,250 L150,140 L260,250` white 7 %, stroke 34; chevron 2 `M70,170 L150,90 L230,170` white 9 %, stroke 30; chevron 3 `M100,95 L150,45 L200,95` turquoise 55 %, stroke 26 (on the student hero: white 12 % instead); spark circle (232, 38) r 14 amber. Round caps and joins. Size 300 at inline-end −40, bottom −60 (desktop); 160 to 170 on phones. Paint mirrored when RTL. |
| `HeroPill` | on dark: background white 14 %, 12/700 uppercase (French), padding 6 / 12. |
| `HeroButtonLight` / `HeroButtonGhost` | h50, radius 14. Light: white background, indigo text 800, play icon. Ghost: white 8 % fill, white 30 % border, white text 700. |
| `SectionCard` | white, border `line`, radius 24, padding 24. Header row: title (sectionTitle) + optional `CountPill` + trailing link (13/700 indigo, no underline). |
| `CountPill` | accent soft background, accent text 12/800, padding 3 / 9. |
| `StatTile` | white, border, radius 20, padding 20, gap 14. Top row: `IconBadge` 40 + caption at the end (12/700, accent-text or slate). Value statValue, label 14/600 slate. 4 tiles per row on desktop (flex basis 200), 2 × 2 on phones. |
| `IconBadge` | square 40 / 36 / 26, radius 12 / 10 / 8, accent soft background, accent text icon (20 / 17 / 15). |
| `StatusChip` | pill, padding 5 / 10 (12 px text 700), 6 px dot of the strong color, soft background, text-on-soft color. |
| `InitialsAvatar` | circle 40 (rows), 38 (stacks), 32 (small stacks); soft accent background chosen by a stable hash of the name; initials 13/800 in the matching text color. |
| `AvatarStack` | overlap −10 (38) or −8 (32), white ring 3 / 2 px, "+N" in an ink circle. |
| `ActionRow` | padding 12 vertical, top divider `rowDivider`, gap 14: avatar, title 15/700 + subtitle 13 slate, meta (13 slate) or a `StatusChip`, then a tonal button. |
| `TonalButton` | h38 to 40, radius 12, `indigoSoft` background, indigo text 13 to 14/800. ("Corriger") |
| `PrimaryButton` | h46 to 56, radius 14, indigo, white text 15 to 16/700, optional trailing arrow (flips in RTL). |
| `SecondaryButton` | h40 to 46, radius 12 to 14, white, border `line`, ink text 13 to 15/600 to 700, optional leading icon ("Ouvrir Meet", "Relancer"). |
| `QuickActionButton` | h42, radius 12, border, white, `IconBadge` 26 + label 13/700. Row wraps. |
| `TimelineItem` | time column 48 wide, end-aligned (start 14/800, end 12 slate), 4 px colored bar (group color), title 15/700, subtitle 13 slate, `StatusChip` at the end. Current item: `indigoSoft` background, radius 16, padding 12, time in indigo. Past items: opacity 0.62. |
| `ProgressLine` | height 8, radius 4, track `rowDivider`, fill turquoise, label "5 sur 8" 12/700 body at the end. |
| `DayStrip` | 5 equal tiles, radius 16, padding 12 / 8, chalk background: day 12/700 slate, number 22/800, caption 11/700. Selected: indigoDeep, white number, amber caption. Day off: diagonal hatch (two greys, 6 px stripes), slate text. |
| `Sparkline` | 88 × 32, polyline 2.5 px orange, end dot r 3.5. |
| `InfoNote` | chalk background, radius 14, padding 12 / 14, icon 16 indigo (info or clock), text 13 body. |
| `NoteCard` (session mode) | background `#FFF8E8`, border `#F8E3B3`, radius 24, overline 12/700 `#9A6300`, text 16/600. |
| `AttendanceTile` | radius 16, padding 12, border 1.5: present `#CDEBD3` / `#F3FBF5` / green text, absent `#F6C9C9` / `#FEF5F5` / red text, late `#F7D3BE` / `#FEF7F2` / orange text; white initials avatar 38; tap cycles Présent → Absent → En retard. |
| `LanguageToggle` | login: pill group on chalk with border, padding 4; active option white with tiny shadow, indigo text 700; each language written in itself (Français, العربية in IBM Plex Sans Arabic). Top bar: compact button "FR · ع". |
| `Classmates` | the four geometric characters (login board values, scale 1): indigo 96 × 200 rounded top 48, two white eyes 18 with ink pupils 8; turquoise half disc 200 × 100 with ink eyes 10 and a smile (30 × 13, 4 px stroke); amber 104 × 150 rounded top 32, ink eyes 10; violet 84 × 170 rounded top 42, white eyes 15. Gap 12, aligned bottom. Take a `scale` parameter (login 1.0, empty states 0.35 to 0.5). Decorative: exclude from semantics. |
| `EmptyState` | `Classmates` at 0.35 to 0.45, message 14/600 body centered, optional `SecondaryButton`. |

## 3. Screens

Every screen: loading, empty and error states (docs/04-delivery/03-DEV_RULES.md). Empty states use the same cards with an `EmptyState` inside, never a blank page. Content max width 1240 on desktop.

### 3.1 Login (R0) · `screens/Login.png`
- ≥ 900 px wide: two panes. Start pane (flex 560): `indigoSoft`, padding 48 / 56, wordmark, headline (loginHeadline), brand line (17, body color), three feature cards (white, radius 16, `IconBadge` 40 + title 15/700 + text 13 slate), `Classmates` at the bottom (clipped by the pane). End pane (flex 440): language toggle at the top end, centered form max 400, footer "© NextGeneration Class" 12 slate.
- Form: overline "Espace privé" (turquoise, 12/700, uppercase in French), title "Bon retour", subtitle, labeled inputs (label 14/600 above the field; field h54, radius 14, chalk fill, border `line`, focused border 1.5 indigo, leading icon user / lock, eye toggle), primary button "Se connecter" h56 with arrow, `InfoNote` "Mot de passe oublié ? …".
- < 900 px: wordmark, then the form, `Classmates` at 0.45 under the form. Language toggle top end.
- Server error: inline banner under the fields (red soft background, red text-on-soft, radius 14).

### 3.2 Choose password (R0)
Same layout as login. Form variant: overline "Première connexion", title `mustChangePasswordTitle`, text `mustChangePasswordMessage`, three password fields (temporary, new with the rule as helper, confirm), primary "Enregistrer", text button "Se déconnecter".

### 3.3 Splash (R0)
Chalk background, centered `BrandWordmark` (40 / 21) and a 160 × 4 indigo progress line (radius 2). No spinner.

### 3.4 Teacher shell (R0)
`AppSidebar` + `AppTopBar` on tablet and desktop (`TeacherHome.png`). Phone: `PhoneHeader` + `PhoneBottomNav` with Ma journée, Planning, Élèves, Devoirs, Plus (Plus opens a sheet with Contenus, Annonces, Paramètres).

### 3.5 Ma journée (R0 frame, filled by later releases) · `screens/TeacherHome.png`
Data comes from one `TeacherDashboard` model (one API call later, docs/03-conception/06-API_OUTLINE.md). In R0 the repository returns an empty dashboard: no sessions and no submissions exist yet, so every block shows its empty state.

| Block | Filled (later) | Empty (R0) |
|---|---|---|
| Header | overline date, pageTitle greeting, summary line (plural keys) | date, greeting, `homeSummaryEmpty` |
| Quick actions | 5 `QuickActionButton`s: Séance, Devoir, QCM, Série, Importer | same; each opens its creation flow, or a "coming soon" snackbar until its release |
| Hero (flex 7) | next session (R1): pill + "dans 1 h 20", heroTime + "jusqu'à 15:30", subject · group, chips (mode, private lesson, chapter), "Démarrer la séance" + "Ouvrir Meet" (online only) | same hero, pill "Aujourd'hui", title "Journée libre" (pageTitle size, white), text, `HeroButtonLight` "Planifier une séance" |
| Aujourd'hui (flex 5) | `TimelineItem`s + `InfoNote` for tomorrow | `EmptyState` "Aucune séance aujourd'hui." |
| Stat tiles | 7 Copies à corriger, 5 Rendus manquants, 2 Élèves à surveiller, 94 % Présence (R2, R4) | hidden until R2 |
| À corriger (flex 7) | `ActionRow`s, max 5, "Tout voir" | `EmptyState` "Rien à corriger. Bonne journée !" |
| À surveiller (flex 5) | rows with reason chips and `Sparkline`, rules `InfoNote` (R4) | `EmptyState` "Aucun élève à surveiller pour le moment." |
| Travail manquant (flex 7) | assignment cards: title, group · deadline, `ProgressLine`, `AvatarStack` of missing students, "Relancer" (R2) | `EmptyState` "Tous les devoirs sont rendus." |
| À venir (flex 5) | `DayStrip` (5 days) + upcoming deadlines list | `DayStrip` with zero counts + `EmptyState` "Rien de prévu dans les 7 prochains jours." |

Responsive: blocks pair as 7 / 5 flex rows and wrap to one column under about 900 px of content width.

### 3.6 Session mode (R1) · `screens/SessionMode.png`
IndigoDeep header (back to Ma journée, title, time · room · chapter, live chip "En cours · 32 min", amber "Terminer la séance"). Two columns: attendance (summary chips, 2-column grid of `AttendanceTile`s) and content of the day (rows with `IconBadge`, title, meta, "Ouvrir" / "Lancer"), then `NoteCard` (previous session note) and the quick note (autosaved, "Enregistrée" in green).

### 3.7 Student home (R0 empty, filled R1 and R2) · `screens/StudentPhoneAr.png`
`PhoneHeader` (wordmark short, bell), greeting (pageTitle phone) + one summary line, student `HeroCard` (next session: pill, "today, in 2 hours" in amber, heroTime 52, subject · level, place or "Rejoindre" when online), "À faire" card (rows: `IconBadge` 42, title, deadline 12/700 orange when tomorrow, action button "Envoyer" primary or "Commencer" secondary), "Derniers résultats" card (title, grade 15/700, `ProgressLine` without label). Bottom nav: Accueil, Cours, Devoirs, Planning, Résultats.
R0 empty: hero shows "Aucune séance prévue pour le moment." with the pattern; other cards show `EmptyState`s.

### 3.8 Parent overview (R0 empty, filled R1 and R2) · `screens/ParentPhone.png`
Greeting block ("Bonjour Mouna" 13/600 slate + "Adam cette semaine" 22/800), avatar; child chips (selected: ink background, white text; others white with border); parent `HeroCard` (indigoDeep): "Moyenne en Math", heroNumber "15,25" + "/20", trend chip (teal on dark), 6 bars of the last grades (white 20 %, last one amber); 2 × 2 tiles (Prochaine séance, Présence, Devoirs with the missing item in red, Dernière note); teacher note card (avatar 34, "Mot de l'enseignante · hier", text 14). Bottom nav: Aperçu, Planning, Notifications (amber count badge).
R0 empty: hero shows "—" with `parentNoDataYet`; tiles show "—" with a short caption; the note card shows "Aucun commentaire pour le moment."

### 3.9 "Coming soon" sections (R0)
Centered `SectionCard` (max 560): `Classmates` at 0.4, section title (sectionTitle 22), a `StatusChip`-style badge "Version 1" (blue) / "Version 2" / "Version 4", one sentence saying what the section will hold (keys in section 6), no button.

## 4. Motion
Light only: cards fade and rise 12 px over 300 ms, 40 ms stagger, ease-out; none when `MediaQuery.disableAnimations` is true. Language switch: no animation, instant rebuild. No skeleton shimmer; loading = the empty card with a thin indigo progress line on top.

## 5. Right to left (Arabic)

- Use only `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`, `BorderDirectional` and `start` / `end`. A `left` / `right` in layout code is a bug.
- Mirror direction icons (arrow-right on "Se connecter", arrow-left on "back", chevrons). Do not mirror: play, video, clock, check, logos, the `Classmates`.
- Times, grades and phone numbers stay left to right inside Arabic text (`Directionality(textDirection: TextDirection.ltr)` around the value, or Unicode LRM).
- `ChevronPattern` paints mirrored, so its spark stays on the outer side (see the student mockup: pattern at bottom left).
- Arabic text: letter spacing 0, no uppercase, weight max 700.
- Test every screen in both languages at 1440 and 390 px.

## 6. Translation keys

Merge into both ARB files. Keys already present stay (check `app_fr.arb`). Values below are approved wording; Arabic should still get a final read by a native speaker.

### 6.1 Needed for R0 screens

| Key | Français | العربية |
|---|---|---|
| loginOverline | Espace privé | فضاء خاص |
| loginWelcome | Bon retour | مرحبًا بعودتك |
| loginBrandLine | L'espace privé de votre enseignante, pour ses élèves et leurs parents. | الفضاء الخاص بأستاذتك، لتلاميذها وأوليائهم. |
| loginFeaturePlanningText | Séances, liens Meet et appel en un geste. | الحصص وروابط Meet وتسجيل الحضور بلمسة واحدة. |
| loginFeatureWorkText | Rendus, file de correction, notes sur 20. | الأعمال المسلّمة وقائمة الإصلاح والأعداد على 20. |
| loginFeatureProgressText | Les parents comprennent tout en une minute. | يفهم الأولياء كل شيء في دقيقة واحدة. |
| firstLoginOverline | Première connexion | أول دخول |
| footerCopyright | © NextGeneration Class | © NextGeneration Class |
| languageToggleShort | FR · ع | FR · ع |
| searchPlaceholder | Rechercher un élève, un contenu… | ابحث عن تلميذ أو محتوى… |
| myGroups | Mes groupes | مجموعاتي |
| homeSummaryEmpty | Rien de prévu pour l'instant. Ajoutez vos élèves et vos séances pour remplir votre journée. | لا شيء مبرمج حاليًا. أضف تلاميذك وحصصك لتمتلئ صفحة يومك. |
| heroToday | Aujourd'hui | اليوم |
| heroFreeDayTitle | Journée libre | يوم فارغ |
| heroFreeDayText | Aucune séance prévue aujourd'hui. | لا توجد حصص مبرمجة اليوم. |
| planSession | Planifier une séance | برمجة حصة |
| quickQcm | QCM | اختيار من متعدد |
| quickImport | Importer | استيراد |
| seeAll | Tout voir | عرض الكل |
| emptyComment | Aucun commentaire pour le moment. | لا توجد ملاحظات حاليًا. |
| teacherNote | Mot de l'enseignante | كلمة الأستاذة |
| noValue | — | — |
| releaseBadge | Version {number} | النسخة {number} |
| comingPlanning | Calendrier de la semaine, séances récurrentes, liens Meet et présences. | جدول الأسبوع والحصص المتكررة وروابط Meet والحضور. |
| comingStudents | Élèves, parents, groupes et cours particuliers, avec leurs identifiants. | التلاميذ والأولياء والمجموعات والدروس الخصوصية مع معرّفاتهم. |
| comingContents | Votre bibliothèque : chapitres, documents, séries et quiz. | مكتبتك: المحاور والوثائق والسلاسل والاختبارات. |
| comingAssignments | Devoirs, rendus des élèves et file de correction. | الفروض وما يسلّمه التلاميذ وقائمة الإصلاح. |
| comingAnnouncements | Annonces aux groupes, aux élèves et aux parents. | إعلانات للمجموعات والتلاميذ والأولياء. |
| comingSettings | Matières, niveaux, année scolaire et préférences. | المواد والمستويات والسنة الدراسية والتفضيلات. |
| comingCourses | Les chapitres et documents partagés par votre enseignante. | المحاور والوثائق التي تشاركها أستاذتك. |
| comingStudentAssignments | Vos devoirs, quiz et séries, avec leur date limite. | فروضك واختباراتك وسلاسلك مع آجالها. |
| comingStudentPlanning | Vos prochaines séances, en présentiel ou en ligne. | حصصك القادمة، حضوريًا أو عن بعد. |
| comingResults | Vos notes, les commentaires et votre progression. | أعدادك والملاحظات وتقدّمك. |
| comingParentPlanning | Les prochaines séances de votre enfant. | الحصص القادمة لطفلك. |
| comingNotifications | Absences, devoirs manquants, nouvelles notes et annonces. | الغيابات والفروض غير المسلّمة والأعداد الجديدة والإعلانات. |

Key `noValue` is a placeholder glyph (the only dash allowed, shown alone in empty tiles). Keys that become unused after the redesign (`loginTitle`, `tagline` duplicates, `quickQuiz`, `quickUpload`): remove them from both files.

### 6.2 For filled states (add with the feature that brings the data)

Counts use ICU plurals. Arabic needs all six forms (zero, one, two, few, many, other); example:

```
"homeSessionsToday": "{count, plural, =0{Aucune séance aujourd'hui} =1{1 séance aujourd'hui} other{{count} séances aujourd'hui}}"
"homeSessionsToday": "{count, plural, =0{لا توجد حصص اليوم} =1{حصة واحدة اليوم} =2{حصتان اليوم} few{{count} حصص اليوم} many{{count} حصة اليوم} other{{count} حصة اليوم}}"
```

Wording to reuse from the mockups: "Prochaine séance", "dans {duration}", "jusqu'à {time}", "Démarrer la séance", "Ouvrir Meet", "En ligne", "Présentiel", "Cours particulier", "Terminée", "Prochaine", "Prévue", "Demain : {count} séances, la première à {time}.", "Copies à corriger", "Rendus manquants", "Élèves à surveiller", "Présence cette semaine", "Corriger", "Relancer", "{done} sur {total}", "date limite {when}", "Repos", "En cours", "Terminer la séance", "Contenu du jour", "Dernière séance", "Note rapide", "Enregistrée", "Touchez un élève pour changer", "Ouvrir", "Lancer", "Moyenne en {subject}", "{delta} ce mois", "Prochaine séance", "Dernière note", "{name} cette semaine", "Envoyer", "Commencer", "Derniers résultats". The Arabic mockup gives the Arabic wording for the student screens.

## 7. Done when

- [x] Fonts: Plus Jakarta Sans for Latin, IBM Plex Sans Arabic for Arabic; Inter is gone. (Files still fetched at runtime: bundle before release.)
- [ ] Every component of section 2 exists and is used by the screens of section 3. (R0 components done; filled-state components come with R1, R2, R4.)
- [x] Login, choose password, splash, teacher shell, Ma journée, student home, parent overview and the coming-soon sections match the screenshots in layout, colors, sizes and spacing (empty states for data that does not exist yet).
- [x] Every screen checked in French and Arabic, at 1440 and 390 px, with screenshots compared to `ui/screens/`.
- [x] No hardcoded string: every new text is in both ARB files with the same keys (`flutter gen-l10n` clean, key sets equal).
- [x] No `left` / `right` in layout code; direction icons mirror.
- [x] `flutter analyze` clean, all tests green, new widget tests for the shell in RTL and for empty states.
