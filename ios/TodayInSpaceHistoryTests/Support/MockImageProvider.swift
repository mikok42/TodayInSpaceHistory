//
//  MockImageProvider.swift
//  TodayInSpaceHistoryTests
//

import Foundation
@testable import TodayInSpaceHistory

final class MockImageProvider: ImageProviderServiceProtocol {
    var result: Result<(item: Item, imageURLs: [String]), Error>

    init(result: Result<(item: Item, imageURLs: [String]), Error>) {
        self.result = result
    }

    func loadTodaysImage() async throws -> (item: Item, imageURLs: [String]) {
        try result.get()
    }
}
