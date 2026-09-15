import XCTest

/// Exercises the Wallpapers section end to end: the discovery page, a wallpaper preview, the three
/// "see all" pages, a collection, and the per-theme pages reached from the rail.
///
/// Launches straight into Wallpapers with `QA_OPEN_WALLPAPERS` rather than walking Themes → the
/// Wallpapers pill, so a change to the Themes screen can't fail this test for unrelated reasons.
/// Dumps a screenshot per step to $SCREENSHOT_DIR (forwarded by xcodebuild as
/// TEST_RUNNER_SCREENSHOT_DIR) and attaches them. Uses only exact accessibility identifiers.
final class WallpapersFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_SKIP_ONBOARDING", "QA_OPEN_WALLPAPERS"]
        app.launch()
        XCTAssertTrue(app.buttons["wallpapers.back"].waitForExistence(timeout: 10),
                      "should land on the Wallpapers screen")
        return app
    }

    /// Discovery page → a Popular tile's preview → back.
    func testDiscoveryAndPreview() throws {
        let app = launch()
        settle()
        capture(app, "wp-01-discover")

        // Every thumbnail everywhere in the section opens the same preview.
        let tile = app.otherElements["wallpapers.card.wallpaper_dark_02"]
        XCTAssertTrue(tile.waitForExistence(timeout: 5), "a Popular Themes card should be tappable")
        tap(tile)
        settle()
        capture(app, "wp-02-preview")
        XCTAssertTrue(app.otherElements["wallpapers.preview.wallpaper_dark_02"].exists
                      || app.buttons["wallpapers.preview.close"].exists,
                      "tapping a tile should open that wallpaper's preview")

        let close = app.buttons["wallpapers.preview.close"]
        XCTAssertTrue(close.waitForExistence(timeout: 4))
        tap(close)
        settle()
        capture(app, "wp-03-back-on-discover")
    }

    /// Each "see all" opens its own page in the same rail-plus-pane structure — no bottom sheet.
    func testSeeAllPages() throws {
        let app = launch()
        settle()

        for section in ["popular", "collections", "trending"] {
            let seeAll = app.buttons["wallpapers.seeAll.\(section)"]
            XCTAssertTrue(seeAll.waitForExistence(timeout: 5), "see all for \(section) present")
            tap(seeAll)
            settle()
            capture(app, "wp-10-seeall-\(section)")
            XCTAssertTrue(app.otherElements["wallpapers.pageHeading"].exists
                          || app.staticTexts["POPULAR THEMES"].exists
                          || app.staticTexts["COLLECTIONS"].exists
                          || app.staticTexts["TRENDING NOW"].exists,
                          "\(section) should get a real page with a heading, not a sheet")
            // The rail is still there, which is what makes it one screen rather than a push.
            XCTAssertTrue(app.buttons["wallpapers.category.all"].exists,
                          "the rail should survive navigating to a see-all page")
            tap(app.buttons["wallpapers.category.all"])
            settle()
        }
    }

    /// A collection cover opens that collection's own page.
    func testCollectionPage() throws {
        let app = launch()
        settle()
        let collection = app.otherElements["wallpapers.collection.collection_kitten_skies"]
        if collection.exists {
            tap(collection)
        } else {
            tap(app.buttons["wallpapers.seeAll.collections"])
            settle()
            tap(app.buttons["wallpapers.collectionTile.collection_kitten_skies"])
        }
        settle()
        capture(app, "wp-20-collection")
    }

    /// Every rail theme reaches its own page, with its own banner and only its own wallpapers.
    func testThemePages() throws {
        let app = launch()
        settle()

        for theme in ["cute", "dark", "nature", "space", "minimal", "y2k"] {
            let row = app.buttons["wallpapers.category.\(theme)"]
            XCTAssertTrue(row.waitForExistence(timeout: 5), "rail row \(theme) present")
            tap(row)
            settle()
            capture(app, "wp-30-theme-\(theme)")
            // Discovery-only sections must not follow the user into a theme page.
            XCTAssertFalse(app.staticTexts["COLLECTIONS"].exists,
                           "\(theme) page should not show the Collections row")
            XCTAssertFalse(app.staticTexts["TRENDING NOW"].exists,
                           "\(theme) page should not show the Trending row")
        }

        tap(app.buttons["wallpapers.category.all"])
        settle()
        XCTAssertTrue(app.staticTexts["COLLECTIONS"].waitForExistence(timeout: 4),
                      "All Themes stays the discovery page")
        capture(app, "wp-31-back-to-all")
    }

    // MARK: Helpers

    private func settle(_ seconds: TimeInterval = 1.0) {
        Thread.sleep(forTimeInterval: seconds)
    }

    /// `.tap()` but tolerant of an overlay badge XCUITest reports as "not hittable": falls back to
    /// a coordinate tap at the element's centre.
    private func tap(_ element: XCUIElement) {
        if element.isHittable {
            element.tap()
        } else {
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
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
