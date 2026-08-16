//
//  MockNetworkClient.swift
//  TodayInSpaceHistoryTests
//

import Foundation
@testable import TodayInSpaceHistory

final class MockNetworkClient: NetworkClientProtocol {
    var searchResult: Result<APIResponse, Error> = .failure(Errors.ImageProvider.noItems)
    var fetchImagesResult: Result<[String], Error> = .success([])
    private(set) var fetchImagesURLs: [String] = []

    func makeRequest<T: Decodable>(endpoint: Endpoints) async throws -> T {
        let response = try searchResult.get()
        guard let typed = response as? T else {
            throw Errors.NetworkClient.decodingFailed(underlying: NSError(domain: "MockNetworkClient", code: 1))
        }
        return typed
    }

    func fetchImages<T: Decodable>(url: String) async throws -> T {
        fetchImagesURLs.append(url)
        let urls = try fetchImagesResult.get()
        guard let typed = urls as? T else {
            throw Errors.NetworkClient.decodingFailed(underlying: NSError(domain: "MockNetworkClient", code: 2))
        }
        return typed
    }
}
