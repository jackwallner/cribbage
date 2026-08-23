# Cribbity / Cribbage Trainer audit

Audit date: 2026-08-23  
Repository: `/Users/jackwallner/cribbage`  
App Store ID: `6796911073`  
Bundle ID: `com.jackwallner.cribbage`  
Product name: `Cribbage Trainer: Count & Peg`  
Installed display name: `Cribbage Trainer`  
Membership: `Cribbage+`

## How to read this audit

Direct evidence is prefixed `Evidence`. Inferences from the code or product
surface are prefixed `Inference`. Proposed work is prefixed `Recommendation`.
No production download, trial, conversion, rating, retention, revenue, crash,
or review metrics are fabricated here. Live App Store Connect and RevenueCat
account data were not available in this worker. The local ASC readiness script
stopped with `error: set ASC_API_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH`, so all
live-state claims remain open validation items.

The owner explicitly excluded reporting the RevenueCat tracking/data-collection
disclosure inconsistency. This audit therefore does not treat that as a
finding. It does call out other product, metadata, website, legal, pricing,
configuration, and operational consistency issues.

## Executive assessment

Cribbage Trainer has a clear, defensible position: a short, explanation-first
practice companion for counting, pegging, discarding, and table decisions, not a
full multiplayer cribbage game. The free surface is unusually generous and the
first-value path has been deliberately engineered around a five-minute Quick
Session. The repository also contains a thoughtful review gate, StoreKit safety
guard, bounded offering readiness checks, a local purchase test configuration,
and a 50-locale metadata set.

The largest growth constraint is observability. The app can currently explain
its UX intent in comments, but it cannot answer basic funnel questions such as
which onboarding page causes abandonment, whether the trial CTA is seen,
whether a product load failure caused the fallback sheet, which locked feature
created purchase intent, or whether a paid player reaches a second session.
RevenueCat receives a custom paywall impression, but there is no first-party
event taxonomy for acquisition, activation, drills, review prompts, errors, or
retention. This makes download-to-trial and trial-to-paid optimization mostly
guesswork.

The most urgent non-analytics issue is release consistency. `project.yml` is on
marketing version 1.2.1 and build 29, while `README.md` still says marketing
version 1.0, the public site's structured data says software version 1.2.0,
and archived release notes still describe build 20 and version 1.0. The public
site also uses `jackwallner.com/ios/cribbage/` for canonical and Open Graph URLs
while App Store metadata and page links use `jackwallner.github.io/cribbage/`.
That can split indexing, create stale snippets, and weaken trust at the exact
point where a visitor decides to download.

Priority order:

1. Establish a privacy-safe event and error pipeline, or at minimum a local
   exportable event log plus RevenueCat attributes, so the funnel is measurable.
2. Reconcile current ASC, RevenueCat, StoreKit, price, trial, version, and
   entitlement state with one release source of truth before shipping.
3. Fix website canonical/version/schema inconsistencies and verify every live
   URL, screenshot, and App Store deep link.
4. Instrument and test onboarding, first session, locked-feature intent,
   offering-load failures, purchase outcomes, restore, review flow, and daily
   rituals.
5. Run controlled paywall and onboarding experiments only after the baseline
   funnel is observable.

## Product, positioning, and likely usage

### Direct evidence

- `README.md` and `CLAUDE.md` describe five-minute drills for counting,
  pegging, discarding, and table decisions, with no opponents and no full game.
- `docs/research/aso-cribbage.md:12-36` identifies new and returning players
  who want short practice reps, with room-based practice, generated hands,
  mistake review, and no account requirement as differentiators.
- `Shared/Content/DrillLibrary.swift` is the source of truth for five rooms:
  Card, Scoring, Discard, Pegging, and Master Tables.
- `Shared/Content/SessionBuilder.swift` creates a mixed Quick Session, review
  sessions, and paid/free variants.
- `Shared/Services/ProgressStore.swift:51-90` stores completed sessions, streak,
  seen items, and missed items locally.
- `Shared/Services/CribbageMinuteStore.swift` and
  `CribbageTrainer/Views/GameNightPrepView.swift` support a daily challenge and
  a scheduled game-night preparation ritual, both described as Cribbage+.
- `docs/index.html` describes a free tier with four practice rooms, flashcards,
  hand reading, and streaks, then lists Endless Practice, Fix My Mistakes,
  Timed Challenge, extra room sets, and Master Tables as paid value.

### Inference

The main user jobs are likely: learn the rules, improve counting accuracy,
make better discards before a real game, refresh skills between games, and
prepare shortly before a regular game night. The high-intent moment is not the
end of onboarding itself. It is the first correct or instructive answer that
proves the explanation loop is useful, followed by a second session or a
return to a missed item. The strongest paid value is recurring practice and
mistake recovery, not merely access to more authored cards.

The likely acquisition mismatch is that the App Store name and listing can be
read as a cribbage game by users searching for an opponent, while the app is a
trainer. That is a valid niche, but the first screenshot, subtitle, and first
paragraph must make “practice companion, not a full game” clear without making
the product sound small or academic.

### Recommendations

- Make “five-minute cribbage practice” the primary acquisition promise, with
  counting, pegging, and discarding as the concrete proof.
- Keep “not a full multiplayer game” in the description and support page, but
  do not lead the first screenshot with a limitation. Lead with a real decision
  and its explanation.
- Treat `Cribbage Minute` and `Game Night Prep` as retention and paid-value
  pillars in the listing, website, onboarding tour, and paywall. They currently
  appear mainly in release notes and later surfaces.
- Validate this positioning with App Store Connect Product Page Optimization:
  control focused practice versus a skill-specific “count, peg, discard”
  variant. Do not change several claims in one treatment.

## Download growth and acquisition plan

### Evidence and limits

- The repository contains a public landing page, App Store ID
  `6796911073`, 50 metadata localizations, six iPhone screenshots, six iPad
  screenshots, and no App Preview video.
- `docs/index.html` has JSON-LD `MobileApplication` data, App Store links, and
  hard-coded offer and rating fields. Its canonical origin is different from
  the GitHub Pages URLs used by metadata and image assets.
- No live App Store Connect downloads, impressions, product-page views,
  conversion, search terms, paid acquisition, referral, or review data was
  available in the repository or claimed in this audit.

### Growth hypotheses to measure

1. The highest-intent searcher wants to practice a decision, not play a full
   opponent game. Measure listing conversion for the current broad title
   against a Product Page Optimization treatment that leads with five-minute
   counting, pegging, and discard practice.
2. Screenshot 1 and the first landing-page viewport should prove the answer,
   explanation, and short-session loop. Measure product-page conversion and
   landing-page App Store click-through separately.
3. A visitor who sees Cribbage Minute, Fix My Mistakes, or Game Night Prep may
   have stronger paid intent than a visitor who only sees generic “more drills.”
   Measure paid feature page views, paywall opens, plan choice, and trial
   starts by acquisition treatment.
4. English-only in-app UI paired with 50 localized listings may create an
   install-to-activation drop in non-English storefronts. Compare downloads,
   first session completion, and refunds by locale before investing in full
   localization.

### Required ASC baseline

Pull a dated baseline for each storefront and app version, retaining the exact
ASC query filters: impressions, product-page views, downloads, conversion,
proceeds, trial starts, subscription starts, cancellations, refunds, ratings,
reviews, and search terms. Break out organic search, browse, web referral, and
campaign links where ASC provides them. Do not compare a PPO treatment with the
control until the treatment has enough impressions and a predeclared end date.

The implementation agent should define a funnel with these denominators:

```text
listing impression -> product-page view -> download -> first launch
-> onboarding completion -> first answer -> first session completion
-> paywall impression -> trial CTA -> StoreKit purchase -> active entitlement
-> second session -> day-7 return
```

Every rate needs its denominator, app version, storefront, acquisition source,
paywall source, and eligibility definition. RevenueCat paywall impressions
alone cannot stand in for downloads or trial starts.

## App Store Connect metadata audit

### Local metadata inventory

`python3 scripts/validate_metadata.py` passes: 50 locales, required fields,
limits, and fallback fields are present. The local locale directories are:
`ar-SA`, `bn-BD`, `ca`, `cs`, `da`, `de-DE`, `el`, `en-AU`, `en-CA`, `en-GB`,
`en-US`, `es-ES`, `es-MX`, `fi`, `fr-CA`, `fr-FR`, `gu-IN`, `he`, `hi`,
`hr`, `hu`, `id`, `it`, `ja`, `kn-IN`, `ko`, `ml-IN`, `mr-IN`, `ms`,
`nl-NL`, `no`, `or-IN`, `pa-IN`, `pl`, `pt-BR`, `pt-PT`, `ro`, `ru`, `sk`,
`sl-SI`, `sv`, `ta-IN`, `te-IN`, `th`, `tr`, `uk`, `ur-PK`, `vi`, `zh-Hans`,
and `zh-Hant`.

The counts below strip the terminal LF in each checked-in text file because
that LF is not part of the App Store value. `name`, `subtitle`,
`promotional_text`, `description`, `release_notes`, and URLs are Unicode
character counts. `keywords` is the UTF-8 byte count used by the validator and
ASC. This distinction matters for exact capacity decisions.

The `en-US` local field lengths are:

| Field | Local count | Apple limit / note | Assessment |
| --- | ---: | --- | --- |
| Name | 29 | 30 | One character remains |
| Subtitle | 28 | 30 | Two characters remain |
| Keywords | 96 bytes | 100 bytes | Four bytes remain |
| Description | 2,444 chars, 2,448 bytes | 4,000 chars | Room for sharper proof and FAQ copy |
| Promotional text | 148 | 170 | 22 characters remain |
| Release notes | 650 | 4,000 | Current release notes fit |
| Marketing URL | 39 | URL | `github.io` path |
| Privacy URL | 53 | URL | `github.io` path |
| Support URL | 46 | URL | `github.io` path |

`en-US/name.txt` is `Cribbage Trainer: Count & Peg`. The subtitle is
`Counting, Pegging & Discards`. The keyword field is
`practice,scoring,crib,board,pegboard,muggins,beginner,lesson,drill,rule,strategy,quiz,skunk,game`.

Exact `name`, `subtitle`, and `keywords` counts for every localizable
storefront are below. The keyword column is bytes, not Unicode characters.

```text
locale   name  subtitle  keywords_bytes
ar-SA      23        26              93
bn-BD      25        21              89
ca         23        26              97
cs         25        26              91
da         22        20              94
de-DE      24        24              98
el         26        25              96
en-AU      29        28              96
en-CA      29        28              96
en-GB      29        28              96
en-US      29        28              96
es-ES      24        24              90
es-MX      24        24              90
fi         29        22              99
fr-CA      25        24              98
fr-FR      25        24              98
gu-IN      25        22              85
he         24        20              91
hi         24        27              98
hr         25        27             100
hu         27        26              96
id         26        28              91
it         24        23             100
ja         23        13              92
kn-IN      26        30             100
ko         22        14              95
ml-IN      26        27              93
mr-IN      22        27              98
ms         26        28              90
nl-NL      23        23              96
no         20        21              94
or-IN      26        22              97
pa-IN      25        26              95
pl         23        27             100
pt-BR      25        26              89
pt-PT      25        26              89
ro         27        29              93
ru         26        24              86
sk         25        27              92
sl-SI      22        30              96
sv         23        23              94
ta-IN      26        30              96
te-IN      26        27              96
th         25        26              79
tr         23        26              99
uk         26        30              96
ur-PK      21        20             100
vi         27        28              96
zh-Hans    22        16              91
zh-Hant    22        16              94
```

For completeness, the full local field count export is below. Columns are
`name`, `subtitle`, `keywords_bytes`, `promotional_text`, `description`,
`release_notes`, `support_url`, `marketing_url`, and `privacy_url`, in that
order. This is a repository snapshot, not a claim about what is currently
uploaded to ASC.

```text
locale   name subtitle keywords_bytes promo description release support marketing privacy
ar-SA       23      26            93    90         959      49      46       39      53
bn-BD       25      21            89   114         967      83      46       39      53
ca          23      26            97   115        1050      86      46       39      53
cs          25      26            91   112         984      76      46       39      53
da          22      20            94   112         992      58      46       39      53
de-DE       24      24            98   127        1154      68      46       39      53
el          26      25            96   114        1026      71      46       39      53
en-AU       29      28            96   122        2445     650      46       39      53
en-CA       29      28            96   122        2445     650      46       39      53
en-GB       29      28            96   122        2445     650      46       39      53
en-US       29      28            96   148        2444     650      46       39      53
es-ES       24      24            90   115        1116      78      46       39      53
es-MX       24      24            90   115        1124      78      46       39      53
fi          29      22            99   118        1013      89      46       39      53
fr-CA       25      24            98   127        1163      81      46       39      53
fr-FR       25      24            98   127        1167      81      46       39      53
gu-IN       25      22            85   107         921      74      46       39      53
he          24      20            91    96         882      48      46       39      53
hi          24      27            98   115         979      71      46       39      53
hr          25      27           100   111        1021      72      46       39      53
hu          27      26            96   127        1032      77      46       39      53
id          26      28            91   125        1080      73      46       39      53
it          24      23           100   130        1108      81      46       39      53
ja          23      13            92    60         644      30      46       39      53
kn-IN       26      30           100   120         992      90      46       39      53
ko          22      14            95    67         653      34      46       39      53
ml-IN       26      27            93   131        1077      90      46       39      53
mr-IN       22      27            98   109         972      78      46       39      53
ms          26      28            90   126        1099      88      46       39      53
nl-NL       23      23            96   123        1040      64      46       39      53
no          20      21            94   110         991      59      46       39      53
or-IN       26      22            97   113         939      80      46       39      53
pa-IN       25      26            95   103         972      80      46       39      53
pl          23      27           100   111        1047      75      46       39      53
pt-BR       25      26            89   128        1084      75      46       39      53
pt-PT       25      26            89   128        1107      75      46       39      53
ro          27      29            93   127        1034      78      46       39      53
ru          26      24            86   125        1069      72      46       39      53
sk          25      27            92   110        1004      78      46       39      53
sl-SI       22      30            96   117         994      75      46       39      53
sv          23      23            94   111         995      66      46       39      53
ta-IN       26      30            96   131        1099     104      46       39      53
te-IN       26      27            96   122        1018      91      46       39      53
th          25      26            79    97         969      51      46       39      53
tr          23      26            99   112        1097      64      46       39      53
uk          26      30            96   119        1073      79      46       39      53
ur-PK       21      20           100   111         964      74      46       39      53
vi          27      28            96   112        1065      59      46       39      53
zh-Hans     22      16            91    50         531      28      46       39      53
zh-Hant     22      16            94    50         534      28      46       39      53
```

### Keyword intent and duplication

#### Evidence

- `docs/research/aso-cribbage.md:38-64` maps cribbage, practice, counting,
  pegging, discard, lesson, and quiz to user intent and rejects competitor
  names, unsupported multiplayer claims, gambling language, scanning, and
  automatic analysis.
- The name contains `Cribbage`, `Trainer`, `Count`, and `Peg`.
- The subtitle repeats `Counting` and `Pegging`, and adds `Discards`.
- The description repeats nearly every core term many times, which is useful
  for conversion but does not make the keyword field more discoverable.
- The keyword field contains `crib`, `board`, and `pegboard` alongside the
  product name and subtitle concepts. It also contains `game`, despite the
  app explicitly not being a complete game.

#### Assessment and recommendations

The keyword field is within the limit and intentionally avoids obvious
competitor names, but it should be treated as a measured hypothesis rather
than a finished ASO result. `game` can attract the wrong intent. `muggins`,
`skunk`, and `board` may have lower volume or weaker fit than user-problem
terms. Apple tokenization and locale indexing need to be confirmed in ASC
search-performance data, which is unavailable here.

Test one keyword hypothesis per release or product page treatment. Candidate
sets to evaluate are:

- Search-intent set: `practice,scoring,crib,board,pegboard,muggins,beginner,lesson,drill,rule,strategy,quiz,skunk`
- Skill set: `practice,scoring,discard,pegging,counting,hand,quiz,lesson,beginner,drill,decision,coach`
- Beginner set: `learn,beginner,lesson,quiz,practice,scoring,crib,pegging,discard,counting,coach,training`

Do not assume adding a repeated word to keywords improves ranking. Record the
exact ASC keyword string, start/end dates, storefront, impressions, product
page views, conversion, and downloads for each test.

### Localization

#### Evidence

- All 50 localizations have the expected metadata files, and the validator
  passes.
- `docs/research/aso-cribbage.md:66-77` says storefront copy is localized but
  in-app UI remains English by design.
- Many localized descriptions contain translated subscription paragraphs, but
  their links remain the same English `github.io` URLs. This is acceptable for
  a single English legal page only if the page is usable for the storefront.

#### Risks and recommendations

- The repository proves file presence and limits, not native-language quality,
  local search demand, or live ASC upload state. Obtain native review for the
  highest-download storefronts first, then compare ASC performance by locale.
- The in-app English-only experience is a conversion risk for non-English
  storefront visitors. Either localize the first-value path, paywall/legal
  microcopy, and core room labels for the top locales, or make the listing
  explicit that the app is currently English.
- Validate that `name`, `subtitle`, `description`, `keywords`, `promotional_text`,
  and `release_notes` on ASC match the repository after every upload. The local
  scripts can upload, but no live pull was possible here.

### Screenshots, icon, and video

#### Evidence

- Six iPhone screenshot files are 1320 x 2868, valid for the 6.9-inch set.
- Six iPad screenshot files are 2064 x 2752, valid for the iPad set.
- The screenshot names cover Quick Session, Hand Match, Keep Discard, Pegging,
  Home, and Card Room. The compositor at
  `scripts/appstore_screenshot_compositor.py` declares headlines of no more
  than two lines and uses a consistent warm card-table frame.
- `CribbageTrainer/Assets.xcassets/AppIcon.appiconset/icon-1024.png` exists.
- No App Store preview video is present in the local screenshot/metadata tree.
- Visual spot checks of `fastlane/screenshots/en-US/01_quick_session.png`,
  `03_keep_discard.png`, and `05_home.png` show a consistent green felt and
  warm-card composition. They communicate “Practice between games,” a real
  discard decision, and a five-minute daily rhythm. `03_keep_discard.png`
  shows the disabled discard CTA before two cards are selected, which is
  useful product evidence but should not be mistaken for an ideal conversion
  frame. `05_home.png` has marketing copy above a dense Home view, so test the
  lower crop on every supported display size.
- `icon-1024.png` has a green felt background, gold cribbage board, card, and
  pawn. It is coherent with the screenshots, but repository presence does not
  prove small-size legibility, dark-mode contrast, or distinctiveness in a
  search grid.

#### Recommendations

- Verify the live ASC screenshot set by checksum, ordering, display type, and
  locale. The fleet convention specifically warns that screenshot upload can
  leave silent duplicates. Run the shared `asc-audit-screenshots` tool before
  submission, not only the repo-local uploader.
- Treat screenshot 1 as the highest-leverage asset. It should show a player
  taking one meaningful action and receiving a clear explanation, with the
  five-minute promise visible in the frame.
- Consider a short preview video only if it demonstrates the swipe/answer/
  explanation loop faster than static screenshots. A video that looks like a
  full game would attract the wrong audience.
- Check the 1024 icon at small search-result size and against dark mode. The
  repository presence is evidence of an asset, not evidence of visual quality.

### Known ASC and release-state issues

- `scripts/verify-store-config.py` could not complete live verification because
  ASC credentials are unavailable. This leaves product existence, prices,
  subscription group, introductory offers, entitlement attachments, current
  offering packages, editable version, build attachment, and review readiness
  unverified.
- `CLAUDE.md:45-52` records a previous build 21 rejection caused by an offering
  with zero packages in the Test Store app. This is historical but high-value
  evidence that the current offering must be checked before each submission.
- `project.yml` currently declares marketing version `1.2.1` and build `29`.
  `README.md:13` says version `1.0`. `docs/index.html:78` says software version
  `1.2.0`. `archive/flow-catalog-2026-07-31.md:37-42` records build 20 on
  version 1.0. These are not all live ASC values, but they are enough to make
  release-source consistency a P0/P1 scanner rule.
- `scripts/generate_metadata_all.py:7-14` warns that its runnable profiles
  still contain pre-raise `$1.99`, `$9.99`, and `$29.99` copy. The same old
  monthly/yearly values are executable inputs in
  `scripts/asc-setup-release.py:18-35` and `scripts/asc-set-prices.py:19-23`.
  Current checked-in `fastlane/metadata` is price-free, so the immediate risk
  is a future agent or release operator regenerating stale copy or prices.
  These commands should be blocked by a preflight until rewritten or archived.

## End-to-end user and monetization flow

### Install to first value

#### Evidence

1. `RootView.swift:4-22` branches to onboarding until
   `progress.hasOnboarded` is true, avoiding a Home flash.
2. `OnboardingView.swift:48-70` presents three value pages, a required skill
   selection page, and a trial page.
3. `OnboardingView.swift:81-87` calls `ensureOfferings()` while the user moves
   through onboarding and records a RevenueCat paywall impression when the
   trial page is reached.
4. `OnboardingView.swift:253-323` keeps a stable CTA geometry, exposes a
   `Start 7-day free trial` primary CTA, shows a live monthly price when loaded,
   includes auto-renew microcopy, and provides Terms, Privacy, and Restore.
5. The primary trial action at `OnboardingView.swift:345-369` purchases the
   monthly package directly. A cancellation leaves the player in place. A
   missing package opens the full fallback paywall.
6. `OnboardingView.swift:375-393` routes a new beginner through How to Play,
   then the Feature Tour, then a real Quick Session before setting onboarded.
7. `FeatureTourView.swift:109-146` explains the rooms, streaks, paid value, and
   then offers a real first Quick Session.
8. `QuickSessionView.swift:85-177` uses a uniform choose, grade, explanation,
   Next flow. `DrillCompleteView.swift:77-109` records the session, celebrates,
   and may show the review funnel.

### Conversion strengths

- The free exit is visible as `Get Started` on the trial page rather than a
  hidden dismiss gesture.
- The trial CTA is close to a live billed price and legal links, addressing the
  documented App Review 3.1.2(c) issue.
- A StoreKit cancellation is distinguished from an error, avoiding an
  unnecessary second paywall.
- A successful purchase is followed by entitlement confirmation retries in
  `SubscriptionService.swift:156-169`.
- The standalone paywall has yearly, monthly, and lifetime cards, package
  prices, renewal text, a Restore action, and Terms/Privacy links.
- The first new-player path teaches rules before the real mixed session.

### Conversion risks and detours

1. **Onboarding is long before first use.** Three value pages, a required skill
   choice, a trial page, How to Play for new players, a feature tour, and a
   first session may be too much for an install motivated by “quick practice.”
   There is no evidence in the repository that each step earns its time.
2. **The trial page directly starts monthly, while the full paywall defaults to
   yearly.** This can be a deliberate low-friction activation choice, but it
   creates a hidden plan-selection difference and may leave annual conversion
   on the table.
3. **The trial page sells monthly but does not show annual or lifetime options
   until the fallback path.** A user who wants a one-time purchase must first
   understand that `Get Started` is the free exit or encounter a locked feature
   later.
4. **Offering load failure is treated as a paywall fallback, but failure modes
   are not categorized.** Network timeout, empty current offering, missing
   monthly package, StoreKit product error, and RevenueCat configuration error
   all collapse into a user-visible fallback/error path.
5. **There is no explicit “why now” paid trigger after a free session.** The
   Home upgrade card and locked rows may be sufficient, but this is unmeasured.
6. **Restore has weak feedback in onboarding.** The onboarding Restore button
   launches an ignored task with `try? await subscriptions.restore()` at
   `OnboardingView.swift:311-313`; failures and successful restores do not
   receive a visible message there.
7. **The app can show a “paid but not unlocked” message after purchase, but no
   persistent support diagnostics are captured.** `PaywallView.swift:308-318`
   is good user copy, but the implementation agent needs an event/error record
   to determine frequency.
8. **The paywall may be visually dense on small screens and large text.** Four
   benefits, three plan cards, buttons, and legal links are in a scroll view,
   but no repository evidence proves Dynamic Type or VoiceOver behavior at the
   largest sizes.
9. **The `Close` button on a standalone paywall and the free path are not
   equivalent experiments.** A user arriving from a locked drill may expect to
   return to the exact drill, while the sheet dismisses to its caller. Preserve
   source and return-state telemetry.
10. **A cancelled Apple sheet is silent.** Staying put is correct, but a small
    non-blocking message or state change could distinguish “not now” from a
    dead CTA and help discoverability without nagging.

### Complete paywall and onboarding state map

| Surface or detour | Entry and exact code | Current behavior | Poor, error, loading, legal, or accessibility risk |
| --- | --- | --- | --- |
| Fresh install | `RootView.swift:4-22` | Routes every un-onboarded player to `OnboardingView` | No measured install-to-page abandonment or first-value time. |
| Value pages | `OnboardingView.swift:48-70` | Three value pages before skill selection | Long path before an interactive answer; page dots are custom visuals and need VoiceOver labels. |
| Skill gate | `OnboardingView.swift:163-199, 305-306` | New, basics, or played is required before Continue | Continue is disabled until selection; test Dynamic Type, focus order, and persistence after relaunch. |
| Trial page | `OnboardingView.swift:203-251, 253-323` | Monthly price and one-week trial copy, Terms, Privacy, Restore, free `Get Started` exit | Price uses a loading placeholder; CTA is not disabled while price or offerings are unavailable. Restore uses `try?` and gives no result. |
| Direct trial purchase | `OnboardingView.swift:345-369` | Ensures offerings, selects monthly, opens StoreKit, stays on page after cancel | Missing package opens fallback; errors use a generic localized message; no trial eligibility or purchase outcome event. |
| Onboarding fallback paywall | `OnboardingView.swift:88-89, 353-356` | Presents `PaywallView(source: "cribbage_onboarding_fallback")` if monthly is missing | User can see a second plan picker only after a failed direct route. Dismissal returns to the trial page unless entitlement is active. |
| Free exit and tour | `OnboardingView.swift:264-273, 375-393`; `FeatureTourView.swift:91-146` | `Get Started` starts How to Play for new players, then tour and Quick Session | A free user can reach value, but the route is not measured and the tour can still precede the first real answer. |
| Home upgrade surfaces | `HomeView.swift:72-73, 178, 457, 580` | One sheet source, `cribbage_home_sheet`, serves pending locked destinations, locked tiles, and upgrade card | Context is not retained in the source ID, so conversion cannot be compared by feature or return-to-feature success. |
| Room locks | `RoomView.swift:41, 78, 144` | Locked drills and room upsell open `cribbage_room_sheet` | A user may not know whether the requested drill or the entire room is paid. Add context copy and return target. |
| Settings membership | `SettingsView.swift:41, 133-157` | Upgrade and Restore are visible; restore reports success, no entitlement, or error | This is the best restore state implementation. It should share an instrumented service result with onboarding and paywall. |
| Paywall loading | `PaywallView.swift:144-160, 281-284` | Prices are live from RevenueCat; placeholder is `Loading price…`; `.task` loads offerings | The purchase CTA remains enabled while a placeholder is shown. Distinguish loading, empty offering, missing package, and retryable network failure. |
| Paywall plans | `PaywallView.swift:67-141, 221` | Yearly is selected by default, then monthly, lifetime; annual savings and lifetime no-renewal badge | Custom plan buttons have no explicit selected accessibility value. Annual default differs from onboarding monthly direct purchase. |
| Paywall purchase | `PaywallView.swift:299-319` | Shows progress, treats cancel as a normal outcome, alerts errors, confirms entitlement | Paid-but-locked state has useful copy but no persistent diagnostic or event. Error text is raw `localizedDescription`, which needs categorization and localization review. |
| Paywall restore | `PaywallView.swift:323-335` | Shows no previous purchase or error; successful entitlement dismisses through `isPro` | Test offline, wrong Apple account, delayed entitlement, repeated taps, and relaunch. |
| Paywall legal links | `PaywallView.swift:288-297` | Terms of Use points to Apple standard EULA, Privacy Policy points to GitHub Pages | The product-specific `/terms` page exists but is not the paywall Terms destination. Confirm the intended legal hierarchy and label both consistently. |
| Timed and swipe drills | `PracticeRunView.swift:140-152, 224-234`; `FlashcardDrillView.swift:262-392` | Timed mode has no obvious pause control; swipe mode has tap/drag logic and async animation tasks | Back/exit, cancellation, stuck animation, Reduce Motion, and non-swipe alternatives require runtime testing. |
| Review and feedback detour | `DrillCompleteView.swift:77-109`; `ReviewPromptSheet.swift:74-223` | Third positive moment opens enjoyment gate, then App Store or mail path | External write-review and native request paths are not attributed. Mail open is not feedback submission. |

The state map is a test inventory, not evidence that each risk occurs in
production. The implementation agent should capture one screenshot and one
structured outcome for every row on a StoreKit test build and a TestFlight
build, including the negative paths.

### Required runtime test matrix

The implementation agent should run this matrix on a StoreKit test account and
an ASC sandbox/TestFlight build, recording screenshots and event logs:

- Fresh install, brand-new skill, skip trial, complete How to Play, skip tour,
  start Quick Session, finish with all-correct and all-wrong answers.
- Fresh install, brand-new skill, start monthly trial, cancel Apple's sheet,
  retry, complete purchase, wait for entitlement, kill/relaunch, and restore.
- Existing-player skill, trial CTA with slow/offline network, no current
  offering, offering with no monthly package, and StoreKit product error.
- Locked drill, locked room, Home upgrade card, Settings upgrade card, and
  notification deep link while free.
- Paid player opening each paid mode, restoring on the same account, restoring
  on a different account, and a delayed RevenueCat entitlement.
- iPhone SE-sized width if supported by the minimum OS, iPhone large text,
  VoiceOver, Reduce Motion, Dark Mode, iPad portrait, and iPad landscape.

## Paywall and native paywall experiment backlog

This is a custom SwiftUI paywall, not RevenueCat's `PaywallView` component. The
“native paywall nooks and crannies” available locally are therefore the package
selection, ordering, default choice, introductory-offer presentation, loading,
restore, legal links, CTA copy, and source-specific presentation. If a future
implementation adopts RevenueCat's native paywall, keep the same experiment
taxonomy and log the paywall identifier/version.

There is currently no local evidence that RevenueCat native paywall controls
are active. Before treating a dashboard change as an A/B test, verify the
resolved SDK and UI package support for placement IDs, offering selection,
package order, default package, eligibility and introductory-offer rendering,
restore placement, legal footer, close behavior, loading state, error state,
and purchase completion state. A native paywall experiment must still preserve
the billed amount, renewal/cancellation explanation, Privacy, Terms of Use,
and a return path to the locked feature. Record the remote paywall revision and
offering identifier with every impression so a server-side edit is not
mistaken for a clean treatment.

| Hypothesis | Primary metric | Guardrails | Implementation location |
| --- | --- | --- | --- |
| Annual default increases paid conversion without reducing trial starts | Trial starts per paywall impression, paid conversion | Monthly starts, lifetime purchases, refund/cancel rate | `PaywallView.swift:67-80, 221`; `PaywallPlan` default |
| Monthly-first onboarding reduces first-session abandonment | Onboarding completion and first session within 24h | Trial start, day-7 return, revenue per install | `OnboardingView.swift:203-251, 345-369` |
| Showing all three plans at onboarding increases lifetime intent | Revenue per install and plan mix | CTA tap, trial start, support contacts | Add an explicit onboarding plan selector, or keep control as current direct monthly CTA |
| “Practice that never runs out” beats feature-name copy | Paywall purchase conversion | Scroll depth, dismiss rate, trial cancellation | `PaywallView.swift:33-50` |
| A short billing line with exact localized price improves trust | CTA to purchase conversion | Error rate, refund/support rate | `PaywallPricing.terms`, `OnboardingView.monthlyDisclosure` |
| A “Try free” CTA versus “Start 7-day free trial” improves tap rate | CTA tap rate | Purchase completion, App Review compliance | `PaywallPlan.ctaTitle`, `OnboardingView.swift:293-304` |
| Yearly savings badge versus no badge changes annual selection | Annual selection rate | Revenue per purchaser, cancellation | `PaywallPricing.savingsBadge`, `planCard` |
| Contextual locked-feature copy converts better than generic upgrade copy | Paywall open to purchase | Return-to-feature rate, dismiss rate | `RoomView.swift`, `HomeView.swift`, `PaywallView(source:)` |
| Restore above the fold reduces support and duplicate purchase attempts | Restore completion and support contacts | Conversion, paywall exits | `PaywallView.swift:288-297`, Settings |
| Trial page after a first free Quick Session beats trial before value | Trial starts per install and paid conversion | Onboarding completion, day-1 activation | `OnboardingView` stage ordering and `FeatureTourView` |
| Showing a daily challenge preview creates a return loop | Day-2/day-7 active return | Trial conversion, notification opt-in | `CribbageMinuteView`, Home upgrade card |

For every test, assign an experiment ID, immutable control, start/end dates,
storefront, app version, paywall source, selected plan, and eligibility rule.
Do not infer conversion from RevenueCat paywall impressions alone.

## StoreKit, RevenueCat, and purchase-state audit

### Local commercial contract

The repository has a coherent local StoreKit contract, but local files do not
prove that the App Store or the current RevenueCat offering has the same
state.

| Product ID | Local type | Local price | Local period | Intro offer | Local evidence |
| --- | --- | ---: | --- | --- | --- |
| `com.jackwallner.cribbage.monthly` | Recurring subscription | `$6.99` | `P1M` | Free `P1W` | `CribbageTrainer/CribbageTrainer.storekit:36-58` |
| `com.jackwallner.cribbage.yearly` | Recurring subscription | `$29.99` | `P1Y` | Free `P1W` | `CribbageTrainer/CribbageTrainer.storekit:60-83` |
| `com.jackwallner.cribbage.lifetime` | Non-consumable | `$69.99` | One time | None | `CribbageTrainer/CribbageTrainer.storekit:5-19` |

Additional local evidence:

- The subscription group is `Cribbage+` in the StoreKit file at
  `CribbageTrainer/CribbageTrainer.storekit:29-34`.
- `SubscriptionService.package(for:)` resolves `.yearly` to
  `offering.annual`, `.monthly` to `offering.monthly`, and `.lifetime` to
  `offering.lifetime` at `Shared/Services/SubscriptionService.swift:103-110`.
- The app accepts any active entitlement at
  `Shared/Services/SubscriptionService.swift:178-186`. `CLAUDE.md:39-46`
  documents the compatibility pair `pro` and `Cribbage+`, with every product
  intended to be attached to both. This is intentional compatibility behavior,
  but a live entitlement mapping check is still required.
- `project.yml:3-5` declares RevenueCat from `5.72.0`, while the resolved
  package is `5.80.3` at
  `CribbageTrainer.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved:5-10`.
  The lower bound and lockfile are not a runtime failure, but they can let a
  future regeneration select an SDK different from the reviewed one.
- The simulator guard at `Shared/Services/SubscriptionService.swift:60-75`
  avoids configuring the production public key. Local StoreKit plus the
  Settings override is the correct simulator test path. A simulator purchase
  therefore cannot validate a real RevenueCat offering or App Store trial.
- No `RevenueCatUI` import, native RevenueCat paywall component, paywall
  placement, or server-controlled package order was found. The current
  paywall is custom SwiftUI in `CribbageTrainer/Views/PaywallView.swift`.

### Required live checks before implementation

Do not change prices, trial wording, entitlement names, or package identifiers
until a read-only ASC and RevenueCat snapshot records, with a timestamp,
storefront, app version, and environment:

1. Current RevenueCat offering identifier, package identifiers, product
   identifiers, and package count for an App Store build.
2. Product state, subscription group, territory prices, one-week introductory
   offer, and review availability for all three products in ASC.
3. `pro` and `Cribbage+` entitlement attachment and the product-to-package
   mapping.
4. The editable ASC version, attached build, processing state, and current
   review state.

The local `python3 scripts/verify-store-config.py` check was attempted and
stopped before making any live claim because the required
`ASC_API_KEY_ID`, `ASC_ISSUER_ID`, and `ASC_KEY_PATH` environment variables are
not present. Its source is still useful evidence: it expects `$rc_monthly`,
`$rc_annual`, and `$rc_lifetime`, and it treats an offering with zero packages
as a failure.

## Instrumentation and RevenueCat opportunities

### Current state

#### Evidence

- `SubscriptionService.swift:77-89` emits a RevenueCat custom paywall
  impression only when configured, with source IDs such as
  `cribbage_onboarding_trial` and caller-specific sheet IDs.
- `SubscriptionService.swift:33-38` exposes `isPro` and offerings but there is
  no app-wide analytics abstraction.
- Local state records sessions, item accuracy, missed IDs, streaks, daily
  completion, and review-prompt state, but those values remain on-device.
- `rg` finds no general analytics SDK, event logger, Sentry, Crashlytics, or
  network crash reporter in the repository.
- RevenueCat is configured only on non-simulator builds at
  `SubscriptionService.swift:60-75`, preserving the fleet simulator safety
  rule.

### Privacy-safe event taxonomy

If analytics is added, keep it aggregate and app-scoped. Do not send card hands,
free-text feedback, email addresses, names, exact timestamps if not needed, or
raw practice content. Prefer event names and bounded enums.

Recommended events:

| Event | Properties |
| --- | --- |
| `app_launch` | app version, build, OS major, device class, locale, days since first launch bucket |
| `onboarding_page_view` | page enum, skill-selected bool, source |
| `onboarding_exit` | page enum, stage, reason enum |
| `onboarding_completed` | skill enum, trial state enum, elapsed bucket |
| `first_value_started` | session type, item count bucket |
| `session_completed` | session type, room mix, item count bucket, score bucket |
| `item_answered` | room enum, mode enum, correct bool, attempt number bucket |
| `paywall_impression` | source, paywall version, offering ID, package availability |
| `paywall_plan_selected` | source, plan enum |
| `purchase_started` | source, plan, trial eligibility state if available |
| `purchase_completed` | plan, entitlement state |
| `purchase_cancelled` | source, plan |
| `purchase_error` | source, plan, error category, retryable bool |
| `restore_started` / `restore_completed` | source, success, entitlement state |
| `offering_load_failed` | stage, error category, package presence |
| `review_gate_shown` | positive-moment bucket, launch bucket |
| `review_gate_outcome` | enjoyed, feedback, not-now, opened-review, maybe-later |
| `daily_challenge_completed` | score bucket |
| `game_night_prep_completed` | session completion, notification source |
| `support_link_opened` | source |

### RevenueCat custom attributes

Set only bounded, non-sensitive attributes, and only after the relevant state
exists. These are useful for segmentation and paywall targeting:

- `app_version`, `build_number`, `os_major`, `device_class`, `storefront`
- `skill_level` with values `new`, `basics`, `played`
- `onboarding_completed` and `onboarding_trial_decision`
- `lifetime_session_bucket`, such as `0`, `1`, `2_4`, `5_9`, `10_plus`
- `last_room`, bounded to the five room IDs
- `weakest_room`, bounded to room ID or `unknown`
- `missed_item_bucket`, not raw item IDs
- `daily_challenge_completed`, `game_night_prep_configured`
- `paywall_last_source`, `paywall_last_plan_selected`
- `review_gate_state`, bounded to funnel outcome

Exact insertion locations for a future implementation are:

| Signal or attribute | Insert at | Required behavior |
| --- | --- | --- |
| Static app context | `Shared/Services/SubscriptionService.swift:45-51`, after `guard isConfigured` and before the refresh task | Set SDK-appropriate `app_version`, `build_number`, OS major, device family, locale, and storefront once per meaningful change. Confirm the RevenueCat 5.80.3 API before coding. |
| Paywall source | Existing `trackPaywallImpression` at `Shared/Services/SubscriptionService.swift:80-88`, called from `PaywallView.swift:281-284` and `OnboardingView.swift:81-87` | Preserve `cribbage_onboarding_trial`, `cribbage_home_sheet`, `cribbage_room_sheet`, `cribbage_settings_sheet`, and fallback IDs. Add paywall version and package availability to the app event boundary. |
| Offering failure | `Shared/Services/SubscriptionService.swift:91-100, 129-139` | Replace silent `try?` classification with bounded categories such as timeout, network, empty offering, missing package, and StoreKit product error. Record duration and retry count, not response bodies. |
| Plan selection | `CribbageTrainer/Views/PaywallView.swift:83-88` | Set `paywall_last_source`, `paywall_last_plan_selected`, and emit `paywall_plan_selected` only when the selection changes. Onboarding has no selector, so mark its direct plan as `monthly` at `OnboardingView.swift:353-360`. |
| Purchase lifecycle | `Shared/Services/SubscriptionService.swift:141-153`, with source and plan passed by callers at `PaywallView.swift:299-318` and `OnboardingView.swift:345-368` | Emit started, cancelled, succeeded, error, and entitlement-delayed states. Do not label the Apple sheet as a trial start until the transaction and entitlement state confirm it. |
| Entitlement confirmation | `Shared/Services/SubscriptionService.swift:156-169` | Emit `entitlement_unlocked` or `entitlement_delayed` with elapsed bucket and attempt count. Preserve the user-facing no-double-charge message. |
| Restore lifecycle | `Shared/Services/SubscriptionService.swift:172-176`, with UI callers at `PaywallView.swift:323-335`, `SettingsView.swift:133-157`, and `OnboardingView.swift:308-313` | Emit started, succeeded, no entitlement, and error. Onboarding must stop swallowing the result and show the same actionable state as Settings. |
| Skill choice | `OnboardingView.skillCard(_:)` at `OnboardingView.swift:163-167` | Set bounded `skill_level` and emit `onboarding_skill_selected`. Do not send the card's display text. |
| Onboarding pages and completion | `OnboardingView.swift:81-87`, `345-369`, `375-393` | Emit page view, free exit, trial CTA, purchase outcome, tour start, and `onboarding_completed`. Include page enum and elapsed bucket. |
| First value | `CribbageTrainer/Views/Drills/QuickSessionView.swift:181-207, 248-257` and `Shared/Services/ProgressStore.swift:51-57` | Emit first session started, first answer, first correct answer, and session completed. Update only aggregate session buckets in RevenueCat attributes. |
| Practice segments | `Shared/Services/PracticeRecordStore.swift:69-97` and `HomeView` room/mode destinations | Update bounded lifetime session, room, weakest-room, and mode attributes after persistence succeeds. Never send raw item IDs or hands. |
| Review funnel | `DrillCompleteView.swift:77-109`, `CribbageTrainer/Views/CribbageMinuteView.swift:161-196`, and `ReviewPromptSheet.swift:98-132, 194-209` | Emit gate shown, outcome, write-review link opened, native request requested, feedback mail opened, and mail fallback. Never claim a review was submitted. |
| Notifications | `Shared/Services/AppSettings.swift:153-224` | Emit permission result and schedule success/failure categories. The current `center.add` errors are ignored and should not become silent operational failures. |

Implement the RevenueCat attribute call behind a small adapter because SDK
method names can differ across the declared lower bound and resolved version.
The adapter must no-op in simulator/local StoreKit mode, must be tested with a
fake, and must reject free text, email, raw card content, and unbounded IDs.
The audit does not assess whether any resulting attributes would require a
change to the app's tracking or data-collection disclosure, per the explicit
scope exclusion.

RevenueCat API calls should be wrapped in a small service boundary so the app
can compile in simulator/local StoreKit mode without configuring production.
Add tests that assert no attribute contains free text, card IDs, or email.

## Ratings, reviews, and feedback

### Evidence

- `ReviewPromptTracker.swift:48-57` waits for at least three positive moments,
  two launches, and uses a 120-day cooldown after a hard dismissal.
- `DrillCompleteView.swift:77-109` records a positive moment after completion,
  waits 1.4 seconds so celebration can land, and presents the custom enjoyment
  gate when eligible.
- `ReviewPromptSheet.swift:74-132` routes “Yes” to the App Store write-review
  URL or a soft defer, and “Not really” to feedback.
- `ReviewPromptSheet.swift:194-205` only reports feedback submitted if the
  mail app actually opened, and provides a copy-email fallback if it did not.
- `SettingsView.swift` offers a manual review/feedback route and uses the
  SwiftUI `requestReview` environment action after a soft defer.
- `CribbageMinuteView.swift:161-196` also has a review request path after a
  daily challenge outcome.
- `AppStoreLinks.writeReviewURL` uses the app ID without a storefront prefix,
  which is a good localization choice.

### Risks and recommendations

- The custom gate is a positive-experience filter, but the code does not
  instrument shown, skipped, yes, no, feedback, opened-review, or native prompt
  outcomes beyond local defaults. Add the review events above.
- `requestReview()` is system-controlled and may show nothing. Treat it as a
  request, not a conversion. Measure the preceding gate and subsequent return
  behavior, never a claimed “review submitted” event.
- The “Maybe later” path is likely the best native prompt candidate, but the
  daily-challenge path can double up with the same user state. Centralize review
  eligibility to prevent two screens requesting in one session.
- A third completed drill may be too early for a beginner who has just learned
  the interface. Test thresholds of 3, 5, and a first successful daily return,
  with support/contact rate and retention as guardrails.
- Keep the unhappy-player feedback route, but add a lightweight category enum
  before mail, such as content, scoring, purchase, crash, accessibility, or
  other. Do not send that category or free text to RevenueCat unless the user
  clearly consents.

## Website, legal, support, and consistency

### Direct evidence

- `docs/index.html` has canonical and Open Graph URLs on
  `https://jackwallner.com/ios/cribbage/`, but the page's screenshot URLs,
  App Store metadata, and most links use `https://jackwallner.github.io/cribbage/`.
- The website's JSON-LD says `softwareVersion` `1.2.0`, while `project.yml` is
  `1.2.1` build `29`.
- JSON-LD includes an `aggregateRating` of 5 with `ratingCount` 1. This needs
  live verification and should not be left as a manually stale claim.
- Website offer prices are hard-coded as USD 6.99 monthly, 29.99 yearly, and
  69.99 lifetime, matching the local StoreKit file, but live regional pricing
  cannot be verified here.
- `docs/privacy-policy.html`, `docs/terms.html`, and `docs/support.html` all
  show an August 17, 2026 update date and link to each other. The support page
  explains restore and cancellation and accurately says this is not a full
  game.
- Each of privacy, terms, and support has a root HTML page and a nested
  directory index page. Privacy and terms differ mainly in relative-link
  paths, while support is byte-identical in the local tree. This is a
  maintainability risk because an agent can edit one legal copy and leave the
  other stale.
- `PaywallLinks.terms` points to Apple's standard EULA, while the website and
  metadata also expose `/terms`. This is defensible, but label the in-app link
  consistently as Terms of Use and ensure the custom terms page remains the
  product-specific explanation.

### Recommendations

- Pick one canonical public origin, redirect the other, and use it consistently
  in canonical, Open Graph, JSON-LD, metadata URLs, in-app links, support
  replies, and screenshots. If `jackwallner.com` is canonical, update all
  `github.io` references after confirming hosting and HTTPS redirects.
- Generate website version, price, membership features, App Store ID, and legal
  URLs from a checked-in source of truth rather than hand-editing HTML.
- Remove or update the structured-data rating unless it is directly sourced and
  maintained. A stale 5/1 claim can harm trust and may be misleading.
- Update `README.md` to 1.2.1 or change the project version only through the
  release workflow. Mark archived documents clearly as historical.
- Add a prominent website “What this is / what this is not” block and show the
  first practice interaction before the subscription explanation.
- Check mobile page load, App Store deep-link fallback, dark mode, keyboard
  navigation, alt text, and all links in both canonical and legacy domains.

## Test coverage and release-regression evidence

### What the current tests protect

- `CribbageTrainerTests/ContentValidityTests.swift` covers unique content IDs,
  legal hands, discard scenarios, answer indices, free/Cribbage+ split, lock
  resolution, stale tile copy, and Quick Session composition.
- `CribbageMinuteTests.swift`, `HandGeneratorTests.swift`, and
  `HandScoringTests.swift` cover daily challenge stability, generated hands,
  deck legality, skill mixing, and scoring edge cases.
- `PracticeRecordStoreTests.swift` and `ProgressStoreTests.swift` cover
  persistence, streaks, review queues, stats, reset behavior, and challenge
  scores.
- `ReviewPromptTrackerTests.swift` covers the positive-moment threshold,
  launch threshold, cooldowns, terminal outcomes, and review URL construction.
- `project.yml:74-77` puts only `CribbageTrainerTests` in the normal scheme.
  The screenshot UI target is a separate `Screenshots` scheme at
  `project.yml:85-93`.

### Important unprotected surfaces

There are no repository tests for `SubscriptionService`, RevenueCat offering
shape, package-to-product mapping, StoreKit prices or trial eligibility,
PaywallPricing, purchase cancellation, delayed entitlement, restore errors,
onboarding fallback, notification scheduling, legal links, accessibility,
Dynamic Type, or review-sheet presentation. This is the main gap between the
strong content-model test suite and release confidence for downloads and paid
activation.

`ios27CribbageTrainer.md:20-25` records Swift concurrency warnings in
`ProgressStoreTests`, `ReviewPromptTrackerTests`, and
`PracticeRecordStoreTests`. It calls the runtime build a pass and says there
was no production compiler blocker, but the warnings remain a maintenance and
future Swift-version risk. The implementation agent should either resolve
actor isolation or record a dated, tested justification.

The read-only generic build run for this audit succeeded with
`CODE_SIGNING_ALLOWED=NO` and a derived-data path outside the repository. Xcode
printed two environment `DVTDeviceOperation` build-number warnings and an
AppIntents metadata-extraction skip because the app has no AppIntents framework
dependency. These did not fail the build and should be distinguished from app
source warnings in the watchdog report.

## Accessibility and degraded UX

### Evidence and likely risks

- Several views use custom cards, icons, colors, animations, haptics, sounds,
  swipe gestures, and confetti. `QuestionUI.swift`, `FlashcardDrillView.swift`,
  `Theme.swift`, and `ConfettiBurst.swift` are the primary review points.
- `OnboardingView.swift:163-198` provides button labels for skill cards and wraps
  detail text, which is good, but the page-dot indicators and decorative card
  tiles need runtime VoiceOver inspection.
- `QuickSessionView.swift:107-175` uses a progress bar and text count, but a
  test is needed to confirm the progress label is meaningful to VoiceOver.
- `PaywallView.swift:83-141` uses a custom plan-card button with visual selected
  state. Verify that selected plan, trial terms, price, and badge are announced
  as one understandable accessibility element.
- `Info.plist:36-46` supports portrait on iPhone and all four orientations on
  iPad, consistent with `project.yml` device family 1,2.

### Scanner and runtime recommendations

- Add automated accessibility assertions for every interactive screen at
  default and accessibility-extra-large content sizes.
- Run VoiceOver and Reduce Motion through onboarding, Quick Session, flashcard
  swipe, discard selection, paywall, restore, review feedback, and settings.
- Provide a non-swipe path for FlashcardDrillView and ensure card front/back
  state is announced. Do not rely on color, haptics, sound, or animation to
  communicate correctness.
- `CribbageTrainerScreenshots/ScreenshotTests.swift:13-16` documents that a
  missing element does not fail the capture unless the test explicitly calls
  `XCTFail`. The screenshot suite is therefore evidence of captured assets,
  not proof that every expected screen element was present. Its settling
  helper also uses a fixed sleep, and the suite does not cover paywall loading,
  purchase error, restore, legal, or review states. Add assertions and a small
  negative-state capture set before treating screenshots as release gates.
- Add watchdog logging around main-thread stalls, unhandled purchase tasks,
  empty session arrays, blank offerings, failed outbound links, and repeated
  notification route attempts.
- Review use of `try?` in onboarding restore and other async flows. Suppressed
  errors are a scanner target because they can create silent dead ends.

## Crash, hang, stale, and operational watchdog signals

No crash-reporting or live diagnostics SDK is present in the repository. The
future fleet watchdog should therefore combine source scanning, local build/
test checks, App Store Connect API snapshots, website checks, and optional
production provider APIs.

Signals for this app:

- crash-free sessions, crash-free users, launch crash, and crash count by
  version/build from ASC or a future crash provider;
- hangs or watchdog terminations, especially during RevenueCat configure,
  offering load, purchase confirmation, paywall presentation, and notification
  deep links;
- no Quick Session items, no current offering, zero available packages, missing
  monthly/annual/lifetime package, StoreKit product error, or entitlement that
  remains inactive after purchase;
- purchase started without completion, restore error, repeated purchase retry,
  and paid state lost after relaunch;
- onboarding page reached but no completion, long time from install to first
  session, and a high fallback-paywall rate;
- review gate shown repeatedly in one session or native requestReview called
  without eligibility;
- broken privacy, terms, support, App Store, report-a-problem, and mailto links;
- version/build mismatch among `project.yml`, `Info.plist` expansion, README,
  website JSON-LD, release notes, ASC editable version, and attached build;
- stale product prices, trial duration, product IDs, entitlement keys, package
  identifiers, offering IDs, and website JSON-LD prices;
- screenshot dimensions outside ASC requirements, duplicate MD5s, wrong
  ordering, screenshots from an old version, or screenshot text claiming a
  feature absent from the current binary;
- hard-coded `github.io` or `jackwallner.com` links that disagree with the
  chosen canonical origin;
- use of deprecated UIKit/StoreKit APIs, compiler warnings, Swift concurrency
  warnings, force unwraps on user/config/network input, `try!`, `fatalError`,
  and suppressed errors in user-facing purchase flows;
- production RevenueCat configuration in simulator builds, which must remain a
  hard failure in the scanner;
- changed `DrillLibrary` content without corresponding content-validity tests;
- notification permissions denied, notification schedule not created, or a
  notification route that does not land in the intended paid session;
- accessibility labels missing for custom buttons, decorative text announced,
  and non-gesture alternatives absent.

### Suggested configurable alert policy

These are starting thresholds for the MacBook or CI watchdog, not observed
metrics. Keep them in a per-app configuration file and require a minimum event
count before comparing percentages.

| Alert | Default trigger | First response |
| --- | --- | --- |
| Critical crash spike | At least 3 distinct users or 5 crash events for the same version/build in 60 minutes, or a crash rate above 2 times the trailing 7-day baseline with at least 20 sessions | Email the owner with build, OS/device buckets, first-seen time, signature, and release link. Pause rollout or submission. |
| Launch or activation crash | Two distinct users crash in launch, onboarding, first Quick Session, or purchase state within 60 minutes | Treat as release blocker even if the overall crash rate is low. Reproduce the named state first. |
| Hang or watchdog spike | At least 3 distinct users with the same hang signature in 6 hours, or a 2 times baseline increase | Inspect main-thread work around launch, offering load, purchase confirmation, and drill animation. |
| Commercial regression | Three or more `productsUnavailable`, empty-offering, or paid-but-not-unlocked outcomes in 15 minutes, or zero packages in a live offering snapshot | Check RevenueCat offering and ASC product state before changing UI copy or prices. |
| Funnel break | A release test cannot reach a free answer, the trial CTA is not actionable after a bounded load window, or restore has no visible result | Block the release and attach the failing state screenshot and log. |
| Release identity drift | Project version/build, uploaded build, website schema, or metadata snapshot disagree | Fail the preflight before upload. Archived documents are excluded only when explicitly marked historical. |
| Watchdog silence | A known TestFlight or sandbox smoke run emits no launch heartbeat, completion heartbeat, or error result within the configured window | Distinguish instrumentation failure from zero traffic and rerun the smoke test. |

The runner should deduplicate the same signature for a configurable cool-down,
store raw snapshots locally, and send only a short email summary. Notifications
are intentionally not deployed by this audit. A later implementation can use
the MacBook's scheduled launch agent, ASC or crash-provider API, RevenueCat
read-only API, `curl`, `xcodebuild`, and repository scanners without AI.

## Prioritized implementation backlog

Severity uses P0 for release-blocking or revenue-risk configuration, P1 for
high-impact conversion or trust work, P2 for meaningful optimization, and P3
for polish. Confidence is confidence in the local evidence, not predicted
business lift.

| ID | Severity | Impact | Effort | Confidence | Evidence | Work and validation |
| --- | --- | --- | --- | --- | --- | --- |
| C-01 | P0 | High | M | High | `project.yml`, `CribbageTrainer.storekit`, `CLAUDE.md:45-52`, ASC verifier failure | Pull live ASC/RevenueCat state, verify offering packages, product IDs, trial, prices, entitlements, and build 29. Validate with a clean TestFlight purchase/restore matrix. |
| C-02 | P1 | High | S | High | `README.md:13`, `project.yml`, `docs/index.html:78`, archive build 20 | Make version/build a single generated source and update or mark stale docs. Add CI test that fails on mismatches. |
| C-03 | P1 | Medium-high | S | High | `docs/index.html:13,21,24,75` versus metadata links | Choose canonical domain, redirect legacy origin, update canonical/OG/JSON-LD and metadata. Run link and canonical checks. |
| C-04 | P1 | High | M | High | No analytics SDK/event abstraction; only `trackPaywallImpression` | Add privacy-safe event boundary and funnel taxonomy. Validate event schema, simulator no-prod behavior, and event counts in sandbox. |
| C-05 | P1 | High | M | High | `OnboardingView.swift:48-393` | A/B test shorter onboarding versus current flow. Validate completion, first session, trial start, and day-7 return with a holdout. |
| C-06 | P1 | High | S | High | `OnboardingView.swift:311-313` uses `try?` | Add visible restore success/failure state and event categories. Test offline, no purchase, and valid restore. |
| C-07 | P1 | High | M | High | `PaywallView.swift:67-141`, onboarding direct monthly purchase | Test annual default, plan visibility, and contextual copy. Validate localized prices, legal disclosure, and refund/support guardrails. |
| C-08 | P1 | Medium | S | High | website JSON-LD rating 5/1 | Source rating from a maintained value or remove it. Validate structured data and human page copy against ASC. |
| C-09 | P1 | Medium | M | Medium-high | 50 localized folders, English-only UI | Native-review top locales and localize purchase/first-value path where justified. Validate screenshots, truncation, and conversion by locale. |
| C-10 | P1 | Medium | S | High | `SubscriptionService.swift:121-139`, `PaywallView.swift:281-284` | Classify offering errors and expose retry/support state. Test timeout, empty offering, missing package, and delayed entitlement. |
| C-11 | P2 | Medium | S | High | Review tracker and `DrillCompleteView.swift:95-109` | Centralize review eligibility and instrument outcomes. Validate no duplicate prompt in one session and native prompt only after a positive gate. |
| C-12 | P2 | Medium | M | Medium | custom UI in `QuestionUI`, `FlashcardDrillView`, `PaywallView` | Add accessibility UI tests and runtime audit for VoiceOver, Dynamic Type, Reduce Motion, and non-swipe operation. |
| C-13 | P2 | Medium | S | High | website and metadata hard-coded price/version fields | Generate website commercial copy from release data. Validate exact prices and trial wording across US and one non-US storefront. |
| C-14 | P2 | Medium | M | Medium | Daily challenge and Game Night Prep local-only state | Instrument completion and notification return without sending content. Validate day-2/day-7 retention cohorts. |
| C-15 | P2 | Low-medium | S | High | screenshot assets and fleet screenshot warning | Run checksum/dimension/order audit before release and attach version evidence to the release record. |
| C-16 | P3 | Low-medium | S | Medium | hard-coded app URLs and mail flows | Add broken-link and mailto checks, plus a support diagnostic template that asks for version, OS, screen, and error category. |
| C-17 | P0 | High | S | High | `scripts/generate_metadata_all.py:7-14, 67-120`, `scripts/asc-setup-release.py:18-35`, `scripts/asc-set-prices.py:19-23` contain pre-raise `$1.99`, `$9.99`, and `$29.99` values | Make stale scripts fail closed or archive them. Add a scanner that rejects old price literals in active release scripts and validates every commercial string against the release source. |
| C-18 | P1 | High | M | High | No MetricKit, crash reporter, hang monitor, or production error pipeline; `CribbageTrainerApp.swift:19-20` only starts local services | Add a configurable release watchdog and a privacy-reviewed crash/error signal. Validate with a controlled crash in a non-production build and a synthetic purchase failure. |
| C-19 | P2 | Medium | S | High | `project.yml:3-5` RevenueCat lower bound `5.72.0` versus resolved `5.80.3` | Pin or intentionally update the reviewed SDK range. Run the purchase, restore, paywall, and concurrency test matrix after dependency changes. |
| C-20 | P2 | Medium | S | High | No repository-local `AGENTS.md`, no Cursor/Codex-specific pointers, no handoff directory, and dated `ios27CribbageTrainer.md` | Establish one canonical agent guide and dated handoff/archive rules. Validate that each agent discovers the same current instructions and ignores historical plans. |

## Scanner rules and emitted data fields

The future fleet scanner should emit JSON and Markdown. For Cribbage Trainer,
the minimum rule IDs are:

`version.project_matches_readme`, `version.project_matches_site_schema`,
`version.project_matches_asc`, `asc.metadata_valid`, `asc.locale_set_matches`,
`asc.field_limit`, `asc.keyword_duplicate`, `asc.keyword_unsupported_claim`,
`asc.screenshot_dimensions`, `asc.screenshot_duplicate_checksum`,
`asc.screenshot_order`, `asc.screenshot_version_claim`, `asc.product_ids_match`,
`asc.trial_duration_match`, `asc.price_match`, `asc.entitlement_match`,
`rc.current_offering_nonempty`, `rc.required_package_present`,
`rc.simulator_prod_key_guard`, `funnel.onboarding_has_free_exit`,
`funnel.first_value_path`, `funnel.purchase_error_visible`,
`funnel.restore_error_visible`, `funnel.legal_links_present`,
`review.positive_gate`, `review.cooldown`, `review.native_prompt_centralized`,
`analytics.paywall_source`, `analytics.purchase_outcomes`,
`analytics.first_value`, `analytics.session_completion`,
`analytics.crash_or_error_signal`, `website.canonical_consistent`,
`website.app_store_link`, `website.legal_links_200`, `website.schema_price`,
`website.schema_rating_source`, `accessibility.custom_control_labels`,
`accessibility.dynamic_type`, `accessibility.reduce_motion`,
`accessibility.gesture_alternative`, `source.deprecated_api`,
`source.suppressed_user_error`, `source.force_unwrap_input`,
`tests.content_validity`, `tests.unit`, `tests.ui_flow`, and
`ops.production_build_health`.

Concrete non-AI checks for the first fleet implementation:

| Rule | Check | Default result |
| --- | --- | --- |
| Version identity | Parse `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` from `project.yml:31-32`; compare to `README.md`, `docs/index.html` JSON-LD `softwareVersion`, release notes, and a live ASC snapshot when supplied | Fail on current-source mismatch. Ignore `archive/` only when the document is dated and marked historical. |
| Old commercial literals | Search active files with `rg -n '\$(1\.99|9\.99|14\.99|19\.99|29\.99)' scripts fastlane docs README.md CLAUDE.md`; exclude `archive/` and the explicit stale-warning line | Fail on runnable scripts, warn on prose, and require an allowlisted reason for historical references. |
| Product contract | Extract product IDs from `CribbageTrainer.storekit:16,54,79`, `SubscriptionService.package(for:)`, `scripts/verify-store-config.py`, and RevenueCat snapshots | Fail if monthly, annual, or lifetime IDs differ, if a local product lacks a mapped package, or if a live offering has zero packages. |
| Trial contract | Compare `P1W` in the StoreKit file, `OnboardingView` and `PaywallView` copy, ASC intro-offer snapshot, and test assertions | Warn on wording drift. Fail if the CTA says trial while no eligible subscription offer is available. |
| Metadata capacity | Run `scripts/validate_metadata.py`, then emit Unicode counts for ordinary fields and UTF-8 byte counts for keywords, using the terminal-LF stripping rule in this audit | Fail missing locale/field, over-limit field, em dash, forbidden template term, or missing URL. Warn under a configurable minimum utilization threshold. |
| Metadata duplication | Tokenize name, subtitle, and keywords per locale, case-fold, and report repeated tokens and unused keyword bytes | Warn only. Do not automatically delete a term without ASC search evidence. |
| Website and legal links | Extract every `https://`, `mailto:`, App Store, EULA, privacy, terms, and support link; request with redirects enabled; compare canonical host and normalized root/nested legal bodies | Fail non-200, bad redirect, missing App Store ID, canonical-host mismatch, or root/nested legal divergence. |
| Screenshot integrity | Read PNG dimensions, SHA-256, filename ordinal, locale, and claimed version; compare with ASC export when supplied | Fail wrong dimensions, duplicate hash, missing ordinal, or asset from an older build. Warn when no App Preview video exists. |
| Deprecated API scan | `rg -n 'UIApplication\.shared|openURL|SKPaymentQueue|SKProductsRequest|UIWebView|NavigationView|onChange\(of:perform:|Thread\.sleep|requestReview\(' CribbageTrainer Shared CribbageTrainerTests CribbageTrainerScreenshots` | Review every match. Allow `requestReview` because it is intentional, allow `Thread.sleep` only in screenshot tests, and require a reason file for other allowlist entries. |
| Silent user errors | `rg -n 'try\? .*restore|try\? .*offerings|try\? .*customerInfo|try\? .*center\.add|try\? await Task\.sleep' CribbageTrainer Shared` | Fail for purchase, restore, offering, notification, or user-visible link paths unless an explicit result state follows. Warn for animation cancellation and test-only sleeps. |
| RevenueCat simulator guard | Search for `Purchases.configure` and inspect all `#if targetEnvironment(simulator)` branches | Fail if a simulator build can configure the production `appl_` key or if a test uses a production customer. |
| Review funnel | Find all `requestReview`, `AppStoreLinks.writeReviewURL`, and `ReviewPromptTracker` calls | Fail if a new call bypasses the centralized eligibility gate; warn if a path cannot distinguish request from submitted review. |
| Build and tests | Run `xcodegen generate` check, unit test scheme, screenshot scheme, and `xcodebuild analyze`; collect warning text and test counts | Fail build/test error, unreviewed Swift concurrency warning, missing generated source, or screenshot test that passes without required assertions. |
| Agent docs | Find root and nearest `AGENTS.md`/`CLAUDE.md`, dated docs, `handoff`, `cursor`, and `codex` paths; scan for stale versions and unresolved status fields | Warn or fail based on path classification. `archive/` must not be the only source for current release instructions. |

Each finding should emit:

```json
{
  "app": "cribbage",
  "bundle_id": "com.jackwallner.cribbage",
  "app_store_id": "6796911073",
  "audit_date": "2026-08-23",
  "rule_id": "website.canonical_consistent",
  "severity": "P1",
  "status": "fail",
  "evidence_path": "docs/index.html",
  "line": 13,
  "symbol": "canonical",
  "observed": "https://jackwallner.com/ios/cribbage/",
  "expected": "one fleet-approved canonical origin",
  "source_kind": "local",
  "live_data_available": false,
  "suggested_fix": "choose canonical origin and update redirects and metadata",
  "validation": "curl both origins, parse canonical and compare ASC URLs"
}
```

Additional app-specific fields should include:

- current project marketing version and build;
- README/site/archive versions found and their paths;
- all metadata locale names and per-field character counts;
- keyword tokens, duplicates with name/subtitle, and unsupported-claim terms;
- screenshot path, width, height, file hash, ordinal, and claimed app version;
- StoreKit product ID, product type, display price, period, and trial;
- RevenueCat offering/package IDs from a live API snapshot when credentials are
  intentionally supplied, never from secrets committed to the repository;
- paywall source enum, default plan, legal URLs, loading/error branches;
- review gate threshold, cooldown, requestReview call sites, and outcome paths;
- event names found and missing from the recommended taxonomy;
- all outbound URLs, HTTP status, redirect target, canonical target, and host;
- deprecated API/compiler warning matches, suppressed errors, and force unwrap
  locations;
- test commands, exit status, test count, and last successful evidence date.

## Evidence gaps for the next implementation agent

The implementation agent must not assume any of these are true until verified:

- current downloads, product-page views, conversion, trial starts, trial
  eligibility, paid conversion, refunds, proceeds, ratings, reviews, and
  retention;
- current ASC metadata, screenshot ordering, editable version, attached build,
  processing state, or review status;
- current RevenueCat offering, package availability, entitlement mapping,
  customer attribute values, or paywall performance;
- live URL status on both `jackwallner.com` and `github.io` origins;
- production crash, hang, launch-failure, or support-contact rates;
- native-language quality or local search ranking in any storefront;
- whether website price/schema/rating values are still current in production.

The strongest next step is a read-only data collection pass that pulls ASC and
RevenueCat snapshots, runs the live link/screenshot checks, and executes the
runtime purchase and accessibility matrix. Only after those baselines exist
should the implementation agent change onboarding or paywall behavior.

## Agent workspace and documentation hygiene

### Inventory and operating model

#### Evidence

- There is no repository-local `AGENTS.md`, `.codex/`, `.claude/`, `.cursor/`,
  or `.agents/` directory. `/Users/jackwallner/AGENTS.md` is workspace-level
  guidance outside this repository. The repository's substantive agent guide
  is `CLAUDE.md`.
- The top-level `CLAUDE.md` is the substantive app guide. It covers product
  rules, RevenueCat and StoreKit, architecture, content workflow, simulator
  constraints, screenshots, and historical release gotchas. It is the right
  place for durable app-specific instructions.
- `CribbageTrainer/Views/Drills/CLAUDE.md` contains a narrow, correctly placed
  interaction invariant for the swipe deck.
- No repository-local `handoff/`, `design/`, Cursor rules, or Codex rules were
  found. `ios27CribbageTrainer.md` is a dated runtime/test note at the root,
  not a maintained handoff. `docs/screenshots/README.md` and the compositor
  scripts are the practical visual-design workflow, but there is no current
  design-system decision record for paywall, onboarding, or accessibility.
- `README.md` is a user/developer entry point with identity, commands, release
  flow, and porting pointers.
- `archive/README.md` explicitly says dated audits and plans are historical and
  that current behavior belongs in the top-level guide and active documents.
- `archive/flow-catalog-2026-07-31.md`, `archive/plan712.md`, and
  `archive/cribbage-accuracy-2026-07-31.md` are dated historical records.
- `docs/tasks/01-accuracy-audit.md` and `docs/tasks/02-quick-session-rebuild.md`
  are short task briefs, but neither records an owner, status, completion date,
  or link to a current issue tracker.
- `docs/research/aso-cribbage.md` is marked final with research dates of
  2026-08-01 and 2026-08-02. `docs/research/cribbage-market.md` correctly says
  it is not current market-size or ranking evidence and must be refreshed.
- `scripts/.asc-state.json` is an ignored local state artifact containing app
  ID 6796911073, draft version 1.2.1, live version 1.2.0, and an update at
  2026-08-17. `scripts/.astro-app.json` is tracked temporary app metadata with
  `appId: null`, `keywordCount: 0`, and `syncedAt: null`. Neither is a reliable
  release source of truth.
- `fastlane/README.md` says it is auto-generated by fastlane. It is generic and
  does not define the repo's actual release gates.
- `scripts/generate_metadata_all.py` contains a prominent stale warning dated
  2026-08-11: its baked-in localized profiles still quote old prices of $1.99,
  $9.99, and $29.99, while `fastlane/metadata/` is declared the source of
  truth. The file still contains those old profile strings, so the warning is
  not sufficient protection if an agent runs it.
- `scripts/testflight.sh` increments `CURRENT_PROJECT_VERSION` in
  `project.yml` with `sed`, regenerates the project, archives, and uploads. It
  is a mutating release command, not a safe validation command. The README
  correctly presents it as a release action, but no separate dry-run or
  preflight contract is documented.

### Contradictions, stale guidance, and classification

| Item | Classification | Evidence | Finding and proposed action |
| --- | --- | --- | --- |
| No repository-local `AGENTS.md` | Add a pointer or document the choice | repository root inventory; workspace `/Users/jackwallner/AGENTS.md` is outside the repo | Keep `CLAUDE.md` as the current substantive guide, then add a repository-root `AGENTS.md` symlink to it if cross-tool discovery requires it. Verify the link in CI. Never add a second policy copy. |
| No local `.codex`, `.claude`, `.cursor`, or `.agents` folders | Keep | repository root inventory | Keep the repo free of tool-specific duplicate instructions. If tool-specific configuration becomes necessary, add only thin pointers that name the canonical guide, not copied policy. |
| Top-level `CLAUDE.md` versus `README.md` | Keep, update | `CLAUDE.md`, `README.md` | Keep both with distinct roles: `README` for quick start and public project identity, `CLAUDE`/`AGENTS` for agent constraints. Update README's version and canonical URLs from one source of truth. |
| `CribbageTrainer/Views/Drills/CLAUDE.md` | Keep | nested `CLAUDE.md` | Keep because it is scoped to a gesture-sensitive directory. Add a one-line pointer from the top-level guide if future agents routinely miss nested guidance. |
| `ios27CribbageTrainer.md` | Update or archive | `ios27CribbageTrainer.md:1-25` | If iOS 27 remains a release target, move it to `docs/quality/` with owner, current status, and a refresh date. Otherwise archive it after extracting the concurrency-warning follow-up into the active test checklist. |
| No `handoff/` or current design decision directory | Add lightweight structure | repository root and `docs/` inventory | Add dated handoffs only for active work and keep design decisions in a small current `docs/decisions/` or `docs/design/` index. Do not make agents infer current UI contracts from archived screenshots or old plans. |
| `README.md` marketing version 1.0 | Update | `README.md:13` versus `project.yml:31` | Update to current release metadata or replace the literal with a command/source-of-truth reference. Add a consistency test. |
| `CLAUDE.md` headings “Game-night rhythm (1.2)” and “iPad (1.2)” | Update | `CLAUDE.md:112,143` versus project 1.2.1 | These are feature labels, but the parenthetical can be mistaken for current app version. Rename to “Game-night rhythm” and “iPad support” or explicitly label it as feature-introduced-in-1.2. |
| `archive/flow-catalog-2026-07-31.md` says build 20/version 1.0 | Archive | `archive/flow-catalog-2026-07-31.md:37-42` | Correctly archived, but add a visible “historical, not current release state” banner near the release handoff. Do not use it for current ASC claims. |
| `archive/plan712.md` | Archive | `archive/plan712.md` | Keep archived. It records the port origin, not current behavior. Link it from a history index if retained. |
| `archive/cribbage-accuracy-2026-07-31.md` | Archive | `archive/cribbage-accuracy-2026-07-31.md` | Keep archived as an evidence record. Convert any unchecked “remaining release checks” into dated resolved/open status if agents may use it for release decisions. |
| `docs/tasks/01-accuracy-audit.md` and `02-quick-session-rebuild.md` | Update or archive | `docs/tasks/*` | They read like completed historical briefs but have no status. Add `Status`, `Owner`, `Last verified`, and links to tests, or move them to `archive/tasks/` once complete. |
| `docs/research/aso-cribbage.md` | Keep, update | `docs/research/aso-cribbage.md:3,10,25,68-77` | Keep as dated ASO evidence. Add “valid through” and a refresh trigger. Do not call it current ranking evidence after competitors/prices age. |
| `docs/research/cribbage-market.md` | Keep, update | `docs/research/cribbage-market.md:3,27-29` | Keep as a research note. Add a last-reviewed field and link to the audit or archive it when superseded. |
| `scripts/generate_metadata_all.py` | Update or archive | stale warning at file top, old prices in profiles | Make it fail closed with a clear exit code, or remove/archive it and use a generator that reads only `fastlane/metadata/` plus a release data file. Never let a warned-but-runnable command regenerate production metadata. |
| `fastlane/metadata/` versus generator profiles | Keep metadata, archive/update generator | `fastlane/metadata/en-US/*`, `scripts/generate_metadata_all.py` | Keep checked-in metadata as the declared source of truth. Move the obsolete generator to `archive/scripts/` or rewrite it to be price-free and test-covered. |
| `scripts/.asc-state.json` | Keep ignored, classify as generated state | `scripts/.asc-state.json`, `.gitignore:12` | Keep only as a local cache for resumable ASC operations. Add a schema/version and generated-file banner if it remains in the workspace. It must never override live ASC or project truth. |
| `scripts/.astro-app.json` | Move or archive | `scripts/.astro-app.json` has null app ID and `syncedAt: null` | Move to a tool-specific ignored cache or delete in a separate cleanup task. It is misleading beside release scripts and should not be consumed by a scanner. |
| `fastlane/README.md` | Keep, update | `fastlane/README.md` | Keep as generated fastlane documentation, but add a short link to the repo release checklist. Do not manually edit generated sections. |
| `scripts/testflight.sh` | Keep, document | `scripts/testflight.sh:10-35` | Keep as an explicit mutating release command. Document that it changes build number and uploads, and add a non-mutating preflight wrapper for CI/watchdog use. |
| `audit823.md` | Keep as dated audit artifact | this file | Keep at repository root because the fleet audit contract requires that location. Add later audits with a new date only when a new audit is commissioned; do not silently overwrite evidence outside the requested workflow. |

### Proposed canonical layout for Cursor, Claude, and Codex

Use one repository authority and tool-neutral documents. The tree below is a
proposed target, not the current repository state. In particular, the root
`AGENTS.md` pointer does not exist today.

```text
cribbage/
├── AGENTS.md -> CLAUDE.md       # recommended compatibility pointer, never a copy
├── CLAUDE.md                    # canonical agent/app instructions
├── README.md                    # human quick start and product identity
├── audit823.md                  # dated fleet audit deliverable
├── project.yml                 # build/version source for XcodeGen
├── CribbageTrainer/             # app target and scoped UI guidance
│   └── Views/Drills/CLAUDE.md   # narrow interaction invariants
├── Shared/                      # models, content, services
├── docs/
│   ├── research/                # dated evidence, refresh dates required
│   ├── tasks/                   # active tasks with status/owner/date
│   ├── legal/                   # optional future canonical legal source
│   └── screenshots/             # capture workflow and proofs
├── fastlane/metadata/           # checked-in ASC metadata source
├── scripts/                    # read-only checks and explicit mutating release commands
└── archive/                    # historical artifacts, never current instructions
```

Cursor, Claude, and Codex should all discover `AGENTS.md` first, follow the
symlink to `CLAUDE.md`, and then apply the nearest scoped `CLAUDE.md` for a
subdirectory. A future `.cursor/rules/` or `.codex/` directory should contain
only pointers or tool integration configuration, never a second copy of app
policy. The canonical layout should define this precedence in `README.md` and
the top-level guide:

1. User request and system/developer policy.
2. Root `AGENTS.md`/`CLAUDE.md`.
3. Nearest nested scoped guide.
4. Current source/configuration and tests.
5. Dated research and audit artifacts.
6. `archive/` only for historical context.

### Release-regression and production-crash signals for the fleet watchdog

The watchdog should treat these as app-specific high-value signals, not merely
generic source lint:

- **Build identity drift:** emitted `CFBundleShortVersionString` and
  `CFBundleVersion` differ from `project.yml`, the ASC draft/live version,
  `scripts/.asc-state.json`, website JSON-LD, README, or release notes.
- **Offering regression:** live/current RevenueCat offering is missing, has
  zero packages, or lacks monthly, annual, or lifetime package IDs expected by
  `SubscriptionService.package(for:)`.
- **StoreKit regression:** local product IDs, types, periods, prices, and trial
  lengths differ from the ASC snapshot or from website commercial copy.
- **Entitlement regression:** product purchase succeeds but no active
  entitlement appears after bounded confirmation retries, or the entitlement
  key set changes from the documented `pro`/`Cribbage+` compatibility state.
- **Onboarding regression:** a fresh install cannot reach a free Quick Session,
  the required skill choice has no selectable option, the trial CTA has no
  package, or a purchase/restore error leaves the user without a visible exit.
- **First-session crash/hang:** launch, onboarding, How to Play, Feature Tour,
  Quick Session grading, and `DrillCompleteView` crash or exceed a watchdog
  latency threshold. These are the activation-critical paths and should be
  reported separately from background crashes.
- **Content crash/regression:** `DrillLibrary` or generated `HandGenerator`
  produces an empty list, duplicate physical card, invalid six-card discard,
  invalid answer index, or an authored item omitted from the validity tests.
- **State corruption:** app relaunch loses `isPro`, session progress, missed
  items, streak, daily challenge completion, or a pending game-night route.
- **Review-funnel regression:** review sheet appears before the configured
  positive-moment/launch threshold, appears twice in one session, or opens an
  invalid App Store URL. A native `requestReview` call cannot prove a rating,
  so only call eligibility and outcome-path signals should be monitored.
- **Release UX regression:** screenshot capture cannot complete, the What's New
  sheet blocks the first Home frame, a back/close action routes to Settings or
  fails to dismiss, or a screenshot claims a feature absent from the binary.
- **Accessibility regression:** a release removes labels/actions for the
  custom plan cards, swipe deck, discard selection, Restore, legal links, or
  Quick Session answer controls, or introduces a Dynamic Type layout overflow.
- **Crash signature triage:** for each production crash, emit build, OS major,
  device class, scene/state enum, last bounded action enum, paywall source if
  relevant, and a redacted stack/signature. Never send card content, feedback
  text, email, or purchase secrets.
- **Operational silence:** a build has no launch, onboarding, session, paywall,
  purchase, or error heartbeat in an expected TestFlight/sandbox test window.
  Silence should be distinguished from zero user activity so an instrumentation
  regression is not mistaken for a healthy release.

The watchdog report should classify each signal as `release_blocker`, `runtime
regression`, `production_crash`, `conversion_observability_gap`, or
`historical_stale_document`, and include the exact path, line/symbol, build,
first-seen date, last-seen date, and a reproducible validation command.

## Verification performed for this audit

- Read the repository guide, README, project.yml, app source, shared services,
  StoreKit configuration, metadata, screenshots, scripts, tests, website, legal,
  support, research, and archive documents.
- Ran `python3 scripts/validate_metadata.py`, which passed for 50 locales.
- Attempted `python3 scripts/verify-store-config.py`; it stopped because ASC
  credentials were unavailable, so no live data was claimed.
- Confirmed local screenshot dimensions: iPhone 1320 x 2868 and iPad 2064 x
  2752 for six screenshots each.
- Final worktree verification shows only the intended untracked
  `/Users/jackwallner/cribbage/audit823.md`; no other path is changed.
- No commit, push, upload, app-code edit, or configuration edit was performed.
