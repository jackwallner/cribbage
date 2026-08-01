import Foundation

/// Additional authored questions kept separate from the launch set so future
/// card-app ports can add a second content pass without rewriting the core.
enum MoreContent {
    static let cardExtras: [QuizQuestion] = [
        QuizQuestion(
            id: "more-card-deal",
            prompt: "How many cards does each player discard to the crib?",
            choices: ["1", "2", "3"],
            answerIndex: 1,
            explanation: "Each player discards exactly two cards. The dealer's crib then contains four cards before the starter is cut."
        ),
        QuizQuestion(
            id: "more-card-face",
            prompt: "What is a king worth toward fifteen?",
            tiles: [.s(13)],
            choices: ["10", "13", "0"],
            answerIndex: 0,
            explanation: "Every face card counts as 10 for fifteens, even though its rank stays jack, queen, or king for pairs and runs."
        ),
        QuizQuestion(
            id: "more-card-board",
            prompt: "What does the first player to 121 do?",
            choices: ["Wins", "Deals the next hand", "Scores the crib twice"],
            answerIndex: 0,
            explanation: "Standard cribbage is a race to 121. A player who reaches the finish first wins immediately."
        ),
        QuizQuestion(
            id: "more-card-cut",
            prompt: "Who usually cuts for the starter card?",
            choices: ["The non-dealer", "The dealer", "The player with fewer points"],
            answerIndex: 0,
            explanation: "The non-dealer cuts the deck after both players have discarded."
        ),
        QuizQuestion(
            id: "more-card-ace",
            prompt: "Can an ace be high in a run?",
            choices: ["Yes, after a king", "No, it is low", "Only in the crib"],
            answerIndex: 1,
            explanation: "Aces are low in cribbage. A, 2, 3 is a run, but Q, K, A is not."
        ),
        QuizQuestion(
            id: "more-card-count",
            prompt: "What is the safest way to count a complicated hand?",
            choices: ["Count only the best-looking pattern", "Use a fixed order and check every combination", "Count the cut card last and ignore it"],
            answerIndex: 1,
            explanation: "A repeatable count order, such as fifteens, pairs, runs, flush, and nobs, prevents omissions and double counting."
        ),
    ]

    static let handReading: [HandMatchQuestion] = [
        HandMatchQuestion(
            id: "more-hand-1",
            tiles: [.c(2), .d(3), .h(4), .s(8), .c(10)],
            choices: [.runs, .fifteens, .flushes],
            answer: .runs,
            explanation: "The 2-3-4 sequence is the clear connected shape. It can also participate in fifteens, but the run is the first structure to see."
        ),
        HandMatchQuestion(
            id: "more-hand-2",
            tiles: [.c(5), .d(5), .h(10), .s(11), .c(2)],
            choices: [.fifteens, .pairs, .nobs],
            answer: .fifteens,
            explanation: "Each 5 pairs with a ten-value card for a fifteen, so this hand has multiple fifteen combinations before the pair is counted."
        ),
        HandMatchQuestion(
            id: "more-hand-3",
            tiles: [.h(1), .h(4), .h(7), .h(12), .c(9)],
            choices: [.flushes, .pairs, .pegging],
            answer: .flushes,
            explanation: "Four hearts make a four-card hand flush. The starter would determine whether the fifth card extends it."
        ),
        HandMatchQuestion(
            id: "more-hand-4",
            tiles: [.c(9), .d(9), .h(9), .s(4), .c(6)],
            choices: [.pairs, .runs, .counting],
            answer: .pairs,
            explanation: "Three 9s contain three separate pairs. There is no consecutive sequence in the hand."
        ),
        HandMatchQuestion(
            id: "more-hand-5",
            tiles: [.c(6), .d(7), .h(8), .s(9), .c(13)],
            choices: [.runs, .fifteens, .crib],
            answer: .runs,
            explanation: "6-7-8-9 is a run of four. The king is separate from that sequence."
        ),
        HandMatchQuestion(
            id: "more-hand-6",
            tiles: [.h(11), .c(2), .d(5), .s(8), .c(10)],
            choices: [.nobs, .fifteens, .flushes],
            answer: .nobs,
            explanation: "The heart jack becomes his nobs if the starter is a heart. Keep the starter in the picture when evaluating this hand."
        ),
    ]

    static let discardExtras: [DiscardScenario] = [
        DiscardScenario(
            id: "more-discard-1",
            situation: "You are pone. Choose two cards without feeding the crib.",
            deal: [.c(3), .d(4), .h(5), .s(9), .c(10), .d(13)],
            recommendedDiscard: [.s(9), .d(13)],
            reasoning: "Keep 3-4-5-10, which is rich in runs and fifteens. The 9 and king are the least connected cards, and they do not make 15 together.",
            tip: "Pone should protect the crib as well as build a hand."
        ),
        DiscardScenario(
            id: "more-discard-2",
            situation: "You are the dealer with a pair and a run. Choose two.",
            deal: [.c(4), .d(4), .h(5), .s(6), .c(10), .d(12)],
            recommendedDiscard: [.c(10), .d(12)],
            reasoning: "Keep the pair of 4s and the 5-6 connection. The pair is guaranteed value, while 10 and queen are the least integrated cards in this deal.",
            tip: "Dealer decisions weigh both the hand and the crib."
        ),
        DiscardScenario(
            id: "more-discard-3",
            situation: "Four cards share a suit. Protect the potential flush.",
            deal: [.h(2), .h(6), .h(8), .h(12), .c(4), .s(7)],
            recommendedDiscard: [.c(4), .s(7)],
            reasoning: "Keeping the four hearts preserves a four-card flush and gives the starter a chance to add a fifth. The off-suit cards are not connected to each other.",
            tip: "A four-card flush is already a real source of points."
        ),
        DiscardScenario(
            id: "more-discard-4",
            situation: "You are near the finish. Favor the hand you can count safely.",
            deal: [.c(2), .d(3), .h(4), .s(8), .c(9), .d(10)],
            recommendedDiscard: [.s(8), .c(9)],
            reasoning: "The 2-3-4 block has clear run and fifteen potential. Keeping the connected small cards makes a stable hand when the board matters more than a speculative ceiling.",
            tip: "The board can make a dependable point more valuable than a risky maximum."
        ),
    ]

    static let tableQuiz: [QuizQuestion] = [
        QuizQuestion(
            id: "more-table-peg-15",
            prompt: "During pegging, what do you announce when the running total reaches 15?",
            choices: ["Fifteen for 2", "Go", "Last card"],
            answerIndex: 0,
            explanation: "A pegging total of exactly 15 scores 2 points."
        ),
        QuizQuestion(
            id: "more-table-peg-31",
            prompt: "What happens when a play brings the running total to 31?",
            choices: ["The player scores 2 and the count resets", "The hand ends", "Only the dealer scores"],
            answerIndex: 0,
            explanation: "Reaching exactly 31 scores 2 points, then the running count resets for the remaining cards."
        ),
        QuizQuestion(
            id: "more-table-go",
            prompt: "What is a go in pegging?",
            choices: ["A player cannot play without exceeding 31", "A player wins the game", "A discarded card is reclaimed"],
            answerIndex: 0,
            explanation: "When you cannot play without going over 31, you say go. The opponent may continue if they can."
        ),
        QuizQuestion(
            id: "more-table-pair-run",
            prompt: "A play makes a pair during pegging. How many points is that?",
            choices: ["1", "2", "3"],
            answerIndex: 1,
            explanation: "A pair in the pegging sequence is worth 2 points, just like a pair in the hand."
        ),
        QuizQuestion(
            id: "more-table-last",
            prompt: "Who scores the last-card point in a pegging sequence that does not reach 31?",
            choices: ["The player who played the last card", "The dealer only", "Nobody"],
            answerIndex: 0,
            explanation: "The player who plays the final card before the count resets scores 1 for last card."
        ),
        QuizQuestion(
            id: "more-table-order",
            prompt: "When should you think about the board position?",
            choices: ["Only after counting", "Before choosing a discard and during pegging", "Never, the highest hand always wins"],
            answerIndex: 1,
            explanation: "Cribbage is a race. Board position should shape discards, pegging risk, and whether you chase points or safety."
        ),
    ]

    static let judgment: [Flashcard] = [
        Flashcard(
            id: "more-judgment-five",
            frontTitle: "You are pone with a 5",
            frontTiles: [.c(5)],
            frontSubtitle: "Throw it to the dealer?",
            backTitle: "Usually keep it",
            backBody: "A 5 connects with every ten-value card and is a dangerous crib gift. Keep it unless the hand improvement from discarding it is overwhelming.",
            choice: CardChoice("Keep it", "Throw it", answerIndex: 0)
        ),
        Flashcard(
            id: "more-judgment-pair",
            frontTitle: "A guaranteed pair",
            frontTiles: [.c(8), .d(8)],
            frontSubtitle: "Break it for a thin possibility?",
            backTitle: "Respect guaranteed points",
            backBody: "A pair is 2 points before the starter. Keep it unless the alternative creates a much stronger, clearly countable hand.",
            choice: CardChoice("Keep the pair", "Break it automatically", answerIndex: 0)
        ),
        Flashcard(
            id: "more-judgment-board",
            frontTitle: "You lead by one hole",
            frontSubtitle: "Big hand or safe hand?",
            backTitle: "Safety gets louder",
            backBody: "A close board rewards choices that create reliable points and reduce the opponent's crib. The theoretical maximum is not always the practical best play.",
            choice: CardChoice("Choose the safe line", "Always chase the maximum", answerIndex: 0)
        ),
        Flashcard(
            id: "more-judgment-go",
            frontTitle: "Pegging total is 27",
            frontSubtitle: "Your remaining cards are 4 and 8",
            backTitle: "Play the 4",
            backBody: "The 4 makes 31 for 2 points. Playing the 8 would exceed 31, so the legal safe play is the 4.",
            choice: CardChoice("Play the 4", "Play the 8", answerIndex: 0)
        ),
    ]

    static let advancedRules: [QuizQuestion] = [
        QuizQuestion(
            id: "more-advanced-muggins",
            prompt: "What is muggins?",
            choices: ["A rule allowing an opponent to claim missed points", "A special crib", "A kind of run"],
            answerIndex: 0,
            explanation: "In games using muggins, an opponent may call out points you failed to peg or count. Agree on the rule before play."
        ),
        QuizQuestion(
            id: "more-advanced-crib-flush",
            prompt: "What is required for a five-card flush in the crib?",
            choices: ["The four crib cards match", "All four crib cards and the starter match", "Any four cards match"],
            answerIndex: 1,
            explanation: "A crib flush requires all four crib cards plus the starter to be the same suit."
        ),
        QuizQuestion(
            id: "more-advanced-double-run",
            prompt: "What creates a double run?",
            tiles: [.c(4), .d(4), .h(5), .s(6)],
            choices: ["A duplicate rank inside a run", "Two flushes", "Two fifteens"],
            answerIndex: 0,
            explanation: "A duplicate rank gives the consecutive sequence two ways to be formed, doubling the run's points."
        ),
        QuizQuestion(
            id: "more-advanced-ace-run",
            prompt: "Which is a legal run?",
            choices: ["Q-K-A", "A-2-3", "K-A-2"],
            answerIndex: 1,
            explanation: "Aces are low in cribbage, so A-2-3 is a run. The ace does not wrap around from king."
        ),
        QuizQuestion(
            id: "more-advanced-dealer-order",
            prompt: "Who counts first after pegging?",
            choices: ["The pone's hand, then the dealer's hand and crib", "The dealer's crib, then the pone", "The player with the higher score"],
            answerIndex: 0,
            explanation: "The pone counts first, then the dealer counts their hand and finally the crib. The order affects who can win before the other player counts."
        ),
    ]
}
