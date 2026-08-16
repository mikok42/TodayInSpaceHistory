//
//  DateExtensionTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

final class DateExtensionTests: XCTestCase {
    func testMonthIsEnglishRegardlessOfLocale() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(calendar: calendar, year: 2026, month: 8, day: 9)
        let date = calendar.date(from: components)!

        // Implementation must use en_US_POSIX, not the device locale.
        XCTAssertEqual(date.month, "August")
    }

    func testTodayDayMonthComponentsHasDayAndEnglishMonth() {
        let parts = Date.todayDayMonthComponents
        XCTAssertEqual(parts.count, 2)
        XCTAssertFalse(parts[0].isEmpty)

        let englishMonths: Set<String> = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        XCTAssertTrue(
            englishMonths.contains(parts[1]),
            "Expected en_US_POSIX month name, got \(parts[1])"
        )
    }
}
