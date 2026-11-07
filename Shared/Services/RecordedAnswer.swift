import Foundation

/// One graded answer, recorded so it can be taken back.
///
/// Flashcard Undo puts a card back in play. Without this the undone answer
/// stayed in both stores and the replacement counted as a second attempt, so
/// right, Undo, right read as known and a miss that was undone kept the item
/// in review.
@MainActor
struct RecordedAnswer {
    let itemID: String
    private let previousRecord: PracticeRecord?
    private let wasSeen: Bool
    private let wasMissed: Bool

    static func record(
        itemID: String,
        roomID: String,
        correct: Bool,
        progress: ProgressStore,
        records: PracticeRecordStore
    ) -> RecordedAnswer {
        let answer = RecordedAnswer(
            itemID: itemID,
            previousRecord: records.record(forItemID: itemID),
            wasSeen: progress.seenItems.contains(itemID),
            wasMissed: progress.missedItems.contains(itemID)
        )
        progress.recordItem(id: itemID, correct: correct)
        records.record(itemID: itemID, roomID: roomID, correct: correct)
        return answer
    }

    /// Puts both stores back as they were before this answer.
    func undo(progress: ProgressStore, records: PracticeRecordStore) {
        progress.restoreItem(id: itemID, seen: wasSeen, missed: wasMissed)
        records.restore(itemID: itemID, to: previousRecord)
    }
}
