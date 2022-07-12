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
}



// MARK:  - Gathering Helpers

extension DutchpayManager {
    
    @discardableResult
    func createGathering(title: String) -> Gathering? {
        let gathering = Gathering(context: mainContext)

        gathering.title = title

        do {
            try mainContext.save()
            return gathering
        } catch let error {
            print("Failed to create: \(error)")
        }
        return nil
    }
    
    @discardableResult
    func createGathering(title: String, people: [Person]) -> Gathering {
        let gathering = Gathering(context: mainContext)
        
        gathering.people = Set(people)
        gathering.isOnWorking = true
        gathering.title = title
        
        do {
            try mainContext.save()
            return gathering
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    func fetchGatherings() -> [Gathering]? {
        
        let fetchRequest = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
        // inverse order
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: .GatheringKeys.createdAt, ascending: false)]
        do {
            let gatherings = try mainContext.fetch(fetchRequest)
            return gatherings
        } catch let error {
            print("Failed to fetch companies: \(error)")
        }
        return nil
    }

    // 이거 두개 묶을 수 있을 것 같음 .
//    func fetchGathering(withTitle title: String) -> Gathering? {
//
//        let fetchRequest = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
//        fetchRequest.fetchLimit = 1
//        fetchRequest.predicate = NSPredicate(format: "\(String.GatheringKeys.title) == %@", title)
//
//        do {
//            let gatherings = try mainContext.fetch(fetchRequest)
//            return gatherings.first
//        } catch let error {
//            print("Failed to fetch: \(error)")
//        }
//
//        return nil
//    }
    
//    func fetchLatestGathering() -> Gathering? {
//    self.fetchGathering()
//    self.fetchGathering(.title(<#T##String#>))
    
    func fetchGathering(_ option: GatheringFetchingEnum) -> Gathering? {
        let fetchRequest = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
        fetchRequest.fetchLimit = 1
        
        switch option {
        case .latest:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: .GatheringKeys.createdAt, ascending: false)]
            
        case .title(let name):
            fetchRequest.predicate = NSPredicate(format: "\(String.GatheringKeys.title) == %@", name)
        }
        
//        let fetchRequest = NSFetchRequest<Gathering>(entityName: .EntityName.Gathering)
//        fetchRequest.fetchLimit = 1
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: .GatheringKeys.createdAt, ascending: false)]
        
        do {
            let gatherings = try mainContext.fetch(fetchRequest)
            return gatherings.first
        } catch let error {
            fatalError(error.localizedDescription)
        }
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
    
    private func getTotalPrice(dutchUnits: Set<DutchUnit>) -> Double{
        var price = 0.0
        for eachUnit in dutchUnits {
            price += eachUnit.spentAmount
        }
        return price
    }
    
    enum GatheringFetchingEnum {
//        case all
        case latest
        case title(String)
    }
}
