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

final class GatedImageProvider: ImageProviderServiceProtocol {
    private let result: Result<(item: Item, imageURLs: [String]), Error>
    private var gateContinuation: CheckedContinuation<Void, Never>?
    private var enteredContinuation: CheckedContinuation<Void, Never>?
    private var didEnter = false

    init(result: Result<(item: Item, imageURLs: [String]), Error>) {
        self.result = result
    }

    func waitUntilEntered() async {
        if didEnter { return }
        await withCheckedContinuation { enteredContinuation = $0 }
    }

    func loadTodaysImage() async throws -> (item: Item, imageURLs: [String]) {
        didEnter = true
        enteredContinuation?.resume()
        enteredContinuation = nil
        await withCheckedContinuation { gateContinuation = $0 }
        return try result.get()
    }

    func release() {
        gateContinuation?.resume()
        gateContinuation = nil
    }
}
