import XCTest
@testable import CribbageTrainer

/// The scoring engine every content invariant is measured against. If these
/// reference counts are wrong, the content audits below them are meaningless.
final class HandScoringTests: XCTestCase {

    func testPerfectTwentyNine() {
        let hand: [PlayingCard] = [.c(5), .d(5), .h(5), .s(11)]
        XCTAssertEqual(HandScoring.score(hand: hand, starter: .s(5)), 29)
    }

    func testTwentyEightWhenTheJackMissesTheStarterSuit() {
        let hand: [PlayingCard] = [.c(5), .d(5), .h(5), .h(11)]
        XCTAssertEqual(HandScoring.score(hand: hand, starter: .s(5)), 28)
    }

    func testHandFlushScoresFourWithoutTheStarter() {
        let hand: [PlayingCard] = [.h(2), .h(5), .h(8), .h(11)]
        XCTAssertEqual(HandScoring.flush(hand: hand, starter: nil, isCrib: false), 4)
        XCTAssertEqual(HandScoring.score(hand: hand), 8)
    }

    func testCribFlushNeedsAllFiveCards() {
        let crib: [PlayingCard] = [.h(2), .h(5), .h(8), .h(11)]
        XCTAssertEqual(HandScoring.score(hand: crib, starter: .c(9), isCrib: true), 4)
        XCTAssertEqual(HandScoring.score(hand: crib, starter: .h(9), isCrib: true), 10)
    }

    func testFiveCardRunAndItsFifteen() {
        let hand: [PlayingCard] = [.c(1), .d(2), .h(3), .s(4)]
        XCTAssertEqual(HandScoring.score(hand: hand, starter: .c(5)), 7)
    }

    func testDoubleDoubleRun() {
        let hand: [PlayingCard] = [.c(3), .d(3), .h(4), .s(4)]
        XCTAssertEqual(HandScoring.runs(hand + [.c(5)]), 12)
        XCTAssertEqual(HandScoring.score(hand: hand, starter: .c(5)), 20)
    }

    func testAcesAreLowAndRunsDoNotWrap() {
        let hand: [PlayingCard] = [.c(12), .d(13), .h(1), .s(2)]
        XCTAssertEqual(HandScoring.runs(hand), 0)
        XCTAssertEqual(HandScoring.score(hand: hand), 0)
    }

    func testNobsOnlyCountsWhenTheSuitMatches() {
        let hand: [PlayingCard] = [.h(11), .c(2), .d(6), .s(8)]
        XCTAssertEqual(HandScoring.score(hand: hand, starter: .h(3)), 3)
        XCTAssertEqual(HandScoring.score(hand: hand, starter: .c(3)), 2)
    }

    func testFourOfAKindIsSixPairs() {
        let hand: [PlayingCard] = [.c(7), .d(7), .h(7), .s(7)]
        XCTAssertEqual(HandScoring.pairs(hand), 12)
        XCTAssertEqual(HandScoring.score(hand: hand, starter: .c(13)), 12)
    }

    func testCourtCardsAreWorthTenTowardFifteen() {
        XCTAssertEqual(HandScoring.fifteens([.c(5), .d(11)]), 2)
        XCTAssertEqual(HandScoring.fifteens([.c(5), .d(12)]), 2)
        XCTAssertEqual(HandScoring.fifteens([.c(5), .d(13)]), 2)
        XCTAssertEqual(HandScoring.fifteens([.c(5), .d(10)]), 2)
        // Rank still separates them, so those four cards never pair.
        XCTAssertEqual(HandScoring.pairs([.c(10), .d(11), .h(12), .s(13)]), 0)
    }

    func testDoubleRunOfThree() {
        let hand: [PlayingCard] = [.c(4), .d(4), .h(5), .s(6)]
        XCTAssertEqual(HandScoring.runs(hand), 6)
        XCTAssertEqual(HandScoring.score(hand: hand), 12)
    }

    func testAverageWithCutIgnoresDeadCards() {
        let hand: [PlayingCard] = [.c(5), .d(5), .c(10), .d(12)]
        let average = HandScoring.averageWithCut(hand: hand, dead: [.h(6), .s(7)])
        XCTAssertGreaterThan(average, Double(HandScoring.score(hand: hand)))
        XCTAssertLessThan(average, 29)
    }
}
