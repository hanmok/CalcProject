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
    
    var name: String {
        get {
//            return self.name_ ?? "default person"
            return self.name_ ?? "가나다라마바사아자차카타파하"
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
