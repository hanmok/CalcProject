//
//  IntExt+.swift
//  Calie
//
//  Created by 이한목 on 2022/05/08.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation


extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
