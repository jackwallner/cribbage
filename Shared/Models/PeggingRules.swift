import Foundation

/// Standard two-player play scoring. A sequence starts afresh after go or 31.
enum PeggingRules {
    static func legal(_ hand: [PlayingCard], total: Int) -> [PlayingCard] {
        hand.filter { total + $0.cribbageValue <= 31 }
    }

    /// Points made by the final card, excluding a separately awarded last card.
    static func points(_ sequence: [PlayingCard]) -> Int {
        guard let last = sequence.last else { return 0 }
        let total = sequence.reduce(0) { $0 + $1.cribbageValue }
        guard total <= 31 else { return 0 }
        var points = total == 15 || total == 31 ? 2 : 0
        let equal = sequence.reversed().prefix { $0.rankValue == last.rankValue }.count
        points += equal * (equal - 1)
        guard sequence.count >= 3 else { return points }
        for length in stride(from: sequence.count, through: 3, by: -1) {
            let ranks = sequence.suffix(length).map(\.rankValue)
            if Set(ranks).count == length, ranks.max()! - ranks.min()! == length - 1 {
                return points + length
            }
        }
        return points
    }

    static func lastCard(total: Int) -> Int { total == 31 ? 0 : 1 }
    static func heels(_ starter: PlayingCard) -> Int { starter.rankValue == 11 ? 2 : 0 }

    enum ScoreKind { case play, hand, crib, heels, penalty, muggins, backward }

    /// ACC Rule 10. Called only after the opponent finishes pegging.
    static func muggins(earned: Int, pegged: Int, enabled: Bool, kind: ScoreKind) -> Int {
        guard enabled, kind == .play || kind == .hand || kind == .crib else { return 0 }
        return max(0, earned - pegged)
    }
}
