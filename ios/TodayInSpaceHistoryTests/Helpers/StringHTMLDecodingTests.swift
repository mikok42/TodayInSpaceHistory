//
//  StringHTMLDecodingTests.swift
//  TodayInSpaceHistoryTests
//

import XCTest
@testable import TodayInSpaceHistory

final class StringHTMLDecodingTests: XCTestCase {
    func testDecodesNamedEntity() {
        XCTAssertEqual("&amp;".decodedHTMLEntities, "&")
    }

    func testDecodesNumericEntity() {
        // &#0146; is the Windows-1252-style curly apostrophe; HTML decode yields U+2019.
        XCTAssertEqual("&#0146;".decodedHTMLEntities, "\u{2019}")
    }

    func testPlainTextUnchangedAsideFromTrimming() {
        XCTAssertEqual("hello".decodedHTMLEntities, "hello")
    }
}
