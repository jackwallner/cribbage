import Foundation

/// Deals "how many points does this play score" pegging questions, graded by
/// `PeggingScoring`. Most questions are chosen to score something, because a
/// stream of zeros teaches nothing, but plays that score nothing still appear
/// so the answer is never assumed.
enum PeggingQuestionGenerator {
    struct Question {
        let pile: [PlayingCard]
        let play: PlayingCard
        let result: PeggingScoring.Result
        let choices: [Int]
        let explanation: String

        var runningTotal: Int { PeggingScoring.runningTotal(pile) }

        /// The narrow skill this question exercises, for mastery stats.
        var topic: String {
            let kinds = [result.fifteen > 0, result.thirtyOne > 0, result.pair > 0, result.run > 0]
            guard kinds.filter({ $0 }).count <= 1 else { return "combo" }
            if result.fifteen > 0 { return "fifteen" }
            if result.thirtyOne > 0 { return "thirtyOne" }
            if result.pair > 0 { return "pair" }
            if result.run > 0 { return "run" }
            return "none"
        }
    }

    private static let wrongAnswerPool = [0, 2, 3, 4, 5, 6, 8, 12]

    static func question<R: RandomNumberGenerator>(using generator: inout R) -> Question {
        while true {
            let size = Int.random(in: 1...5, using: &generator)
            let cards = Array(PlayingCard.standardDeck.shuffled(using: &generator).prefix(size + 1))
            let pile = Array(cards.dropLast())
            let play = cards[size]
            guard let result = PeggingScoring.score(pile: pile, play: play) else { continue }
            let wantsPoints = Int.random(in: 0..<4, using: &generator) != 0
            guard (result.points > 0) == wantsPoints else { continue }
            let wrong = wrongAnswerPool
                .filter { $0 != result.points }
                .shuffled(using: &generator)
                .prefix(3)
            return Question(
                pile: pile,
                play: play,
                result: result,
                choices: (wrong + [result.points]).shuffled(using: &generator),
                explanation: explain(pile: pile, play: play, result: result)
            )
        }
    }

    static func explain(pile: [PlayingCard], play: PlayingCard, result: PeggingScoring.Result) -> String {
        let before = PeggingScoring.runningTotal(pile)
        guard result.points > 0 else {
            return String(localized: "The count goes from \(before) to \(result.total). That is not 15 or 31, the \(play.shortLabel) does not match the card played just before it, and the last cards form no run of three, so you score nothing.")
        }
        return String(localized: "The count goes from \(before) to \(result.total). You score \(result.summary), \(result.points) in all. A pegging run counts the last cards played in any order, and a pair only counts against the card played just before.")
    }
}
