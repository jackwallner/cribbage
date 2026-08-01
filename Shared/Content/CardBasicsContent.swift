import Foundation

/// The Card Basics room: enough vocabulary to make the first deal feel calm.
enum CardBasicsContent {
    static let meetTheCards: [Flashcard] = [
        Flashcard(
            id: "cards-deck",
            frontTitle: "The deck",
            frontSubtitle: "Start with the shape of the game",
            backTitle: "52 cards, one cut",
            backBody: "Cribbage uses a standard 52-card deck. Each player is dealt six cards, discards two to the crib, and then the starter card is cut from the deck."
        ),
        Flashcard(
            id: "cards-suits",
            frontTitle: "Four suits",
            frontTiles: [.c(7), .d(7), .h(7), .s(7)],
            frontSubtitle: "The same rank, four suits",
            backTitle: "Suit matters selectively",
            backBody: "Clubs, diamonds, hearts, and spades each have thirteen ranks. Suit matters for flushes and his nobs. Most fifteens, pairs, and runs care about rank or value instead."
        ),
        Flashcard(
            id: "cards-values",
            frontTitle: "Card values",
            frontTiles: [.c(1), .d(5), .h(10), .s(13)],
            frontSubtitle: "What counts toward fifteen?",
            backTitle: "Ace is 1, face cards are 10",
            backBody: "Aces count as 1. Number cards keep their number. Jacks, queens, and kings each count as 10. The rank still matters for pairs and runs."
        ),
        Flashcard(
            id: "cards-fifteen",
            frontTitle: "Make fifteen",
            frontTiles: [.c(5), .d(10)],
            frontSubtitle: "The most common scoring pattern",
            backTitle: "Every combination counts",
            backBody: "Every distinct combination totaling 15 scores 2 points. A hand can contain several fifteens, and each one is counted separately."
        ),
        Flashcard(
            id: "cards-pairs",
            frontTitle: "Spot a pair",
            frontTiles: [.c(9), .h(9)],
            frontSubtitle: "Matching rank, different suit",
            backTitle: "A pair is 2 points",
            backBody: "Two cards with the same rank score 2 points. Three of a kind contains three separate pairs, and four of a kind contains six."
        ),
        Flashcard(
            id: "cards-runs",
            frontTitle: "Build a run",
            frontTiles: [.c(4), .d(5), .s(6)],
            frontSubtitle: "Order matters, suit does not",
            backTitle: "Three in sequence is 3",
            backBody: "Three consecutive ranks score 3 points, four score 4, and so on. Suits may be mixed. Duplicate ranks can create double, triple, or quadruple runs."
        ),
        Flashcard(
            id: "cards-starter",
            frontTitle: "The starter card",
            frontTiles: [.h(11)],
            frontSubtitle: "The cut changes the hand",
            backTitle: "It joins both counts",
            backBody: "After the discard, the non-dealer cuts the deck and the starter card joins both hands and the crib. It can create new fifteens, pairs, runs, a flush, or his nobs."
        ),
        Flashcard(
            id: "cards-nobs",
            frontTitle: "His nobs",
            frontTiles: [.h(11), .h(4)],
            frontSubtitle: "One tiny suit check",
            backTitle: "A matching jack is 1",
            backBody: "If your hand contains a jack that matches the starter card's suit, score one point for his nobs. The jack does not need to match the starter's rank."
        ),
        Flashcard(
            id: "cards-dealer",
            frontTitle: "Who owns the crib?",
            frontSubtitle: "The dealer's tradeoff",
            backTitle: "The dealer scores it",
            backBody: "Both players discard two cards to the dealer's crib. The dealer counts the crib after counting their own hand, so dealer discards are both an opportunity and a risk."
        ),
        Flashcard(
            id: "cards-goal",
            frontTitle: "The race",
            frontSubtitle: "Why every point matters",
            backTitle: "Reach 121 first",
            backBody: "Players move pegs around a 120-hole board. The first player to reach 121 wins, so a safe point now can matter more than a perfect-looking hand later."
        ),
    ]

    static let cardQuiz: [QuizQuestion] = [
        QuizQuestion(
            id: "card-quiz-1",
            prompt: "How many points does a single combination totaling 15 score?",
            tiles: [.c(5), .d(10)],
            choices: ["1 point", "2 points", "5 points"],
            answerIndex: 1,
            explanation: "Each distinct combination totaling 15 scores 2 points."
        ),
        QuizQuestion(
            id: "card-quiz-2",
            prompt: "What value does a queen contribute to a fifteen?",
            tiles: [.h(12)],
            choices: ["10", "12", "0"],
            answerIndex: 0,
            explanation: "Jacks, queens, and kings each have a cribbage value of 10, while their ranks stay distinct for pairs and runs."
        ),
        QuizQuestion(
            id: "card-quiz-3",
            prompt: "Who scores the crib?",
            choices: ["The non-dealer", "The dealer", "Whoever cut the starter"],
            answerIndex: 1,
            explanation: "The crib belongs to the dealer. Both players contribute two cards to it."
        ),
        QuizQuestion(
            id: "card-quiz-4",
            prompt: "What makes his nobs?",
            tiles: [.h(11), .h(6)],
            choices: ["A jack matching the starter's suit", "Any jack in the hand", "A pair of jacks"],
            answerIndex: 0,
            explanation: "His nobs is one point for a jack matching the starter card's suit."
        ),
        QuizQuestion(
            id: "card-quiz-5",
            prompt: "How many cards does each player receive before discarding?",
            choices: ["4", "5", "6"],
            answerIndex: 2,
            explanation: "The standard deal gives each player six cards. Each player then discards two to the crib."
        ),
        QuizQuestion(
            id: "card-quiz-6",
            prompt: "Can a run use mixed suits?",
            tiles: [.c(3), .d(4), .s(5)],
            choices: ["Yes", "No, all suits must match", "Only in the crib"],
            answerIndex: 0,
            explanation: "Runs use consecutive ranks. The suits can be mixed."
        ),
        QuizQuestion(
            id: "card-quiz-7",
            prompt: "How many points does a pair score?",
            tiles: [.c(8), .s(8)],
            choices: ["1", "2", "4"],
            answerIndex: 1,
            explanation: "Two cards of the same rank make one pair worth 2 points."
        ),
        QuizQuestion(
            id: "card-quiz-8",
            prompt: "What is the usual winning hole on a cribbage board?",
            choices: ["31", "61", "121"],
            answerIndex: 2,
            explanation: "Cribbage is normally a race to 121 points."
        ),
        QuizQuestion(
            id: "card-quiz-9",
            prompt: "What happens after the two players discard?",
            choices: ["The starter card is cut", "The dealer redeals", "Pegging starts immediately"],
            answerIndex: 0,
            explanation: "The non-dealer cuts the deck and the starter card is placed face up before pegging begins."
        ),
        QuizQuestion(
            id: "card-quiz-10",
            prompt: "Which cards all count as 10 for fifteens?",
            choices: ["10s only", "10s and face cards", "All cards above 9 count as their rank"],
            answerIndex: 1,
            explanation: "Tens, jacks, queens, and kings each contribute 10 to a fifteen."
        ),
    ]
}
