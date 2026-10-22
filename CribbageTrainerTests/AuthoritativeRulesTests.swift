import XCTest
@testable import CribbageTrainer

final class AuthoritativeRulesTests: XCTestCase {
    private func card(_ code: String) -> PlayingCard {
        let suits: [Character: Suit] = ["C": .clubs, "D": .diamonds, "H": .hearts, "S": .spades]
        let rank = ["A": 1, "J": 11, "Q": 12, "K": 13][String(code.dropFirst())] ?? Int(code.dropFirst())!
        return .standard(rank: rank, suit: suits[code.first!]!)
    }

    private func reference() throws -> [String: Any] {
        let url = Bundle(for: Self.self).url(forResource: "rules-reference", withExtension: "json")
            ?? URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Resources/rules-reference.json")
        return try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
    }

    func testAuthoritativeHandCounts() throws {
        for row in try XCTUnwrap(reference()["hands"] as? [[String: Any]]) {
            let hand = (row["hand"] as! [String]).map(card)
            let starter = (row["starter"] as? String).map(card)
            let crib = row["isCrib"] as! Bool
            let all = hand + (starter.map { [$0] } ?? [])
            let components = [HandScoring.fifteens(all), HandScoring.pairs(all), HandScoring.runs(all),
                              HandScoring.flush(hand: hand, starter: starter, isCrib: crib), HandScoring.nobs(hand: hand, starter: starter)]
            let expected = row["components"] as! [Int]
            XCTAssertEqual(components, expected, row["id"] as! String)
            XCTAssertEqual(HandScoring.score(hand: hand, starter: starter, isCrib: crib), expected.reduce(0, +))
        }
        for count in [0, 1, 2, 3, 5] {
            XCTAssertEqual(HandScoring.flush(hand: (1...max(1, count)).prefix(count).map { .h($0) }, starter: .h(9), isCrib: false), 0)
        }
    }

    func testPeggingAndLegalGo() throws {
        for row in try XCTUnwrap(reference()["pegging"] as? [[String: Any]]) {
            let cards = (row["ranks"] as! [Int]).enumerated().map { PlayingCard.standard(rank: $0.element, suit: Suit.allCases[$0.offset % 4]) }
            XCTAssertEqual(PeggingRules.points(cards), row["points"] as! Int, "\(row)")
            XCTAssertEqual(PeggingScoring.score(pile: Array(cards.dropLast()), play: cards.last!)?.points, row["points"] as? Int)
        }
        for (total, ranks, allowed) in [(27, [4, 8], [4]), (30, [1, 2], [1]), (31, [1, 2], []), (22, [10, 9], [9])] {
            XCTAssertEqual(PeggingRules.legal(ranks.map { .c($0) }, total: total).map(\.rankValue), allowed)
        }
        for (total, points) in [(15, 1), (30, 1), (31, 0)] { XCTAssertEqual(PeggingRules.lastCard(total: total), points) }
        for rank in 1...13 { XCTAssertEqual(PeggingRules.heels(.c(rank)), rank == 11 ? 2 : 0) }
    }

    func testMugginsExceptions() {
        for kind in [PeggingRules.ScoreKind.play, .hand, .crib, .heels, .penalty, .muggins, .backward] {
            XCTAssertEqual(PeggingRules.muggins(earned: 8, pegged: 6, enabled: false, kind: kind), 0)
            let eligible = kind == .play || kind == .hand || kind == .crib
            XCTAssertEqual(PeggingRules.muggins(earned: 8, pegged: 6, enabled: true, kind: kind), eligible ? 2 : 0)
            XCTAssertEqual(PeggingRules.muggins(earned: 6, pegged: 8, enabled: true, kind: kind), 0)
        }
    }

    func testCribExpectationAgainstEveryPhysicalCompletion() {
        // An independent physical-card enumeration includes suits and jacks.
        for codes in [["HJ", "H5", "C2", "D4", "S8", "CK"], ["H2", "H6", "H9", "HQ", "C5", "D5"]] {
            let deal = codes.map(card)
            let discard = Array(deal.prefix(2))
            let live = PlayingCard.standardDeck.filter { !deal.contains($0) }
            var sum = 0, count = 0
            for i in live.indices {
                for j in live.indices where j > i {
                    for k in live.indices where k != i && k != j {
                        sum += HandScoring.score(hand: discard + [live[i], live[j]], starter: live[k], isCrib: true)
                        count += 1
                    }
                }
            }
            XCTAssertEqual(count, 45_540)
            XCTAssertEqual(HandScoring.averageCrib(discard: discard, dead: deal), Double(sum) / Double(count), accuracy: 1e-10)
        }
    }

    func testTeachingUsesDealerCribAndAccMuggins() throws {
        let dealer = try XCTUnwrap(KeepDiscardContent.judgmentCards.first { $0.id == "decision-dealer-crib" })
        XCTAssertEqual(dealer.choice?.options[dealer.choice!.answerIndex], "Build hand plus crib")
        XCTAssertTrue(dealer.backBody.contains("pone does not score your crib"))
        let muggins = try XCTUnwrap(MoreContent.advancedRules.first { $0.id == "more-advanced-muggins" })
        XCTAssertTrue(muggins.explanation.contains("starter jack"))
        let flush = ProContent.advancedDiscard[1]
        let keep = flush.deal.filter { !flush.recommendedDiscard.contains($0) }
        XCTAssertEqual(HandScoring.score(hand: keep), 6)
        XCTAssertTrue(flush.reasoning.contains("count 6"))
    }

    func testEquivalentDiscardsReceiveFullCredit() throws {
        for (id, codes) in [("master-discard-4", ["C8", "DK"]), ("master-discard-6", ["C10", "DQ"])] {
            let scenario = try XCTUnwrap(ProContent.advancedDiscard.first { $0.id == id })
            XCTAssertNotEqual(Set(codes.map(card)), Set(scenario.recommendedDiscard))
            XCTAssertEqual(HandScoring.discardMatches(codes.map(card), scenario: scenario), 2)
            XCTAssertEqual(HandScoring.discardMatches(scenario.recommendedDiscard, scenario: scenario), 2)
            XCTAssertEqual(HandScoring.discardMatches([.c(1), .c(2)], scenario: scenario), 0)
        }
    }

    func testAuthoredKeepArithmeticAndConditionalPatterns() throws {
        let scenarios = DrillLibrary.rooms.flatMap(\.drills).flatMap { drill -> [DiscardScenario] in
            if case .discard(let scenarios) = drill.kind { return scenarios }; return []
        }
        for row in try reference()["keeps"] as! [[String: Any]] {
            let scenario = try XCTUnwrap(scenarios.first { $0.id == row["id"] as? String })
            let keep = scenario.deal.filter { !scenario.recommendedDiscard.contains($0) }
            XCTAssertEqual(HandScoring.score(hand: keep), row["score"] as! Int, scenario.id)
        }
        let sixSeven = try XCTUnwrap(scenarios.first { $0.id == "discard-scenario-2" })
        XCTAssertEqual(sixSeven.recommendedDiscard.reduce(0) { $0 + $1.cribbageValue }, 13)
        XCTAssertEqual(HandScoring.fifteens(sixSeven.recommendedDiscard), 0)
        XCTAssertTrue(sixSeven.reasoning.contains("total 13"))
        XCTAssertEqual(HandCategory.nobs.displayName, "Nobs potential")
        XCTAssertEqual(HandCategory.flushes.displayName, "Flush potential")
        XCTAssertTrue(HandCategory.patternPrompt.contains("No starter"))
        XCTAssertTrue(HandCategory.nobs.isPresent(in: [.h(11), .c(2), .d(6), .s(8), .c(13)]))
        XCTAssertEqual(HandScoring.nobs(hand: [.h(11), .c(2), .d(6), .s(8)], starter: .c(3)), 0)
    }
}
