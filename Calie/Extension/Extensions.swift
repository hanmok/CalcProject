//
//  Extensions.swift
//  Caliy
//
//  Created by Mac mini on 2021/07/21.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}


public extension String {
    func firstIndexInt(of char: Character) -> Int? {
        return firstIndex(of: char)?.utf16Offset(in: self)
    }
    
    func lastIndexInt(of char : Character) -> Int? {
        return lastIndex(of: char)?.utf16Offset(in: self)
    }
}

// String -> Double

extension Double {
    public func convertToInt() -> Int? {
        if self == Double(Int(self)) {
            return Int(self)
        }
        return nil
    }
}



extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

extension FloatingPoint{}

extension Double {
    func decimalCount() -> Int {
        if self == Double(Int(self)) {
            return 0
        }
        
        let integerString = String(Int(self))
        let doubleString = String(Double(self))
        let decimalCount = doubleString.count - integerString.count - 1
        
        return decimalCount
    }
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    convenience init(leftPadding: CGFloat = 5, rightPadding: CGFloat = 5, withPadding: Bool) {
        self.init(frame: .zero)

        if withPadding {
        setLeftPaddingPoints(leftPadding)
        setRightPaddingPoints(rightPadding)
        }
    }
}
