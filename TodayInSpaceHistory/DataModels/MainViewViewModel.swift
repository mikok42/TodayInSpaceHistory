//
//  MainViewViewModel.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation

class MainViewViewModel {
    private let imageProvider: ImageProviderServiceProtocol
    weak var viewControllerDelegate: ViewControllerDelegate?
    
    var description: String?
    var title: String?
    var httpsImageURLs: [String] = []
    
    let timer = AnalyticsTimer(reportName: "downloading")
    
    init(imageProvider: ImageProviderServiceProtocol = ImageProviderService()) {
        self.imageProvider = imageProvider
    }
    
    func fetchData() {
        Task {
            timer.startTimer()
            defer {
                timer.endTimer()
                timer.reportToAnalytics()
            }
            do {
                let (item, imageURLs) = try await imageProvider.loadTodaysImage()
                await MainActor.run {
                    self.apply(item: item, imageURLs: imageURLs)
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func apply(item: Item, imageURLs: [String]) {
        httpsImageURLs = imageURLs
        let result = item.data?.first
        title = result?.title
        description = result?.description
        viewControllerDelegate?.populate()
    }
}
