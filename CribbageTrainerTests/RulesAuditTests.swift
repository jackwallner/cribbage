import XCTest
@testable import CribbageTrainer

/// Hand-computed cross-checks of the scoring engines against the American
/// Cribbage Congress rules (six-card, two-player). Every total below was
/// worked out by hand, so a change that shifts a rule fails here first.
final class RulesAuditTests: XCTestCase {
    private func hand(_ cards: PlayingCard..., starter: PlayingCard, crib: Bool = false) -> Int {
        HandScoring.score(hand: cards, starter: starter, isCrib: crib)
    }

    // MARK: - Hand and crib counts

    func testTwentyNineAndTwentyEight() {
        XCTAssertEqual(hand(.c(5), .d(5), .h(5), .s(11), starter: .s(5)), 29)
        // Jack in the wrong suit loses only nobs.
        XCTAssertEqual(hand(.c(5), .d(5), .h(5), .h(11), starter: .s(5)), 28)
        // Three 5s and a king with the fourth 5 cut: 16 + 12 and no jack.
        XCTAssertEqual(hand(.c(5), .d(5), .h(5), .s(13), starter: .s(5)), 28)
    }

    func testDoubleRunDoubleDoubleRunAndTripleRun() {
        // 6-7-8-8-9: fifteens 6+9, 7+8, 7+8 = 6, pair 2, two runs of four = 8.
        XCTAssertEqual(hand(.h(7), .s(8), .d(8), .c(9), starter: .h(6)), 16)
        // 4-4-5-6-6: four fifteens 8, two pairs 4, four runs of three 12.
        XCTAssertEqual(hand(.h(4), .s(4), .d(5), .c(6), starter: .h(6)), 24)
        // 7-7-7-8-9: three fifteens 6, three pairs 6, three runs of three 9.
        XCTAssertEqual(hand(.h(7), .s(7), .d(8), .c(9), starter: .d(7)), 21)
        // 7-7-8-8-9: eight points of fifteens, four of pairs, twelve of runs.
        XCTAssertEqual(hand(.c(7), .d(7), .h(8), .s(8), starter: .c(9)), 24)
        // 4-5-5-5-6: four fifteens, three pairs, a triple run of three.
        XCTAssertEqual(hand(.c(4), .d(5), .h(5), .c(6), starter: .s(5)), 23)
    }

    func testHandFlushVersusCribFlush() {
        let hearts: [PlayingCard] = [.h(2), .h(6), .h(9), .h(13)]
        // Fifteens 6+9 and 2+3+K are worth 4 in either place.
        XCTAssertEqual(HandScoring.score(hand: hearts, starter: .s(3)), 8)
        XCTAssertEqual(HandScoring.score(hand: hearts, starter: .h(3)), 9)
        // Four cards of one suit score nothing in the crib, five score 5.
        XCTAssertEqual(HandScoring.score(hand: hearts, starter: .s(3), isCrib: true), 4)
        XCTAssertEqual(HandScoring.score(hand: hearts, starter: .h(3), isCrib: true), 9)
        XCTAssertEqual(HandScoring.flush(hand: hearts, starter: .s(3), isCrib: true), 0)
    }

    func testThreeCardFlushScoresNothing() {
        let mixed: [PlayingCard] = [.h(2), .h(6), .h(9), .s(13)]
        XCTAssertEqual(HandScoring.flush(hand: mixed, starter: .h(3), isCrib: false), 0)
    }

    func testNobsNeedsTheStarterSuitAndAJackInTheHandOrCrib() {
        XCTAssertEqual(hand(.d(11), .c(2), .s(6), .h(8), starter: .d(3)), 3)
        XCTAssertEqual(hand(.d(11), .c(2), .s(6), .h(8), starter: .c(3)), 2)
        XCTAssertEqual(HandScoring.nobs(hand: [.d(11), .c(2), .s(6), .h(8)], starter: .d(3)), 1)
        // A jack as the starter is not nobs; the dealer pegs his heels instead.
        XCTAssertEqual(HandScoring.nobs(hand: [.d(2), .c(7), .s(6), .h(8)], starter: .d(11)), 0)
    }

    func testAZeroHandScoresZero() {
        // The "nineteen" hand: no fifteen, pair, run, flush or nobs.
        XCTAssertEqual(hand(.c(10), .d(8), .h(6), .s(4), starter: .c(13)), 0)
    }

    func testCrossCheckAgainstAnIndependentCounter() {
        var generator = SplitMix(seed: 0xC1BB)
        for _ in 0..<4000 {
            let dealt = Array(PlayingCard.standardDeck.shuffled(using: &generator).prefix(5))
            let cards = Array(dealt.prefix(4))
            for crib in [false, true] {
                XCTAssertEqual(
                    HandScoring.score(hand: cards, starter: dealt[4], isCrib: crib),
                    Self.slowScore(hand: cards, starter: dealt[4], crib: crib),
                    "\(dealt.map(\.shortLabel)) crib=\(crib)"
                )
            }
        }
    }

    func testScoresStayInsideTheReachableRange() {
        var generator = SplitMix(seed: 29)
        for _ in 0..<30_000 {
            let dealt = Array(PlayingCard.standardDeck.shuffled(using: &generator).prefix(5))
            let score = HandScoring.score(hand: Array(dealt.prefix(4)), starter: dealt[4])
            XCTAssertLessThanOrEqual(score, 29)
            XCTAssertFalse([19, 25, 26, 27].contains(score))
        }
    }

    /// Counts a hand by brute force over card subsets, the way the rules are
    /// worded rather than the way the engine is written.
    private static func slowScore(hand: [PlayingCard], starter: PlayingCard, crib: Bool) -> Int {
        let all = hand + [starter]
        var total = 0
        var runSets: [Set<Int>] = []
        for mask in 1..<(1 << all.count) {
            let indices = all.indices.filter { mask & (1 << $0) != 0 }
            let chosen = indices.map { all[$0] }
            if chosen.map(\.cribbageValue).reduce(0, +) == 15 { total += 2 }
            if chosen.count == 2, chosen[0].rankValue == chosen[1].rankValue { total += 2 }
            let ranks = chosen.map(\.rankValue).sorted()
            if chosen.count >= 3, Set(ranks).count == ranks.count, ranks.last! - ranks.first! == ranks.count - 1 {
                runSets.append(Set(indices))
            }
        }
        // Only a run that is not part of a longer run counts.
        for set in runSets where !runSets.contains(where: { $0.count > set.count && set.isSubset(of: $0) }) {
            total += set.count
        }
        let suits = hand.compactMap { card -> Suit? in
            if case .standard(_, let suit) = card { return suit }
            return nil
        }
        if Set(suits).count == 1 {
            if case .standard(_, let starterSuit) = starter, starterSuit == suits[0] {
                total += 5
            } else if !crib {
                total += 4
            }
        }
        if case .standard(_, let starterSuit) = starter {
            total += hand.contains { $0 == .standard(rank: 11, suit: starterSuit) } ? 1 : 0
        }
        return total
    }

    // MARK: - Pegging

    private func peg(_ pile: [PlayingCard], _ play: PlayingCard) -> Int? {
        PeggingScoring.score(pile: pile, play: play)?.points
    }

    func testAnOutOfOrderRunCountsEveryCardAsItGrows() {
        // ACC example: 3-5-6-7-4 counts 3 when the 7 lands, then 5 when the 4 does.
        XCTAssertEqual(peg([.c(3), .d(5), .h(6)], .s(7)), 3)
        XCTAssertEqual(peg([.c(3), .d(5), .h(6), .s(7)], .c(4)), 5)
    }

    func testAPairInsideTheSequenceBreaksTheRun() {
        XCTAssertEqual(peg([.c(4), .d(5), .h(5)], .s(6)), 0)
        XCTAssertEqual(peg([.c(4), .d(5), .h(6), .s(6)], .c(7)), 0)
    }

    func testRunsNeedContiguousCards() {
        // 2-3-4 are all played, but a 9 sits between the 2 and the other two.
        XCTAssertEqual(peg([.c(2), .d(9), .h(3)], .s(4)), 0)
    }

    func testPairsNeedConsecutiveCards() {
        XCTAssertEqual(peg([.c(8), .d(8), .h(2)], .s(8)), 0)
        XCTAssertEqual(peg([.c(7), .d(2), .h(7)], .s(7)), 2)
    }

    func testPairRoyalAndDoublePairRoyal() {
        // 5-5-5 makes fifteen as well: 6 + 2.
        XCTAssertEqual(peg([.c(5), .d(5)], .h(5)), 8)
        XCTAssertEqual(peg([.c(9), .d(9)], .h(9)), 6)
        XCTAssertEqual(peg([.c(6), .d(6), .h(6)], .s(6)), 12)
    }

    func testThirtyOneScoresTwoAndTheNextSequenceStartsClean() {
        XCTAssertEqual(peg([.c(10), .d(10), .h(8)], .s(3)), 2)
        // After a go or a 31 the pile restarts, so nothing carries over.
        XCTAssertEqual(peg([], .c(7)), 0)
        XCTAssertEqual(peg([.c(7)], .d(8)), 2)
        XCTAssertNil(peg([.c(10), .d(10), .h(8)], .s(4)))
    }

    func testTheLastLegalCardBeforeGo() {
        // At 29 only an ace or a 2 fits; a 3 is illegal, so that player says go.
        let pile: [PlayingCard] = [.c(10), .d(10), .h(9)]
        XCTAssertNil(peg(pile, .s(3)))
        XCTAssertEqual(peg(pile, .s(2)), 2)
        XCTAssertEqual(peg(pile, .s(1)), 0)
    }

    // MARK: - Copy that states rules or counts

    func testExtraSetSubtitlesNameTheRealItemCount() {
        let words = [8: "Eight", 9: "Nine", 12: "Twelve", 14: "Fourteen"]
        for room in DrillLibrary.rooms where room.isFree {
            for drill in room.drills where drill.isPlus {
                let count = drill.kind.itemCount
                guard let word = words[count] else {
                    XCTFail("Add \(count) to the word table for \(drill.id)")
                    continue
                }
                XCTAssertTrue(drill.subtitle.hasPrefix("\(word) more"), "\(drill.id): \(drill.subtitle)")
            }
        }
    }

    func testMugginsIsTaughtAsOptional() {
        let muggins = MoreContent.advancedRules.first { $0.id == "more-advanced-muggins" }
        XCTAssertTrue(muggins?.explanation.contains("optional rule") == true)
    }

    func testStarterCardTeachesHisHeels() {
        let starter = CardBasicsContent.meetTheCards.first { $0.id == "cards-starter" }
        XCTAssertTrue(starter?.backBody.contains("his heels") == true)
    }
}

/// Small deterministic generator so the cross-checks deal the same hands on
/// every run.
private struct SplitMix: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
