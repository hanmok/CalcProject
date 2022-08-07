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
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            if let intValue = amt.convertToInt() {
                return convertIntoKoreanPrice(number: Double(intValue))
            } else {
                return convertIntoKoreanPrice(number: amt)
            }
        }()
    }
    
    private func convertIntoKoreanPrice(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.string(from: NSNumber(value:number))
        return numberFormatter.string(from: NSNumber(value: number))! + " 원"
    }
    
    private func convertPeopleIntoStr(peopleDetails: Set<PersonDetail>) -> String {
        return peopleDetails.sorted().map { $0.person!.name}.joined(separator: ", ")
    }
    
    private func convertDateIntoStr(date: Date) -> String {
        return date.getFormattedDate(format: "yyyy.MM.dd HH:mm")
    }
}
