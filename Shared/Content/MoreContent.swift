import Foundation

/// Additional authored questions kept separate from the launch set so future
/// card-app ports can add a second content pass without rewriting the core.
enum MoreContent {
    static let cardExtras: [QuizQuestion] = [
        QuizQuestion(
            id: "more-card-deal",
            prompt: String(localized: "How many cards does each player discard to the crib?"),
            choices: [String(localized: "1"), String(localized: "2"), String(localized: "3")],
            answerIndex: 1,
            explanation: String(localized: "Each player discards exactly two cards. The dealer's crib then contains four cards before the starter is cut.")
        ),
        QuizQuestion(
            id: "more-card-face",
            prompt: String(localized: "What is a king worth toward fifteen?"),
            tiles: [.s(13)],
            choices: [String(localized: "10"), String(localized: "13"), String(localized: "0")],
            answerIndex: 0,
            explanation: String(localized: "Every face card counts as 10 for fifteens, even though its rank stays jack, queen, or king for pairs and runs.")
        ),
        QuizQuestion(
            id: "more-card-board",
            prompt: String(localized: "What does the first player to 121 do?"),
            choices: [String(localized: "Wins"), String(localized: "Deals the next hand"), String(localized: "Scores the crib twice")],
            answerIndex: 0,
            explanation: String(localized: "Standard cribbage is a race to 121. A player who reaches the finish first wins immediately.")
        ),
        QuizQuestion(
            id: "more-card-cut",
            prompt: String(localized: "Who usually cuts for the starter card?"),
            choices: [String(localized: "The non-dealer"), String(localized: "The dealer"), String(localized: "The player with fewer points")],
            answerIndex: 0,
            explanation: String(localized: "The non-dealer cuts the deck after both players have discarded.")
        ),
        QuizQuestion(
            id: "more-card-ace",
            prompt: String(localized: "Can an ace be high in a run?"),
            choices: [String(localized: "Yes, after a king"), String(localized: "No, it is low"), String(localized: "Only in the crib")],
            answerIndex: 1,
            explanation: String(localized: "Aces are low in cribbage. A, 2, 3 is a run, but Q, K, A is not.")
        ),
        QuizQuestion(
            id: "more-card-count",
            prompt: String(localized: "What is the safest way to count a complicated hand?"),
            choices: [String(localized: "Count only the best-looking pattern"), String(localized: "Use a fixed order and check every combination"), String(localized: "Count the cut card last and ignore it")],
            answerIndex: 1,
            explanation: String(localized: "A repeatable count order, such as fifteens, pairs, runs, flush, and nobs, prevents omissions and double counting.")
        ),
    ]

    static let handReading: [HandMatchQuestion] = [
        HandMatchQuestion(
            id: "more-hand-1",
            tiles: [.c(2), .d(3), .h(4), .s(8), .c(10)],
            choices: [.runs, .pairs, .flushes],
            answer: .runs,
            explanation: String(localized: "2-3-4 is a run of three. No rank repeats and only two cards share a suit, so the run is the shape on the table. Two fifteens hide behind it for a full count of 7.")
        ),
        HandMatchQuestion(
            id: "more-hand-2",
            tiles: [.c(5), .d(5), .h(10), .s(11), .c(2)],
            choices: [.fifteens, .runs, .flushes],
            answer: .fifteens,
            explanation: String(localized: "Each 5 makes fifteen with the 10 and again with the jack. Four fifteens is 8 points, before the pair of 5s adds 2 more.")
        ),
        HandMatchQuestion(
            id: "more-hand-3",
            tiles: [.h(1), .h(4), .h(7), .h(12), .c(9)],
            choices: [.flushes, .pairs, .runs],
            answer: .flushes,
            explanation: String(localized: "Four hearts make a four-card hand flush worth 4, or 5 if the starter is a heart too.")
        ),
        HandMatchQuestion(
            id: "more-hand-4",
            tiles: [.c(9), .d(9), .h(9), .s(4), .c(6)],
            choices: [.pairs, .runs, .flushes],
            answer: .pairs,
            explanation: String(localized: "Three 9s contain three separate pairs for 6 points. There is no consecutive sequence, though each 9 does make fifteen with the 6.")
        ),
        HandMatchQuestion(
            id: "more-hand-5",
            tiles: [.c(6), .d(7), .h(8), .s(9), .c(13)],
            choices: [.runs, .pairs, .flushes],
            answer: .runs,
            explanation: String(localized: "6-7-8-9 is a run of four. The king sits apart from that sequence, and the two fifteens, 6 with 9 and 7 with 8, are counted separately.")
        ),
        HandMatchQuestion(
            id: "more-hand-6",
            tiles: [.h(11), .c(2), .d(5), .s(8), .c(10)],
            choices: [.nobs, .runs, .flushes],
            answer: .nobs,
            explanation: String(localized: "The heart jack becomes his nobs if the starter is a heart. Nothing here runs three deep and only two cards share a suit, so the jack is the shape to watch.")
        ),
    ]

    static let discardExtras: [DiscardScenario] = [
        DiscardScenario(
            id: "more-discard-1",
            isDealer: false,
            situation: String(localized: "You are pone. Choose two cards without feeding the crib."),
            deal: [.c(3), .d(4), .h(5), .s(9), .c(10), .d(13)],
            recommendedDiscard: [.s(9), .d(13)],
            reasoning: String(localized: "Keep 3-4-5-10, which is rich in runs and fifteens. The 9 and king are the least connected cards, and they do not make 15 together."),
            tip: String(localized: "Pone should protect the crib as well as build a hand.")
        ),
        DiscardScenario(
            id: "more-discard-2",
            isDealer: true,
            situation: String(localized: "You are the dealer with a pair and a run. Choose two."),
            deal: [.c(4), .d(4), .h(5), .s(6), .c(10), .d(12)],
            recommendedDiscard: [.c(10), .d(12)],
            reasoning: String(localized: "Keep the pair of 4s and the 5-6 connection. The pair is guaranteed value, while 10 and queen are the least integrated cards in this deal."),
            tip: String(localized: "Dealer decisions weigh both the hand and the crib.")
        ),
        DiscardScenario(
            id: "more-discard-3",
            isDealer: false,
            situation: String(localized: "You are pone and four cards share a suit. Protect the flush."),
            deal: [.c(2), .c(4), .c(9), .c(12), .d(7), .h(13)],
            recommendedDiscard: [.d(7), .h(13)],
            reasoning: String(localized: "Keeping the four clubs is 4 for the flush plus 2 for the 2-4-9 fifteen, and a club cut makes the flush 5. The 7 and king are off-suit, do not pair, and do not reach fifteen together, so they cost the dealer's crib very little."),
            tip: String(localized: "A four-card flush is already a real source of points.")
        ),
        DiscardScenario(
            id: "more-discard-4",
            isDealer: false,
            situation: String(localized: "You are pone near the finish. Favor the hand you can count safely."),
            deal: [.c(2), .d(3), .h(4), .s(8), .c(9), .d(10)],
            recommendedDiscard: [.s(8), .d(10)],
            reasoning: String(localized: "Keep 2-3-4 with the 9: the run scores 3 and 2-4-9 makes fifteen. Holding the 9 rather than the 10 matters on the discard side, because 8 and 10 give the dealer nothing, while 8 and 9 hand over a run start."),
            tip: String(localized: "The board can make a dependable point more valuable than a risky maximum.")
        ),
    ]

    static let tableQuiz: [QuizQuestion] = [
        QuizQuestion(
            id: "more-table-peg-15",
            prompt: String(localized: "During pegging, what do you announce when the running total reaches 15?"),
            choices: [String(localized: "Fifteen for 2"), String(localized: "Go"), String(localized: "Last card")],
            answerIndex: 0,
            explanation: String(localized: "A pegging total of exactly 15 scores 2 points.")
        ),
        QuizQuestion(
            id: "more-table-peg-31",
            prompt: String(localized: "What happens when a play brings the running total to 31?"),
            choices: [String(localized: "The player scores 2 and the count resets"), String(localized: "The hand ends"), String(localized: "Only the dealer scores")],
            answerIndex: 0,
            explanation: String(localized: "Reaching exactly 31 scores 2 points, then the running count resets for the remaining cards.")
        ),
        QuizQuestion(
            id: "more-table-go",
            prompt: String(localized: "What is a go in pegging?"),
            choices: [String(localized: "A player cannot play without exceeding 31"), String(localized: "A player wins the game"), String(localized: "A discarded card is reclaimed")],
            answerIndex: 0,
            explanation: String(localized: "When you cannot play without going over 31, you say go. The opponent may continue if they can.")
        ),
        QuizQuestion(
            id: "more-table-pair-run",
            prompt: String(localized: "A play makes a pair during pegging. How many points is that?"),
            choices: [String(localized: "1"), String(localized: "2"), String(localized: "3")],
            answerIndex: 1,
            explanation: String(localized: "A pair in the pegging sequence is worth 2 points, just like a pair in the hand.")
        ),
        QuizQuestion(
            id: "more-table-last",
            prompt: String(localized: "Who scores the last-card point in a pegging sequence that does not reach 31?"),
            choices: [String(localized: "The player who played the last card"), String(localized: "The dealer only"), String(localized: "Nobody")],
            answerIndex: 0,
            explanation: String(localized: "The player who plays the final card before the count resets scores 1 for last card.")
        ),
        QuizQuestion(
            id: "more-table-order",
            prompt: String(localized: "When should you think about the board position?"),
            choices: [String(localized: "Only after counting"), String(localized: "Before choosing a discard and during pegging"), String(localized: "Never, the highest hand always wins")],
            answerIndex: 1,
            explanation: String(localized: "Cribbage is a race. Board position should shape discards, pegging risk, and whether you chase points or safety.")
        ),
    ]

    static let judgment: [Flashcard] = [
        Flashcard(
            id: "more-judgment-five",
            frontTitle: String(localized: "You are pone with a 5"),
            frontTiles: [.c(5)],
            frontSubtitle: String(localized: "Throw it to the dealer?"),
            backTitle: String(localized: "Usually keep it"),
            backBody: String(localized: "A 5 connects with every ten-value card and is a dangerous crib gift. Keep it unless the hand improvement from discarding it is overwhelming."),
            choice: CardChoice(String(localized: "Keep it"), String(localized: "Throw it"), answerIndex: 0)
        ),
        Flashcard(
            id: "more-judgment-pair",
            frontTitle: String(localized: "A guaranteed pair"),
            frontTiles: [.c(8), .d(8)],
            frontSubtitle: String(localized: "Break it for a thin possibility?"),
            backTitle: String(localized: "Respect guaranteed points"),
            backBody: String(localized: "A pair is 2 points before the starter. Keep it unless the alternative creates a much stronger, clearly countable hand."),
            choice: CardChoice(String(localized: "Keep the pair"), String(localized: "Break it automatically"), answerIndex: 0)
        ),
        Flashcard(
            id: "more-judgment-board",
            frontTitle: String(localized: "You lead by one hole"),
            frontSubtitle: String(localized: "Big hand or safe hand?"),
            backTitle: String(localized: "Safety gets louder"),
            backBody: String(localized: "A one-point lead alone does not decide your strategy. Consider the actual scores, who counts first, and likely pegging. Choose the line that best serves the race."),
            choice: CardChoice(String(localized: "Choose the safe line"), String(localized: "Always chase the maximum"), answerIndex: 0)
        ),
        Flashcard(
            id: "more-judgment-go",
            frontTitle: String(localized: "Pegging total is 27"),
            frontSubtitle: String(localized: "Your remaining cards are 4 and 8"),
            backTitle: String(localized: "Play the 4"),
            backBody: String(localized: "The 4 makes 31 for 2 points. Playing the 8 would exceed 31, so the legal safe play is the 4."),
            choice: CardChoice(String(localized: "Play the 4"), String(localized: "Play the 8"), answerIndex: 0)
        ),
    ]

    static let advancedRules: [QuizQuestion] = [
        QuizQuestion(
            id: "more-advanced-muggins",
            prompt: String(localized: "What is muggins?"),
            choices: [String(localized: "A rule allowing an opponent to claim missed points"), String(localized: "A special crib"), String(localized: "A kind of run")],
            answerIndex: 0,
            explanation: String(localized: "Muggins is an optional rule, agreed before play. Under ACC rules, after a player releases the peg or forfeits a score, the opponent may claim missed play, hand or crib points. Missed heels (the starter jack), penalties, muggins points and backward-pegging losses are excluded.")
        ),
        QuizQuestion(
            id: "more-advanced-crib-flush",
            prompt: String(localized: "What is required for a five-card flush in the crib?"),
            choices: [String(localized: "The four crib cards match"), String(localized: "All four crib cards and the starter match"), String(localized: "Any four cards match")],
            answerIndex: 1,
            explanation: String(localized: "A crib flush requires all four crib cards plus the starter to be the same suit.")
        ),
        QuizQuestion(
            id: "more-advanced-double-run",
            prompt: String(localized: "What creates a double run?"),
            tiles: [.c(4), .d(4), .h(5), .s(6)],
            choices: [String(localized: "A duplicate rank inside a run"), String(localized: "Two flushes"), String(localized: "Two fifteens")],
            answerIndex: 0,
            explanation: String(localized: "A duplicate rank gives the consecutive sequence two ways to be formed, doubling the run's points.")
        ),
        QuizQuestion(
            id: "more-advanced-ace-run",
            prompt: String(localized: "Which is a legal run?"),
            choices: [String(localized: "Q-K-A"), String(localized: "A-2-3"), String(localized: "K-A-2")],
            answerIndex: 1,
            explanation: String(localized: "Aces are low in cribbage, so A-2-3 is a run. The ace does not wrap around from king.")
        ),
        QuizQuestion(
            id: "more-advanced-dealer-order",
            prompt: String(localized: "Who counts first after pegging?"),
            choices: [String(localized: "The pone's hand, then the dealer's hand and crib"), String(localized: "The dealer's crib, then the pone"), String(localized: "The player with the higher score")],
            answerIndex: 0,
            explanation: String(localized: "The pone counts first, then the dealer counts their hand and finally the crib. The order affects who can win before the other player counts.")
        ),
    ]
}
