# Conception 07. Non-functional requirements

## Platforms (Q1)
| User | Target | Note |
|---|---|---|
| Teacher | web on a laptop (Chrome, Edge, Firefox, Safari, last 2 versions), tablet | desktop first |
| Students, parents | Android app (Android 8+), web on any phone | phone first |
| iPhone users | web version at first | an App Store app costs 99 USD per year; decide later |

## Language and formats
- Interface in **French and Arabic** (decided 2026-10-05), switchable at any time; Arabic turns the whole layout right to left. No hardcoded text: app strings in ARB files, server messages in `messages*.properties` chosen by `Accept-Language`, reference data stored in both languages.
- Content fields accept Arabic and French text, mixed with formulas.
- Time zone Africa/Tunis; dates `dd/MM/yyyy`; 24 h clock; decimal comma in grades (15,25).
- Formulas rendered the same way in the app and in PDFs.

## Privacy and security
Most users are minors.
- Collect only what is needed: names, level, phone numbers, parent links. No birth date, no address, no photo of the student.
- HTTPS everywhere (Let's Encrypt).
- Passwords hashed with BCrypt; login rate limited (5 failures, then wait).
- JWT access token short-lived (15 minutes), renewed silently. Refresh token opaque, stored hashed, valid **365 days and extended on each use** (user decision: stay signed in at least a year); revocable by logout or a teacher password reset.
- Permission checks on the server for every request; separate DTOs for student and parent responses.
- Files stored under random names, downloaded only through short-lived signed links.
- No student data sent to third parties, except push tokens to Firebase and emails to the SMTP provider.
- The client should know the Tunisian personal data law (loi organique 2004-63) and inform families.
- Logs do not contain passwords, tokens or submission content.

## Scale and storage
| Item | Estimate |
|---|---|
| Accounts | 1 teacher, up to 150 students, about 250 parents |
| Photo submissions | 150 students × 2 per week × 3 pages × 300 KB ≈ 270 MB per week at most, about 4 to 8 GB per school year in practice |
| Documents | a few GB |
| Database | under 1 GB per year |

Images are compressed on the device before upload. Old submission files can be moved to cheaper storage after the school year.

## Performance
- Home screens: one API call, under 2 seconds on 4G.
- Lists paginated (20 to 50 items).
- PDF of 10 pages generated in under 5 seconds on a mid-range phone.
- App start to home screen under 3 seconds on a mid-range Android phone.

## Availability and backups
- Target: available during the school day; short maintenance at night.
- Nightly database dump and file sync to a second location, 30 days kept.
- A restore is tested once before going live and once per term.
- Uptime monitoring with a free service, alert by email.

## Accessibility
- Text contrast WCAG AA (brand colors chosen for it).
- Touch targets at least 48 × 48.
- Status never shown by color alone.
- Text scales with the system font size up to 130 % without breaking layouts.

## Quality
- Every screen: loading, empty and error states.
- Form validation with clear French messages next to the field.
- Unit tests for business rules (statuses, scoring, averages, visibility).
- API tests proving that private notes and other students' data never reach student or parent accounts.
