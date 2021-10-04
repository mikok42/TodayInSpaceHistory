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
    
    private var startTime: TimeInterval = 0
    private var endTime: TimeInterval = 0
    private var duration: TimeInterval { endTime - startTime }
    
    init(reportName: String) {
        self.reportName = reportName
    }
    
    func startTimer() {
        startTime = (Double(DispatchTime.now().uptimeNanoseconds) / 1000000.0)
    }
    
    func endTimer() {
        endTime = (Double(DispatchTime.now().uptimeNanoseconds) / 1000000.0)
    }
    
    func reportToAnalytics() {
        FirebaseAnalytics.Analytics.logEvent(reportName, parameters: ["duration_ms": duration])
    }
}
