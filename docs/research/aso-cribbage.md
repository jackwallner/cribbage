# Cribbage Trainer: Count & Peg ASO research brief

Status: FINAL
Final product name: Cribbage Trainer: Count & Peg
Installed display name: Cribbage Trainer
Membership name: Cribbage+
Game: Cribbage
Slug: cribbage
Primary storefront: en-US
Research date: 2026-08-01

## Product and search intent

- Product type: cribbage practice trainer, not a complete multiplayer game.
- Audience: new and returning cribbage players who want short practice reps.
- Primary outcome: improve counting, pegging, discarding, and table decisions.
- Product promise: short, focused cribbage drills that explain the answer.
- Differentiators: room-based practice, generated hands, mistake review, and
  no opponent or account requirement in the free rooms.
- Naming decision: use the direct game term in the brand, then add the two
  signature skills, counting and pegging, in the App Store qualifier.

## Competitor evidence

Evidence reviewed on 2026-08-01 in the US App Store:

| App or source | Storefront | URL | Promise observed | Gap or opportunity |
| --- | --- | --- | --- | --- |
| Cribbage - Play & Learn | en-US | https://apps.apple.com/us/app/cribbage-play-learn/id6758065339 | Step-by-step lessons combined with full games against AI opponents. | Own the focused practice position for players who want skill reps without a full game. |
| Cribbage Lab | en-US | https://apps.apple.com/us/app/cribbage-lab/id6760797182 | Training drills, hand analysis, card scanning, and full games. | Keep the loop calm and explanation-first, with no scanner or opponent surface. |
| Cribbage Classic | en-US | https://apps.apple.com/us/app/cribbage-classic/id901900997 | Full cribbage play with automatic counting and discard or pegging support. | Lead with deliberate counting, discard, and pegging practice rather than automatic play. |
| Cribbage Blitz | en-US | https://apps.apple.com/us/app/cribbage-blitz-skill-practice/id1447919543 | Skill practice framed around speed and avoiding counting errors. | Differentiate on short, pressure-free coaching with an explanation behind each answer. |

The category is crowded with complete games, AI opponents, and analyzers. The
binary deliberately occupies the adjacent practice niche. It should not claim
multiplayer, hand scanning, automatic analysis, or a full game.

## Keyword map

| Term | Intent | Locale | Evidence | Decision |
| --- | --- | --- | --- | --- |
| cribbage | game | en-US | Present in every reviewed competitor and the product category. | Keep in the name and keyword field. |
| practice | problem | en-US | The product's defining use case and a recurring competitor intent. | Keep in the subtitle and keyword field. |
| counting | skill | en-US | Core room and recurring lesson language in competitor listings. | Keep in subtitle, description, and keywords. |
| pegging | skill | en-US | Core room and explicit skill language in competitor listings. | Keep in name, subtitle, description, and keywords. |
| discard | skill | en-US | Core room and a common analysis feature in competitor listings. | Keep in subtitle, description, and keywords. |
| lesson | learning | en-US | Used by learning-oriented competitor positioning. | Keep in keywords and description. |
| quiz | learning | en-US | Accurate description of the choice drills in the binary. | Keep in keywords. |

Rejected or prohibited terms:

- Competitor names, unsupported multiplayer claims, gambling language, card
  scanning, automatic hand analysis, and any feature absent from the binary.

## Metadata draft

Name: Cribbage Trainer: Count & Peg
Subtitle: Counting, Pegging & Discards
Keywords: cribbage,practice,scoring,pegging,discard,crib,counting,beginner,lesson,drill,rule,strategy,quiz
Description angle: five-minute practice rooms for counting, scoring, discarding,
pegging, generated practice, and mistake review, with a clear explanation
behind each answer.
Promotional text angle: fresh generated hands, spaced mistake review, and a
90-second timed challenge.

## Localization plan

| Locale group | Native reviewer | Query evidence | Translation status | Approved date |
| --- | --- | --- | --- | --- |
| en-US | Jack | This brief and the App Store competitor set above. | Approved canonical copy. | 2026-08-01 |
| Other supported locales | Jack for fallback validation | No locale-specific search research in this release. | Complete English fallback package, intentionally deferred until native review. | 2026-08-01 |

The 50 locale folders are complete and use the approved en-US fallback copy.
Native translation is a follow-up localization project, not an identity or
metadata completeness blocker for the initial English storefront release.

## Screenshot and experiment plan

- Screenshot 1 proves: a beginner can start a short mixed practice session.
- Screenshot 2 proves: the app explains a counting or pegging decision.
- Screenshot 3 proves: the room structure supports focused practice.
- Screenshot 4 proves: a discard decision shows the tradeoff and reasoning.
- Screenshot 5 proves: the home lobby exposes progress and the free surface.
- Screenshot 6 proves: the card room teaches the standard deck.
- Test hypothesis: a skill-specific title and first screenshot convert better
  than a generic complete-game claim.

## Release gate

- [x] Final name follows the trainer naming pattern and fits Apple limits.
- [x] Competitor evidence is dated and the selected terms describe real
  features.
- [x] Competitor names and unsupported claims are absent from metadata.
- [x] All 50 metadata folders contain complete fallback fields.
- [x] Six real product screenshots are present and distinct from Mahj.
- [x] `validate_aso_brief.py` passes without `--allow-draft`.
- [x] `validate_metadata.py` passes for every supported locale.
- [ ] Native translation review for non-en-US storefronts remains a later
  localization pass.
