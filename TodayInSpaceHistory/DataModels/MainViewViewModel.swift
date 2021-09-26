//
//  MainViewViewModel.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation
import Combine

class MainViewViewModel {
    let dataGetter = HTTPRequestMaker()
    var dataSubscriber: AnyCancellable?
    var imageLinksSubscriber: AnyCancellable?
    var description: String?
    var imageLinks: [String]? {
        didSet {
            guard let images = imageLinks else { return }
            var httpsImageURLs: [String] = []
            images.forEach {
                httpsImageURLs.append($0.replacingOccurrences(of: "http", with: "https", options: .literal))
            }
            self.httpsImageURLs = httpsImageURLs
        }
    }
    
    var httpsImageURLs: [String] = []{
        didSet {
            viewControllerDelegate?.populate()
        }
    }
    
    var data: APIResponse? {
        didSet {
            self.currentItem = data?.collection.items?.randomElement()
            guard let url = currentItem?.href else { return }
            fetchImages(url: url)
            self.description = currentItem?.data?.first?.description
            print("Mikołaj: \(description)")
        }
    }
    
    var currentItem: Item?
    weak var viewControllerDelegate: ViewControllerDelegate?
    
    func fetchData() {
        dataSubscriber = dataGetter.makeRequestAndParse(endpoint: .search, arguments: getCurrentDate())?
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("alles in ordnung")
                    case .failure(let error):
                        print("Mikołaj: err \(error)")
                    }
                },
                receiveValue: { data in
                    self.data = data
        })
    }
    
    func fetchImages(url: String) {
        imageLinksSubscriber = dataGetter.makeRequest(url: url)?
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("alles in ordnung")
                    case .failure(let error):
                        print("Mikołaj: err \(error)")
                    }
                },
                receiveValue: { images in
                    self.imageLinks = images
                    
                    
        })
    }
    
    private func getCurrentDate() -> [String]{
        let date = Date()
        let calendar = Calendar.current
        let day = String(calendar.component(.day, from: date))
        let month = date.month
        return [day, month]
    }
}
