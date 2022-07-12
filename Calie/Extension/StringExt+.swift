//
//  StringExt+.swift
//  Calie
//
//  Created by 이한목 on 2022/05/08.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation



extension String {
    /// apply Formatter to self, add comma to number
    public mutating func applyNumberFormatter() {
        
        if self.hasSuffix(".0") {
            self.removeLast()
            self.removeLast()
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        self = self.replacingOccurrences(of: ",", with: "")
        
        guard self != "" else { return }
        
        guard let int = Int(self),
              let result = numberFormatter.string(for: int) else {
            print("self: \(self)")
            fatalError("fail to convert str to Int! ", file: #function, line: #line)
        }
       
        self = result
    }
    /// used to convert formatted String To Double
    public func convertStrToDouble() -> Double {
        var str = self
        guard str != "" else { return 0 }
        str = str.replacingOccurrences(of: ",", with: "")
        guard let double = Double(str) else {
            fatalError("fail to convert Str to Double", file: #file, line: #line)
        }
        return double
    }
}



extension String {
    
    struct EntityName {
        static let Person = "Person"
        static let Gathering = "Gathering"
        static let PersonDetail = "PersonDetail"
        static let Group = "Group"
        static let DutchUnit = "DutchUnit"
    }
    
    
    struct DutchUnitKeys {
        static let personDetails = "personDetails_"
        static let placeName = "placeName_"
        static let spentAmount = "spentAmount"
        static let date = "date_"
        static let id = "id_"
    }
    
    struct GatheringKeys {
        static let totalCost = "totalCost"
        static let title = "title_"
        static let isOnWorking = "isOnWorking"
        static let createdAt = "createdAt_"
        static let updatedAt = "updatedAt_"
        static let dutchUnits = "dutchUnits_"
        static let people = "people_"
    }
    
    struct GroupKeys {
        static let title = "title_"
        static let people = "people_"
    }
    
    struct PersonKeys {
        static let name = "name_"
        static let order = "order_"
    }
    
    struct PersonDetailKeys {
        static let spentAmount = "spentAmount"
        static let isAttended = "isAttended"
        static let person = "person"
    }
}
