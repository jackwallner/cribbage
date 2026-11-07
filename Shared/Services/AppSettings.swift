import SwiftUI
import UserNotifications

/// User-configurable app settings, persisted in UserDefaults.
/// Appearance defaults to the warm light theme regardless of the device style.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    enum Appearance: String, CaseIterable, Identifiable {
        case light, dark, system

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "Match Device"
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }

    enum GameNightDay: Int, CaseIterable, Identifiable {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

        var id: Int { rawValue }

        var displayName: String {
            switch self {
            case .sunday: return "Sunday"
            case .monday: return "Monday"
            case .tuesday: return "Tuesday"
            case .wednesday: return "Wednesday"
            case .thursday: return "Thursday"
            case .friday: return "Friday"
            case .saturday: return "Saturday"
            }
        }
    }

    private enum Keys {
        static let appearance = "settings.appearance"
        static let haptics = "settings.haptics"
        static let sound = "settings.sound"
        static let reminderEnabled = "settings.reminderEnabled"
        static let reminderHour = "settings.reminderHour"
        static let reminderMinute = "settings.reminderMinute"
        static let gameNightReminderEnabled = "settings.gameNightReminderEnabled"
        static let gameNightDay = "settings.gameNightDay"
        static let gameNightHour = "settings.gameNightHour"
        static let gameNightMinute = "settings.gameNightMinute"
    }

    private static let reminderID = "cribbage.dailyReminder"
    private static let gameNightReminderID = "cribbage.gameNightReminder"

    @Published var appearance: Appearance {
        didSet { defaults.set(appearance.rawValue, forKey: Keys.appearance) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Keys.haptics) }
    }

    @Published var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Keys.sound) }
    }

    @Published var reminderEnabled: Bool {
        didSet {
            defaults.set(reminderEnabled, forKey: Keys.reminderEnabled)
            if reminderEnabled {
                requestPermissionAndSchedule()
            } else {
                cancelReminder()
            }
        }
    }

    /// True when the player asked for a reminder but iOS notifications are off
    /// for the app. Without this the toggle just silently flips back, which
    /// looks like the app is broken.
    @Published var reminderPermissionDenied = false

    /// The picker's value, built from the stored hour and minute each time it
    /// is read. A `Date` kept from launch was an instant in the launch zone, so
    /// after a time zone change the picker showed another hour, and toggling
    /// the reminder off and on scheduled that hour.
    var reminderTime: Date {
        get { Self.time(hour: reminderHour, minute: reminderMinute) }
        set {
            objectWillChange.send()
            let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            defaults.set(parts.hour ?? 9, forKey: Keys.reminderHour)
            defaults.set(parts.minute ?? 0, forKey: Keys.reminderMinute)
            if reminderEnabled { scheduleReminder() }
        }
    }

    private var reminderHour: Int { defaults.object(forKey: Keys.reminderHour) as? Int ?? 9 }
    private var reminderMinute: Int { defaults.object(forKey: Keys.reminderMinute) as? Int ?? 0 }

    @Published var gameNightReminderEnabled: Bool {
        didSet {
            defaults.set(gameNightReminderEnabled, forKey: Keys.gameNightReminderEnabled)
            if gameNightReminderEnabled {
                requestPermissionAndScheduleGameNight()
            } else {
                cancelGameNightReminder()
            }
        }
    }

    @Published var gameNightDay: GameNightDay {
        didSet {
            defaults.set(gameNightDay.rawValue, forKey: Keys.gameNightDay)
            if gameNightReminderEnabled { scheduleGameNightReminder() }
        }
    }

    /// Built from the stored hour and minute on every read, like `reminderTime`.
    var gameNightReminderTime: Date {
        get { Self.time(hour: gameNightHour, minute: gameNightMinute) }
        set {
            objectWillChange.send()
            let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            defaults.set(parts.hour ?? 17, forKey: Keys.gameNightHour)
            defaults.set(parts.minute ?? 0, forKey: Keys.gameNightMinute)
            if gameNightReminderEnabled { scheduleGameNightReminder() }
        }
    }

    private var gameNightHour: Int { defaults.object(forKey: Keys.gameNightHour) as? Int ?? 17 }
    private var gameNightMinute: Int { defaults.object(forKey: Keys.gameNightMinute) as? Int ?? 0 }

    private static func time(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        appearance = Appearance(rawValue: defaults.string(forKey: Keys.appearance) ?? "") ?? .light
        hapticsEnabled = defaults.object(forKey: Keys.haptics) as? Bool ?? true
        soundEnabled = defaults.object(forKey: Keys.sound) as? Bool ?? true
        reminderEnabled = defaults.bool(forKey: Keys.reminderEnabled)
        gameNightReminderEnabled = defaults.bool(forKey: Keys.gameNightReminderEnabled)
        let savedDay = defaults.integer(forKey: Keys.gameNightDay)
        gameNightDay = GameNightDay(rawValue: savedDay) ?? .thursday
    }

    // MARK: - Reminder copy

    /// Generic on purpose. A repeating notification is static text, so any
    /// number in it goes stale for exactly the player who stops opening the
    /// app. Progress counts live on Home and Your Progress, where they are
    /// always current.
    static let dailyReminderBody = "Five minutes of practice keeps your discards calm and your count sharp."
    static let gameNightReminderBody = "Five personalized minutes now can make the table feel calmer later."

    // MARK: - Launch

    /// Whether iOS will deliver the app's notifications. Tests replace it.
    static var notificationsAllowed: () async -> Bool = {
        let status = await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
        return [.authorized, .provisional, .ephemeral].contains(status)
    }

    /// Schedules the reminders that are on, at launch and each return to the
    /// app. The toggles live in UserDefaults, which can outlast iOS's pending
    /// requests (a restore to a new phone), and then they read ON while
    /// nothing fires. Requests are replaced by id, so this is a no-op when
    /// they are already pending. The player's choice is never changed here.
    func reconcileReminders() async {
        guard reminderEnabled || gameNightReminderEnabled else { return }
        guard await Self.notificationsAllowed() else { return }
        if reminderEnabled { scheduleReminder() }
        if gameNightReminderEnabled { scheduleGameNightReminder() }
    }

    // MARK: - Daily reminder

    private func requestPermissionAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            Task { @MainActor in
                if granted {
                    self.scheduleReminder()
                } else {
                    self.reminderEnabled = false
                    self.reminderPermissionDenied = true
                }
            }
        }
    }

    private func scheduleReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.reminderID])

        let content = UNMutableNotificationContent()
        content.title = "Time for a quick drill"
        content.body = Self.dailyReminderBody
        content.sound = .default

        let parts = DateComponents(hour: reminderHour, minute: reminderMinute, second: 0)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: true)
        center.add(UNNotificationRequest(identifier: Self.reminderID, content: content, trigger: trigger))
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.reminderID])
    }

    // MARK: - Game night reminder

    private func requestPermissionAndScheduleGameNight() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            Task { @MainActor in
                if granted {
                    self.scheduleGameNightReminder()
                } else {
                    self.gameNightReminderEnabled = false
                    self.reminderPermissionDenied = true
                }
            }
        }
    }

    private func scheduleGameNightReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.gameNightReminderID])

        let content = UNMutableNotificationContent()
        content.title = "Your game night prep is ready"
        content.body = Self.gameNightReminderBody
        content.sound = .default
        content.userInfo = [AppNotification.routeKey: AppNotification.gameNightPrepValue]

        let parts = DateComponents(
            hour: gameNightHour, minute: gameNightMinute, second: 0, weekday: gameNightDay.rawValue
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: true)
        center.add(UNNotificationRequest(identifier: Self.gameNightReminderID, content: content, trigger: trigger))
    }

    func cancelGameNightReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.gameNightReminderID])
    }
}
