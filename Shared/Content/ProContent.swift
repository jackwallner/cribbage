import Foundation

/// The Master Tables: advanced discard, board-position, and pegging judgment.
enum ProContent {
    static let advancedDiscard: [DiscardScenario] = [
        DiscardScenario(
            id: "master-discard-1",
            situation: "You are pone and the dealer is close to the finish. Choose two.",
            deal: [.c(2), .d(3), .h(4), .s(5), .c(9), .d(10)],
            recommendedDiscard: [.c(9), .d(10)],
            reasoning: "Keep 2-3-4-5, a hand with multiple runs and fifteens. The 9 and 10 look useful in isolation, but throwing them together would make a strong dealer crib, so this is a close judgment. The board favors protecting the crib while retaining the connected block.",
            tip: "Advanced discard is hand value plus crib value plus board position."
        ),
        DiscardScenario(
            id: "master-discard-2",
            situation: "You are the dealer with a choice between a pair and a flush draw.",
            deal: [.h(2), .h(6), .h(9), .h(12), .c(5), .d(5)],
            recommendedDiscard: [.c(5), .d(5)],
            reasoning: "The four hearts are a four-card flush and the pair of 5s creates guaranteed points, so this choice is genuinely close. As dealer, keep the flush and place the pair in a crib where the duplicate rank can score.",
            tip: "When dealer, a pair can be a feature of the crib rather than the hand."
        ),
        DiscardScenario(
            id: "master-discard-3",
            situation: "You are pone with a high raw total but a dangerous gift. Choose two.",
            deal: [.c(5), .d(10), .h(11), .s(12), .c(13), .d(4)],
            recommendedDiscard: [.s(12), .c(13)],
            reasoning: "Keep the 5, 10, jack, and 4. The 5 creates several fifteens, and 4 keeps small-card possibilities open. The queen and king together give the dealer a ten-value-heavy crib with more fifteen paths.",
            tip: "A high card count can be worse than a lower count if the crib swings the race."
        ),
        DiscardScenario(
            id: "master-discard-4",
            situation: "The starter is likely to matter. Keep the hand with more useful cuts.",
            deal: [.c(3), .d(4), .h(5), .s(8), .c(8), .d(13)],
            recommendedDiscard: [.s(8), .d(13)],
            reasoning: "The 3-4-5 block has broad cut potential and the king can pair with the 5 only through value, not rank. The pair of 8s is tempting, but keeping it would give up the more connected low-card shape in this teaching line.",
            tip: "Useful cuts are a distribution, not one favorite card."
        ),
        DiscardScenario(
            id: "master-discard-5",
            situation: "The board rewards a pegging lead more than a hand maximum.",
            deal: [.c(2), .d(3), .h(7), .s(8), .c(10), .d(11)],
            recommendedDiscard: [.h(7), .s(8)],
            reasoning: "Keep the 2-3 connection and the ten-value cards for fifteens. The 7-8 pair can create a dangerous sequence for the opponent in pegging, while the board calls for a hand you can steer.",
            tip: "Discard choices can set up the pegging phase before it begins."
        ),
        DiscardScenario(
            id: "master-discard-6",
            situation: "Your lead is safe, but a spectacular crib would lose the race. Choose two.",
            deal: [.c(4), .d(5), .h(6), .s(10), .c(10), .d(12)],
            recommendedDiscard: [.s(10), .d(12)],
            reasoning: "Keep 4-5-6 and the pair of 10s for a dense scoring hand. The queen and one 10 are a risky crib package only when you are the dealer; this line assumes you are pone and need to deny the swing.",
            tip: "Know whose crib you are feeding before evaluating any discard."
        ),
    ]

    static let defenseQuiz: [QuizQuestion] = [
        QuizQuestion(
            id: "master-defense-1",
            prompt: "The opponent is at 120 and counts next. What matters most?",
            choices: ["Whether you can win before they count", "Your highest theoretical hand", "Keeping the dealer's crib large"],
            answerIndex: 0,
            explanation: "Cribbage is a race. If the opponent can reach 121 while counting first, ordinary hand value may not matter."
        ),
        QuizQuestion(
            id: "master-defense-2",
            prompt: "During pegging, which card is often safest to lead from a small connected hand?",
            choices: ["A 5 in every situation", "A card that avoids giving an immediate 15 or pair", "The highest card always"],
            answerIndex: 1,
            explanation: "Pegging defense depends on the running total and your opponent's likely replies. There is no universal safe rank, but avoiding obvious 15s and pairs is a strong start."
        ),
        QuizQuestion(
            id: "master-defense-3",
            prompt: "You have a choice between pegging 31 now or saving a card for last. What should decide it?",
            choices: ["Only the current hand score", "Board position, opponent cards, and the reset", "The suit of the card"],
            answerIndex: 1,
            explanation: "A 31 is 2 points, but saving a card can deny the opponent a go or earn last card. Use the board and the unseen cards, not a single rule."
        ),
        QuizQuestion(
            id: "master-defense-4",
            prompt: "Why track discarded ranks during the hand?",
            choices: ["To predict which runs and pairs remain possible", "Because discards can be reclaimed", "To change the starter"],
            answerIndex: 0,
            explanation: "Known discards reduce the live copies of ranks and help you judge both hand potential and pegging danger."
        ),
        QuizQuestion(
            id: "master-defense-5",
            prompt: "What is the most common counting error in a double run?",
            choices: ["Counting the run only once", "Counting a pair as a flush", "Adding the starter twice"],
            answerIndex: 0,
            explanation: "A duplicate rank creates multiple ways to form the same run. Count each distinct run, then count fifteens and pairs separately."
        ),
        QuizQuestion(
            id: "master-defense-6",
            prompt: "When should you choose a lower expected hand over a higher one?",
            choices: ["When the board and crib swing make it the better race decision", "Never", "Only when the suits match"],
            answerIndex: 0,
            explanation: "The correct decision maximizes your chance to win, not the number printed by a hand calculator in isolation."
        ),
    ]

    static let expertHandReading: [HandMatchQuestion] = [
        HandMatchQuestion(
            id: "master-hand-1",
            tiles: [.c(4), .d(4), .h(5), .s(6), .c(10)],
            choices: [.runs, .pairs, .fifteens],
            answer: .runs,
            explanation: "The duplicate 4 makes a double run of 4-5-6, worth 6 before the 5-10 fifteen is added."
        ),
        HandMatchQuestion(
            id: "master-hand-2",
            tiles: [.c(5), .d(5), .h(5), .s(10), .c(11)],
            choices: [.pairs, .fifteens, .counting],
            answer: .counting,
            explanation: "This hand is a full counting trap: three pairs from the 5s, three fifteens with the 10, and another with the jack."
        ),
        HandMatchQuestion(
            id: "master-hand-3",
            tiles: [.h(2), .h(3), .h(4), .h(5), .c(9)],
            choices: [.flushes, .runs, .fifteens],
            answer: .flushes,
            explanation: "Four hearts make a hand flush, while the 2-3-4-5 sequence also makes a run. The full count needs both, but the suit structure is the deceptive clue."
        ),
        HandMatchQuestion(
            id: "master-hand-4",
            tiles: [.c(6), .d(7), .h(8), .s(9), .c(10)],
            choices: [.runs, .fifteens, .pairs],
            answer: .runs,
            explanation: "6-7-8-9-10 is a five-card run, regardless of the mixed suits."
        ),
        HandMatchQuestion(
            id: "master-hand-5",
            tiles: [.c(2), .d(2), .h(2), .s(2), .c(10)],
            choices: [.pairs, .fifteens, .runs],
            answer: .pairs,
            explanation: "Four 2s contain six separate pairs. The 2s also combine with the 10 only as 12, so the duplicate rank is the core read."
        ),
        HandMatchQuestion(
            id: "master-hand-6",
            tiles: [.h(11), .c(5), .d(10), .s(4), .c(8)],
            choices: [.nobs, .fifteens, .flushes],
            answer: .fifteens,
            explanation: "The 5 makes fifteens with the 10 and jack. His nobs depends on the starter suit, so it is not guaranteed from the hand alone."
        ),
        HandMatchQuestion(
            id: "master-hand-7",
            tiles: [.c(3), .d(3), .h(4), .s(4), .c(5)],
            choices: [.runs, .pairs, .counting],
            answer: .counting,
            explanation: "There are two pairs and multiple overlapping runs. This is exactly the kind of hand that needs a disciplined full count."
        ),
        HandMatchQuestion(
            id: "master-hand-8",
            tiles: [.c(1), .d(2), .h(3), .s(4), .c(5)],
            choices: [.runs, .fifteens, .counting],
            answer: .counting,
            explanation: "A-2-3-4-5 is a five-card run and contains several fifteens. The expert move is to recognize the full count rather than stop at the first pattern."
        ),
    ]
}
