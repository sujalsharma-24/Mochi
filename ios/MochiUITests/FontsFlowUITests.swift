import XCTest

/// Exercises the Fonts screen end to end: category pills, sort, a card tap driving the preview,
/// custom preview text, the size slider, Apply, the downloaded-fonts "see all", and the
/// Home → Fonts cross-screen selection. Best-effort screenshots, like `ScreenshotUITests`.
final class FontsFlowUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = true }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let shot = app.screenshot()
        if let dir = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] {
            try? shot.pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name).png"))
        }
        let a = XCTAttachment(screenshot: shot)
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }

    func testFontsFlow() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_SKIP_ONBOARDING"]
        app.launch()

        XCTAssertTrue(app.buttons["tab.fonts"].waitForExistence(timeout: 8))
        app.buttons["tab.fonts"].tap()
        Thread.sleep(forTimeInterval: 1.2)
        capture(app, "fonts-01-initial")

        // Category pill filters the grid.
        if app.buttons["fonts.category.Bold"].waitForExistence(timeout: 3) {
            app.buttons["fonts.category.Bold"].tap()
            Thread.sleep(forTimeInterval: 0.8)
            capture(app, "fonts-02-category-bold")
            XCTAssertTrue(app.otherElements["fonts.card.bold-strong"].exists
                          || app.buttons["fonts.card.bold-strong"].exists
                          || app.staticTexts["Bold Strong"].exists)
        }
        if app.buttons["fonts.category.All"].exists { app.buttons["fonts.category.All"].tap() }
        Thread.sleep(forTimeInterval: 0.6)

        // Sort menu.
        if app.buttons["fonts.sort"].exists {
            app.buttons["fonts.sort"].tap()
            Thread.sleep(forTimeInterval: 0.6)
            let az = app.buttons["A–Z"].firstMatch
            if az.waitForExistence(timeout: 2) { az.tap() }
            Thread.sleep(forTimeInterval: 0.6)
            capture(app, "fonts-03-sorted-az")
        }

        // Tap a font card -> preview follows it. The "Preview" pill is the reliable hit target.
        let card = app.descendants(matching: .any)["fonts.card.gothic-dark.preview"].firstMatch
        if card.waitForExistence(timeout: 3) {
            card.tap()
            Thread.sleep(forTimeInterval: 0.6)
            capture(app, "fonts-04-selected-gothic")
            XCTAssertTrue(app.descendants(matching: .any)["fonts.card.gothic-dark.selected"].firstMatch.waitForExistence(timeout: 3),
                          "Tapping a card's Preview should select it")
        }

        // Custom preview text, then dismiss the keyboard so the panels below are reachable.
        let f2 = app.textFields.firstMatch
        if f2.waitForExistence(timeout: 3) {
            f2.tap()
            f2.typeText("Hello Mochi")
            Thread.sleep(forTimeInterval: 0.8)
            capture(app, "fonts-05-custom-text")
            if app.keyboards.buttons["return"].exists { app.keyboards.buttons["return"].tap() }
            app.swipeUp()
            Thread.sleep(forTimeInterval: 0.5)
        }

        // gothic-dark is Pro: applying it without premium must route to the paywall.
        capture(app, "fonts-06-before-apply")
        let applyBtn = app.descendants(matching: .any)["fonts.applyButton"].firstMatch
        if applyBtn.waitForExistence(timeout: 3) {
            applyBtn.tap()
            Thread.sleep(forTimeInterval: 1.0)
            capture(app, "fonts-07-paywall-for-pro")
            XCTAssertTrue(app.buttons["paywall.close"].waitForExistence(timeout: 3),
                          "Applying a Pro font without premium should open the paywall")
            app.buttons["paywall.close"].tap()
            Thread.sleep(forTimeInterval: 0.8)
        }

        // Now select a Free font and apply it for real.
        let freePreview = app.descendants(matching: .any)["fonts.card.typewriter-classic.preview"].firstMatch
        if freePreview.waitForExistence(timeout: 3) {
            freePreview.tap()
            Thread.sleep(forTimeInterval: 0.5)
            let apply2 = app.descendants(matching: .any)["fonts.applyButton"].firstMatch
            if apply2.waitForExistence(timeout: 3) {
                apply2.tap()
                Thread.sleep(forTimeInterval: 0.8)
                capture(app, "fonts-08-applied-free")
                XCTAssertTrue(app.descendants(matching: .any)["fonts.card.typewriter-classic.apply"].firstMatch.label.contains("Applied")
                              || app.staticTexts["Applied"].firstMatch.exists,
                              "Applying a Free font should mark it Applied")
            }
        }

        // See all downloaded.
        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        let seeAll = app.descendants(matching: .any)["fonts.downloaded.seeAll"].firstMatch
        if seeAll.waitForExistence(timeout: 3) {
            seeAll.tap()
            Thread.sleep(forTimeInterval: 1.0)
            capture(app, "fonts-09-downloaded-list")
            XCTAssertTrue(app.descendants(matching: .any)["downloadedFonts.empty"].firstMatch.exists
                          || app.descendants(matching: .any)["downloadedFonts.row.bubble-cute"].firstMatch.exists,
                          "See all should open the downloaded-fonts collection")
            if app.buttons["downloadedFonts.back"].waitForExistence(timeout: 3) {
                app.buttons["downloadedFonts.back"].tap()
                Thread.sleep(forTimeInterval: 0.8)
            }
        }

        // Home -> Fonts cross-screen selection.
        if app.buttons["tab.keyboard"].waitForExistence(timeout: 3) {
            app.buttons["tab.keyboard"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            let homeCard = app.descendants(matching: .any)["home.fontCard.typewriter-classic"].firstMatch
            let nameText = app.staticTexts["Typewriter Classic"].firstMatch
            if homeCard.waitForExistence(timeout: 3) {
                homeCard.tap()
            } else if nameText.waitForExistence(timeout: 3) {
                nameText.tap()
            }
            Thread.sleep(forTimeInterval: 1.0)
            capture(app, "fonts-10-from-home-typewriter")
            XCTAssertTrue(app.descendants(matching: .any)["fonts.card.typewriter-classic.selected"].firstMatch.waitForExistence(timeout: 4),
                          "Fonts screen should open with the tapped Home font selected")
        }
    }
}
