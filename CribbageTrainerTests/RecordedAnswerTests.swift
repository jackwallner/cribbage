import XCTest
@testable import CribbageTrainer

/// Flashcard Undo (`FlashcardDrillView.undo`) takes back the answer it undoes,
/// so the answer given after it is the only one counted.
@MainActor
final class RecordedAnswerTests: XCTestCase {
    private let suite = "RecordedAnswerTests"
    private var defaults: UserDefaults!
    private var progress: ProgressStore!
    private var records: PracticeRecordStore!
    private let item = "keep-discard-1"
    private let room = "pegging-room"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        progress = ProgressStore(defaults: defaults)
        records = PracticeRecordStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
        super.tearDown()
    }

    private func answer(_ correct: Bool) -> RecordedAnswer {
        RecordedAnswer.record(itemID: item, roomID: room, correct: correct, progress: progress, records: records)
    }

    /// Right, Undo, right is one real pass, not two right answers in a row.
    func testRightUndoRightIsNotKnown() throws {
        answer(true).undo(progress: progress, records: records)
        _ = answer(true)
        let record = try XCTUnwrap(records.records[item])
        XCTAssertEqual(record.attempts, 1)
        XCTAssertFalse(record.isKnown(), "an undone answer must not count toward known")
    }

    /// AGAIN, Undo, KNEW IT leaves no miss behind.
    func testUndoneMissIsForgotten() throws {
        answer(false).undo(progress: progress, records: records)
        _ = answer(true)
        let record = try XCTUnwrap(records.records[item])
        XCTAssertEqual(record.attempts, 1)
        XCTAssertEqual(record.correct, 1)
        XCTAssertFalse(record.needsReview)
        XCTAssertFalse(progress.missedItems.contains(item))
        XCTAssertTrue(progress.seenItems.contains(item))
    }

    /// Undoing the first answer ever leaves the item unseen, and the restore
    /// is persisted.
    func testUndoingAFirstAnswerLeavesNoTrace() {
        answer(false).undo(progress: progress, records: records)
        XCTAssertNil(records.records[item])
        XCTAssertFalse(progress.seenItems.contains(item))
        XCTAssertFalse(progress.missedItems.contains(item))
        XCTAssertNil(PracticeRecordStore(defaults: defaults).records[item])
        XCTAssertFalse(ProgressStore(defaults: defaults).missedItems.contains(item))
    }

    /// Earlier history survives an undo: a missed item answered right, then
    /// undone, is still missed with its old counts.
    func testUndoRestoresEarlierHistory() throws {
        _ = answer(false)
        let before = try XCTUnwrap(records.records[item])
        answer(true).undo(progress: progress, records: records)
        let after = try XCTUnwrap(records.records[item])
        XCTAssertEqual(after.attempts, before.attempts)
        XCTAssertEqual(after.correct, before.correct)
        XCTAssertEqual(after.streak, before.streak)
        XCTAssertEqual(after.dueDate, before.dueDate)
        XCTAssertTrue(progress.missedItems.contains(item))
    }

    /// The card re-queued by AGAIN is picked again before Undo: Undo takes
    /// back the pick first, then the swipe, and ends where the deck began.
    func testUndoOfAPendingPickThenTheSwipeRestoresTheStart() {
        let swipe = answer(false)
        let pick = answer(true)
        pick.undo(progress: progress, records: records)
        swipe.undo(progress: progress, records: records)
        XCTAssertNil(records.records[item])
        XCTAssertFalse(progress.seenItems.contains(item))
    }
}
