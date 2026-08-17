//
//  MainViewViewModel.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation
import Observation

struct MainViewState: Observable {
    var title: String?
    var description: String?
    var imageURL: String?
    var dayLabel: String = Date().formatted(.dateTime.day().month(.wide))
    var isLoading = true
    
    var error: DescriptiveError? = nil
}



@Observable
final class MainViewViewModel {
    private let imageProvider: ImageProviderServiceProtocol
    private let timer: AnalyticsTimer
    
    var viewProperties: MainViewState
    
    init(
        imageProvider: ImageProviderServiceProtocol = ImageProviderService(),
        timer: AnalyticsTimer = AnalyticsTimer(reportName: "downloading")
    ) {
        self.imageProvider = imageProvider
        self.timer = timer
        self.viewProperties = .init()
    }
    
    func reload() async {
        viewProperties = .init()
        await fetchData()
    }
    
    @MainActor
    func fetchData() async {
        viewProperties.isLoading = true
        timer.startTimer()
        defer {
            timer.endTimer()
            timer.reportToAnalytics()
            viewProperties.isLoading = false
        }
        do {
            let (item, imageURLs) = try await imageProvider.loadTodaysImage()
            apply(item: item, imageURLs: imageURLs)
        } catch let error as DescriptiveError {
            viewProperties.error = error
        } catch {
            print(error)
        }
    }
    
    private func apply(item: Item, imageURLs: [String]) {
        viewProperties.error = nil
        viewProperties.imageURL = imageURLs.first {
            $0.contains("large") || $0.contains("medium") || $0.contains("original")
        }
        let result = item.data?.first
        viewProperties.title = result?.title?.decodedHTMLEntities
        viewProperties.description = result?.description?.decodedHTMLEntities
    }
}
