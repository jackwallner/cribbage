# iOS 27 compatibility audit: Cribbage Trainer

- Audit date: 2026-08-05
- Runtime: iOS 27.0 (24A5390f)
- Xcode: 26.6 (17F113)
- Scheme: `CribbageTrainer`
- Unit target: `CribbageTrainerTests`
- Overall: Pass with test concurrency warnings

## Checks

- Debug build: Pass.
- Unit tests: Pass.
- Normal rebuild after tests: Pass.
- Install and launch smoke test: Pass.
- Runtime UI snapshot: Pass. Onboarding rendered.

## Findings

- `CribbageTrainerTests/ProgressStoreTests.swift`, `ReviewPromptTrackerTests.swift`, and `PracticeRecordStoreTests.swift` contain main-actor isolation warnings.
- No production compiler warning, iOS 27-specific error, or runtime blocker was observed.

## Recommended follow-up

- Clean up the test target's actor isolation so a future Swift concurrency warning policy does not turn these into failures.
