import XCTest
@testable import CribbageTrainer

@MainActor
final class ProgressStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var store: ProgressStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "ProgressStoreTests")
        defaults.removePersistentDomain(forName: "ProgressStoreTests")
        store = ProgressStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "ProgressStoreTests")
        super.tearDown()
    }

    func testRecordSessionIncrementsCounts() {
        store.recordSession(drillID: "meet-tiles")
        store.recordSession(drillID: "meet-tiles")
        XCTAssertEqual(store.completions(for: "meet-tiles"), 2)
        XCTAssertEqual(store.totalSessions, 2)
    }

    /// The tour's closing practice is recorded before onboarding ends, so
    /// Home's extras wait for a practice the player starts after it.
    func testTourPracticeDoesNotCountTowardHomeExtras() {
        XCTAssertFalse(store.hasPracticedSinceOnboarding)
        store.recordSession(drillID: "quick-session")
        store.sessionsAtOnboarding = store.totalSessions
        XCTAssertFalse(store.hasPracticedSinceOnboarding)
        store.recordSession(drillID: "meet-cards")
        XCTAssertTrue(store.hasPracticedSinceOnboarding)
    }

    /// Players who onboarded before this mark existed have none stored, so any
    /// finished practice counts, as before.
    func testUpgradersCountEveryPractice() {
        store.recordSession(drillID: "meet-cards")
        XCTAssertTrue(store.hasPracticedSinceOnboarding)
    }

    func testStreakStartsAtOne() {
        store.recordSession(drillID: "a")
        XCTAssertEqual(store.streakCount, 1)
    }

    func testSameDaySessionsKeepStreak() {
        let day1 = Date(timeIntervalSince1970: 1_750_000_000)
        store.recordSession(drillID: "a", now: day1)
        store.recordSession(drillID: "b", now: day1.addingTimeInterval(3600))
        XCTAssertEqual(store.streakCount, 1)
    }

    func testConsecutiveDaysGrowStreak() {
        let day1 = Date(timeIntervalSince1970: 1_750_000_000)
        store.recordSession(drillID: "a", now: day1)
        store.recordSession(drillID: "a", now: day1.addingTimeInterval(86_400))
        XCTAssertEqual(store.streakCount, 2)
    }

    func testGapResetsStreakToOne() {
        let day1 = Date(timeIntervalSince1970: 1_750_000_000)
        store.recordSession(drillID: "a", now: day1)
        store.recordSession(drillID: "a", now: day1.addingTimeInterval(86_400 * 3))
        XCTAssertEqual(store.streakCount, 1)
    }

    func testCurrentStreakHoldsThroughTheNextDay() {
        let day1 = Date(timeIntervalSince1970: 1_750_000_000)
        store.recordSession(drillID: "a", now: day1)
        store.recordSession(drillID: "a", now: day1.addingTimeInterval(86_400))
        XCTAssertEqual(store.currentStreak(now: day1.addingTimeInterval(86_400 * 2)), 2)
    }

    func testCurrentStreakDropsToZeroAfterAMissedDay() {
        let day1 = Date(timeIntervalSince1970: 1_750_000_000)
        store.recordSession(drillID: "a", now: day1)
        store.recordSession(drillID: "a", now: day1.addingTimeInterval(86_400))
        XCTAssertEqual(store.currentStreak(now: day1.addingTimeInterval(86_400 * 5)), 0)
    }

    func testClockGoingBackwardsDoesNotRewindTheLastDay() {
        let day1 = Date(timeIntervalSince1970: 1_750_000_000)
        store.recordSession(drillID: "a", now: day1)
        store.recordSession(drillID: "a", now: day1.addingTimeInterval(86_400))
        store.recordSession(drillID: "a", now: day1)
        store.recordSession(drillID: "a", now: day1.addingTimeInterval(86_400))
        XCTAssertEqual(store.streakCount, 2, "Returning to the real date must not count the same day twice")
    }

    func testRoomProgress() {
        guard let room = DrillLibrary.rooms.first else { return XCTFail("no rooms") }
        XCTAssertEqual(store.roomProgress(room), 0)
        store.recordSession(drillID: room.drills[0].id)
        XCTAssertEqual(store.roomProgress(room), 1 / Double(room.drills.count), accuracy: 0.001)
    }

    func testRecordItemTracksSeenAndMissed() {
        store.recordItem(id: "q1", correct: false)
        XCTAssertTrue(store.seenItems.contains("q1"))
        XCTAssertTrue(store.missedItems.contains("q1"))
        store.recordItem(id: "q1", correct: true)
        XCTAssertTrue(store.seenItems.contains("q1"))
        XCTAssertFalse(store.missedItems.contains("q1"), "A correct answer clears the miss")
    }

    func testItemTrackingPersists() {
        store.recordItem(id: "q1", correct: false)
        let reloaded = ProgressStore(defaults: defaults)
        XCTAssertTrue(reloaded.seenItems.contains("q1"))
        XCTAssertTrue(reloaded.missedItems.contains("q1"))
    }

    func testResetAllClearsEverythingButOnboarding() {
        store.hasOnboarded = true
        store.recordSession(drillID: "a")
        store.recordItem(id: "q1", correct: false)
        store.resetAll()
        XCTAssertEqual(store.streakCount, 0)
        XCTAssertEqual(store.totalSessions, 0)
        XCTAssertEqual(store.completions(for: "a"), 0)
        XCTAssertTrue(store.seenItems.isEmpty)
        XCTAssertTrue(store.missedItems.isEmpty)
        XCTAssertTrue(store.hasOnboarded, "Reset must not re-trigger onboarding")
    }

    // MARK: - Daylight saving that starts at midnight

    /// Chile, Cuba, Egypt, Lebanon and the Azores move the clocks at midnight,
    /// so the local day that begins then starts at 01:00 and lasts 23 hours.
    /// Run `body` with the app reading `identifier` as the device time zone and
    /// `dstDay` as that day (00:00 on the calendar, 01:00 on the clock).
    private func withMidnightDaylightSaving(
        _ identifier: String, dstDay: DateComponents, _ body: (_ evening: (Int) -> Date) -> Void
    ) throws {
        let zone = try XCTUnwrap(TimeZone(identifier: identifier))
        let saved = NSTimeZone.default
        NSTimeZone.default = zone
        defer { NSTimeZone.default = saved }
        XCTAssertEqual(Calendar.current.timeZone.identifier, identifier, "the app must read this zone")

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let day = try XCTUnwrap(calendar.date(from: dstDay))
        XCTAssertEqual(
            calendar.component(.hour, from: calendar.startOfDay(for: day)), 1,
            "\(identifier) was expected to start this day at 01:00"
        )
        body { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: day)!
            return calendar.date(bySettingHour: 21, minute: 30, second: 0, of: date)!
        }
    }

    private let santiagoDay = DateComponents(year: 2026, month: 9, day: 6)   // clocks 00:00 -> 01:00

    /// Measured between two start-of-day instants, the 23 hour day read as no
    /// gap before the day after it, so that practice did not extend the streak.
    func testStreakGrowsOnTheDayAfterAMidnightDaylightSavingChange() throws {
        try withMidnightDaylightSaving("America/Santiago", dstDay: santiagoDay) { evening in
            for offset in -2...1 { store.recordSession(drillID: "a", now: evening(offset)) }
            XCTAssertEqual(store.streakCount, 4, "four days in a row, the third of them the short day")
        }
    }

    /// ...and two days after it the gap read as one, so a missed day was
    /// forgiven and Home kept showing a streak the player had lost.
    func testMissedDayAfterAMidnightDaylightSavingChangeBreaksTheStreak() throws {
        try withMidnightDaylightSaving("America/Santiago", dstDay: santiagoDay) { evening in
            for offset in -2...0 { store.recordSession(drillID: "a", now: evening(offset)) }
            XCTAssertEqual(store.currentStreak(now: evening(1)), 3, "the next day is still open")
            XCTAssertEqual(store.currentStreak(now: evening(2)), 0, "that day was missed")
            store.recordSession(drillID: "a", now: evening(2))
            XCTAssertEqual(store.streakCount, 1, "practising after a missed day starts the streak over")
        }
    }

    // Rating-ask rules live in ReviewPromptTracker; see ReviewPromptTrackerTests.
}
