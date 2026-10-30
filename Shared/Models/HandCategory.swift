import Foundation

/// The five scoring shapes a player can spot in a five-card cribbage layout.
/// Every hand-match question offers three of these, and exactly one of the
/// three is present in the cards on screen, so the answer is never a judgment
/// call. These are teaching categories, not a substitute for the full rules
/// used at a table.
enum HandCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case fifteens
    case pairs
    case runs
    case flushes
    case nobs

    static var patternPrompt: String { String(localized: "Which scoring pattern or potential can you spot? No starter is designated.") }

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fifteens: return String(localized: "Fifteens")
        case .pairs: return String(localized: "Pairs")
        case .runs: return String(localized: "Runs")
        case .flushes: return String(localized: "Flush potential")
        case .nobs: return String(localized: "Nobs potential")
        }
    }

    var shortName: String { displayName }

    var howToSpot: String {
        switch self {
        case .fifteens:
            return String(localized: "Look for any combination of cards whose values add to 15. A ten-value card pairs with a five, while smaller cards can make several combinations.")
        case .pairs:
            return String(localized: "Two cards of the same rank score a pair. Three of a rank makes three pairs, and four makes six pairs.")
        case .runs:
            return String(localized: "Three or more consecutive ranks score a run. Duplicate ranks can multiply the run through pairs.")
        case .flushes:
            return String(localized: "Keeping four matching cards gives a hand flush. A matching starter extends it to five. This pattern exercise does not designate a starter.")
        case .nobs:
            return String(localized: "A jack in the hand can become his nobs when the cut matches its suit. It is easy to miss because the cut decides it.")
        }
    }

    /// True when this shape is actually present in the cards on screen. Nobs is
    /// potential rather than guaranteed, because the cut decides it, so a jack
    /// in the layout counts as present.
    func isPresent(in cards: [PlayingCard]) -> Bool {
        switch self {
        case .fifteens: return HandScoring.fifteens(cards) > 0
        case .pairs: return HandScoring.pairs(cards) > 0
        case .runs: return HandScoring.runs(cards) > 0
        case .flushes: return HandScoring.longestSuitCount(cards) >= 4
        case .nobs: return cards.contains { $0.rankValue == 11 }
        }
    }
}
