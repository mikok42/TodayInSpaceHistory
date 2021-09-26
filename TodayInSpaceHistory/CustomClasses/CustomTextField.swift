//
//  CustomTextField.swift
//  diveCompanionSnapKit
//
//  Created by Mikołaj Linczewski on 27/05/2021.
//

import Foundation
import UIKit

class TextFieldWithPadding: UITextField {
    var textPadding: UIEdgeInsets
    
    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        textPadding = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        super.init(frame: CGRect())
    }
    
    init(insets: UIEdgeInsets) {
        self.textPadding = insets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
