import XCTest
@testable import CribbageTrainer

/// The Timed Challenge reads its clock from a deadline, so time the app spent
/// suspended (a phone call) is spent, not handed back.
@MainActor
final class TimedChallengeClockTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)

    func testAFreshRunShowsTheFullClock() {
        let deadline = start.addingTimeInterval(TimeInterval(PracticeRunView.challengeSeconds))
        XCTAssertEqual(PracticeRunView.secondsRemaining(until: deadline, now: start), 90)
    }

    func testTimeAwayIsCounted() {
        let deadline = start.addingTimeInterval(90)
        XCTAssertEqual(PracticeRunView.secondsRemaining(until: deadline, now: start.addingTimeInterval(40)), 50)
        XCTAssertEqual(PracticeRunView.secondsRemaining(until: deadline, now: start.addingTimeInterval(40.2)), 50)
    }

    func testAReturnAfterTheDeadlineReadsZero() {
        let deadline = start.addingTimeInterval(90)
        XCTAssertEqual(PracticeRunView.secondsRemaining(until: deadline, now: start.addingTimeInterval(600)), 0)
    }
}
