import SwiftUI
import UIKit
import XCTest
@testable import CribbageTrainer

/// A hand must never be wider than the screen offers, or cards clip at both
/// edges (Display Zoom 320pt, SE and mini 375pt, Slide Over 320pt).
@MainActor
final class CardHandViewFitTests: XCTestCase {
    private let gap: CGFloat = 6
    private let minimumTileWidth: CGFloat = 30
    private let offeredWidths: [CGFloat] = [200, 232, 268, 288, 320]

    /// (card count, requested card width) for every call site, including the
    /// worst cases: 6-card flashcard fronts at 52pt and the 6-card Discard
    /// deal at 48pt.
    private let shapes: [(count: Int, width: CGFloat)] = [
        (6, 52), (5, 52), (4, 52), (2, 52),
        (6, 48), (5, 48),
        (7, 44), (6, 44), (5, 44), (2, 44),
        (6, 54), (4, 54), (3, 54),
        (6, 46), (4, 46),
    ]

    private func hand(_ count: Int) -> [PlayingCard] {
        let ranks = [2, 4, 6, 8, 10, 12, 1, 3]
        let suits: [(Int) -> PlayingCard] = [PlayingCard.c, .d, .h, .s]
        return (0..<count).map { suits[$0 % 4](ranks[$0]) }
    }

    private func fittedWidth(count: Int, tileWidth: CGFloat, offered: CGFloat) -> CGFloat {
        let view = CardHandView(tiles: hand(count), tileWidth: tileWidth)
        let host = UIHostingController(rootView: view)
        let size = host.sizeThatFits(in: CGSize(width: offered, height: .greatestFiniteMagnitude))
        return size.width
    }

    private func designWidth(count: Int, tileWidth: CGFloat) -> CGFloat {
        let perRow = CGFloat(min(count, 7))
        return perRow * tileWidth + gap * (perRow - 1)
    }

    func testHandsFitTheOfferedWidth() {
        for shape in shapes {
            for offered in offeredWidths {
                let width = fittedWidth(count: shape.count, tileWidth: shape.width, offered: offered)
                let floor = designWidth(count: shape.count, tileWidth: minimumTileWidth)
                // Below the 30pt floor a hand cannot shrink further; every
                // real screen leaves more room than that.
                let limit = max(offered, floor)
                XCTAssertLessThanOrEqual(
                    width, limit + 0.5,
                    "\(shape.count) cards at \(shape.width)pt offered \(offered)pt fitted \(width)pt"
                )
            }
        }
    }

    func testNarrowScreensKeepTheCommonHandsInsideTheScreen() {
        // Six cards need 6 x 30 + 30 = 210pt at the floor, so 232pt and up
        // must fit exactly. 7 cards need 246pt.
        for shape in shapes where shape.count <= 6 {
            for offered in offeredWidths where offered >= 232 {
                let width = fittedWidth(count: shape.count, tileWidth: shape.width, offered: offered)
                XCTAssertLessThanOrEqual(width, offered + 0.5)
            }
        }
    }

    func testWideScreensKeepTheDesignWidth() {
        for shape in shapes {
            let width = fittedWidth(count: shape.count, tileWidth: shape.width, offered: 500)
            XCTAssertEqual(
                width, designWidth(count: shape.count, tileWidth: shape.width), accuracy: 0.5,
                "\(shape.count) cards at \(shape.width)pt"
            )
        }
    }

    func testWorstCasesShrinkRatherThanOverflow() {
        // 6 x 52 + 30 = 342pt, which does not fit a 320pt screen.
        let flashcard = fittedWidth(count: 6, tileWidth: 52, offered: 320)
        XCTAssertLessThan(flashcard, 342)
        XCTAssertLessThanOrEqual(flashcard, 320.5)
        // 6 x 48 + 30 = 318pt fits 320pt but not 288pt.
        let discard = fittedWidth(count: 6, tileWidth: 48, offered: 288)
        XCTAssertLessThan(discard, 318)
        XCTAssertLessThanOrEqual(discard, 288.5)
    }
}
