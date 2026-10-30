import Foundation

/// One line on the What's New sheet.
struct WhatsNewItem: Identifiable, Sendable {
    let id: String
    let icon: String
    let title: String
    let body: String
    /// Marks the line as membership content, so the sheet can badge it and a
    /// free player can see exactly what the upgrade would hand them.
    let isPlus: Bool

    init(id: String, icon: String, title: String, body: String, isPlus: Bool = false) {
        self.id = id
        self.icon = icon
        self.title = title
        self.body = body
        self.isPlus = isPlus
    }
}

struct WhatsNewRelease: Sendable {
    let version: String
    let headline: String
    let items: [WhatsNewItem]
}

/// Decides whether to show the post-update What's New sheet, and remembers
/// that it has been shown.
///
/// The rule that matters: a FRESH install never sees it. Onboarding already
/// introduces the app, and opening a brand-new download with "here's what
/// changed" is nonsense. Only a player who had an older version installed gets
/// the sheet, once, on the first launch after updating.
enum WhatsNew {

    static let currentVersion: String =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"

    private static let lastSeenKey = "whatsnew.lastSeenVersion"

    static let releases: [WhatsNewRelease] = [
        WhatsNewRelease(
            version: "1.3.0",
            headline: String(localized: "Count it, peg it, fix it"),
            items: [
                WhatsNewItem(
                    id: "count-hand",
                    icon: "sum",
                    title: String(localized: "Count the Hand"),
                    body: String(localized: "Endless four-card hands with a starter. Add up fifteens, pairs, runs, flushes and nobs, then see exactly where every point came from."),
                    isPlus: true
                ),
                WhatsNewItem(
                    id: "peg-points",
                    icon: "target",
                    title: String(localized: "Pegging Points"),
                    body: String(localized: "Play a card onto the pile and score it: fifteen, thirty-one, pairs and runs in any order."),
                    isPlus: true
                ),
                WhatsNewItem(
                    id: "sharpen",
                    icon: "chart.bar.fill",
                    title: String(localized: "Know what to sharpen"),
                    body: String(localized: "Your progress now names the exact skills you miss, like spotting runs, and Endless Practice flags them.")
                ),
                WhatsNewItem(
                    id: "weekly-gain",
                    icon: "arrow.up.right",
                    title: String(localized: "See your week"),
                    body: String(localized: "Home and Your Progress show how many questions you locked in this week, so you can tell the practice is working.")
                ),
            ]
        ),
        WhatsNewRelease(
            version: "1.2.0",
            headline: String(localized: "A smarter rhythm for cribbage night"),
            items: [
                WhatsNewItem(
                    id: "cribbage-minute",
                    icon: "calendar.badge.clock",
                    title: String(localized: "Cribbage Minute"),
                    body: String(localized: "Take the same five-question challenge as every other member, share your score, and keep a forgiving five-day weekly rhythm."),
                    isPlus: true
                ),
                WhatsNewItem(
                    id: "game-night-prep",
                    icon: "person.2.fill",
                    title: String(localized: "Game Night Prep"),
                    body: String(localized: "Choose your usual cribbage night and get a five-minute session built from your mistakes and weakest room when it matters."),
                    isPlus: true
                ),
                WhatsNewItem(
                    id: "ipad",
                    icon: "ipad.landscape",
                    title: String(localized: "Made for iPad"),
                    body: String(localized: "Practice at the table with a native iPad layout in portrait or landscape.")
                ),
            ]
        ),
        WhatsNewRelease(
            version: "1.0",
            headline: String(localized: "Learn the hand, one rep at a time"),
            items: [
                WhatsNewItem(
                    id: "rooms",
                    icon: "rectangle.grid.2x2.fill",
                    title: String(localized: "Four free practice rooms"),
                    body: String(localized: "Build confidence with focused drills for cards, scoring, discards, and pegging.")
                ),
                WhatsNewItem(
                    id: "coaching",
                    icon: "lightbulb.fill",
                    title: String(localized: "Explanations that stick"),
                    body: String(localized: "Every answer shows the rule, the observation, and why the choice works at the table.")
                ),
                WhatsNewItem(
                    id: "progress",
                    icon: "chart.bar.fill",
                    title: String(localized: "Practice that remembers"),
                    body: String(localized: "Streaks, missed items, and a daily mixed session help you keep the useful parts in reach.")
                ),
            ]
        ),
        WhatsNewRelease(
            version: "1.1",
            headline: String(localized: "Practice that never runs out"),
            items: [
                WhatsNewItem(
                    id: "endless",
                    icon: "infinity",
                    title: String(localized: "Endless Practice"),
                    body: String(localized: "Freshly dealt hands, every time. Read the scoring shape or practice the running total for as long as you like, with a full explanation after every answer."),
                    isPlus: true
                ),
                WhatsNewItem(
                    id: "review",
                    icon: "arrow.trianglehead.counterclockwise",
                    title: String(localized: "Fix My Mistakes"),
                    body: String(localized: "The app now remembers what you get wrong and brings it back on a schedule, so the weak spots actually close instead of piling up."),
                    isPlus: true
                ),
                WhatsNewItem(
                    id: "challenge",
                    icon: "timer",
                    title: String(localized: "Timed Challenge"),
                    body: String(localized: "Ninety seconds, as many correct reads as you can manage, and a personal best to chase."),
                    isPlus: true
                ),
                WhatsNewItem(
                    id: "stats",
                    icon: "chart.bar.fill",
                    title: String(localized: "Your progress, in detail"),
                    body: String(localized: "Accuracy for every room, your weakest area, and how much you have practised overall.")
                ),
                WhatsNewItem(
                    id: "content",
                    icon: "plus.rectangle.on.folder.fill",
                    title: String(localized: "More drills in every room"),
                    body: String(localized: "New hand-written questions across the deck, scoring, discards, pegging, and the Master Tables.")
                ),
            ]
        )
    ]

    /// The newest notes at or below the running version, so a release with
    /// no entry of its own still carries the last notes to a player updating
    /// straight past the version that had them.
    static var currentRelease: WhatsNewRelease? {
        releases
            .filter { !isOlder(currentVersion, than: $0.version) }
            .max { isOlder($0.version, than: $1.version) }
    }

    static func isOlder(_ version: String, than other: String) -> Bool {
        version.compare(other, options: .numeric) == .orderedAscending
    }

    /// True when this launch is the first one after an update and there are
    /// notes to show for the version now running.
    static func shouldPresent(hasOnboarded: Bool, defaults: UserDefaults = .standard) -> Bool {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-cribbage.suppressWhatsNew") { return false }
        #endif
        guard hasOnboarded, let release = currentRelease else { return false }
        let lastSeen = defaults.string(forKey: lastSeenKey) ?? ""
        // An empty marker on an onboarded player means they updated from a
        // build that predates this feature. That is exactly the audience.
        // Anyone who last saw these notes' version or later has read them.
        return lastSeen.isEmpty || isOlder(lastSeen, than: release.version)
    }

    static func markSeen(defaults: UserDefaults = .standard) {
        defaults.set(currentVersion, forKey: lastSeenKey)
    }

    /// Set when the sheet shows. Apple's tracking prompt waits for the next
    /// launch, so an updating player is not hit with both back to back.
    @MainActor static var shownThisLaunch = false

    /// Called when onboarding finishes so a new player is never shown notes
    /// for a version they have only ever run.
    static func markCurrentAsBaseline(defaults: UserDefaults = .standard) {
        defaults.set(currentVersion, forKey: lastSeenKey)
    }
}
