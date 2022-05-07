//
//  DutchUnitViewModel.swift
//  Calie
//
//  Created by Mac mini on 2022/05/02.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit


struct DutchUnitViewModel {
    public var dutchUnit: DutchUnit2
    
    var placeName: String { return dutchUnit.placeName}
    var spentAmount: String {
        // TODO: Apply Global Currency
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let intValue = dutchUnit.spentAmount.convertToInt() {
//            return String(intValue) + " 원"
            return numberFormatter.string(from: NSNumber(value: intValue))! + " 원"
        } else {
            return numberFormatter.string(from: NSNumber(value: dutchUnit.spentAmount))! + " 원"
        }
    }
    
    var peopleList: String {
        return dutchUnit.personDetails.map { $0.person.name}.joined(separator: ", ")
    }
}
