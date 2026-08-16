//
//  ImageProviderService.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 09/08/2026.
//

import Foundation

protocol ImageProviderServiceProtocol {
    func loadTodaysImage() async throws -> (item: Item, imageURLs: [String])
}

final class ImageProviderService: ImageProviderServiceProtocol {
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }
    
    func loadTodaysImage() async throws -> (item: Item, imageURLs: [String]) {
        let response: APIResponse = try await client.makeRequest(endpoint: .search)
        let items = response.collection.items ?? []
        let todaysItems = items.filter(\.matchesTodaysAnniversary)
        guard let item = (todaysItems.isEmpty ? items : todaysItems).randomElement() else {
            throw Errors.ImageProvider.noItems
        }
        guard let href = item.href else {
            throw Errors.ImageProvider.missingAssetURL
        }
        let rawURLs: [String] = try await client.fetchImages(url: href)
        let imageURLs = rawURLs.map(\.rewritingHTTPSchemeToHTTPS)
        return (item, imageURLs)
    }
}

extension String {
    /// Rewrites only the `http://` scheme prefix; leaves `https://` unchanged.
    var rewritingHTTPSchemeToHTTPS: String {
        guard lowercased().hasPrefix("http://") else { return self }
        return "https://" + dropFirst("http://".count)
    }
}
