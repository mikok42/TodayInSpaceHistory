//
//  DateExtension.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation

extension Date {
    /// English month name for NASA search queries (locale-independent).
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    static func todayDayMonthComponents(now: Date = Date()) -> [String] {
        let calendar = Calendar(identifier: .gregorian)
        let day = String(calendar.component(.day, from: now))
        let month = now.month
        return [day, month]
    }
}
