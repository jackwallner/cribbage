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
        guard hand.count == 4 else { return 0 }
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
    /// This is a uniform random-discard model, not a prediction of an
    /// opponent's strategy. Include nobs and crib flushes as well as ranks.
    static func averageCrib(discard: [PlayingCard], dead: [PlayingCard]) -> Double {
        var live = [Int](repeating: 4, count: 14)
        let excluded = Set(dead + discard)
        for card in excluded { live[card.rankValue] -= 1 }
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
        guard weightSum > 0 else { return 0 }
        let unseen = PlayingCard.standardDeck.filter { !excluded.contains($0) }
        var nobsTotal = 0.0
        for cut in unseen {
            guard case .standard(_, let suit) = cut else { continue }
            let matchingJack = PlayingCard.standard(rank: 11, suit: suit)
            if discard.contains(matchingJack) {
                nobsTotal += 1
            } else if cut != matchingJack && unseen.contains(matchingJack) {
                nobsTotal += 2.0 / Double(unseen.count - 1)
            }
        }
        let nobs = nobsTotal / Double(unseen.count)
        var flush = 0.0
        if discard.count == 2, discard[0].suit == discard[1].suit {
            let suited = unseen.filter { $0.suit == discard[0].suit }.count
            let n = Double(unseen.count)
            flush = 5 * Double(suited * (suited - 1) * (suited - 2)) / (n * (n - 1) * (n - 2))
        }
        return total / weightSum + nobs + flush
    }

    /// A discard's value in the uniform random-discard model: what the four cards kept
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

    /// Equivalent physical-card choices earn the same credit as the coach.
    static func discardMatches(_ chosen: [PlayingCard], scenario: DiscardScenario) -> Int {
        guard chosen.count == 2, Set(chosen).count == 2, chosen.allSatisfy(scenario.deal.contains) else { return 0 }
        if Set(chosen) == Set(scenario.recommendedDiscard) { return 2 }
        let dealer = scenario.situation.lowercased().contains("dealer")
        let expected = discardValue(deal: scenario.deal, discard: scenario.recommendedDiscard, isDealer: dealer)
        let actual = discardValue(deal: scenario.deal, discard: chosen, isDealer: dealer)
        if abs(actual - expected) < 1e-9 { return 2 }
        return chosen.filter(scenario.recommendedDiscard.contains).count
    }
}

extension PlayingCard {
    static let standardDeck: [PlayingCard] = Suit.allCases.flatMap { suit in
        (1...13).map { PlayingCard.standard(rank: $0, suit: suit) }
    }
}
