import Foundation

/// Cribbage+ extra practice sets. The free beginner drills remain intact;
/// membership adds more original reps in the same mechanics.
enum PlusContent {
    static let cardExtras: [QuizQuestion] = [
        QuizQuestion(
            id: "plus-card-1",
            prompt: String(localized: "How many cards are in the crib before the starter is cut?"),
            choices: [String(localized: "2"), String(localized: "4"), String(localized: "6")],
            answerIndex: 1,
            explanation: String(localized: "Each player contributes two cards, so the dealer's crib has four cards before the starter joins it.")
        ),
        QuizQuestion(
            id: "plus-card-2",
            prompt: String(localized: "What does a 5 combine with most readily?"),
            tiles: [.c(5), .d(10)],
            choices: [String(localized: "A ten-value card for 15"), String(localized: "Only another 5"), String(localized: "Nothing until pegging")],
            answerIndex: 0,
            explanation: String(localized: "A 5 plus any 10, jack, queen, or king is a fifteen worth 2 points.")
        ),
        QuizQuestion(
            id: "plus-card-3",
            prompt: String(localized: "Does a run need matching suits?"),
            tiles: [.c(4), .h(5), .s(6)],
            choices: [String(localized: "Yes"), String(localized: "No"), String(localized: "Only in the crib")],
            answerIndex: 1,
            explanation: String(localized: "A run is about consecutive ranks. The suits may be mixed.")
        ),
        QuizQuestion(
            id: "plus-card-4",
            prompt: String(localized: "What makes a crib flush?"),
            choices: [String(localized: "Any three matching suits"), String(localized: "All four crib cards and the starter match"), String(localized: "Only the four crib cards match")],
            answerIndex: 1,
            explanation: String(localized: "The crib's flush rule is stricter than a hand flush: all five cards, including the starter, must match suit.")
        ),
        QuizQuestion(
            id: "plus-card-5",
            prompt: String(localized: "Which card can be his nobs?"),
            tiles: [.h(11), .h(4)],
            choices: [String(localized: "A jack matching the starter suit"), String(localized: "Any queen"), String(localized: "Any card matching the starter rank")],
            answerIndex: 0,
            explanation: String(localized: "His nobs is one point for a jack whose suit matches the starter.")
        ),
        QuizQuestion(
            id: "plus-card-6",
            prompt: String(localized: "What is a triple run?"),
            tiles: [.c(4), .d(4), .h(4), .s(5), .c(6)],
            choices: [String(localized: "Three fifteens"), String(localized: "Three ways to make the same run"), String(localized: "Three cards of one suit")],
            answerIndex: 1,
            explanation: String(localized: "Three copies of a rank inside a run create three distinct ways to form that sequence.")
        ),
        QuizQuestion(
            id: "plus-card-7",
            prompt: String(localized: "Who counts first after pegging?"),
            choices: [String(localized: "The pone"), String(localized: "The dealer"), String(localized: "Whoever cut")],
            answerIndex: 0,
            explanation: String(localized: "The pone counts first, then the dealer counts their hand and the crib. The order can decide a close game.")
        ),
        QuizQuestion(
            id: "plus-card-8",
            prompt: String(localized: "What is an ace's value in a fifteen?"),
            tiles: [.c(1)],
            choices: [String(localized: "1"), String(localized: "10"), String(localized: "11")],
            answerIndex: 0,
            explanation: String(localized: "An ace counts as 1 and is low in runs.")
        ),
    ]

    static let extraHandReading: [HandMatchQuestion] = [
        HandMatchQuestion(
            id: "plus-hand-1",
            tiles: [.c(8), .s(9), .d(10), .d(11), .h(13)],
            choices: [.runs, .fifteens, .flushes],
            answer: .runs,
            explanation: String(localized: "8-9-10-jack is a run of four. Rank order is what builds a run, so the jack sits directly above the 10 even though both are worth 10 toward a fifteen.")
        ),
        HandMatchQuestion(
            id: "plus-hand-2",
            tiles: [.c(6), .d(7), .h(7), .s(7), .d(12)],
            choices: [.pairs, .fifteens, .nobs],
            answer: .pairs,
            explanation: String(localized: "Three 7s contain three separate pairs for 6 points, not a single three-of-a-kind score. Nothing here reaches fifteen and there is no jack.")
        ),
        HandMatchQuestion(
            id: "plus-hand-3",
            tiles: [.s(2), .s(6), .s(8), .s(13), .d(4)],
            choices: [.flushes, .runs, .nobs],
            answer: .flushes,
            explanation: String(localized: "Four spades create a four-card hand flush worth 4, or 5 if the starter is a spade too.")
        ),
        HandMatchQuestion(
            id: "plus-hand-4",
            tiles: [.c(2), .d(2), .h(3), .s(4), .c(5)],
            choices: [.runs, .flushes, .nobs],
            answer: .runs,
            explanation: String(localized: "2-3-4-5 is a run of four, and the second 2 lets it form twice. That double run of four is 8 points before the pair of 2s adds 2 more.")
        ),
        HandMatchQuestion(
            id: "plus-hand-5",
            tiles: [.c(5), .d(10), .s(12), .h(8), .c(2)],
            choices: [.fifteens, .runs, .pairs],
            answer: .fifteens,
            explanation: String(localized: "The 5 makes fifteen with the 10 and again with the queen, and 2-5-8 makes a third. Three fifteens is 6 points, with no repeated rank and no sequence.")
        ),
        HandMatchQuestion(
            id: "plus-hand-6",
            tiles: [.c(7), .d(7), .h(7), .s(7), .c(13)],
            choices: [.pairs, .runs, .flushes],
            answer: .pairs,
            explanation: String(localized: "Four of a rank contain six separate pairs for 12 points. The king is not consecutive with the 7s and only two cards share a suit.")
        ),
    ]

    static let extraDiscards: [DiscardScenario] = [
        DiscardScenario(
            id: "plus-discard-1",
            isDealer: false,
            situation: String(localized: "You are pone. Keep the broadest scoring hand."),
            deal: [.c(3), .d(4), .h(5), .s(6), .c(10), .d(13)],
            recommendedDiscard: [.c(10), .d(13)],
            reasoning: String(localized: "Keep 3-4-5-6: a run of four for 4, plus the 4-5-6 fifteen for 2. Swapping the 6 for the 10 looks similar but drops the run to three cards. The two ten-value cards neither pair nor make fifteen together, so they are the safest thing to hand the dealer."),
            tip: String(localized: "Count combinations, not just the prettiest sequence.")
        ),
        DiscardScenario(
            id: "plus-discard-2",
            isDealer: true,
            situation: String(localized: "You are the dealer. A pair sits inside a run."),
            deal: [.c(6), .d(6), .h(7), .s(8), .c(2), .d(13)],
            recommendedDiscard: [.c(2), .d(13)],
            reasoning: String(localized: "Keep 6-6-7-8. The second 6 gives 6-7-8 two ways to form, a double run of three for 6, plus 2 for the pair and 2 for the 7-8 fifteen: 10 points before the cut. The 2 and the king touch none of that."),
            tip: String(localized: "A pair inside a run is worth far more than a pair on its own.")
        ),
        DiscardScenario(
            id: "plus-discard-3",
            isDealer: false,
            situation: String(localized: "You are pone with four diamonds. Choose two cards."),
            deal: [.d(2), .d(6), .d(9), .d(12), .c(4), .s(8)],
            recommendedDiscard: [.c(4), .s(8)],
            reasoning: String(localized: "The four diamonds preserve a hand flush and give the cut a chance to make five. The off-suit cards are not a pair and do not form a fifteen together."),
            tip: String(localized: "As pone, do not give away a pair or a clean fifteen when you have another path.")
        ),
        DiscardScenario(
            id: "plus-discard-4",
            isDealer: false,
            situation: String(localized: "You are pone and the board is close. Choose the easy hand to count."),
            deal: [.c(2), .d(3), .h(4), .s(9), .c(10), .d(12)],
            recommendedDiscard: [.s(9), .d(12)],
            reasoning: String(localized: "The 2-3-4 block has a clear run path and the 10 helps a 5 if the cut arrives. The 9 and queen are the least integrated cards."),
            tip: String(localized: "Reliable points are often worth more than a fragile ceiling.")
        ),
    ]

    static let extraJudgment: [Flashcard] = [
        Flashcard(
            id: "plus-judgment-1",
            frontTitle: String(localized: "Pegging total is 26"),
            frontTiles: [.c(5), .d(10)],
            frontSubtitle: String(localized: "Which card keeps you under 31?"),
            backTitle: String(localized: "Play the 5"),
            backBody: String(localized: "Playing the 5 makes 31 for 2 points. The ten-value card would go over, so the legal choice is clear."),
            choice: CardChoice(String(localized: "Play the 5"), String(localized: "Play the 10"), answerIndex: 0)
        ),
        Flashcard(
            id: "plus-judgment-2",
            frontTitle: String(localized: "You hold a pair"),
            frontTiles: [.c(8), .h(8)],
            frontSubtitle: String(localized: "Throw one to avoid a bad crib?"),
            backTitle: String(localized: "Keep the guaranteed pair"),
            backBody: String(localized: "A pair scores 2 before the cut. Breaking it is a major trade, not a default defensive move."),
            choice: CardChoice(String(localized: "Keep both"), String(localized: "Break the pair"), answerIndex: 0)
        ),
        Flashcard(
            id: "plus-judgment-3",
            frontTitle: String(localized: "The dealer is one point from 121"),
            frontSubtitle: String(localized: "Should you gift a 5 to the crib?"),
            backTitle: String(localized: "Avoid the risky gift"),
            backBody: String(localized: "The dealer is already at a finish line. If your hand can stay competitive without discarding the 5, protect the crib and make the opponent work for the win."),
            choice: CardChoice(String(localized: "Keep the 5"), String(localized: "Give the 5 away"), answerIndex: 0)
        ),
        Flashcard(
            id: "plus-judgment-4",
            frontTitle: String(localized: "You made 15 while pegging"),
            frontSubtitle: String(localized: "What do you announce?"),
            backTitle: String(localized: "Fifteen for 2"),
            backBody: String(localized: "Say the score out loud and peg 2 points before the next player acts. Verbalizing the total keeps the sequence honest."),
            choice: CardChoice(String(localized: "Announce 2"), String(localized: "Wait until the hand count"), answerIndex: 0)
        ),
        Flashcard(
            id: "plus-judgment-5",
            frontTitle: String(localized: "The starter matches your jack"),
            frontTiles: [.h(11), .h(4)],
            frontSubtitle: String(localized: "Do you add the bonus?"),
            backTitle: String(localized: "Add his nobs"),
            backBody: String(localized: "A jack matching the starter's suit scores one point. Keep a separate nobs check in your count routine."),
            choice: CardChoice(String(localized: "Add 1"), String(localized: "Ignore it"), answerIndex: 0)
        ),
    ]
}
