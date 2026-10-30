import Foundation

/// The Decision Room: quick keep-or-discard instincts before a full hand count.
enum KeepDiscardContent {
    static let judgmentCards: [Flashcard] = [
        Flashcard(
            id: "decision-keep-five",
            frontTitle: String(localized: "Six cards: keep the 5"),
            frontTiles: [.c(5), .d(10), .h(2), .s(8), .c(11), .d(4)],
            frontSubtitle: String(localized: "Which card is the anchor?"),
            backTitle: String(localized: "Protect the 5"),
            backBody: String(localized: "A 5 connects with every ten-value card for a fifteen and is one of the most valuable cards to keep. Discard the card that creates the fewest combinations with the rest of the hand."),
            choice: CardChoice(String(localized: "Keep the 5"), String(localized: "Discard the 5"), answerIndex: 0)
        ),
        Flashcard(
            id: "decision-dealer-crib",
            frontTitle: String(localized: "You are the dealer"),
            frontTiles: [.c(2), .d(3), .h(7), .s(8), .c(10), .d(12)],
            frontSubtitle: String(localized: "The crib changes the tradeoff"),
            backTitle: String(localized: "Build your own crib"),
            backBody: String(localized: "As dealer, you count both your hand and the crib. When two keeps have equal value, favor the discard with more crib potential. The pone does not score your crib."),
            choice: CardChoice(String(localized: "Build hand plus crib"), String(localized: "Avoid points in your own crib"), answerIndex: 0)
        ),
        Flashcard(
            id: "decision-pone-danger",
            frontTitle: String(localized: "You are the pone"),
            frontTiles: [.c(4), .d(5), .h(6), .s(10), .c(13), .d(2)],
            frontSubtitle: String(localized: "The dealer owns your discards"),
            backTitle: String(localized: "Do not feed the crib"),
            backBody: String(localized: "As pone, the crib belongs to the dealer. A discard that is fine for your own hand may still cost you if the two cards pair, make fifteen together, or include a 5."),
            choice: CardChoice(String(localized: "Minimize crib help"), String(localized: "Maximize only your hand"), answerIndex: 0)
        ),
        Flashcard(
            id: "decision-pair",
            frontTitle: String(localized: "A natural pair"),
            frontTiles: [.c(8), .d(8), .h(3), .s(5), .c(10), .d(13)],
            frontSubtitle: String(localized: "The obvious points"),
            backTitle: String(localized: "Pairs are sturdy"),
            backBody: String(localized: "A pair guarantees 2 points before the cut. Do not break it casually just to chase a speculative run unless the complete hand shape makes the trade worthwhile."),
            choice: CardChoice(String(localized: "Keep the pair"), String(localized: "Break the pair automatically"), answerIndex: 0)
        ),
        Flashcard(
            id: "decision-run",
            frontTitle: String(localized: "Three in sequence"),
            frontTiles: [.c(4), .d(5), .h(6), .s(9), .c(12), .d(2)],
            frontSubtitle: String(localized: "A run has room to grow"),
            backTitle: String(localized: "Keep connected ranks"),
            backBody: String(localized: "A 4-5-6 run is already 3 points. Cards that extend it or create fifteens are valuable, while an isolated queen offers fewer connections here."),
            choice: CardChoice(String(localized: "Keep the 4-5-6 shape"), String(localized: "Keep the isolated queen"), answerIndex: 0)
        ),
        Flashcard(
            id: "decision-suited",
            frontTitle: String(localized: "Four hearts"),
            frontTiles: [.h(2), .h(6), .h(9), .h(12), .c(4), .s(7)],
            frontSubtitle: String(localized: "A cut can matter"),
            backTitle: String(localized: "A four-card flush is real value"),
            backBody: String(localized: "Four matching suits score 4 in the hand, and a matching starter would make 5. Keep the suited block when the other cards do not offer a clearly stronger structure."),
            choice: CardChoice(String(localized: "Preserve the hearts"), String(localized: "Ignore the suits"), answerIndex: 0)
        ),
        Flashcard(
            id: "decision-ten-five",
            frontTitle: String(localized: "The ten-value connection"),
            frontTiles: [.c(5), .d(10), .h(7), .s(8), .c(2), .d(13)],
            frontSubtitle: String(localized: "One small card, many outcomes"),
            backTitle: String(localized: "A 5 is rarely dead"),
            backBody: String(localized: "The 5 already makes a fifteen with the 10 and king. It can also connect with small ranks into runs, so it is usually a keeper in a close choice."),
            choice: CardChoice(String(localized: "Keep the 5"), String(localized: "Keep the disconnected 2"), answerIndex: 0)
        ),
        Flashcard(
            id: "decision-endgame",
            frontTitle: String(localized: "You are near the finish"),
            frontTiles: [.c(2), .d(4), .h(5), .s(7), .c(9), .d(10)],
            frontSubtitle: String(localized: "The board changes your priorities"),
            backTitle: String(localized: "Count the board, not just the cards"),
            backBody: String(localized: "When either player is close to 121, a conservative discard and safe pegging line can beat a higher theoretical hand. Cribbage is a race, not only a counting puzzle."),
            choice: CardChoice(String(localized: "Choose the safer line"), String(localized: "Always chase the biggest hand"), answerIndex: 0)
        ),
    ]
}
