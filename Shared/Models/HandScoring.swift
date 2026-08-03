import Foundation

/// Standard cribbage scoring for a four-card hand plus an optional starter.
/// The app uses it to keep authored content honest: every teaching hand, every
/// hand-match answer, and every recommended discard is checked against these
/// rules rather than against prose.
///
/// House rules vary at the edges, so the two variable rules are explicit:
/// a hand flush needs four cards of one suit (five with a matching starter),
/// while a crib flush needs all five. Aces are low, and a run never wraps.
enum HandScoring {

    // MARK: - Components

    /// 2 points for every distinct combination of cards totaling fifteen.
    static func fifteens(_ cards: [PlayingCard]) -> Int {
        let values = cards.map(\.cribbageValue)
        guard values.count < 31 else { return 0 }
        var total = 0
        for mask in 1..<(1 << values.count) {
            var sum = 0
            for index in values.indices where mask & (1 << index) != 0 {
                sum += values[index]
            }
            if sum == 15 { total += 2 }
        }
        return total
    }

    /// 2 points per pair, counting every distinct pair of matching ranks.
    static func pairs(_ cards: [PlayingCard]) -> Int {
        var counts: [Int: Int] = [:]
        for card in cards { counts[card.rankValue, default: 0] += 1 }
        return counts.values.reduce(0) { $0 + $1 * ($1 - 1) }
    }

    /// One point per card in the longest run of three or more, multiplied by
    /// the number of ways duplicate ranks let that run be formed.
    static func runs(_ cards: [PlayingCard]) -> Int {
        var counts: [Int: Int] = [:]
        for card in cards { counts[card.rankValue, default: 0] += 1 }
        let ranks = counts.keys.sorted()
        guard ranks.count >= 3 else { return 0 }
        for length in stride(from: ranks.count, through: 3, by: -1) {
            var total = 0
            for start in 0...(ranks.count - length) {
                let window = Array(ranks[start..<(start + length)])
                guard window[length - 1] - window[0] == length - 1 else { continue }
                total += length * window.reduce(1) { $0 * (counts[$1] ?? 0) }
            }
            if total > 0 { return total }
        }
        return 0
    }

    /// How many cards share the most common suit in the layout.
    static func longestSuitCount(_ cards: [PlayingCard]) -> Int {
        var counts: [Suit: Int] = [:]
        for card in cards {
            if case .standard(_, let suit) = card { counts[suit, default: 0] += 1 }
        }
        return counts.values.max() ?? 0
    }

    /// A hand flush is 4 for four matching cards, 5 when the starter matches.
    /// A crib flush scores only when all five cards match.
    static func flush(hand: [PlayingCard], starter: PlayingCard?, isCrib: Bool) -> Int {
        var suits: Set<Suit> = []
        for card in hand {
            guard case .standard(_, let suit) = card else { return 0 }
            suits.insert(suit)
        }
        guard suits.count == 1, let suit = suits.first else { return 0 }
        if let starter, case .standard(_, let starterSuit) = starter, starterSuit == suit {
            return 5
        }
        return isCrib ? 0 : 4
    }

    /// One point for a jack in the hand whose suit matches the starter.
    static func nobs(hand: [PlayingCard], starter: PlayingCard?) -> Int {
        guard let starter, case .standard(_, let starterSuit) = starter else { return 0 }
        let match = hand.contains { card in
            if case .standard(let rank, let suit) = card { return rank == 11 && suit == starterSuit }
            return false
        }
        return match ? 1 : 0
    }

    // MARK: - Totals

    /// The full count for a hand, with or without the starter card.
    static func score(hand: [PlayingCard], starter: PlayingCard? = nil, isCrib: Bool = false) -> Int {
        let all = hand + (starter.map { [$0] } ?? [])
        return fifteens(all)
            + pairs(all)
            + runs(all)
            + flush(hand: hand, starter: starter, isCrib: isCrib)
            + nobs(hand: hand, starter: starter)
    }

    /// The average count across every starter still live once the six dealt
    /// cards are known. This is the number the discard coach is graded on.
    static func averageWithCut(hand: [PlayingCard], dead: [PlayingCard]) -> Double {
        let excluded = Set(hand + dead)
        let live = PlayingCard.standardDeck.filter { !excluded.contains($0) }
        guard !live.isEmpty else { return 0 }
        let total = live.reduce(0) { $0 + score(hand: hand, starter: $1) }
        return Double(total) / Double(live.count)
    }

    // MARK: - Discard value

    /// Fifteens, pairs, and runs for a bare list of ranks. Suit-dependent
    /// scoring is deliberately excluded; the caller supplies it separately.
    private static func rankOnlyScore(_ ranks: [Int]) -> Int {
        let cards = ranks.map { PlayingCard.standard(rank: $0, suit: .clubs) }
        return fifteens(cards) + pairs(cards) + runs(cards)
    }

    /// What a two-card discard is worth once it lands in a crib, averaged over
    /// every opponent discard pair and every starter, weighted by how many
    /// copies of each rank are still live.
    ///
    /// The one term this leaves out is the five-card crib flush, which needs
    /// all four crib cards and the starter in a single suit. It is worth well
    /// under a tenth of a point and cannot reorder a discard choice.
    static func averageCrib(discard: [PlayingCard], dead: [PlayingCard]) -> Double {
        var live = [Int](repeating: 4, count: 14)
        for card in dead { live[card.rankValue] -= 1 }
        let thrown = discard.map(\.rankValue)
        var total = 0.0
        var weightSum = 0.0
        for first in 1...13 where live[first] > 0 {
            for second in first...13 {
                let pairWeight = first == second
                    ? Double(live[first] * (live[first] - 1)) / 2
                    : Double(live[first] * live[second])
                guard pairWeight > 0 else { continue }
                for cut in 1...13 {
                    let used = (first == cut ? 1 : 0) + (second == cut ? 1 : 0)
                    let cutWeight = live[cut] - used
                    guard cutWeight > 0 else { continue }
                    let weight = pairWeight * Double(cutWeight)
                    total += weight * Double(rankOnlyScore(thrown + [first, second, cut]))
                    weightSum += weight
                }
            }
        }
        return weightSum > 0 ? total / weightSum : 0
    }

    /// A discard's true value: what the four cards you keep are expected to
    /// count, plus what the two you throw are expected to make in the crib if
    /// you are the dealer, or minus it if you are the pone.
    static func discardValue(deal: [PlayingCard], discard: [PlayingCard], isDealer: Bool) -> Double {
        let keep = deal.filter { !discard.contains($0) }
        let hand = averageWithCut(hand: keep, dead: deal)
        let crib = averageCrib(discard: discard, dead: deal)
        return isDealer ? hand + crib : hand - crib
    }

    /// Every two-card discard from a six-card deal, best first.
    static func rankedDiscards(deal: [PlayingCard], isDealer: Bool) -> [(discard: [PlayingCard], value: Double)] {
        var results: [(discard: [PlayingCard], value: Double)] = []
        for i in deal.indices {
            for j in deal.indices where j > i {
                let discard = [deal[i], deal[j]]
                results.append((discard, discardValue(deal: deal, discard: discard, isDealer: isDealer)))
            }
        }
        return results.sorted { $0.value > $1.value }
    }
}

extension PlayingCard {
    static let standardDeck: [PlayingCard] = Suit.allCases.flatMap { suit in
        (1...13).map { PlayingCard.standard(rank: $0, suit: suit) }
    }
}
