import Foundation

/// The scoring and decision families a cribbage player learns to recognize.
/// These are teaching categories, not a copyrighted card or a substitute for
/// the official rules used at a table.
enum HandCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case fifteens
    case pairs
    case runs
    case flushes
    case nobs
    case pegging
    case crib
    case counting
    case endgame

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fifteens: return "Fifteens"
        case .pairs: return "Pairs"
        case .runs: return "Runs"
        case .flushes: return "Flushes"
        case .nobs: return "His Nobs"
        case .pegging: return "Pegging"
        case .crib: return "The Crib"
        case .counting: return "Counting"
        case .endgame: return "Endgame"
        }
    }

    var shortName: String {
        switch self {
        case .fifteens: return "Fifteens"
        case .pairs: return "Pairs"
        case .runs: return "Runs"
        case .flushes: return "Flushes"
        case .nobs: return "His Nobs"
        case .pegging: return "Pegging"
        case .crib: return "The Crib"
        case .counting: return "Counting"
        case .endgame: return "Endgame"
        }
    }

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
            return "A jack matching the cut card's suit is his nobs, worth one point. It is easy to miss because the cut matters."
        case .pegging:
            return "During play, stay at or below 31 while looking for 15s, pairs, runs, and the last-card point."
        case .crib:
            return "The crib belongs to the dealer, so discard choices should balance your hand's score against what you are giving away."
        case .counting:
            return "Count every scoring combination once, then add the cut-card bonuses and any pegging points separately."
        case .endgame:
            return "The board changes priorities. A safe point now can matter more than a flashy hand later when someone is close to the finish."
        }
    }
}
