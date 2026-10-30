import Foundation

/// The Scoring Room: recognize the building blocks before doing full counts.
enum CategoryContent {
    static let categoryCards: [Flashcard] = [
        Flashcard(
            id: "score-fifteens",
            frontTitle: String(localized: "Fifteens"),
            frontTiles: [.c(5), .d(10), .h(4), .s(1)],
            frontSubtitle: String(localized: "The combinations add up"),
            backTitle: String(localized: "Count every combination"),
            backBody: String(localized: "A 5 with a ten-value card is one fifteen. The ace, the 4, and the same ten-value card make another. When a hand has several small cards, check combinations systematically so none are missed.")
        ),
        Flashcard(
            id: "score-pairs",
            frontTitle: String(localized: "Pairs"),
            frontTiles: [.c(8), .d(8), .h(3), .s(3)],
            frontSubtitle: String(localized: "Same rank, different suits"),
            backTitle: String(localized: "Two points per pair"),
            backBody: String(localized: "This example has two separate pairs for 4 points. Three cards of one rank create three pairs, not one three-of-a-kind score.")
        ),
        Flashcard(
            id: "score-runs",
            frontTitle: String(localized: "Runs"),
            frontTiles: [.c(3), .d(4), .s(5), .h(6)],
            frontSubtitle: String(localized: "Consecutive ranks"),
            backTitle: String(localized: "Length is the score"),
            backBody: String(localized: "Three in sequence scores 3, four scores 4, and five scores 5. Duplicate ranks can create multiple runs, so sort the cards before counting.")
        ),
        Flashcard(
            id: "score-flush",
            frontTitle: String(localized: "Flushes"),
            frontTiles: [.h(2), .h(5), .h(8), .h(11)],
            frontSubtitle: String(localized: "Suit is the whole clue"),
            backTitle: String(localized: "Four or five matching suits"),
            backBody: String(localized: "Four cards of the same suit score 4 in a hand. If the starter also matches, the hand flush is 5. The crib has a stricter flush rule: all five cards must match.")
        ),
        Flashcard(
            id: "score-nobs",
            frontTitle: String(localized: "His nobs"),
            frontTiles: [.h(11), .c(7), .d(9), .s(4)],
            frontSubtitle: String(localized: "The jack is watching the cut"),
            backTitle: String(localized: "One point for a match"),
            backBody: String(localized: "A jack matching the starter card's suit scores one point. In a real count, keep the jack in view until you know the cut.")
        ),
        Flashcard(
            id: "score-double-run",
            frontTitle: String(localized: "A double run"),
            frontTiles: [.c(4), .d(4), .h(5), .s(6)],
            frontSubtitle: String(localized: "A pair can multiply a run"),
            backTitle: String(localized: "The pair makes two runs"),
            backBody: String(localized: "The 4-5-6 sequence appears twice because there are two 4s. That is 6 points for the two runs, plus 2 for the pair. Count any fifteens separately.")
        ),
        Flashcard(
            id: "score-count-order",
            frontTitle: String(localized: "Count in an order"),
            frontSubtitle: String(localized: "A habit prevents misses"),
            backTitle: String(localized: "Fifteens, pairs, runs, flush, nobs"),
            backBody: String(localized: "Use the same order every time. Count fifteens first, then pairs, runs, flushes, and his nobs. Add the starter-driven bonuses as you go.")
        ),
        Flashcard(
            id: "score-pegging",
            frontTitle: String(localized: "Pegging scores too"),
            frontSubtitle: String(localized: "The hand count is not the whole game"),
            backTitle: String(localized: "Track the running total"),
            backBody: String(localized: "During pegging, points come from making 15, pairs, runs, 31, go, and the last card. The same cards can score differently in this phase because order matters.")
        ),
    ]

    static let handMatch: [HandMatchQuestion] = [
        HandMatchQuestion(
            id: "score-match-1",
            tiles: [.c(5), .d(10), .h(2), .s(3), .c(9)],
            choices: [.fifteens, .pairs, .flushes],
            answer: .fifteens,
            explanation: String(localized: "The 5 with the 10 is a clear fifteen, and the 2, 3, and 10-value card make another 15. There is no pair or four-card flush.")
        ),
        HandMatchQuestion(
            id: "score-match-2",
            tiles: [.c(7), .d(7), .h(7), .s(2), .c(10)],
            choices: [.pairs, .runs, .nobs],
            answer: .pairs,
            explanation: String(localized: "Three 7s create three separate pairs for 6 points. They are not a run, and no jack is present.")
        ),
        HandMatchQuestion(
            id: "score-match-3",
            tiles: [.c(4), .d(5), .s(6), .h(7), .c(10)],
            choices: [.runs, .flushes, .nobs],
            answer: .runs,
            explanation: String(localized: "The four cards from 4 through 7 form a run of four. The suits are mixed, so this is not a flush, and there is no jack to watch.")
        ),
        HandMatchQuestion(
            id: "score-match-4",
            tiles: [.d(6), .d(8), .d(12), .d(13), .h(4)],
            choices: [.flushes, .fifteens, .pairs],
            answer: .flushes,
            explanation: String(localized: "Four of the five cards are diamonds, so a hand holding those four has a four-card flush worth 4, or 5 if the starter is a diamond too. Nothing here adds to fifteen and no rank repeats.")
        ),
        HandMatchQuestion(
            id: "score-match-5",
            tiles: [.h(11), .c(2), .d(6), .s(8), .c(13)],
            choices: [.nobs, .runs, .flushes],
            answer: .nobs,
            explanation: String(localized: "The hand contains a heart jack. If the starter is a heart, that jack becomes his nobs for one point.")
        ),
        HandMatchQuestion(
            id: "score-match-6",
            tiles: [.c(3), .d(3), .h(4), .s(5), .c(6)],
            choices: [.runs, .flushes, .nobs],
            answer: .runs,
            explanation: String(localized: "The 3-4-5-6 shape is a four-card run, and the second 3 lets it form twice. That double run of four is 8 points before the pair is counted.")
        ),
        HandMatchQuestion(
            id: "score-match-7",
            tiles: [.s(3), .s(5), .d(6), .c(9), .h(12)],
            choices: [.fifteens, .runs, .pairs],
            answer: .fifteens,
            explanation: String(localized: "Two combinations reach fifteen: the 6 with the 9, and the 5 with the queen. No rank repeats and nothing runs three deep, so 4 points of fifteens is the whole count.")
        ),
        HandMatchQuestion(
            id: "score-match-8",
            tiles: [.c(1), .d(10), .s(10), .c(12), .h(13)],
            choices: [.pairs, .runs, .fifteens],
            answer: .pairs,
            explanation: String(localized: "Only the two 10s share a rank, so there is exactly one pair. Queen and king are also worth 10 toward a fifteen, but rank is what pairs, and 10-queen-king skips the jack so there is no run.")
        ),
    ]
}
