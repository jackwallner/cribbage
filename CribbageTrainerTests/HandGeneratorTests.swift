import XCTest
@testable import CribbageTrainer

final class HandGeneratorTests: XCTestCase {
    func testReadsAFlush() {
        let cards: [PlayingCard] = [.h(2), .h(5), .h(8), .h(11), .h(13)]
        XCTAssertEqual(HandGenerator.category(for: cards), .flushes)
    }

    func testReadsARun() {
        let cards: [PlayingCard] = [.c(3), .d(4), .h(5), .s(6), .c(7)]
        XCTAssertEqual(HandGenerator.category(for: cards), .runs)
        XCTAssertFalse(HandGenerator.fits(cards, .flushes))
    }

    func testReadsPairs() {
        let cards: [PlayingCard] = [.c(8), .d(8), .h(2), .s(6), .c(13)]
        XCTAssertEqual(HandGenerator.category(for: cards), .pairs)
    }

    func testReadsFifteens() {
        let cards: [PlayingCard] = [.c(5), .d(10), .h(1), .s(2), .c(7)]
        XCTAssertEqual(HandGenerator.category(for: cards), .fifteens)
    }

    func testGeneratedHandsAreLegalAndUnambiguous() {
        for target in HandGenerator.generatableCategories {
            for _ in 0..<20 {
                guard let hand = HandGenerator.hand(for: target) else {
                    XCTFail("Could not deal a hand for \(target.displayName)")
                    continue
                }
                XCTAssertEqual(hand.tiles.count, 5)
                XCTAssertEqual(Set(hand.tiles).count, hand.tiles.count)
                XCTAssertEqual(HandGenerator.category(for: hand.tiles), target)
                XCTAssertTrue(hand.choices.contains(target))
                XCTAssertGreaterThanOrEqual(hand.choices.count, 3)
                XCTAssertEqual(Set(hand.choices).count, hand.choices.count)
                for choice in hand.choices where choice != target {
                    XCTAssertFalse(HandGenerator.fits(hand.tiles, choice), "\(choice.displayName) is also a correct answer")
                }
                XCTAssertFalse(hand.explanation.isEmpty)
                XCTAssertFalse(hand.explanation.contains("\u{2014}"))
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
