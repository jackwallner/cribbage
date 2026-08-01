# Runtime flow catalog

The port preserves the source app's runtime structure:

| Flow | Primary interaction | Completion |
| --- | --- | --- |
| Onboarding | skill choice, primer, feature tour | real Quick Session or Home escape hatch |
| Card Room | swipe cards and quizzes | graded drill completion |
| Scoring Room | hand recognition and count explanations | graded drill completion |
| Discard Room | select two cards from a six-card deal | scenario score and explanation |
| Pegging Room | choices and running-total questions | graded drill completion |
| Master Tables | advanced locked content | membership-gated drill completion |
| Practice | generated, review, or timed items | score, best score, or review history |

The dedicated simulator and the test command are recorded in the handoff notes
after the final runtime pass.

## Final parity pass, 2026-08-01

- Device: `agent-cribbage`, UDID `37E4A923-3AC9-4425-ADAB-F356FF51F103`.
- Build: `xcodegen generate`, then the `CribbageTrainer` scheme on the
  dedicated simulator.
- Tests: 52 tests, 0 failures.
- Headless UI checks: Home, Get Started, Scoring Room, Discard Room, a live
  six-card discard screen, Settings, and the Cribbity+ paywall. The paywall
  showed yearly, lifetime, and monthly pricing, trial and renewal language,
  Restore, Terms of Use, and Privacy Policy.
- Release captures: six real screens in `scripts/screenshot_raw/`,
  `fastlane/screenshots/en-US/`, `docs/screenshots/`, and the six public
  `docs/appstore-screenshot-*.png` assets.
- Simulator safety: the final runtime log contained no production RevenueCat
  configure call or RevenueCat API endpoint.
- Structural gate: Cardport parity passed against `/Users/jackwallner/mahj`.
