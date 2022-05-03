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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//extension String {
//    /// apply Formatter to self
//    public mutating func applyNumberFormatter() {
//        guard let intNum = Int(self) else {return} // working bad
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//
//        if let result = numberFormatter.string(for: intNum) {
//            self = result
//        }
//    }
//}


extension String {
    /// apply Formatter to self
    public mutating func applyNumberFormatter() {
        
        if self.hasSuffix(".0") {
            self.removeLast()
            self.removeLast()
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
    
        guard let intNum = Int(self),
              let result = numberFormatter.string(for: intNum) else { return }
        
        self = result
    }
}
