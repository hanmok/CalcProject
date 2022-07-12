//
//  CoreDataStack.swift
//  Calie
//
//  Created by Mac mini on 2022/07/12.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext

//    private init() {
    public init() {
        persistentContainer = NSPersistentContainer(name: "Dutch")
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = NSSQLiteStoreType

        persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError("was unable to load store \(error!)")
            }
        }

        mainContext = persistentContainer.viewContext

        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.parent = self.mainContext
    }
}
