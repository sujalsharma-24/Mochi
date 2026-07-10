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
