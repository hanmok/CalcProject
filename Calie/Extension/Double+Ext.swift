//
//  Double+Ext.swift
//  Calie
//
//  Created by Mac mini on 2022/07/24.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation


extension Double {
    
    public func applyDecimalFormatWithCurrency() -> String {

        let initialStr = self.applyCustomNumberFormatter()
        
        
        return UserDefaultSetup.appendProperUnit(to: initialStr)
        
    }
    
    static var maxNum: Double {
        return Double(1_000_000_000_000_000)
    }
    
    func applyCustomNumberFormatter() -> String {
        
        if self > -0.001 && self < 0.001 {
            return "0"
        }
        
        var ret = ""
        
        var isInt = false
        
        if Double(Int(self)) == self {
            isInt = true
        }
    
        // FIXME: - 에 대한 고려가 안됨.
        var currentNumber = self
//        currentNumber = ma
        var isMinus = currentNumber < 0
        currentNumber = max(currentNumber, -currentNumber)
        
        
        if currentNumber < 1000 {
            if isInt {
//                var ret = String(currentNumber)
                ret = String(currentNumber)
                ret.removeLast(2) // remove .0
//                return ret
            } else {
//                return String(currentNumber)
                ret = String(currentNumber)
            }
        } else {
            
            var str = "\(currentNumber)"
            
            var commaStack = 0
            for _ in 0 ..< str.count {
                
                if commaStack == 3 {
                    ret = "," + ret
                    commaStack = 0
                }
                
                if let last = str.last {
                    let lastStr = String(last)
                    
                    ret = String(str.removeLast()) + ret
                    
                    if lastStr.contains(".") {
                        commaStack = 0
                    } else {
                        commaStack += 1
                    }
                }
            }
            
            if isInt {
                ret.removeLast(2)
//                return ret
            } else {
//                return ret
            }
        }
        
        if isMinus {
            return "-" + ret
        } else {
            return ret
        }
        
    }
    
    static let minimumValue = 0.009
    
    static func cutTails(_ input: Double) -> Double {
        var num = input
        num = (num * 100).rounded() / 100
        return num
    }
}
