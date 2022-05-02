//
//  PriceTextField.swift
//  Calie
//
//  Created by Mac mini on 2022/05/03.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit


class PriceTextField: UITextField {
    
    
    private let currencyLabel = UILabel().then { $0.text = "원"}
    private let currencyTF = UITextField().then {
        $0.placeholder = "0"
        $0.textAlignment = .right
//        $0.placeholdercol
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    init(placeHolder: String, _ frame: CGRect = .zero) {
        self.init()
        currencyTF.placeholder = placeholder
    }
    
    
    private func setupLayout() {
        addSubview(currencyLabel)
        addSubview(currencyTF)
        
        currencyLabel.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        
        currencyTF.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(currencyLabel.snp.leading).offset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

