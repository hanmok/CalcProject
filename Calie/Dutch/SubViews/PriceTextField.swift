//
//  PriceTextField.swift
//  Calie
//
//  Created by Mac mini on 2022/05/03.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit


//protocol PriceTextFieldDelegate: UITextFieldDelegate {
//     func textFieldDidBeginEditing(_ textField: PriceTextField)
//     func textFieldShouldBeginEditing(_ textField: PriceTextField) -> Bool
//}

extension UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: PriceTextField) {
        print("tag : \(textField.tag)")
    }
}


class PriceTextField: UITextField {
    public var isTotalPrice = false
    let id = UUID()
    
    private let currencyLabel = UILabel().then { $0.text = "원"}
    
    override weak var delegate: UITextFieldDelegate? {
        didSet{
            print("delegate has been assigned!")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setLeftPaddingPoints(5)
        setRightPaddingPoints(5)
    }
    
    init(placeHolder: String, _ frame: CGRect = .zero) {
        self.init()
        self.textAlignment = .right
    }
    
    private func setupLayout() {
        currencyLabel.frame.size = CGSize(width: 30, height: 30)
        rightView = currencyLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ZombieTextField: UITextField {
    
}
