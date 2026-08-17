//
//  UITestStubImageProvider.swift
//  TodayInSpaceHistory
//

import Foundation
import UIKit

enum UITestLaunchArgument {
    static let stub = "-UITestStub"
}

/// Deterministic provider for previews, UI tests, and unit tests.
final class UITestStubImageProvider: ImageProviderServiceProtocol {
    static let stubTitle = "Stub Title"
    static let stubDescription = "Stub Description"
    static let stubFallbackImageURL = "https://example.com/images/large.jpg"

    static var stubImageURL: String {
        previewMockURL?.absoluteString ?? stubFallbackImageURL
    }

    static var previewMockURL: URL? {
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("preview-large.jpg")
        if let bundled = Bundle.main.url(forResource: "PreviewMock", withExtension: "jpg"),
           let data = try? Data(contentsOf: bundled) {
            try? data.write(to: destination)
            return destination
        }
        guard let image = UIImage(named: "PreviewMock"),
              let data = image.jpegData(compressionQuality: 0.9) else {
            return nil
        }
        try? data.write(to: destination)
        return destination
    }

    func loadTodaysImage() async throws -> (item: Item, imageURLs: [String]) {
        let result = SearchResult(
            center: nil,
            dateCreated: "1969-07-20T00:00:00Z",
            description: Self.stubDescription,
            keywords: nil,
            mediaType: "image",
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
