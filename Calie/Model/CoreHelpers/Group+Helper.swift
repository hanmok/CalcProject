//
//  Group+Helper.swift
//  Calie
//
//  Created by 핏투비 on 2022/05/31.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import CoreData

extension Group {
    var people: Set<Person> {
        get {
            self.people_ as? Set<Person> ?? []
        }
        set {
            self.people_ = newValue as NSSet
        }
    }
}

extension Group {
    @discardableResult
    static func save(title: String, people: [Person]) -> Group{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: .EntityName.Group, in: managedContext) else { fatalError("failed to get entity from Group")}
        guard let group = NSManagedObject(entity: entity, insertInto: managedContext) as? Group else {
            fatalError("failed to case to Group during saving ")
        }
        let convertedPeople = Array<Any>.convertToSet(items: people)
        group.setValue(title, forKey: .Group.title)
        group.setValue(convertedPeople, forKey: .Group.people)
        
        managedContext.saveCoreData()
        return group
    }
}

extension Array {
    static func convertToSet<T:Hashable>(items: [T]) -> Set<T> {
        var result = Set<T>()
        for item in items {
            result.update(with: item)
        }
        return result
    }
}


//struct Group2 {
//    let people: [Person2]
//    let title: String
//}
