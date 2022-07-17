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
        }
    }

    var totalCost: Double {
        return getTotalPrice(dutchUnits: self.dutchUnits)
    }
    
    var totalCostStr: String {
        let cost = getTotalPrice(dutchUnits: self.dutchUnits)
        return convertIntoKoreanPrice(number: cost)
    }

    var people: Set<Person> {
        get {
            self.people_ as? Set<Person> ?? []
        }
        set {
            self.people_ = newValue as NSSet
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

