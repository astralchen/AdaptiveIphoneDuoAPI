import XCTest

@MainActor
final class AdaptiveDuoLabUITests: XCTestCase {
    func testEditableLayoutStateSurvivesRotation() {
        let app = openExample("layout")
        let editor = app.descendants(matching: .any)["apiLab.layout.title"]
        XCTAssertTrue(editor.waitForExistence(timeout: 3))
        editor.tap()
        editor.typeText(" preserved")
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value CONTAINS %@", "preserved"),
            object: editor
        )
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 4), .completed)
    }

    func testToolbarActionsSurviveClosingAndReopeningSession() {
        let app = openExample("toolbar")
        let nativeLaunch = app.buttons["apiLab.toolbar.openNative"]
        let baselineLaunch = app.buttons["apiLab.toolbar.openBaseline"]
        scrollToEither(nativeLaunch, baselineLaunch, in: app)
        (nativeLaunch.exists ? nativeLaunch : baselineLaunch).tap()
        let review = app.buttons["apiLab.toolbar.reviewFallback"]
        XCTAssertTrue(review.waitForExistence(timeout: 4))
        review.tap()
        assertValue("1", for: "apiLab.toolbar.reviewCount", in: app)
        app.buttons["apiLab.toolbar.close"].tap()
        scrollToEither(nativeLaunch, baselineLaunch, in: app)
        (nativeLaunch.exists ? nativeLaunch : baselineLaunch).tap()
        assertValue("1", for: "apiLab.toolbar.reviewCount", in: app)
        app.buttons["apiLab.toolbar.close"].tap()
    }

    func testCameraExampleStartsWithCaptureOff() {
        let app = openExample("camera")
        let start = app.buttons["apiLab.cameraStart"]
        for _ in 0..<6 where !start.isHittable { app.swipeUp() }
        XCTAssertTrue(start.exists)
        XCTAssertFalse(app.buttons["apiLab.cameraStop"].exists)
    }

    func testAPILabUsesSharedRecordsAndCanDismiss() {
        let app = launch(tab: "Settings")
        select("工程", from: "settings.category", in: app)
        let openLab = app.buttons["settings.apiLab"]
        XCTAssertTrue(openLab.waitForExistence(timeout: 5))
        openLab.tap()
        XCTAssertTrue(app.navigationBars["API 实验室"].waitForExistence(timeout: 3))

        let systemDemo = app.buttons["apiLab.systemDemo"]
        XCTAssertTrue(systemDemo.waitForExistence(timeout: 3))
        systemDemo.tap()
        XCTAssertTrue(app.navigationBars["系统布局"].waitForExistence(timeout: 3))
        // 基线构建显示准备说明，原生构建显示记录。
        // 两种路径均保留对所选分类中每条记录的访问能力。
        XCTAssertTrue(
            app.descendants(matching: .any)["apiLab.nativeStatus"].exists ||
            app.descendants(matching: .any)["apiLab.nativeRecords"].exists
        )
        assertValue("3", for: "apiLab.recordCount", in: app)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["API 实验室"].waitForExistence(timeout: 3))
        app.buttons["apiLab.done"].tap()
        assertValue("8", for: "settings.recordCount", in: app)
        assertValue("工程", for: "settings.category", in: app)
        assertValue("3", for: "settings.filteredCount", in: app)
    }

    func testListGridAndAuditJourney() {
        let app = launch(tab: "Workspace")
        showWorkspaceDetail(in: app)

        if !app.buttons["layout.grid"].isHittable {
            app.buttons["layout.menu"].tap()
        }
        app.buttons["layout.grid"].tap()
        XCTAssertTrue(
            app.descendants(matching: .any)["layout.decision"]
                .waitForExistence(timeout: 3)
        )

        app.buttons["audit.open"].tap()
        XCTAssertTrue(app.navigationBars["布局检查"].waitForExistence(timeout: 3))
        app.buttons["audit.done"].tap()
        XCTAssertTrue(app.buttons["audit.open"].waitForExistence(timeout: 3))
    }

    func testSettingsStaySharedAcrossTabsAndRotation() {
        let app = launch(tab: "Settings")
        assertValue("8", for: "settings.recordCount", in: app)

        select("工程", from: "settings.category", in: app)
        select("网格", from: "settings.presentation", in: app)
        select("书本折叠", from: "settings.pose", in: app)
        assertValue("3", for: "settings.filteredCount", in: app)

        openTab("Review", in: app)
        assertReviewState(in: app)

        openTab("Workspace", in: app)
        showWorkspaceDetail(in: app, category: "engineering")
        XCTAssertTrue(app.descendants(matching: .any)["layout.decision"].exists)

        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        openTab("Review", in: app)
        assertReviewState(in: app)

        openTab("Settings", in: app)
        assertValue("工程", for: "settings.category", in: app)
        assertValue("网格", for: "settings.presentation", in: app)
        assertValue("书本折叠", for: "settings.pose", in: app)
        assertValue("3", for: "settings.filteredCount", in: app)
    }

    func testReviewLaunchUsesExistingSeededData() {
        let app = launch(tab: "Review")
        assertValue("全部", for: "review.category", in: app)
        assertValue("8", for: "review.recordCount", in: app)
        assertValue("当前窗口", for: "review.pose", in: app)
        assertValue("自动", for: "review.presentation", in: app)
        XCTAssertFalse(app.buttons["audit.done"].exists)

        openTab("Settings", in: app)
        assertValue("8", for: "settings.recordCount", in: app)
        assertValue("8", for: "settings.filteredCount", in: app)
    }

    private func launch(tab: String) -> XCUIApplication {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-reset-data", "-demo-tab", tab]
        app.launch()
        return app
    }

    private func openExample(_ route: String) -> XCUIApplication {
        let app = launch(tab: "Settings")
        let openLab = app.buttons["settings.apiLab"]
        XCTAssertTrue(openLab.waitForExistence(timeout: 5))
        openLab.tap()
        let destination = app.buttons["apiLab.demo.\(route)"]
        XCTAssertTrue(destination.waitForExistence(timeout: 3))
        for _ in 0..<6 where !destination.isHittable { app.swipeUp() }
        XCTAssertTrue(destination.isHittable)
        destination.tap()
        return app
    }

    private func scrollToEither(_ first: XCUIElement, _ second: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 where !first.isHittable && !second.isHittable { app.swipeUp() }
        XCTAssertTrue(first.isHittable || second.isHittable)
    }

    private func openTab(_ title: String, in app: XCUIApplication) {
        // 根据原生条目的标签查找，无需假定栏的排列轴向。
        let identifiedItem = app.buttons["tabs.\(title.lowercased())"]
        let item = identifiedItem.exists ? identifiedItem : app.buttons.matching(
            NSPredicate(format: "label == %@", ["Workspace": "工作区", "Review": "检查", "Settings": "设置"][title] ?? title)
        ).firstMatch
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        item.tap()
    }

    private func select(_ option: String, from identifier: String, in app: XCUIApplication) {
        let picker = app.buttons[identifier]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.tap()
        let choice = app.buttons.matching(identifier: option).firstMatch
        XCTAssertTrue(choice.waitForExistence(timeout: 3))
        choice.tap()
        assertValue(option, for: identifier, in: app)
    }

    private func assertValue(_ value: String, for identifier: String, in app: XCUIApplication) {
        let element = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: 5), "未找到 \(identifier)")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", value),
            object: element
        )
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 3), .completed,
                       "预期 \(identifier) 的值为 \(value)")
    }

    private func assertReviewState(in app: XCUIApplication) {
        assertValue("工程", for: "review.category", in: app)
        assertValue("网格", for: "review.presentation", in: app)
        assertValue("书本折叠", for: "review.pose", in: app)
        assertValue("3", for: "review.recordCount", in: app)
    }

    private func showWorkspaceDetail(in app: XCUIApplication, category: String = "all") {
        let dashboard = app.staticTexts["自适应工作区"]
        if !dashboard.waitForExistence(timeout: 3) {
            let categoryLink = app.buttons["category.\(category)"]
            XCTAssertTrue(categoryLink.waitForExistence(timeout: 5))
            categoryLink.tap()
        }
        XCTAssertTrue(dashboard.waitForExistence(timeout: 8))
    }
}
