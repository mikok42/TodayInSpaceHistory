//
//  UITestStubImageProvider.swift
//  TodayInSpaceHistory
//

import Foundation

enum UITestLaunchArgument {
    static let stub = "-UITestStub"
}

/// Deterministic provider used when the app is launched with `-UITestStub`.
final class UITestStubImageProvider: ImageProviderServiceProtocol {
    static let stubTitle = "Stub Title"
    static let stubDescription = "Stub Description"
    static let stubImageURL = "https://example.com/images/large.jpg"

    func loadTodaysImage() async throws -> (item: Item, imageURLs: [String]) {
        let result = SearchResult(
            center: nil,
            dateCreated: "1969-07-20T00:00:00Z",
            description: Self.stubDescription,
            keywords: nil,
            media_type: "image",
            nasaId: "stub",
            title: Self.stubTitle
        )
        let item = Item(
            data: [result],
            links: nil,
            href: "https://example.com/asset.json"
        )
        return (item, [Self.stubImageURL])
    }
}

extension ProcessInfo {
    var isUITestStubLaunch: Bool {
        arguments.contains(UITestLaunchArgument.stub)
    }
}
