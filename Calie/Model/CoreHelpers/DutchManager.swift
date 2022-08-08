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
        gathering.createdAt = Date()
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
        gathering.createdAt = Date()
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

        update()
    }
    
    
    /// dutchUnit added with new People -> add personDetails to existing dutchUnits  & update gathering's people
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
    
// 모든 DutchUnit 의 SpentAmount 와 PersonDetails 의 합이 같다고 가정.
    func getFirstOverallResult(using gathering: Gathering) -> [Double] {
        

//        [0 0 0 0 0 .. ]
        var result = Array(repeating: 0.0, count: gathering.people.count)
        print("\ngetOverallResult, numOfElements:\(result.count)")

        // 인원 체크 굳이 안해도 ..;;
//        if eachResult.count != result.count { fatalError() }
        
        for eachUnit in gathering.dutchUnits {
            let eachResult = getUnitResult(using: eachUnit)

//            result += getUnitResult(using: eachUnit)
            for (idx, element) in eachResult.enumerated() {
                result[idx] += element
            }
        }
        
        print("overall Result: \(result)")
        return result
    }
    
    // need random Generator.. TT....

    
    
    // 이거부터 그렇게 쉽지 않네.. 한명이 낸다고 가정하는 것부터 잘못됨..
    // 전체 인원가지고 하는게 편할수도..
    func getUnitResult(using dutchUnit: DutchUnit) -> [Double] {
        // 150
        var totalAmount: Double
        
        if dutchUnit.isAmountEqual {
            totalAmount = dutchUnit.spentAmount
        } else {
            totalAmount = dutchUnit.isAmountEqual ? dutchUnit.spentAmount : dutchUnit.personDetails.map { $0.spentAmount }.reduce(0, { partialResult, element in
                return partialResult + element
            })
        }
        
        // 불참 인원은 Average 계산에서 제외.
        let average = getAverage(totalAmount: totalAmount, numOfPeople: dutchUnit.personDetails.filter { $0.isAttended }.count)
        // 불참인 경우 -1 대입
        let unitArr = dutchUnit.personDetails.sorted().map { $0.isAttended ? $0.spentAmount : -1 }
        // 불참인 경우 계산 없이 0, 그 외: X - Average
        let result = unitArr.map { $0 < 0 ? 0 : $0 - average }
        print("result: \(result)")
        return result
    }
    
    func getAverage(totalAmount: Double, numOfPeople: Int) -> Double {
        return totalAmount / Double(numOfPeople)
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
                         spentTo placeName: String?,
                         spentAmount: Double,
                         personDetails: [PersonDetail],
                         spentDate: Date?) -> DutchUnit {

//        dutchUnit.placeName = placeName
        
        dutchUnit.spentAmount = spentAmount
        dutchUnit.personDetails = Set(personDetails)

        let totalPrice = personDetails.map { $0.spentAmount }.reduce(0) { partialResult, element in
            return partialResult + element
        }

        dutchUnit.isAmountEqual = totalPrice == spentAmount

//        dutchUnit.spentDate = spentDate
        if spentDate != nil {
            dutchUnit.spentDate = spentDate!
        }

        if placeName != nil {
            dutchUnit.placeName = placeName!
        }
        
        do {
            try mainContext.save()
            return dutchUnit
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
//    @discardableResult
//    func updateDutchUnit(target originalUnit: DutchUnit, with updatedUnit: DutchUnit) -> DutchUnit {
//        originalUnit.placeName = updatedUnit.placeName
//        originalUnit.spentAmount = updatedUnit.spentAmount
//        originalUnit.personDetails = updatedUnit.personDetails
//        originalUnit.spentDate = updatedUnit.spentDate
//
//        let totalPrice = originalUnit.personDetails.map { $0.spentAmount }.reduce(0) { partialResult, element in
//            return partialResult + element
//        }
//
//        originalUnit.isAmountEqual = totalPrice == originalUnit.spentAmount
//
//        do {
//            try mainContext.save()
//            return originalUnit
//        } catch let error {
//            fatalError(error.localizedDescription)
//        }
//    }
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

// MARK: - People Helper
extension DutchManager {
    @discardableResult
//    func createPerson(name: String, prevPeople: [Person]? = nil, givenIndex: Int = 100 ) -> Person {
    func createPerson(name: String, currentGathering: Gathering ) -> Person {
        
         let person = Person(context: mainContext)
         
         person.name = name
        person.id = UUID()
        
        let numOfPeople = currentGathering.people.count
        person.order = Int64(numOfPeople)
        
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
        update()
    }
    
    func addPeople(addedPeople: [Person], currentGathering: Gathering) {
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
    
    func removePeople(from gathering: Gathering, removedPeople: [Person]) {
        if removedPeople.count == 0 { return }
        
        for removedPerson in removedPeople {
            for dutchUnit in gathering.dutchUnits {
                for eachDetail in dutchUnit.personDetails {
                    if eachDetail.person! == removedPerson {
                        dutchUnit.personDetails.remove(eachDetail)
                    }
                }
            }
            gathering.people.remove(removedPerson)
        }
        update()
    }
    
    func updatePeople(updatedPeople: [Person], currentGathering: Gathering) {
        // 이름 바꾸는 경우는 어떻게 처리하지... ??
        // 사람을 추가할 수도, 제거할 수도 있는 경우.
        let originalMemberSet = Set(currentGathering.people)
        let updatedMemberSet = Set(updatedPeople)
        
        let addedPeopleSet = updatedMemberSet.subtracting(originalMemberSet)
        
        let removedPeopleSet = originalMemberSet.subtracting(updatedMemberSet)
        print("people flag 2, addedPeopleSet: \(addedPeopleSet)")
        
        // 이 과정을 먼저 해야 Loop 를 짧게 돈다.
        // removedPeopleSet
        if removedPeopleSet.count != 0 {
            for eachPerson in removedPeopleSet {
                for eachUnit in currentGathering.dutchUnits {
                    for eachDetail in eachUnit.personDetails {
                        if eachDetail.person! == eachPerson {
                            eachUnit.personDetails.remove(eachDetail)
                        }
                    }
                }
                currentGathering.people.remove(eachPerson)
            }
        }
        
        
        // addedPeopleSet
        if addedPeopleSet.count != 0 {
            
            for eachUnit in currentGathering.dutchUnits { // 이게.. 존재하지 않아서 call 되지 않음.
                for eachPerson in addedPeopleSet {
                    let newPersonDetail = self.createPersonDetail(person: eachPerson, isAttended: false, spentAmount: 0)
                    // 순서가 중요함 !! 내부에서 새로 personDetail 만든 후 update 할 것!
                    eachUnit.personDetails.update(with: newPersonDetail)
                    print("people flag 3, currentGathering's people: \(currentGathering.people)")
                }
            }
            
            for eachPerson in addedPeopleSet {
                currentGathering.people.update(with: eachPerson)
            }
        }
        
        update() // update 했는데 왜... ??
    }
    
    func addPerson(name: String) {
//        let newPerson =
    }
    
    
    
    // MARK: - Test Funcs
    
    
    
}


extension DutchManager {
    func swapPersonOrder(of person1: Person, with person2: Person) {
        let tempOrder = person2.order
        
        person2.order = person1.order
        person1.order = tempOrder
        
        //        update()
        
    }
}

