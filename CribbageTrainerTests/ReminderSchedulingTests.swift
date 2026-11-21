import UserNotifications
import XCTest
@testable import CribbageTrainer

/// Reminder times are stored as an hour and minute, so what the pickers show
/// and what gets scheduled stay the stored time after a time zone change.
@MainActor
final class ReminderSchedulingTests: XCTestCase {
    private let suite = "ReminderSchedulingTests"
    private let dailyID = "cribbage.dailyReminder"
    private let gameNightID = "cribbage.gameNightReminder"
    private var defaults: UserDefaults!
    private var savedZone: TimeZone!
    private var fake: FakeNotificationCenter!

    override func setUp() {
        super.setUp()
        savedZone = NSTimeZone.default
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        fake = FakeNotificationCenter.install()
    }

    override func tearDown() {
        fake.uninstall()
        NSTimeZone.default = savedZone
        defaults.removePersistentDomain(forName: suite)
        super.tearDown()
    }

    private func inZone(_ identifier: String) {
        NSTimeZone.default = TimeZone(identifier: identifier)!
        XCTAssertEqual(Calendar.current.timeZone.identifier, identifier, "precondition")
    }

    private func settle() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
    }

    func testPickerShowsTheStoredHourAfterAZoneChange() {
        inZone("Asia/Tokyo")
        defaults.set(true, forKey: "settings.reminderEnabled")
        defaults.set(9, forKey: "settings.reminderHour")
        defaults.set(0, forKey: "settings.reminderMinute")
        defaults.set(19, forKey: "settings.gameNightHour")
        let settings = AppSettings(defaults: defaults)
        XCTAssertEqual(Calendar.current.component(.hour, from: settings.reminderTime), 9, "precondition")

        inZone("America/Los_Angeles")
        XCTAssertEqual(Calendar.current.component(.hour, from: settings.reminderTime), 9)
        XCTAssertEqual(Calendar.current.component(.hour, from: settings.gameNightReminderTime), 19)
    }

    /// Toggling the reminder off and on after the move scheduled the old
    /// zone's 9:00 read in the new zone (15:48), while the stored hour said 9.
    func testReenablingAfterAZoneChangeSchedulesTheStoredHour() async {
        inZone("Asia/Tokyo")
        defaults.set(true, forKey: "settings.reminderEnabled")
        defaults.set(9, forKey: "settings.reminderHour")
        defaults.set(0, forKey: "settings.reminderMinute")
        let settings = AppSettings(defaults: defaults)

        inZone("America/Los_Angeles")
        settings.reminderEnabled = false
        settings.reminderEnabled = true
        await settle()
        let trigger = fake.lastTrigger(dailyID)
        XCTAssertEqual(trigger?.hour, 9)
        XCTAssertEqual(trigger?.minute, 0)
    }

    /// Changing the game night day after the move kept the stored time too.
    func testChangingGameNightDayAfterAZoneChangeKeepsTheStoredTime() {
        inZone("Asia/Tokyo")
        defaults.set(true, forKey: "settings.gameNightReminderEnabled")
        defaults.set(5, forKey: "settings.gameNightDay")
        defaults.set(19, forKey: "settings.gameNightHour")
        defaults.set(30, forKey: "settings.gameNightMinute")
        let settings = AppSettings(defaults: defaults)

        inZone("America/Los_Angeles")
        settings.gameNightDay = .friday
        let trigger = fake.lastTrigger(gameNightID)
        XCTAssertEqual(trigger?.weekday, AppSettings.GameNightDay.friday.rawValue)
        XCTAssertEqual(trigger?.hour, 19)
        XCTAssertEqual(trigger?.minute, 30)
    }

    /// Picking a time stores and schedules it, as before.
    func testPickingATimeStoresAndSchedulesIt() {
        defaults.set(true, forKey: "settings.reminderEnabled")
        let settings = AppSettings(defaults: defaults)
        settings.reminderTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 30))!
        XCTAssertEqual(defaults.integer(forKey: "settings.reminderHour"), 7)
        XCTAssertEqual(defaults.integer(forKey: "settings.reminderMinute"), 30)
        XCTAssertEqual(Calendar.current.component(.minute, from: settings.reminderTime), 30)
        XCTAssertEqual(fake.lastTrigger(dailyID)?.hour, 7)
        XCTAssertEqual(fake.lastTrigger(dailyID)?.minute, 30)
        XCTAssertEqual(AppSettings(defaults: defaults).reminderTime, settings.reminderTime, "survives a relaunch")
    }

    // MARK: - Reconciling at launch

    private func storeBothRemindersOn() {
        defaults.set(true, forKey: "settings.reminderEnabled")
        defaults.set(8, forKey: "settings.reminderHour")
        defaults.set(15, forKey: "settings.reminderMinute")
        defaults.set(true, forKey: "settings.gameNightReminderEnabled")
        defaults.set(5, forKey: "settings.gameNightDay")
        defaults.set(19, forKey: "settings.gameNightHour")
    }

    private func withNotifications(_ status: UNAuthorizationStatus, _ body: () async -> Void) async {
        let saved = AppSettings.notificationStatus
        AppSettings.notificationStatus = { status }
        await body()
        AppSettings.notificationStatus = saved
    }

    /// A launch with the toggles ON and nothing pending (a restore to a new
    /// phone) used to schedule nothing while Settings read ON.
    func testLaunchSchedulesRemindersThatAreOn() async {
        storeBothRemindersOn()
        await withNotifications(.authorized) {
            let settings = AppSettings(defaults: defaults)
            XCTAssertEqual(fake.added, [], "precondition: init schedules nothing")
            await settings.reconcileReminders()
        }
        XCTAssertEqual(fake.lastTrigger(dailyID)?.hour, 8)
        XCTAssertEqual(fake.lastTrigger(dailyID)?.minute, 15)
        XCTAssertEqual(fake.lastTrigger(gameNightID)?.weekday, 5)
        XCTAssertEqual(fake.lastTrigger(gameNightID)?.hour, 19)
    }

    /// With notifications off in iOS Settings nothing is scheduled and the
    /// player's choice is left alone, but they are told: the toggles used to
    /// read ON with nothing firing and no word why.
    func testLaunchWithNotificationsOffSaysSoAndKeepsTheChoice() async {
        storeBothRemindersOn()
        let settings = AppSettings(defaults: defaults)
        await withNotifications(.denied) {
            await settings.reconcileReminders()
        }
        XCTAssertEqual(fake.added, [])
        XCTAssertTrue(settings.reminderEnabled)
        XCTAssertTrue(settings.gameNightReminderEnabled)
        XCTAssertTrue(settings.reminderPermissionDenied, "Settings shows the Open Settings alert")
    }

    /// Only the game night reminder on counts too.
    func testGameNightReminderAloneRaisesTheDeniedAlert() async {
        defaults.set(true, forKey: "settings.gameNightReminderEnabled")
        let settings = AppSettings(defaults: defaults)
        await withNotifications(.denied) {
            await settings.reconcileReminders()
        }
        XCTAssertTrue(settings.reminderPermissionDenied)
    }

    /// Turned back on in iOS Settings before the alert was seen: the alert
    /// would now be false, and the reminders are scheduled again.
    func testNotificationsBackOnClearsTheAlert() async {
        storeBothRemindersOn()
        let settings = AppSettings(defaults: defaults)
        await withNotifications(.denied) {
            await settings.reconcileReminders()
        }
        XCTAssertTrue(settings.reminderPermissionDenied, "precondition")
        await withNotifications(.authorized) {
            await settings.reconcileReminders()
        }
        XCTAssertFalse(settings.reminderPermissionDenied)
        XCTAssertEqual(fake.lastTrigger(dailyID)?.hour, 8)
    }

    /// Never asked (a restore that reset the permission) is a different,
    /// held case: nothing changes and no alert shows.
    func testLaunchWithPermissionNotAskedChangesNothing() async {
        storeBothRemindersOn()
        let settings = AppSettings(defaults: defaults)
        await withNotifications(.notDetermined) {
            await settings.reconcileReminders()
        }
        XCTAssertEqual(fake.added, [])
        XCTAssertTrue(settings.reminderEnabled)
        XCTAssertFalse(settings.reminderPermissionDenied)
    }

    /// Notifications off with every reminder off is nobody's problem.
    func testNotificationsOffWithRemindersOffSaysNothing() async {
        let settings = AppSettings(defaults: defaults)
        await withNotifications(.denied) {
            await settings.reconcileReminders()
        }
        XCTAssertFalse(settings.reminderPermissionDenied)
    }

    /// The shipped authorization check, not the stand-in the other tests use.
    /// iOS answers `getNotificationSettings` on a background queue; a callback
    /// that inherited the main actor would trap there on every launch.
    func testRealNotificationCheckAnswersOffTheMainQueue() async {
        let allowed = await AppSettings.notificationsAllowed()
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        XCTAssertEqual(allowed, [.authorized, .provisional, .ephemeral].contains(status))
    }

    func testLaunchWithRemindersOffSchedulesNothing() async {
        let settings = AppSettings(defaults: defaults)
        await withNotifications(.authorized) {
            await settings.reconcileReminders()
        }
        XCTAssertEqual(fake.added, [])
    }
}
