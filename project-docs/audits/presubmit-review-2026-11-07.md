# Pre-submit review: Cribbage Trainer 1.3.3 (2026-11-07)

Live version: 1.3.2 (App Store lookup, released 2026-11-04), build 44, commit
`482c34e`. Reviewed `482c34e..2ac3ff9`, app sources only (`CribbageTrainer/`,
`Shared/`). The app change is the state machine fix set: zone-free day numbers
for the streak and Get Started (`ProgressStore`), flashcard Undo taking its
answer back (`FlashcardDrillView`, `RecordedAnswer`, `PracticeRecordStore`),
reminder times read from the stored hour and minute, and reminders reconciled
at launch and on return (`AppSettings`, `CribbageTrainerApp`).

Paywall, onboarding trial page, `SubscriptionService`, RevenueCat lookups,
restore and gating code are unchanged since the approved 1.3.2 build. The
paywall and trial page still carry Terms and Privacy links, no price is
hard-coded in Swift copy, no other-platform links or health claims were
found, and debug-only UI stays behind `#if DEBUG`.

Checked and clean: legacy `Date` keys migrate without resetting a streak or
Get Started day and are cleared on Reset Progress; no other target reads
them; Undo restores in reverse order when the pick and the swipe land on the
same spaced-review row; `reconcileReminders` re-reads the toggles after its
await, so a toggle flipped mid-check is respected; the double call at cold
launch replaces requests by id.

| Severity | File:line | What happens | Status |
|---|---|---|---|
| P2 | `Shared/Services/AppSettings.swift:174` | The real `notificationsAllowed` closure (UNUserNotificationCenter callback on a background queue, Swift 6 mode) runs on every launch and return but no test ever ran it; every reconcile test swapped in a stand-in. A main-actor isolated callback would trap there. | Fixed (test only): `testRealNotificationCheckAnswersOffTheMainQueue` runs the shipped closure on the simulator. No code change was needed. |
| P2 | `Shared/Services/AppSettings.swift:188` | `reconcileReminders` re-adds the Cribbage+ game night reminder without knowing membership. Home turns the toggle off only on a lapse it observes during a session (`HomeView.swift:126`), so a member who lapsed while the app was closed keeps the toggle ON and the request is re-added each launch. Tapping it routes to a member-only destination, which is gated, so nothing unlocks. Before 1.3.3 the repeating request already stayed pending in this case; the new exposure is a restore to a new phone. | Not fixed: needs a membership-aware rule (and a resolved membership at launch), a product call rather than a definite bug. |
| P2 | `Shared/Services/AppSettings.swift:190` | After a restore that resets notification permission to not determined, reconcile does nothing and the toggle reads ON with nothing pending. | Not fixed: the fix is a launch permission prompt, a product change. Already noted in `state-machines-2026-11-06-verify.md`. |

No P0 or P1 findings.

## Tests

Not run to completion. `gh-sim test --scheme CribbageTrainer` on `2ac3ff9`
(gh-sim id `cribbage@20261107-222725-5785-claude-imac98c8-1107-223204-12299`,
GitHub Actions run 42455146952) sat queued for the full 90 minute window
behind 17 other fleet runs and never started. The run stays queued; fetch it
with `gh-sim get <id>` once it finishes. The last full-suite pass on the
1.3.3 app code is run 42349505350 (214 passed), reported in
`state-machines-2026-11-06-verify.md`; this review changed no app code, only
added the one test above.
