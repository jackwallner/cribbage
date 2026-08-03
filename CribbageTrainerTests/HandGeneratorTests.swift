import XCTest
@testable import CribbageTrainer

final class HandGeneratorTests: XCTestCase {
    func testReadsAFlush() {
        let cards: [PlayingCard] = [.h(2), .h(5), .h(8), .h(11), .h(13)]
        XCTAssertTrue(HandCategory.flushes.isPresent(in: cards))
        XCTAssertFalse(HandCategory.pairs.isPresent(in: cards))
    }

    func testReadsARun() {
        let cards: [PlayingCard] = [.c(3), .d(4), .h(5), .s(6), .c(7)]
        XCTAssertTrue(HandCategory.runs.isPresent(in: cards))
        XCTAssertFalse(HandCategory.flushes.isPresent(in: cards))
        XCTAssertFalse(HandCategory.pairs.isPresent(in: cards))
    }

    func testReadsPairs() {
        let cards: [PlayingCard] = [.c(8), .d(8), .h(2), .s(6), .c(13)]
        XCTAssertTrue(HandCategory.pairs.isPresent(in: cards))
        XCTAssertFalse(HandCategory.runs.isPresent(in: cards))
    }

    func testReadsFifteens() {
        let cards: [PlayingCard] = [.c(5), .d(10), .h(1), .s(2), .c(7)]
        XCTAssertTrue(HandCategory.fifteens.isPresent(in: cards))
        XCTAssertFalse(HandCategory.nobs.isPresent(in: cards))
    }

    func testNobsIsPresentOnlyWithAJack() {
        XCTAssertTrue(HandCategory.nobs.isPresent(in: [.h(11), .c(2), .d(6), .s(8), .c(13)]))
        XCTAssertFalse(HandCategory.nobs.isPresent(in: [.h(12), .c(2), .d(6), .s(8), .c(13)]))
    }

    /// Generated questions keep the same contract as the authored ones: of the
    /// three categories offered, exactly one is really in the cards.
    func testGeneratedHandsAreLegalAndUnambiguous() {
        for target in HandGenerator.generatableCategories {
            for _ in 0..<40 {
                guard let hand = HandGenerator.hand(for: target) else {
                    XCTFail("Could not deal a hand for \(target.displayName)")
                    continue
                }
                let shown = hand.tiles.map(\.shortLabel).joined(separator: " ")
                XCTAssertEqual(hand.tiles.count, 5, shown)
                XCTAssertEqual(Set(hand.tiles).count, hand.tiles.count, shown)
                XCTAssertEqual(hand.answer, target)
                XCTAssertTrue(hand.choices.contains(target), shown)
                XCTAssertEqual(hand.choices.count, 3, shown)
                XCTAssertEqual(Set(hand.choices).count, hand.choices.count, shown)
                let present = hand.choices.filter { $0.isPresent(in: hand.tiles) }
                XCTAssertEqual(present, [target],
                               "[\(shown)] offers \(hand.choices.map(\.rawValue)) but contains \(present.map(\.rawValue))")
                XCTAssertFalse(hand.explanation.isEmpty)
                XCTAssertFalse(hand.explanation.contains("\u{2014}"))
            }
        }
    }

    /// Cards are dealt from one 52-card deck, so no rank can appear five times
    /// and no physical card can repeat.
    func testGeneratedHandsUseOneStandardDeck() {
        for target in HandGenerator.generatableCategories {
            for _ in 0..<40 {
                guard let hand = HandGenerator.hand(for: target) else { continue }
                var counts: [Int: Int] = [:]
                for tile in hand.tiles {
                    guard case .standard(let rank, _) = tile else {
                        XCTFail("Generated hand contains a joker")
                        continue
                    }
                    XCTAssertTrue((1...13).contains(rank))
                    counts[rank, default: 0] += 1
                }
                XCTAssertLessThanOrEqual(counts.values.max() ?? 0, 4,
                                         "A rank appeared more than four times")
            }
        }
    }

    func testBatchCoversEverySkill() {
        let hands = HandGenerator.batch(count: 60)
        XCTAssertGreaterThan(hands.count, 40)
        XCTAssertEqual(Set(hands.map(\.answer)).count, HandGenerator.generatableCategories.count)
    }

    func testEndlessItemsAreWellFormed() {
        for skill in PracticeSkill.allCases {
            let items = EndlessPractice.items(for: skill, count: 12)
            XCTAssertEqual(items.count, 12)
            for item in items {
                XCTAssertTrue(item.id.hasPrefix(skill.itemPrefix))
                XCTAssertEqual(PracticeSkill.skill(forItemID: item.id), skill)
                XCTAssertGreaterThanOrEqual(item.choices.count, 3)
                XCTAssertTrue(item.choices.indices.contains(item.answerIndex))
                XCTAssertEqual(Set(item.choices).count, item.choices.count)
                XCTAssertFalse(item.explanation.isEmpty)
                XCTAssertNotNil(DrillLibrary.room(id: item.roomID))
            }
        }
    }

    func testPeggingItemsDescribeLegalTotals() {
        let items = EndlessPractice.items(for: .pegging, count: 40)
        for item in items {
            guard case .standard(let rank, _) = item.tiles[0] else {
                XCTFail("Generated pegging item must show a standard card")
                continue
            }
            XCTAssertTrue((1...13).contains(rank))
            XCTAssertTrue(item.prompt.contains("running total"))
        }
    }

    func testMixedItemsDrawFromEverySkill() {
        let items = EndlessPractice.mixedItems(count: 40)
        XCTAssertEqual(items.count, 40)
        XCTAssertEqual(Set(items.compactMap { PracticeSkill.skill(forItemID: $0.id) }).count,
                       PracticeSkill.allCases.count)
    }
}
