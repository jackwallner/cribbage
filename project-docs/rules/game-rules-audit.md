# Cribbage rules audit, 2026-10-22

Baseline: `cd102957`. Scope: all registered scoring, pegging, discard and table-advice exercises, the Swift/Kotlin scoring and recommendation evaluators, and real discard grading. Unrelated edits in the original tree are preserved.

Final integration base: `8c82723` (current origin/main). Some corrections listed below were already present there and were retained. The table records findings in the original local checkout as well as the remaining fixes. Final verification covers the newer generated engines too.

## Authority and rule table

[American Cribbage Congress 2025 rulebook](https://cribbage.org/NewSite/rules/rulebook_2025.pdf), especially scoring chart 1.7 and rules 6, 7, 9 and 10. The app teaches standard two-player, six-card cribbage to 121, plus an optional muggins lesson. It is not a complete multiplayer implementation.

| Rule | Native table test on both platforms |
| --- | --- |
| Each player keeps four of six; dealer owns the four-card crib. Pone counts first, then dealer's hand, then crib. First to 121 wins immediately. | Existing deal/content tests; `teachingUsesDealerCribAndAccMuggins` |
| Fifteens: 2 per distinct combination. Pairs: 2 each; triple 6, four alike 12. | Fifteen hand component rows |
| Runs: consecutive ranks, ace low, no wrap; only maximal runs, with all duplicate combinations. | Single, double, triple, double-double and five-card runs |
| Hand flush: all four held cards match, 4 points; matching starter makes 5. Starter plus only three held cards never forms a flush. Crib requires all five. | Hand/crib/starter-only flush rows; invalid hand-size rows |
| Nobs: held/crib jack matches starter suit, 1. Starter jack is heels, 2 to dealer, not nobs. | 29/28, crib nobs, starter-jack and heels rows |
| Pegging: total at most 31. Score final contiguous suffix pairs/runs, not arbitrary hand combinations. 15 and 31 each score 2. A 31 gets no additional last-card point. | Eleven pegging sequences, legal-go and last-card tables |
| Maximum hand: three held fives plus jack, fourth five starter matching jack: 29 (16 fifteens, 12 pairs, 1 nobs). Wrong jack suit: 28. | Explicit component rows |
| Muggins is agreed in advance. It claims missed play/hand/crib points after pegging is completed or forfeited. Heels, penalties, muggins and backward-pegging losses are excluded. | Muggins enabled/disabled and score-kind table; actual lesson copy |

## Corrections

| Before | After | Regression |
| --- | --- | --- |
| Dealer lesson advises minimizing the pone's crib points, despite dealer owning the crib. | Build hand plus own crib; actual graded choice changed. | `teachingUsesDealerCribAndAccMuggins` |
| `averageCrib` omits nobs and five-card flushes, calls estimate a true value, claims omission cannot change choices. | Includes both suit-dependent terms. Labels the calculation as a uniform random-opponent-discard model. | Independent enumeration of 45,540 physical completions each for two deals, including a held jack and a possible incoming jack |
| Two equally best physical discard pairs graded differently (`master-discard-4`, `master-discard-6`). | Either optimal equivalent pair receives full credit on both platforms, including persisted answer result. | `equivalentDiscardsReceiveFullCredit`, same production grader used by both UIs |
| 6+7 claimed to make fifteen; four-heart H2,H6,H9,HQ hand described as 4 points. | 6+7 totals 13, with run potential. The flush hand counts 6. | All 22 authored keep totals plus explicit 6+7 regression |
| 7-8 described as the strongest possible crib pair. | Claim restricted to its actual deal and stated model. | Existing complete discard ranking checks |
| Flush component accepts fewer/more than four held cards. | Only a four-card held hand can receive a flush component. | Hand sizes 0,1,2,3,5 reject flush |
| Five-card recognition layouts show no designated starter but call a jack actual nobs and four suited cards a scored flush. | Labels now say nobs/flush potential; every pattern prompt states that no starter is designated. Generated explanations condition points on keeping four and the actual starter. | Potential versus actual scoring assertions and shared prompt |
| Muggins lesson broadly permits claiming every missed score. | ACC scope and exceptions explicit. | Muggins score-kind and lesson-copy checks |

All authored recommended pairs remain optimal under the corrected uniform model. Exact-equivalence tolerance is 1e-9, replacing the old 0.05 recommendation tolerance. This model measures expected hand plus/minus expected crib. It does not model optimal opposing discards, pegging strategy, board position or win probability. Lessons do not justify a unique winning strategy solely from an unspecified close board.

## Verification

The same independently authored `rules-reference.json` drives `AuthoritativeRulesTests` and JUnit. The newer upstream `RulesAuditTests` and `PracticeGeneratorTests` are retained, including generated hand counts, pegging, and independent counting cross-checks. Android parity exports are additional checks. Run `xcodegen generate`, the `CribbageTrainer` unit-test scheme and `fm-gradle testDebugUnitTest` from `android/`. See `verification.md` for final receipts.
