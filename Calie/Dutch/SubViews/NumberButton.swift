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
        self.layer.borderColor = ColorList().bgColorForExtrasLM.cgColor
        self.layer.borderWidth = 0.3
    }
    
    init(tripleZeroOrDot: Bool, frame: CGRect = .zero) {
        let wrapperString: String = ASD.currencyShort.localized == "원" ? "000" : "."
        self.wrapperString = wrapperString
        super.init(frame: frame)
        self.setTitle(wrapperString, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .black
        self.layer.borderColor = ColorList().bgColorForExtrasLM.cgColor
        self.layer.borderWidth = 0.3
    }
    
//    init(_ wrapperString: String, frame: CGRect = .zero, hasBoundary: Bool = false) {
//        self.wrapperString = wrapperString
//        super.init(frame: frame)
//        self.setTitle(wrapperString, for: .normal)
//        self.setTitleColor(.white, for: .normal)
//        self.backgroundColor = .black
//        if hasBoundary {
//        self.layer.borderColor = ColorList().bgColorForExtrasLM.cgColor
//        self.layer.borderWidth = 0.3
//        }
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
