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
}

extension Gathering {
    @discardableResult
    static func save(title: String, people: [Person]) -> Gathering{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Gathering", in: managedContext) else { fatalError("failed to get entity from subject ")}
        guard let gathering = NSManagedObject(entity: entity, insertInto: managedContext) as? Gathering else {
            fatalError("failed to case to Subject during saving ")
        }
        let convertedPeople = Array<Any>.convertToSet(items: people)
        gathering.setValue(title, forKey: "title")
        gathering.setValue(convertedPeople, forKey: "people")
        
        managedContext.saveCoreData()
        return gathering
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
