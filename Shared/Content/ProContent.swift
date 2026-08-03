import Foundation

/// The Master Tables: advanced discard, board-position, and pegging judgment.
enum ProContent {
    static let advancedDiscard: [DiscardScenario] = [
        DiscardScenario(
            id: "master-discard-1",
            situation: "You are pone. The bigger hand is the wrong hand. Choose two.",
            deal: [.d(1), .h(1), .s(5), .h(6), .h(8), .c(12)],
            recommendedDiscard: [.h(6), .c(12)],
            reasoning: "Keeping A-A-6-8 counts 6 and A-A-5-8 counts 4, so the bigger hand is two points better. It is still the wrong choice: the cards it throws are a 5 and a queen, which already make fifteen in the crib you do not own. Throw the 6 and the queen instead and hand over nothing that scores by itself.",
            tip: "As pone, subtract what the crib gains before you compare two hands."
        ),
        DiscardScenario(
            id: "master-discard-2",
            situation: "You are the dealer, choosing between a pair and a flush.",
            deal: [.h(2), .h(6), .h(9), .h(12), .c(5), .d(5)],
            recommendedDiscard: [.c(5), .d(5)],
            reasoning: "Both halves score, so the question is where each half is worth more. The four hearts are 4 in the hand with a fifth heart still live, and a pair of 5s is the single strongest thing you can put in your own crib, because it pairs and makes fifteen with every ten-value card that lands there.",
            tip: "When dealer, a pair can be a feature of the crib rather than the hand."
        ),
        DiscardScenario(
            id: "master-discard-3",
            situation: "You are pone with four ten-value cards. Choose two.",
            deal: [.c(5), .d(10), .h(11), .s(12), .c(13), .d(4)],
            recommendedDiscard: [.c(13), .d(4)],
            reasoning: "Keep 5-10-J-Q. The 5 makes fifteen with each of the three ten-value cards, and 10-jack-queen is a run of three, so the hand counts 9 before the cut, with a jack that can add his nobs. The king and the 4 neither pair nor make fifteen together in the dealer's crib.",
            tip: "A high card count can be worse than a lower count if the crib swings the race."
        ),
        DiscardScenario(
            id: "master-discard-4",
            situation: "You are pone. Keep the hand with more useful cuts.",
            deal: [.c(3), .d(4), .h(5), .s(8), .c(8), .d(13)],
            recommendedDiscard: [.s(8), .d(13)],
            reasoning: "Breaking the pair of 8s costs a guaranteed 2, but 3-4-5 with one 8 already scores 5: the run is 3 and 3-4-8 makes fifteen. The low block also improves on far more cuts, and an 8 with a king is a quiet gift to the dealer.",
            tip: "Useful cuts are a distribution, not one favorite card."
        ),
        DiscardScenario(
            id: "master-discard-5",
            situation: "You are the dealer. Choose the discard that works twice.",
            deal: [.c(2), .d(3), .h(7), .s(8), .c(10), .d(11)],
            recommendedDiscard: [.h(7), .s(8)],
            reasoning: "Keep 2-3-10-J: 2-3-10 and 2-3-jack are two fifteens, and the jack can still add his nobs. The 7 and 8 are the strongest pair of cards you can put in your own crib, because they already make fifteen there no matter what the opponent throws.",
            tip: "Discard choices can set up the crib before the cut is turned."
        ),
        DiscardScenario(
            id: "master-discard-6",
            situation: "You are pone and your lead is safe. Choose two.",
            deal: [.c(4), .d(5), .h(6), .s(10), .c(10), .d(12)],
            recommendedDiscard: [.s(10), .d(12)],
            reasoning: "Keep 4-5-6 with one 10: the run is 3, 4-5-6 makes fifteen, and 5 with the 10 makes another, for 7 points. Breaking the pair of 10s costs 2, but it denies the dealer a 10-queen crib package and keeps the block that most cuts improve.",
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
            choices: [.runs, .flushes, .nobs],
            answer: .runs,
            explanation: "The second 4 gives 4-5-6 two ways to form, a double run of three worth 6. Add 2 for the pair and 6 for three fifteens, two of them 4-5-6 and one the 5 with the 10, and the hand counts 14."
        ),
        HandMatchQuestion(
            id: "master-hand-2",
            tiles: [.c(5), .d(5), .h(5), .s(10), .c(11)],
            choices: [.fifteens, .runs, .flushes],
            answer: .fifteens,
            explanation: "Every 5 makes fifteen with the 10 and again with the jack, and the three 5s together also total fifteen. Seven fifteens is 14 points, before 6 more for the three pairs."
        ),
        HandMatchQuestion(
            id: "master-hand-3",
            tiles: [.h(2), .h(3), .h(4), .h(5), .c(9)],
            choices: [.flushes, .pairs, .nobs],
            answer: .flushes,
            explanation: "Four hearts make a hand flush worth 4, and a heart cut would make it 5. No rank repeats and there is no jack, so the suit is the only one of these three shapes on the table."
        ),
        HandMatchQuestion(
            id: "master-hand-4",
            tiles: [.c(6), .d(7), .h(8), .s(9), .c(10)],
            choices: [.runs, .pairs, .flushes],
            answer: .runs,
            explanation: "6-7-8-9-10 is a five-card run worth 5, regardless of the mixed suits. It also hides two fifteens, 6 with 9 and 7 with 8, for a full count of 9."
        ),
        HandMatchQuestion(
            id: "master-hand-5",
            tiles: [.c(2), .d(2), .h(2), .s(2), .c(10)],
            choices: [.pairs, .fifteens, .runs],
            answer: .pairs,
            explanation: "Four 2s contain six separate pairs for 12. The 2s and the 10 reach 12, 14, 16, and 18 but never fifteen, so the duplicate rank is the entire count."
        ),
        HandMatchQuestion(
            id: "master-hand-6",
            tiles: [.h(11), .c(5), .d(10), .s(4), .c(8)],
            choices: [.fifteens, .runs, .pairs],
            answer: .fifteens,
            explanation: "The 5 makes fifteen with the 10 and again with the jack, for 4 points. Nothing repeats a rank, and 4-5 never reaches a third consecutive card."
        ),
        HandMatchQuestion(
            id: "master-hand-7",
            tiles: [.c(3), .d(3), .h(4), .s(4), .c(5)],
            choices: [.runs, .flushes, .nobs],
            answer: .runs,
            explanation: "Two 3s and two 4s let 3-4-5 form four different ways, 12 points of runs. Add 4 for the two pairs and 4 for the two fifteens and the hand counts 20."
        ),
        HandMatchQuestion(
            id: "master-hand-8",
            tiles: [.c(1), .d(2), .h(3), .s(4), .c(5)],
            choices: [.runs, .pairs, .flushes],
            answer: .runs,
            explanation: "Ace through 5 is a five-card run for 5 points, and the five cards together total exactly fifteen for 2 more. Aces are low, so the run starts at the ace."
        ),
    ]
}
