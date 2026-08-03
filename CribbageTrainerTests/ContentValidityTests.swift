import XCTest
@testable import CribbageTrainer

final class ContentValidityTests: XCTestCase {
    private var allDrills: [Drill] { DrillLibrary.rooms.flatMap(\.drills) }

    private var allHandMatch: [HandMatchQuestion] {
        allDrills.flatMap { drill in
            if case .handMatch(let questions) = drill.kind { return questions }
            return []
        }
    }

    private var allQuiz: [QuizQuestion] {
        allDrills.flatMap { drill in
            if case .quiz(let questions) = drill.kind { return questions }
            return []
        }
    }

    private var allDiscard: [DiscardScenario] {
        allDrills.flatMap { drill in
            if case .discard(let scenarios) = drill.kind { return scenarios }
            return []
        }
    }

    private var allFlashcards: [Flashcard] {
        allDrills.flatMap { drill in
            if case .flashcards(let cards) = drill.kind { return cards }
            return []
        }
    }

    func testHandMatchQuestionsShowFiveCards() {
        for question in allHandMatch {
            XCTAssertEqual(question.tiles.count, 5, "\(question.id) must show a five-card hand")
            XCTAssertEqual(Set(question.tiles).count, question.tiles.count, "\(question.id) repeats a physical card")
        }
    }

    func testHandMatchAnswerIsAmongChoices() {
        for question in allHandMatch {
            XCTAssertTrue(question.choices.contains(question.answer), "\(question.id) answer missing from choices")
            XCTAssertEqual(Set(question.choices).count, question.choices.count, "\(question.id) has duplicate choices")
            XCTAssertGreaterThanOrEqual(question.choices.count, 3, "\(question.id) needs at least 3 choices")
        }
    }

    /// The contract that makes a hand-match question fair: of the categories
    /// offered, the answer is present in the cards on screen and every other
    /// offered category genuinely is not. Without this, a player who correctly
    /// spots a second real shape gets marked wrong.
    func testHandMatchQuestionsHaveExactlyOneCorrectAnswer() {
        for question in allHandMatch {
            let present = question.choices.filter { $0.isPresent(in: question.tiles) }
            let shown = question.tiles.map(\.shortLabel).joined(separator: " ")
            XCTAssertEqual(
                present, [question.answer],
                "\(question.id) [\(shown)] offers \(question.choices.map(\.rawValue)) "
                + "but the hand actually contains \(present.map(\.rawValue))"
            )
        }
    }

    /// Every discard scenario has to say whose crib the two cards land in,
    /// because that single fact can flip the right answer.
    func testDiscardScenariosStateTheRole() {
        for scenario in allDiscard {
            let text = scenario.situation.lowercased()
            let isDealer = text.contains("dealer")
            let isPone = text.contains("pone")
            XCTAssertNotEqual(isDealer, isPone,
                              "\(scenario.id) must state exactly one role: \(scenario.situation)")
        }
    }

    /// The coach's answer must be the best available discard, measured the way
    /// the game measures it: the expected count of the four cards kept, plus
    /// what the two thrown cards make in the crib for the dealer, or minus it
    /// for the pone.
    func testRecommendedDiscardsAreOptimal() {
        for scenario in allDiscard {
            let isDealer = scenario.situation.lowercased().contains("dealer")
            let ranked = HandScoring.rankedDiscards(deal: scenario.deal, isDealer: isDealer)
            guard let best = ranked.first else {
                XCTFail("\(scenario.id) produced no discard options")
                continue
            }
            let recommended = HandScoring.discardValue(
                deal: scenario.deal, discard: scenario.recommendedDiscard, isDealer: isDealer
            )
            XCTAssertEqual(
                recommended, best.value, accuracy: 0.05,
                "\(scenario.id) recommends \(scenario.recommendedDiscard.map(\.shortLabel)) "
                + "worth \(String(format: "%.2f", recommended)), but "
                + "\(best.discard.map(\.shortLabel)) is worth \(String(format: "%.2f", best.value))"
            )
        }
    }

    /// Pone throws into the opponent's crib, so the app must never coach a
    /// discard that hands the dealer free points.
    func testPoneDiscardsNeverGiftTheCrib() {
        for scenario in allDiscard where !scenario.situation.lowercased().contains("dealer") {
            let thrown = scenario.recommendedDiscard
            guard thrown.count == 2 else { continue }
            XCTAssertNotEqual(thrown[0].rankValue, thrown[1].rankValue,
                              "\(scenario.id) gives the dealer's crib a pair")
            XCTAssertNotEqual(thrown[0].cribbageValue + thrown[1].cribbageValue, 15,
                              "\(scenario.id) gives the dealer's crib a fifteen")
            XCTAssertFalse(thrown.contains { $0.rankValue == 5 },
                           "\(scenario.id) gives the dealer's crib a 5")
        }
    }

    func testDiscardDealsHaveSixCardsAndRecommendTwo() {
        for scenario in allDiscard {
            XCTAssertEqual(scenario.deal.count, 6, "\(scenario.id) deal must have six cards")
            XCTAssertEqual(scenario.recommendedDiscard.count, 2, "\(scenario.id) must recommend exactly two cards")
            XCTAssertEqual(Set(scenario.deal).count, scenario.deal.count, "\(scenario.id) repeats a physical card")
            XCTAssertTrue(scenario.recommendedDiscard.allSatisfy(scenario.deal.contains), "\(scenario.id) recommends a card outside the deal")
        }
    }

    func testDiscardDealsUseAStandardDeck() {
        for scenario in allDiscard {
            for card in scenario.deal {
                if case .standard(let rank, _) = card {
                    XCTAssertTrue((1...13).contains(rank), "\(scenario.id) has an invalid rank")
                } else {
                    XCTFail("\(scenario.id) contains a joker; cribbage uses a standard deck")
                }
            }
        }
    }

    func testQuizAnswerIndicesAreValid() {
        for question in allQuiz {
            XCTAssertTrue(question.choices.indices.contains(question.answerIndex), "\(question.id) has out-of-range answer")
            XCTAssertGreaterThanOrEqual(question.choices.count, 2, "\(question.id) needs at least 2 choices")
            XCTAssertEqual(Set(question.choices).count, question.choices.count, "\(question.id) has duplicate choices")
        }
    }

    func testCardChoicesAreTwoOptionsWithValidAnswer() {
        for card in allFlashcards {
            guard let choice = card.choice else { continue }
            XCTAssertEqual(choice.options.count, 2, "\(card.id) choice must have exactly 2 options")
            XCTAssertTrue(choice.options.indices.contains(choice.answerIndex), "\(card.id) has out-of-range choice answer")
            XCTAssertEqual(Set(choice.options).count, 2, "\(card.id) has duplicate choice options")
        }
    }

    func testAllContentIDsAreUnique() {
        var ids: [String] = []
        for room in DrillLibrary.rooms {
            ids.append(room.id)
            for drill in room.drills {
                ids.append(drill.id)
                switch drill.kind {
                case .flashcards(let cards): ids += cards.map(\.id)
                case .quiz(let questions): ids += questions.map(\.id)
                case .handMatch(let questions): ids += questions.map(\.id)
                case .discard(let scenarios): ids += scenarios.map(\.id)
                }
            }
        }
        XCTAssertEqual(Set(ids).count, ids.count, "Duplicate content IDs found")
    }

    func testEveryRoomHasDrillsAndFreeBeginnerModelIsIntact() {
        XCTAssertFalse(DrillLibrary.rooms.isEmpty)
        for room in DrillLibrary.rooms {
            XCTAssertFalse(room.drills.isEmpty, "\(room.id) has no drills")
            for drill in room.drills {
                XCTAssertGreaterThan(drill.kind.itemCount, 0, "\(drill.id) is empty")
            }
        }
        XCTAssertTrue(DrillLibrary.rooms.first?.isFree == true)
        for room in DrillLibrary.rooms {
            if room.id == "pro-tables" {
                XCTAssertFalse(room.isFree)
            } else {
                XCTAssertTrue(room.isFree)
                XCTAssertEqual(room.drills.filter(\.isPlus).count, 1, "\(room.id) should have one Cribbage+ extra set")
            }
        }
    }

    func testLockedDrillsResolveByMembership() {
        for room in DrillLibrary.rooms {
            for drill in room.drills {
                XCTAssertFalse(room.isLocked(drill, isMember: true))
                XCTAssertEqual(room.isLocked(drill, isMember: false), !room.isFree || drill.isPlus)
            }
        }
    }

    func testNoEmDashesOrStaleCardCopyInPlayerFacingContent() {
        var copy: [String] = []
        for room in DrillLibrary.rooms {
            copy += [room.name, room.tagline]
            for drill in room.drills {
                copy += [drill.title, drill.subtitle]
                switch drill.kind {
                case .flashcards(let cards):
                    copy += cards.flatMap { [$0.frontTitle, $0.frontSubtitle ?? "", $0.backTitle, $0.backBody] + ($0.choice?.options ?? []) }
                case .quiz(let questions):
                    copy += questions.flatMap { [$0.prompt, $0.explanation] + $0.choices }
                case .handMatch(let questions):
                    copy += questions.map(\.explanation)
                case .discard(let scenarios):
                    copy += scenarios.flatMap { [$0.situation, $0.reasoning, $0.tip] }
                }
            }
        }
        copy += HowToPlayContent.pages.flatMap { [$0.title, $0.body, $0.tip ?? ""] }
        for text in copy {
            XCTAssertFalse(text.contains("\u{2014}"), "Em dash found in copy: \(text)")
            XCTAssertFalse(text.localizedCaseInsensitiveContains("tile"), "Stale tile copy found: \(text)")
        }
    }

    func testHowToPlayPagesHaveUniqueIDsAndValidCards() {
        let pages = HowToPlayContent.pages
        XCTAssertFalse(pages.isEmpty)
        XCTAssertEqual(Set(pages.map(\.id)).count, pages.count)
        for page in pages {
            XCTAssertEqual(Set(page.tiles).count, page.tiles.count, "\(page.id) repeats a physical card")
        }
    }

    func testQuickSessionPullsTenItemsAndPrioritizesMisses() {
        let mix = SessionBuilder.quickSession(seen: [], missed: [], includePro: false)
        XCTAssertEqual(mix.count, 10)
        XCTAssertEqual(Set(mix.map(\.id)).count, 10)
        let missedID = mix[0].id
        let biased = SessionBuilder.quickSession(seen: [missedID], missed: [missedID], includePro: false)
        XCTAssertTrue(biased.contains { $0.id == missedID })
    }

    private var lockedItemIDs: Set<String> {
        var ids: Set<String> = []
        for room in DrillLibrary.rooms {
            for drill in room.drills where room.isLocked(drill, isMember: false) {
                switch drill.kind {
                case .flashcards(let cards): ids.formUnion(cards.map(\.id))
                case .quiz(let questions): ids.formUnion(questions.map(\.id))
                case .handMatch(let questions): ids.formUnion(questions.map(\.id))
                case .discard(let scenarios): ids.formUnion(scenarios.map(\.id))
                }
            }
        }
        return ids
    }

    func testQuickSessionExcludesLockedContentForFreeUsers() {
        let mix = SessionBuilder.quickSession(count: 200, seen: [], missed: [], includePro: false)
        XCTAssertFalse(lockedItemIDs.isEmpty)
        for item in mix {
            XCTAssertFalse(lockedItemIDs.contains(item.id), "\(item.id) leaked into a free session")
        }
    }

    func testQuickSessionIncludesLockedContentForMembers() {
        let mix = SessionBuilder.quickSession(count: 500, seen: [], missed: [], includePro: true)
        XCTAssertFalse(Set(mix.map(\.id)).isDisjoint(with: lockedItemIDs))
    }

    func testQuickSessionItemsAreChoiceOnlyWithValidAnswers() {
        let mix = SessionBuilder.quickSession(count: 50, seen: [], missed: [], includePro: true)
        for item in mix {
            XCTAssertGreaterThanOrEqual(item.choices.count, 2)
            XCTAssertTrue(item.choices.indices.contains(item.answerIndex))
        }
    }

    func testQuickSessionExcludesPlainFlashcardsAndDiscard() {
        let plainFlashcardIDs = Set(allFlashcards.filter { $0.choice == nil }.map(\.id))
        let discardIDs = Set(allDiscard.map(\.id))
        let mix = SessionBuilder.quickSession(count: 200, seen: [], missed: [], includePro: true)
        for item in mix {
            XCTAssertFalse(plainFlashcardIDs.contains(item.id))
            XCTAssertFalse(discardIDs.contains(item.id))
        }
    }
}
