//
//  NetworkClientTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

final class NetworkClientTests: XCTestCase {
    private var client: NetworkClient!
    private var lastRequestURL: URL?

    private let nasaSearchJSON = """
    {"collection":{"items":[{"href":"https://images-assets.nasa.gov/image/MSFC-1601301/collection.json","data":[{"center":"MSFC","date_created":"2014-03-16T00:00:00Z","description":"A &amp; B","media_type":"image","nasa_id":"MSFC-1601301","title":"Apollo"}]}]}}
    """

    override func setUp() {
        super.setUp()
        client = NetworkClient(session: .stubbed())
    }

    override func tearDown() {
        StubURLProtocol.respond = nil
        lastRequestURL = nil
        client = nil
        super.tearDown()
    }

    func testMakeRequestDecodesNASASnakeCaseFields() async throws {
        stub(statusCode: 200, body: Data(nasaSearchJSON.utf8))

        let response: APIResponse = try await client.makeRequest(endpoint: .search)
        let result = response.collection.items?.first?.data?.first

        XCTAssertEqual(result?.dateCreated, "2014-03-16T00:00:00Z")
        XCTAssertEqual(result?.mediaType, "image")
        XCTAssertEqual(result?.nasaId, "MSFC-1601301")
        XCTAssertEqual(result?.title, "Apollo")
    }

    func testMakeRequestUsesNASASearchQuery() async throws {
        stub(statusCode: 200, body: Data(nasaSearchJSON.utf8))

        let _: APIResponse = try await client.makeRequest(endpoint: .search)

        assertNASASearchURL(lastRequestURL)
    }

    func testMakeRequestThrowsOnNotFound() async {
        stub(statusCode: 404, body: Data(#"{"error":"nope"}"#.utf8))

        await assertUnacceptableStatusCode(404) {
            let _: APIResponse = try await self.client.makeRequest(endpoint: .search)
        }
        assertNASASearchURL(lastRequestURL)
    }

    func testMakeRequestThrowsOnServerError() async {
        stub(statusCode: 500, body: Data())

        await assertUnacceptableStatusCode(500) {
            let _: APIResponse = try await self.client.makeRequest(endpoint: .search)
        }
        assertNASASearchURL(lastRequestURL)
    }

    func testFetchImagesThrowsOnNotFound() async {
        stub(statusCode: 404, body: Data())

        await assertUnacceptableStatusCode(404) {
            let _: [String] = try await self.client.fetchImages(url: "https://example.com/a.json")
        }
        XCTAssertEqual(lastRequestURL?.absoluteString, "https://example.com/a.json")
    }

    func testMakeRequestThrowsDecodingFailedOnMalformedBody() async {
        stub(statusCode: 200, body: Data("not json".utf8))

        do {
            let _: APIResponse = try await client.makeRequest(endpoint: .search)
            XCTFail("Expected decodingFailed")
        } catch let error as Errors.NetworkClient {
            guard case .decodingFailed = error else {
                return XCTFail("Expected decodingFailed, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        assertNASASearchURL(lastRequestURL)
    }

    private func stub(statusCode: Int, body: Data) {
        lastRequestURL = nil
        StubURLProtocol.respond = { [weak self] request in
            self?.lastRequestURL = request.url
            let url = request.url ?? URL(fileURLWithPath: "/")
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw URLError(.badServerResponse)
            }
            return (response, body)
        }
    }

    private func assertNASASearchURL(_ url: URL?, file: StaticString = #filePath, line: UInt = #line) {
        guard let url else {
            return XCTFail("Expected a captured request URL", file: file, line: line)
        }
        XCTAssertEqual(url.host, "images-api.nasa.gov", file: file, line: line)
        XCTAssertEqual(url.path, "/search", file: file, line: line)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let query = Dictionary(uniqueKeysWithValues: items.compactMap { item -> (String, String)? in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })
        XCTAssertEqual(query["media_type"], "image", file: file, line: line)
        let description = query["description"] ?? ""
        let englishMonths = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        XCTAssertTrue(
            englishMonths.contains { description.contains($0) },
            "Expected English month in description, got \(description)",
            file: file,
            line: line
        )
        let day = description.split(separator: " ").first.map(String.init) ?? ""
        XCTAssertNotNil(Int(day), "Expected numeric day in description, got \(description)", file: file, line: line)
    }

    private func assertUnacceptableStatusCode(
        _ expected: Int,
        file: StaticString = #filePath,
        line: UInt = #line,
        when perform: () async throws -> Void
    ) async {
        do {
            try await perform()
            XCTFail("Expected unacceptableStatusCode(\(expected))", file: file, line: line)
        } catch let error as Errors.NetworkClient {
            guard case .unacceptableStatusCode(let statusCode) = error else {
                return XCTFail("Expected unacceptableStatusCode, got \(error)", file: file, line: line)
            }
            XCTAssertEqual(statusCode, expected, file: file, line: line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }
}
