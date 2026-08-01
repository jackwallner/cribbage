import Foundation

/// Deals original five-card cribbage hands that foreground one scoring idea.
/// Generated hands are teaching shapes, not copies of any external card or
/// copyrighted content.
enum HandGenerator {
    static let generatableCategories: [HandCategory] = [.fifteens, .pairs, .runs, .flushes]

    private static func ranks(_ cards: [PlayingCard]) -> [Int] {
        cards.compactMap { card in
            if case .standard(let rank, _) = card { return rank }
            return nil
        }
    }

    private static func suits(_ cards: [PlayingCard]) -> [Suit] {
        cards.compactMap { card in
            if case .standard(_, let suit) = card { return suit }
            return nil
        }
    }

    private static func hasFifteen(_ cards: [PlayingCard]) -> Bool {
        let values = cards.map(\.cribbageValue)
        for mask in 1..<(1 << values.count) {
            var total = 0
            for index in values.indices where mask & (1 << index) != 0 {
                total += values[index]
            }
            if total == 15 { return true }
        }
        return false
    }

    private static func hasPair(_ cards: [PlayingCard]) -> Bool {
        let values = ranks(cards)
        return Set(values).count < values.count
    }

    private static func hasRun(_ cards: [PlayingCard]) -> Bool {
        let values = Set(ranks(cards)).sorted()
        guard values.count == cards.count, let low = values.first, let high = values.last else { return false }
        return high - low == values.count - 1
    }

    private static func hasFlush(_ cards: [PlayingCard]) -> Bool {
        let values = suits(cards)
        return values.count == cards.count && Set(values).count == 1
    }

    /// The precedence makes generated answer choices mutually exclusive. A
    /// hand may contain several real scoring patterns, but the question gives
    /// the player one deliberately chosen teaching read.
    static func fits(_ cards: [PlayingCard], _ category: HandCategory) -> Bool {
        switch category {
        case .flushes:
            return hasFlush(cards)
        case .runs:
            return !hasFlush(cards) && hasRun(cards)
        case .pairs:
            return !hasFlush(cards) && !hasRun(cards) && hasPair(cards)
        case .fifteens:
            return !hasFlush(cards) && !hasRun(cards) && !hasPair(cards) && hasFifteen(cards)
        default:
            return false
        }
    }

    static func category(for cards: [PlayingCard]) -> HandCategory? {
        let matches = generatableCategories.filter { fits(cards, $0) }
        return matches.count == 1 ? matches[0] : nil
    }

    struct GeneratedHand {
        let tiles: [PlayingCard]
        let answer: HandCategory
        let choices: [HandCategory]
        let explanation: String
    }

    private static func uniqueCards(count: Int, ranks: [Int], suit: Suit? = nil) -> [PlayingCard] {
        let suits = suit.map { [$0] } ?? Suit.allCases
        var result: [PlayingCard] = []
        for rank in ranks {
            guard let selectedSuit = suits.shuffled().first(where: { candidate in
                !result.contains(.standard(rank: rank, suit: candidate))
            }) else { continue }
            result.append(.standard(rank: rank, suit: selectedSuit))
            if result.count == count { break }
        }
        return result
    }

    private static func deal(_ targetCategory: HandCategory) -> [PlayingCard]? {
        switch targetCategory {
        case .flushes:
            let suit = Suit.allCases.randomElement() ?? .hearts
            for _ in 0..<40 {
                let cards = uniqueCards(count: 5, ranks: (1...13).shuffled(), suit: suit)
                if cards.count == 5 && Self.category(for: cards) == .flushes { return cards }
            }
        case .runs:
            for _ in 0..<40 {
                let start = Int.random(in: 1...9)
                let cards = uniqueCards(count: 5, ranks: Array(start...(start + 4)))
                if cards.count == 5 && Self.category(for: cards) == .runs { return cards }
            }
        case .pairs:
            for _ in 0..<80 {
                let pairRank = Int.random(in: 1...13)
                let otherRanks = (1...13).filter { $0 != pairRank }.shuffled()
                guard let first = otherRanks.first, let second = otherRanks.dropFirst().first, let third = otherRanks.dropFirst(2).first else { continue }
                let pairSuit = Suit.allCases.shuffled().prefix(2)
                let cards = [
                    .standard(rank: pairRank, suit: pairSuit[0]),
                    .standard(rank: pairRank, suit: pairSuit[1]),
                ] + uniqueCards(count: 3, ranks: [first, second, third])
                if cards.count == 5 && Self.category(for: cards) == .pairs { return cards }
            }
        case .fifteens:
            for _ in 0..<100 {
                let ranks = [5, 10, 1, 2, 7].shuffled()
                let cards = uniqueCards(count: 5, ranks: ranks)
                if cards.count == 5 && Self.category(for: cards) == .fifteens { return cards }
            }
        default:
            break
        }
        return nil
    }

    static func hand(for target: HandCategory, attempts: Int = 120) -> GeneratedHand? {
        for _ in 0..<attempts {
            guard let cards = deal(target), category(for: cards) == target else { continue }
            let distractors = generatableCategories
                .filter { $0 != target && !fits(cards, $0) }
                .shuffled()
                .prefix(3)
            guard distractors.count >= 2 else { continue }
            return GeneratedHand(
                tiles: cards.racked,
                answer: target,
                choices: ([target] + distractors).shuffled(),
                explanation: explain(cards, answer: target)
            )
        }
        return nil
    }

    static func batch(count: Int) -> [GeneratedHand] {
        var targets: [HandCategory] = []
        while targets.count < count {
            targets += generatableCategories.shuffled()
        }
        return targets.prefix(count).compactMap { hand(for: $0) }.shuffled()
    }

    static func explain(_ cards: [PlayingCard], answer: HandCategory) -> String {
        let labels = ranks(cards).sorted().map(String.init).joined(separator: ", ")
        switch answer {
        case .flushes:
            return "All five cards share a suit. That is a flush shape, so start with the suit bonus before checking the other combinations."
        case .runs:
            return "The ranks form a consecutive sequence (\(labels)). The suits are mixed, so the run is the strongest first read."
        case .pairs:
            return "Two cards share a rank, while the hand is not a flush or a clean run. Start with the guaranteed pair and then search for fifteens."
        case .fifteens:
            return "At least one combination totals 15, and no pair, run, or flush dominates the shape. Search the small cards and ten-value cards systematically."
        default:
            return answer.howToSpot
        }
    }
}
