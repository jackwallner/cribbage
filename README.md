# Cribbity

Cribbity is a five-minute cribbage practice app for counting, pegging,
discarding, and table decisions. The app is an independent practice companion,
not a complete multiplayer game.

## Product identity

- Display name: Cribbity
- Bundle ID: `com.jackwallner.cribbage`
- App Store ID: `6796911073`
- Marketing version: `1.0`
- Public site: <https://jackwallner.github.io/cribbage/>
- Support: <https://jackwallner.github.io/cribbage/support>
- Privacy: <https://jackwallner.github.io/cribbage/privacy-policy>
- Terms: <https://jackwallner.github.io/cribbage/terms>
- Membership: Cribbity+
- Name status: placeholder, pending the per-app ASO brief in
  `docs/research/aso-cribbage.md`

## Development

```sh
xcodegen generate
python3 scripts/validate_metadata.py
xcodebuild -project CribbageTrainer.xcodeproj -scheme CribbageTrainer \
  -destination 'platform=iOS Simulator,id=<agent-cribbage-udid>' \
  test CODE_SIGNING_ALLOWED=NO
```

Use the dedicated headless simulator `agent-cribbage`. Never open
Simulator.app. Simulator builds must not configure the production RevenueCat
key.

## Release

Read [docs/asc-submission-checklist.md](docs/asc-submission-checklist.md), then
use the scripts in `scripts/` for the pull, draft-version, localization,
metadata, product, readiness, and TestFlight workflow. Run the TestFlight
archive/upload only after the headless test pass:

```sh
./scripts/testflight.sh
```

Do not submit for App Review automatically. A readiness report is the normal
end of a port; submission is a separate decision.

Before a public name or metadata change, complete the ASO brief, replace the
placeholder name everywhere, and run:

```sh
python3 scripts/validate_aso_brief.py \
  --brief docs/research/aso-cribbage.md \
  --product-name "<final name>"
```

## Reusable port workflow

The source template and complete end-to-end porting instructions live in
`/Users/jackwallner/cardport`. Start with
`cardport/docs/porting-guide.md`, then use the scaffold and verification
scripts. The `.cardport.json` file records public identity values for this port.
