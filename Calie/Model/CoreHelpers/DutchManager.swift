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
    
    func addMorePeople(addedPeople: [Person], currentGathering: Gathering) {
        if addedPeople.count == 0 { return }
        // name check needed each time person name input
        
        addedPeople.forEach { currentGathering.people.update(with: $0)}
        print("numOfPeople: \(currentGathering.people.count)")
        update()
        
        if currentGathering.dutchUnits.count == 0 { return }
        
        var addedPersonDetails: [PersonDetail] = []
        
        // make PersonDetails for added people
        for eachPerson in addedPeople {
            let newPersonDetail = createPersonDetail(person: eachPerson, isAttended: false, spentAmount: 0)
            addedPersonDetails.append(newPersonDetail)
        }
        
        // add PersonDetails to each of dutchUnits
        for eachUnit in currentGathering.dutchUnits {
            for eachDetail in addedPersonDetails {
                eachUnit.personDetails.update(with: eachDetail)
            }
        }
        

        update()
    }
    /// add personDetails to existing dutchUnits when dutchUnit added with new People & update gather's people
    func addDutchUnit(of dutchUnit: DutchUnit, to gathering: Gathering) {

        let peopleInUnit = Set(dutchUnit.personDetails.map { $0.person! })
        
        let originalPeople = gathering.people
        //  인원이 감소하는 경우는? 없음.
        let appendedPeople = peopleInUnit.subtracting(originalPeople)
        
        for eachPerson in appendedPeople {
            gathering.people.update(with: eachPerson)
            
            let appendedDetail = createPersonDetail(person: eachPerson, isAttended: false, spentAmount: 0)
            
            for eachDutchUnit in gathering.dutchUnits {
                eachDutchUnit.personDetails.update(with: appendedDetail)
            }
        }
        
        
        gathering.dutchUnits.update(with: dutchUnit)
        
        update()
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
        let totalPrice = personDetails.map { $0.spentAmount }.reduce(0) { partialResult, element in
            return partialResult + element
        }
        
        dutchUnit.isAmountEqual = totalPrice == spentAmount
        
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
        
        let totalPrice = personDetails.map { $0.spentAmount }.reduce(0) { partialResult, element in
            return partialResult + element
        }
        
        dutchUnit.isAmountEqual = totalPrice == spentAmount
        
        dutchUnit.spentDate = spentDate
        
        do {
            try mainContext.save()
            return dutchUnit
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    @discardableResult
    func updateDutchUnit(target originalUnit: DutchUnit, with updatedUnit: DutchUnit) -> DutchUnit {
        originalUnit.placeName = updatedUnit.placeName
        originalUnit.spentAmount = updatedUnit.spentAmount
        originalUnit.personDetails = updatedUnit.personDetails
        originalUnit.spentDate = updatedUnit.spentDate
        
        let totalPrice = originalUnit.personDetails.map { $0.spentAmount }.reduce(0) { partialResult, element in
            return partialResult + element
        }
        
        originalUnit.isAmountEqual = totalPrice == originalUnit.spentAmount
        
        do {
            try mainContext.save()
            return originalUnit
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


extension Person {
    public static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.name == rhs.name
    }
}
