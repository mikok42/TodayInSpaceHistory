//
//  MainCoordinator.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 11/05/2021.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = WelcomeViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
}
