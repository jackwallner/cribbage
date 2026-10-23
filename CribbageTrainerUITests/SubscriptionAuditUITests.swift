import XCTest

/// Persona audit walkthrough: a skeptical free user deciding what is paid,
/// comparing value, and testing restore and exit paths. Fresh install, nothing
/// skipped by launch argument. RevenueCat is never configured on a simulator
/// (prices read "Loading price..." and a "purchase" only flips the local
/// override), so this records what a free user can see and reach, not Apple's
/// sheet. Never fails on a missing element; it logs what it could not find.
@MainActor
final class SubscriptionAuditUITests: XCTestCase {
    private var app: XCUIApplication!
    private var log: [String] = []
    private var started = Date()

    override func setUp() {
        continueAfterFailure = true
    }

    func testSkepticalFreeUserSubscriptionPaths() {
        app = XCUIApplication(bundleIdentifier: "com.jackwallner.cribbage")
        app.launch()
        started = Date()
        _ = app.wait(for: .runningForeground, timeout: 30)
        settle()

        // Onboarding to the trial page.
        tapButton("Continue"); tapButton("Continue"); tapButton("Continue")
        tapText("Played real games")
        tapButton("Continue")
        settle(2.5)
        shot("01_trial_page")
        dumpTexts("trial_page")
        measure("trial Get Started", app.buttons["Get Started"].firstMatch)
        measure("trial Restore", app.buttons["Restore"].firstMatch)
        measure("trial Terms", app.links["Terms"].firstMatch)
        measure("trial Privacy", app.links["Privacy"].firstMatch)
        measure("trial primary CTA", app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'trial' OR label CONTAINS 'Join'")).firstMatch)

        // Restore from the trial page with nothing to restore.
        tapButton("Restore")
        settle(1.5)
        shot("02_trial_restore_result")
        dumpTexts("trial_restore_result")
        if app.alerts.firstMatch.exists {
            note("alert after Restore: \(app.alerts.firstMatch.label) / \(app.alerts.firstMatch.staticTexts.allElementsBoundByIndex.map(\.label))")
            app.alerts.firstMatch.buttons.firstMatch.tap()
            settle(0.8)
        } else {
            note("NO alert after Restore on trial page")
        }

        // Tap the primary trial CTA on a simulator (no RevenueCat): what does a skeptic see if prices never load?
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'trial' OR label CONTAINS 'Join'")).firstMatch
        note("trial CTA enabled: \(cta.isEnabled), label: \(cta.label)")

        // Free exit.
        tapButton("Get Started")
        settle(1.2)
        skipToHome()
        shot("03_home_free")
        dumpTexts("home_free")
        swipeUp()
        shot("03_home_free_scrolled")
        dumpTexts("home_free_scrolled")
        swipeDown()

        // Locked training tiles.
        for tile in ["Endless", "Cribbage", "Game Night", "Timed"] {
            if tapLabelContaining(tile) {
                shot("04_tile_" + tile.replacingOccurrences(of: " ", with: ""))
                dumpTexts("tile_\(tile)")
                if app.buttons["Close"].exists {
                    measure("paywall Close", app.buttons["Close"].firstMatch)
                    app.buttons["Close"].firstMatch.tap()
                    settle(1)
                } else {
                    note("tile \(tile) did not open a paywall (opened a mode)")
                    goHome()
                }
            }
        }

        // The paywall in full.
        if tapLabelContaining("Get Cribbage+") {
            settle(2.5)
            shot("05_paywall_top")
            dumpTexts("paywall")
            for name in ["Restore"] { measure("paywall \(name)", app.buttons[name].firstMatch) }
            measure("paywall Terms", app.links["Terms of Use"].firstMatch)
            measure("paywall Privacy", app.links["Privacy Policy"].firstMatch)
            let plans = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Auto-renews' OR label CONTAINS 'nothing renews'"))
            for i in 0..<plans.count { measure("paywall plan card \(i)", plans.element(boundBy: i)) }
            swipeUp()
            shot("05_paywall_scrolled")
            app.buttons["Restore"].firstMatch.tap()
            settle(0.4)
            shot("05_paywall_restore_inflight")
            settle(1.5)
            shot("05_paywall_restore_result")
            dumpTexts("paywall_restore_result")
            if app.alerts.firstMatch.exists {
                note("paywall restore alert: \(app.alerts.firstMatch.staticTexts.allElementsBoundByIndex.map(\.label))")
                app.alerts.firstMatch.buttons.firstMatch.tap()
                settle(0.8)
            }
            if app.buttons["Close"].exists { app.buttons["Close"].firstMatch.tap(); settle(1) }
        }

        // Rooms: free vs paid contents.
        for room in ["Card Room", "Scoring Room", "Discard Room", "Pegging Room", "Master Tables"] {
            if tapLabelContaining(room) {
                shot("06_room_" + room.replacingOccurrences(of: " ", with: ""))
                dumpTexts("room_\(room)")
                let rows = app.buttons.allElementsBoundByIndex.map(\.label).filter { !$0.isEmpty }
                note("room \(room) buttons: \(rows)")
                swipeUp()
                dumpTexts("room_\(room)_bottom")
                shot("06_room_" + room.replacingOccurrences(of: " ", with: "") + "_bottom")
                // Tap the first locked row to see what a preview gives.
                if let locked = app.buttons.allElementsBoundByIndex.first(where: { $0.label.localizedCaseInsensitiveContains("Cribbage+") && $0.label.contains("Extra") || ($0.label.contains("Cribbage+") && $0.label.contains("Locked")) }) {
                    note("tapping locked row: \(locked.label)")
                    locked.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                    settle(2)
                    shot("06_room_" + room.replacingOccurrences(of: " ", with: "") + "_locked_tap")
                    if app.buttons["Close"].exists { app.buttons["Close"].firstMatch.tap(); settle(1) }
                }
                goHome()
            }
        }

        // Settings, free state.
        openSettings()
        shot("07_settings_free")
        dumpTexts("settings_free")
        tapButton("Restore Purchases")
        settle(1.5)
        shot("07_settings_restore_result")
        if app.alerts.firstMatch.exists {
            note("settings restore alert: \(app.alerts.firstMatch.staticTexts.allElementsBoundByIndex.map(\.label))")
            app.alerts.firstMatch.buttons.firstMatch.tap()
            settle(0.8)
        }

        // Simulated membership: the debug override stands in for a purchase,
        // then switched off to stand in for a cancelled, lapsed membership.
        app.swipeUp(); settle(0.5)
        let override = app.switches["Local Pro override"].firstMatch
        if override.waitForExistence(timeout: 3) {
            override.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
            settle(1.5)
            shot("08_settings_member")
            app.swipeDown(); settle(0.5)
            shot("08_settings_member_top")
            dumpTexts("settings_member")
            note("member settings has Manage Subscription: \(app.links["Manage Subscription"].exists || app.buttons["Manage Subscription"].exists)")
            app.buttons["Done"].firstMatch.tap(); settle(1.5)
            shot("09_home_member")
            dumpTexts("home_member")
            // Lapse.
            openSettings()
            app.swipeUp(); settle(0.5)
            let again = app.switches["Local Pro override"].firstMatch
            if again.exists { again.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap(); settle(1.2) }
            app.swipeDown(); settle(0.4)
            app.buttons["Done"].firstMatch.tap(); settle(1.5)
            shot("10_home_after_lapse")
            dumpTexts("home_after_lapse")
        } else {
            note("MISSING Local Pro override switch (non-debug build)")
        }

        // Return visit: cold relaunch.
        app.terminate()
        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 30)
        settle(3)
        shot("11_return_visit_home")
        dumpTexts("return_home")
        note("return visit shows a paywall or trial page: \(app.buttons["Close"].exists || app.buttons["Get Started"].exists)")

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

    private func measure(_ name: String, _ element: XCUIElement) {
        guard element.exists else { note("TARGET \(name): not found"); return }
        let f = element.frame
        note("TARGET \(name): \(Int(f.width))x\(Int(f.height)) at y=\(Int(f.minY)) hittable=\(element.isHittable) label=\(element.label)")
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
        button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        settle(0.9)
    }

    private func tapText(_ label: String) {
        let match = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", label)).firstMatch
        guard match.waitForExistence(timeout: 3) else {
            note("MISSING choice \(label)")
            return
        }
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
        if !match.isHittable { app.swipeUp(); settle(0.6) }
        match.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        settle(1.5)
        return true
    }

    private func skipToHome() {
        for _ in 0..<12 {
            if app.buttons["Skip for now"].exists { app.buttons["Skip for now"].tap(); settle(1) }
            else if app.buttons["Skip it, take me to the app"].exists { app.buttons["Skip it, take me to the app"].tap(); settle(1.5) }
            else if app.buttons["Skip the tour"].exists { app.buttons["Skip the tour"].tap(); settle(1.5) }
            else if app.buttons["Take your seat"].exists { app.buttons["Take your seat"].tap(); settle(1) }
            else if app.buttons["Continue"].exists { app.buttons["Continue"].tap(); settle(0.8) }
            else if app.navigationBars.buttons["Settings"].exists { return }
            else { settle(1) }
        }
    }

    private func openSettings() {
        goHome()
        app.navigationBars.buttons["Settings"].firstMatch.tap()
        settle(1.5)
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
            if app.navigationBars.buttons["Settings"].exists { return }
            let back = app.navigationBars.buttons.element(boundBy: 0)
            guard back.exists else { return }
            back.tap()
            settle(0.8)
        }
    }
}
