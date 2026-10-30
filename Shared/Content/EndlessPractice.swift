import Foundation

/// Generated practice skills. Each skill still becomes the same QuickItem
/// shape used by authored drills, so the runner never cares where a question
/// came from.
enum PracticeSkill: String, CaseIterable, Identifiable, Sendable {
    case handReading
    case countHand
    case pegging
    case pegScore

    var id: String { rawValue }

    var title: String {
        switch self {
        case .handReading: return String(localized: "Read the Hand")
        case .pegging: return String(localized: "Count to 31")
        case .countHand: return String(localized: "Count the Hand")
        case .pegScore: return String(localized: "Pegging Points")
        }
    }

    var subtitle: String {
        switch self {
        case .handReading: return String(localized: "Fresh five-card hands, unlimited reps")
        case .pegging: return String(localized: "Practice legal plays against the running total")
        case .countHand: return String(localized: "Add up a four-card hand and its starter")
        case .pegScore: return String(localized: "Score the card you just played")
        }
    }

    var icon: String {
        switch self {
        case .handReading: return "rectangle.portrait.on.rectangle.portrait.angled"
        case .pegging: return "number.circle.fill"
        case .countHand: return "sum"
        case .pegScore: return "target"
        }
    }

    var roomID: String {
        switch self {
        case .handReading, .countHand: return "scoring-room"
        case .pegging, .pegScore: return "pegging-room"
        }
    }

    var itemPrefix: String { "gen-\(rawValue)-" }

    static func skill(forItemID id: String) -> PracticeSkill? {
        allCases.first { id.hasPrefix($0.itemPrefix) }
    }
}

enum EndlessPractice {
    static func drill(for skill: PracticeSkill) -> Drill {
        Drill(id: "endless-\(skill.rawValue)", title: skill.title, subtitle: skill.subtitle, kind: .quiz([]))
    }

    static let challengeDrill = Drill(
        id: "timed-challenge",
        title: String(localized: "Timed Challenge"),
        subtitle: String(localized: "Beat the clock"),
        kind: .quiz([])
    )

    static func items(for skill: PracticeSkill, count: Int) -> [QuickItem] {
        switch skill {
        case .handReading: return handItems(count: count)
        case .pegging: return peggingItems(count: count)
        case .countHand: return countHandItems(count: count)
        case .pegScore: return pegScoreItems(count: count)
        }
    }

    static func mixedItems(count: Int) -> [QuickItem] {
        let skills = PracticeSkill.allCases
        let perSkill = max(1, count / skills.count + 1)
        return skills.flatMap { items(for: $0, count: perSkill) }.shuffled().prefix(count).map { $0 }
    }

    private static func handItems(count: Int) -> [QuickItem] {
        HandGenerator.batch(count: count).map { hand in
            let labels = hand.choices.map(\.displayName)
            let answerIndex = hand.choices.firstIndex(of: hand.answer) ?? 0
            return QuickItem(
                id: PracticeSkill.handReading.itemPrefix + UUID().uuidString,
                prompt: HandCategory.patternPrompt,
                tiles: hand.tiles,
                choices: labels,
                answerIndex: answerIndex,
                explanation: hand.explanation,
                sourceLabel: String(localized: "Endless Practice"),
                roomID: PracticeSkill.handReading.roomID,
                topic: PracticeTopic.id(.handReading, hand.answer.rawValue)
            )
        }
    }

    private static func peggingItems(count: Int) -> [QuickItem] {
        var items: [QuickItem] = []
        while items.count < count {
            let total = Int.random(in: 10...30)
            let rank = Int.random(in: 1...13)
            let card = PlayingCard.standard(rank: rank, suit: Suit.allCases.randomElement() ?? .clubs)
            let value = card.cribbageValue
            let canPlay = total + value <= 31
            let nextTotal = total + value
            let play = String(localized: "Play it, making \(nextTotal)")
            let choices = canPlay
                ? [play, String(localized: "Say go"), String(localized: "Reset the count")]
                : [play, String(localized: "Say go"), String(localized: "Ask for a new card")]
            let explanation = canPlay
                ? String(localized: "The running total is \(total), and \(card.spokenName) is worth \(value), so the legal total is \(nextTotal). Check whether the play also creates 15, a pair, a run, or 31.")
                : String(localized: "The running total is \(total), and \(card.spokenName) is worth \(value), which would pass 31. You must say go if you have no legal card.")
            let id = PracticeSkill.pegging.itemPrefix + UUID().uuidString
            let shuffled = ChoiceShuffle.shuffledChoices(labels: choices, answerIndex: canPlay ? 0 : 1, seed: id)
            items.append(QuickItem(
                id: id,
                prompt: String(localized: "The running total is \(total). You hold the \(card.spokenName). What is the legal play?"),
                tiles: [card],
                choices: shuffled.labels,
                answerIndex: shuffled.answerIndex,
                explanation: explanation,
                sourceLabel: String(localized: "Endless Practice"),
                roomID: PracticeSkill.pegging.roomID,
                topic: PracticeTopic.id(.pegging, canPlay ? "play" : "go")
            ))
        }
        return items
    }

    // MARK: - Count the Hand

    private static func countHandItems(count: Int) -> [QuickItem] {
        (0..<count).compactMap { _ in
            var generator = SystemRandomNumberGenerator()
            return HandCountGenerator.question(using: &generator)
        }.map { question in
            let id = PracticeSkill.countHand.itemPrefix + UUID().uuidString
            return QuickItem(
                id: id,
                prompt: String(localized: "Count this hand. The first four cards are your hand and the last card is the starter."),
                tiles: question.hand.racked + [question.starter],
                choices: question.choices.map { String(localized: "\($0) points") },
                answerIndex: question.choices.firstIndex(of: question.score) ?? 0,
                explanation: question.explanation,
                sourceLabel: String(localized: "Endless Practice"),
                roomID: PracticeSkill.countHand.roomID
            )
        }
    }

    // MARK: - Pegging Points

    private static func pegScoreItems(count: Int) -> [QuickItem] {
        (0..<count).compactMap { _ in
            var generator = SystemRandomNumberGenerator()
            return PeggingQuestionGenerator.question(using: &generator)
        }.map { question in
            let id = PracticeSkill.pegScore.itemPrefix + UUID().uuidString
            let pileText = question.pile.map(\.shortLabel).joined(separator: " ")
            return QuickItem(
                id: id,
                prompt: String(localized: "Cards played so far: \(pileText). The count is \(question.runningTotal). You play the \(question.play.shortLabel). How many points do you score?"),
                tiles: question.pile + [question.play],
                choices: question.choices.map { String(localized: "\($0) points") },
                answerIndex: question.choices.firstIndex(of: question.result.points) ?? 0,
                explanation: question.explanation,
                sourceLabel: String(localized: "Endless Practice"),
                roomID: PracticeSkill.pegScore.roomID,
                topic: PracticeTopic.id(.pegScore, question.topic)
            )
        }
    }
}

/// Names the narrow skills inside a practice skill so the stats screen can say
/// which one a player keeps missing ("Spotting runs") instead of only a
/// skill-wide percentage.
enum PracticeTopic {
    static func id(_ skill: PracticeSkill, _ name: String) -> String { "\(skill.rawValue).\(name)" }

    static func skill(forTopic id: String) -> PracticeSkill? {
        PracticeSkill(rawValue: String(id.split(separator: ".").first ?? ""))
    }

    static func title(_ id: String) -> String {
        switch id {
        case "handReading.fifteens": return String(localized: "Spotting fifteens")
        case "handReading.pairs": return String(localized: "Spotting pairs")
        case "handReading.runs": return String(localized: "Spotting runs")
        case "handReading.flushes": return String(localized: "Spotting flushes")
        case "handReading.nobs": return String(localized: "Spotting his nobs")
        case "pegging.play": return String(localized: "Legal plays under 31")
        case "pegging.go": return String(localized: "Knowing when to say go")
        case "pegScore.none": return String(localized: "Plays that score nothing")
        case "pegScore.fifteen": return String(localized: "Pegging fifteens")
        case "pegScore.thirtyOne": return String(localized: "Pegging thirty-one")
        case "pegScore.pair": return String(localized: "Pegging pairs")
        case "pegScore.run": return String(localized: "Pegging runs")
        case "pegScore.combo": return String(localized: "Plays that score two ways")
        default: return id
        }
    }
}
