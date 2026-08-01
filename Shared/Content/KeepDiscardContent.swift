import Foundation

/// The Decision Room: quick keep-or-discard instincts before a full hand count.
enum KeepDiscardContent {
    static let judgmentCards: [Flashcard] = [
        Flashcard(
            id: "decision-keep-five",
            frontTitle: "Six cards: keep the 5",
            frontTiles: [.c(5), .d(10), .h(2), .s(8), .c(11), .d(4)],
            frontSubtitle: "Which card is the anchor?",
            backTitle: "Protect the 5",
            backBody: "A 5 connects with every ten-value card for a fifteen and is one of the most valuable cards to keep. Discard the card that creates the fewest combinations with the rest of the hand.",
            choice: CardChoice("Keep the 5", "Discard the 5", answerIndex: 0)
        ),
        Flashcard(
            id: "decision-dealer-crib",
            frontTitle: "You are the dealer",
            frontTiles: [.c(2), .d(3), .h(7), .s(8), .c(10), .d(12)],
            frontSubtitle: "The crib changes the tradeoff",
            backTitle: "Avoid gifting connected cards",
            backBody: "As dealer, you want your hand and crib to score. When two discards help your hand equally, prefer the pair that is less likely to give the pone a fifteen or run in the crib.",
            choice: CardChoice("Protect your hand first", "Give away your best fifteen cards", answerIndex: 0)
        ),
        Flashcard(
            id: "decision-pone-danger",
            frontTitle: "You are the pone",
            frontTiles: [.c(4), .d(5), .h(6), .s(10), .c(13), .d(2)],
            frontSubtitle: "The dealer owns your discards",
            backTitle: "Do not feed the crib",
            backBody: "As pone, the crib belongs to the dealer. A discard that is fine for your own hand may be dangerous if it pairs a card already likely to land in the crib.",
            choice: CardChoice("Minimize crib help", "Maximize only your hand", answerIndex: 0)
        ),
        Flashcard(
            id: "decision-pair",
            frontTitle: "A natural pair",
            frontTiles: [.c(8), .d(8), .h(3), .s(5), .c(10), .d(13)],
            frontSubtitle: "The obvious points",
            backTitle: "Pairs are sturdy",
            backBody: "A pair guarantees 2 points before the cut. Do not break it casually just to chase a speculative run unless the complete hand shape makes the trade worthwhile.",
            choice: CardChoice("Keep the pair", "Break the pair automatically", answerIndex: 0)
        ),
        Flashcard(
            id: "decision-run",
            frontTitle: "Three in sequence",
            frontTiles: [.c(4), .d(5), .h(6), .s(9), .c(12), .d(2)],
            frontSubtitle: "A run has room to grow",
            backTitle: "Keep connected ranks",
            backBody: "A 4-5-6 run is already 3 points. Cards that extend it or create fifteens are valuable, while an isolated queen offers fewer connections here.",
            choice: CardChoice("Keep the 4-5-6 shape", "Keep the isolated queen", answerIndex: 0)
        ),
        Flashcard(
            id: "decision-suited",
            frontTitle: "Four hearts",
            frontTiles: [.h(2), .h(6), .h(9), .h(12), .c(4), .s(7)],
            frontSubtitle: "A cut can matter",
            backTitle: "A four-card flush is real value",
            backBody: "Four matching suits score 4 in the hand, and a matching starter would make 5. Keep the suited block when the other cards do not offer a clearly stronger structure.",
            choice: CardChoice("Preserve the hearts", "Ignore the suits", answerIndex: 0)
        ),
        Flashcard(
            id: "decision-ten-five",
            frontTitle: "The ten-value connection",
            frontTiles: [.c(5), .d(10), .h(7), .s(8), .c(2), .d(13)],
            frontSubtitle: "One small card, many outcomes",
            backTitle: "A 5 is rarely dead",
            backBody: "The 5 already makes a fifteen with the 10 and king. It can also connect with small ranks into runs, so it is usually a keeper in a close choice.",
            choice: CardChoice("Keep the 5", "Keep the disconnected 2", answerIndex: 0)
        ),
        Flashcard(
            id: "decision-endgame",
            frontTitle: "You are near the finish",
            frontTiles: [.c(2), .d(4), .h(5), .s(7), .c(9), .d(10)],
            frontSubtitle: "The board changes your priorities",
            backTitle: "Count the board, not just the cards",
            backBody: "When either player is close to 121, a conservative discard and safe pegging line can beat a higher theoretical hand. Cribbage is a race, not only a counting puzzle.",
            choice: CardChoice("Choose the safer line", "Always chase the biggest hand", answerIndex: 0)
        ),
    ]
}
