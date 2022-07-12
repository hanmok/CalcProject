//
//  DutchpayManager.swift
//  Calie
//
//  Created by Mac mini on 2022/07/12.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import CoreData

// fetch 만 하면 지랄이군.. DK.. 설마...
struct DutchpayManager {
    let mainContext: NSManagedObjectContext

    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.mainContext = mainContext
    }

    @discardableResult
    func createGathering(title: String) -> Gathering? {
        let gathering = Gathering(context: mainContext)

        gathering.title = title
//        gathering.setValue(title, forKey: .Gathering.title)

        do {
            try mainContext.save()
            return gathering
        } catch let error {
            print("Failed to create: \(error)")
        }
        return nil
    }

    func fetchGatherings() -> [Gathering]? {
        return nil
//        let fetchRequest = NSFetchRequest<Gathering>(entityName: "Gathering")
        let fetchRequest = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)

        do {
            let gatherings = try mainContext.fetch(fetchRequest)
            return gatherings
        } catch let error {
            print("Failed to fetch companies: \(error)")
        }
        return nil
    }

    func fetchGathering(withTitle title: String) -> Gathering? {
        return nil
//        let fetchRequest = NSFetchRequest<Gathering>(entityName: "Gathering")
        let fetchRequest = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        do {
            let gatherings = try mainContext.fetch(fetchRequest)
            return gatherings.first
        } catch let error {
            print("Failed to fetch: \(error)")
        }

        return nil
    }

    func updateGathering(gathering: Gathering) {
        do {
            try mainContext.save()
        }catch let error {
            print("Failed to update: \(error)")
        }
    }

    func deleteGathering(gathering: Gathering) {
        mainContext.delete(gathering)

        do {
            try mainContext.save()
        } catch let error {
            print("Failed to delete: \(error)")
        }
    }
}
