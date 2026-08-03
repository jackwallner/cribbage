import Foundation

/// Deals original five-card cribbage hands that foreground one scoring shape.
///
/// The contract is the one the authored hand-match questions keep: of the three
/// categories offered, exactly one is actually present in the cards on screen.
/// Both distractors are shapes the hand genuinely does not contain, so a player
/// who reads the cards correctly is never marked wrong.
///
/// Generated hands are teaching shapes, not copies of any external card or
/// copyrighted content.
enum HandGenerator {
    static let generatableCategories: [HandCategory] = HandCategory.allCases

    /// Every shape actually present in the layout.
    static func presentCategories(_ cards: [PlayingCard]) -> [HandCategory] {
        HandCategory.allCases.filter { $0.isPresent(in: cards) }
    }

    struct GeneratedHand {
        let tiles: [PlayingCard]
        let answer: HandCategory
        let choices: [HandCategory]
        let explanation: String
    }

    // MARK: - Dealing

    private static func fill(_ cards: [PlayingCard], to count: Int, avoiding blocked: Set<Int>) -> [PlayingCard] {
        var result = cards
        var pool = PlayingCard.standardDeck.shuffled()
        while result.count < count, let next = pool.popLast() {
            guard !result.contains(next), !blocked.contains(next.rankValue) else { continue }
            result.append(next)
        }
        return result
    }

    /// The seed ranks plus the ranks on either side, so filler cards cannot
    /// accidentally extend a run or duplicate a rank.
    private static func neighbors(of ranks: [Int]) -> Set<Int> {
        var blocked = Set(ranks)
        for rank in ranks {
            blocked.insert(rank - 1)
            blocked.insert(rank + 1)
        }
        return blocked
    }

    private static func deal(_ target: HandCategory) -> [PlayingCard] {
        switch target {
        case .flushes:
            let suit = Suit.allCases.randomElement() ?? .hearts
            let ranks = Array((1...13).shuffled().prefix(4))
            let suited = ranks.map { PlayingCard.standard(rank: $0, suit: suit) }
            let others = Suit.allCases.filter { $0 != suit }
            let oddRank = (1...13).filter { !ranks.contains($0) }.randomElement() ?? 1
            let odd = PlayingCard.standard(rank: oddRank, suit: others.randomElement() ?? .clubs)
            return suited + [odd]

        case .runs:
            let length = [3, 3, 4, 5].randomElement() ?? 3
            let start = Int.random(in: 1...(14 - length))
            let sequence = Array(start..<(start + length))
            let run = sequence.map { rank in
                PlayingCard.standard(rank: rank, suit: Suit.allCases.randomElement() ?? .clubs)
            }
            return fill(run, to: 5, avoiding: neighbors(of: sequence))

        case .pairs:
            let rank = Int.random(in: 1...13)
            let copies = [2, 2, 3].randomElement() ?? 2
            let pair = Suit.allCases.shuffled().prefix(copies).map {
                PlayingCard.standard(rank: rank, suit: $0)
            }
            return fill(Array(pair), to: 5, avoiding: neighbors(of: [rank]))

        case .nobs:
            let jack = PlayingCard.standard(rank: 11, suit: Suit.allCases.randomElement() ?? .hearts)
            return fill([jack], to: 5, avoiding: neighbors(of: [11]))

        case .fifteens:
            let anchor = [2, 5, 6, 7, 9].randomElement() ?? 5
            let partner = min(15 - anchor, 10)
            guard partner != anchor else { return fill([], to: 5, avoiding: []) }
            let first = PlayingCard.standard(rank: anchor, suit: Suit.allCases.randomElement() ?? .clubs)
            let second = PlayingCard.standard(rank: partner, suit: Suit.allCases.randomElement() ?? .diamonds)
            return fill([first, second], to: 5, avoiding: neighbors(of: [anchor, partner]))
        }
    }

    // MARK: - Question assembly

    static func hand(for target: HandCategory, attempts: Int = 200) -> GeneratedHand? {
        for _ in 0..<attempts {
            let cards = deal(target)
            guard cards.count == 5, Set(cards).count == 5 else { continue }
            let present = presentCategories(cards)
            guard present.contains(target) else { continue }
            let distractors = HandCategory.allCases
                .filter { !present.contains($0) }
                .shuffled()
                .prefix(2)
            guard distractors.count == 2 else { continue }
            return GeneratedHand(
                tiles: cards.racked,
                answer: target,
                choices: (CollectionOfOne(target) + distractors).shuffled(),
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

    // MARK: - Explanations

    static func explain(_ cards: [PlayingCard], answer: HandCategory) -> String {
        switch answer {
        case .flushes:
            let count = HandScoring.longestSuitCount(cards)
            return count == 5
                ? "All five cards share a suit, so the flush alone is 5 points."
                : "Four cards share a suit for a 4-point hand flush, and a matching cut would make it 5."
        case .runs:
            return "The ranks build a run worth \(HandScoring.runs(cards)) points. Suits never matter for a run, and aces stay low."
        case .pairs:
            return "Matching ranks are worth \(HandScoring.pairs(cards)) points here. Three of a rank is three separate pairs, not one score."
        case .fifteens:
            return "Combinations totaling fifteen are worth \(HandScoring.fifteens(cards)) points here. Court cards count 10 and the ace counts 1."
        case .nobs:
            return "The hand holds a jack, so his nobs is live: one point if the cut comes up in that jack's suit."
        }
    }
}
