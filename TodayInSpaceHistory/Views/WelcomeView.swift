//
//  WelcomeView.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation
import SnapKit
import Then
import Kingfisher
import UIKit

protocol RefreshViewDelegate: AnyObject {
    func refreshView()
}

class WelcomeView: UIView {
    weak var refreshDelegate: RefreshViewDelegate?
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .black
        addSubviews()
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var welcomeLabel = UILabel().then {
        $0.text = "Today In Space History"
        $0.textColor = .white
        $0.font = UIFont(name: "Avenir Next Ultra Light", size: 25)
    }
    
    private lazy var dayLabel = UILabel().then {
        $0.text = "26.09"
        $0.textColor = .white
        $0.font = UIFont(name: Constants.fontName + Constants.lightFontMod, size: 20)
    }
    
    private lazy var refreshButton = UIButton().then {
        $0.setTitle("↺", for: .normal)
        $0.backgroundColor = .clear
        $0.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        $0.layer.cornerRadius = 0.5 * $0.bounds.size.width
        
        $0.addTarget(self, action: #selector(refreshButtonPressed(_:)), for: .touchUpInside)
        $0.addTarget(self, action: #selector(buttonLetGoOutside(_:)), for: .touchUpOutside)
        $0.addTarget(self, action: #selector(buttonTouched), for: .touchDown)
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.backgroundColor = .white.withAlphaComponent(0.5)
        $0.font = UIFont(name: Constants.fontName + Constants.boldFontMod, size: 15)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    private lazy var descriptionLabel = UITextView().then {
        $0.backgroundColor = .black
        $0.textColor = .white
        $0.font = UIFont(name: Constants.fontName, size: 20)
        $0.isEditable = false
        $0.isScrollEnabled = true
    }
    
    private lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 50.0
    }
    
    private func addSubviews() {
        [welcomeLabel, dayLabel, imageView, descriptionLabel, titleLabel, refreshButton].forEach { addSubview($0) }
    }
    
    private func setupSubviews() {
        welcomeLabelSetup()
        dayLabelSetup()
        imageViewSetup()
        titleLabelSetup()
        descriptionLabelSetup()
        refreshButtonSetup()
    }
    
    internal func populate(imageLink: String, description: String, title: String) {
        imageView.kf.setImage(
            with: URL(string: imageLink),
            options: [.transition(.fade(0.2))]
        )
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = date.month
        dayLabel.text = [String(day), month].map ({ $0 }).joined(separator: " ")
        descriptionLabel.text = description
        titleLabel.text = title
    }
    
    @objc private func refreshButtonPressed(_ sender: UIButton) {
        sender.alpha = 1
        refreshDelegate?.refreshView()
    }
    
    @objc private func buttonLetGoOutside(_ sender: UIButton) {
        sender.alpha = 1
    }
    
    @objc private func buttonTouched(_ sender: UIButton) {
        sender.alpha = 0.5
    }
    
    //MARK: constraints setup
    private func welcomeLabelSetup() {
        welcomeLabel.snp.makeConstraints {
            $0.centerX.equalTo(snp.centerX)
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func dayLabelSetup() {
        dayLabel.snp.makeConstraints {
            $0.leading.equalTo(welcomeLabel.snp.leading)
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(Constants.labelsMargins)
        }
    }
    
    private func titleLabelSetup() {
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(imageView.snp.bottom).inset(20)
            $0.leading.equalTo(imageView.snp.leading)
            $0.trailing.equalTo(imageView.snp.centerX)
        }
    }
    
    private func imageViewSetup() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(Constants.labelsMargins)
            $0.leading.equalTo(snp.leading).inset(10)
            $0.trailing.equalTo(snp.trailing).inset(10)
            $0.height.equalTo(300)
        }
    }
    
    private func refreshButtonSetup() {
        refreshButton.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel.snp.top)
            $0.trailing.equalTo(snp.trailing).inset(15)
        }
    }
    
    private func descriptionLabelSetup() {
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(Constants.labelsMargins)
            $0.leading.equalTo(snp.leading)
            $0.trailing.equalTo(snp.trailing)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}
