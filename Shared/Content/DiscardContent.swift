import Foundation

/// The Discard Room: choose two cards before the crib is made, then compare
/// the decision with a coach explanation.
enum DiscardContent {
    static let strategyCards: [Flashcard] = [
        Flashcard(
            id: "discard-what",
            frontTitle: "What are you choosing?",
            frontSubtitle: "The first decision after the deal",
            backTitle: "Two cards to the crib",
            backBody: "Each player receives six cards and discards exactly two. The four cards you keep are your hand. The dealer adds both discards to the crib."
        ),
        Flashcard(
            id: "discard-dealer",
            frontTitle: "Dealer or pone?",
            frontSubtitle: "The same hand has two different jobs",
            backTitle: "Dealer wants a strong crib",
            backBody: "The dealer scores the crib later, so a dealer can accept a slightly weaker hand when the discarded pair is likely to make a useful crib. The pone tries to starve it."
        ),
        Flashcard(
            id: "discard-five",
            frontTitle: "The dangerous 5",
            frontSubtitle: "A gift worth watching",
            backTitle: "A 5 feeds many cribs",
            backBody: "A 5 pairs with every ten-value card for a fifteen and connects with small cards. As pone, discarding a 5 is often risky unless your hand improves dramatically."
        ),
        Flashcard(
            id: "discard-pair",
            frontTitle: "Keep a pair?",
            frontSubtitle: "Guaranteed points versus flexibility",
            backTitle: "Start with the guaranteed 2",
            backBody: "A pair is already worth 2. Break it only when the replacement creates a much stronger mix of fifteens, runs, or a flush, and account for what the crib will receive."
        ),
        Flashcard(
            id: "discard-run",
            frontTitle: "Connected cards",
            frontSubtitle: "The cards talk to each other",
            backTitle: "Keep cards that make several shapes",
            backBody: "A 4, 5, and 6 can make runs and fifteens. The more combinations a card participates in, the more expensive it is to throw away."
        ),
        Flashcard(
            id: "discard-crib-safety",
            frontTitle: "Starve the opponent",
            frontSubtitle: "Pone's defensive lens",
            backTitle: "Avoid pairs and fifteens",
            backBody: "When you are pone, look at the cards you are giving the dealer. Avoid giving a pair, a 5, or two cards that immediately make 15 together when a similar hand score is available."
        ),
        Flashcard(
            id: "discard-cut",
            frontTitle: "You cannot see the cut",
            frontSubtitle: "Plan for the unknown",
            backTitle: "Prefer broad potential",
            backBody: "The starter is random, so do not build a discard around one miracle card. Favor a hand that already scores and has several useful cuts."
        ),
        Flashcard(
            id: "discard-crib-count",
            frontTitle: "After the discard",
            frontSubtitle: "The decision is not finished",
            backTitle: "Remember what went where",
            backBody: "During the hand count, the same starter joins your hand and the crib. During pegging, the discarded cards are gone, so use the information to estimate what remains."
        ),
    ]

    static let scenarios: [DiscardScenario] = [
        DiscardScenario(
            id: "discard-scenario-1",
            situation: "You are pone. Choose 2 cards to discard.",
            deal: [.c(2), .d(3), .h(4), .s(5), .c(10), .d(13)],
            recommendedDiscard: [.c(10), .d(13)],
            reasoning: "Keep 2-3-4-5 for a run of four. Trading the 5 away would be worse: it is the single most useful card in the deck, and as pone every card you throw lands in the dealer's crib. The 10 and king neither pair nor make fifteen together, so they are the cheapest pair to give up.",
            tip: "As pone, judge a discard by what it gives the dealer, not only by what it costs you."
        ),
        DiscardScenario(
            id: "discard-scenario-2",
            situation: "You are the dealer. Choose 2 cards to discard.",
            deal: [.c(5), .d(5), .h(6), .s(7), .c(10), .d(12)],
            recommendedDiscard: [.h(6), .s(7)],
            reasoning: "Keep 5-5-10-Q. Each 5 makes fifteen with the 10 and again with the queen, so that is four fifteens for 8, plus 2 for the pair: 10 points before the cut. The 6 and 7 are not wasted either, because they make fifteen together in your own crib.",
            tip: "As dealer, evaluate the hand and the crib together."
        ),
        DiscardScenario(
            id: "discard-scenario-3",
            situation: "You are pone. A flush is available. Choose 2 cards.",
            deal: [.h(2), .h(5), .h(8), .h(11), .c(4), .s(9)],
            recommendedDiscard: [.c(4), .s(9)],
            reasoning: "Keeping the four hearts preserves a four-card flush and gives the starter a chance to extend it. The off-suit 4 and 9 do not create a stronger structure together, and neither is an appealing gift as a pair.",
            tip: "Four cards of one suit are already a meaningful hand feature."
        ),
        DiscardScenario(
            id: "discard-scenario-4",
            situation: "You are the dealer. Where does the pair do the most work?",
            deal: [.c(7), .d(7), .h(3), .s(4), .c(5), .d(10)],
            recommendedDiscard: [.c(7), .d(7)],
            reasoning: "Keeping the 7s scores 2 and almost nothing else, because 7-7-4-5 makes no fifteen and no run. Put the pair in your own crib instead: it still scores 2 there, and 3-4-5-10 keeps a run, the 5-10 fifteen, and the widest set of helpful cuts.",
            tip: "A dealer's own crib is a safe home for a pair that does not fit the hand."
        ),
        DiscardScenario(
            id: "discard-scenario-5",
            situation: "You are pone. Which two cards starve the crib best?",
            deal: [.c(2), .d(5), .h(6), .s(8), .c(9), .d(13)],
            recommendedDiscard: [.c(2), .s(8)],
            reasoning: "Keep 5-6-9-K for two fifteens: 6 with 9, and 5 with the king. Throwing the 2 and the 8 gives the dealer two cards that neither pair nor reach fifteen together, and it keeps the 5 out of the crib.",
            tip: "For the pone, crib defense is part of your score."
        ),
        DiscardScenario(
            id: "discard-scenario-6",
            situation: "You are the dealer. Keep the double run alive.",
            deal: [.c(4), .d(4), .h(5), .s(6), .c(9), .d(12)],
            recommendedDiscard: [.c(9), .d(12)],
            reasoning: "The two 4s with 5 and 6 make a double run of three. The 9 and queen are isolated from that shape and do not form a useful pair or fifteen with each other.",
            tip: "Duplicate ranks can multiply a run, so sort before discarding."
        ),
        DiscardScenario(
            id: "discard-scenario-7",
            situation: "You are the dealer with a high-card-heavy deal.",
            deal: [.c(10), .d(10), .h(11), .s(12), .c(13), .d(4)],
            recommendedDiscard: [.c(13), .d(4)],
            reasoning: "Keep 10-10-J-Q. The second 10 lets 10-jack-queen form twice, a double run of three for 6, plus 2 for the pair. Dropping the king breaks nothing, because 10-jack-queen-king would only be a single run of four, and the 4 connects to nothing here.",
            tip: "Ten-value cards make few fifteens, but they still pair and run by rank."
        ),
        DiscardScenario(
            id: "discard-scenario-8",
            situation: "You are the dealer and the board is tight. Choose two.",
            deal: [.c(3), .d(4), .h(5), .s(7), .c(8), .d(10)],
            recommendedDiscard: [.s(7), .c(8)],
            reasoning: "The 3-4-5 block plus a ten-value card is the most connected hand here: a run of three and the 5-10 fifteen, with many helpful cuts. The 7 and 8 are not a loss either, because they already make fifteen in your own crib.",
            tip: "The board can make a safe, countable hand the best hand."
        ),
    ]
}
