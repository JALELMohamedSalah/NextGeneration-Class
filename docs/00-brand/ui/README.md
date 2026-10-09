# Approved UI design

Approved by the user on 2026-10-05. This folder is the source of truth for every screen's look.

| File | What |
|---|---|
| `screens/*.png` | Rendered screenshots of each board. Look at these first. |
| `mockups/*.html` | The boards' HTML. Inline styles hold the exact values (sizes, colors, radii, weights). Open in Chrome to view. |
| `../UI_DESIGN_SPEC.md` | How to build this design in Flutter: tokens, components, screens, empty states, RTL, translation keys. |

| Board | Screenshot | Release that needs it |
|---|---|---|
| Direction UI (principles, colors, type, components, characters) | `screens/Main.png` | all |
| Connexion | `screens/Login.png` | R0 |
| Enseignante · Ma journée | `screens/TeacherHome.png` | R0 frame and empty states, filled by R1, R2, R4 |
| Enseignante · Mode séance | `screens/SessionMode.png` | R1 |
| Parent · Aperçu (FR) | `screens/ParentPhone.png` | R0 empty states, filled by R1 and R2 |
| Élève · Accueil (AR, right to left) | `screens/StudentPhoneAr.png` | R0 empty states, filled by R1 and R2 |

All names and numbers in the mockups are sample data.

**Live canvas** (private, owned by the user): https://claude.ai/artifact/EkCgGCYYyoB7mLWCzLz5mg
On the canvas, the content of "Ma journée" was dragged into a separate free piece named "Box" (`Piece-de4z`) sitting over the board. The design is unchanged; the files here hold the complete board.

**Inspiration** (Dribbble, education-platform tag): Zajno "Edtech App Concept" (one big number as the hero), VALMAX "Synclly" (groups in the sidebar, pastel sessions, Meet popover), Fikri Studio "Trenning" LMS (greeting with stat chips, rows that carry their action, quiz builder), WeStud login (friendly geometric characters).
