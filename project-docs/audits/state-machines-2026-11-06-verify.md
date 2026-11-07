VERDICT: PASS

# Verification of the state machine fixes (2026-11-06)

Independent check of `state-machines-2026-11-06-fixes.md` against `state-machines-2026-11-06-review.md` and the whole change `435016e..b037a26` (commits `efc0809`, `e4d3fa5`, `2e46662`, `c8924aa`, the fixes doc `c630dc2`, and an empty fleet snapshot commit `b037a26`). Every fix was walked on the review's user route through the new code, every changed function's callers and readers were read, and the claims were rerun on GitHub. No app code or tests were changed.

**Summary: 4 fixes checked. 4 work on their route, 0 regressions, 0 newly failing tests, 0 scope failures. Disputed: none listed, nothing to rule on.**

## Fixes

| id | works | regression check | evidence |
|---|---|---|---|
| S1 | Yes | Clean | Days are stored as a zone-free date number (`ProgressStore.swift:92-104` `dayNumber`, written at `:132` and `:169`) and compared as numbers (`:79-81`, `:114-135`, `:164-166`). Review route (Mon 20:00 New York, Tue 20:00 Los Angeles): stored Mon number, today Tue number, gap 1, so Home's chip (`HomeView.swift:351`), Your Progress (`StatsView.swift:231`) and the drill-complete card (`DrillCompleteView.swift:55`) read 1 and the drill makes 2. Get Started (`HomeView.swift:193`, written by `QuickSessionView.swift:251`) stays done for the rest of Monday in Los Angeles. Upgrade: `storedDay` (`:107-111`) reads the old start-of-day `Date` in the current zone exactly as the old build did, and the legacy key is removed only after the new number is written (`:132-133`, `:169-170`), so no streak or Get Started day is reset. Reset Progress clears both old and new keys (`:181-189`). DST-at-midnight, backward clock and gap tests still pass. Eastward and date-line moves give the same gaps as before. No other reader of these keys exists (grep: no widget, watch or other target). Tests assert the user-visible values (`currentStreak`, `streakCount`, `quickSessionCompletedToday`) and fail without the fix (run 42352088847 below). |
| U1 | Yes | Clean | Each graded answer snapshots the item's `PracticeRecord` and seen/missed marks before recording (`RecordedAnswer.swift:16-33`); `FlashcardDrillView` records through it at the pick (`FlashcardDrillView.swift:238`) and the plain swipe (`:351`), carries it on `SwipeRecord` (`:353`), and Undo restores the pending pick on the top card and then the swipe's answer (`:371-375`). Review routes: Pegging Judgment pick, Next, Undo, pick again: one attempt. Plain AGAIN, Undo, KNEW IT: one right attempt, no miss, not in review. Ordering when the re-queued card is the one picked (queue of one) restores pick then swipe, ending at the start state (`testUndoOfAPendingPickThenTheSwipeRestoresTheStart`). Queue logic is byte-for-byte unchanged (`:376-382`), so the swipe deck invariants in `Views/Drills/AGENTS.md` hold. `restore` uses the same key mapping as `record` (`PracticeRecordStore.swift:93,127-129`) and does not touch `topics`. Readers: Home's `onChange(of: records.records.count)` (`HomeView.swift:111`) and its `onAppear` re-record (`:57`) bring the weekly ledger back to the restored value; Your Progress and the review queue read `records` live. Stored formats unchanged. Test gap below. |
| R2 | Yes | Clean | `reminderTime` and `gameNightReminderTime` are computed from the stored hour and minute on every read (`AppSettings.swift:98-110`, `:131-147`), and both triggers use the stored components (`:219`, `:254-256`). Review route (Tokyo to Los Angeles with the process alive, toggle off and on, or change the game night day): the trigger is the stored 9:00 / 19:30, and the picker reads the stored hour. Setters send `objectWillChange` before writing, keep the same keys, defaults (9:00, 17:00) and reschedule rule as the old `didSet`s. The only binders are `SettingsView.swift:103` and `GameNightPrepView.swift:94`; nothing subscribed to the removed `$reminderTime` publishers (grep). Stored keys and format unchanged, so upgraders keep their times. Tests assert the trigger and picker hour and fail without the fix. |
| R1 | Yes, for the state it targets | Clean | `reconcileReminders` (`AppSettings.swift:188-193`) re-adds reminders whose toggle is ON when iOS reports authorized, provisional or ephemeral (`:174-181`), called at launch and on each return to active (`CribbageTrainerApp.swift:30,36`). Requests are replaced by id (remove then add, `:211-221`, `:245-258`), so the double call at cold launch and every foreground are harmless. It never flips a toggle, never prompts (`getNotificationSettings` only), and does nothing when notifications are off or both toggles are off. The game night reminder's member rule is untouched: Home still turns the toggle off on an observed lapse (`HomeView.swift:126-127`), and reconcile only re-adds a request the toggle already asked for. Failing test on `435016e` exists for this UNVERIFIED claim: the audit's `testBUG_R1` (`added=[]`) in review run 42295524673. Test gap below. |

## Must change

Nothing.

## Fail-without-fix proof

On a throwaway branch `scratch-revert` (deleted afterwards), the S1, U1 and R2 fixes were reverted and their tests kept: `ProgressStore.swift` back to `435016e` behaviour, `AppSettings.swift` time handling back to the stored `Date` (R1's `reconcileReminders` kept so the test file builds), `FlashcardDrillView.swift` back to its pre-fix `choose`/`commit`/`undo`, and `RecordedAnswer.undo` emptied (the stores were never restored before the fix; deleting the type would only break the build). One `gh-sim test --only` run of the three tests, GitHub Actions run **42352088847** (gh-sim id `cribbage@20261106-230050-2aaa-claude-imac53bd-1106-233754-1767`): **0 passed, 3 failed**:

- `ProgressStoreTests/testWestwardTravelOnConsecutiveDaysKeepsTheStreak`: `("0") is not equal to ("1") - Tuesday is still open`, then `("1") is not equal to ("2")`.
- `RecordedAnswerTests/testUndoneMissIsForgotten`: `("2") is not equal to ("1")` (attempts), then `XCTAssertFalse failed` (needsReview).
- `ReminderSchedulingTests/testReenablingAfterAZoneChangeSchedulesTheStoredHour`: `Optional(15)` not `Optional(9)`, `Optional(48)` not `Optional(0)`.

Also confirmed from the fixes agent's base run 42342143276 log: the 6 S1 and R2 regression tests fail on `435016e` with the values the fixes doc quotes. R1's tests call the new `reconcileReminders` and cannot build on `435016e`; the audit's `testBUG_R1` covers that.

## Test results

- Full suite on HEAD `b037a26`: `gh-sim test --scheme CribbageTrainer`, GitHub Actions run **42349505350** (gh-sim id `cribbage@20261106-230050-2aaa-claude-imac53bd-1106-230132-27821`, Xcode 27.1, iPhone 17, iOS 27.2): **214 passed, 0 failed, 0 skipped.** Matches the fixes doc (run 42338791665, 214 passed). All 16 tests the change added pass on HEAD: the 4 new `ProgressStoreTests`, the 5 `RecordedAnswerTests`, the 7 `ReminderSchedulingTests`. No existing test case changed (`ProgressStoreTests.swift` only gained the four new cases).
- Fail-without-fix: run 42352088847, above.
- Screens: `gh-sim test --scheme Screenshots --only CribbageTrainerScreenshots/ScreenshotTests/testCaptureAppStoreSet` on HEAD, GitHub Actions run **42355016950** (gh-sim id `cribbage@20261106-230050-2aaa-claude-imac53bd-1107-001950-22410`): passed. The changed screen is the flashcard deck (`FlashcardDrillView`); its rendering code did not change, only grading and Undo. Screenshot `03_pegging` shows Pegging Judgment's deck as before (0 of 8 down, Keep the 5 / Discard the 5). Screenshot `03_pegging_answered` shows the card flipped to its back with the swipe hint: the capture helper tapped the card itself (it carries the button trait, `FlashcardDrillView.swift:142`) rather than a choice button, so the pick, Next and Undo path was not reached on screen. No other view changed (`SettingsView` and `GameNightPrepView` bind to the changed `AppSettings` properties but their code is unchanged).

## What the tests leave open (device checks)

- U1: `RecordedAnswerTests` drive `RecordedAnswer` against the real stores, not `FlashcardDrillView`. If the view's calls at `FlashcardDrillView.swift:238,351,371-372` were removed, these tests would still pass. The wiring was checked by reading the view (above). A UI check would settle it: Pegging Judgment, pick, Next, Undo, pick again, then Your Progress shows one attempt; and a plain card AGAIN, Undo, KNEW IT leaves nothing in Fix My Mistakes.
- R1: the tests call `reconcileReminders` directly and fake the authorization answer; the app wiring (`CribbageTrainerApp.swift:30,36`) is untested. The real route stays unverified, as the review and the fixes doc say. One more open point: if a restore to a new phone also resets notification permission to "not determined", reconcile does nothing (`AppSettings.swift:180,190`) and the toggle still reads ON with nothing pending. Asking for permission at launch would be a new prompt, a product change, so it was right not to add it. Device check: enable the reminder, back up, restore to a second device, open the app, read `getPendingNotificationRequests` and the authorization status.
- R2: the tests move `NSTimeZone.default`. Whether a live process and SwiftUI's DatePicker follow a real system zone change is still a device check (enable the reminder, background the app, change the zone, foreground, read the picker). The scheduling half does not depend on that: triggers no longer read any `Date`.
- S1: none beyond the review's; the tests assert the values Home and Your Progress render.

## Scope

- Only the four listed bugs are touched. No trial, onboarding, paywall, price, offer or membership code changed; no backend, App Store Connect or RevenueCat change is needed.
- Stored data: S1 adds two keys and reads the old ones (no reset; downgrading to an older build would read no last day and show the stored streak until the next drill, not a concern for a shipped app). R2 and U1 keep every format.
- Nothing is cleared on an inferred state: reconcile only adds requests, and the legacy day keys are removed only after their replacement is written.
- UNVERIFIED claims fixed (R1, R2) each have a failing test on `435016e` (R2: run 42342143276 and 42352088847; R1: `testBUG_R1`, run 42295524673).
- The fixes table covers all 4 in-scope review claims; nothing is held, skipped or disputed, so there is nothing to rule on under Disputed.
- No localized text, layout, widget, watch or entitlement code changed, so iPhone Duo layouts and localized strings are unaffected.

## Notes

- The fixes doc's README line and table are accurate. The `b037a26` snapshot commit is empty.
- `testPickingATimeStoresAndSchedulesIt` and the upgrade test pass on both base and HEAD, as controls should.
- Minor: `reconcileReminders` runs twice on a cold launch (`onAppear` and the first `.active`); harmless since requests replace by id.
