import XCTest
@testable import CribbageTrainer

/// Repro on the base commit: the shared text carries a month-first date.
final class MinuteShareDateReproTests: XCTestCase {
    func testShareTextDateFollowsTheLocale() {
        let result = CribbageMinuteResult(
            dayKey: "2026-11-20", shortDate: "11/20", completedAt: Date(),
            answers: [true, true, true, true, false], correctByCategory: [:], totalByCategory: [:]
        )
        let day = Calendar.gregorianLocal.date(from: DateComponents(year: 2026, month: 11, day: 20, hour: 12))!
        let label = day.formatted(.dateTime.month(.abbreviated).day())
        XCTAssertTrue(result.shareText.hasPrefix("Cribbage Minute \(label): 4/5"), result.shareText)
        XCTAssertFalse(result.shareText.contains("11/20"), result.shareText)
    }
}
