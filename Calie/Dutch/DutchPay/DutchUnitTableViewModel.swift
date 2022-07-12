//
//  DutchUnitViewModel.swift
//  Calie
//
//  Created by Mac mini on 2022/05/02.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit


//struct DutchUnitTableViewModel {
//    public var dutchUnit: DutchUnit2
//
//    var placeName: String { return dutchUnit.placeName}
//    var spentAmount: String {
//        // TODO: Apply Global Currency
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//        if let intValue = dutchUnit.spentAmount.convertToInt() {
//            return numberFormatter.string(from: NSNumber(value: intValue))! + " 원"
//        } else {
//            return numberFormatter.string(from: NSNumber(value: dutchUnit.spentAmount))! + " 원"
//        }
//    }
//
//    var peopleList: String {
//        return dutchUnit.personDetails.map { $0.person.name}.joined(separator: ", ")
//    }
//}



struct CoreDutchUnitViewModel {
    public var dutchUnit: DutchUnit
    
    var placeName: String { return dutchUnit.placeName}
    
    var date: String { return dutchUnit.spentDate.getFormattedDate(format: "yyyy.MM.dd HH:mm") }
    
    var spentAmount: String {
        // TODO: Apply Global Currency
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if let intValue = dutchUnit.spentAmount.convertToInt() {
            return convertIntoKoreanPrice(number: Double(intValue))
        } else {
            return convertIntoKoreanPrice(number: dutchUnit.spentAmount)
        }
    }
    

    var peopleList: String {
        return dutchUnit.personDetails.sorted().map { $0.person!.name}.joined(separator: ", ")
    }
    
    private func convertIntoKoreanPrice(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.string(from: NSNumber(value:number))
        return numberFormatter.string(from: NSNumber(value: number))! + " 원"
    }
}

public func convertIntoKoreanPrice(number: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.string(from: NSNumber(value:number))
    return numberFormatter.string(from: NSNumber(value: number))! + " 원"
}
