# State machine audit: Cribbage Trainer (2026-11-06)

Scope: iOS app and `Shared/` code at commit `7951326` (clean tree, `git stash -u` had nothing to stash). There are no widget, watch or backend targets in this repo (`project.yml` has the app, unit tests, screenshots and one UI test target; `scripts/` holds only release and store tooling). Android is out of scope. Nothing was fixed.

**Summary: 4 bugs. 3 proved by test (R1, R2, S1), 1 code path only (U1, with store-level consequence tests that do not run the view). 0 money or entitlement bugs found.**

Test runs: `gh-sim test --only CribbageTrainerTests/StateMachineAuditRepro`, run 42283170327 (first, 6 failed, 3 passed) and run 42287893714 (final, 5 failed, 4 passed, iPhone 17, iOS 27.2). The suite is in `state-machines-2026-11-06-repro.swift`. All four control tests pass in the final run. Every `testBUG_*` assertion that fails is quoted below with the recorded value.

## Bugs, ranked by users reached times cost

| id | bug | what the user sees | promise | user route | impact | evidence | file:line |
|---|---|---|---|---|---|---|---|
| R1 | Reminder toggles are never reconciled with what iOS has pending or permits. `AppSettings.init` restores the flags and schedules nothing; the only scheduler calls are the toggle's granted callback and the time/day `didSet`s. | Settings shows Daily Reminder (and Game Night Prep weekly reminder) ON with a time, no alert, but no notification ever fires. | "Time for a quick drill" repeating reminder the toggle turns on (`SettingsView.swift:101-104`); `AppSettings.swift:89-91`: "True when the player asked for a reminder but iOS notifications are off. Without this the toggle just silently flips back, which looks like the app is broken." The warning alert (`SettingsView.swift:63-72`, "Cribbage Trainer cannot send reminders until notifications are turned on in iOS Settings.") only ever appears in the moment of tapping the toggle. | Settings (gear on Home) > Practice > Daily Reminder shows ON. Reaching the bad state needs the flag persisted while no request is pending: restore to a new iPhone from a backup (defaults come back; pending local notifications are not part of an app backup, unverified here), or notifications turned off in iOS Settings and the app reopened (no code reads authorization status; grep for `getNotificationSettings`/`getPendingNotificationRequests` in app code finds nothing). | Everyone with a reminder ON who changes phone from backup or revokes and later regrants notifications. Small share of reminder users, but the cost is total and silent loss of the retention feature, with the UI affirming it is on. | Test: `testBUG_R1`, fake center (swizzled `add`, `removePending...`, `requestAuthorization`, granted). Preconditions asserted (both toggles read ON, `added == []`). Recorded: `Daily Reminder toggle is ON but nothing was scheduled, added=[]` and `Game night toggle is ON but nothing was scheduled, added=[]`. Control `testCONTROL_fakeCenterSeesScheduling` passes: turning the toggle on records `[cribbage.dailyReminder]`, changing the time records a second add. Scheduler call sites, all of them: `AppSettings.swift:166` (daily, after auth granted), `:99` (reminderTime didSet), `:201` (game night after auth granted), `:117` (gameNightDay didSet), `:126` (gameNightReminderTime didSet). `init` (`:132-149`) has none. What the test does not prove: how a real device ends with the flag ON and nothing pending (backup restore and revoked permission are the candidates). A device check of "restore from backup, then `getPendingNotificationRequests`" would settle it. | `AppSettings.swift:78-87,132-149,162-228`, `SettingsView.swift:101-104` |
| U1 | Flashcard Undo restores only the queue. The answer it undoes stays in `ProgressStore` and `PracticeRecordStore`, and re-answering records a second attempt. | After Undo and a new pick, the item has 2 attempts. A right-then-undo-then-right pick reads as "two right answers in a row" (known, counts toward the weekly gain chip). A wrong-then-undo-then-right pick keeps the item in Fix My Mistakes. | Undo button, accessibility label "Undo last answer" (`FlashcardDrillView.swift:88`). `Mastery.swift:86`: "Known means answered right twice in a row". `PracticeRecord.needsReview` (`PracticeRecordStore.swift:29-31`): "has been missed at least once and has not yet been answered right twice running". | Home > The Pegging Room (free) > Pegging Judgment (cards carry Keep/Discard choices, 8 of them in `KeepDiscardContent`). Pick a choice (graded and recorded in `choose()`), tap the card to flip and swipe, tap the arrow in the top-right (Undo), pick again. Plain cards: swipe "again", Undo, swipe "got it" gives the same double record. | Anyone who uses Undo in a flashcard deck; Undo shows after every swipe. Cost is small: a skewed accuracy figure, an item parked in or credited by the review and mastery numbers. | **Code path** for the view: `undo()` (`:362-376`) mutates `queue`, `lastSwipe`, `choicePick`, `isFlipped` and calls no store; `choose()` (`:231-236`) and `commit()` (`:337-349`) record before the swipe. Consequence tests (store level, they model the view's calls and do not run the view): `testBUG_U1a` recorded `XCTAssertFalse failed - an undone answer should not count toward known`; `testBUG_U1b` recorded `undone answer still counted, attempts=2` and `needsReview=true after the miss was undone`. Control `testCONTROL_singleRightAnswerIsNotKnown` passes. A UI test that picks, flips, swipes, taps Undo, picks again, then reads Your Progress would settle the view part. | `FlashcardDrillView.swift:231-251,337-376`, `PracticeRecordStore.swift:86-114`, `Mastery.swift:93` |
| S1 | Streak stores `lastActiveDay` as an instant (start of day in the zone at the time) and compares calendar dates in the zone of the moment, so a zone change shifts the stored day. | Practice on Monday in Tokyo, fly west, practice Monday again in Los Angeles: streak shows 2 days. | `ProgressStore.swift:103`: "Streak counts consecutive calendar days with at least one finished drill." `:80-81`: "Whole calendar days from `earlier` to `later` in the player's time zone." | Finish any drill at Mon 23:00 in Tokyo (Home streak chip: 1). Phone moves to Los Angeles (Mon 06:00 there on the same instant). Finish a drill Mon 18:00 Los Angeles. Home chip and the drill-complete card show "2-day streak". Needs a west-bound zone change with practice on both sides inside one calendar day of the new zone. | Frequent travelers only, rare; cost is a streak inflated by one day (it self-corrects only by breaking later). | Test: `testBUG_S1`. Preconditions asserted (`Calendar.current.timeZone` is Asia/Tokyo then America/Los_Angeles; both instants are Nov 2 in Los Angeles; streak is 1 after the first drill). Recorded: `("2") is not equal to ("1")`. Control `testCONTROL_streakSameZone` passes (same day twice stays 1, next day is 2). | `ProgressStore.swift:87-124` (`today = startOfDay(for: now)` stored at `:105,122`; compared via `calendarDays` at `:109`) |
| R2 | `reminderTime` is a `Date` built in the zone current at launch, shown by the DatePicker in whatever zone is current later; the stored hour and the pending trigger are zone-less (hour 9). | After a zone change with the process alive, Settings > Reminder Time shows a different time than the one that will fire. | `SettingsView.swift:103`: "Reminder Time" picker is the control for when the daily notification fires; trigger uses `hour`/`minute` components (`AppSettings.swift:184-186`). | Daily Reminder ON at 9:00 in Tokyo. Travel to Los Angeles without the app being terminated (suspended apps survive zone changes). Open Settings: the picker reads a different hour. Relaunch heals the display. If the player toggles the reminder off and on in that state, the new zone's hour is scheduled while `settings.reminderHour` keeps 9 (`:96-98` only runs when `reminderTime` itself changes). | Reminder users who travel across zones with the app resident and open Settings; display mismatch only, the fire time stays at the local 9:00. | Test: `testBUG_R2`. Preconditions asserted (zone is Tokyo, picker hour 9, stored `settings.reminderHour` 9, then zone is Los Angeles). Recorded: `("15") is not equal to ("9") - picker would show hour 15 while the stored hour and trigger are 9`. (`Calendar.date(from:)` with only hour/minute resolves to year 1, so historic offsets make the shown hour differ from a naive shift; any value other than 9 breaks the claim.) Control `testCONTROL_reminderPickerHourMatchesStoredHourInOneZone` passes. | `AppSettings.swift:94-101,140`, `SettingsView.swift:103` |

## Product calls (no promise to quote, not counted)

- Fix My Mistakes "Close" after answering part of the run goes to the completion screen as `k/total` over the whole queue and records a finished drill (streak day, completions) (`PracticeRunView.swift:322-333`, comment at `:326`: a run quit before answering anything "is not an achievement"). One answered question already counts.
- The daily reminder is a fixed repeating notification and fires on days the player already practiced (`AppSettings.swift:157,186`). Documented as intentional static text.
- A lapsed member's game night reminder is turned off by Home only on an observed `isPro` true to false change (`HomeView.swift:118-128`); it is not restored on re-subscribing. Looks intentional.
- A lapse then re-subscribe inside seven days raises the member-only mastery total again and shows "Up N questions this week" with no new practice (`HomeView.swift:202-206`, `MasteryLedger.swift:46-51`). No promise on the chip's causality.
- `SubscriptionService.loadOfferings` assigns `try? await ...` so one failed call nulls already-loaded offerings (`SubscriptionService.swift:252-255`). Whether the SDK returns cached offerings on that failure is not settled here; it would need a RevenueCat fixture. Not counted.
- Home and Cribbage Minute compute "today" in `body` (`CribbageMinuteView.swift:7-9`, `HomeView.swift:192-196`), so an app left open across midnight shows the previous day's cards until something re-renders. Not reproduced; SwiftUI re-render timing was not tested.

## Related fixes, in order

1. Reconcile reminders on launch and each return to the app: read notification authorization and pending requests, reschedule when the flag is on and authorized, and when the flag is on but permission is off, flip it and show the existing alert. Closes R1 for both reminders. Add an injected center so it is testable.
2. Persist the reminder as hour/minute only and build the picker's `Date` fresh each time the zone is read (or use `Calendar.autoupdatingCurrent`). Closes R2.
3. Persist `lastActiveDay` and `lastQuickSessionDay` as a zone-free day string or day number and compare those. Closes S1 and the same shape in `quickSessionCompletedToday` (`ProgressStore.swift:145-152`).
4. Make flashcard Undo revert the store changes of the swipe it undoes (snapshot the `PracticeRecord` and seen/missed sets before recording, restore on Undo). Closes U1.

## State machines

Notation: invariants are `Ix`; a transition marked `breaks Ix` is reachable. "Fine" means checked and sound.

### M1. Membership and entitlement (`SubscriptionService`)

State is spread across: `isPro`, `membershipResolved`, `isTrialing`, `expirationDate`, `offerings`, `isConfigured`, `membershipRecovery` (a `Task?`), UserDefaults `membership.reinstallSyncDone`, DEBUG `subscription.localProOverride`.

States: Unconfigured (simulator, resolved at `start()`), Unresolved (configured, no record read), Free, Trial, Paid, Lifetime, plus the Recovering flag (reinstall sync running).

Invariants:
- I1 `isPro == (any active entitlement) || debug override`, set only by `apply`.
- I2 Nothing treats "not a member" as a lapse or sells a trial before `membershipResolved` (`SubscriptionService.swift:36-40`).
- I3 A purchase waits for the reinstall sync, capped at 3 s (`:116-131,301-307`).
- I4 `isTrialing` and `expirationDate` always describe the same entitlement that set `isPro` (`:365-385`).

| from | event | to | notes |
|---|---|---|---|
| Unresolved | cached record applied (`start`) | Free/Trial/Paid | stale cache can show active; RevenueCat behaviour, not provable here |
| Unresolved | network record | any | fine |
| any | delegate `receivedUpdated` / refresh / restore / purchase | `apply(info)` | last writer wins, no `requestDate` ordering; sound only if SDK delivers in order (code path, not counted) |
| Free | purchase | Trial/Paid/Lifetime | `startedTrial` from `periodType` (`:328`); fine |
| Free + StoreKit owns entitlement + RC empty | `recoverReinstalledMembership` | Paid | key set only after a successful sync; retried until then; fine |
| any | purchase cancelled | unchanged | `PurchaseOutcome.cancelled`; fine |
| any | `loadOfferings` fails | `offerings = nil` | product call above |

No invariant break found in this machine.

### M2. Churn ask (`observe`, `MembershipTransitions`, Home prompt)

State: stored snapshot `membership.lastSnapshot` (nil or active/trial/willRenew), `churnAskSpent`, `pendingChurnMoment` (stored and published), Home's `churnPrompt`.

Invariants: I1 at most one moment per departure; I2 a queued moment is dropped if the member comes back; I3 a first record only becomes the baseline if under 5 minutes old; I4 a moment is spent only when shown (`HomeView.swift:211-218`).

Transitions: nil to snapshot (stale cache): no baseline, no ask. active+renew to renewal off: moment, spent. Spent plus lapse: no second ask by design. Back to active+renew: `resetsAsk` clears spent and pending. Billing issue counts as renewing. Prompt shown: `consumeChurnMoment`, then spent stays until reset. Several 0.9 s tasks racing: the first consumes, the rest see nil (MainActor). Checked with `MembershipTransitionsTests` shapes; no break found.

### M3. Onboarding and trial (`OnboardingView`)

State: `page` (0-4), `stage` (pages/howToPlay/tour), `purchasing`, `restoring`, `trialEligible`, `showPaywallFallback`, `purchaseError`, AppStorage `cribbage.skillLevel`, `progress.hasOnboarded`.

Invariants: I1 skill is chosen before the trial page (swipe past is reverted, `:98-106`); I2 the CTA buys the monthly trial only if eligibility matches what the page shows (`:617-620`); I3 a member never reaches Apple's sheet (`:583-600`); I4 `hasOnboarded` flips only in `finish()`.

Transitions: purchase success with unconfirmed entitlement stays on the trial page with an error, later `isPro` flips the CTA to Continue (fine). Force quit during the tour after a purchase: `stage` is not persisted, onboarding restarts at page 0 with the Continue CTA for the member (inconvenient, no money lost, not counted). `fullScreenCover(onDismiss: onDone)` makes any dismissal finish onboarding, which is intended.

### M4. Paywall (`PaywallView`)

State: `selectedPlan`, `purchasing`, `restoring`, `loadingPrices`, `priceLoadAttempted`, `trialEligible`, `message`. Eligibility loads once in `.task` for the plan selected at that moment; Apple's eligibility is per subscription group, so switching monthly/yearly cannot change it. A purchase re-checks eligibility and returns without buying if it changed (`PaywallView.swift:456-458`). Closing the sheet mid-purchase leaves the Task running; the "purchase went through" message is lost with the view (cosmetic). No invariant break found.

### M5. Reminders and notification routing (`AppSettings`, `AppRouter`, `AppDelegate`, `HomeView`)

State: `reminderEnabled`, `reminderTime`, `gameNightReminderEnabled`, `gameNightDay`, `gameNightReminderTime`, `reminderPermissionDenied` (shared by Settings and Game Night Prep alerts), pending iOS requests `cribbage.dailyReminder` and `cribbage.gameNightReminder`, `AppRouter.pendingDestination`, Home `pendingAfterUpgrade`, `membershipWaitOver`.

Invariants: I1 flag ON implies a request pending and permission granted; I2 flag OFF implies no request pending; I3 reminder time shown equals trigger time; I4 game night flag ON implies member.

| from | event | to | notes |
|---|---|---|---|
| off | toggle on, auth granted | on + scheduled | fine |
| off | toggle on, auth denied | off + alert | fine (callback sets flag false, `didSet` cancels) |
| on | launch with nothing pending | on, nothing scheduled | **breaks I1 (R1)** |
| on | iOS permission revoked later | on, silently dead | **breaks I1 (R1, code path for this cause)** |
| on | zone change, process alive | picker shows another hour | **breaks I3 (R2)** |
| on | time/day change | reschedule | fine, replaces by id |
| on | toggle off | off + removed | fine |
| game night on | Home sees `isPro` true to false | off + removed | fine when observed; a lapse that is the first `apply` of a launch has no transition (`isPro` was already false), so I4 can break; narrow, depends on the RevenueCat cache, not counted |
| notification tap | `route(to:)` then Home `consumePendingDestination` | session or paywall | waits up to 4 s for `membershipResolved`; non-member gets the paywall, then `pendingAfterUpgrade` opens it after purchase; fine |
| notification tap | while Settings sheet is up | push under the sheet | Home's `showPaywall` cannot present over Settings; not reproduced |

Not a bug: auth callback racing a toggle-off. The system prompt blocks the UI, and a decided permission answers within milliseconds.

### M6. Daily progress (`ProgressStore`)

State: `streakCount`, `lastActiveDay` (instant), `totalSessions`, `completions`, `seenItems`, `missedItems`, `lastQuickSessionDay` (instant), `sessionsAtOnboarding`.

Invariants: I1 streak counts distinct calendar days; I2 a skipped day resets the next finish to 1 and `currentStreak()` reads 0; I3 a backward clock does not double count; I4 Get Started is spent once per calendar day.

Transitions: same day, +1 day, gap above 1, backward clock (`:114-118`, fine). Zone change: **breaks I1 (S1)**. DST at midnight: handled by date-number compare (`:87-101`, fine). Reset Progress clears all of the above plus ledger, records and Minute results (fine; `sessionsAtOnboarding` removed so Home extras wait for a new practice).

### M7. Practice records, mastery, ledger (`PracticeRecordStore`, `Mastery`, `MasteryLedger`)

State per item: `attempts`, `correct`, `streak`, `dueDate`, `intervalDays`, `ease`, `reviewSuppressed`. Derived: review queue, `isKnown`, room mastery, daily ledger snapshot, weekly gain.

Invariants: I1 each graded answer is recorded once; I2 `needsReview` iff missed and not right twice running; I3 generated items collapse to one skill row; I4 ledger is idempotent per day and written only after `membershipResolved`.

Transitions: answer in quiz/hand-match/discard/session/run: once (fine). Flashcard answer then Undo then answer: **breaks I1 (U1)**. Generated item: collapsed (fine). Free to member: no jump because locked sets cannot hold answers. Member to free to member inside a week: fake gain (product call).

### M8. Cribbage Minute (`CribbageMinuteStore`, `CribbageMinuteContent`)

State: `results[dayKey]`, key from `Calendar.gregorianLocal` in the current zone. Invariants: I1 one result per day key, the first wins (`record` returns the existing result, `:58`); I2 a challenge finished after midnight is stored under the day it started; I3 weekly count uses `completedAt`. Checked; a replay of a completed day cannot start from the UI (archive row shows the result), so I1 holds. Zone change maps the same instant to a different day key, so the same Monday can appear completed in the new zone; matches the documented local-calendar rule.

### M9. Review prompt (`ReviewPromptTracker`, `requestsReview`)

State: launch count (every cold `App.init`), `lastShown`, `outcome`. Gates: onboarded, remote switch, second launch, 30 days, no alert or share sheet on top, view still on screen after 3 s. Opening write-review is the only terminal state. `markShown` is written when the call is made, as documented. Checked; no break.

### M10. Feedback queue (`FeedbackService`)

States: sent, queued (cap 20), dropped (4xx other than 408/429). Flush iterates a snapshot and removes by value from the live queue, so rows enqueued during a flush survive; `isFlushing` guards reentry. Checked; no break.

### M11. What's New (`WhatsNew`)

`lastSeen` marker, `currentRelease` newest at or below the running version, marked seen when shown, baseline stamped at the end of onboarding. Checked; no break.

### M12. Flashcard deck session (`FlashcardDrillView`)

State: `queue`, `isFlipped`, `choicePick`, `lastSwipe`, `drag`, `isFlinging`, `finished`. Invariants: I1 only a flipped card swipes; I2 a choice card is graded once at pick (`guard choicePick == nil`); I3 Undo restores everything the swipe changed. Undo breaks I3 for the stores (U1); the queue part is exact (removes the re-appended card, reinserts at front).

### M13. Timed, Endless and Review runs (`PracticeRunView`)

State: `items`, `index`, `selection`, `attempted`, `secondsRemaining`, `finished`. The clock is a `Task.sleep` loop, so it pauses while the app is suspended (a 90 s run lasts 90 s of foreground time). `finish()` records the best timed score before the zero-attempt guard (`:322-333`). No break; see the Close product call.

### M14. Home overlay arbitration (`HomeView`)

State: `showSettings`, `showPaywall`, `showWhatsNew`, `churnPrompt`, `path`, `homeOnScreen`, `pendingAfterUpgrade`. `homeIsBare` gates What's New and the churn prompt; each waits a beat and re-checks. `showPaywall` set while Settings is up is a possible stuck state (see M5 last row), not reproduced.
