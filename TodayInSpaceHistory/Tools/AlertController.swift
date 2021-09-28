//
//  AlertController.swift
//  diveCompanionSnapKit
//
//  Created by Mikołaj Linczewski on 26/05/2021.
//
import Foundation
import UIKit

extension CustomViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
