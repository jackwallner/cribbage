import XCTest
@testable import CribbageTrainer

/// The glossary is read mid-game, so a wrong number there is acted on at the
/// board. Every point value it quotes is checked against `HandScoring`.
final class ReferenceContentTests: XCTestCase {

    private func definition(_ id: String) -> String {
        ReferenceContent.glossary.first { $0.id == id }?.definition ?? ""
    }

    func testIDsAreUniqueAndEveryGroupHasEntries() {
        let ids = ReferenceContent.glossary.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
        for group in GlossaryGroup.allCases {
            XCTAssertFalse(ReferenceContent.terms(in: group).isEmpty, group.title)
        }
    }

    func testNoEmDashes() {
        for term in ReferenceContent.glossary {
            XCTAssertFalse(term.term.contains("—") || term.definition.contains("—"), term.id)
        }
    }

    func testSearchFindsNicknames() {
        XCTAssertTrue(ReferenceContent.terms(in: .deal, matching: "nibs").contains { $0.id == "g-heels" })
        XCTAssertTrue(ReferenceContent.terms(in: .deal, matching: "Kitty").contains { $0.id == "g-crib" })
        XCTAssertTrue(ReferenceContent.terms(in: .counting, matching: "nob").contains { $0.id == "g-nobs" })
        XCTAssertTrue(GlossaryGroup.allCases.allSatisfy { ReferenceContent.terms(in: $0, matching: "zzzz").isEmpty })
    }

    func testQuotedRunValuesMatchTheScorer() {
        // Double run 4-5-5-6: 8 from runs and the pair.
        let doubleRun: [PlayingCard] = [.c(4), .d(5), .h(5), .s(6)]
        XCTAssertEqual(HandScoring.runs(doubleRun) + 2, 8)
        XCTAssertTrue(definition("g-double-run").contains("8 before fifteens"))
        // Triple run 3-3-3-4-5: 9 from runs plus 6 for the pair royal.
        let tripleRun: [PlayingCard] = [.c(3), .d(3), .h(3), .s(4), .c(5)]
        XCTAssertEqual(HandScoring.runs(tripleRun) + 6, 15)
        XCTAssertTrue(definition("g-triple-run").contains("15 before fifteens"))
        // Double double run 3-3-4-4-5: 12 from runs plus two pairs.
        let doubleDouble: [PlayingCard] = [.c(3), .d(3), .h(4), .s(4), .c(5)]
        XCTAssertEqual(HandScoring.runs(doubleDouble) + 4, 16)
        XCTAssertTrue(definition("g-double-double-run").contains("16 before fifteens"))
    }

    func testQuotedHandValuesMatchTheScorer() {
        // The 29 hand as described: three fives and the jack of the fourth suit, the fourth five cut.
        XCTAssertEqual(HandScoring.score(hand: [.c(5), .d(5), .h(5), .s(11)], starter: .s(5)), 29)
        // A four-card hand flush counts 4, five with the starter; a crib needs all five.
        let hearts: [PlayingCard] = [.h(2), .h(7), .h(9), .h(13)]
        XCTAssertEqual(HandScoring.flush(hand: hearts, starter: nil, isCrib: false), 4)
        XCTAssertEqual(HandScoring.flush(hand: hearts, starter: .h(4), isCrib: false), 5)
        XCTAssertEqual(HandScoring.flush(hand: hearts, starter: .c(4), isCrib: true), 0)
        XCTAssertEqual(HandScoring.flush(hand: hearts, starter: .h(4), isCrib: true), 5)
        // A pair royal is 6 and four of a kind 12.
        XCTAssertEqual(HandScoring.score(hand: [.c(8), .d(8), .h(8), .s(2)], starter: .c(13)), 6)
        XCTAssertEqual(HandScoring.score(hand: [.c(9), .d(9), .h(9), .s(9)], starter: .c(1)), 12)
    }

    func testNoHandScoresNineteen() {
        // "19 hand" slang depends on 19 being unreachable: no random deal
        // ever scores it, while zero hands are common.
        let deck: [PlayingCard] = (1...13).flatMap { rank in [PlayingCard.c(rank), .d(rank), .h(rank), .s(rank)] }
        var seen = Set<Int>()
        var generator = SystemRandomNumberGenerator()
        for _ in 0..<20000 {
            let five = Array(deck.shuffled(using: &generator).prefix(5))
            seen.insert(HandScoring.score(hand: Array(five.prefix(4)), starter: five[4]))
        }
        XCTAssertFalse(seen.contains(19))
        XCTAssertTrue(seen.contains(0))
    }
}
