import XCTest

/// Journeys for the 2026-11-20 bug catalog: a Timed Challenge left early or
/// interrupted, a session that crosses midnight, Home left open overnight,
/// and the paywall at the largest text size.
///
/// Midnight is staged by launching the app in a fixed-offset time zone
/// (`TZ`) whose local clock is a minute or two before midnight.
///
/// RevenueCat is never configured on a simulator. Membership comes from the
/// DEBUG local override, never from a store key.
@MainActor
final class DayAndExitJourneysUITests: XCTestCase {
    private var app: XCUIApplication!

    private let onboarded = [
        "-progress.hasOnboarded", "YES",
        "-cribbage.hasReadPrimer", "YES",
        "-cribbage.skillLevel", "some",
        "-cribbage.suppressWhatsNew",
        "-cribbage.rc.rating_prompt", "off",
    ]
    private let member = ["-subscription.localProOverride", "YES"]

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication(bundleIdentifier: "com.jackwallner.cribbage")
    }

    /// The release journeys expect a clean install after this class.
    private func leaveProgressClean() {
        if app.state == .runningForeground, home("THE ROOMS").exists {
            resetProgress()
        }
    }

    // MARK: - Timed Challenge

    /// Leaving a timed run by Back threw its score away; only the clock
    /// running out saved a best.
    func testTimedChallengeLeftEarlyKeepsTheBest() {
        defer { leaveProgressClean() }
        app.launchArguments = onboarded + member
        app.launch()
        waitForHome()
        resetProgress()

        openTimedChallenge()
        var score = 0
        for _ in 0..<25 {
            answerCurrentQuestion(counter: questionCounter())
            score = currentTimedScore()
            if score > 0 { break }
            tap("Next")
            XCTAssertTrue(questionCounter().waitForExistence(timeout: 10))
        }
        XCTAssertGreaterThan(score, 0, "no correct answer in 25 tries")
        attach("timed-before-back")

        app.navigationBars.buttons.firstMatch.tap()
        waitForHome()
        let best = home("Best \(score)")
        reveal(best)
        attach("home-after-timed-back")
    }

    /// The clock subtracted one second per wake, so time away from the app
    /// (a phone call) was handed back.
    func testTimedChallengeClockCountsTimeAway() {
        defer { leaveProgressClean() }
        app.launchArguments = onboarded + member
        app.launch()
        waitForHome()
        openTimedChallenge()
        let before = secondsLeft()

        XCUIDevice.shared.press(.home)
        sleep(20)
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        sleep(2)
        let after = secondsLeft()
        attach("timed-after-away")
        XCTAssertLessThanOrEqual(after, before - 18, "the clock did not count the 20 seconds away (\(before)s then \(after)s)")
        app.navigationBars.buttons.firstMatch.tap()
        waitForHome()
    }

    // MARK: - Midnight

    /// Get Started begun before midnight and finished after it spent the next
    /// day's Get Started (and broke a streak), because it was stamped with the
    /// finish time.
    func testGetStartedBegunBeforeMidnightLeavesTheNextDayOpen() {
        defer { leaveProgressClean() }
        let midnight = launchNearMidnight(secondsBefore: 100)
        waitForHome()
        resetProgress()

        startGetStarted()
        XCTAssertLessThan(Date(), midnight, "setup ran past midnight; the session did not start before it")

        while true {
            let (index, total) = progress()
            answerCurrentQuestion(counter: counter())
            let last = index == total
            if last {
                waitUntil(midnight.addingTimeInterval(3))
                tap("Finish")
                break
            }
            tap("Next")
            XCTAssertTrue(counter().waitForExistence(timeout: 10))
        }
        tap("Done", timeout: 15)
        waitForHome()
        attach("home-after-midnight-session")
        XCTAssertTrue(getStartedCard().waitForExistence(timeout: 10), "the new day's Get Started is gone")
        XCTAssertFalse(home("Today's session is done").exists)
        XCTAssertTrue(home("1 day streak").exists, "the session did not count for the day it began")
    }

    /// Home finished for the evening and left open past midnight kept showing
    /// the finished card until something else redrew it. (A trip to the home
    /// screen and back already redrew it on the base build.)
    func testHomeLeftOpenPastMidnightShowsTheNewDay() {
        defer { leaveProgressClean() }
        let midnight = launchNearMidnight(secondsBefore: 170)
        waitForHome()
        resetProgress()

        startGetStarted()
        while true {
            let (index, total) = progress()
            answerCurrentQuestion(counter: counter())
            let last = index == total
            tap(last ? "Finish" : "Next")
            if last { break }
            XCTAssertTrue(counter().waitForExistence(timeout: 10))
        }
        tap("Done", timeout: 15)
        waitForHome()
        XCTAssertTrue(home("Today's session is done").waitForExistence(timeout: 10))
        XCTAssertLessThan(Date(), midnight, "the session finished after midnight; nothing to show")
        attach("home-before-midnight")

        waitUntil(midnight.addingTimeInterval(1))
        let turnedInForeground = getStartedCard().waitForExistence(timeout: 15)
        print("DAY-TURN home in foreground after midnight: \(turnedInForeground ? "new day" : "still done")")
        attach("home-after-midnight-foreground")
        XCTAssertTrue(turnedInForeground, "Home left open past midnight still shows last night's finished session")

        XCUIDevice.shared.press(.home)
        sleep(3)
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        XCTAssertTrue(getStartedCard().waitForExistence(timeout: 10), "Home still shows last night's finished session")
        XCTAssertFalse(home("Today's session is done").exists)
        attach("home-after-midnight-resume")
    }

    // MARK: - Paywall at the largest text size

    /// At AX5 the plan card broke "Yearly" and stacked the badge letter by
    /// letter. Proof is the attached screenshots.
    func testPaywallPlanCardsAtTheLargestTextSize() {
        defer { leaveProgressClean() }
        app.launchArguments = onboarded + [
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
        ]
        app.launch()
        waitForHome()
        let upgrade = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Get Cribbage+")).firstMatch
        reveal(upgrade, swipes: 20)
        upgrade.tap()
        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 10), "the paywall did not appear")

        let yearly = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Yearly")).firstMatch
        XCTAssertTrue(yearly.waitForExistence(timeout: 10))
        for _ in 0..<12 where yearly.frame.minY > app.windows.firstMatch.frame.height * 0.45 {
            drag(up: 0.25)
        }
        attach("paywall-ax5-yearly")
        drag(up: 0.5)
        attach("paywall-ax5-monthly")
        drag(up: 0.5)
        attach("paywall-ax5-lifetime")
        app.buttons["Close"].tap()
        waitForHome()
    }

    // MARK: - Helpers

    /// Launches in a fixed-offset zone whose local midnight is between
    /// `secondsBefore` and a minute more away, and returns that instant.
    private func launchNearMidnight(secondsBefore: Int) -> Date {
        let now = Date().timeIntervalSince1970.rounded(.down)
        let utcSecond = Int(now) % 86_400
        var offset = ((86_400 - secondsBefore - utcSecond) % 86_400 + 86_400) % 86_400
        offset -= offset % 60
        if offset > 43_200 { offset -= 86_400 }
        let minutes = abs(offset) / 60
        let zone = String(format: "GMT%@%02d%02d", offset < 0 ? "-" : "+", minutes / 60, minutes % 60)
        let toMidnight = 86_400 - ((utcSecond + offset) % 86_400 + 86_400) % 86_400
        app.launchArguments = onboarded
        app.launchEnvironment["TZ"] = zone
        app.launch()
        print("DAY-TURN launched in \(zone), midnight in \(toMidnight)s")
        return Date(timeIntervalSince1970: now + TimeInterval(toMidnight))
    }

    private func waitUntil(_ date: Date) {
        let wait = date.timeIntervalSinceNow
        if wait > 0 { Thread.sleep(forTimeInterval: wait) }
    }

    private func waitForHome() {
        XCTAssertTrue(app.staticTexts["THE ROOMS"].waitForExistence(timeout: 20), "Home did not appear")
    }

    private func resetProgress() {
        let gear = app.buttons["Settings"]
        guard gear.waitForExistence(timeout: 10) else { return XCTFail("no Settings button") }
        gear.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 10), "Settings did not open")
        // A Form builds rows only as they scroll in, so look while scrolling.
        let reset = app.buttons["Reset Progress"]
        for _ in 0..<25 where !(reset.exists && reset.isHittable) { drag(up: 0.4) }
        XCTAssertTrue(reset.isHittable, "no Reset Progress row")
        reset.tap()
        let confirm = app.alerts.buttons["Reset"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 10))
        confirm.tap()
        tap("Done")
        waitForHome()
    }

    /// The training tiles are a horizontal row: bring it on screen, then
    /// swipe it left until the Timed Challenge tile is reachable.
    private func openTimedChallenge() {
        let endless = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Endless")).firstMatch
        reveal(endless)
        let tile = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Timed")).firstMatch
        for _ in 0..<6 where !(tile.exists && tile.isHittable) {
            let row = endless.exists ? endless : app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Game Night")).firstMatch
            let start = row.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
            start.press(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: -220, dy: 0)))
        }
        XCTAssertTrue(tile.isHittable, "the Timed Challenge tile could not be reached")
        tile.tap()
        XCTAssertTrue(questionCounter().waitForExistence(timeout: 15), "the timed run did not start")
    }

    private func startGetStarted() {
        let card = getStartedCard()
        XCTAssertTrue(card.waitForExistence(timeout: 20), "Home has no Get Started card")
        reveal(card)
        card.tap()
        XCTAssertTrue(counter().waitForExistence(timeout: 15), "the session did not start")
    }

    private func getStartedCard() -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Get Started")).firstMatch
    }

    private func home(_ text: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    private func tap(_ text: String, timeout: TimeInterval = 10) {
        let button = app.buttons[text]
        XCTAssertTrue(button.waitForExistence(timeout: timeout), "no button \(text)")
        button.tap()
    }

    private func reveal(_ element: XCUIElement, swipes: Int = 8) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), "element not found")
        for _ in 0..<swipes where !element.isHittable { drag(up: 0.4) }
        XCTAssertTrue(element.isHittable, "element could not be scrolled into view")
    }

    /// Scrolls the content up by a fraction of the screen.
    private func drag(up fraction: CGFloat) {
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75 - fraction))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    /// The "3 of 10" label under a Get Started question.
    private func counter() -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "\\d+ of \\d+")).firstMatch
    }

    /// The "Question 3" label under a timed question.
    private func questionCounter() -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "Question \\d+")).firstMatch
    }

    private func progress() -> (index: Int, total: Int) {
        let parts = counter().label.components(separatedBy: " of ").compactMap { Int($0) }
        XCTAssertEqual(parts.count, 2, "unreadable progress label \(counter().label)")
        return (parts.first ?? 0, parts.last ?? 0)
    }

    private func currentTimedScore() -> Int {
        let label = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "\\d+ correct")).firstMatch
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        return Int(label.label.components(separatedBy: " ").first ?? "") ?? 0
    }

    private func secondsLeft() -> Int {
        let label = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "\\d+s")).firstMatch
        XCTAssertTrue(label.waitForExistence(timeout: 5), "no clock on screen")
        return Int(label.label.dropLast()) ?? -1
    }

    /// Taps the first answer row: the buttons between the navigation bar and the counter.
    private func answerCurrentQuestion(counter: XCUIElement) {
        let top = app.navigationBars.firstMatch.frame.maxY
        let bottom = counter.frame.minY
        let rows = app.buttons.allElementsBoundByIndex.filter {
            !$0.label.isEmpty && $0.frame.minY >= top && $0.frame.maxY <= bottom
        }
        guard let row = rows.first else { return XCTFail("no answer row on screen") }
        row.tap()
        XCTAssertTrue(app.buttons["Next"].waitForExistence(timeout: 10) || app.buttons["Finish"].exists, "the answer did not grade")
    }

    private func attach(_ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
