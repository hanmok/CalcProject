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
//            self.managedObjectContext?.saveCoreData()
        }
    }

    var totalCost: String {
        let cost = getTotalPrice(dutchUnits: self.dutchUnits)
        return convertIntoKoreanPrice(number: cost)
    }

    var people: Set<Person> {
        get {
            self.people_ as? Set<Person> ?? []
        }
        set {
            self.people_ = newValue as NSSet
//            self.managedObjectContext?.saveCoreData()
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
//            self.managedObjectContext?.saveCoreData()
        }
    }

    var updatedAt: Date {
        get {
            self.updatedAt_ ?? Date()
        }
        set {
            self.updatedAt_ = newValue
//            self.managedObjectContext?.saveCoreData()
        }
    }

    var title: String {
        get {
            self.title_ ?? ""
        }
        set {
            self.title_ = newValue
            print("title has changed to \(newValue)")
//            self.managedObjectContext?.saveCoreData()
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

//    @discardableResult
//    static func save(title: String, people: [Person]) -> Gathering{
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//        guard let entity = NSEntityDescription.entity(forEntityName: .EntityName.Gathering, in: managedContext) else { fatalError("failed to get entity from entity ")}
//        guard let gathering = NSManagedObject(entity: entity, insertInto: managedContext) as? Gathering else {
//            fatalError("failed to case to Subject during saving ")
//        }
//        let convertedPeople = Array<Any>.convertToSet(items: people)
//
//        gathering.setValue(Date(), forKey: .Gathering.createdAt)
//        gathering.setValue(title, forKey: .Gathering.title)
//        gathering.setValue(convertedPeople, forKey: .Gathering.people)
//        gathering.setValue(true, forKey: .Gathering.isOnWorking)
//
//        managedContext.saveCoreData()
//
//
//        return gathering
//    }
}

extension Gathering {
    static func fetch(_ predicate: NSPredicate)-> NSFetchRequest<Gathering> {
        let request = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
//        request.sortDescriptors = [NSSortDescriptor(key: FolderProperties.order, ascending: true)]
        request.sortDescriptors = [NSSortDescriptor(key: String.GatheringKeys.createdAt, ascending: true)]
        // temp
//        request.sortDescriptors = [NSSortDescriptor(key: FolderProperties.title, ascending: true)]
        request.predicate = predicate
        return request
    }

//    static func fetchLatest() -> Gathering? {
//
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let req = Gathering.fetch(.all)
//        if let gatherings = try? managedContext.fetch(req) {
//            if gatherings.count != 0 {
//                return gatherings.sorted{$0.updatedAt < $1.updatedAt }.last!
//            } else {
//                return nil }
//        }
//        fatalError("failed to get gathering ")
//    }

    static func fetchAll() -> [Gathering] {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        let managedContext = appDelegate.persistentContainer.viewContext

        let req = Gathering.fetch(.all)

        if let gatherings = try? managedContext.fetch(req) {
            return gatherings.sorted{$0.createdAt < $1.createdAt }
        } else {
//            fatalError(<#T##() -> String#>, file: <#T##StaticString#>, line: <#T##UInt#>)
        fatalError("hi")
        }

        fatalError("failed t o get gathering ")

    }
}

extension NSManagedObjectContext {
    func saveCoreData() {
        print("saveCoreData called")
        do {
            try self.save()
        } catch {
            fatalError("failed to save gathering coreData")
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
