//
//  DutchpayManager.swift
//  Calie
//
//  Created by Mac mini on 2022/07/12.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import CoreData


struct DutchManager {
    let mainContext: NSManagedObjectContext

    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.mainContext = mainContext
    }
}



// MARK:  - Gathering Helpers
extension DutchManager {
    
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

    func fetchGatherings() -> [Gathering] {
        
        let fetchRequest = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
        // inverse order
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: .GatheringKeys.createdAt, ascending: false)]
        
        do {
            let gatherings = try mainContext.fetch(fetchRequest)
            return gatherings
        } catch let error {
            fatalError("fail to get gatherings, \(error.localizedDescription)")
        }

    }

    
    func fetchGathering(_ option: GatheringFetchingEnum) -> Gathering? {
        let fetchRequest = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
        fetchRequest.fetchLimit = 1
        
        switch option {
        case .latest:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: .GatheringKeys.createdAt, ascending: false)]
            
        case .title(let name):
            fetchRequest.predicate = NSPredicate(format: "\(String.GatheringKeys.title) == %@", name)
        }
        
        do {
            let gatherings = try mainContext.fetch(fetchRequest)
            return gatherings.first
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    
    func update() {
        mainContext.saveCoreData()
    }

    func deleteGathering(gathering: Gathering) {
        mainContext.delete(gathering)

        mainContext.saveCoreData()
    }
}

extension DutchManager {
    
    enum GatheringFetchingEnum {
        case latest
        case title(String)
    }
}


// MARK: - DutchUnit Helper
extension DutchManager {
    func createDutchUnit(spentTo placeName: String,
                         spentAmount: Double,
                         personDetails: [PersonDetail],
                         spentDate: Date = Date()) -> DutchUnit {
        
        let dutchUnit = DutchUnit(context: mainContext)
        
        dutchUnit.placeName = placeName
        dutchUnit.spentAmount = spentAmount
        dutchUnit.personDetails = Set(personDetails)
        dutchUnit.spentDate = spentDate
        
        dutchUnit.id = UUID()
        
        do {
            try mainContext.save()
            return dutchUnit
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    @discardableResult
    func updateDutchUnit(target dutchUnit: DutchUnit,
                         spentTo placeName: String,
                         spentAmount: Double,
                         personDetails: [PersonDetail],
                         spentDate: Date = Date()) -> DutchUnit {
        
        dutchUnit.placeName = placeName
        dutchUnit.spentAmount = spentAmount
        dutchUnit.personDetails = Set(personDetails)
        dutchUnit.spentDate = spentDate
        
        do {
            try mainContext.save()
            return dutchUnit
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}


// MARK: -PersonDetail
extension DutchManager {
    
    @discardableResult
    func createPersonDetail(person: Person,
                     isAttended: Bool = true,
                     spentAmount: Double = 0) -> PersonDetail {
        
        let personDetail = PersonDetail(context: mainContext)
        
        personDetail.person = person
        personDetail.isAttended = isAttended
        personDetail.spentAmount = spentAmount
        
        do {
            try mainContext.save()
            return personDetail
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}


extension DutchManager {
    @discardableResult
     func createPerson(name: String, gathering: Gathering? = nil ) -> Person {
        
         let person = Person(context: mainContext)
         
         person.name = name

         if let gathering = gathering {
             person.order = Int64(gathering.people.count + 1)
         }
         
         do {
             try mainContext.save()
             return person
         } catch let error {
             fatalError(error.localizedDescription)
         }
     }
    
    func changePersonOrder(of first: Person, with second: Person) {
        let tempOrder = first.order
        
        first.order = second.order
        second.order = tempOrder
        mainContext.saveCoreData()
    }
}
