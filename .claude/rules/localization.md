---
paths:
  - "CribbageTrainer/**"
  - "Shared/**"
  - "CribbageTrainerScreenshots/GermanScreenshotTests.swift"
  - "Tools/Localization/**"
---

# Cribbage Trainer: localization (added 2026-10-30)

The app ships in English plus German (`de`). Non-English markets trialed at
about 6% against 15 to 19% for US/UK/CA/AU across the fleet (Sober, 2026-10-27)
while the App Store pages were already translated, so the copy inside the app
is the lever. German was the one language done to a native standard; add
others only when they can be written as well.

## Setup
- One catalog, `Shared/Localizable.xcstrings` (source `en`, every key
  `extractionState: manual`), compiled by the app target. XcodeGen 2.39+ reads
  its languages into `knownRegions`; `CribbageTrainer/Info.plist` also lists
  them in `CFBundleLocalizations`. No `InfoPlist.xcstrings`: there are no
  permission purpose strings and the display name is the brand.
- `python3 Tools/Localization/check.py` (repo root, no Xcode needed) fails on a
  source literal with no key, a key missing a language, mismatched format
  specifiers, or an em dash in a translation. Run it before every build that
  touches copy.
- `LocalizationTests` proves `de.lproj` ships, German plurals and
  substitutions resolve, and English says "1 drill" not "1 drills".
  `GermanRuntimeTests` runs the app's own string builders (card names, pegging
  summaries, generated explanations, Endless prompts, pricing terms) and only
  runs in a German test process, where a key whose interpolation type differs
  from the source (`%lld` against `%@`) shows up as English:
  `gh-sim test --only CribbageTrainerTests/GermanRuntimeTests --testarg -testLanguage --testarg de --testarg -testRegion --testarg DE`.

## Adding or changing copy
- `Text("literal")`, `Button`, `Label`, `Section`, `navigationTitle`, `alert`
  and friends localize themselves. Copy held in a `String` (drill content,
  view parameters, enums, notifications, errors) must be
  `String(localized: "...")`. Logs, analytics, RevenueCat metadata, feedback
  tags and identifiers stay plain.
- The catalog key is what Swift generates: an `Int` interpolation is `%lld`,
  a `String` is `%@`. check.py compares them loosely, so get the type right
  by hand and cover new generated sentences in `GermanRuntimeTests`.
- Whole sentences only. `PeggingScoring.Result.summary` joins at most two
  whole parts with the `"%@ and %@"` key; each part ("%lld for a pair") is its
  own key. Card names are one key per face rank (`"J of %@"` is "Herz-Bube").
- Counts are plural variations (en and de both carry `one`), or a `%#@n@`
  substitution when the sentence has other arguments; the other arguments then
  need positional specifiers (`%2$@`).
- Stored English values are translated at display time: churn chips are sent
  as English tags and shown through `ReviewPromptSheet.chipLabel(_:)`.
  `DiscardScenario.isDealer` is stored because the situation line is
  translated. `PlayingCard.stableName` stays English for orderings that must
  match on every device (the daily discard's distractors).
- No `.capitalized`/`.lowercased()` on translated text. Dates use
  `setLocalizedDateFormatFromTemplate`; percentages use `Double.percentText`.
- Prices only from StoreKit (`PaywallPricing`).
- Card corner letters stay A/J/Q/K in every language because the tiles draw
  them; German prose names the cards (Ass, Bube, Dame, König) but hand shapes
  such as "5-5-10-Q" keep the tile letters.

## German terms
Informal "du". Crib (die Crib), Startkarte, Pegging/peggen, Go, Fünfzehn
(Fünfzehnen), Paar, Drilling (pair royal), Vierling (double pair royal), Folge
(Dreierfolge, Doppelfolge), Flush, His Nobs, His Heels, Muggins, Geber and
Vorhand (pone, also used for "non-dealer"), Stand (running total), Zehnerkarte
(ten-value card), Bildkarten. Features: Endlos-Training, Gegen die Uhr, Fehler
üben, Spieleabend-Vorbereitung, Meistertische; Cribbage Minute and Cribbage+
stay as brands. Room names: Kartenraum, Punkteraum, Abwurfraum, Pegging-Raum.

## Proving a change
`gh-sim all --screen "-AppleLanguages (de) -AppleLocale de_DE"` for the first
onboarding page, and the Screenshots scheme's `GermanScreenshotTests` for the
trial page, paywall, Home, rooms, drills and member features:
`gh-sim test --scheme Screenshots --only CribbageTrainerScreenshots/GermanScreenshotTests`.
Simulator runs never configure RevenueCat, so prices read "Preis wird
geladen…" there; that is the placeholder, not a bug.
