import Foundation

/// Generated practice skills. Each skill still becomes the same QuickItem
/// shape used by authored drills, so the runner never cares where a question
/// came from.
enum PracticeSkill: String, CaseIterable, Identifiable, Sendable {
    case handReading
    case pegging

    var id: String { rawValue }

    var title: String {
        switch self {
        case .handReading: return "Read the Hand"
        case .pegging: return "Count to 31"
        }
    }

    var subtitle: String {
        switch self {
        case .handReading: return "Fresh five-card hands, unlimited reps"
        case .pegging: return "Practice legal plays against the running total"
        }
    }

    var icon: String {
        switch self {
        case .handReading: return "rectangle.portrait.on.rectangle.portrait.angled"
        case .pegging: return "number.circle.fill"
        }
    }

    var roomID: String {
        switch self {
        case .handReading: return "scoring-room"
        case .pegging: return "pegging-room"
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
        title: "Timed Challenge",
        subtitle: "Beat the clock",
        kind: .quiz([])
    )

    static func items(for skill: PracticeSkill, count: Int) -> [QuickItem] {
        switch skill {
        case .handReading: return handItems(count: count)
        case .pegging: return peggingItems(count: count)
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
                prompt: "Which scoring shape should you spot first?",
                tiles: hand.tiles,
                choices: labels,
                answerIndex: answerIndex,
                explanation: hand.explanation,
                sourceLabel: "Endless Practice",
                roomID: PracticeSkill.handReading.roomID
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
            let choices = canPlay
                ? ["Play it, making \(nextTotal)", "Say go", "Reset the count"]
                : ["Play it, making \(nextTotal)", "Say go", "Ask for a new card"]
            let explanation = canPlay
                ? "The running total is \(total), and \(card.spokenName) is worth \(value), so the legal total is \(nextTotal). Check whether the play also creates 15, a pair, a run, or 31."
                : "The running total is \(total), and \(card.spokenName) is worth \(value), which would pass 31. You must say go if you have no legal card."
            items.append(QuickItem(
                id: PracticeSkill.pegging.itemPrefix + UUID().uuidString,
                prompt: "The running total is \(total). You hold the \(card.spokenName). What is the legal play?",
                tiles: [card],
                choices: choices,
                answerIndex: canPlay ? 0 : 1,
                explanation: explanation,
                sourceLabel: "Endless Practice",
                roomID: PracticeSkill.pegging.roomID
            ))
        }
        return items
    }
}
