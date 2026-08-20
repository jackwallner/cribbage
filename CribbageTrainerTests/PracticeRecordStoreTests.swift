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
        store.record(itemID: "q1", roomID: room, correct: false)
        XCTAssertEqual(store.reviewQueue(), ["q1"])

        store.record(itemID: "q1", roomID: room, correct: true)
        XCTAssertEqual(store.reviewQueue(), [], "One correct answer schedules it a day out")

        store.record(itemID: "q1", roomID: room, correct: true)
        XCTAssertFalse(store.records["q1"]!.needsReview, "Two in a row retires it")
    }

    func testQueueRanksWorstFirst() {
        // q1: 1 of 3. q2: 2 of 3. Both due, q1 should lead.
        for correct in [false, false, false] {
            store.record(itemID: "q1", roomID: room, correct: correct)
        }
        store.record(itemID: "q2", roomID: room, correct: true)
        store.record(itemID: "q2", roomID: room, correct: false)
        XCTAssertEqual(store.reviewQueue().first, "q1")
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

    /// The running version may or may not have notes, but if it does they have
    /// to be the ones that will actually render.
    func testCurrentReleaseMatchesTheRunningVersion() {
        guard let release = WhatsNew.currentRelease else { return }
        XCTAssertEqual(release.version, WhatsNew.currentVersion)
    }
}
