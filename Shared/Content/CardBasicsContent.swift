import Foundation

/// The Card Basics room: enough vocabulary to make the first deal feel calm.
enum CardBasicsContent {
    static let meetTheCards: [Flashcard] = [
        Flashcard(
            id: "cards-deck",
            frontTitle: String(localized: "The deck"),
            frontSubtitle: String(localized: "Start with the shape of the game"),
            backTitle: String(localized: "52 cards, one cut"),
            backBody: String(localized: "Cribbage uses a standard 52-card deck. Each player is dealt six cards, discards two to the crib, and then the starter card is cut from the deck.")
        ),
        Flashcard(
            id: "cards-suits",
            frontTitle: String(localized: "Four suits"),
            frontTiles: [.c(7), .d(7), .h(7), .s(7)],
            frontSubtitle: String(localized: "The same rank, four suits"),
            backTitle: String(localized: "Suit matters selectively"),
            backBody: String(localized: "Clubs, diamonds, hearts, and spades each have thirteen ranks. Suit matters for flushes and his nobs. Most fifteens, pairs, and runs care about rank or value instead.")
        ),
        Flashcard(
            id: "cards-values",
            frontTitle: String(localized: "Card values"),
            frontTiles: [.c(1), .d(5), .h(10), .s(13)],
            frontSubtitle: String(localized: "What counts toward fifteen?"),
            backTitle: String(localized: "Ace is 1, face cards are 10"),
            backBody: String(localized: "Aces count as 1. Number cards keep their number. Jacks, queens, and kings each count as 10. The rank still matters for pairs and runs.")
        ),
        Flashcard(
            id: "cards-fifteen",
            frontTitle: String(localized: "Make fifteen"),
            frontTiles: [.c(5), .d(10)],
            frontSubtitle: String(localized: "The most common scoring pattern"),
            backTitle: String(localized: "Every combination counts"),
            backBody: String(localized: "Every distinct combination totaling 15 scores 2 points. A hand can contain several fifteens, and each one is counted separately.")
        ),
        Flashcard(
            id: "cards-pairs",
            frontTitle: String(localized: "Spot a pair"),
            frontTiles: [.c(9), .h(9)],
            frontSubtitle: String(localized: "Matching rank, different suit"),
            backTitle: String(localized: "A pair is 2 points"),
            backBody: String(localized: "Two cards with the same rank score 2 points. Three of a kind contains three separate pairs, and four of a kind contains six.")
        ),
        Flashcard(
            id: "cards-runs",
            frontTitle: String(localized: "Build a run"),
            frontTiles: [.c(4), .d(5), .s(6)],
            frontSubtitle: String(localized: "Order matters, suit does not"),
            backTitle: String(localized: "Three in sequence is 3"),
            backBody: String(localized: "Three consecutive ranks score 3 points, four score 4, and so on. Suits may be mixed. Duplicate ranks can create double, double-double, or triple runs.")
        ),
        Flashcard(
            id: "cards-starter",
            frontTitle: String(localized: "The starter card"),
            frontTiles: [.h(11)],
            frontSubtitle: String(localized: "The cut changes the hand"),
            backTitle: String(localized: "It joins both counts"),
            backBody: String(localized: "After the discard, the non-dealer cuts the deck and the starter card joins both hands and the crib. It can create new fifteens, pairs, runs, a flush, or his nobs. A jack as the starter also pegs 2 for the dealer, called his heels.")
        ),
        Flashcard(
            id: "cards-nobs",
            frontTitle: String(localized: "His nobs"),
            frontTiles: [.h(11), .h(4)],
            frontSubtitle: String(localized: "One tiny suit check"),
            backTitle: String(localized: "A matching jack is 1"),
            backBody: String(localized: "If your hand contains a jack that matches the starter card's suit, score one point for his nobs. The jack does not need to match the starter's rank.")
        ),
        Flashcard(
            id: "cards-dealer",
            frontTitle: String(localized: "Who owns the crib?"),
            frontSubtitle: String(localized: "The dealer's tradeoff"),
            backTitle: String(localized: "The dealer scores it"),
            backBody: String(localized: "Both players discard two cards to the dealer's crib. The dealer counts the crib after counting their own hand, so dealer discards are both an opportunity and a risk.")
        ),
        Flashcard(
            id: "cards-goal",
            frontTitle: String(localized: "The race"),
            frontSubtitle: String(localized: "Why every point matters"),
            backTitle: String(localized: "Reach 121 first"),
            backBody: String(localized: "Players move pegs along a board with 120 holes plus a final game hole. The first player to reach 121 wins, so a safe point now can matter more than a perfect-looking hand later.")
        ),
    ]

    static let cardQuiz: [QuizQuestion] = [
        QuizQuestion(
            id: "card-quiz-1",
            prompt: String(localized: "How many points does a single combination totaling 15 score?"),
            tiles: [.c(5), .d(10)],
            choices: [String(localized: "1 point"), String(localized: "2 points"), String(localized: "5 points")],
            answerIndex: 1,
            explanation: String(localized: "Each distinct combination totaling 15 scores 2 points.")
        ),
        QuizQuestion(
            id: "card-quiz-2",
            prompt: String(localized: "What value does a queen contribute to a fifteen?"),
            tiles: [.h(12)],
            choices: [String(localized: "10"), String(localized: "12"), String(localized: "0")],
            answerIndex: 0,
            explanation: String(localized: "Jacks, queens, and kings each have a cribbage value of 10, while their ranks stay distinct for pairs and runs.")
        ),
        QuizQuestion(
            id: "card-quiz-3",
            prompt: String(localized: "Who scores the crib?"),
            choices: [String(localized: "The non-dealer"), String(localized: "The dealer"), String(localized: "Whoever cut the starter")],
            answerIndex: 1,
            explanation: String(localized: "The crib belongs to the dealer. Both players contribute two cards to it.")
        ),
        QuizQuestion(
            id: "card-quiz-4",
            prompt: String(localized: "What makes his nobs?"),
            tiles: [.h(11), .h(6)],
            choices: [String(localized: "A jack matching the starter's suit"), String(localized: "Any jack in the hand"), String(localized: "A pair of jacks")],
            answerIndex: 0,
            explanation: String(localized: "His nobs is one point for a jack matching the starter card's suit.")
        ),
        QuizQuestion(
            id: "card-quiz-5",
            prompt: String(localized: "How many cards does each player receive before discarding?"),
            choices: [String(localized: "4"), String(localized: "5"), String(localized: "6")],
            answerIndex: 2,
            explanation: String(localized: "The standard deal gives each player six cards. Each player then discards two to the crib.")
        ),
        QuizQuestion(
            id: "card-quiz-6",
            prompt: String(localized: "Can a run use mixed suits?"),
            tiles: [.c(3), .d(4), .s(5)],
            choices: [String(localized: "Yes"), String(localized: "No, all suits must match"), String(localized: "Only in the crib")],
            answerIndex: 0,
            explanation: String(localized: "Runs use consecutive ranks. The suits can be mixed.")
        ),
        QuizQuestion(
            id: "card-quiz-7",
            prompt: String(localized: "How many points does a pair score?"),
            tiles: [.c(8), .s(8)],
            choices: [String(localized: "1"), String(localized: "2"), String(localized: "4")],
            answerIndex: 1,
            explanation: String(localized: "Two cards of the same rank make one pair worth 2 points.")
        ),
        QuizQuestion(
            id: "card-quiz-8",
            prompt: String(localized: "What is the usual winning hole on a cribbage board?"),
            choices: [String(localized: "31"), String(localized: "61"), String(localized: "121")],
            answerIndex: 2,
            explanation: String(localized: "Cribbage is normally a race to 121 points.")
        ),
        QuizQuestion(
            id: "card-quiz-9",
            prompt: String(localized: "What happens after the two players discard?"),
            choices: [String(localized: "The starter card is cut"), String(localized: "The dealer redeals"), String(localized: "Pegging starts immediately")],
            answerIndex: 0,
            explanation: String(localized: "The non-dealer cuts the deck and the starter card is placed face up before pegging begins.")
        ),
        QuizQuestion(
            id: "card-quiz-10",
            prompt: String(localized: "Which cards all count as 10 for fifteens?"),
            choices: [String(localized: "10s only"), String(localized: "10s and face cards"), String(localized: "All cards above 9 count as their rank")],
            answerIndex: 1,
            explanation: String(localized: "Tens, jacks, queens, and kings each contribute 10 to a fifteen.")
        ),
    ]
}
