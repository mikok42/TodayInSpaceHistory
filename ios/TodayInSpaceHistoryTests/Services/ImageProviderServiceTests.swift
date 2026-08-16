//
//  ImageProviderServiceTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

final class ImageProviderServiceTests: XCTestCase {
    func testPrefersAnniversaryItems() async throws {
        let client = MockNetworkClient()
        let anniversary = TestFixtures.item(
            title: "Anniversary",
            dateCreated: TestFixtures.todaysAnniversaryDateCreated,
            href: "https://example.com/a.json"
        )
        let other = TestFixtures.item(
            title: "Other",
            dateCreated: TestFixtures.nonAnniversaryDateCreated,
            href: "https://example.com/o.json"
        )
        client.searchResult = .success(TestFixtures.apiResponse(items: [other, anniversary]))
        client.fetchImagesResult = .success(["https://images.example.com/large.jpg"])

        let service = ImageProviderService(client: client)
        let result = try await service.loadTodaysImage()

        XCTAssertEqual(result.item.data?.first?.title, "Anniversary")
        XCTAssertEqual(client.fetchImagesURLs, ["https://example.com/a.json"])
        XCTAssertEqual(result.imageURLs, ["https://images.example.com/large.jpg"])
    }

    func testFallsBackWhenNoAnniversaryMatches() async throws {
        let client = MockNetworkClient()
        let other = TestFixtures.item(
            title: "Fallback",
            dateCreated: TestFixtures.nonAnniversaryDateCreated,
            href: "https://example.com/f.json"
        )
        client.searchResult = .success(TestFixtures.apiResponse(items: [other]))
        client.fetchImagesResult = .success(["http://images.example.com/medium.jpg"])

        let service = ImageProviderService(client: client)
        let result = try await service.loadTodaysImage()

        XCTAssertEqual(result.item.data?.first?.title, "Fallback")
        XCTAssertEqual(result.imageURLs, ["https://images.example.com/medium.jpg"])
    }

    func testThrowsNoItems() async {
        let client = MockNetworkClient()
        client.searchResult = .success(TestFixtures.apiResponse(items: []))
        let service = ImageProviderService(client: client)

        do {
            _ = try await service.loadTodaysImage()
            XCTFail("Expected noItems")
        } catch let error as Errors.ImageProvider {
            XCTAssertEqual(error, .noItems)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testThrowsMissingAssetURL() async {
        let client = MockNetworkClient()
        let item = TestFixtures.item(
            dateCreated: TestFixtures.todaysAnniversaryDateCreated,
            href: nil
        )
        client.searchResult = .success(TestFixtures.apiResponse(items: [item]))
        let service = ImageProviderService(client: client)

        do {
            _ = try await service.loadTodaysImage()
            XCTFail("Expected missingAssetURL")
        } catch let error as Errors.ImageProvider {
            XCTAssertEqual(error, .missingAssetURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRewritesOnlyHTTPScheme() async throws {
        let client = MockNetworkClient()
        let item = TestFixtures.item(
            dateCreated: TestFixtures.todaysAnniversaryDateCreated,
            href: "https://example.com/a.json"
        )
        client.searchResult = .success(TestFixtures.apiResponse(items: [item]))
        client.fetchImagesResult = .success([
            "http://cdn.example.com/large.jpg",
            "https://cdn.example.com/original.jpg"
        ])

        let service = ImageProviderService(client: client)
        let result = try await service.loadTodaysImage()

        XCTAssertEqual(
            result.imageURLs,
            [
                "https://cdn.example.com/large.jpg",
                "https://cdn.example.com/original.jpg"
            ]
        )
    }
}
