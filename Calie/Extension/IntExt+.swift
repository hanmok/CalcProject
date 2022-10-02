//
//  IntExt+.swift
//  Calie
//
//  Created by 이한목 on 2022/05/08.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

extension String {

    func convertNumStrToDouble() -> Double {
        print("input : \(self)")
        if self == "" { return 0 }
        let num = self.replacingOccurrences(of: ",", with: "")
        print("replaced num: \(num)")
        print("converted result: \(Double(num))")
        return Double(num)!
    }
}
