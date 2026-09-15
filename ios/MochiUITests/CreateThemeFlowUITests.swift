import XCTest

/// Exercises the Create Custom Theme screen end to end: tab switching, background/key
/// shape/color/font/effect selection, name + Save Draft + Publish, and Back. Best-effort
/// screenshots, like `ScreenshotUITests`/`FontsFlowUITests`.
final class CreateThemeFlowUITests: XCTestCase {
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

    func testCreateThemeFlow() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_SKIP_ONBOARDING"]
        app.launch()

        XCTAssertTrue(app.buttons["tab.create"].waitForExistence(timeout: 8))
        app.buttons["tab.create"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        capture(app, "create-01-background")

        // Background tab: picking a real plate updates the draft immediately.
        let plate = app.descendants(matching: .any)["create.background.plate.themebg_zen_garden"].firstMatch
        if plate.waitForExistence(timeout: 3) {
            plate.tap()
            Thread.sleep(forTimeInterval: 0.6)
            capture(app, "create-02-plate-selected")
        }

        // Keys tab: shape + colour.
        XCTAssertTrue(app.descendants(matching: .any)["create.tab.keys"].firstMatch.waitForExistence(timeout: 3))
        app.descendants(matching: .any)["create.tab.keys"].firstMatch.tap()
        Thread.sleep(forTimeInterval: 0.6)
        capture(app, "create-03-keys-tab")

        let hexagon = app.descendants(matching: .any)["create.keyShape.hexagon"].firstMatch
        if hexagon.waitForExistence(timeout: 3) {
            hexagon.tap()
            Thread.sleep(forTimeInterval: 0.5)
            capture(app, "create-04-hexagon-shape")
        }

        let keySquare = app.descendants(matching: .any)["create.keyColor.square"].firstMatch
        if keySquare.waitForExistence(timeout: 3) {
            keySquare.tap()
            Thread.sleep(forTimeInterval: 0.5)
            capture(app, "create-05-key-color-dragged")
        }
        let hueRail = app.descendants(matching: .any)["create.keyColor.hueRail"].firstMatch
        if hueRail.waitForExistence(timeout: 3) {
            hueRail.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5)).tap()
            Thread.sleep(forTimeInterval: 0.5)
            capture(app, "create-06-hue-dragged")
        }

        // Fonts tab.
        app.descendants(matching: .any)["create.tab.fonts"].firstMatch.tap()
        Thread.sleep(forTimeInterval: 0.6)
        let handwritten = app.descendants(matching: .any)["create.font.handwritten"].firstMatch
        if handwritten.waitForExistence(timeout: 3) {
            handwritten.tap()
            Thread.sleep(forTimeInterval: 0.5)
            capture(app, "create-07-handwritten-font")
        }

        // Effect tab.
        app.descendants(matching: .any)["create.tab.effect"].firstMatch.tap()
        Thread.sleep(forTimeInterval: 0.6)
        let sparkle = app.descendants(matching: .any)["create.effect.sparkle"].firstMatch
        if sparkle.waitForExistence(timeout: 3) {
            sparkle.tap()
            Thread.sleep(forTimeInterval: 0.5)
            capture(app, "create-08-sparkle-effect")
        }

        // Name, then Save Draft.
        let nameField = app.textFields.firstMatch
        if nameField.waitForExistence(timeout: 3) {
            nameField.tap()
            nameField.typeText("UITest Theme")
            if app.keyboards.buttons["return"].exists { app.keyboards.buttons["return"].tap() }
        }

        let saveDraft = app.descendants(matching: .any)["create.saveDraft"].firstMatch
        if saveDraft.waitForExistence(timeout: 3) {
            saveDraft.tap()
            Thread.sleep(forTimeInterval: 0.8)
            capture(app, "create-09-draft-saved")
            XCTAssertTrue(app.staticTexts["Draft saved."].waitForExistence(timeout: 3),
                          "Save Draft should confirm the save")
        }

        // Publish.
        let publish = app.descendants(matching: .any)["create.publish"].firstMatch
        if publish.waitForExistence(timeout: 3) {
            publish.tap()
            Thread.sleep(forTimeInterval: 0.8)
            capture(app, "create-10-published")
            let publishedText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Published'")).firstMatch
            XCTAssertTrue(publishedText.waitForExistence(timeout: 3), "Publish should confirm the theme went live")
        }

        // Back returns to the Keyboard (Home) tab, and the published theme should already be live
        // in Themes' own grid — before Reset All, which (correctly) unpublishes a draft that no
        // longer has the name/tags/etc. it was published with.
        let back = app.buttons["create.back"].firstMatch
        if back.waitForExistence(timeout: 3) {
            back.tap()
            Thread.sleep(forTimeInterval: 0.8)
            capture(app, "create-11-after-back")
            XCTAssertTrue(app.buttons["tab.create"].waitForExistence(timeout: 3),
                          "Back should leave the Create tab and return to a normal tab bar state")
        }

        if app.buttons["tab.themes"].waitForExistence(timeout: 3) {
            app.buttons["tab.themes"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            capture(app, "create-12-in-themes-tab")
            XCTAssertTrue(app.staticTexts["UITest Theme"].waitForExistence(timeout: 3),
                          "A published custom theme should appear in the Themes tab")
        }

        // Reopening Create should restore the published draft (local-first persistence) — the
        // theme name field still shows what was published, since Reset All hasn't run yet.
        app.buttons["tab.create"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        capture(app, "create-13-reopened")
        let reopenedName = app.textFields.firstMatch
        XCTAssertTrue(reopenedName.waitForExistence(timeout: 3) && (reopenedName.value as? String)?.contains("UITest") == true,
                      "Reopening Create should restore the last-active draft's name")

        // Reset All actually clears the name field back to empty (its placeholder, not the name).
        let resetAll = app.descendants(matching: .any)["create.resetAll"].firstMatch
        if resetAll.waitForExistence(timeout: 3) {
            resetAll.tap()
            Thread.sleep(forTimeInterval: 0.5)
            capture(app, "create-14-reset")
            XCTAssertFalse((app.textFields.firstMatch.value as? String)?.contains("UITest") == true,
                           "Reset All should clear the theme name")
        }
    }
}
