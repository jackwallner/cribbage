import ObjectiveC
import UserNotifications
import XCTest
@testable import CribbageTrainer

/// State machine audit repro suite (2026-11-06). Failing tests are expected:
/// each `testBUG_*` asserts the promised behaviour and fails on the shipped
/// code. Each `testCONTROL_*` passes and shows the setup works.
@MainActor
final class StateMachineAuditRepro: XCTestCase {
    private let dailyID = "cribbage.dailyReminder"
    private let gameNightID = "cribbage.gameNightReminder"
    private var savedZone: TimeZone!
    private var suites: [String] = []

    override func setUp() async throws {
        try await super.setUp()
        savedZone = NSTimeZone.default
    }

    override func tearDown() async throws {
        NSTimeZone.default = savedZone
        suites.forEach { UserDefaults(suiteName: $0)?.removePersistentDomain(forName: $0) }
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func freshDefaults(_ name: String) -> UserDefaults {
        let suite = "StateMachineAuditRepro.\(name)"
        suites.append(suite)
        let d = UserDefaults(suiteName: suite)!
        d.removePersistentDomain(forName: suite)
        return d
    }

    private func settle(_ seconds: Double = 1.0) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    private func date(_ iso: String) -> Date {
        ISO8601DateFormatter().date(from: iso)!
    }

    // MARK: - R1: reminder toggles are never reconciled with what is pending

    /// CONTROL: the fake sees the scheduler call when the toggle is turned on
    /// with permission granted, and when the time changes with the toggle on.
    func testCONTROL_fakeCenterSeesScheduling() async {
        let fake = FakeNotificationCenter.install()
        defer { fake.uninstall() }
        let d = freshDefaults("control-reminder")
        let settings = AppSettings(defaults: d)
        XCTAssertFalse(settings.reminderEnabled, "precondition: toggle starts off")
        XCTAssertEqual(fake.added, [], "precondition: nothing scheduled by init")

        settings.reminderEnabled = true
        await settle()
        XCTAssertEqual(fake.added, [dailyID], "turning the toggle on schedules once permission is granted")

        settings.reminderTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 30))!
        XCTAssertEqual(fake.added, [dailyID, dailyID], "changing the time reschedules")
    }

    /// BUG R1: Settings shows "Daily Reminder" and "Weekly game night reminder"
    /// ON (persisted flags), but a launch with nothing pending (new phone
    /// restored from backup, or pending requests cleared) never schedules them.
    /// Every scheduler call site is `reminderEnabled`/`gameNightReminderEnabled`
    /// granted callbacks and the time/day `didSet`s; `init` has none.
    func testBUG_R1_enabledReminderFlagsWithNothingPendingAreNeverReconciled() async {
        let fake = FakeNotificationCenter.install()
        defer { fake.uninstall() }
        let d = freshDefaults("r1")
        d.set(true, forKey: "settings.reminderEnabled")
        d.set(9, forKey: "settings.reminderHour")
        d.set(true, forKey: "settings.gameNightReminderEnabled")
        d.set(5, forKey: "settings.gameNightDay")
        d.set(19, forKey: "settings.gameNightHour")
        XCTAssertEqual(fake.added, [], "precondition: nothing scheduled yet")

        let settings = AppSettings(defaults: d)
        XCTAssertTrue(settings.reminderEnabled, "precondition: Daily Reminder toggle reads ON")
        XCTAssertTrue(settings.gameNightReminderEnabled, "precondition: game night toggle reads ON")
        await settle(1.5)

        XCTAssertTrue(fake.added.contains(dailyID), "Daily Reminder toggle is ON but nothing was scheduled, added=\(fake.added)")
        XCTAssertTrue(fake.added.contains(gameNightID), "Game night toggle is ON but nothing was scheduled, added=\(fake.added)")
    }

    // MARK: - R2: picker label drifts from the trigger across a time zone change

    /// CONTROL: in one zone the picker's hour equals the stored hour.
    func testCONTROL_reminderPickerHourMatchesStoredHourInOneZone() {
        NSTimeZone.default = TimeZone(identifier: "Asia/Tokyo")!
        let d = freshDefaults("control-r2")
        d.set(true, forKey: "settings.reminderEnabled")
        d.set(9, forKey: "settings.reminderHour")
        let settings = AppSettings(defaults: d)
        XCTAssertEqual(Calendar.current.timeZone.identifier, "Asia/Tokyo", "precondition: Calendar.current follows NSTimeZone.default")
        XCTAssertEqual(Calendar.current.component(.hour, from: settings.reminderTime), 9)
    }

    /// BUG R2: the process lives across a zone change. The stored hour and the
    /// pending trigger stay 9 (floating), but the DatePicker renders
    /// `reminderTime` (a Date built in the old zone) in the new zone.
    func testBUG_R2_reminderPickerShowsStoredHourAfterZoneChange() {
        NSTimeZone.default = TimeZone(identifier: "Asia/Tokyo")!
        let d = freshDefaults("r2")
        d.set(true, forKey: "settings.reminderEnabled")
        d.set(9, forKey: "settings.reminderHour")
        d.set(0, forKey: "settings.reminderMinute")
        let settings = AppSettings(defaults: d)
        XCTAssertEqual(Calendar.current.timeZone.identifier, "Asia/Tokyo", "precondition")
        XCTAssertEqual(Calendar.current.component(.hour, from: settings.reminderTime), 9, "precondition")
        XCTAssertEqual(d.integer(forKey: "settings.reminderHour"), 9, "precondition: stored hour")

        NSTimeZone.default = TimeZone(identifier: "America/Los_Angeles")!
        XCTAssertEqual(Calendar.current.timeZone.identifier, "America/Los_Angeles", "precondition")

        let shown = Calendar.current.component(.hour, from: settings.reminderTime)
        XCTAssertEqual(shown, 9, "picker would show hour \(shown) while the stored hour and trigger are 9")
    }

    // MARK: - S1: streak counts one calendar day twice after westward travel

    /// CONTROL: consecutive days in one zone are 2, the same day twice is 1.
    func testCONTROL_streakSameZone() {
        NSTimeZone.default = TimeZone(identifier: "America/Los_Angeles")!
        let store = ProgressStore(defaults: freshDefaults("control-s1"))
        store.recordSession(drillID: "a", now: date("2026-11-02T17:00:00Z"))
        store.recordSession(drillID: "a", now: date("2026-11-02T23:00:00Z"))
        XCTAssertEqual(store.streakCount, 1, "same day twice")
        store.recordSession(drillID: "a", now: date("2026-11-03T20:00:00Z"))
        XCTAssertEqual(store.streakCount, 2, "next day")
    }

    /// BUG S1: practice Monday 23:00 in Tokyo (= Monday 06:00 in Los Angeles),
    /// fly to Los Angeles, practice Monday 18:00 there. Both are Monday on the
    /// calendar of the zone the phone is in now, but the streak becomes 2.
    func testBUG_S1_streakDoesNotCountOneCalendarDayTwiceAfterTravel() {
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let la = TimeZone(identifier: "America/Los_Angeles")!
        let first = date("2026-11-02T14:00:00Z")   // Mon 23:00 JST
        let second = date("2026-11-03T02:00:00Z")  // Mon 18:00 PST

        NSTimeZone.default = tokyo
        XCTAssertEqual(Calendar.current.timeZone.identifier, "Asia/Tokyo", "precondition")
        let store = ProgressStore(defaults: freshDefaults("s1"))
        store.recordSession(drillID: "a", now: first)
        XCTAssertEqual(store.streakCount, 1, "precondition")

        NSTimeZone.default = la
        XCTAssertEqual(Calendar.current.timeZone.identifier, "America/Los_Angeles", "precondition")
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = la
        XCTAssertEqual(cal.component(.day, from: first), 2, "precondition: first practice is Nov 2 in LA")
        XCTAssertEqual(cal.component(.day, from: second), 2, "precondition: second practice is Nov 2 in LA")

        store.recordSession(drillID: "a", now: second)
        XCTAssertEqual(store.streakCount, 1, "one calendar day, practiced twice, streak should stay 1")
    }

    // MARK: - U1: flashcard Undo does not retract the recorded answer

    /// The view's undo() (FlashcardDrillView.swift:362) changes only the queue
    /// and calls no store. These tests model the store calls the view makes
    /// around an undo: they are consequences, not a run of the view.
    ///
    /// CONTROL: a single right answer does not make an item known.
    func testCONTROL_singleRightAnswerIsNotKnown() {
        let records = PracticeRecordStore(defaults: freshDefaults("control-u1"))
        records.record(itemID: "keep-discard-1", roomID: "scoring-room", correct: true)
        XCTAssertEqual(records.records["keep-discard-1"]?.attempts, 1, "precondition")
        XCTAssertFalse(records.records["keep-discard-1"]!.isKnown(), "one right answer is not known")
    }

    /// U1a: right pick, swipe, Undo, pick right again. One genuine pass reads
    /// as two right answers in a row, which is the definition of known.
    func testBUG_U1a_undoThenReanswerDoesNotDoubleCreditMastery() {
        let records = PracticeRecordStore(defaults: freshDefaults("u1a"))
        records.record(itemID: "keep-discard-1", roomID: "scoring-room", correct: true)  // choose()
        // commit(): no store call for a choice card. undo(): no store call.
        records.record(itemID: "keep-discard-1", roomID: "scoring-room", correct: true)  // choose() again
        XCTAssertFalse(records.records["keep-discard-1"]!.isKnown(), "an undone answer should not count toward known")
    }

    /// U1b: wrong pick, swipe, Undo, pick right. The player's final state is
    /// right, but the undone miss keeps the item in Fix My Mistakes.
    func testBUG_U1b_undoneMissDoesNotKeepItemNeedingReview() {
        let records = PracticeRecordStore(defaults: freshDefaults("u1b"))
        records.record(itemID: "keep-discard-1", roomID: "scoring-room", correct: false)
        records.record(itemID: "keep-discard-1", roomID: "scoring-room", correct: true)
        let record = records.records["keep-discard-1"]!
        XCTAssertEqual(record.attempts, 1, "undone answer still counted, attempts=\(record.attempts)")
        XCTAssertFalse(record.needsReview, "needsReview=\(record.needsReview) after the miss was undone")
    }
}

/// Test-only stand-in for `UNUserNotificationCenter`: swizzles the three
/// methods AppSettings calls so nothing reaches iOS and every call is recorded.
/// Authorization is always granted.
final class FakeNotificationCenter: @unchecked Sendable {
    private(set) var added: [String] = []
    private(set) var removed: [String] = []
    private(set) var authRequests = 0
    private var saved: [(Method, IMP)] = []

    static func install() -> FakeNotificationCenter {
        let fake = FakeNotificationCenter()
        let cls: AnyClass = UNUserNotificationCenter.self

        let addBlock: @convention(block) (AnyObject, UNNotificationRequest, ((Error?) -> Void)?) -> Void = { _, request, done in
            fake.added.append(request.identifier)
            done?(nil)
        }
        let removeBlock: @convention(block) (AnyObject, [String]) -> Void = { _, ids in
            fake.removed.append(contentsOf: ids)
        }
        let authBlock: @convention(block) (AnyObject, UInt, @escaping (Bool, Error?) -> Void) -> Void = { _, _, done in
            fake.authRequests += 1
            done(true, nil)
        }
        fake.swap(cls, #selector(UNUserNotificationCenter.add(_:withCompletionHandler:)), addBlock)
        fake.swap(cls, #selector(UNUserNotificationCenter.removePendingNotificationRequests(withIdentifiers:)), removeBlock)
        fake.swap(cls, #selector(UNUserNotificationCenter.requestAuthorization(options:completionHandler:)), authBlock)
        return fake
    }

    private func swap(_ cls: AnyClass, _ selector: Selector, _ block: Any) {
        guard let method = class_getInstanceMethod(cls, selector) else { return }
        let original = method_getImplementation(method)
        saved.append((method, original))
        method_setImplementation(method, imp_implementationWithBlock(block))
    }

    func uninstall() {
        for (method, imp) in saved { method_setImplementation(method, imp) }
        saved = []
    }
}
