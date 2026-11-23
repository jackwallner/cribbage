import XCTest
@testable import CribbageTrainer

/// "Why not X?" notes. A note that states something false about the cards on
/// screen teaches the wrong thing, so each claim is checked against the cards
/// directly, without going through `HandScoring`.
final class MissNoteTests: XCTestCase {

    // MARK: - Independent checks

    private func hasFifteen(_ cards: [PlayingCard]) -> Bool { fifteenCount(cards) > 0 }

    private func fifteenCount(_ cards: [PlayingCard]) -> Int {
        let values = cards.map(\.cribbageValue)
        return (1..<(1 << values.count)).filter { mask in
            values.indices.filter { mask & (1 << $0) != 0 }.map { values[$0] }.reduce(0, +) == 15
        }.count
    }

    private func hasPair(_ cards: [PlayingCard]) -> Bool {
        Set(cards.map(\.rankValue)).count < cards.count
    }

    private func hasRun(_ cards: [PlayingCard]) -> Bool {
        let ranks = Set(cards.map(\.rankValue))
        return ranks.contains { ranks.contains($0 + 1) && ranks.contains($0 + 2) }
    }

    private func hasFourOfASuit(_ cards: [PlayingCard]) -> Bool {
        Dictionary(grouping: cards.compactMap(\.suit), by: { $0 }).values.contains { $0.count >= 4 }
    }

    private func patternIsAbsent(_ category: HandCategory, _ cards: [PlayingCard]) -> Bool {
        switch category {
        case .fifteens: return !hasFifteen(cards)
        case .pairs: return !hasPair(cards)
        case .runs: return !hasRun(cards)
        case .flushes: return !hasFourOfASuit(cards)
        case .nobs: return !cards.contains { $0.rankValue == 11 }
        }
    }

    // MARK: - Hand reading

    func testPatternNotesOnlyNameAbsentPatterns() {
        for hand in HandGenerator.batch(count: 300) {
            XCTAssertNil(hand.answer.missNote(in: hand.tiles))
            for choice in hand.choices where choice != hand.answer {
                let note = hand.answer == choice ? nil : choice.missNote(in: hand.tiles)
                XCTAssertNotNil(note, "\(choice) on \(hand.tiles.map(\.shortLabel))")
                XCTAssertTrue(patternIsAbsent(choice, hand.tiles), "\(choice) is present in \(hand.tiles.map(\.shortLabel))")
                XCTAssertFalse(note?.contains("\u{2014}") ?? false)
            }
        }
    }

    func testAuthoredHandMatchNotesAreTrue() {
        for room in DrillLibrary.rooms {
            for drill in room.drills {
                guard case .handMatch(let questions) = drill.kind else { continue }
                for question in questions {
                    for choice in question.choices where choice != question.answer {
                        if choice.missNote(in: question.tiles) != nil {
                            XCTAssertTrue(patternIsAbsent(choice, question.tiles), question.id)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Count the hand

    func testCountNotesCoverEveryMissAndClaimOnlyWhatIsTrue() {
        var generator = SystemRandomNumberGenerator()
        for _ in 0..<400 {
            let question = HandCountGenerator.question(using: &generator)
            let all = question.hand + [question.starter]
            XCTAssertNil(HandCountGenerator.missNote(picked: question.score, hand: question.hand, starter: question.starter))
            for picked in question.choices where picked != question.score {
                guard let note = HandCountGenerator.missNote(picked: picked, hand: question.hand, starter: question.starter) else {
                    XCTFail("no note for \(picked)")
                    continue
                }
                XCTAssertTrue(note.hasPrefix("\(picked) is \(abs(question.score - picked)) point"), note)
                XCTAssertEqual(note.contains("short"), picked < question.score, note)
                if note.contains("exactly his nobs") {
                    let jack = question.hand.first { $0.rankValue == 11 && $0.suit == question.starter.suit }
                    XCTAssertNotNil(jack, note)
                }
                if note.contains("different fifteens") {
                    XCTAssertTrue(note.contains("make \(fifteenCount(all)) different fifteens"), note)
                }
                XCTAssertFalse(note.contains("\u{2014}"))
            }
        }
    }

    // MARK: - Plumbing

    func testEndlessItemsCarryNotesForEveryWrongPick() {
        for skill in [PracticeSkill.handReading, .pegging, .countHand] {
            for item in EndlessPractice.items(for: skill, count: 30) {
                XCTAssertEqual(item.choiceNotes.count, item.choices.count)
                XCTAssertNil(item.note(forPick: item.answerIndex))
                for index in item.choices.indices where index != item.answerIndex {
                    XCTAssertNotNil(item.note(forPick: index), "\(skill) \(item.choices[index])")
                }
            }
        }
    }

    func testLegalPlayNotesMatchThePick() {
        for item in EndlessPractice.items(for: .pegging, count: 60) {
            for index in item.choices.indices where index != item.answerIndex {
                let note = item.note(forPick: index)?.reason ?? ""
                switch item.choices[index] {
                case "Say go": XCTAssertTrue(note.hasPrefix("Go is only"), note)
                case "Reset the count": XCTAssertTrue(note.contains("31 or a go"), note)
                case "Ask for a new card": XCTAssertTrue(note.contains("no drawing"), note)
                default: XCTAssertTrue(note.contains("never pass 31"), note)
                }
            }
        }
    }

    func testPreparedKeepsNotesWithTheirChoices() {
        let item = QuickItem(
            id: "note-order", prompt: "p", tiles: [],
            choices: ["a", "b", "c", "d"], answerIndex: 0, explanation: "e",
            sourceLabel: "s", roomID: "r",
            choiceNotes: [nil, "note-b", "note-c", "note-d"]
        )
        let prepared = SessionBuilder.prepared(item)
        for (index, label) in prepared.choices.enumerated() {
            XCTAssertEqual(prepared.choiceNotes[index], label == "a" ? nil : "note-\(label)")
        }
        XCTAssertEqual(prepared.choices[prepared.answerIndex], "a")
    }

    func testMinuteHandReadingCoachesEveryMiss() {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.date(from: DateComponents(year: 2026, month: 8, day: 9, hour: 12))!
        for offset in 0..<20 {
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            let challenge = CribbageMinuteContent.challenge(for: day, calendar: calendar)
            for question in challenge.questions where question.category == .handReading {
                let item = question.item
                XCTAssertNil(item.note(forPick: item.answerIndex))
                for index in item.choices.indices where index != item.answerIndex {
                    XCTAssertNotNil(item.note(forPick: index), item.id)
                }
            }
        }
    }
}
