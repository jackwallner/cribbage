import SwiftUI
import UIKit
import XCTest
@testable import CribbageTrainer

/// A fixed seven-column row ignored the offered width and ran cards off both
/// screen edges on a 320pt or 375pt phone. These host the real view and ask
/// SwiftUI how wide it wants to be inside a given width.
@MainActor
final class CardHandViewFitTests: XCTestCase {

    /// (cards, requested card width) for every call site: flashcard fronts
    /// (6 at 52), Discard deal (6 at 48), onboarding (up to 4 at 54), questions
    /// and generated practice (up to 6 at 44), How to Play (up to 6 at 46).
    private let shapes: [(count: Int, width: CGFloat)] = [
        (6, 52), (5, 52), (2, 52),
        (6, 48),
        (4, 54), (3, 54),
        (6, 44), (5, 44),
        (6, 46), (5, 46),
        (7, 44),
    ]

    private let gap: CGFloat = 6
    private let floorWidth: CGFloat = 30

    private func hand(_ count: Int) -> [PlayingCard] {
        Array([PlayingCard.c(5), .d(10), .h(2), .s(8), .c(11), .d(4), .h(7)].prefix(count))
    }

    private func fittedWidth(count: Int, tileWidth: CGFloat, in width: CGFloat) -> CGFloat {
        let host = UIHostingController(
            rootView: CardHandView(tiles: hand(count), tileWidth: tileWidth)
        )
        return host.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude)).width
    }

    private func designWidth(count: Int, tileWidth: CGFloat) -> CGFloat {
        CGFloat(count) * tileWidth + CGFloat(count - 1) * gap
    }

    func testHandsNeverExceedTheOfferedWidth() {
        for (count, tileWidth) in shapes {
            for width in [200, 232, 268, 288, 320] as [CGFloat] {
                // Below the 30pt floor a hand cannot shrink any further.
                let limit = max(width, designWidth(count: count, tileWidth: floorWidth))
                let fitted = fittedWidth(count: count, tileWidth: tileWidth, in: width)
                XCTAssertLessThanOrEqual(
                    fitted, limit + 0.5,
                    "\(count) cards at \(tileWidth)pt in \(width)pt fitted \(fitted)pt"
                )
            }
        }
    }

    func testEveryShapeFitsRealPhoneContentWidths() {
        // 320pt screen less 20pt of padding each side is the narrowest content area.
        for (count, tileWidth) in shapes {
            let fitted = fittedWidth(count: count, tileWidth: tileWidth, in: 280)
            XCTAssertLessThanOrEqual(fitted, 280.5, "\(count) cards at \(tileWidth)pt")
        }
    }

    func testWideScreensKeepTheDesignedSize() {
        for (count, tileWidth) in shapes {
            let fitted = fittedWidth(count: count, tileWidth: tileWidth, in: 500)
            XCTAssertEqual(
                fitted, designWidth(count: count, tileWidth: tileWidth), accuracy: 0.5,
                "\(count) cards at \(tileWidth)pt"
            )
        }
    }
}
