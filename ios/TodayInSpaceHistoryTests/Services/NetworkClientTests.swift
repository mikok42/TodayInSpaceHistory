//
//  NetworkClientTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

final class NetworkClientTests: XCTestCase {
    private var client: NetworkClient!

    override func setUp() {
        super.setUp()
        client = NetworkClient(session: .stubbed())
    }

    override func tearDown() {
        StubURLProtocol.respond = nil
        client = nil
        super.tearDown()
    }

    func testMakeRequestDecodesSuccessfulResponse() async throws {
        let json = """
        {"collection":{"items":[{"href":"https://example.com/a.json","data":[{"title":"Apollo"}]}]}}
        """
        stub(statusCode: 200, body: Data(json.utf8))

        let response: APIResponse = try await client.makeRequest(endpoint: .search)

        XCTAssertEqual(response.collection.items?.count, 1)
        XCTAssertEqual(response.collection.items?.first?.data?.first?.title, "Apollo")
    }

    func testMakeRequestThrowsOnNotFound() async {
        stub(statusCode: 404, body: Data(#"{"error":"nope"}"#.utf8))

        await assertUnacceptableStatusCode(404) {
            let _: APIResponse = try await self.client.makeRequest(endpoint: .search)
        }
    }

    func testMakeRequestThrowsOnServerError() async {
        stub(statusCode: 500, body: Data())

        await assertUnacceptableStatusCode(500) {
            let _: APIResponse = try await self.client.makeRequest(endpoint: .search)
        }
    }

    func testFetchImagesThrowsOnNotFound() async {
        stub(statusCode: 404, body: Data())

        await assertUnacceptableStatusCode(404) {
            let _: [String] = try await self.client.fetchImages(url: "https://example.com/a.json")
        }
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
    }

    private func stub(statusCode: Int, body: Data) {
        StubURLProtocol.respond = { request in
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
