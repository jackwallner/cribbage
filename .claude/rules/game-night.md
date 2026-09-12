---
paths:
  - "Shared/Content/CribbageMinuteContent.swift"
  - "Shared/Services/CribbageMinuteStore.swift"
  - "CribbageTrainer/Views/CribbageMinuteView.swift"
  - "CribbageTrainer/Views/GameNightPrepView.swift"
  - "Shared/Content/SessionBuilder.swift"
  - "Shared/Content/HandGenerator.swift"
  - "Shared/Services/AppSettings.swift"
  - "CribbageTrainerTests/CribbageMinuteTests.swift"
  - "CribbageTrainerTests/HandGeneratorTests.swift"
  - "CribbageTrainer/Views/Drills/QuickSessionView.swift"
  - "CribbageTrainer/Views/SettingsView.swift"
---

# Cribbage Trainer: game-night rhythm

Moved verbatim from CLAUDE.md. Loads when a matching file is read; update it here.

## Game-night rhythm (1.2)

Cribbage+ owns two recurring rituals. `CribbageMinuteContent` deterministically builds the
same five questions for every member on a local calendar day: two generated
hand reads, one discard decision, and two pegging questions. Results and a 30-day
archive stay on device in `CribbageMinuteStore`; sharing uses the system share sheet and
needs no account or leaderboard.

The discard question is built straight from the authored scenarios, NOT through
`SessionBuilder.choiceItems`. The quick-session pool deliberately excludes
those drills, so drawing the daily from it silently produced a four-question
challenge with that skill missing entirely.

`HandGenerator` deals the daily hands from a caller-supplied generator all the
way down: `deal`, `fill`, and `randomHand` are all generic over
`RandomNumberGenerator`. One `.shuffled()` or `.randomElement()` left calling
the system source is enough to make the same day deal different hands on
different devices, and the stability test is what catches it.

`GameNightPrepView` stores a weekly game night in `AppSettings`, schedules a
local notification, and opens directly into `SessionBuilder.gameNightPrep`,
which prioritizes due mistakes, misses, the weakest room, and unseen member
content in that order. Both features are entirely Cribbage+ gated.
