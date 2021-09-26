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

class WelcomeViewController: CustomViewController<WelcomeView>, ViewControllerDelegate {
    var viewModel: MainViewViewModel
    
    override init() {
        self.viewModel = MainViewViewModel()
        super.init()
        self.viewModel.viewControllerDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchData()
    }
    
    func populate() {
        guard let url = viewModel.httpsImageURLs.first(where: { $0.contains("large") || $0.contains("medium") }) else { return }
        guard let description = viewModel.description else { return }
        customView.populate(imageLink: url, description: description)
    }
}

