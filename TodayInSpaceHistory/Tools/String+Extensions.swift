//
//  String+Extensions.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 09/08/2026.
//

import Foundation
import UIKit

extension String {
    /// NASA text often contains HTML entities (e.g. `&#0146;` for ’).
    var decodedHTMLEntities: String {
        let data = Data(utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let decoded = try? NSAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        ).string
        return decoded?.trimmingCharacters(in: .newlines) ?? self
    }
}
