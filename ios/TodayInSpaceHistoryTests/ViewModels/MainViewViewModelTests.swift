//
//  MainViewViewModelTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

@MainActor
final class MainViewViewModelTests: XCTestCase {
    func testFetchDataSuccessDecodesAndPicksPreferredImage() async {
        let item = TestFixtures.item(
            title: "Apollo &amp; Friends",
            description: "Hello &#0146; world",
            dateCreated: TestFixtures.anniversaryDateCreated
        )
        let provider = MockImageProvider(
            result: .success((
                item: item,
                imageURLs: [
                    "https://cdn.example.com/thumb.jpg",
                    "https://cdn.example.com/large.jpg",
                    "https://cdn.example.com/original.jpg"
                ]
            ))
        )
        var reported: (name: String, duration: TimeInterval)?
        let viewModel = MainViewViewModel(
            imageProvider: provider,
            timer: AnalyticsTimer(reportName: "downloading") { name, duration in
                reported = (name, duration)
            }
        )

        await viewModel.fetchData()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.imageURL, "https://cdn.example.com/large.jpg")
        XCTAssertEqual(viewModel.title, "Apollo & Friends")
        XCTAssertNotNil(viewModel.description)
        XCTAssertFalse(viewModel.description?.contains("&#0146;") ?? true)
        XCTAssertEqual(reported?.name, "downloading")
        XCTAssertGreaterThanOrEqual(reported?.duration ?? -1, 0)
    }

    func testFetchDataFailureClearsLoadingWithoutCrashing() async {
        let provider = MockImageProvider(result: .failure(Errors.ImageProvider.noItems))
        var reportedName: String?
        let viewModel = MainViewViewModel(
            imageProvider: provider,
            timer: AnalyticsTimer(reportName: "downloading") { name, _ in
                reportedName = name
            }
        )

        await viewModel.fetchData()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.imageURL)
        XCTAssertNil(viewModel.title)
        XCTAssertEqual(reportedName, "downloading")
    }

    func testFetchDataSetsLoadingWhileInFlight() async {
        let item = TestFixtures.item(dateCreated: TestFixtures.anniversaryDateCreated)
        let provider = GatedImageProvider(
            result: .success((item: item, imageURLs: ["https://cdn.example.com/large.jpg"]))
        )
        let viewModel = MainViewViewModel(
            imageProvider: provider,
            timer: AnalyticsTimer(reportName: "downloading") { _, _ in }
        )

        async let fetch: Void = viewModel.fetchData()
        await provider.waitUntilEntered()
        XCTAssertTrue(viewModel.isLoading)
        provider.release()
        await fetch
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFetchDataLeavesImageURLNilWhenNoPreferredSize() async {
        let item = TestFixtures.item(
            title: "Only thumbs",
            dateCreated: TestFixtures.anniversaryDateCreated
        )
        let provider = MockImageProvider(
            result: .success((
                item: item,
                imageURLs: [
                    "https://cdn.example.com/thumb.jpg",
                    "https://cdn.example.com/small.jpg"
                ]
            ))
        )
        let viewModel = MainViewViewModel(
            imageProvider: provider,
            timer: AnalyticsTimer(reportName: "downloading") { _, _ in }
        )

        await viewModel.fetchData()

        XCTAssertNil(viewModel.imageURL)
        XCTAssertEqual(viewModel.title, "Only thumbs")
        XCTAssertFalse(viewModel.isLoading)
    }
}
