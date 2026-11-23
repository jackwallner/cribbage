import SwiftUI
import UIKit
import XCTest
@testable import CribbageTrainer

/// A hand is never wider than the room it is offered. Six 52pt cards on a
/// flashcard front are 342pt; with Display Zoom a 6.1" iPhone is 320pt wide
/// and the card offers 232pt, so a fixed row ran past the card and the
/// screen and lost cards off both edges.
@MainActor
final class CardHandViewFitTests: XCTestCase {
    private let six: [PlayingCard] = [.c(5), .d(10), .h(4), .s(1), .h(11), .c(7)]

    private func size(_ cards: [PlayingCard], tileWidth: CGFloat, in width: CGFloat) -> CGSize {
        let host = UIHostingController(rootView: CardHandView(tiles: cards, tileWidth: tileWidth))
        return host.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude))
    }

    func testAHandFitsTheWidthItIsOffered() {
        // A zoomed flashcard (232), a zoomed question (268), zoomed full width (288), an SE card (287).
        for width in [232, 268, 287, 288] as [CGFloat] {
            for (cards, tileWidth) in [(six, 52), (six, 48), (Array(six.prefix(5)), 44), (Array(six.prefix(4)), 54)] as [([PlayingCard], CGFloat)] {
                let fitted = size(cards, tileWidth: tileWidth, in: width)
                XCTAssertLessThanOrEqual(fitted.width, width + 0.5, "\(cards.count) cards at \(tileWidth)pt in \(width)pt")
            }
        }
    }

    func testAHandThatFitsKeepsItsDesign() {
        // Six 52pt cards and five 6pt gaps.
        XCTAssertEqual(size(six, tileWidth: 52, in: 500).width, 6 * 52 + 5 * 6, accuracy: 0.5)
    }
}
