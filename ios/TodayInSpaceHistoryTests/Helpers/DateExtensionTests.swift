//
//  DateExtensionTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

final class DateExtensionTests: XCTestCase {
    func testMonthIsEnglishRegardlessOfLocale() {
        let previousLanguages = UserDefaults.standard.stringArray(forKey: "AppleLanguages")
        UserDefaults.standard.set(["pl-PL"], forKey: "AppleLanguages")
        defer { UserDefaults.standard.set(previousLanguages, forKey: "AppleLanguages") }

        let date = TestFixtures.august9_2026

        let polishFormatter = DateFormatter()
        polishFormatter.locale = Locale(identifier: "pl_PL")
        polishFormatter.dateFormat = "MMMM"
        XCTAssertNotEqual(
            polishFormatter.string(from: date),
            "August",
            "Sanity: a Polish formatter must not emit the NASA English month name"
        )

        XCTAssertEqual(date.month, "August")
        XCTAssertEqual(Date.todayDayMonthComponents(now: date), ["9", "August"])
    }

    func testTodayDayMonthComponentsHasDayAndEnglishMonth() {
        let parts = Date.todayDayMonthComponents()
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
