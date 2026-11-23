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
        let reachable = (1...maxScore).filter { $0 != score && !impossibleScores.contains($0) }
        var nearby = reachable.filter { abs($0 - score) <= 4 }.shuffled(using: &generator)
        if nearby.count < 3 {
            // 28 and 29 sit above a gap of impossible totals; borrow the next closest.
            nearby += reachable.filter { abs($0 - score) > 4 }.sorted { abs($0 - score) < abs($1 - score) }
        }
        return (Array(nearby.prefix(3)) + [score]).shuffled(using: &generator)
    }

    /// Why a wrong total is wrong: how far off it is and, when one part of
    /// the count is worth exactly the gap, that part. It never claims to
    /// know which part the player missed, only what the gap matches.
    static func missNote(picked: Int, hand: [PlayingCard], starter: PlayingCard) -> String? {
        let all = hand + [starter]
        let score = HandScoring.score(hand: hand, starter: starter)
        guard picked != score else { return nil }
        let gap = abs(score - picked)
        let points = gap == 1 ? "1 point" : "\(gap) points"
        guard picked < score else {
            return "\(picked) is \(points) more than these cards hold. Count each combination once, and a hand flush needs all four hand cards in one suit."
        }
        let fifteens = HandScoring.fifteens(all)
        let pairs = HandScoring.pairs(all)
        let runs = HandScoring.runs(all)
        let flush = HandScoring.flush(hand: hand, starter: starter, isCrib: false)
        let nobs = HandScoring.nobs(hand: hand, starter: starter)
        if nobs == 1, gap == 1 {
            return "\(picked) is 1 point short, exactly his nobs: the jack in hand matches the starter's suit."
        }
        if flush > 0, gap == flush {
            return "\(picked) is \(points) short, exactly the flush: \(flush == 5 ? "all four hand cards and the starter" : "all four hand cards") share a suit."
        }
        if runs > 0, gap == runs {
            return "\(picked) is \(points) short, exactly what the runs are worth. Every run of three or more counts, once for each way it can be made."
        }
        if pairs > 0, gap == pairs {
            return "\(picked) is \(points) short, exactly what the pairs are worth. Every two cards of a rank count 2."
        }
        if fifteens >= gap, gap % 2 == 0 {
            let missed = gap / 2
            return "\(picked) is \(points) short, \(missed == 1 ? "one fifteen's" : "\(missed) fifteens'") worth. These cards make \(fifteens / 2) different fifteens."
        }
        return "\(picked) is \(points) short. Count fifteens, pairs, runs, flush and nobs in turn, with the starter."
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
        let unit = total == 1 ? "point" : "points"
        return "Count everything with the starter: \(detail). That is \(total) \(unit) in all. Count each fifteen, pair and run separately, and remember a flush in the hand needs four matching cards."
    }
}
