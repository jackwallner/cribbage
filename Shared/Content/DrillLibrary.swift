import Foundation

enum DrillLibrary {
    static let rooms: [Room] = [
        Room(
            id: "card-room",
            name: "The Card Room",
            tagline: "Meet the deck and learn the vocabulary",
            icon: "rectangle.portrait.on.rectangle.portrait.angled",
            isFree: true,
            drills: [
                Drill(
                    id: "meet-cards",
                    title: "Meet the Cards",
                    subtitle: "Flashcards: suits, values, the cut, and the board",
                    kind: .flashcards(CardBasicsContent.meetTheCards)
                ),
                Drill(
                    id: "card-quiz",
                    title: "Card Check",
                    subtitle: "Quick quiz: the rules new players miss first",
                    kind: .quiz(CardBasicsContent.cardQuiz)
                ),
                Drill(
                    id: "plus-card-extras",
                    title: "Card Check: Extra Reps",
                    subtitle: "Eight more: deal sizes, values, cuts, and counts",
                    kind: .quiz(PlusContent.cardExtras + MoreContent.cardExtras),
                    isPlus: true
                ),
            ]
        ),
        Room(
            id: "scoring-room",
            name: "The Scoring Room",
            tagline: "See the points before you count them",
            icon: "number.circle.fill",
            isFree: true,
            drills: [
                Drill(
                    id: "scoring-cards",
                    title: "Know the Scores",
                    subtitle: "Flashcards: fifteens, pairs, runs, flushes, and nobs",
                    kind: .flashcards(CategoryContent.categoryCards)
                ),
                Drill(
                    id: "hand-match",
                    title: "Read the Hand",
                    subtitle: "See five cards, name the scoring shape",
                    kind: .handMatch(CategoryContent.handMatch)
                ),
                Drill(
                    id: "plus-hand-extras",
                    title: "Read the Hand: Extra Reps",
                    subtitle: "Six more hands with overlapping scoring patterns",
                    kind: .handMatch(PlusContent.extraHandReading + MoreContent.handReading),
                    isPlus: true
                ),
            ]
        ),
        Room(
            id: "discard-room",
            name: "The Discard Room",
            tagline: "Choose two cards with a plan",
            icon: "arrow.left.arrow.right",
            isFree: true,
            drills: [
                Drill(
                    id: "discard-rules",
                    title: "Discard Playbook",
                    subtitle: "Flashcards: dealer, pone, crib defense, and useful cuts",
                    kind: .flashcards(DiscardContent.strategyCards)
                ),
                Drill(
                    id: "discard-two",
                    title: "Pick Your Discard",
                    subtitle: "Six-card deals: choose two, then compare with the coach",
                    kind: .discard(DiscardContent.scenarios)
                ),
                Drill(
                    id: "plus-discard-extras",
                    title: "Pick Your Discard: Extra Reps",
                    subtitle: "Four more deals: flushes, pairs, board position, and defense",
                    kind: .discard(PlusContent.extraDiscards + MoreContent.discardExtras),
                    isPlus: true
                ),
            ]
        ),
        Room(
            id: "pegging-room",
            name: "The Pegging Room",
            tagline: "Play to 31 without giving points away",
            icon: "arrow.up.right.circle.fill",
            isFree: true,
            drills: [
                Drill(
                    id: "pegging-judgment",
                    title: "Pegging Judgment",
                    subtitle: "Make the call, then flip to see the coach's answer",
                    kind: .flashcards(KeepDiscardContent.judgmentCards)
                ),
                Drill(
                    id: "pegging-quiz",
                    title: "Pegging Rules",
                    subtitle: "Fifteens, pairs, runs, go, 31, and last card",
                    kind: .quiz(MoreContent.tableQuiz)
                ),
                Drill(
                    id: "plus-pegging-extras",
                    title: "Pegging Judgment: Extra Reps",
                    subtitle: "Five more calls: safe totals, board pressure, and nobs",
                    kind: .flashcards(PlusContent.extraJudgment + MoreContent.judgment),
                    isPlus: true
                ),
            ]
        ),
        Room(
            id: "pro-tables",
            name: "The Master Tables",
            tagline: "Advanced board play, defense, and full counts",
            icon: "crown.fill",
            isFree: false,
            drills: [
                Drill(
                    id: "master-discard",
                    title: "Advanced Discard",
                    subtitle: "Hand value, crib value, and board position together",
                    kind: .discard(ProContent.advancedDiscard)
                ),
                Drill(
                    id: "master-defense",
                    title: "Defense School",
                    subtitle: "Track the board, the count, and the cards still live",
                    kind: .quiz(ProContent.defenseQuiz)
                ),
                Drill(
                    id: "master-counting",
                    title: "Expert Counting",
                    subtitle: "Overlapping runs, fifteens, pairs, and deceptive hands",
                    kind: .handMatch(ProContent.expertHandReading)
                ),
                Drill(
                    id: "master-rules",
                    title: "Master Rules",
                    subtitle: "Muggins, crib flushes, double runs, and count order",
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
