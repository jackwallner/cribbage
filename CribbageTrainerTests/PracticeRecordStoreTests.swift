import SwiftUI
import XCTest
@testable import CribbageTrainer

@MainActor
final class PracticeRecordStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var store: PracticeRecordStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "PracticeRecordStoreTests")!
        defaults.removePersistentDomain(forName: "PracticeRecordStoreTests")
        store = PracticeRecordStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "PracticeRecordStoreTests")
        super.tearDown()
    }

    private let room = "card-room"

    func testRecordsAccuracy() {
        store.record(itemID: "q1", roomID: room, correct: true)
        store.record(itemID: "q1", roomID: room, correct: false)
        let record = store.records["q1"]
        XCTAssertEqual(record?.attempts, 2)
        XCTAssertEqual(record?.correct, 1)
        XCTAssertEqual(record?.accuracy, 0.5)
    }

    /// A missed item goes into the queue; two clean answers retire it. Without
    /// the second condition an item would either nag forever or vanish on the
    /// first lucky guess.
    func testMissedItemEntersAndLeavesTheQueue() {
        let id = reviewItems[0].id
        store.record(itemID: id, roomID: room, correct: false)
        XCTAssertEqual(store.reviewQueue(), [id])

        store.record(itemID: id, roomID: room, correct: true)
        XCTAssertEqual(store.reviewQueue(), [], "One correct answer schedules it a day out")

        store.record(itemID: id, roomID: room, correct: true)
        XCTAssertFalse(store.records[id]!.needsReview, "Two in a row retires it")
    }

    func testQueueRanksWorstFirst() {
        let ids = reviewItems.prefix(2).map(\.id)
        for correct in [false, false, false] {
            store.record(itemID: ids[0], roomID: room, correct: correct)
        }
        store.record(itemID: ids[1], roomID: room, correct: true)
        store.record(itemID: ids[1], roomID: room, correct: false)
        XCTAssertEqual(store.reviewQueue().first, ids[0])
    }

    private var reviewItems: [QuickItem] {
        SessionBuilder.quickSession(count: Int.max, seen: [], missed: [], includePro: true)
            .sorted { $0.id < $1.id }
    }

    private var unsupportedIDs: [String] {
        DrillLibrary.rooms.flatMap(\.drills).flatMap { drill -> [String] in
            switch drill.kind {
            case .flashcards(let cards): return cards.filter { $0.choice == nil }.map(\.id)
            case .discard(let scenarios): return scenarios.map(\.id)
            default: return []
            }
        } + ["removed-item"]
    }

    func testUnsupportedMistakesStayOutOfReviewButKeepTheirHistory() {
        XCTAssertTrue(unsupportedIDs.contains("discard-scenario-1"))
        XCTAssertTrue(unsupportedIDs.contains("cards-deck"))
        for id in unsupportedIDs {
            store.record(itemID: id, roomID: room, correct: false)
        }
        let reloaded = PracticeRecordStore(defaults: defaults)
        XCTAssertEqual(reloaded.totalAttempts, unsupportedIDs.count)
        XCTAssertEqual(reloaded.dueCount, 0)
        XCTAssertTrue(reloaded.reviewQueue().isEmpty)
    }

    func testReviewFiltersBeforeLimitingAndBadgeMatchesPlayableItems() {
        XCTAssertGreaterThan(unsupportedIDs.count, 12)
        for id in unsupportedIDs {
            store.record(itemID: id, roomID: room, correct: false, now: .distantPast)
        }
        let playable = reviewItems
        XCTAssertGreaterThan(playable.count, 12)
        for item in playable {
            store.record(itemID: item.id, roomID: item.roomID, correct: false)
        }
        XCTAssertEqual(store.dueCount, playable.count)
        let queue = store.reviewQueue()
        XCTAssertEqual(queue.count, 12)
        XCTAssertEqual(SessionBuilder.reviewSession(ids: queue, includePro: true).map(\.id), queue)
        let allDue = store.reviewQueue(limit: Int.max)
        XCTAssertEqual(Set(allDue), Set(playable.map(\.id)))
        XCTAssertEqual(SessionBuilder.reviewSession(ids: allDue, includePro: true).count, store.dueCount)
    }

    func testEmptyReviewDoesNotRecordACompletedSession() async throws {
        let progress = ProgressStore(defaults: defaults)
        let controller = UIHostingController(rootView:
            NavigationStack {
                PracticeRunView(mode: .review)
            }
            .environmentObject(progress)
            .environmentObject(SubscriptionService.shared)
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        controller.view.layoutIfNeeded()
        try await Task.sleep(for: .milliseconds(300))
        XCTAssertEqual(progress.totalSessions, 0)
        XCTAssertEqual(progress.completions(for: SessionBuilder.reviewDrill.id), 0)
        XCTAssertEqual(progress.streakCount, 0)
    }

    /// Generated items mint a new id per question. They must roll up onto one
    /// per-skill row and must never enter the review queue, or the queue would
    /// fill with questions that can never be shown again.
    func testGeneratedItemsCollapseAndStayOutOfTheQueue() {
        let prefix = PracticeSkill.handReading.itemPrefix
        store.record(itemID: prefix + "a", roomID: room, correct: false)
        store.record(itemID: prefix + "b", roomID: room, correct: true)

        XCTAssertEqual(store.records.count, 1)
        XCTAssertEqual(store.records[PracticeSkill.handReading.rawValue]?.attempts, 2)
        XCTAssertTrue(store.reviewQueue().isEmpty)
        XCTAssertEqual(store.dueCount, 0)
    }

    func testRoomStatsAggregate() {
        store.record(itemID: "q1", roomID: "card-room", correct: true)
        store.record(itemID: "q2", roomID: "card-room", correct: false)
        store.record(itemID: "q3", roomID: "scoring-room", correct: true)

        let stats = store.roomStats()
        XCTAssertEqual(stats.count, 2)
        let cardRoom = stats.first { $0.id == "card-room" }
        XCTAssertEqual(cardRoom?.attempts, 2)
        XCTAssertEqual(cardRoom?.accuracy, 0.5)
        XCTAssertEqual(store.overallAccuracy, 2.0 / 3.0, accuracy: 0.0001)
    }

    func testChallengeScoreKeepsTheBest() {
        store.recordChallengeScore(12)
        store.recordChallengeScore(7)
        XCTAssertEqual(store.bestChallengeScore, 12)
    }

    func testPersistsAcrossInstances() {
        store.record(itemID: "q1", roomID: room, correct: true)
        let reloaded = PracticeRecordStore(defaults: defaults)
        XCTAssertEqual(reloaded.records["q1"]?.attempts, 1)
    }

    func testResetClearsEverything() {
        store.record(itemID: "q1", roomID: room, correct: true)
        store.recordChallengeScore(9)
        store.resetAll()
        XCTAssertTrue(store.records.isEmpty)
        XCTAssertEqual(store.bestChallengeScore, 0)
        XCTAssertTrue(PracticeRecordStore(defaults: defaults).records.isEmpty)
    }
}

final class WhatsNewTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "WhatsNewTests")!
        defaults.removePersistentDomain(forName: "WhatsNewTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "WhatsNewTests")
        super.tearDown()
    }

    func testNeverShownBeforeOnboarding() {
        XCTAssertFalse(WhatsNew.shouldPresent(hasOnboarded: false, defaults: defaults))
    }

    /// A player updating from a build that predates the feature has no stored
    /// marker at all. That is exactly who the sheet is for, WHEN the running
    /// version has notes. A maintenance release deliberately ships none, and
    /// then nobody is shown an empty sheet.
    func testShownToAnUpgraderWithNoMarker() {
        guard WhatsNew.currentRelease != nil else {
            XCTAssertFalse(WhatsNew.shouldPresent(hasOnboarded: true, defaults: defaults))
            return
        }
        XCTAssertTrue(WhatsNew.shouldPresent(hasOnboarded: true, defaults: defaults))
    }

    func testShownOnlyOnce() {
        WhatsNew.markSeen(defaults: defaults)
        XCTAssertFalse(WhatsNew.shouldPresent(hasOnboarded: true, defaults: defaults))
    }

    func testFreshInstallBaselineSuppressesIt() {
        WhatsNew.markCurrentAsBaseline(defaults: defaults)
        XCTAssertFalse(WhatsNew.shouldPresent(hasOnboarded: true, defaults: defaults))
    }

    /// Checks EVERY authored release, not just the running one. The old version
    /// unwrapped `currentRelease` and failed outright on a maintenance build
    /// that ships no notes, which said nothing about the copy it was meant to
    /// guard; this way the em dash and duplicate-id checks cover the whole file.
    func testReleaseNotesAreWellFormed() {
        XCTAssertFalse(WhatsNew.releases.isEmpty)
        XCTAssertEqual(Set(WhatsNew.releases.map(\.version)).count, WhatsNew.releases.count)
        for release in WhatsNew.releases {
            XCTAssertFalse(release.version.isEmpty)
            XCTAssertFalse(release.headline.isEmpty)
            XCTAssertFalse(release.headline.contains("\u{2014}"), "No em dash in copy")
            XCTAssertFalse(release.items.isEmpty)
            XCTAssertEqual(Set(release.items.map(\.id)).count, release.items.count)
            for item in release.items {
                XCTAssertFalse(item.title.isEmpty)
                XCTAssertFalse(item.body.isEmpty)
                XCTAssertFalse(item.body.contains("\u{2014}"), "No em dash in copy")
            }
        }
    }

    /// The sheet reads `currentRelease`: the newest entry at or below the
    /// bundle's version, so an entry authored for a later version never shows.
    func testCurrentReleaseIsNotNewerThanTheRunningVersion() {
        guard let release = WhatsNew.currentRelease else { return }
        XCTAssertFalse(WhatsNew.isOlder(WhatsNew.currentVersion, than: release.version))
    }

    /// A player who skipped a version still sees the last notes, once; a
    /// player who already saw them does not see them again on a patch build.
    func testPatchReleaseCarriesTheLastNotesOnce() {
        guard let release = WhatsNew.currentRelease else { return }
        defaults.set("1.0", forKey: "whatsnew.lastSeenVersion")
        XCTAssertEqual(
            WhatsNew.shouldPresent(hasOnboarded: true, defaults: defaults),
            WhatsNew.isOlder("1.0", than: release.version)
        )
        defaults.set(release.version, forKey: "whatsnew.lastSeenVersion")
        XCTAssertFalse(WhatsNew.shouldPresent(hasOnboarded: true, defaults: defaults))
        XCTAssertTrue(WhatsNew.isOlder("1.4.1", than: "1.4.10"))
    }
}
