import XCTest

/// Walks the German app through onboarding, the trial page, Home, the paywall,
/// a few rooms and drills, and the member features, attaching a screenshot of
/// each so clipped or untranslated copy can be checked by eye. Like
/// `ScreenshotTests`, it records what it could not reach instead of failing.
@MainActor
final class GermanScreenshotTests: XCTestCase {
    private var app: XCUIApplication!
    private var problems: [String] = []
    private let german = ["-AppleLanguages", "(de)", "-AppleLocale", "de_DE"]
    private let onboarded = [
        "-progress.hasOnboarded", "YES",
        "-cribbage.hasReadPrimer", "YES",
        "-cribbage.skillLevel", "some",
        "-progress.totalSessions", "12",
    ]

    private func launch(_ extra: [String]) {
        continueAfterFailure = true
        app = XCUIApplication()
        let version = ProcessInfo.processInfo.environment["SCREENSHOT_APP_VERSION"] ?? "1.3.1"
        app.launchArguments = german + ["-whatsnew.lastSeenVersion", version] + extra
        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 30)
        settle(2.5)
    }

    func testOnboardingAndTrialPage() {
        launch(["-progress.hasOnboarded", "NO"])
        capture("de_01_onboarding_1")
        for page in 2...3 {
            tap("Weiter")
            capture("de_01_onboarding_\(page)")
        }
        tap("Weiter")
        capture("de_02_skill_level")
        tap("Ganz neu")
        tap("Weiter")
        settle(3)
        capture("de_03_trial_page")
        tap("Los geht's")
        capture("de_04_primer")
        tap("Weiter")
        capture("de_04_primer_2")
        finish()
    }

    func testFreeHomePaywallAndDrills() {
        launch(onboarded)
        capture("de_10_home_free")
        app.swipeUp()
        settle()
        capture("de_11_home_free_scrolled")
        tap("Cribbage+ holen")
        settle(2)
        capture("de_12_paywall")
        tap("Schließen")
        app.swipeDown()
        settle()

        if tap("Der Punkteraum") {
            capture("de_13_scoring_room")
            if tap("Die Hand lesen") {
                capture("de_14_read_the_hand")
                answerVisibleChoice()
                capture("de_15_read_the_hand_answered")
            }
        }
        relaunch(onboarded)
        if tap("Der Kartenraum") {
            capture("de_16_card_room")
            if tap("Die Karten kennenlernen") {
                capture("de_17_flashcard")
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                settle()
                capture("de_18_flashcard_back")
            }
        }
        relaunch(onboarded)
        if tap("Der Abwurfraum"), tap("Wähle deinen Abwurf") {
            capture("de_19_discard")
        }
        relaunch(onboarded)
        if tap("Der Pegging-Raum"), tap("Pegging-Gespür") {
            capture("de_20_pegging")
        }
        relaunch(onboarded)
        let gear = app.buttons["Einstellungen"].firstMatch
        if gear.waitForExistence(timeout: 5) {
            gear.tap()
            settle()
            capture("de_21_settings")
        } else {
            problems.append("no settings gear")
        }
        relaunch(onboarded)
        if tap("Übungen erledigt") {
            capture("de_22_progress")
        }
        finish()
    }

    func testMemberFeatures() {
        let member = onboarded + ["-subscription.localProOverride", "YES"]
        launch(member)
        capture("de_30_home_member")
        app.swipeUp()
        settle()
        capture("de_31_home_member_scrolled")
        app.swipeDown()
        settle()
        if tap("Los geht's") {
            capture("de_32_quick_session")
            answerVisibleChoice()
            capture("de_33_quick_session_answered")
        }
        relaunch(member)
        if tap("Endlos") {
            capture("de_34_endless_picker")
            if tap("Pegging-Punkte") {
                capture("de_35_peg_points")
                answerVisibleChoice()
                capture("de_36_peg_points_answered")
            }
        }
        relaunch(member)
        if tap("Minute") {
            capture("de_37_minute")
        }
        relaunch(member)
        if tap("Spieleabend") {
            capture("de_38_game_night")
        }
        relaunch(member)
        if tap("Gegen") {
            capture("de_39_timed")
        }
        relaunch(member)
        if tap("Die Meistertische") {
            capture("de_40_master_tables")
        }
        finish()
    }

    // MARK: - Helpers

    private func relaunch(_ extra: [String]) {
        app.terminate()
        launch(extra)
    }

    /// Taps the first element whose label contains `label`, by coordinate,
    /// since SwiftUI cards often report isHittable false.
    @discardableResult
    private func tap(_ label: String) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", label)
        for query in [app.buttons, app.staticTexts] {
            let match = query.matching(predicate).firstMatch
            guard match.waitForExistence(timeout: 5) else { continue }
            match.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            settle()
            return true
        }
        problems.append("could not tap: \(label)")
        return false
    }

    private func answerVisibleChoice() {
        let height = max(app.windows.firstMatch.frame.height, 1)
        let choice = app.buttons.allElementsBoundByIndex.first { element in
            !element.label.isEmpty
                && element.frame.midY > height * 0.35
                && element.frame.midY < height * 0.82
        }
        guard let choice else {
            problems.append("could not answer visible choice")
            return
        }
        choice.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        settle()
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

    private func finish() {
        guard !problems.isEmpty else { return }
        let note = XCTAttachment(string: problems.joined(separator: "\n"))
        note.name = "problems"
        note.lifetime = .keepAlways
        add(note)
    }
}
