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
        }
    }
    
    var people: Set<Person> {
        get {
            self.people_ as? Set<Person> ?? []
        }
        set {
            self.people_ = newValue as NSSet
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
}

extension Gathering {
    @discardableResult
    static func save(title: String, people: [Person]) -> Gathering{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: .EntityName.Gathering, in: managedContext) else { fatalError("failed to get entity from entity ")}
        guard let gathering = NSManagedObject(entity: entity, insertInto: managedContext) as? Gathering else {
            fatalError("failed to case to Subject during saving ")
        }
        let convertedPeople = Array<Any>.convertToSet(items: people)
        gathering.setValue(title, forKey: .Gathering.title)
        gathering.setValue(convertedPeople, forKey: .Gathering.people)
        gathering.setValue(true, forKey: .Gathering.isOnWorking)
        
        managedContext.saveCoreData()
        return gathering
    }
}

extension Gathering {
    static func fetch(_ predicate: NSPredicate)-> NSFetchRequest<Gathering> {
        let request = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
//        request.sortDescriptors = [NSSortDescriptor(key: FolderProperties.order, ascending: true)]
        request.sortDescriptors = [NSSortDescriptor(key: String.Gathering.createdAt, ascending: true)]
        // temp
//        request.sortDescriptors = [NSSortDescriptor(key: FolderProperties.title, ascending: true)]
        request.predicate = predicate
        return request
    }
    
    static func fetchLatest() -> Gathering? {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let req = Gathering.fetch(.all)
        if let gatherings = try? managedContext.fetch(req) {
            if gatherings.count != 0 {
                return gatherings.sorted{$0.createdAt < $1.createdAt }.last!
            } else {
                return nil }
        }
        fatalError("failed to get gathering ")
    }
    
    static func fetchAll() -> [Gathering] {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let req = Gathering.fetch(.all)
        if let gatherings = try? managedContext.fetch(req) {
            return gatherings.sorted{$0.createdAt < $1.createdAt }
        }
        
        fatalError("failed to get gathering ")
        
    }
}

extension NSManagedObjectContext {
    func saveCoreData() {
        do {
            try self.save()
        } catch {
            fatalError("failed to save gathering coreData")
        }
    }
}


//struct Gathering2 {
//    let title: String
//    var totalCost: Double
//    var dutchUnits: [DutchUnit2]
//    let people: [Person2]
//}


extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}
