import XCTest
@testable import CribbageTrainer

final class PeggingScoringTests: XCTestCase {
    private func points(_ pile: [PlayingCard], _ play: PlayingCard) -> Int? {
        PeggingScoring.score(pile: pile, play: play)?.points
    }

    func testFifteenAndThirtyOneScoreTwo() {
        XCTAssertEqual(points([.c(5)], .d(10)), 2)
        XCTAssertEqual(points([.c(10), .d(10), .h(10)], .s(1)), 2)
    }

    func testFifteenWithRunStacks() {
        // 4 + 5 + 6 = 15 and the three cards are a run: 2 + 3
        XCTAssertEqual(points([.c(4), .d(5)], .h(6)), 5)
    }

    func testPairsScaleWithMatchingTail() {
        XCTAssertEqual(points([.c(8)], .d(8)), 2)
        XCTAssertEqual(points([.c(7), .d(7)], .h(7)), 6)
        XCTAssertEqual(points([.c(6), .d(6), .h(6)], .s(6)), 12)
    }

    func testPairMustBeAdjacent() {
        XCTAssertEqual(points([.c(4), .d(9), .h(4)], .s(9)), 0)
    }

    func testRunsScoreInAnyOrderAndTakeTheLongestTail() {
        XCTAssertEqual(points([.c(9), .d(4), .h(5)], .s(3)), 3)
        XCTAssertEqual(points([.c(8), .d(6), .h(7)], .s(5)), 4)
        // 5 5 6 7: the duplicate breaks the four-card run, the last three still run
        XCTAssertEqual(points([.c(5), .d(5), .h(6)], .s(7)), 3)
    }

    func testRunsDoNotWrapAndAcesAreLow() {
        XCTAssertEqual(points([.c(12), .d(13)], .h(1)), 0)
        XCTAssertEqual(points([.c(11), .d(12)], .h(13)), 3)
        XCTAssertEqual(points([.c(2), .d(3)], .h(1)), 3)
    }

    func testPlayPastThirtyOneIsIllegal() {
        XCTAssertNil(PeggingScoring.score(pile: [.c(13), .d(12), .h(5)], play: .s(11)))
    }

    func testSummaryNamesEveryComponent() {
        let result = PeggingScoring.score(pile: [.c(4), .d(5)], play: .h(6))
        XCTAssertEqual(result?.summary, "2 for making fifteen and 3 for a run of 3")
    }
}

final class PracticeGeneratorTests: XCTestCase {
    /// Slow independent recount of a pegging play, written differently from
    /// the shipped rules: it replays the pile card by card.
    private func oracle(pile: [PlayingCard], play: PlayingCard) -> Int {
        let seq = pile + [play]
        let total = seq.reduce(0) { $0 + min($1.rankValue, 10) }
        var points = (total == 15 ? 2 : 0) + (total == 31 ? 2 : 0)
        var tail = 0
        for card in seq.reversed() {
            if card.rankValue == play.rankValue { tail += 1 } else { break }
        }
        points += [0, 0, 2, 6, 12][min(tail, 4)]
        var best = 0
        if seq.count >= 3 {
            for n in 3...seq.count {
                let ranks = seq.suffix(n).map(\.rankValue)
                let low = ranks.min()!
                if Set(ranks) == Set(low..<(low + n)) { best = n }
            }
        }
        return points + best
    }

    func testGeneratedPeggingQuestionsMatchTheOracle() {
        var generator = StableSeededGenerator(seed: "pegging-oracle")
        var sawScoring = false
        var sawZero = false
        for _ in 0..<400 {
            let q = PeggingQuestionGenerator.question(using: &generator)
            let cards = q.pile + [q.play]
            XCTAssertEqual(Set(cards).count, cards.count, "no card dealt twice")
            XCTAssertLessThanOrEqual(q.runningTotal + q.play.cribbageValue, 31)
            XCTAssertEqual(q.result.points, oracle(pile: q.pile, play: q.play))
            XCTAssertEqual(q.choices.count, 4)
            XCTAssertEqual(Set(q.choices).count, 4)
            XCTAssertEqual(q.choices.filter { $0 == q.result.points }.count, 1)
            XCTAssertFalse(q.choices.contains(1), "one point only comes from go, never a play")
            XCTAssertFalse(q.explanation.contains("\u{2014}"))
            if q.result.points > 0 { sawScoring = true } else { sawZero = true }
        }
        XCTAssertTrue(sawScoring && sawZero)
    }

    func testPeggingQuestionsAreReproducibleFromASeed() {
        var a = StableSeededGenerator(seed: "same")
        var b = StableSeededGenerator(seed: "same")
        let first = PeggingQuestionGenerator.question(using: &a)
        let second = PeggingQuestionGenerator.question(using: &b)
        XCTAssertEqual(first.pile, second.pile)
        XCTAssertEqual(first.play, second.play)
        XCTAssertEqual(first.choices, second.choices)
    }

    func testCountHandQuestionsAreCorrectAndFair() {
        var generator = StableSeededGenerator(seed: "count-hand")
        for _ in 0..<400 {
            let q = HandCountGenerator.question(using: &generator)
            let cards = q.hand + [q.starter]
            XCTAssertEqual(q.hand.count, 4)
            XCTAssertEqual(Set(cards).count, 5)
            XCTAssertGreaterThan(q.score, 0)
            XCTAssertEqual(q.score, HandScoring.score(hand: q.hand, starter: q.starter))
            XCTAssertEqual(q.choices.count, 4)
            XCTAssertEqual(Set(q.choices).count, 4)
            XCTAssertTrue(q.choices.contains(q.score))
            for choice in q.choices {
                XCTAssertFalse(HandCountGenerator.impossibleScores.contains(choice))
                XCTAssertTrue((1...HandCountGenerator.maxScore).contains(choice))
            }
            // The explanation's parts must add to the answer it teaches.
            let total = q.explanation
                .components(separatedBy: " That is ").last?
                .components(separatedBy: " points").first.flatMap(Int.init)
            XCTAssertEqual(total, q.score, q.explanation)
        }
    }

    func testTopTotalsStillGetFourReachableChoices() {
        var generator = StableSeededGenerator(seed: "top-totals")
        for score in [24, 28, 29] {
            let choices = HandCountGenerator.options(for: score, using: &generator)
            XCTAssertEqual(choices.count, 4, "score \(score)")
            XCTAssertEqual(Set(choices).count, 4, "score \(score)")
            XCTAssertTrue(choices.contains(score))
            XCTAssertTrue(Set(choices).isDisjoint(with: HandCountGenerator.impossibleScores))
        }
    }

    func testZeroPointExplanationDoesNotClaimTheCardMatchesNothing() {
        // 5 9 then 5: the 5 matches an earlier card but not the one just before.
        let pile: [PlayingCard] = [.c(5), .d(9)]
        let play = PlayingCard.h(5)
        let result = PeggingScoring.score(pile: pile, play: play)!
        XCTAssertEqual(result.points, 0)
        let text = PeggingQuestionGenerator.explain(pile: pile, play: play, result: result)
        XCTAssertFalse(text.contains("matches nothing"))
        XCTAssertTrue(text.contains("just before"))
    }

    func testImpossibleScoresReallyNeverOccur() {
        var generator = StableSeededGenerator(seed: "impossible")
        for _ in 0..<5000 {
            let dealt = Array(PlayingCard.standardDeck.shuffled(using: &generator).prefix(5))
            let score = HandScoring.score(hand: Array(dealt.prefix(4)), starter: dealt[4])
            XCTAssertFalse(HandCountGenerator.impossibleScores.contains(score), "\(dealt.map(\.shortLabel)) scored \(score)")
        }
    }

    func testNewEndlessSkillsProduceGradeableItems() {
        for skill in [PracticeSkill.countHand, .pegScore] {
            for item in EndlessPractice.items(for: skill, count: 30) {
                XCTAssertEqual(PracticeSkill.skill(forItemID: item.id), skill)
                XCTAssertEqual(item.choices.count, 4)
                XCTAssertEqual(Set(item.choices).count, 4)
                XCTAssertTrue(item.choices.indices.contains(item.answerIndex))
                XCTAssertEqual(item.tiles.count, Set(item.tiles).count)
                XCTAssertFalse(item.prompt.contains("\u{2014}"))
            }
        }
        let hand = EndlessPractice.items(for: .countHand, count: 1)[0]
        XCTAssertEqual(hand.tiles.count, 5)
        let peg = EndlessPractice.items(for: .pegScore, count: 1)[0]
        XCTAssertTrue(peg.prompt.contains("How many points"))
        XCTAssertNotNil(peg.topic)
    }

    func testPeggingLegalPlayAnswerPositionVaries() {
        let positions = Set(EndlessPractice.items(for: .pegging, count: 60).map(\.answerIndex))
        XCTAssertGreaterThan(positions.count, 1)
    }

    func testTopicTitlesCoverEveryGeneratedTopic() {
        var generator = StableSeededGenerator(seed: "topics")
        for _ in 0..<300 {
            let q = PeggingQuestionGenerator.question(using: &generator)
            let id = PracticeTopic.id(.pegScore, q.topic)
            XCTAssertNotEqual(PracticeTopic.title(id), id, "missing title for \(id)")
        }
        for category in HandCategory.allCases {
            let id = PracticeTopic.id(.handReading, category.rawValue)
            XCTAssertNotEqual(PracticeTopic.title(id), id)
        }
        for name in ["play", "go"] {
            let id = PracticeTopic.id(.pegging, name)
            XCTAssertNotEqual(PracticeTopic.title(id), id)
        }
    }
}

@MainActor
final class TopicStatsTests: XCTestCase {
    private var defaults: UserDefaults!
    private var store: PracticeRecordStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "TopicStatsTests")!
        defaults.removePersistentDomain(forName: "TopicStatsTests")
        store = PracticeRecordStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "TopicStatsTests")
        super.tearDown()
    }

    func testWeakTopicsNeedEnoughAnswersAndLowAccuracy() {
        let runs = PracticeTopic.id(.handReading, "runs")
        let pairs = PracticeTopic.id(.handReading, "pairs")
        for _ in 0..<3 { store.recordTopic(runs, correct: false) }
        XCTAssertTrue(store.weakTopics().isEmpty, "three answers is not enough to coach on")
        store.recordTopic(runs, correct: true)
        for _ in 0..<5 { store.recordTopic(pairs, correct: true) }
        XCTAssertEqual(store.weakTopics().map(\.id), [runs])
    }

    func testWeakTopicsFilterBySkillAndSortWorstFirst() {
        let runs = PracticeTopic.id(.handReading, "runs")
        let peg = PracticeTopic.id(.pegScore, "pair")
        for _ in 0..<4 { store.recordTopic(runs, correct: false) }
        for index in 0..<4 { store.recordTopic(peg, correct: index == 0) }
        XCTAssertEqual(store.weakTopics().map(\.id), [runs, peg])
        XCTAssertEqual(store.weakTopics(skill: .pegScore).map(\.id), [peg])
    }

    func testTopicsPersistAndResetWithoutTouchingRoomTotals() {
        let runs = PracticeTopic.id(.handReading, "runs")
        store.recordTopic(runs, correct: true)
        XCTAssertEqual(store.totalAttempts, 0)
        XCTAssertEqual(PracticeRecordStore(defaults: defaults).topics[runs]?.attempts, 1)
        store.resetAll()
        XCTAssertTrue(PracticeRecordStore(defaults: defaults).topics.isEmpty)
    }
}
