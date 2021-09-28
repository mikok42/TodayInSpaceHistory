//
//  ViewController.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import UIKit
import Combine

protocol ViewControllerDelegate: AnyObject {
    func populate()
}

class WelcomeViewController: CustomViewController<WelcomeView>, ViewControllerDelegate, RefreshViewDelegate {
    
    var viewModel: MainViewViewModel
    var coordinator: Coordinator?
    override init() {
        self.viewModel = MainViewViewModel()
        super.init()
        self.viewModel.viewControllerDelegate = self
        self.customView.refreshDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchData()
    }
    
    func populate() {
        guard let url = viewModel.httpsImageURLs.first(where: {
            $0.contains("large") || $0.contains("medium") ||
            $0.contains("original") }) else { return }
        guard let description = viewModel.description else { return }
        guard let title = viewModel.title else { return }
        customView.populate(imageLink: url, description: description, title: title)
        if #available(iOS 15.0, *) {
            do {
                let x = try Date(viewModel.date_created!, strategy: .iso8601)
                print("Mikołaj: \(x)")
            } catch {
                print("Mikołaj: \(error)")
            }
        }
    }
    
    func refreshView() {
        viewModel.fetchData()
    }
}

