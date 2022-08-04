//
//  Double+Ext.swift
//  Calie
//
//  Created by Mac mini on 2022/07/24.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

extension Double {
    func convertIntoStr() -> String {
        //        return String(self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
    
        if let intValue = self.convertToInt() {
            return String(intValue)
        } else {
            return String(self)
        }
        
    }
}

extension Double {
    private func convertIntoKoreanPrice(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.string(from: NSNumber(value:number))
        return numberFormatter.string(from: NSNumber(value: number))! + " 원"
    }
}
