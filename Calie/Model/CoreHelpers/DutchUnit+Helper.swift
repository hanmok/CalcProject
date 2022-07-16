//
//  DutchUnit+Helper.swift
//  Calie
//
//  Created by Mac mini on 2022/06/02.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import CoreData
extension DutchUnit {
    
    public var id: UUID {
        get {
            if let validId = self.id_ {
                return validId
            } else {
                self.id_ = UUID()
                return self.id_!
            }
        }
        set {
            self.id_ = UUID()
        }
    }
    
    public var isAmountEqual: Bool {
        get {
            return self.isAmountEqual_
        }
        set {
            self.isAmountEqual_ = newValue
        }
    }
    
    var personDetails: Set<PersonDetail> {
        get {
            self.personDetails_ as? Set<PersonDetail> ?? []
        }
        set {
            self.personDetails_ = newValue as NSSet
        }
    }
    
    var placeName: String {
        get {
            return self.placeName_ ?? "default place"
        }
        set {
            self.placeName_ = newValue
        }
    }
    
    var spentDate: Date {
        get {
            return self.spentDate_ ?? Date()
        }
        set {
            self.spentDate_ = newValue
        }
    }
}

extension DutchUnit: RemovableProtocol {}


extension DutchUnit: Comparable {
    public static func <(lhs: DutchUnit, rhs: DutchUnit) -> Bool {
        return lhs.spentDate < rhs.spentDate
    }
}

extension DutchUnit {
    
//    @discardableResult
//    static func save(spentTo placeName: String,
//                     spentAmount:Double,
//                     personDetails: [PersonDetail],
//                     spentDate: Date = Date()) -> DutchUnit {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        guard let entity = NSEntityDescription.entity(forEntityName: .EntityName.DutchUnit, in: managedContext) else { fatalError("failed to get entity from DutchUnit ")}
//
//        guard let dutchUnit = NSManagedObject(entity: entity, insertInto: managedContext) as? DutchUnit else {
//            fatalError("failed to case to Subject during saving ")
//        }
//
//        let convertedDetails = Array<Any>.convertToSet(items: personDetails)
//        dutchUnit.setValue(UUID(), forKey: .DutchUnitKeys.id)
//        dutchUnit.setValue(placeName, forKey: .DutchUnitKeys.placeName)
//        dutchUnit.setValue(spentAmount, forKey: .DutchUnitKeys.spentAmount)
//        dutchUnit.setValue(convertedDetails, forKey: .DutchUnitKeys.personDetails)
//        dutchUnit.setValue(spentDate, forKey: .DutchUnitKeys.date)
//
//        managedContext.saveCoreData()
//        return dutchUnit
//    }
    
//    static func update(spentTo placeName: String,
//                       spentAmount: Double,
//                       personDetails: [PersonDetail],
//                       spentDate: Date = Date(), from dutchUnit: DutchUnit) -> DutchUnit {
//
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
//
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let convertedDetails = Array<Any>.convertToSet(items: personDetails)
//
//        dutchUnit.setValue(placeName, forKey: .DutchUnitKeys.placeName)
//        dutchUnit.setValue(spentAmount, forKey: .DutchUnitKeys.spentAmount)
//
//        dutchUnit.setValue(convertedDetails, forKey: .DutchUnitKeys.personDetails)
//        dutchUnit.setValue(spentDate, forKey: .DutchUnitKeys.date)
//
//        managedContext.saveCoreData()
//
//        return dutchUnit
//    }
    
}


//struct DutchUnit2 {
//    var placeName: String
//    var spentAmount: Double
//    var date: Date = Date()
//    var personDetails: [PersonDetail2]
//}


