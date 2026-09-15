import XCTest

/// Exercises the Search screen end to end: the type pills, a real relevance query, the recent /
/// trending / suggestion chips, the FILTERS menus, and navigation out of a result. Dumps a
/// screenshot per step to $SCREENSHOT_DIR and attaches them. Uses exact accessibility identifiers.
final class SearchFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testSearchScreenFlow() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_SKIP_ONBOARDING"]
        app.launch()

        // Open Search from the Themes tab.
        XCTAssertTrue(app.buttons["tab.themes"].waitForExistence(timeout: 8))
        app.buttons["tab.themes"].tap()
        Thread.sleep(forTimeInterval: 1.5)
        XCTAssertTrue(app.buttons["themes.openSearch"].waitForExistence(timeout: 5))
        app.buttons["themes.openSearch"].tap()
        Thread.sleep(forTimeInterval: 1.5)
        capture(app, "search-01-initial")

        // All four type pills present on one screen (no scroll).
        for pill in ["All", "Theme", "Font", "Creator"] {
            XCTAssertTrue(app.buttons["search.type.\(pill)"].waitForExistence(timeout: 3),
                          "type pill \(pill) should be visible without scrolling")
        }

        // Relevance query: "night" — should surface dark/night themes even without the literal word.
        let field = app.textFields["search.field"]
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.typeText("night")
        Thread.sleep(forTimeInterval: 0.6)
        // Submit (records the recent) and drop the keyboard so the grid is visible.
        if app.keyboards.buttons["search"].exists { app.keyboards.buttons["search"].tap() }
        Thread.sleep(forTimeInterval: 0.8)

        XCTAssertTrue(app.staticTexts["SEARCH RESULTS"].waitForExistence(timeout: 3),
                      "results section should appear")

        // Only ~6 catalogue themes carry the literal word "night" (in a name or a hashtag). Getting
        // materially more than that back proves the concept lexicon expanded the query — "midnight",
        // "moonlit", "witchy" etc. surfaced too.
        let countLabel = app.staticTexts["search.results.count"]
        XCTAssertTrue(countLabel.waitForExistence(timeout: 3))
        let count = Int(countLabel.label.components(separatedBy: " ").first ?? "0") ?? 0
        XCTAssertGreaterThan(count, 7, "‘night’ should surface concept matches, not just literal ones (got \(count))")

        app.swipeUp(); Thread.sleep(forTimeInterval: 0.4)
        capture(app, "search-02-query-night")
        app.swipeDown(); app.swipeDown(); Thread.sleep(forTimeInterval: 0.3)

        // Narrow to Font, then Creator, then back to All. Scroll to the grid for each.
        app.buttons["search.type.Font"].tap()
        Thread.sleep(forTimeInterval: 0.6)
        app.swipeUp(); app.swipeUp(); Thread.sleep(forTimeInterval: 0.4)
        capture(app, "search-03-type-font")
        app.swipeDown(); app.swipeDown(); app.swipeDown(); Thread.sleep(forTimeInterval: 0.3)
        app.buttons["search.type.Creator"].tap()
        Thread.sleep(forTimeInterval: 0.6)
        app.swipeUp(); app.swipeUp(); Thread.sleep(forTimeInterval: 0.4)
        capture(app, "search-04-type-creator")
        app.swipeDown(); app.swipeDown(); app.swipeDown(); Thread.sleep(forTimeInterval: 0.3)
        app.buttons["search.type.All"].tap()
        Thread.sleep(forTimeInterval: 0.6)

        // Clear the field, back to the empty state.
        if app.buttons["search.field.clear"].exists {
            app.buttons["search.field.clear"].tap()
            Thread.sleep(forTimeInterval: 0.8)
        }
        capture(app, "search-05-cleared")

        // Trending chip runs a search.
        let trending = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'search.trending.'")).firstMatch
        if trending.waitForExistence(timeout: 3) {
            trending.tap()
            Thread.sleep(forTimeInterval: 1.0)
            capture(app, "search-06-trending-tap")
            XCTAssertTrue(app.staticTexts["SEARCH RESULTS"].exists, "trending chip should produce results")
        }

        // Recent chip now holds that term — tap it.
        let recent = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'search.recent.'")).firstMatch
        if recent.waitForExistence(timeout: 3) {
            recent.tap()
            Thread.sleep(forTimeInterval: 1.0)
            capture(app, "search-07-recent-tap")
        }

        // FILTERS: switch the sort menu.
        let sort = app.buttons["search.filter.sort"]
        if sort.waitForExistence(timeout: 3) {
            sort.tap()
            Thread.sleep(forTimeInterval: 0.6)
            if app.buttons["Newest"].waitForExistence(timeout: 3) {
                app.buttons["Newest"].tap()
                Thread.sleep(forTimeInterval: 0.8)
                capture(app, "search-08-sort-newest")
            }
        }

        // Open a theme result -> Theme Detail.
        let anyThemeResult = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH 'search.result.theme:'")).firstMatch
        if anyThemeResult.waitForExistence(timeout: 3) {
            anyThemeResult.tap()
            Thread.sleep(forTimeInterval: 1.2)
            capture(app, "search-09-theme-detail")
            XCTAssertFalse(app.textFields["search.field"].exists,
                           "tapping a theme result should navigate off the Search screen")
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
