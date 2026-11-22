import Foundation

/// One looked-up term. Kept short: it is read at the board with a hand in
/// front of you, not studied.
struct GlossaryTerm: Identifiable, Sendable {
    let id: String
    let term: String
    /// Other names a player might search for. Never shown, only matched, so
    /// "nibs" finds His heels.
    let aliases: [String]
    let group: GlossaryGroup
    let definition: String

    init(id: String, term: String, aliases: [String] = [], group: GlossaryGroup, definition: String) {
        self.id = id
        self.term = term
        self.aliases = aliases
        self.group = group
        self.definition = definition
    }

    func matches(_ query: String) -> Bool {
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !needle.isEmpty else { return true }
        if term.lowercased().contains(needle) { return true }
        if aliases.contains(where: { $0.lowercased().contains(needle) }) { return true }
        return definition.lowercased().contains(needle)
    }
}

enum GlossaryGroup: String, CaseIterable, Identifiable, Sendable {
    case deal
    case counting
    case pegging
    case game

    var id: String { rawValue }

    var title: String {
        switch self {
        case .deal: return "The Deal"
        case .counting: return "Counting a Hand"
        case .pegging: return "Pegging"
        case .game: return "The Game"
        }
    }

    var icon: String {
        switch self {
        case .deal: return "rectangle.stack.fill"
        case .counting: return "plus.forwardslash.minus"
        case .pegging: return "mappin.and.ellipse"
        case .game: return "flag.checkered"
        }
    }
}

/// The two-player glossary. Point values follow the American Cribbage
/// Congress rules; `ReferenceContentTests` checks every number quoted here
/// against `HandScoring`, the engine the drills grade with.
enum ReferenceContent {
    static func terms(in group: GlossaryGroup, matching query: String = "") -> [GlossaryTerm] {
        glossary.filter { $0.group == group && $0.matches(query) }
    }

    static let glossary: [GlossaryTerm] = [
        // MARK: The deal
        GlossaryTerm(
            id: "g-dealer", term: "Dealer", group: .deal,
            definition: "Deals six cards to each player, owns the crib, and plays second in pegging. The deal alternates every hand. To start a game, each player cuts the deck and the lower card deals, with aces low."
        ),
        GlossaryTerm(
            id: "g-pone", term: "Pone", aliases: ["non-dealer"], group: .deal,
            definition: "The non-dealer. Pone plays the first card in pegging and counts first, which can win a close game before the dealer gets to count."
        ),
        GlossaryTerm(
            id: "g-discard", term: "Discard", aliases: ["throw", "lay away", "toss"], group: .deal,
            definition: "After the deal, each player puts two cards face down into the crib and keeps four. Feed your own crib cards that score together; give your opponent's crib cards that score little."
        ),
        GlossaryTerm(
            id: "g-crib", term: "Crib", aliases: ["kitty", "box"], group: .deal,
            definition: "The extra four-card hand made from both players' discards. It belongs to the dealer and is counted last, with the starter, after both hands."
        ),
        GlossaryTerm(
            id: "g-starter", term: "Starter", aliases: ["cut", "turn-up", "turn card", "upcard"], group: .deal,
            definition: "After the discards, pone cuts the deck and the dealer turns the top card face up. It counts as a fifth card for both hands and the crib, but is never played."
        ),
        GlossaryTerm(
            id: "g-heels", term: "His heels", aliases: ["two for his heels", "nibs", "jack cut"], group: .deal,
            definition: "When the starter is a jack, the dealer pegs 2 right away."
        ),

        // MARK: Counting
        GlossaryTerm(
            id: "g-fifteen", term: "Fifteen", aliases: ["15", "fifteen two"], group: .counting,
            definition: "Every different combination of cards that adds up to 15 scores 2. Face cards count 10 and aces 1. Count them aloud: fifteen two, fifteen four."
        ),
        GlossaryTerm(
            id: "g-pair", term: "Pair", group: .counting,
            definition: "Two cards of the same rank score 2. Every pair counts, so three of a kind holds three pairs and four of a kind holds six."
        ),
        GlossaryTerm(
            id: "g-pair-royal", term: "Pair royal", aliases: ["three of a kind", "trips", "triplet"], group: .counting,
            definition: "Three cards of the same rank: three pairs, 6 points. Four of a kind, a double pair royal, scores 12."
        ),
        GlossaryTerm(
            id: "g-run", term: "Run", aliases: ["sequence", "straight"], group: .counting,
            definition: "Three or more cards in rank order, any suits, score 1 per card. Aces are always low, so Q-K-A is not a run."
        ),
        GlossaryTerm(
            id: "g-double-run", term: "Double run", group: .counting,
            definition: "A run with one rank held twice, like 4-5-5-6: two runs of three plus a pair, 8 before fifteens."
        ),
        GlossaryTerm(
            id: "g-triple-run", term: "Triple run", group: .counting,
            definition: "A run with one rank held three times, like 3-3-3-4-5: three runs of three plus a pair royal, 15 before fifteens."
        ),
        GlossaryTerm(
            id: "g-double-double-run", term: "Double double run", aliases: ["quadruple run"], group: .counting,
            definition: "A run with two ranks each held twice, like 3-3-4-4-5: four runs of three plus two pairs, 16 before fifteens."
        ),
        GlossaryTerm(
            id: "g-flush", term: "Flush", group: .counting,
            definition: "Four hand cards of one suit score 4, or 5 when the starter matches too. In the crib, only a five-card flush counts."
        ),
        GlossaryTerm(
            id: "g-nobs", term: "His nobs", aliases: ["nobs", "nob", "one for his nob", "right jack"], group: .counting,
            definition: "A jack in a hand or the crib that matches the starter's suit scores 1."
        ),
        GlossaryTerm(
            id: "g-counting-order", term: "Counting order", aliases: ["the show", "show"], group: .counting,
            definition: "After pegging, pone counts first, then the dealer's hand, then the crib. Points peg as they are counted, so the first to reach 121 wins even if the other has more to count."
        ),
        GlossaryTerm(
            id: "g-29", term: "29 hand", aliases: ["perfect hand", "twenty-nine"], group: .counting,
            definition: "The highest possible hand: three fives and the jack of the fourth suit, with the fourth five cut as the starter."
        ),
        GlossaryTerm(
            id: "g-19", term: "19 hand", aliases: ["zero hand", "nineteen"], group: .counting,
            definition: "Table slang for a hand worth nothing, because no hand can score exactly 19."
        ),
        GlossaryTerm(
            id: "g-muggins", term: "Muggins", group: .counting,
            definition: "An optional rule: when a player undercounts, the opponent may call muggins and peg the missed points. Agree on it before the game."
        ),

        // MARK: Pegging
        GlossaryTerm(
            id: "g-pegging", term: "Pegging", aliases: ["the play", "play"], group: .pegging,
            definition: "Players take turns laying one card face up and calling the running total, which may not pass 31. Fifteens, pairs and runs made on the table peg at once."
        ),
        GlossaryTerm(
            id: "g-peg-fifteen", term: "Fifteen in play", group: .pegging,
            definition: "Playing a card that brings the count to exactly 15 pegs 2."
        ),
        GlossaryTerm(
            id: "g-thirty-one", term: "Thirty-one", aliases: ["31"], group: .pegging,
            definition: "Playing a card that brings the count to exactly 31 pegs 2. The count then starts again from zero."
        ),
        GlossaryTerm(
            id: "g-go", term: "Go", group: .pegging,
            definition: "Say go when every card you hold would push the count past 31. Your opponent plays on while they can, and whoever plays the last card under 31 pegs 1. Then the count starts again."
        ),
        GlossaryTerm(
            id: "g-last-card", term: "Last card", aliases: ["one for last"], group: .pegging,
            definition: "The player who lays the final card of the play pegs 1, or 2 if it makes exactly 31."
        ),
        GlossaryTerm(
            id: "g-peg-pairs", term: "Pairs in play", group: .pegging,
            definition: "Matching the rank of the card just played pegs 2. A third in a row pegs 6 and a fourth pegs 12."
        ),
        GlossaryTerm(
            id: "g-peg-runs", term: "Runs in play", group: .pegging,
            definition: "When the last three or more cards played form a run in any order, peg 1 per card: 4, 6, 5 pegs 3. Only cards played since the count last reset can count."
        ),

        // MARK: The game
        GlossaryTerm(
            id: "g-121", term: "Game", aliases: ["121", "game hole"], group: .game,
            definition: "The first player to 121 points wins, the moment they reach it, even in the middle of pegging or counting."
        ),
        GlossaryTerm(
            id: "g-board", term: "Pegs and board", aliases: ["peg", "board", "leapfrog"], group: .game,
            definition: "Each player moves two pegs, jumping the back peg past the front one by the points scored, so the gap between them always shows the last score."
        ),
        GlossaryTerm(
            id: "g-skunk", term: "Skunk", group: .game,
            definition: "Winning while the loser is still at 90 or below. Many players count it as two games, and a double skunk, with the loser at 60 or below, as more."
        ),
    ]
}
