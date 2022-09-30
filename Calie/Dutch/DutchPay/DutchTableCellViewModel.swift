//
//  DutchTableCellViewModel.swift
//  Calie
//
//  Created by 핏투비 on 2022/08/03.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

struct DutchTableCellViewModel {
    
    var dutchUnit: DutchUnit
    
    var placeName: String { return dutchUnit.placeName }
    
    var spentAmount: String { convertSpentAmount(amt: dutchUnit.spentAmount)}
    
    var peopleNameList: String { return convertPeopleIntoStr(peopleDetails: dutchUnit.personDetails)}
    
    var date: String {
        return convertDateIntoStr(date: dutchUnit.spentDate)
    }
    
}


extension DutchTableCellViewModel {
    private func convertSpentAmount(amt: Double) -> String {
        return {
            print("currency flag 1, input amt: \(amt)")
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            if let intValue = amt.convertToInt() {
                let double = Double(intValue)
                print("currency flag 2a, double: \(double)")
//                return double.convertIntoKoreanPrice()
//                return numberFormatter.string(from: double as NSNumber)!
                return double.applyDecimalFormatWithCurrency()
//                return convertIntoKoreanPrice(number: Double(intValue))
            } else {
                print("currency flag 2b, double: \(amt)")
//                return convertIntoKoreanPrice(number: amt)
                return amt.applyDecimalFormatWithCurrency()
            }
        }()
    }
    
    
    private func convertPeopleIntoStr(peopleDetails: Set<PersonDetail>) -> String {
        // print attended people only
        let attendedPeople = peopleDetails.sorted().filter { $0.isAttended == true }
        return attendedPeople.map { $0.person!.name}.joined(separator: ", ")
    }
    
    private func convertDateIntoStr(date: Date) -> String {
        return date.getFormattedDate(format: "yyyy.MM.dd HH:mm")
    }
}
