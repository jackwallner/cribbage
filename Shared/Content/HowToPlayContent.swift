import Foundation

/// One page of the beginner cribbage primer.
struct HowToPlayPage: Identifiable, Sendable {
    let id: String
    let icon: String
    let title: String
    let body: String
    let tiles: [PlayingCard]
    let tip: String?

    init(id: String, icon: String, title: String, body: String, tiles: [PlayingCard] = [], tip: String? = nil) {
        self.id = id
        self.icon = icon
        self.title = title
        self.body = body
        self.tiles = tiles
        self.tip = tip
    }
}

/// The five-minute primer for players who picked "brand new" in onboarding.
enum HowToPlayContent {
    static let pages: [HowToPlayPage] = [
        HowToPlayPage(
            id: "crib-goal",
            icon: "flag.checkered",
            title: "The goal",
            body: "Cribbage is a race to 121 points. You score by making combinations in your hand and crib, then by playing cards in order during pegging. The first player to reach the finish wins.",
            tiles: [.c(5), .d(10)],
            tip: "A fifteen is any combination of cards totaling 15, worth 2 points."
        ),
        HowToPlayPage(
            id: "crib-deck",
            icon: "suit.club.fill",
            title: "Meet the deck",
            body: "Use a standard 52-card deck. Aces are low and count as 1. Number cards keep their values, while jacks, queens, and kings count as 10 for fifteens.",
            tiles: [.c(1), .d(5), .h(10), .s(13)]
        ),
        HowToPlayPage(
            id: "crib-deal",
            icon: "rectangle.stack.fill",
            title: "Deal and discard",
            body: "Each player receives six cards and discards two to the dealer's crib. The non-dealer cuts the starter card, which joins both hands and the crib for scoring.",
            tiles: [.c(2), .d(4), .h(6), .s(8), .c(10), .d(12)],
            tip: "The dealer wants a strong crib. The pone tries to starve it."
        ),
        HowToPlayPage(
            id: "crib-score",
            icon: "number.circle.fill",
            title: "Count the hand",
            body: "Score every combination of 15, then pairs, runs, and flushes. Add one for his nobs when a jack matches the starter's suit. The same starter card can create several bonuses at once.",
            tiles: [.c(4), .d(5), .h(6)],
            tip: "Count in the same order every time so your points do not disappear."
        ),
        HowToPlayPage(
            id: "crib-pegging",
            icon: "arrow.up.right.circle.fill",
            title: "Peg the cards",
            body: "After the starter is cut, players alternate playing one card while keeping the running total at or below 31. Score for 15, pairs, runs, 31, go, and the last card.",
            tiles: [.c(4), .d(6), .h(10)],
            tip: "Say the running total out loud. It is the center of every pegging decision."
        ),
        HowToPlayPage(
            id: "crib-ready",
            icon: "checkmark.seal.fill",
            title: "You are ready",
            body: "That is the whole loop: choose a discard, peg carefully, count every combination, and keep an eye on the board. The drills teach each skill one room at a time, five minutes at a stretch."
        ),
    ]

    /// Maps the onboarding skill level to a useful first room.
    static func recommendedRoom(forSkillLevel skillLevel: String) -> Room {
        let roomID: String
        switch skillLevel {
        case "basics": roomID = "scoring-room"
        case "played": roomID = "discard-room"
        default: roomID = "card-room"
        }
        return DrillLibrary.rooms.first { $0.id == roomID } ?? DrillLibrary.rooms[0]
    }
}
