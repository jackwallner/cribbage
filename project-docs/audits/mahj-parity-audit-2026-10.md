# Mahj-reference feature audit: Cribbage Trainer

Reference: the practice loop in jackwallner/mahj (endless generated practice, spaced review, timed challenge, room stats, daily set, coaching). Adapted to cribbage rules and this app's identity; no mahjong terms or mechanics copied.

Status key: PRESENT, GAP (fixed in this change), MISSING (left), UNSUITABLE.

| Area | Status | Source | Notes |
|---|---|---|---|
| Endless original practice | PRESENT, thin | `Shared/Content/EndlessPractice.swift`, `HandGenerator.swift` | Only two skills (read the shape, legal play). No hand counting, no pegging scoring. Both core cribbage skills missing. |
| Count the hand | GAP, fixed | `HandCountGenerator.swift` | Four cards plus starter, graded by `HandScoring`, distractors limited to reachable totals. |
| Pegging points | GAP, fixed | `PeggingScoring.swift`, `PeggingQuestionGenerator.swift` | 15, 31, pairs, pair royals, runs in any order. Explanation names each component. |
| Pegging legal-play item | INCORRECT UX, fixed | `EndlessPractice.peggingItems` | Correct answer was always slot 0 (play) or 1 (go) because generated choices were never shuffled. Now shuffled per item id. |
| Fix My Mistakes / spaced review | PRESENT | `PracticeRecordStore.swift` (SM-2 trim), `PracticeRunView.swift` `.review` | Authored items only; generated items deliberately excluded (they never repeat). Correct design for this game. |
| Timed challenge | PRESENT | `PracticeRunView` `.timed` | 90 s, best score. Now draws from four skills. Personal best only (no backend, by design). |
| Room-level stats | PRESENT | `StatsView.swift`, `roomStats()` | Per room accuracy and weakest room. |
| Skill-level mastery / coaching for misses | GAP, fixed | `PracticeRecordStore.recordTopic/weakTopics`, `StatsView.sharpenCard`, `EndlessPickerView` | Misses on generated questions only fed a skill-wide percent. Now tracked per narrow topic ("Spotting runs", "Pegging pairs"), surfaced in Progress and on the skill card once there are 4+ answers under 80%. Kept apart from `records` so room totals are not double counted. |
| Daily short practice | PRESENT | `CribbageMinuteContent.swift`, `CribbageMinuteStore.swift` | Seeded, no backend. Left unchanged (it is the shared five-question protocol). |
| Reminders | PRESENT | `AppSettings.swift` (daily and game-night reminders) | Unchanged. |
| Progression | PRESENT, light | streak, drills done in `ProgressStore` | No levels. Unsuitable to add: a trainer with finite rule knowledge reads worse with XP. |
| Reference / practice-hand flow | PRESENT | `HowToPlayView`, primer, `HandCategory.howToSpot` | Unchanged. |
| Feedback | PRESENT | `FeedbackSheet.swift`, rate row | Unchanged; rating policy per AGENTS.md. |
| What's New | GAP, fixed | `WhatsNew.swift` | Marketing version 1.2.3 had no release entry, so no sheet would show. Added 1.3.0 and bumped `MARKETING_VERSION` to 1.3.0. |
| Reduced motion | GAP, fixed | no `accessibilityReduceMotion` anywhere before | Confetti, shine sweep, wrong-answer shake, green flash and slide transitions now respect it in the practice runner and shared components. Other drill views still use springs for page changes (MISSING, lower risk: no flashing). |
| Larger text | NEEDS WORK | see `project-docs/audits/mahj-parity-evidence.md` for captures | Fonts are dynamic styles; checked in running UI. |

## Persona walk-through

- Beginner: Count the Hand is a good next step after Read the Hand, but the explanation must show the total as a sum of parts (it does). Pegging Points removes the old "always tap Play" shortcut.
- Experienced, improving weaknesses: topic coaching names the exact weak shape. Timed Challenge now mixes counting and pegging scoring, harder than before.
- Returning: Fix My Mistakes and Minute unchanged; What's New now announces the update.
- Larger text / reduced motion: see evidence file.

## Paid boundary

Unchanged. The two new skills sit in Endless Practice, which is already Cribbage+ (`HomeView` training tile). Free rooms, Read the Hand and Fix My Mistakes access are untouched.

## Correctness notes

- Hand totals of 19, 25, 26, 27 cannot occur and are never offered as options; a 5000-hand sample test guards the claim. Zero-point hands are not dealt (they are called "nineteen" at the table).
- Pegging 1 point comes only from go or last card, never from a card play, so 1 is never an option.
- A pegging pair counts only against the cards played immediately before; a run is the longest tail of the pile, in any order, of 3+ consecutive ranks with no duplicates.
