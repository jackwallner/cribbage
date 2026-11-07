import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var streakCount: Int
    @Published private(set) var totalSessions: Int
    @Published private(set) var completions: [String: Int]
    @Published private(set) var seenItems: Set<String>
    @Published private(set) var missedItems: Set<String>

    private let defaults: UserDefaults

    private enum Keys {
        static let streakCount = "progress.streakCount"
        /// Legacy: the start of the day as an instant. Read back in a different
        /// zone it named the wrong date, so only upgraders still have it.
        static let lastActiveDay = "progress.lastActiveDay"
        static let lastActiveDayNumber = "progress.lastActiveDayNumber"
        static let totalSessions = "progress.totalSessions"
        static let completions = "progress.completions"
        static let hasOnboarded = "progress.hasOnboarded"
        static let reviewGateShown = "progress.reviewGateShown"
        static let seenItems = "progress.seenItems"
        static let missedItems = "progress.missedItems"
        static let lastQuickSessionDay = "progress.lastQuickSessionDay"
        static let lastQuickSessionDayNumber = "progress.lastQuickSessionDayNumber"
        static let sessionsAtOnboarding = "progress.sessionsAtOnboarding"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        streakCount = defaults.integer(forKey: Keys.streakCount)
        totalSessions = defaults.integer(forKey: Keys.totalSessions)
        completions = (defaults.dictionary(forKey: Keys.completions) as? [String: Int]) ?? [:]
        seenItems = Set(defaults.stringArray(forKey: Keys.seenItems) ?? [])
        missedItems = Set(defaults.stringArray(forKey: Keys.missedItems) ?? [])
    }

    var hasOnboarded: Bool {
        get { defaults.bool(forKey: Keys.hasOnboarded) }
        set { defaults.set(newValue, forKey: Keys.hasOnboarded) }
    }

    /// Sessions finished before onboarding ended: the tour's closing
    /// practice. Players who onboarded earlier have none stored (0).
    var sessionsAtOnboarding: Int {
        get { defaults.integer(forKey: Keys.sessionsAtOnboarding) }
        set { defaults.set(newValue, forKey: Keys.sessionsAtOnboarding) }
    }

    /// True once the player has finished a practice of their own after
    /// onboarding. Home's extras wait for it, so the first Home after the tour
    /// is the plain lobby.
    var hasPracticedSinceOnboarding: Bool { totalSessions > sessionsAtOnboarding }

    func completions(for drillID: String) -> Int {
        completions[drillID] ?? 0
    }

    func roomProgress(_ room: Room) -> Double {
        guard !room.drills.isEmpty else { return 0 }
        let done = room.drills.filter { completions(for: $0.id) > 0 }.count
        return Double(done) / Double(room.drills.count)
    }

    func recordSession(drillID: String, now: Date = Date()) {
        completions[drillID, default: 0] += 1
        totalSessions += 1
        bumpStreak(now: now)
        defaults.set(completions, forKey: Keys.completions)
        defaults.set(totalSessions, forKey: Keys.totalSessions)
    }

    /// The streak as it stands right now. `streakCount` only changes when a
    /// drill is finished, so after a missed day it still held the old number
    /// and Home showed a streak the player had already lost.
    func currentStreak(now: Date = Date()) -> Int {
        guard let last = storedDay(Keys.lastActiveDayNumber, legacy: Keys.lastActiveDay) else { return streakCount }
        return Self.dayNumber(now) - last > 1 ? 0 : streakCount
    }

    /// The calendar date of `date` in the player's time zone, as a day count.
    ///
    /// Days are stored as this number, not as a start-of-day instant: an
    /// instant read back after a flight west named the previous date, so a
    /// streak practised the day before and the day after broke. Comparing
    /// date numbers, not instants, also keeps the 23 hour day where daylight
    /// saving starts at midnight (Chile, Cuba, Egypt, Lebanon, the Azores)
    /// one day long.
    private static func dayNumber(_ date: Date) -> Int {
        // The Gregorian date in the device zone, read back as noon UTC, which
        // has no daylight saving to lose an hour to.
        var local = Calendar(identifier: .gregorian)
        local.timeZone = Calendar.current.timeZone
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let parts = local.dateComponents([.year, .month, .day], from: date)
        let noon = utc.date(from: DateComponents(year: parts.year, month: parts.month, day: parts.day, hour: 12)) ?? date
        return Int((noon.timeIntervalSince1970 / 86_400).rounded(.down))
    }

    /// The stored day number, or for players upgrading from a build that
    /// stored an instant, that instant's date in the current zone (what the
    /// old build read).
    private func storedDay(_ key: String, legacy: String) -> Int? {
        if let day = defaults.object(forKey: key) as? Int { return day }
        guard let date = defaults.object(forKey: legacy) as? Date else { return nil }
        return Self.dayNumber(date)
    }

    /// Streak counts consecutive calendar days with at least one finished drill.
    private func bumpStreak(now: Date) {
        let today = Self.dayNumber(now)
        let last = storedDay(Keys.lastActiveDayNumber, legacy: Keys.lastActiveDay)

        if let last {
            let gap = today - last
            if gap == 1 {
                streakCount += 1
            } else if gap > 1 {
                streakCount = 1
            } else if gap < 0 {
                // The clock went backwards (travel, a manual change). Keep the
                // later day so the streak is not counted twice on the way back.
                return
            } // gap == 0: same day, streak unchanged
        } else {
            streakCount = 1
        }
        defaults.set(today, forKey: Keys.lastActiveDayNumber)
        defaults.removeObject(forKey: Keys.lastActiveDay)
        defaults.set(streakCount, forKey: Keys.streakCount)
    }

    /// Item-level memory that feeds the Get Started mix: anything answered wrong
    /// (or self-graded "again") comes back first; unseen items come next.
    func recordItem(id: String, correct: Bool) {
        seenItems.insert(id)
        if correct {
            missedItems.remove(id)
        } else {
            missedItems.insert(id)
        }
        defaults.set(Array(seenItems), forKey: Keys.seenItems)
        defaults.set(Array(missedItems), forKey: Keys.missedItems)
    }

    // MARK: - Daily Quick Session

    /// Get Started is a once-a-day ritual: a fresh mix each day, and once
    /// today's is done the Home card rests until tomorrow rather than handing
    /// back the same questions (repeating a question you just answered teaches
    /// nothing). Missed items still return on later days as spaced repetition.
    func quickSessionCompletedToday(now: Date = Date()) -> Bool {
        storedDay(Keys.lastQuickSessionDayNumber, legacy: Keys.lastQuickSessionDay) == Self.dayNumber(now)
    }

    func markQuickSessionCompleted(now: Date = Date()) {
        defaults.set(Self.dayNumber(now), forKey: Keys.lastQuickSessionDayNumber)
        defaults.removeObject(forKey: Keys.lastQuickSessionDay)
    }

    /// Clears every practice stat. Leaves onboarding and purchases alone.
    func resetAll() {
        streakCount = 0
        totalSessions = 0
        completions = [:]
        seenItems = []
        missedItems = []
        defaults.removeObject(forKey: Keys.streakCount)
        defaults.removeObject(forKey: Keys.lastActiveDay)
        defaults.removeObject(forKey: Keys.lastActiveDayNumber)
        defaults.removeObject(forKey: Keys.totalSessions)
        defaults.removeObject(forKey: Keys.completions)
        defaults.removeObject(forKey: Keys.seenItems)
        defaults.removeObject(forKey: Keys.missedItems)
        defaults.removeObject(forKey: Keys.reviewGateShown)
        defaults.removeObject(forKey: Keys.lastQuickSessionDay)
        defaults.removeObject(forKey: Keys.lastQuickSessionDayNumber)
        defaults.removeObject(forKey: Keys.sessionsAtOnboarding)
    }
}
