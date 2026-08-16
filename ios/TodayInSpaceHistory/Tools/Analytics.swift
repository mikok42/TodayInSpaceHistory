//
//  Analytics.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 04/10/2021.
//

import Foundation
import FirebaseAnalytics

class AnalyticsTimer {
    internal let reportName: String
    private let onReport: (String, TimeInterval) -> Void
    
    private var startTime: TimeInterval = 0
    private var endTime: TimeInterval = 0
    private var duration: TimeInterval { endTime - startTime }
    
    init(
        reportName: String,
        onReport: @escaping (String, TimeInterval) -> Void = { name, duration in
            FirebaseAnalytics.Analytics.logEvent(name, parameters: ["duration_ms": duration])
        }
    ) {
        self.reportName = reportName
        self.onReport = onReport
    }
    
    func startTimer() {
        startTime = (Double(DispatchTime.now().uptimeNanoseconds) / 1000000.0)
    }
    
    func endTimer() {
        endTime = (Double(DispatchTime.now().uptimeNanoseconds) / 1000000.0)
    }
    
    func reportToAnalytics() {
        onReport(reportName, duration)
    }
}
