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
