import Foundation

/// The Scoring Room: recognize the building blocks before doing full counts.
enum CategoryContent {
    static let categoryCards: [Flashcard] = [
        Flashcard(
            id: "score-fifteens",
            frontTitle: "Fifteens",
            frontTiles: [.c(5), .d(10), .h(4), .s(1)],
            frontSubtitle: "The combinations add up",
            backTitle: "Count every combination",
            backBody: "A 5 with a ten-value card is one fifteen. An ace and a 4 make another. When a hand has several small cards, check combinations systematically so none are missed."
        ),
        Flashcard(
            id: "score-pairs",
            frontTitle: "Pairs",
            frontTiles: [.c(8), .d(8), .h(3), .s(3)],
            frontSubtitle: "Same rank, different suits",
            backTitle: "Two points per pair",
            backBody: "This example has two separate pairs for 4 points. Three cards of one rank create three pairs, not one three-of-a-kind score."
        ),
        Flashcard(
            id: "score-runs",
            frontTitle: "Runs",
            frontTiles: [.c(3), .d(4), .s(5), .h(6)],
            frontSubtitle: "Consecutive ranks",
            backTitle: "Length is the score",
            backBody: "Three in sequence scores 3, four scores 4, and five scores 5. Duplicate ranks can create multiple runs, so sort the cards before counting."
        ),
        Flashcard(
            id: "score-flush",
            frontTitle: "Flushes",
            frontTiles: [.h(2), .h(5), .h(8), .h(11)],
            frontSubtitle: "Suit is the whole clue",
            backTitle: "Four or five matching suits",
            backBody: "Four cards of the same suit score 4 in a hand. If the starter also matches, the hand flush is 5. The crib has a stricter flush rule: all five cards must match."
        ),
        Flashcard(
            id: "score-nobs",
            frontTitle: "His nobs",
            frontTiles: [.h(11), .c(7), .d(9), .s(4)],
            frontSubtitle: "The jack is watching the cut",
            backTitle: "One point for a match",
            backBody: "A jack matching the starter card's suit scores one point. In a real count, keep the jack in view until you know the cut."
        ),
        Flashcard(
            id: "score-double-run",
            frontTitle: "A double run",
            frontTiles: [.c(4), .d(4), .h(5), .s(6)],
            frontSubtitle: "A pair can multiply a run",
            backTitle: "The pair makes two runs",
            backBody: "The 4-5-6 sequence appears twice because there are two 4s. That is a double run of three for 6 points, before any fifteens."
        ),
        Flashcard(
            id: "score-count-order",
            frontTitle: "Count in an order",
            frontSubtitle: "A habit prevents misses",
            backTitle: "Fifteens, pairs, runs, flush, nobs",
            backBody: "Use the same order every time. Count fifteens first, then pairs, runs, flushes, and his nobs. Add the starter-driven bonuses as you go."
        ),
        Flashcard(
            id: "score-pegging",
            frontTitle: "Pegging scores too",
            frontSubtitle: "The hand count is not the whole game",
            backTitle: "Track the running total",
            backBody: "During pegging, points come from making 15, pairs, runs, 31, go, and the last card. The same cards can score differently in this phase because order matters."
        ),
    ]

    static let handMatch: [HandMatchQuestion] = [
        HandMatchQuestion(
            id: "score-match-1",
            tiles: [.c(5), .d(10), .h(2), .s(3), .c(9)],
            choices: [.fifteens, .pairs, .flushes],
            answer: .fifteens,
            explanation: "The 5 with the 10 is a clear fifteen, and the 2, 3, and 10-value card make another 15. There is no pair or four-card flush."
        ),
        HandMatchQuestion(
            id: "score-match-2",
            tiles: [.c(7), .d(7), .h(7), .s(2), .c(10)],
            choices: [.pairs, .runs, .nobs],
            answer: .pairs,
            explanation: "Three 7s create three separate pairs for 6 points. They are not a run, and no jack is present."
        ),
        HandMatchQuestion(
            id: "score-match-3",
            tiles: [.c(4), .d(5), .s(6), .h(7), .c(10)],
            choices: [.runs, .flushes, .crib],
            answer: .runs,
            explanation: "The four cards from 4 through 7 form a run of four. The suits are mixed, so this is not a flush."
        ),
        HandMatchQuestion(
            id: "score-match-4",
            tiles: [.h(2), .h(6), .h(9), .h(13), .c(4)],
            choices: [.flushes, .fifteens, .pairs],
            answer: .flushes,
            explanation: "Four cards in the hand are hearts, so the hand has a four-card flush. The cut could extend it to five."
        ),
        HandMatchQuestion(
            id: "score-match-5",
            tiles: [.h(11), .c(2), .d(6), .s(8), .c(13)],
            choices: [.nobs, .runs, .flushes],
            answer: .nobs,
            explanation: "The hand contains a heart jack. If the starter is a heart, that jack becomes his nobs for one point."
        ),
        HandMatchQuestion(
            id: "score-match-6",
            tiles: [.c(3), .d(3), .h(4), .s(5), .c(6)],
            choices: [.runs, .pairs, .counting],
            answer: .runs,
            explanation: "The 3-4-5-6 shape is a four-card run, duplicated through the two 3s for a double run of four."
        ),
        HandMatchQuestion(
            id: "score-match-7",
            tiles: [.c(2), .d(3), .h(4), .s(6), .c(9)],
            choices: [.counting, .fifteens, .pegging],
            answer: .counting,
            explanation: "This is a counting exercise: sort the values, find every fifteen, and do not confuse a hand count with a pegging sequence."
        ),
        HandMatchQuestion(
            id: "score-match-8",
            tiles: [.c(4), .d(5), .h(6), .s(10), .c(10)],
            choices: [.pairs, .runs, .crib],
            answer: .pairs,
            explanation: "The two 10s make a pair. The 4-5-6 run is also present, but the question's strongest first read is to spot the duplicate rank."
        ),
    ]
}
