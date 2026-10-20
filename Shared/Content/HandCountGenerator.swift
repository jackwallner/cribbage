import Foundation

/// Deals "count this hand" questions: four cards plus a starter, graded by
/// `HandScoring`. Zero-point hands are never dealt (players call them
/// "nineteen", which is a different lesson), and the wrong answers are
/// neighbouring totals that a real hand can reach, so a distractor is never
/// obviously impossible.
enum HandCountGenerator {
    /// Totals no cribbage hand can make.
    static let impossibleScores: Set<Int> = [19, 25, 26, 27]
    static let maxScore = 29

    struct Question {
        let hand: [PlayingCard]
        let starter: PlayingCard
        let score: Int
        let choices: [Int]
        let explanation: String
    }

    static func question<R: RandomNumberGenerator>(using generator: inout R) -> Question {
        while true {
            let dealt = Array(PlayingCard.standardDeck.shuffled(using: &generator).prefix(5))
            let hand = Array(dealt.prefix(4))
            let starter = dealt[4]
            let score = HandScoring.score(hand: hand, starter: starter)
            guard score > 0 else { continue }
            let choices = options(for: score, using: &generator)
            return Question(
                hand: hand,
                starter: starter,
                score: score,
                choices: choices,
                explanation: explain(hand: hand, starter: starter)
            )
        }
    }

    /// The right total plus the three nearest other reachable totals, shuffled.
    static func options<R: RandomNumberGenerator>(for score: Int, using generator: inout R) -> [Int] {
        let nearby = (1...maxScore)
            .filter { $0 != score && !impossibleScores.contains($0) && abs($0 - score) <= 4 }
            .shuffled(using: &generator)
            .prefix(3)
        return (nearby + [score]).shuffled(using: &generator)
    }

    static func explain(hand: [PlayingCard], starter: PlayingCard) -> String {
        let all = hand + [starter]
        let parts: [(String, Int)] = [
            ("fifteens", HandScoring.fifteens(all)),
            ("pairs", HandScoring.pairs(all)),
            ("runs", HandScoring.runs(all)),
            ("flush", HandScoring.flush(hand: hand, starter: starter, isCrib: false)),
            ("his nobs", HandScoring.nobs(hand: hand, starter: starter)),
        ].filter { $0.1 > 0 }
        let detail = parts.map { "\($0.0) \($0.1)" }.joined(separator: ", ")
        let total = parts.reduce(0) { $0 + $1.1 }
        return "Count everything with the starter: \(detail). That is \(total) points in all. Count each fifteen, pair and run separately, and remember a flush in the hand needs four matching cards."
    }
}
