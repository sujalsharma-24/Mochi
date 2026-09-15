import XCTest

/// Exercises the Themes screen: category pills, the Filter and Sort menus, a card's Apply, and the
/// downloaded strip's See All. Dumps a screenshot per step to $SCREENSHOT_DIR (forwarded by
/// xcodebuild as TEST_RUNNER_SCREENSHOT_DIR) and attaches them. Deliberately uses only exact
/// accessibility identifiers — broad `NSPredicate` element scans time out against a 28-card grid.
final class ThemesFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testThemesScreenFlow() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_SKIP_ONBOARDING"]
        app.launch()

        XCTAssertTrue(app.buttons["tab.themes"].waitForExistence(timeout: 8))
        app.buttons["tab.themes"].tap()
        Thread.sleep(forTimeInterval: 2.0)
        capture(app, "themes-01-initial")

        for pill in ["Dreamy", "Cozy", "Nature", "Cute", "All"] {
            let button = app.buttons["themes.category.\(pill)"]
            if button.waitForExistence(timeout: 3) {
                button.tap()
                Thread.sleep(forTimeInterval: 0.8)
                capture(app, "themes-02-category-\(pill)")
            } else {
                XCTFail("pill \(pill) missing")
            }
        }

        let filter = app.buttons["themes.filter"]
        if filter.waitForExistence(timeout: 3) {
            filter.tap()
            Thread.sleep(forTimeInterval: 0.8)
            capture(app, "themes-03-filter-open")
            let premium = app.buttons["Premium Only"]
            if premium.waitForExistence(timeout: 3) {
                premium.tap()
                Thread.sleep(forTimeInterval: 0.8)
                capture(app, "themes-04-filter-premium")
            }
        } else {
            XCTFail("filter control missing")
        }

        let sort = app.buttons["themes.sort"]
        if sort.waitForExistence(timeout: 3) {
            sort.tap()
            Thread.sleep(forTimeInterval: 0.8)
            let az = app.buttons["A–Z"]
            if az.waitForExistence(timeout: 3) {
                az.tap()
                Thread.sleep(forTimeInterval: 0.8)
                capture(app, "themes-05-sort-az")
            }
        }

        // Reset the filter + sort so the grid is full and Popular-ordered again (FCN back on top).
        if filter.exists {
            filter.tap(); Thread.sleep(forTimeInterval: 0.5)
            app.buttons["All Themes"].tap()
            Thread.sleep(forTimeInterval: 0.6)
        }
        if sort.exists {
            sort.tap(); Thread.sleep(forTimeInterval: 0.5)
            app.buttons["Popular"].tap()
            Thread.sleep(forTimeInterval: 0.6)
        }

        // Apply Fantasy Castle Night from its card. Preview/Apply are tappable Text, not Button, so
        // they surface as staticTexts.
        let applyFCN = element(app, "themes.card.mochi.fantasy-castle-night.apply")
        if applyFCN.waitForExistence(timeout: 3) {
            applyFCN.tap()
            Thread.sleep(forTimeInterval: 1.2)
            capture(app, "themes-06-applied-fcn")
        } else {
            XCTFail("FCN apply button missing")
        }

        // Download the first six visible cards via their download discs so the strip has more than
        // one row's worth (the See All control only appears past four).
        let firstSix = ["mochi.fantasy-castle-night", "mochi.aurora-winter-wonderland",
                        "mochi.dreamy-castle", "mochi.lavender-paris-night",
                        "mochi.sakura-train", "mochi.cozy-sakura-cafe"]
        for id in firstSix {
            let dl = element(app, "themes.card.\(id).download")
            if dl.waitForExistence(timeout: 2) { dl.tap(); Thread.sleep(forTimeInterval: 0.35) }
        }
        capture(app, "themes-07-after-downloads")

        // Scroll to the downloaded strip.
        for _ in 0..<4 { app.swipeUp(); Thread.sleep(forTimeInterval: 0.35) }
        Thread.sleep(forTimeInterval: 0.6)
        capture(app, "themes-08-downloaded-strip")

        let seeAll = app.buttons["themes.downloaded.seeAll"]
        XCTAssertTrue(seeAll.waitForExistence(timeout: 3), "See All should appear once > 4 downloaded")
        seeAll.tap()
        Thread.sleep(forTimeInterval: 1.0)
        capture(app, "themes-09-see-all-expanded")
        seeAll.tap() // now "show less"
        Thread.sleep(forTimeInterval: 0.8)
        capture(app, "themes-10-see-all-collapsed")

        // Open Theme Detail from a downloaded tile and confirm its name is shown.
        let tile = element(app, "themes.downloadCard.mochi.aurora-winter-wonderland")
        if tile.waitForExistence(timeout: 3) {
            tile.tap()
            Thread.sleep(forTimeInterval: 1.2)
            capture(app, "themes-11-detail-from-strip")
            XCTAssertTrue(app.staticTexts["Aurora Winter Wonderland"].waitForExistence(timeout: 3),
                          "Theme Detail should show the tapped tile's theme")
        }
    }

    /// Card Preview/Apply/download controls are tappable `Text`/glyphs, not `Button`s, so they land
    /// as `staticTexts`/`images`/`otherElements` depending on the element. Return whichever exists.
    private func element(_ app: XCUIApplication, _ id: String) -> XCUIElement {
        let button = app.buttons[id]
        if button.exists { return button }
        let staticText = app.staticTexts[id]
        if staticText.exists { return staticText }
        let other = app.otherElements[id]
        if other.exists { return other }
        let image = app.images[id]
        if image.exists { return image }
        return app.descendants(matching: .any)[id]
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
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
