//
//  CustomViewController.swift
//  diveCompanionSnapKit
//
//  Created by Mikołaj Linczewski on 12/05/2021.
//

import UIKit

class CustomViewController<CustomView: UIView>: UIViewController {
    var customView: CustomView {
        return view as! CustomView
    }
    
    override func loadView() {
        view = CustomView()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
