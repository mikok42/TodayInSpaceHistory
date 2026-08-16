//
//  TestFixtures.swift
//  TodayInSpaceHistoryTests
//

import Foundation
@testable import TodayInSpaceHistory

enum TestFixtures {
    static let anniversaryDateCreated = "1969-07-20T20:17:40Z"
    static let otherDateCreated = "1971-08-16T00:00:00Z"

    static var july20_2026: Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
    }

    static var august9_2026: Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: DateComponents(year: 2026, month: 8, day: 9, hour: 12))!
    }

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
            mediaType: "image",
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
}
