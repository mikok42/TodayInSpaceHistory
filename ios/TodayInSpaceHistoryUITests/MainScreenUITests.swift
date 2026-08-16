//
//  MainScreenUITests.swift
//  TodayInSpaceHistoryUITests
//

import XCTest

final class MainScreenUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestStub"]
        app.launch()
    }

    func testSmokeShowsChrome() {
        let title = app.staticTexts["main.title"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertEqual(title.label, "Today In Space History")
        XCTAssertTrue(app.buttons["main.refresh"].exists)
        XCTAssertTrue(app.staticTexts["main.dayLabel"].exists)

        attachScreenshot(named: "smoke-chrome")
        attachSuccessReport(testName: "testSmokeShowsChrome")
    }

    func testStubbedContentAppears() {
        let imageTitle = app.staticTexts["main.imageTitle"]
        XCTAssertTrue(imageTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(imageTitle.label, "Stub Title")

        let description = app.staticTexts["main.description"]
        XCTAssertTrue(description.waitForExistence(timeout: 5))
        XCTAssertEqual(description.label, "Stub Description")

        attachScreenshot(named: "stubbed-content")
        attachSuccessReport(testName: "testStubbedContentAppears")
    }

    func testRefreshKeepsStubbedContent() {
        let imageTitle = app.staticTexts["main.imageTitle"]
        XCTAssertTrue(imageTitle.waitForExistence(timeout: 5))

        app.buttons["main.refresh"].tap()

        XCTAssertTrue(imageTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(imageTitle.label, "Stub Title")
        XCTAssertEqual(app.staticTexts["main.description"].label, "Stub Description")

        attachScreenshot(named: "after-refresh")
        attachSuccessReport(testName: "testRefreshKeepsStubbedContent")
    }

    private func attachScreenshot(named name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func attachSuccessReport(testName: String) {
        let body = """
        status: SUCCESS
        test: \(testName)
        timestamp: \(ISO8601DateFormatter().string(from: Date()))
        """
        let attachment = XCTAttachment(string: body)
        attachment.name = "\(testName)-report"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
