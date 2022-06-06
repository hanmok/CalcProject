//
//  Person+Helper.swift
//  Calie
//
//  Created by 핏투비 on 2022/05/31.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import CoreData

extension Person {
//    convenience init(name: String, index: Int64 = 0, context: NSManagedObjectContext) {
//        self.init(context: context)
////        self.person = person
////        self.isAttended = isAttended
////        self.spentAmount = spentAmount
//        self.name = name
//        self.index = index
//        context.saveCoreData()
//    }
    
    var name: String {
        get {
            return self.name_ ?? ""
        }
        set {
            self.name_ = newValue
        }
    }
    
}

extension Person {
    @discardableResult
    static func save(name: String, index: Int64 = 0) -> Person {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: String.EntityName.Person, in: managedContext) else { fatalError("failed to get entity from subject ")}
        
        guard let person = NSManagedObject(entity: entity, insertInto: managedContext) as? Person else {
            fatalError("failed to case to Subject during saving ")
        }
        
        person.setValue(name, forKey: .Person.name)
        person.setValue(index, forKey: .Person.index)
        
        managedContext.saveCoreData()
        return person
//        do {
//            try managedContext.save()
//            print("savedData: \(person)")
//        } catch let error as NSError {
//            print("Could not save, \(error), \(error.userInfo)")
//        }
        
    }
}

//extension Person: Hashable {}

//struct Person2 {
//    let name: String
//
//    init(_ name: String) {
//        self.name = name
//    }
//
//    init(name: String) {
//        self.name = name
//    }
//}
