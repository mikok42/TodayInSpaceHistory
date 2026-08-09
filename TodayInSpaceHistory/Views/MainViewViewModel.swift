//
//  MainViewViewModel.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation
import Observation

@Observable
final class MainViewViewModel {
    private let imageProvider: ImageProviderServiceProtocol
    let timer = AnalyticsTimer(reportName: "downloading")
    
    var title: String?
    var description: String?
    var imageURL: String?
    var dayLabel: String = Date().formatted(.dateTime.day().month(.wide))
    var isLoading = false
    
    init(imageProvider: ImageProviderServiceProtocol = ImageProviderService()) {
        self.imageProvider = imageProvider
    }
    
    @MainActor
    func fetchData() async {
        isLoading = true
        timer.startTimer()
        defer {
            timer.endTimer()
            timer.reportToAnalytics()
            isLoading = false
        }
        do {
            let (item, imageURLs) = try await imageProvider.loadTodaysImage()
            apply(item: item, imageURLs: imageURLs)
        } catch let error as DescriptiveError {
            print(error.description)
        } catch {
            print(error)
        }
    }
    
    private func apply(item: Item, imageURLs: [String]) {
        imageURL = imageURLs.first {
            $0.contains("large") || $0.contains("medium") || $0.contains("original")
        }
        let result = item.data?.first
        title = result?.title
        description = result?.description
    }
}
