//
//  BasicCalculator.swift
//  Caliy
//
//  Created by Mac mini on 2021/09/27.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit

// 1. send process,
// 2. send result
// 2. send whether it need to show notification.

protocol BasicCalculatorDelegate {
    func sendProcess(_ calc: BasicCalculator, _ process: String)
    func sendResult(_ calc: BasicCalculator, _ result: String)
    func showAlert(_ calc: BasicCalculator, _ isShowing: Bool)
}

class BasicCalculator {
    
    
}
