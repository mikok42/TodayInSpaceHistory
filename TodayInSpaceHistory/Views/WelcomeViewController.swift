//
//  ViewController.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import UIKit
import Combine
import Firebase

protocol ViewControllerDelegate: AnyObject {
    func populate()
}

class WelcomeViewController: CustomViewController<WelcomeView>, ViewControllerDelegate, RefreshViewDelegate {
    let analyticsOfficer = AnalyticsTimer(reportName: "view_loading")
    
    var didSendLoadReport: Bool = false
    var viewModel: MainViewViewModel
    var coordinator: Coordinator?
    override init() {
        self.viewModel = MainViewViewModel()
        super.init()
        self.viewModel.viewControllerDelegate = self
        self.customView.refreshDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        analyticsOfficer.startTimer()
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
        if !didSendLoadReport {
            analyticsOfficer.endTimer()
            analyticsOfficer.reportToAnalytics()
            didSendLoadReport = true
        }
    }
    
    func refreshView() {
        viewModel.fetchData()
    }
}

