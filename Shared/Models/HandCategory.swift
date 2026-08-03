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

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fifteens: return "Fifteens"
        case .pairs: return "Pairs"
        case .runs: return "Runs"
        case .flushes: return "Flushes"
        case .nobs: return "His Nobs"
        }
    }

    var shortName: String { displayName }

    var howToSpot: String {
        switch self {
        case .fifteens:
            return "Look for any combination of cards whose values add to 15. A ten-value card pairs with a five, while smaller cards can make several combinations."
        case .pairs:
            return "Two cards of the same rank score a pair. Three of a rank makes three pairs, and four makes six pairs."
        case .runs:
            return "Three or more consecutive ranks score a run. Duplicate ranks can multiply the run through pairs."
        case .flushes:
            return "Four cards of one suit score a hand flush. A fifth card, the cut, can extend it when it matches too."
        case .nobs:
            return "A jack in the hand can become his nobs when the cut matches its suit. It is easy to miss because the cut decides it."
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
