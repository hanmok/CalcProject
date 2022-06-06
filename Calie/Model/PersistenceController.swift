//
//  PersistenceManager.swift
//  Learning Core Data
//
//  Created by Kyle Lee on 7/15/18.
//  Copyright © 2018 Kyle Lee. All rights reserved.
//

import Foundation
import CoreData

final class PersistenceController {
    
    private init() {}
    static let shared = PersistenceController()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Learning_Core_Data")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("saved successfully")
                
                
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        
        let entityName = String(describing: objectType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            return fetchedObjects ?? [T]()
            
        } catch {
            print(error)
            return [T]()
        }
        
    }
    
    
    
}

