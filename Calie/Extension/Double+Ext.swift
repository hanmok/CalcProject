//
//  Double+Ext.swift
//  Calie
//
//  Created by Mac mini on 2022/07/24.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

extension Double {
//    func convertIntoStr() -> String {
//        //        return String(self)
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//
//
//        if let intValue = self.convertToInt() {
//            return String(intValue)
//        } else {
//            return String(self)
//        }
//    }
}

extension Double {
    
    public func applyDecimalFormatWithCurrency() -> String {
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//
//
//        print("currency flag 3, formatted Str: \(numberFormatter.string(from: NSNumber(value:self)))")
//        return numberFormatter.string(from: NSNumber(value: self))! + " 원"

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

//        numberFormatter.decimalSeparator = "-"

        var initialStr = numberFormatter.string(from: self as NSNumber)!
//        initialStr = initialStr.replacingOccurrences(of: ".", with: ",")
//        initialStr = initialStr.replacingOccurrences(of: "-", with: ".")
        

        //        이게 되는구나?!
        if ASD.currencyShort.localized == "$" {
            return ASD.currencyShort.localized + initialStr
        } else {
            return initialStr + ASD.currencyShort.localized
        }
//        return initialStr + " " + ASD.currency.localized
    }
    
    public func applyDecimalFormat() -> String {
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//
//
//        print("currency flag 3, formatted Str: \(numberFormatter.string(from: NSNumber(value:self)))")
//        return numberFormatter.string(from: NSNumber(value: self))! + " 원"

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

//        numberFormatter.decimalSeparator = "-"

        var initialStr = numberFormatter.string(from: self as NSNumber)!
//        initialStr = initialStr.replacingOccurrences(of: ".", with: ",")
//        initialStr = initialStr.replacingOccurrences(of: "-", with: ".")
        
        return initialStr
    }
    
//    func convertIntoCurrencyUnit(isKorean: Bool, isUsingFloatingPoint: Bool = false) -> String {
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//        numberFormatter.string(from: NSNumber(value:self))
//        var result = numberFormatter.string(from: NSNumber(value: self))!
//
//        if result == "-0" { return isKorean ? "0원" : "$0"}
//
//        if isUsingFloatingPoint == false {
//            if result.contains(".0") {
//                result.removeLast()
//                result.removeLast()
//            }
//        }
////        return result + isKorean ? "원" :
//        if isKorean {
//            return result + "원"
//        } else {
//            return "$" + result
//        }
//    }
    
    func getStrWithoutDots() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.string(from: NSNumber(value:self))
        var result = numberFormatter.string(from: NSNumber(value: self))!
         if result == "-0" { return "0"}
        
            if result.contains(".0") {
                result.removeLast()
                result.removeLast()
            }

        return result
    }
    
    static let minimumValue = 0.009
}
