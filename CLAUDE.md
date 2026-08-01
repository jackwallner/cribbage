# Cribbity project guide

Cribbity is a practice app for standard-deck cribbage. It teaches
counting, pegging, discarding, and table decisions through short drills. It is
not a full multiplayer game. The XcodeGen project and scheme are
`CribbageTrainer`, the headless simulator is `agent-cribbage`, and the bundle ID
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
the free versus Cribbity+ split.

The review funnel is intentionally terminal. After the third positive drill,
`ReviewPromptSheet` asks whether the player is enjoying the app. Yes opens the
App Store review page when `AppStoreLinks.appStoreID` is configured, otherwise
it uses Apple's in-app request. No opens the feedback mail draft. Do not ask an
unhappy player for a rating.

## Cribbity+ products

The local StoreKit configuration contains:

- `com.jackwallner.cribbage.monthly`, $1.99 per month, one-week trial
- `com.jackwallner.cribbage.yearly`, $9.99 per year, one-week trial
- `com.jackwallner.cribbage.lifetime`, $29.99 one time

The RevenueCat entitlement remains `pro` for fleet compatibility. The player
facing membership name is `Cribbity+`. The public RevenueCat key lives in
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

The beginner rooms are free. Each free room has one extra Cribbity+ set. The
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
2. Register the drill in `DrillLibrary` and assign its free or Cribbity+ state.
3. Add or update invariants in `ContentValidityTests`.
4. Regenerate the Xcode project with `xcodegen generate`.
5. Run the unit tests and inspect the room in `agent-cribbage`.

The reusable porting workflow for future card apps lives in the sibling
`/Users/jackwallner/cardport` folder. Start with its README, then use the
scaffold and validation scripts before replacing the model and content.

## Build and simulator rules

Use `xcodegen generate` after adding or removing Swift files or changing
`project.yml`. Build with the `CribbageTrainer` scheme. Use only the dedicated
`agent-cribbage` simulator for runtime checks. Do not open Simulator.app.

The repository's release scripts expect App Store Connect credentials from the
local credential file and must never print those credentials. The App Store ID
is not set yet, so the review funnel currently falls back to the in-app review
request until the Cribbage App Store record exists.

See `CribbageTrainer/Views/Drills/CLAUDE.md` for the gesture and flip
invariants of the signature swipe deck.
