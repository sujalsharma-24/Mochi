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
    }

    /// Home theme card -> Theme Detail (live keyboard render) -> Apply -> the typable "try it" sheet.
    /// Best-effort: a missing element here is logged, not a test failure — these are screenshots.
    private func captureThemeApplyFlow(_ app: XCUIApplication) {
        if app.buttons["tab.keyboard"].waitForExistence(timeout: 5) {
            app.buttons["tab.keyboard"].tap()
            Thread.sleep(forTimeInterval: 1.0)
        }
        // "Space vibe" is a non-premium card, so Theme Detail offers "Apply Theme" rather than
        // "Unlock Premium".
        let card = app.staticTexts["Space vibe"].firstMatch
        guard card.waitForExistence(timeout: 5) else { return }
        card.tap()
        Thread.sleep(forTimeInterval: 1.5)
        capture(app, name: "08-theme-detail")

        let apply = app.buttons["Apply Theme"].firstMatch
        guard apply.waitForExistence(timeout: 5) else { return }
        apply.tap()
        Thread.sleep(forTimeInterval: 1.5)
        capture(app, name: "09-apply-try-sheet")
        if app.buttons["Done"].firstMatch.waitForExistence(timeout: 3) {
            app.buttons["Done"].firstMatch.tap()
            Thread.sleep(forTimeInterval: 0.8)
        }
    }

    /// Search with a real query typed, exercising the live catalogue filter.
    private func captureSearchResults(_ app: XCUIApplication) {
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
