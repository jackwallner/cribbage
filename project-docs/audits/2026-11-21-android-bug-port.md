# Android port of the 2026-11-20 bug fixes

Checked 2026-11-22 on `main`. Each row of
[2026-11-20-bug-fixes.md](2026-11-20-bug-fixes.md) was checked against the
`android/` port by reading the code. Bugs that exist there were fixed with the
smallest change that matches the iOS behavior.

Unit run (`fm-gradle testDebugUnitTest`, GitHub Linux) at HEAD `f156591`:
`cribbage-mbairfcc1-1122-101601-10214`, **91 passed, 0 failed.**

No run before the fixes: every new test calls an API the fix adds, so none of
them compiles on the old code. No emulator run. The Compose wiring of B2, B3
and B9 was checked by reading the code; the unit tests cover the decision each
one makes.

| iOS bug | Android verdict | Commit | Test | Notes |
|---|---|---|---|---|
| B1 Timed Challenge loses the best on early exit; clock ignores time away | already fine | | | `PracticeRunScreen` saves a timed score from a `DisposableEffect` when the screen leaves, and its clock end is a `SystemClock.elapsedRealtime` deadline, so time away counts |
| B2 A session that crosses midnight counts for the wrong day | ported | 1312dc7 | `StoreTest.runStartedBeforeMidnightKeepsTheStreak`, `getStartedStartedBeforeMidnightLeavesTomorrowOpen`, `minuteStartedSaturdayNightCountsInThatWeek` | Each pushed screen records when it opened (`LocalRunStart`). Sessions, the Get Started card and the Minute are credited to that day |
| B3 Reminders read on after notifications are turned off | ported | ba14c4b | `ReminderRefreshTest` (4 tests) | `AppSettings.reconcileReminders` runs on every `ON_START`. Blocked with a reminder on: the "Notifications are off" message shows on Settings or Game Night Prep and the choice is kept. Allowed again: the message is dropped and the alarms are laid again |
| B4 Ask to Buy shows the SDK's raw error | already fine | | | `SubscriptionService.purchase` maps `PaymentPendingError` to `PurchaseOutcome.PENDING`, and both buy screens say Google Play is still processing the payment |
| B5 Charged but not posted: raw error, no word about Restore | ported | d952249 | `PurchaseFailureTest` (3 tests) | After any other purchase error the customer is fetched once. A member moves on. Errors that only come once Google Play holds the purchase show the existing "went through, tap Restore" line. See the note below |
| B6 Paywall plan cards break words at AX5 | not applicable | | | iOS Dynamic Type accessibility sizes. Android font scale stops at 2x |
| B7 Minute dates print month first in every locale | ported | 1b1be79 | `StoreTest.minuteDateLabelFollowsTheLocale`, `cribbageMinuteKeepsOnlyTheFirstAttempt` | `CribbageMinuteResult.dateLabel()` reads the day key in the device locale for the result card and the share text. The stored `shortDate` is unchanged |
| B8 Fix My Mistakes icon blank on iOS 17 | not applicable | | | An SF Symbol missing from the iOS 17 runtime. Android draws its own vector for every symbol name |
| B9 Home and the Minute keep yesterday's day state | ported | f156591 | `StoreTest.aDayPassedInReadsAsTheNewDay`, `theDayTurnsOverJustPastLocalMidnight` | `rememberToday()` refreshes on return to the app, one second past local midnight, and on a clock or time zone change. Home and the Minute screen read their day from it |

Counts: 5 ported, 2 already fine, 2 not applicable.

## B5 on Android

RevenueCat's `NetworkError` does not say whether the Google Play sheet never
loaded or the receipt post failed after the charge (not checked on a device),
so a network drop right after the charge still shows "Couldn't complete the purchase". Saying "your purchase
went through" there would be wrong for the far more common case where nothing
was sold. RevenueCat's SDK retries a held purchase when the app next comes to the
front, and Restore still works.

## Needs Jack

Nothing blocking. Not uploaded to Play; the fixes ship with the next Android
build when you ask for one.
