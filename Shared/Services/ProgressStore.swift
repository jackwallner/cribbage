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
        static let lastActiveDay = "progress.lastActiveDay"
        static let totalSessions = "progress.totalSessions"
        static let completions = "progress.completions"
        static let hasOnboarded = "progress.hasOnboarded"
        static let reviewGateShown = "progress.reviewGateShown"
        static let seenItems = "progress.seenItems"
        static let missedItems = "progress.missedItems"
        static let lastQuickSessionDay = "progress.lastQuickSessionDay"
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
        guard let last = defaults.object(forKey: Keys.lastActiveDay) as? Date else { return streakCount }
        return Self.calendarDays(from: last, to: now) > 1 ? 0 : streakCount
    }

    /// Whole calendar days from `earlier` to `later` in the player's time zone.
    ///
    /// Compares calendar dates, not the distance between two start-of-day
    /// instants. Where daylight saving starts at midnight (Chile, Cuba, Egypt,
    /// Lebanon, the Azores) that day begins at 01:00 and lasts 23 hours, so the
    /// next day was 0 days from it and the one after only 1, and the streak
    /// neither grew nor broke on the day it should.
    private static func calendarDays(from earlier: Date, to later: Date) -> Int {
        // Gregorian dates in the zone `Calendar.current.startOfDay` uses (how
        // `lastActiveDay` is stored), each read back as noon UTC, which has no
        // daylight saving to lose an hour to.
        var local = Calendar(identifier: .gregorian)
        local.timeZone = Calendar.current.timeZone
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        func dayNumber(_ date: Date) -> Int {
            let parts = local.dateComponents([.year, .month, .day], from: date)
            let noon = utc.date(from: DateComponents(year: parts.year, month: parts.month, day: parts.day, hour: 12)) ?? date
            return Int((noon.timeIntervalSince1970 / 86_400).rounded(.down))
        }
        return dayNumber(later) - dayNumber(earlier)
    }

    /// Streak counts consecutive calendar days with at least one finished drill.
    private func bumpStreak(now: Date) {
        let today = Calendar.current.startOfDay(for: now)
        let last = defaults.object(forKey: Keys.lastActiveDay) as? Date

        if let last {
            let gap = Self.calendarDays(from: last, to: now)
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
        defaults.set(today, forKey: Keys.lastActiveDay)
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
        guard let last = defaults.object(forKey: Keys.lastQuickSessionDay) as? Date else { return false }
        return Calendar.current.isDate(last, inSameDayAs: now)
    }

    func markQuickSessionCompleted(now: Date = Date()) {
        defaults.set(Calendar.current.startOfDay(for: now), forKey: Keys.lastQuickSessionDay)
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
        defaults.removeObject(forKey: Keys.totalSessions)
        defaults.removeObject(forKey: Keys.completions)
        defaults.removeObject(forKey: Keys.seenItems)
        defaults.removeObject(forKey: Keys.missedItems)
        defaults.removeObject(forKey: Keys.reviewGateShown)
        defaults.removeObject(forKey: Keys.lastQuickSessionDay)
        defaults.removeObject(forKey: Keys.sessionsAtOnboarding)
    }
}
