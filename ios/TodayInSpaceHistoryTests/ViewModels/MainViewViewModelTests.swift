//
//  MainViewViewModelTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

@MainActor
final class MainViewViewModelTests: XCTestCase {
    func testFetchDataSuccessUsesStubContent() async {
        var reported: (name: String, duration: TimeInterval)?
        let viewModel = MainViewViewModel(
            imageProvider: UITestStubImageProvider(),
            timer: AnalyticsTimer(reportName: "downloading") { name, duration in
                reported = (name, duration)
            }
        )

        await viewModel.fetchData()

        XCTAssertFalse(viewModel.viewProperties.isLoading)
        XCTAssertEqual(viewModel.viewProperties.imageURL, UITestStubImageProvider.stubImageURL)
        XCTAssertEqual(viewModel.viewProperties.title, UITestStubImageProvider.stubTitle)
        XCTAssertEqual(viewModel.viewProperties.description, UITestStubImageProvider.stubDescription)
        XCTAssertEqual(reported?.name, "downloading")
        XCTAssertGreaterThanOrEqual(reported?.duration ?? -1, 0)
    }

    func testFetchDataDecodesHTMLAndPicksPreferredImage() async {
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
        let viewModel = MainViewViewModel(
            imageProvider: provider,
            timer: AnalyticsTimer(reportName: "downloading") { _, _ in }
        )

        await viewModel.fetchData()

        XCTAssertEqual(viewModel.viewProperties.imageURL, "https://cdn.example.com/large.jpg")
        XCTAssertEqual(viewModel.viewProperties.title, "Apollo & Friends")
        XCTAssertFalse(viewModel.viewProperties.description?.contains("&#0146;") ?? true)
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

        XCTAssertFalse(viewModel.viewProperties.isLoading)
        XCTAssertNil(viewModel.viewProperties.imageURL)
        XCTAssertNil(viewModel.viewProperties.title)
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
        XCTAssertTrue(viewModel.viewProperties.isLoading)
        provider.release()
        await fetch
        XCTAssertFalse(viewModel.viewProperties.isLoading)
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

        XCTAssertNil(viewModel.viewProperties.imageURL)
        XCTAssertEqual(viewModel.viewProperties.title, "Only thumbs")
        XCTAssertFalse(viewModel.viewProperties.isLoading)
    }
}
