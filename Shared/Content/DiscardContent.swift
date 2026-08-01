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
            recommendedDiscard: [.c(2), .d(13)],
            reasoning: "Keep 3-4-5-10: the connected small cards make runs and fifteens, while the 2 and king create fewer useful combinations. As pone, avoid giving the dealer a 5 or a pair.",
            tip: "Protect the 5 and the cards that connect to it."
        ),
        DiscardScenario(
            id: "discard-scenario-2",
            situation: "You are the dealer. Choose 2 cards to discard.",
            deal: [.c(5), .d(5), .h(6), .s(7), .c(10), .d(12)],
            recommendedDiscard: [.c(10), .d(12)],
            reasoning: "Keep the pair of 5s plus 6 and 7. The hand already has a pair, two fifteens with ten-value cards, and a run path. The queen and 10 are useful in the dealer's crib but do not improve the four-card hand as much here.",
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
            situation: "You are the dealer. Choose 2 cards from a paired hand.",
            deal: [.c(7), .d(7), .h(3), .s(4), .c(5), .d(10)],
            recommendedDiscard: [.h(3), .d(10)],
            reasoning: "Keep the pair of 7s and the 4-5 connection. The pair is guaranteed value, and 4-5 can connect with the starter. The 3 and 10 are the least integrated cards in this particular hand.",
            tip: "Do not break guaranteed points without a clear reason."
        ),
        DiscardScenario(
            id: "discard-scenario-5",
            situation: "You are pone. Which two cards starve the crib best?",
            deal: [.c(2), .d(5), .h(6), .s(8), .c(9), .d(13)],
            recommendedDiscard: [.c(2), .d(13)],
            reasoning: "Keep 5-6-8-9, which offers runs and fifteens. Throwing the 2 and king gives the dealer two cards that do not immediately pair or make 15 with each other, while keeping the 5 away from the crib.",
            tip: "For the pone, crib defense is part of your score."
        ),
        DiscardScenario(
            id: "discard-scenario-6",
            situation: "Choose 2 cards while keeping a double run alive.",
            deal: [.c(4), .d(4), .h(5), .s(6), .c(9), .d(12)],
            recommendedDiscard: [.c(9), .d(12)],
            reasoning: "The two 4s with 5 and 6 make a double run of three. The 9 and queen are isolated from that shape and do not form a useful pair or fifteen with each other.",
            tip: "Duplicate ranks can multiply a run, so sort before discarding."
        ),
        DiscardScenario(
            id: "discard-scenario-7",
            situation: "You are the dealer with a high-card-heavy deal.",
            deal: [.c(10), .d(10), .h(11), .s(12), .c(13), .d(4)],
            recommendedDiscard: [.h(11), .d(4)],
            reasoning: "Keep the pair of 10s and the queen and king, then place the jack and 4 in the crib. The pair guarantees points, and the dealer can accept the high-card shape while avoiding a discard pair in the crib.",
            tip: "Ten-value cards have low variety for fifteens but still pair and run by rank."
        ),
        DiscardScenario(
            id: "discard-scenario-8",
            situation: "The board is tight. Choose the safer two-card discard.",
            deal: [.c(3), .d(4), .h(5), .s(7), .c(8), .d(10)],
            recommendedDiscard: [.s(7), .c(8)],
            reasoning: "The 3-4-5 block is the most connected part of the deal, with several run and fifteen possibilities. Keep it and discard the less integrated 7 and 8. In a close race, favor a hand you can count confidently.",
            tip: "The board can make a safe, countable hand the best hand."
        ),
    ]
}
