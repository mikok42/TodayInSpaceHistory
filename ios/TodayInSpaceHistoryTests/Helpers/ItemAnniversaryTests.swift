//
//  ItemAnniversaryTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

final class ItemAnniversaryTests: XCTestCase {
    func testMatchesTodaysAnniversary() {
        let item = TestFixtures.item(dateCreated: TestFixtures.todaysAnniversaryDateCreated)
        XCTAssertTrue(item.matchesTodaysAnniversary)
    }

    func testDoesNotMatchOtherDay() {
        let item = TestFixtures.item(dateCreated: TestFixtures.nonAnniversaryDateCreated)
        XCTAssertFalse(item.matchesTodaysAnniversary)
    }

    func testInvalidOrShortDateReturnsFalse() {
        XCTAssertFalse(TestFixtures.item(dateCreated: "bad").matchesTodaysAnniversary)
        XCTAssertFalse(TestFixtures.item(dateCreated: nil).matchesTodaysAnniversary)
        XCTAssertFalse(TestFixtures.item(dateCreated: "2020-01").matchesTodaysAnniversary)
    }
}
