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
    
    static var todayDayMonthComponents: [String] {
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let day = String(calendar.component(.day, from: date))
        let month = date.month
        return [day, month]
    }
}
