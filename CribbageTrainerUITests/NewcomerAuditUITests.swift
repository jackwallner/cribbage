import XCTest

/// Persona audit walkthrough: a first-time player who does not know cribbage
/// terms and wants one useful result immediately. Fresh install, no launch
/// arguments that skip anything. Never fails on a missing element (a failing
/// UI test spends minutes collecting diagnostics); it records what it could
/// not find in the `log` attachment instead.
@MainActor
final class NewcomerAuditUITests: XCTestCase {
    private var app: XCUIApplication!
    private var log: [String] = []
    private var started = Date()
    private var taps = 0

    override func setUp() {
        continueAfterFailure = true
    }

    func testNewcomerFirstRunBrandNew() {
        walkthrough(skill: "Brand new")
    }

    // MARK: - Flow

    private func walkthrough(skill: String) {
        app = XCUIApplication(bundleIdentifier: "com.jackwallner.cribbage")
        app.launch()
        started = Date()
        _ = app.wait(for: .runningForeground, timeout: 30)
        settle()
        note("launched")

        // Onboarding value pages 0-2, skill page 3, trial page 4.
        shot("01_onboard_p0")
        dumpTexts("onboard_p0")
        for page in 1...2 {
            tapButton("Continue")
            shot("01_onboard_p\(page)")
        }
        tapButton("Continue")
        shot("02_skill_empty")
        let continueDisabled = app.buttons["Continue"].firstMatch
        note("skill page Continue enabled before pick: \(continueDisabled.isEnabled)")
        tapText(skill)
        shot("02_skill_picked")
        tapButton("Continue")
        settle(2.5)
        shot("03_trial_page")
        dumpTexts("trial_page")

        // Free way in.
        tapButton("Get Started")
        settle(1.2)
        note("after trial exit: primer on screen = \(app.buttons["Skip for now"].exists)")

        // Primer, only for Brand new.
        var primerPages = 0
        if app.buttons["Skip for now"].waitForExistence(timeout: 5) {
            shot("04_primer_p0")
            dumpTexts("primer_p0")
            for page in 1...5 {
                tapButton("Continue")
                primerPages += 1
                shot("04_primer_p\(page)")
                if page == 3 || page == 5 { dumpTexts("primer_p\(page)") }
            }
            tapButton("Take your seat")
        }
        note("primer pages seen: \(primerPages + 1)")
        settle(1.2)

        // Tour.
        var tourPages = 0
        while app.buttons["Skip the tour"].waitForExistence(timeout: 3), tourPages < 6 {
            shot("05_tour_p\(tourPages)")
            dumpTexts("tour_p\(tourPages)")
            tapButton("Show me")
            tourPages += 1
        }
        note("tour pages seen (before final): \(tourPages)")
        shot("05_tour_final")
        dumpTexts("tour_final")
        note("elapsed to first question button: \(Int(Date().timeIntervalSince(started)))s, taps \(taps)")
        tapButton("Start my first session")
        settle(2)

        // Quick Session.
        for q in 1...10 {
            guard app.staticTexts["\(q) of 10"].waitForExistence(timeout: 6) else {
                note("question \(q) did not appear")
                break
            }
            shot(String(format: "06_q%02d", q))
            dumpTexts("q\(q)")
            if !answerVisibleChoice() { break }
            shot(String(format: "06_q%02d_answered", q))
            let next = app.buttons["Next"].firstMatch.exists ? "Next" : "Finish"
            tapButton(next)
            settle(1.0)
        }
        settle(1.5)
        shot("07_session_complete")
        dumpTexts("session_complete")
        tapButton("Done")
        settle(2)

        // Home, first arrival.
        shot("08_home_first")
        dumpTexts("home_first")
        swipeUp()
        shot("08_home_scrolled")
        dumpTexts("home_scrolled")
        swipeUp()
        shot("08_home_bottom")
        swipeDown(); swipeDown()

        // A room and a drill, like a newcomer browsing.
        if tapLabelContaining("Card Room") {
            shot("09_card_room")
            dumpTexts("card_room")
            let rows = app.buttons.allElementsBoundByIndex.map(\.label).filter { !$0.isEmpty }
            note("card room buttons: \(rows)")
            if let first = app.buttons.allElementsBoundByIndex.first(where: { $0.label.contains("Card") && $0.frame.midY > 250 && !$0.label.contains("Room") }) {
                first.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                settle(1.5)
                shot("09_card_room_drill")
                dumpTexts("card_room_drill")
            }
        }
        goHome()

        // Settings.
        app.navigationBars.buttons["Settings"].firstMatch.tap()
        settle(1.5)
        shot("10_settings")
        dumpTexts("settings")
        let done = app.buttons["Done"].firstMatch
        if done.exists { done.tap(); settle(1) }

        // Return visit: kill and relaunch.
        app.terminate()
        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 30)
        settle(3)
        shot("11_return_visit_home")
        dumpTexts("return_home")

        attachLog()
    }

    // MARK: - Helpers

    private func note(_ text: String) {
        log.append(String(format: "[%4.0fs] ", Date().timeIntervalSince(started)) + text)
    }

    private func settle(_ seconds: TimeInterval = 1.4) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func shot(_ name: String) {
        settle(0.5)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func dumpTexts(_ name: String) {
        let texts = app.staticTexts.allElementsBoundByIndex.map(\.label).filter { !$0.isEmpty }
        let buttons = app.buttons.allElementsBoundByIndex.map { "[\($0.label)]" }.filter { $0 != "[]" }
        log.append("--- \(name) texts: \(texts.joined(separator: " | "))")
        log.append("--- \(name) buttons: \(buttons.joined(separator: " "))")
    }

    private func attachLog() {
        let attachment = XCTAttachment(string: log.joined(separator: "\n"))
        attachment.name = "log"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func tapButton(_ label: String) {
        let button = app.buttons[label].firstMatch
        guard button.waitForExistence(timeout: 6) else {
            note("MISSING button \(label)")
            return
        }
        taps += 1
        button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        settle(0.9)
    }

    private func tapText(_ label: String) {
        let match = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", label)).firstMatch
        guard match.waitForExistence(timeout: 6) else {
            note("MISSING choice \(label)")
            return
        }
        taps += 1
        match.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        settle(0.9)
    }

    @discardableResult
    private func tapLabelContaining(_ label: String) -> Bool {
        let match = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", label)).firstMatch
        guard match.waitForExistence(timeout: 6) else {
            note("MISSING \(label)")
            return false
        }
        match.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        settle(1.5)
        return true
    }

    private func answerVisibleChoice() -> Bool {
        let height = max(app.windows.firstMatch.frame.height, 1)
        let excluded = ["Settings", "Back", "Next", "Finish", "Close"]
        let choice = app.buttons.allElementsBoundByIndex.first { element in
            let label = element.label
            return !label.isEmpty && !excluded.contains(label)
                && element.frame.midY > height * 0.20 && element.frame.midY < height * 0.85
        }
        guard let choice else {
            note("could not find a choice to answer")
            return false
        }
        note("answering with: \(choice.label)")
        taps += 1
        choice.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        settle(1.2)
        return true
    }

    private func swipeUp() {
        app.windows.firstMatch.swipeUp()
        settle(0.8)
    }

    private func swipeDown() {
        app.windows.firstMatch.swipeDown()
        settle(0.6)
    }

    private func goHome() {
        for _ in 0..<4 {
            if app.staticTexts["Cribbage Trainer"].firstMatch.exists, app.navigationBars.buttons["Settings"].exists { return }
            let back = app.navigationBars.buttons.element(boundBy: 0)
            guard back.exists, back.identifier != "Settings" else { return }
            back.tap()
            settle(0.8)
        }
    }
}
