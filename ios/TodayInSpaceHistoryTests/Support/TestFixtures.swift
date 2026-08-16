//
//  TestFixtures.swift
//  TodayInSpaceHistoryTests
//

import Foundation
@testable import TodayInSpaceHistory

enum TestFixtures {
    static func item(
        title: String? = "Title",
        description: String? = "Description",
        dateCreated: String?,
        href: String? = "https://example.com/asset.json"
    ) -> Item {
        let result = SearchResult(
            center: nil,
            dateCreated: dateCreated,
            description: description,
            keywords: nil,
            media_type: "image",
            nasaId: "id",
            title: title
        )
        return Item(data: [result], links: nil, href: href)
    }

    static func apiResponse(items: [Item]) -> APIResponse {
        APIResponse(
            collection: Collection(
                links: nil,
                href: nil,
                items: items
            )
        )
    }

    /// `date_created` for today's month/day in an arbitrary past year.
    static var todaysAnniversaryDateCreated: String {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date()
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)
        return String(format: "2001-%02d-%02dT12:00:00Z", month, day)
    }

    /// A `date_created` that is deliberately NOT today's month+day anniversary.
    /// Same month, day flipped to 1 (or 2 if today is already the 1st).
    static var nonAnniversaryDateCreated: String {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date()
        let month = calendar.component(.month, from: today)
        let todayDay = calendar.component(.day, from: today)
        let day = todayDay == 1 ? 2 : 1
        return String(format: "2001-%02d-%02dT12:00:00Z", month, day)
    }
}
