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
            dateCreated: TestFixtures.todaysAnniversaryDateCreated
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
        let viewModel = MainViewViewModel(imageProvider: provider)

        await viewModel.fetchData()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.imageURL, "https://cdn.example.com/large.jpg")
        XCTAssertEqual(viewModel.title, "Apollo & Friends")
        XCTAssertNotNil(viewModel.description)
        XCTAssertFalse(viewModel.description?.contains("&#0146;") ?? true)
    }

    func testFetchDataFailureClearsLoadingWithoutCrashing() async {
        let provider = MockImageProvider(result: .failure(Errors.ImageProvider.noItems))
        let viewModel = MainViewViewModel(imageProvider: provider)

        await viewModel.fetchData()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.imageURL)
        XCTAssertNil(viewModel.title)
    }
}
