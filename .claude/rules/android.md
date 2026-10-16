---
paths:
  - "android/**"
  - "docs/android-*.html"
  - "scripts/android-export/**"
  - "scripts/sync-android-content.sh"
  - "scripts/play_screenshot_compositor.py"
  - "scripts/play-products.py"
  - "scripts/play-upload.sh"
  - "scripts/make_android_icon.py"
---

# Cribbage Trainer Android rules

## Identity and products

- Native Android code is in `android/`, a screen-for-screen port of the iOS app
  (same copy, tokens, flows, product IDs). When iOS changes, port the change.
  It started from `~/mahj/android`; every Mahj screen, string and asset was
  stripped.
- Package `com.jackwallner.cribbage`, launcher label "Cribbage Trainer", Play
  title "Cribbage Trainer: Count & Peg", paid tier "Cribbage+". Feedback and
  Play contact email `jackwallner+m@gmail.com` (same as iOS).
- Products (same IDs as iOS): subscriptions `com.jackwallner.cribbage.monthly`
  and `com.jackwallner.cribbage.yearly` (base plans `monthly` / `yearly`, 7-day
  `trial-7d` new-customer offer), lifetime one-time product
  `com.jackwallner.cribbage.lifetime` (purchase option `lifetime`). Android US
  ladder $5.49 / $23.99 / $55.99, about 20% under iOS ($6.99 / $29.99 /
  $69.99); local prices are Play's conversion plus the fleet PPP curve. Never
  put prices in listing copy or app literals (`TrialCopyTest` pins the
  fallback strings).
- RevenueCat project `proj371df86d`: Test Store app `app667e0c7167` (Debug key
  `apikey24fc2c5009`), Play app `appabc719e07c` (`goog_` key
  `apikey099742bd86`, release only), App Store app `appcdf961b5f7`.
  Entitlements `Cribbage+` (`entl980b601a21`) and `pro` (`entlb8993b5f7d`);
  either unlocks, and each holds the Play, App Store and Test Store products.
  The app reads offering `android` (`ofrng9c2959a40d`, not current; iOS keeps
  `default`) with `$rc_monthly` (`pkge3fbd2a12fc`), `$rc_annual`
  (`pkge6e1fb06e26`) and `$rc_lifetime` (`pkge0bc7bf1971`), each holding the
  Play product (`...monthly:monthly`, `...yearly:yearly`, `...lifetime`) and
  the Test Store twin (`monthly`, `yearly`, `lifetime`).
- Play reviewers unlock Cribbage+ with a code (long-press Settings > Version).
  Only its SHA-256 is in the build (`PLAY_REVIEW_CODE_SHA256` in
  `local.properties`); the code is `CRIBBAGE_PLAY_REVIEW_CODE` in
  `~/.cribbage_credentials` and goes in Play Console App access. Never commit
  it.

## Content and parity

- Content and engine fixtures come from Swift, never hand-edited:
  `scripts/sync-android-content.sh` runs `scripts/android-export/` and writes
  `app/src/main/resources/cribbage-content.json` and the test fixture
  `cribbage-parity.json`. Rerun it after changing `Shared/Models`,
  `Shared/Content`, `WhatsNew.swift` or `ChoiceShuffle.swift`.
- `SeededRandom.kt` is the Swift RNG bit for bit (FNV-1a seed, xorshift64*,
  Lemire bounded draw, forward Fisher-Yates), so seeded deals, choice order
  and the daily Cribbage Minute match iOS. The parity unit tests compare
  against the exported fixtures.

## Deliberate differences from iOS

- Purchase copy names Google Play and has no "24 hours before the end of the
  period" clause (Play has no such rule).
- The review prompt keeps the iOS gates (second launch on, 30-day cooldown) and
  calls `launchReviewFlow` with no enjoyment question. Settings says "Rate
  Cribbage Trainer" and opens the Play listing.

## Build

- JDK 17, checked-in Gradle wrapper, AGP 9.4.1, Kotlin 2.4.20, minSdk 26,
  target/compile 36.
- `android/local.properties` (ignored, mode 600) holds `REVENUECAT_TEST_KEY`,
  `REVENUECAT_PLAY_KEY`, `PLAY_REVIEW_CODE_SHA256` and `PLAY_UPLOAD_*` (upload
  keystore `~/.android/keystores/cribbage-upload.p12`, alias `upload`, password
  `CRIBBAGE_PLAY_UPLOAD_PASSWORD` in `~/.cribbage_credentials`). Release builds
  fail without them. Upload cert SHA-256
  `B1:A6:6A:83:41:46:15:B4:93:72:2C:63:27:54:E6:E0:07:68:14:A4:D8:72:FA:BA:FE:A1:A6:13:97:7D:A6:0A`.
- `scripts/make_android_icon.py` derives the adaptive icon layers, legacy and
  round icons and `play-assets/icon-512.png` from the iOS AppIcon.
- Increment `versionCode` on every Play upload. 1.2.3 is versionCode 1.
- `scripts/play-upload.sh [validate|internal|internal-draft|production-draft]`
  and `scripts/play-products.py [--dry-run]` need `PLAY_SERVICE_ACCOUNT_JSON`.
  Neither has been run yet.

## Emulator (remote MacBook Pro only)

Follow the `android-dev` skill's Remote MacBook Pro section. Host
`jackwallner@192.168.4.25` (strict host keys), SDK
`/Users/jackwallner/Library/Android/sdk`. The Pro has no cmdline-tools and no
JDK 17: sync `android/` (minus `build/`, `.gradle/`, `local.properties`,
`play-assets/`) to `~/cribbage-agent-test/android`, write a debug-only
`local.properties` (sdk.dir, Test Store key, review digest), and unpack a
temporary Temurin 17 into `~/cribbage-agent-test/jdk`. Create the temporary AVD
`cribbage_agent_test` by hand (`.ini` plus a `config.ini` cloned from another
agent AVD, `android-36` `google_apis_playstore` x86_64, 1080x2400), boot it
headless on port 5566:

```sh
ssh jackwallner@192.168.4.25 'nohup ~/Library/Android/sdk/emulator/emulator -avd cribbage_agent_test -port 5566 -no-window -no-audio -no-boot-anim -no-metrics -gpu swiftshader_indirect > ~/cribbage-agent-test/emulator.log 2>&1 &'
ssh jackwallner@192.168.4.25 '~/Library/Android/sdk/platform-tools/adb -s emulator-5566 shell getprop sys.boot_completed'
```

Run connected tests there with `ANDROID_SERIAL=emulator-5566`
`./gradlew --no-daemon --max-workers=2 connectedDebugAndroidTest`. Afterwards
`adb -s emulator-5566 emu kill`, then delete only
`~/.android/avd/cribbage_agent_test.{avd,ini}` and `~/cribbage-agent-test`.
Never touch `small_phone` (emulator-5554) or other agents' AVDs. The Pro is a
2-core 2015 i7: a cold boot takes about 5 minutes; let it settle before a
connected run.

Debug launch extras (`DebugLaunchOptions`, debug builds only): `resetAll`,
`onboarded`, `skillLevel`, `seedProgress`, `forcePro`, `appearance`, `uiTest`.
Test tags are exposed as resource ids.

## Store assets

`StoreScreenshotTest` (excluded from the connected suite; run it with
`am instrument -w -e class com.jackwallner.cribbage.StoreScreenshotTest com.jackwallner.cribbage.test/androidx.test.runner.AndroidJUnitRunner`)
writes the six raw 1080x2400 captures to
`/sdcard/Android/data/com.jackwallner.cribbage/files/screens/`, the same six
screens as the App Store set. Turn System UI demo mode on first. Pull them
into `android/play-assets/raw/` and run
`python3 scripts/play_screenshot_compositor.py` for the 1080x1920 frames (App
Store headlines) and the 1024x500 feature graphic. Listing text and the
changelog are in `android/play-assets/metadata/android/en-US/` (English only,
no prices, no em dashes). Privacy and terms pages are
`docs/android-privacy.html` and `docs/android-terms.html` on GitHub Pages.

## Play state (2026-10-16)

Not yet created. The app record, listing, App content declarations, products,
service account access and every upload are still to do in Play Console.
