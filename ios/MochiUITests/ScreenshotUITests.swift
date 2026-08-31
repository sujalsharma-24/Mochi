import XCTest

/// Walks every top-level tab and dumps a screenshot per screen. Run in CI (see
/// .github/workflows/ios-screenshots.yml) since this dev environment has no way to
/// run the Simulator directly. Screenshots land in $SCREENSHOT_DIR (set by the workflow
/// via TEST_RUNNER_SCREENSHOT_DIR) and are also attached to the test result for Xcode viewing.
final class ScreenshotUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureAllScreens() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_SKIP_ONBOARDING"]
        app.launch()

        // The app launches on the Fonts tab (RootView's default selection), not Home — so the
        // first real Home/Keyboard capture needs an explicit tap on that tab.
        capture(app, name: "00-launch-default")

        if app.buttons["tab.keyboard"].waitForExistence(timeout: 5) {
            app.buttons["tab.keyboard"].tap()
            Thread.sleep(forTimeInterval: 1.5)
        }
        capture(app, name: "01-keyboard-home")

        let orderedTabs: [(identifier: String, fileName: String)] = [
            ("tab.fonts", "02-fonts"),
            ("tab.themes", "03-themes"),
            ("tab.community", "04-community"),
            ("tab.create", "05-create")
        ]

        for tab in orderedTabs {
            let button = app.buttons[tab.identifier]
            guard button.waitForExistence(timeout: 5) else {
                XCTFail("Tab button \(tab.identifier) never appeared")
                continue
            }
            button.tap()
            Thread.sleep(forTimeInterval: 1.5)
            capture(app, name: tab.fileName)
        }

        // Profile and Search are pushed over the tab bar rather than being tabs themselves, so each
        // needs its host tab reselected before its trigger button exists.
        tapAndCapture(app, tabIdentifier: "tab.community", triggerIdentifier: "community.openProfile", fileName: "06-profile", backIdentifier: "profile.back")
        tapAndCapture(app, tabIdentifier: "tab.themes", triggerIdentifier: "themes.openSearch", fileName: "07-search", backIdentifier: "search.back")

        captureThemeApplyFlow(app)
        captureSearchResults(app)
        captureParityScreens(app)
    }

    /// The screens added for Android parity: Leaderboard, Wallpapers, Settings, Paywall.
    /// Best-effort — a missing element is logged, not a failure.
    private func captureParityScreens(_ app: XCUIApplication) {
        returnToRoot(app)
        // Leaderboard: Community › "see all" beside Popular Creators.
        if app.buttons["tab.community"].waitForExistence(timeout: 5) {
            app.buttons["tab.community"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            let link = app.buttons["community.openLeaderboard"].firstMatch
            if link.waitForExistence(timeout: 3) {
                link.tap()
                Thread.sleep(forTimeInterval: 1.5)
                capture(app, name: "11-leaderboard")
                tapBackIfPresent(app, "leaderboard.back")
            }
        }

        returnToRoot(app)
        // Wallpapers: Themes › "Wallpapers" pill.
        if app.buttons["tab.themes"].waitForExistence(timeout: 5) {
            app.buttons["tab.themes"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            let wp = app.buttons["themes.openWallpapers"].firstMatch
            if wp.waitForExistence(timeout: 3) {
                wp.tap()
                Thread.sleep(forTimeInterval: 1.5)
                capture(app, name: "12-wallpapers")
                tapBackIfPresent(app, "wallpapers.back")
            }
        }

        returnToRoot(app)
        // Settings: Community › Profile › gear.
        if app.buttons["tab.community"].waitForExistence(timeout: 5) {
            app.buttons["tab.community"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            if app.buttons["community.openProfile"].waitForExistence(timeout: 3) {
                app.buttons["community.openProfile"].tap()
                Thread.sleep(forTimeInterval: 1.2)
                if app.buttons["profile.openSettings"].waitForExistence(timeout: 3) {
                    app.buttons["profile.openSettings"].tap()
                    Thread.sleep(forTimeInterval: 1.5)
                    capture(app, name: "13-settings")
                    tapBackIfPresent(app, "settings.back")
                }
                tapBackIfPresent(app, "profile.back")
            }
        }

        returnToRoot(app)
        // Paywall: Community › Profile › Upgrade Plan.
        if app.buttons["tab.community"].waitForExistence(timeout: 5) {
            app.buttons["tab.community"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            if app.buttons["community.openProfile"].waitForExistence(timeout: 3) {
                app.buttons["community.openProfile"].tap()
                Thread.sleep(forTimeInterval: 1.2)
                if app.buttons["profile.upgradePlan"].firstMatch.waitForExistence(timeout: 3) {
                    app.buttons["profile.upgradePlan"].firstMatch.tap()
                    Thread.sleep(forTimeInterval: 1.5)
                    capture(app, name: "14-paywall")
                    tapBackIfPresent(app, "paywall.close")
                }
            }
        }
    }

    private func tapBackIfPresent(_ app: XCUIApplication, _ identifier: String) {
        let back = app.buttons[identifier].firstMatch
        if back.waitForExistence(timeout: 3) {
            back.tap()
            Thread.sleep(forTimeInterval: 0.8)
        }
    }

    /// Pop any pushed screens / dismiss any sheet until the tab bar is back. Uses `isHittable`
    /// (not `exists`) so a back button sitting behind a presented sheet is skipped, not tapped
    /// in a loop.
    private func returnToRoot(_ app: XCUIApplication) {
        for _ in 0..<8 {
            if app.buttons["tab.keyboard"].waitForExistence(timeout: 2) { return }
            if app.buttons["Done"].firstMatch.isHittable {
                app.buttons["Done"].firstMatch.tap()
                Thread.sleep(forTimeInterval: 0.6)
                continue
            }
            let backIds = ["themeDetail.back", "settings.back", "leaderboard.back",
                           "wallpapers.back", "search.back", "profile.back", "paywall.close"]
            if let id = backIds.first(where: { app.buttons[$0].firstMatch.isHittable }) {
                app.buttons[id].firstMatch.tap()
                Thread.sleep(forTimeInterval: 0.6)
                continue
            }
            // Last resort: edge-swipe to pop.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)))
            Thread.sleep(forTimeInterval: 0.6)
        }
    }

    /// Home theme card -> Theme Detail (live keyboard render) -> Apply -> the typable "try it" sheet.
    /// Best-effort: a missing element here is logged, not a test failure — these are screenshots.
    private func captureThemeApplyFlow(_ app: XCUIApplication) {
        returnToRoot(app)
        if app.buttons["tab.keyboard"].waitForExistence(timeout: 5) {
            app.buttons["tab.keyboard"].tap()
            Thread.sleep(forTimeInterval: 1.0)
        }
        let card = app.staticTexts["Space vibe"].firstMatch
        guard card.waitForExistence(timeout: 5) else { return }
        card.tap()
        Thread.sleep(forTimeInterval: 1.5)
        capture(app, name: "08-theme-detail")

        // "Apply Theme" the first time, "Applied" if a prior run already applied it.
        let apply = app.buttons["Apply Theme"].firstMatch
        let applied = app.buttons["Applied"].firstMatch
        if apply.waitForExistence(timeout: 3) { apply.tap() }
        else if applied.exists { applied.tap() }
        else { returnToRoot(app); return }
        Thread.sleep(forTimeInterval: 1.5)
        capture(app, name: "09-apply-try-sheet")
        returnToRoot(app)
    }

    /// Search with a real query typed, exercising the live catalogue filter.
    private func captureSearchResults(_ app: XCUIApplication) {
        returnToRoot(app)
        let tabButton = app.buttons["tab.themes"]
        guard tabButton.waitForExistence(timeout: 5) else { return }
        tabButton.tap()
        Thread.sleep(forTimeInterval: 0.8)
        let trigger = app.buttons["themes.openSearch"]
        guard trigger.waitForExistence(timeout: 5) else { return }
        trigger.tap()
        Thread.sleep(forTimeInterval: 1.0)

        let field = app.textFields.firstMatch
        if field.waitForExistence(timeout: 5) {
            field.tap()
            field.typeText("sakura")
            Thread.sleep(forTimeInterval: 1.2)
            capture(app, name: "10-search-results")
        }
        returnToRoot(app)
    }

    private func tapAndCapture(_ app: XCUIApplication, tabIdentifier: String, triggerIdentifier: String, fileName: String, backIdentifier: String) {
        let tabButton = app.buttons[tabIdentifier]
        guard tabButton.waitForExistence(timeout: 5) else {
            XCTFail("Tab button \(tabIdentifier) never appeared")
            return
        }
        tabButton.tap()
        Thread.sleep(forTimeInterval: 1.0)

        let trigger = app.buttons[triggerIdentifier]
        guard trigger.waitForExistence(timeout: 5) else {
            XCTFail("Trigger button \(triggerIdentifier) never appeared")
            return
        }
        trigger.tap()
        Thread.sleep(forTimeInterval: 1.5)
        capture(app, name: fileName)

        let back = app.buttons[backIdentifier]
        if back.waitForExistence(timeout: 5) {
            back.tap()
            Thread.sleep(forTimeInterval: 1.0)
        }
    }

    private func capture(_ app: XCUIApplication, name: String) {
        let screenshot = app.screenshot()

        if let dir = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] {
            let url = URL(fileURLWithPath: dir).appendingPathComponent("\(name).png")
            try? screenshot.pngRepresentation.write(to: url)
        }

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
