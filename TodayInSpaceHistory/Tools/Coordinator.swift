//
//  Coordinator.swift
//  diveCompanionSnapKit
//
//  Created by Mikołaj Linczewski on 11/05/2021.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set}
    var navigationController: UINavigationController { get set }
    
    func goToMainView()
}
