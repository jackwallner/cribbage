# Cribbage Trainer project guide

Cribbage Trainer is a practice app for standard-deck cribbage. It teaches
counting, pegging, discarding, and table decisions through short drills. It is
not a full multiplayer game. The XcodeGen project and scheme are
`CribbageTrainer`, runtime checks use a checked-out shared agent-sim group, and the bundle ID
is `com.jackwallner.cribbage`.

## Product rules

The swipe deck is the signature interaction, but the app is not only a
flashcard app. Each room can use the mechanic that best fits its skill:
choice questions, hand recognition, discard scenarios, or generated practice.

All authored examples are original teaching hands. They illustrate standard
cribbage rules without copying any external card, lesson, or branded rules
source. House rules vary, so copy should identify the rule being taught when a
variation is common.

`ContentValidityTests` is the safety net for every drill in `DrillLibrary`.
Keep IDs unique, use a 52-card deck, do not repeat a physical card in one hand
or deal, keep discard scenarios at six cards with two recommended discards,
keep player-facing copy free of em dashes and stale domain terms, and preserve
the free versus Cribbage+ split.

The review funnel is intentionally terminal. After the third positive drill,
`ReviewPromptSheet` asks whether the player is enjoying the app. Yes opens the
App Store write-review page for `6796911073`. No opens the feedback mail draft.
Do not ask an unhappy player for a rating.

## Cribbage+ products

The local StoreKit configuration contains:

- `com.jackwallner.cribbage.monthly`, $1.99 per month, one-week trial
- `com.jackwallner.cribbage.yearly`, $9.99 per year, one-week trial
- `com.jackwallner.cribbage.lifetime`, $29.99 one time

This project has two entitlements, `pro` and `Cribbage+`, and every product is
attached to both. The scaffold keyed the entitlement to the player-facing name
and RevenueCat will not let a lookup_key be edited, so `pro` was added
alongside it: shipped binaries that check `entitlements["pro"]` and current
ones that accept any active entitlement both unlock on a purchase. Keep both
fed, which `scripts/rc-wire-appstore-products.py` does idempotently along with
creating the App Store products and attaching them to the `$rc_monthly` /
`$rc_annual` / `$rc_lifetime` packages of the current offering. Products
existing only on the Test Store app, which serves an offering with zero
packages, is what got build 21 rejected, so run
`scripts/verify-store-config.py` before any submission. The player
facing membership name is `Cribbage+`. The public RevenueCat key lives in
`Shared/Services/SubscriptionService.swift`. The simulator guard must remain
in place so the production `appl_` key is never configured by simulator builds.
Use the local StoreKit file and the Settings local membership override for
simulator purchase testing.

## Architecture

- `Shared/Models` contains `PlayingCard`, `Suit`, `HandCategory`, drill models,
  and room locking.
- `Shared/Content` contains the authored card basics, scoring, discarding,
  pegging, primer, plus, and Master Tables content. `DrillLibrary.rooms` is the
  source of truth for the five rooms.
- `Shared/Services` contains progress, settings, spaced review, subscriptions,
  notifications, and the review funnel.
- `CribbageTrainer/Views` contains onboarding, the home lobby, room screens,
  the swipe deck, quick sessions, generated practice, settings, and the
  paywall.
- `CribbageTrainer/Utilities/Theme.swift` contains the warm card-table visual
  system, haptics, sounds, and reusable view styles.

The beginner rooms are free. Each free room has one extra Cribbage+ set. The
Master Tables room is membership-only. `Room.isLocked(_:isMember:)` is the
single locking rule, and `SessionBuilder` applies the same rule to Quick
Session content.

Generated practice uses `HandGenerator` for mutually exclusive five-card
teaching shapes, `PracticeRecordStore` for spaced review, and
`PracticeRunView` for Endless, Review, and Timed modes. Generated questions
must remain finite, valid, and independent of authored IDs.

## Content workflow

When adding a room or card set:

1. Add original content under `Shared/Content`.
2. Register the drill in `DrillLibrary` and assign its free or Cribbage+ state.
3. Add or update invariants in `ContentValidityTests`.
4. Regenerate the Xcode project with `xcodegen generate`.
5. Run the unit tests and inspect the room on the checked-out agent-sim UDID.

The reusable porting workflow for future card apps lives in the sibling
`/Users/jackwallner/cardport` folder. Start with its README and
`docs/parity-contract.md`, then use the scaffold and validation scripts before
replacing the model and content. The port must preserve this app's full
runtime, release, website, legal, and screenshot surface.

## Build and simulator rules

Use `xcodegen generate` after adding or removing Swift files or changing
`project.yml`. Build with the `CribbageTrainer` scheme. Use only a checked-out
shared agent-sim group for runtime checks. Do not open Simulator.app.

The repository's release scripts expect App Store Connect credentials from the
local credential file and must never print those credentials. The App Store ID
is `6796911073`, and the review funnel opens the app's App Store write-review
page after the enjoyment gate.

See `CribbageTrainer/Views/Drills/CLAUDE.md` for the gesture and flip
invariants of the signature swipe deck.

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

## iPad (1.2)

iPad support is free: `TARGETED_DEVICE_FAMILY "1,2"`, portrait and landscape,
adaptive Home columns, drill grids, and readable content widths.

Every drill body is a scroll view, so a question that underfills the viewport
was pinned to the top and left the bottom half of a 13-inch iPad empty.
`CenteringScrollView` centres short content and leaves taller content scrolling
untouched (minHeight, not height). Keep its `maxWidth: .infinity`: a plain
ScrollView centres narrow content for you, an explicitly framed one does not.
The room eyebrow lives INSIDE `QuestionPager` so it centres with the question,
and the flashcard deck is capped at 520pt wide so a card still looks like a
card.

## Screenshots

`scripts/capture-screenshots.sh <udid> <out-dir> [prefix]` drives the real app
through the App Store screens via the `Screenshots` scheme.
`scripts/with-ipad-sim.sh` creates a throwaway 13-inch iPad (App Store iPad
shots must be 2064x2752 and the agent-sim pool has no iPad Pro), boots it
headless, and deletes it on exit:

```bash
./scripts/with-ipad-sim.sh sh -c './scripts/capture-screenshots.sh "$IPAD_UDID" out ipad_'
```

Gotchas baked into the test: the What's New sheet covers Home on the first
launch after a version bump and returns every time Home reappears, so the
script passes the marketing version in through
`TEST_RUNNER_SCREENSHOT_APP_VERSION` and the test marks it seen; returning to
the root only taps navigation-bar button 0 while a back button is there,
because on Home that button is the Settings gear; and the test never calls
XCTFail, because a failing UI test spends ten minutes collecting simulator
diagnostics first.
