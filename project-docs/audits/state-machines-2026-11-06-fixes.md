# Fixes for the state machine audit (2026-11-06)

Fixes for every claim `state-machines-2026-11-06-review.md` left in scope, in its ranked order, on top of `435016e`. No verify file existed, so there was nothing to redo.

**Summary: 4 in scope. 4 fixed (S1, U1, R2, R1), 0 held, 0 skipped, 0 disputed.**

| id | review verdict | outcome | commit | regression test | what changed |
|---|---|---|---|---|---|
| S1 | CONFIRMED (rank 1) | fixed | `efc0809` | `ProgressStoreTests.testWestwardTravelOnConsecutiveDaysKeepsTheStreak`, `testOneCalendarDayAcrossAWestwardMoveCountsOnce`, `testQuickSessionStaysDoneAfterAWestwardMove`, `testUpgradeFromStartOfDayInstantsKeepsStreakAndQuickSession` | The last practice day and the last Get Started day are stored as a zone-free date number (`progress.lastActiveDayNumber`, `progress.lastQuickSessionDayNumber`) and compared as numbers, so a westward move no longer reads the stored day as the previous date. Upgraders' old start-of-day instants are still read (as the old build read them) and replaced on the next write; the upgrade test keeps a 5-day streak and today's Get Started. |
| U1 | CONFIRMED-MINOR | fixed | `e4d3fa5` | `RecordedAnswerTests` (5 tests: right, Undo, right is not known; an undone miss is forgotten; undoing a first answer leaves no trace and persists; earlier history survives; a pending pick and the swipe both undo) | Each flashcard answer snapshots the item's `PracticeRecord` and seen/missed marks before recording (`RecordedAnswer`). Undo restores them, for the swipe it undoes and for a pick already made on the card now on top. Queue behaviour is unchanged. |
| R2 | UNVERIFIED (likely real) | fixed: headless test failed on `435016e` | `2e46662` | `ReminderSchedulingTests.testPickerShowsTheStoredHourAfterAZoneChange`, `testReenablingAfterAZoneChangeSchedulesTheStoredHour`, `testChangingGameNightDayAfterAZoneChangeKeepsTheStoredTime`, `testPickingATimeStoresAndSchedulesIt` | `reminderTime` and `gameNightReminderTime` are computed from the stored hour and minute on every read, and both triggers are built from the stored hour and minute, so the pickers and any reschedule (re-toggle, game night day change) keep the stored time after a zone change. Stored keys and format are unchanged. Covers the game night variant the review added. |
| R1 | UNVERIFIED | fixed: headless test failed on `435016e`, route still unverified | `c8924aa` | `ReminderSchedulingTests.testLaunchSchedulesRemindersThatAreOn`, `testLaunchWithNotificationsOffChangesNothing`, `testLaunchWithRemindersOffSchedulesNothing` | At launch and on each return to the app, reminders whose toggle is ON are re-added when iOS allows notifications (`AppSettings.reconcileReminders`). Requests are replaced by id, so this is a no-op when they are already pending. Toggles are never switched off, and nothing is prompted. |

## How the unverified claims were settled

- R2: the reviewer's re-enable check (Tokyo to Los Angeles, toggle off and on) and the audit's `testBUG_R2` both failed on the base code in review run 42295524673 (trigger 15:48 instead of 9:00; picker hour 15 instead of 9). The same scenarios, now permanent in `ReminderSchedulingTests`, fail on `435016e` (run 42342143276) and pass with the fix.
- R1: the code fact, a launch with the toggle ON and nothing pending schedules nothing, fails headless on `435016e` (`testBUG_R1`, `added=[]` for both reminders, review run 42295524673). What stays unverified is how often a real phone reaches that state (whether a backup restore or Quick Start drops pending local notifications while keeping UserDefaults). The fix is safe either way: if the requests survive, re-adding them by id changes nothing; if they are dropped, the reminder comes back. It never flips a toggle on an inferred state. A device check would still size the reach: enable the reminder, back up, restore to a second device, open the app, read `getPendingNotificationRequests`.

## Held for Jack

None.

## Skipped

None.

## Disputed

None.

## Test results

- Full suite with the fixes: `gh-sim test --scheme CribbageTrainer`, GitHub Actions run 42338791665 (gh-sim id `cribbage@20261106-195538-87cb-claude-mbpro331f-1106-203056-20141`, Xcode 27.1, iPhone 17, iOS 27.2): **214 passed, 0 failed, 0 skipped.** No test newly fails, and none needed checking against `435016e`.
- Regression tests on `435016e` (base checkout plus the new `ProgressStoreTests`, `ReminderSchedulingTests` without the launch tests, which call the new `reconcileReminders`, and `FakeNotificationCenter`): run 42342143276 (gh-sim id `cribbage-base-mbpro331f-1106-211808-32343`): 18 passed, 6 failed. The 6 failures are the S1 and R2 regression tests: `testWestwardTravelOnConsecutiveDaysKeepsTheStreak` (`("0") is not equal to ("1") - Tuesday is still open`), `testOneCalendarDayAcrossAWestwardMoveCountsOnce` (`("2") is not equal to ("1")`), `testQuickSessionStaysDoneAfterAWestwardMove` (`XCTAssertTrue failed`), `testPickerShowsTheStoredHourAfterAZoneChange` (`("15") is not equal to ("9")`), `testReenablingAfterAZoneChangeSchedulesTheStoredHour` (`Optional(15)` not `Optional(9)`), `testChangingGameNightDayAfterAZoneChangeKeepsTheStoredTime` (`Optional(2)` not `Optional(19)`). The upgrade test and `testPickingATimeStoresAndSchedulesIt` pass on both, as controls should. The U1 and R1 regression tests call APIs the fixes add, so they cannot build on `435016e`; the equivalent audit repro tests (`testBUG_U1a`, `testBUG_U1b`, `testBUG_R1`) failed there in review run 42295524673.

The audit's repro suite was never added to the test target (it lives only in this folder as `state-machines-2026-11-06-repro.swift`); its sound tests were carried over as the regression tests above, and `FakeNotificationCenter` is now `CribbageTrainerTests/FakeNotificationCenter.swift`.
