# Cribbity ASO research brief

Status: DRAFT
Working placeholder: Cribbity
Final product name: pending ASO review
Game: Cribbage
Slug: cribbage
Primary storefront: en-US
Research date: 2026-07-31

Cribbity is the current port-proof label. It is not a naming recommendation
for a future app and must be replaced after the final name and storefront
positioning are researched.

## Product and search intent

- Product type: cribbage practice trainer, not a complete multiplayer game
- Audience: new and returning cribbage players who want short practice reps
- Primary outcome: improve counting, pegging, discarding, and table decisions
- Product promise: short, focused cribbage drills that explain the answer
- Differentiators: room-based practice, generated hands, and mistake review

These are product hypotheses from the binary, not completed keyword research.

## Competitor evidence

| App or source | Storefront | Query or URL | Promise observed | Gap or opportunity |
| --- | --- | --- | --- | --- |
| To research | en-US | cribbage practice | Compare trainer intent with game intent | Separate learning from play |
| To research | en-US | cribbage counting | Compare rules and scoring language | Lead with a concrete skill |
| To research | en-US | cribbage pegging | Compare novice terminology | Explain the table decision |

Before final metadata, replace every `To research` row with dated App Store
search evidence, competitor links, and a documented decision.

## Keyword map

| Term | Intent | Locale | Evidence | Decision |
| --- | --- | --- | --- | --- |
| cribbage | game | en-US | Product category, verify demand | Candidate |
| practice | problem | en-US | Product mechanic, verify intent | Candidate |
| counting | skill | en-US | Product mechanic, verify query use | Candidate |
| pegging | skill | en-US | Product mechanic, verify query use | Candidate |
| discard | skill | en-US | Product mechanic, verify query use | Candidate |

Rejected or prohibited terms:

- Competitor names, unsupported multiplayer claims, gambling language, and
  any rules or feature that the binary does not teach.

## Metadata draft

Name: Cribbity, provisional
Subtitle: Cribbage Practice, One Hand, provisional
Keywords: cribbage,practice,scoring,pegging,discard,crib,counting,beginner,lesson,drill,rule,strategy,quiz
Description angle: short practice rooms, concrete explanations, free beginner
access, and Cribbity+ extras. The final description needs a researched
positioning pass and native copy review.
Promotional text angle: pending launch message and release timing.

## Localization plan

| Locale | Native reviewer | Query evidence | Translation status | Approved date |
| --- | --- | --- | --- | --- |
| en-US | Jack, pending final review | This brief | provisional fallback | pending |

The current 50 locale folders are a complete fallback package for the port
proof. Each target locale needs local cribbage vocabulary, query evidence,
native review, and a decision to translate or explicitly retain the fallback.

Fallback locales and why they are acceptable:

- All non-en-US locales are temporary English fallbacks for TestFlight and
  must be reviewed before a public release.

## Screenshot and experiment plan

- Screenshot 1 proves: a beginner can start a short practice session.
- Screenshot 2 proves: the app explains a counting or pegging decision.
- Screenshot 3 proves: room structure and mistake review.
- Test hypothesis: a skill-specific subtitle and first screenshot convert
  better than a generic game claim.

## Release gate

- [ ] Placeholder name and placeholder terms removed.
- [ ] Final name checked against App Store and domain availability.
- [ ] Final keyword set has dated search evidence.
- [ ] Competitor names and trademarks are absent from metadata.
- [ ] Every selected term describes a real feature or user intent.
- [ ] Target locales have native review or an explicit fallback decision.
- [ ] `validate_aso_brief.py` passes without `--allow-draft`.
- [x] `validate_metadata.py` passes for every locale in the port proof.
