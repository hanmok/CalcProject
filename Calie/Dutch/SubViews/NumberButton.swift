//
//  NumberButton.swift
//  Calie
//
//  Created by Mac mini on 2022/05/04.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit

class NumberButton: UIButton {
    public let wrapperString: String
    
    init(_ wrapperString: String, frame: CGRect = .zero) {
        self.wrapperString = wrapperString
        super.init(frame: frame)
        self.setTitle(wrapperString, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
