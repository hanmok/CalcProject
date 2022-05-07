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
        
//        self.backgroundColor = .magenta
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

        self = self.replacingOccurrences(of: ",", with: "")
        
        guard self != "" else { return }
        
        guard let int = Int(self),
              let result = numberFormatter.string(for: int) else {
            print("self: \(self)")
            fatalError("fail to convert str to Int! ", file: #function, line: #line)
        }
       
        self = result
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
