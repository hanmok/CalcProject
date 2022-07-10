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
            return self.name_ ?? "가나다라마바사아자차카타파하"
        }
        set {
            self.name_ = newValue
        }
    }
    
    public var order: Int64 {
        get {
            return self.order_
        }
        set {
            self.order_ = newValue
        }
    }
    
    
    
}

extension Person {
    @discardableResult
    static func save(name: String, gathering: Gathering? = nil ) -> Person {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: String.EntityName.Person, in: managedContext) else { fatalError("failed to get entity from subject ")}
        
        guard let person = NSManagedObject(entity: entity, insertInto: managedContext) as? Person else {
            fatalError("failed to case to Subject during saving ")
        }
        var order: Int64 = 100
        if let gathering = gathering {
            order = Int64(gathering.people.count)
        }
        
        person.setValue(name, forKey: .Person.name)
        person.setValue(order, forKey: .Person.order)
        
        managedContext.saveCoreData()
        return person
    }
}


extension Person {

    static func changeOrder(of first: Person, with second: Person ) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let firstOrder = first.order
        
        first.setValue(second.order, forKey: .Person.order)
        second.setValue(firstOrder, forKey: .Person.order)
        
        managedContext.saveCoreData()
    }
}

extension Person: Comparable {
    public static func <(lhs: Person, rhs: Person) -> Bool {
        return lhs.order < rhs.order
    }
}
