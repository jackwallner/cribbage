import Foundation

enum DrillLibrary {
    static let rooms: [Room] = [
        Room(
            id: "card-room",
            name: String(localized: "The Card Room"),
            tagline: String(localized: "Meet the deck and learn the vocabulary"),
            icon: "rectangle.portrait.on.rectangle.portrait.angled",
            isFree: true,
            drills: [
                Drill(
                    id: "meet-cards",
                    title: String(localized: "Meet the Cards"),
                    subtitle: String(localized: "Flashcards: suits, values, the cut, and the board"),
                    kind: .flashcards(CardBasicsContent.meetTheCards)
                ),
                Drill(
                    id: "card-quiz",
                    title: String(localized: "Card Check"),
                    subtitle: String(localized: "Quick quiz: the rules new players miss first"),
                    kind: .quiz(CardBasicsContent.cardQuiz)
                ),
                Drill(
                    id: "plus-card-extras",
                    title: String(localized: "Card Check: Extra Reps"),
                    subtitle: String(localized: "Fourteen more: deal sizes, values, cuts, and counts"),
                    kind: .quiz(PlusContent.cardExtras + MoreContent.cardExtras),
                    isPlus: true
                ),
            ]
        ),
        Room(
            id: "scoring-room",
            name: String(localized: "The Scoring Room"),
            tagline: String(localized: "See the points before you count them"),
            icon: "number.circle.fill",
            isFree: true,
            drills: [
                Drill(
                    id: "scoring-cards",
                    title: String(localized: "Know the Scores"),
                    subtitle: String(localized: "Flashcards: fifteens, pairs, runs, flushes, and nobs"),
                    kind: .flashcards(CategoryContent.categoryCards)
                ),
                Drill(
                    id: "hand-match",
                    title: String(localized: "Read the Hand"),
                    subtitle: String(localized: "See five cards, name the scoring shape"),
                    kind: .handMatch(CategoryContent.handMatch)
                ),
                Drill(
                    id: "plus-hand-extras",
                    title: String(localized: "Read the Hand: Extra Reps"),
                    subtitle: String(localized: "Twelve more hands with overlapping scoring patterns"),
                    kind: .handMatch(PlusContent.extraHandReading + MoreContent.handReading),
                    isPlus: true
                ),
            ]
        ),
        Room(
            id: "discard-room",
            name: String(localized: "The Discard Room"),
            tagline: String(localized: "Choose two cards with a plan"),
            icon: "arrow.left.arrow.right",
            isFree: true,
            drills: [
                Drill(
                    id: "discard-rules",
                    title: String(localized: "Discard Playbook"),
                    subtitle: String(localized: "Flashcards: dealer, pone, crib defense, and useful cuts"),
                    kind: .flashcards(DiscardContent.strategyCards)
                ),
                Drill(
                    id: "discard-two",
                    title: String(localized: "Pick Your Discard"),
                    subtitle: String(localized: "Six-card deals: choose two, then compare with the coach"),
                    kind: .discard(DiscardContent.scenarios)
                ),
                Drill(
                    id: "plus-discard-extras",
                    title: String(localized: "Pick Your Discard: Extra Reps"),
                    subtitle: String(localized: "Eight more deals: flushes, pairs, board position, and defense"),
                    kind: .discard(PlusContent.extraDiscards + MoreContent.discardExtras),
                    isPlus: true
                ),
            ]
        ),
        Room(
            id: "pegging-room",
            name: String(localized: "The Pegging Room"),
            tagline: String(localized: "Play to 31 without giving points away"),
            icon: "arrow.up.right.circle.fill",
            isFree: true,
            drills: [
                Drill(
                    id: "pegging-judgment",
                    title: String(localized: "Pegging Judgment"),
                    subtitle: String(localized: "Make the call, then flip to see the coach's answer"),
                    kind: .flashcards(KeepDiscardContent.judgmentCards)
                ),
                Drill(
                    id: "pegging-quiz",
                    title: String(localized: "Pegging Rules"),
                    subtitle: String(localized: "Fifteens, pairs, runs, go, 31, and last card"),
                    kind: .quiz(MoreContent.tableQuiz)
                ),
                Drill(
                    id: "plus-pegging-extras",
                    title: String(localized: "Pegging Judgment: Extra Reps"),
                    subtitle: String(localized: "Nine more calls: safe totals, board pressure, and nobs"),
                    kind: .flashcards(PlusContent.extraJudgment + MoreContent.judgment),
                    isPlus: true
                ),
            ]
        ),
        Room(
            id: "pro-tables",
            name: String(localized: "The Master Tables"),
            tagline: String(localized: "Advanced board play, defense, and full counts"),
            icon: "crown.fill",
            isFree: false,
            drills: [
                Drill(
                    id: "master-discard",
                    title: String(localized: "Advanced Discard"),
                    subtitle: String(localized: "Hand value, crib value, and board position together"),
                    kind: .discard(ProContent.advancedDiscard)
                ),
                Drill(
                    id: "master-defense",
                    title: String(localized: "Defense School"),
                    subtitle: String(localized: "Track the board, the count, and the cards still live"),
                    kind: .quiz(ProContent.defenseQuiz)
                ),
                Drill(
                    id: "master-counting",
                    title: String(localized: "Expert Counting"),
                    subtitle: String(localized: "Overlapping runs, fifteens, pairs, and deceptive hands"),
                    kind: .handMatch(ProContent.expertHandReading)
                ),
                Drill(
                    id: "master-rules",
                    title: String(localized: "Master Rules"),
                    subtitle: String(localized: "Muggins, crib flushes, double runs, and count order"),
                    kind: .quiz(MoreContent.advancedRules)
                ),
            ]
        ),
    ]

    static func room(id: String) -> Room? {
        rooms.first { $0.id == id }
    }

    static func roomID(forDrillID drillID: String) -> String {
        rooms.first { $0.drills.contains { $0.id == drillID } }?.id ?? ""
    }
}
