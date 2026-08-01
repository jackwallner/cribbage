import Foundation

/// Cribbity+ extra practice sets. The free beginner drills remain intact;
/// membership adds more original reps in the same mechanics.
enum PlusContent {
    static let cardExtras: [QuizQuestion] = [
        QuizQuestion(
            id: "plus-card-1",
            prompt: "How many cards are in the crib before the starter is cut?",
            choices: ["2", "4", "6"],
            answerIndex: 1,
            explanation: "Each player contributes two cards, so the dealer's crib has four cards before the starter joins it."
        ),
        QuizQuestion(
            id: "plus-card-2",
            prompt: "What does a 5 combine with most readily?",
            tiles: [.c(5), .d(10)],
            choices: ["A ten-value card for 15", "Only another 5", "Nothing until pegging"],
            answerIndex: 0,
            explanation: "A 5 plus any 10, jack, queen, or king is a fifteen worth 2 points."
        ),
        QuizQuestion(
            id: "plus-card-3",
            prompt: "Does a run need matching suits?",
            tiles: [.c(4), .h(5), .s(6)],
            choices: ["Yes", "No", "Only in the crib"],
            answerIndex: 1,
            explanation: "A run is about consecutive ranks. The suits may be mixed."
        ),
        QuizQuestion(
            id: "plus-card-4",
            prompt: "What makes a crib flush?",
            choices: ["Any three matching suits", "All four crib cards and the starter match", "Only the four crib cards match"],
            answerIndex: 1,
            explanation: "The crib's flush rule is stricter than a hand flush: all five cards, including the starter, must match suit."
        ),
        QuizQuestion(
            id: "plus-card-5",
            prompt: "Which card can be his nobs?",
            tiles: [.h(11), .h(4)],
            choices: ["A jack matching the starter suit", "Any queen", "Any card matching the starter rank"],
            answerIndex: 0,
            explanation: "His nobs is one point for a jack whose suit matches the starter."
        ),
        QuizQuestion(
            id: "plus-card-6",
            prompt: "What is a triple run?",
            tiles: [.c(4), .d(4), .h(4), .s(5), .c(6)],
            choices: ["Three fifteens", "Three ways to make the same run", "Three cards of one suit"],
            answerIndex: 1,
            explanation: "Three copies of a rank inside a run create three distinct ways to form that sequence."
        ),
        QuizQuestion(
            id: "plus-card-7",
            prompt: "Who counts first after pegging?",
            choices: ["The pone", "The dealer", "Whoever cut"],
            answerIndex: 0,
            explanation: "The pone counts first, then the dealer counts their hand and the crib. The order can decide a close game."
        ),
        QuizQuestion(
            id: "plus-card-8",
            prompt: "What is an ace's value in a fifteen?",
            tiles: [.c(1)],
            choices: ["1", "10", "11"],
            answerIndex: 0,
            explanation: "An ace counts as 1 and is low in runs."
        ),
    ]

    static let extraHandReading: [HandMatchQuestion] = [
        HandMatchQuestion(
            id: "plus-hand-1",
            tiles: [.c(3), .d(4), .h(5), .s(6), .c(9)],
            choices: [.runs, .fifteens, .flushes],
            answer: .runs,
            explanation: "3-4-5-6 is a run of four. The 9 is separate, but the run is the first structure to identify."
        ),
        HandMatchQuestion(
            id: "plus-hand-2",
            tiles: [.c(5), .d(5), .h(5), .s(10), .c(12)],
            choices: [.pairs, .fifteens, .nobs],
            answer: .pairs,
            explanation: "Three 5s contain three pairs. They also create fifteens with the 10, so a full count must include both patterns."
        ),
        HandMatchQuestion(
            id: "plus-hand-3",
            tiles: [.s(2), .s(6), .s(8), .s(13), .d(4)],
            choices: [.flushes, .runs, .crib],
            answer: .flushes,
            explanation: "Four spades create a four-card hand flush."
        ),
        HandMatchQuestion(
            id: "plus-hand-4",
            tiles: [.c(2), .d(2), .h(3), .s(4), .c(5)],
            choices: [.runs, .pairs, .counting],
            answer: .runs,
            explanation: "The 2-3-4-5 sequence is a run of four, with the duplicate 2 creating a double run of three inside it."
        ),
        HandMatchQuestion(
            id: "plus-hand-5",
            tiles: [.h(11), .c(5), .d(10), .s(8), .c(2)],
            choices: [.nobs, .fifteens, .flushes],
            answer: .fifteens,
            explanation: "The 5 makes a fifteen with both the 10 and the jack. The jack's suit would matter only if the starter is a heart."
        ),
        HandMatchQuestion(
            id: "plus-hand-6",
            tiles: [.c(7), .d(7), .h(7), .s(7), .c(13)],
            choices: [.pairs, .counting, .runs],
            answer: .pairs,
            explanation: "Four of a rank contain six separate pairs. The king is not consecutive with the 7s."
        ),
    ]

    static let extraDiscards: [DiscardScenario] = [
        DiscardScenario(
            id: "plus-discard-1",
            situation: "You are pone. Keep the broadest scoring hand.",
            deal: [.c(3), .d(4), .h(5), .s(6), .c(10), .d(13)],
            recommendedDiscard: [.s(6), .d(13)],
            reasoning: "Keep 3-4-5-10 for several fifteens and a run path. The 6 and king are less connected to the rest of the hand in this example.",
            tip: "Count combinations, not just the prettiest sequence."
        ),
        DiscardScenario(
            id: "plus-discard-2",
            situation: "You are the dealer. Protect the hand and feed a useful crib.",
            deal: [.c(5), .d(5), .h(6), .s(7), .c(10), .d(11)],
            recommendedDiscard: [.c(10), .d(11)],
            reasoning: "Keep the 5 pair and the 6-7 connection. The dealer can place two ten-value cards in the crib while preserving guaranteed points in the hand.",
            tip: "A dealer can accept a useful crib when the hand stays strong."
        ),
        DiscardScenario(
            id: "plus-discard-3",
            situation: "Pone has four diamonds. Choose two cards to protect the crib.",
            deal: [.d(2), .d(6), .d(9), .d(12), .c(4), .s(8)],
            recommendedDiscard: [.c(4), .s(8)],
            reasoning: "The four diamonds preserve a hand flush and give the cut a chance to make five. The off-suit cards are not a pair and do not form a fifteen together.",
            tip: "As pone, do not give away a pair or a clean fifteen when you have another path."
        ),
        DiscardScenario(
            id: "plus-discard-4",
            situation: "The board is close. Choose the easy hand to count.",
            deal: [.c(2), .d(3), .h(4), .s(9), .c(10), .d(12)],
            recommendedDiscard: [.s(9), .d(12)],
            reasoning: "The 2-3-4 block has a clear run path and the 10 helps a 5 if the cut arrives. The 9 and queen are the least integrated cards.",
            tip: "Reliable points are often worth more than a fragile ceiling."
        ),
    ]

    static let extraJudgment: [Flashcard] = [
        Flashcard(
            id: "plus-judgment-1",
            frontTitle: "Pegging total is 26",
            frontTiles: [.c(5), .d(10)],
            frontSubtitle: "Which card keeps you under 31?",
            backTitle: "Play the 5",
            backBody: "Playing the 5 makes 31 for 2 points. The ten-value card would go over, so the legal choice is clear.",
            choice: CardChoice("Play the 5", "Play the 10", answerIndex: 0)
        ),
        Flashcard(
            id: "plus-judgment-2",
            frontTitle: "You hold a pair",
            frontTiles: [.c(8), .h(8)],
            frontSubtitle: "Throw one to avoid a bad crib?",
            backTitle: "Keep the guaranteed pair",
            backBody: "A pair scores 2 before the cut. Breaking it is a major trade, not a default defensive move.",
            choice: CardChoice("Keep both", "Break the pair", answerIndex: 0)
        ),
        Flashcard(
            id: "plus-judgment-3",
            frontTitle: "The dealer is one point from 121",
            frontSubtitle: "Should you gift a 5 to the crib?",
            backTitle: "Avoid the risky gift",
            backBody: "The dealer is already at a finish line. If your hand can stay competitive without discarding the 5, protect the crib and make the opponent work for the win.",
            choice: CardChoice("Keep the 5", "Give the 5 away", answerIndex: 0)
        ),
        Flashcard(
            id: "plus-judgment-4",
            frontTitle: "You made 15 while pegging",
            frontSubtitle: "What do you announce?",
            backTitle: "Fifteen for 2",
            backBody: "Say the score out loud and peg 2 points before the next player acts. Verbalizing the total keeps the sequence honest.",
            choice: CardChoice("Announce 2", "Wait until the hand count", answerIndex: 0)
        ),
        Flashcard(
            id: "plus-judgment-5",
            frontTitle: "The starter matches your jack",
            frontTiles: [.h(11), .h(4)],
            frontSubtitle: "Do you add the bonus?",
            backTitle: "Add his nobs",
            backBody: "A jack matching the starter's suit scores one point. Keep a separate nobs check in your count routine.",
            choice: CardChoice("Add 1", "Ignore it", answerIndex: 0)
        ),
    ]
}
