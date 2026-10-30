import Foundation

enum Suit: String, Codable, CaseIterable, Hashable, Sendable {
    case clubs, diamonds, hearts, spades

    var symbol: String {
        switch self {
        case .clubs: return "♣"
        case .diamonds: return "♦"
        case .hearts: return "♥"
        case .spades: return "♠"
        }
    }

    var displayName: String {
        switch self {
        case .clubs: return String(localized: "Clubs")
        case .diamonds: return String(localized: "Diamonds")
        case .hearts: return String(localized: "Hearts")
        case .spades: return String(localized: "Spades")
        }
    }
}

enum PlayingCard: Hashable, Codable, Sendable {
    case standard(rank: Int, suit: Suit)
    case joker

    // Shortcuts keep authored examples compact and make suits obvious.
    static func c(_ rank: Int) -> PlayingCard { .standard(rank: rank, suit: .clubs) }
    static func d(_ rank: Int) -> PlayingCard { .standard(rank: rank, suit: .diamonds) }
    static func h(_ rank: Int) -> PlayingCard { .standard(rank: rank, suit: .hearts) }
    static func s(_ rank: Int) -> PlayingCard { .standard(rank: rank, suit: .spades) }

    var shortLabel: String {
        switch self {
        case .standard(let rank, let suit): return "\(Self.rankLabel(rank))\(suit.symbol)"
        case .joker: return String(localized: "Joker")
        }
    }

    /// "7 of Hearts". One key per face rank so a language can name the card
    /// its own way ("Herz-Bube") instead of reusing the corner letter.
    var spokenName: String {
        switch self {
        case .standard(let rank, let suit):
            switch rank {
            case 1: return String(localized: "A of \(suit.displayName)")
            case 11: return String(localized: "J of \(suit.displayName)")
            case 12: return String(localized: "Q of \(suit.displayName)")
            case 13: return String(localized: "K of \(suit.displayName)")
            default: return String(localized: "\(rank) of \(suit.displayName)")
            }
        case .joker: return String(localized: "Joker")
        }
    }

    /// The English name, for orderings that must match on every device
    /// whatever the language (the daily discard's distractors).
    var stableName: String {
        switch self {
        case .standard(let rank, let suit): return "\(Self.rankLabel(rank)) of \(suit.rawValue.capitalized)"
        case .joker: return "Joker"
        }
    }

    var rankValue: Int {
        switch self {
        case .standard(let rank, _): return rank
        case .joker: return 0
        }
    }

    var suit: Suit? {
        if case .standard(_, let suit) = self { return suit }
        return nil
    }

    var cribbageValue: Int {
        switch self {
        case .standard(let rank, _): return min(rank, 10)
        case .joker: return 0
        }
    }

    var sortKey: Int {
        switch self {
        case .standard(let rank, let suit):
            let suitOrder = [Suit.clubs: 0, .diamonds: 1, .hearts: 2, .spades: 3][suit] ?? 0
            return suitOrder * 20 + rank
        case .joker: return 100
        }
    }

    private func rankLabel(_ rank: Int) -> String {
        switch rank {
        case 1: return "A"
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return String(rank)
        }
    }

    static func rankLabel(_ rank: Int) -> String {
        switch rank {
        case 1: return "A"
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return String(rank)
        }
    }
}

extension Array where Element == PlayingCard {
    var racked: [PlayingCard] { sorted { $0.sortKey < $1.sortKey } }
}
