//
//  ItemAnniversaryTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

final class ItemAnniversaryTests: XCTestCase {
    func testMatchesHardcodedAnniversaryDate() {
        let item = TestFixtures.item(dateCreated: TestFixtures.anniversaryDateCreated)
        XCTAssertTrue(item.matchesAnniversary(of: TestFixtures.july20_2026))
    }

    func testDoesNotMatchOtherDay() {
        let item = TestFixtures.item(dateCreated: TestFixtures.anniversaryDateCreated)
        XCTAssertFalse(item.matchesAnniversary(of: TestFixtures.august9_2026))
    }

    func testInvalidOrShortDateReturnsFalse() {
        let now = TestFixtures.july20_2026
        XCTAssertFalse(TestFixtures.item(dateCreated: "bad").matchesAnniversary(of: now))
        XCTAssertFalse(TestFixtures.item(dateCreated: nil).matchesAnniversary(of: now))
        XCTAssertFalse(TestFixtures.item(dateCreated: "2020-01").matchesAnniversary(of: now))
    }
}
