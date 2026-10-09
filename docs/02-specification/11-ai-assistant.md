# Spec 11. AI assistant (later, optional)

Priority: **Later** · Not part of the MVP. Requires the client's approval because it has a running cost.

## Principle
**Scope decided 2026-10-09 (user)**: AI only helps on content (series, QCM, corrigés, questions from a document). No notifications, no alerts, nothing sent to families by the AI.

AI is a productivity helper for the teacher, never a requirement. The platform must stay fully useful with AI turned off.

## Possible actions

| Action | Input | Output (always a draft) |
|---|---|---|
| Generate a QCM | "10 questions sur les fractions, niveau 6ème" | quiz draft in the quiz builder |
| Generate exercises | "8 exercices sur les équations, difficulté moyenne" | exercises in a draft series |
| Revision sheet | a chapter or a document | worksheet draft |
| Model answer | an exercise | proposed corrigé in the exercise editor |
| Questions from a PDF | an uploaded document | proposed questions and exercises |

## Mandatory rules
1. AI output is **never published or assigned automatically**.
2. Flow: `Générer` → `Aperçu` → teacher edits → `Enregistrer` (draft) → `Publier` / `Assigner`.
3. Generated items are marked "Brouillon IA" until the teacher saves them.
4. A setting turns the whole feature on or off; when off, no AI button is visible.
5. Students and parents never interact with AI.
6. No student personal data is sent to an AI provider.

## Design for later
- One provider interface on the backend (`AiProvider`) so the model or vendor can change.
- Cost options: pay per use with a monthly cap, or the teacher's own API key.
- Before adding it: document why it is needed, free alternatives considered, estimated monthly cost, and get written approval (`04-delivery/02-COST.md`).
