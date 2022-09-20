//
//  Gathering+Helper.swift
//  Calie
//
//  Created by Mac mini on 2022/06/02.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import CoreData

extension Gathering {

    var dutchUnits: Set<DutchUnit> {
        get {
            self.dutchUnits_ as? Set<DutchUnit> ?? []
        }
        set {
            self.dutchUnits_ = newValue as NSSet
            print("gathering dutchUnits set triggered")
            self.updatedAt = Date()
        }
    }

    var totalCost: Double {
        return getTotalPrice(dutchUnits: self.dutchUnits)
    }
    
    var totalCostStr: String {
        let cost = getTotalPrice(dutchUnits: self.dutchUnits)
        return convertIntoKoreanPrice(number: cost)
    }
    
    private func convertIntoKoreanPrice(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.string(from: NSNumber(value:number))
        return numberFormatter.string(from: NSNumber(value: number))! + " 원"
    }

    // Index 업데이트 할 것.
    var people: Set<Person> {
        
        get {
            self.people_ as? Set<Person> ?? []
        }
        set {
            self.people_ = newValue as NSSet
            let orderSet = Set(self.people.map { $0.order })
            
            if orderSet.count != self.people.count {
            // 중복 Order 발생.
                var sorted = self.people.sorted()
                for idx in 0 ..< sorted.count {
                    sorted[idx].order = Int64(idx)
                }
                self.people = Set(sorted)
            }
            self.updatedAt = Date()
        }
    }
    
//    public var id: String {
    public var id: UUID {
        get {
            if let validId = self.id_ {
                return validId
            } else {
//                let newId = UUID().uuidString
                let newId = UUID()
                self.id_ = newId
                return self.id_!
            }
        }
        set {
            self.id_ = newValue
        }
    }

    var sortedPeople: [Person] {
        get {
            self.people.sorted()
        }
    }

    var createdAt: Date {
        get {
            self.createdAt_ ?? Date()
        }
        set {
            self.createdAt_ = newValue
        }
    }

    var updatedAt: Date {
        get {
            self.updatedAt_ ?? Date()
        }
        set {
            self.updatedAt_ = newValue
        }
    }

    var title: String {
        get {
            self.title_ ?? ""
        }
        set {
            self.title_ = newValue
            print("title has changed to \(newValue)")
        }
    }
}

extension Gathering {

    private func getTotalPrice(dutchUnits: Set<DutchUnit>) -> Double{
        var price = 0.0
        for eachUnit in dutchUnits {
            price += eachUnit.spentAmount
        }
        return price
    }
}


extension Gathering {
    public static func < (lhs: Gathering, rhs: Gathering) -> Bool {
        return lhs.createdAt < rhs.createdAt
    }
}




extension NSManagedObjectContext {
    func saveCoreData(msg: String = "" ) {
        print("saveCoreData called")
        do {
            try self.save()
        } catch {
            fatalError("failed to save coreData \(msg)")
        }
    }
}



extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}



protocol RemovableProtocol: AnyObject {
    static func deleteSelf(_ target: NSManagedObject)
}

extension RemovableProtocol {
    static func deleteSelf(_ target: NSManagedObject) {

        if let context = target.managedObjectContext {
            context.delete(target)
            context.saveCoreData()
        }
    }
}

extension Gathering: RemovableProtocol {}

