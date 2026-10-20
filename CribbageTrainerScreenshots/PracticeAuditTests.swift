import XCTest

/// Audit walkthroughs of the generated-practice flow, captured as screenshots.
/// Like ScreenshotTests this never calls XCTFail, so one run reports what it
/// could and could not reach instead of stalling on simulator diagnostics.
@MainActor
final class PracticeAuditTests: XCTestCase {
    private var app: XCUIApplication!

    private static let seededTopics = "<7b2268616e6452656164696e672e72756e73223a7b22617474656d707473223a352c22636f7272656374223a317d2c2270656753636f72652e70616972223a7b22617474656d707473223a362c22636f7272656374223a327d7d>"
    private static let seededRecords = "<7b2273636f72696e672d726f6f6d2d78223a7b22617474656d707473223a31322c22636f7272656374223a372c2273747265616b223a302c226c617374416e737765726564223a302c2264756544617465223a302c22696e74657276616c44617973223a302c2265617365223a322e352c22726f6f6d4944223a2273636f72696e672d726f6f6d227d2c2270656767696e672d78223a7b22617474656d707473223a382c22636f7272656374223a362c2273747265616b223a312c226c617374416e737765726564223a302c2264756544617465223a343030303030303030302c22696e74657276616c44617973223a312c2265617365223a322e352c22726f6f6d4944223a2270656767696e672d726f6f6d227d7d>"

    private func launch(largeText: Bool = false, seeded: Bool = false) {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = [
            "-progress.hasOnboarded", "YES",
            "-cribbage.hasReadPrimer", "YES",
            "-cribbage.skillLevel", "some",
            "-subscription.localProOverride", "YES",
            "-whatsnew.lastSeenVersion", ProcessInfo.processInfo.environment["SCREENSHOT_APP_VERSION"] ?? "1.3.0",
        ]
        if seeded {
            app.launchArguments += ["-practice.topics", Self.seededTopics, "-practice.records", Self.seededRecords]
        }
        if largeText {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXL"]
        }
        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 30)
        settle(2)
    }

    func testEndlessFlowBeginner() {
        launch(seeded: true)
        capture("a01_home")
        guard tap("Endless") else { return }
        capture("a02_picker_with_coaching")
        guard tap("Count the Hand") else { return }
        capture("a03_count_hand_question")
        answerFirstChoice()
        capture("a04_count_hand_explained")
        goBack()
        goBack()
        if tap("Endless"), tap("Pegging Points") {
            capture("a05_pegging_points_question")
            answerFirstChoice()
            capture("a06_pegging_points_explained")
        }
    }

    func testStatsShowsSharpenCard() {
        launch(seeded: true)
        let gear = app.navigationBars.buttons.element(boundBy: 0)
        _ = gear
        if tap("day streak") {
            capture("b01_stats")
            app.swipeUp()
            settle(1)
            capture("b02_stats_scrolled")
        }
    }

    func testLargerTextEndless() {
        launch(largeText: true, seeded: true)
        capture("c01_home_large_text")
        guard tap("Endless") else { return }
        capture("c02_picker_large_text")
        guard tap("Count the Hand") else { return }
        capture("c03_count_hand_large_text")
        answerFirstChoice()
        capture("c04_count_hand_explained_large_text")
    }

    // MARK: - Helpers

    @discardableResult
    private func tap(_ label: String) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", label)
        for query in [app.buttons, app.staticTexts] {
            let match = query.matching(predicate).firstMatch
            guard match.waitForExistence(timeout: 6) else { continue }
            match.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            settle()
            return true
        }
        let note = XCTAttachment(string: "could not find: \(label)\n\(app.debugDescription)")
        note.name = "missing-\(label)"
        note.lifetime = .keepAlways
        add(note)
        return false
    }

    private func answerFirstChoice() {
        let height = max(app.windows.firstMatch.frame.height, 1)
        let excluded = ["Settings", "Back", "Next", "Finish", "Close"]
        let choice = app.buttons.allElementsBoundByIndex.first { element in
            !element.label.isEmpty
                && !excluded.contains(element.label)
                && element.frame.midY > height * 0.30
                && element.frame.midY < height * 0.85
        }
        choice?.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        settle()
    }

    private func goBack() {
        let back = app.navigationBars.buttons.element(boundBy: 0)
        if back.exists { back.tap() }
        settle(0.8)
    }

    private func settle(_ seconds: TimeInterval = 1.6) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func capture(_ name: String) {
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
