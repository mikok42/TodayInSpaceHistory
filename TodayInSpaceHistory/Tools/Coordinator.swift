//
//  Coordinator.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 11/05/2021.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
