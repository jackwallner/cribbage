import Foundation

/// Points scored by playing one card onto a pegging pile, under standard
/// rules: 15 and 31 are 2 each, a run of the last three or more cards (in any
/// order) scores its length, and a card matching the end of the pile scores
/// 2, 6 or 12 for a pair, pair royal or double pair royal. Go and last-card
/// points depend on the other player's hand, so they are not part of this.
enum PeggingScoring {
    struct Result: Equatable, Sendable {
        let total: Int
        let fifteen: Int
        let thirtyOne: Int
        let pair: Int
        let run: Int

        var points: Int { fifteen + thirtyOne + pair + run }

        /// Plain-language breakdown, e.g. "2 for fifteen and 3 for a run of three".
        var summary: String {
            var parts: [String] = []
            if fifteen > 0 { parts.append("\(fifteen) for making fifteen") }
            if thirtyOne > 0 { parts.append("\(thirtyOne) for making thirty-one") }
            if pair > 0 { parts.append("\(pair) for \(Self.pairName(pair))") }
            if run > 0 { parts.append("\(run) for a run of \(run)") }
            switch parts.count {
            case 0: return "nothing"
            case 1: return parts[0]
            default: return parts.dropLast().joined(separator: ", ") + " and " + parts[parts.count - 1]
            }
        }

        private static func pairName(_ points: Int) -> String {
            switch points {
            case 12: return "a double pair royal"
            case 6: return "a pair royal"
            default: return "a pair"
            }
        }
    }

    static func runningTotal(_ pile: [PlayingCard]) -> Int {
        pile.reduce(0) { $0 + $1.cribbageValue }
    }

    /// Nil when the play would take the count past 31, which is not legal.
    static func score(pile: [PlayingCard], play: PlayingCard) -> Result? {
        let total = runningTotal(pile) + play.cribbageValue
        guard total <= 31 else { return nil }
        let sequence = pile + [play]
        return Result(
            total: total,
            fifteen: total == 15 ? 2 : 0,
            thirtyOne: total == 31 ? 2 : 0,
            pair: pairPoints(sequence),
            run: runPoints(sequence)
        )
    }

    private static func pairPoints(_ sequence: [PlayingCard]) -> Int {
        guard let last = sequence.last else { return 0 }
        let matching = sequence.reversed().prefix { $0.rankValue == last.rankValue }.count
        switch matching {
        case 2: return 2
        case 3: return 6
        case 4: return 12
        default: return 0
        }
    }

    /// The longest tail of the sequence whose ranks are all different and
    /// consecutive once sorted. Aces are low and a run never wraps.
    private static func runPoints(_ sequence: [PlayingCard]) -> Int {
        guard sequence.count >= 3 else { return 0 }
        for length in stride(from: sequence.count, through: 3, by: -1) {
            let ranks = sequence.suffix(length).map(\.rankValue)
            if Set(ranks).count == length, ranks.max()! - ranks.min()! == length - 1 {
                return length
            }
        }
        return 0
    }
}
