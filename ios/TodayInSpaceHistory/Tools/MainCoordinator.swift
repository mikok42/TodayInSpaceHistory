//
//  MainCoordinator.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 11/05/2021.
//

import UIKit
import SwiftUI

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let hostingController = UIHostingController(rootView: MainView())
        navigationController.pushViewController(hostingController, animated: false)
    }
}
