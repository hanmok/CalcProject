//
//  DutchpayService.swift
//  Calie
//
//  Created by Mac mini on 2022/07/31.
//  Copyright © 2022 Mac mini. All rights reserved.
//



// DutchUnit 에서 추가한거는 중복추가됨
// ParticipantsController 에서 추가한거는 덜 추가됨; ;;;;

import Foundation


class DutchService {
    
    var currentGathering: Gathering?
    var currentDutchUnit: DutchUnit?
    
    let dutchManager = DutchManager()

    func fetchDutchUnits(closure: @escaping () -> [DutchUnit]) {
    }
    
    init() {
        
    }
    
    init(currentGathering: Gathering) {
        self.currentGathering = currentGathering
    }
    
    typealias ResultTest = (Result<Gathering, DutchError>) -> Void
    
    func resetGathering(completion: @escaping ResultTest) {
        //        currentGathering
        guard let gathering = currentGathering else {
            completion(.failure(.failedToGetGathering))
            return }
        
        gathering.people = []
        gathering.dutchUnits = []
        gathering.totalCost_ = 0
        
        gathering.createdAt = Date()
        gathering.updatedAt = Date()
        
        dutchManager.update()
        completion(.success(gathering))
        return
        // order updating to viewmodel
    }
    
    
    func createPersonDetails(from gathering: Gathering) -> [PersonDetail] {
        
        var personDetails: [PersonDetail] = []
        let sortedPeople = gathering.people.sorted()
        
        for idx in 0 ..< sortedPeople.count {
            let targetPerson = sortedPeople[idx]
            let newPersonDetail = dutchManager.createPersonDetail(person: targetPerson, isAttended: true, spentAmount: 0)
            personDetails.append(newPersonDetail)
        }
        
//        completion(personDetails)
    return personDetails
    }
    
    
    
    func fetchLatestGathering(completion: @escaping (Gathering) -> Void) {
        
        let latestGathering = dutchManager.fetchGathering(.latest)
        guard let latestGathering = latestGathering else {
            return
        }

        completion(latestGathering)
    }
    
    
    func changeGatheringName(to newName: String, completion: @escaping (Gathering) -> Void) {
        guard let gathering = currentGathering else { return }
        gathering.title = newName
        self.dutchManager.update()
        completion(gathering)
        return
    }
    
    func updateDutchUnit(dutchUnit: DutchUnit, isNew: Bool, completion: @escaping (Gathering) -> Void) {
        guard let gathering = currentGathering else { fatalError() }
        
        if isNew {
            gathering.dutchUnits.insert(dutchUnit)
        }
        
        let updatedPeopleArr = dutchUnit.personDetails.map { $0.person! }
        let updatedPeopleSet = Set(updatedPeopleArr)
        
        let prevPeople = gathering.people
        
        let newPeople = updatedPeopleSet.subtracting(prevPeople)
        
        if newPeople.count != 0 {
            for newPerson in newPeople {
                gathering.people.insert(newPerson)
            }
            
            
            for eachUnit in gathering.dutchUnits {
                if eachUnit.personDetails.count != updatedPeopleSet.count {
                    for newPerson in newPeople {
                        
                        let newDetail = dutchManager.createPersonDetail(person: newPerson, isAttended: false, spentAmount: 0)
                        eachUnit.personDetails.insert(newDetail)
                        print("person added to another DutchUnit, title: \(eachUnit.placeName), personName: \(newPerson.name)")
                    }
                }
            }
        }
        
        print("current participants flag1: \(gathering.people)")
        
        dutchManager.update()
        completion(gathering)
        return
    }
    
    func updatePeople(with newPeople: [Person], completion: @escaping (Gathering) -> Void) {
        guard let currentGathering = currentGathering else {
            return
        }
        
        dutchManager.updatePeople(updatedPeople: newPeople, currentGathering: currentGathering)
        let newGathering = currentGathering
        completion(newGathering)
        return
        
    }
    
    func deleteDutchUnit(idx: Int, completion: @escaping (Gathering) -> Void) {
        guard let currentGathering = currentGathering else {
            fatalError()
        }
        
        DutchUnit.deleteSelf(currentGathering.dutchUnits.sorted()[idx])
        completion(currentGathering)
        return
    }
    func createGathering( completion: @escaping (Gathering) -> Void) {
        let allGatheringsCount = dutchManager.fetchGatherings().count
        let newGathering = dutchManager.createGathering(title: String(allGatheringsCount + 1))
        completion(newGathering)
        return
    }
    
    func updateGathering(completion: @escaping (Gathering) -> Void) {
        //        if let latestGathering = dutchManager.fetchGathering(.latest) {
        //            gathering = latestGathering
        //        }
        
        //        if gathering == nil {
        //            gathering = dutchManager.createGathering(title: "default gathering")
        //        }
        
        
        let gathering = Gathering()
        
        completion(gathering)
        return
    }
}

// MARK: -DutchUnitController
extension DutchService {

    func updateDutchUnit(originalDutchUnit: DutchUnit, peopleDetail: [PersonDetail], spentAmount: Double,  spentPlace: String?, spentDate: Date? ) {
        
        guard let currentGathering = currentGathering else { fatalError() }
        // TODO: Compare people
        let updatedPeople = peopleDetail.map { $0.person! }
        
        dutchManager.updatePeople(updatedPeople: updatedPeople, currentGathering: currentGathering)
        
        dutchManager.updateDutchUnit(target: originalDutchUnit, spentTo: spentPlace ?? "somewhere", spentAmount: spentAmount, personDetails: peopleDetail, spentDate: spentDate)
    }
    
    func createDutchUnit(spentplace: String, spentAmount: Double, spentDate: Date, personDetails: [PersonDetail]) -> Gathering{
        // TODO: create DutchUnit
        
        guard let currentGathering = currentGathering else {fatalError("no gathering") }
        
        let newDutchUnit = dutchManager.createDutchUnit(spentTo: spentplace, spentAmount: spentAmount, personDetails: personDetails, spentDate: Date())


        // personDetails : Updated
        let updatedPeople = personDetails.map { $0.person! }
            print("people flag 1, updatedPeople: \(updatedPeople)")
        dutchManager.updatePeople(updatedPeople: updatedPeople, currentGathering: currentGathering)
        
        // Need to be done inside DutchManger ?? 
        currentGathering.dutchUnits.insert(newDutchUnit)
        
        dutchManager.update()
        
        return currentGathering
        
    }
    
    func addPerson(name: String, personDetails: [PersonDetail], completion: @escaping (Result<[PersonDetail], DutchUnitError>) -> Void) {
        
        // convert current personDetails into names Set
        let personNames = Set(personDetails.map { $0.person!.name})
        
        // Check if name set contains new name
        if personNames.contains(name) {
            completion(.failure(.duplicateName))
        }
        
        
        //TODO: Make New Person, PersonDetail
        
        guard let currentGathering = currentGathering else { fatalError() }
        
        let newPerson = dutchManager.createPerson(name: name, currentGathering: currentGathering)
        
        let newPersonDetail = dutchManager.createPersonDetail(person: newPerson)
        
        //FIXME: 이거 여기서 하면 안돼요~
//        dutchManager.addPeople(addedPeople: [newPerson], currentGathering: currentGathering)
        
        let resultDetails = personDetails + [newPersonDetail]
        
        completion(.success(resultDetails))
        return
    }
    
    func returnPersonDetails(initialDetails: [PersonDetail], detailPriceDic: [Int:Double]) -> [PersonDetail] {
        
        var newPersonDetails = initialDetails
//        newPersonDetails
        for (idx, eachValue) in detailPriceDic {
            newPersonDetails[idx].spentAmount = eachValue
        }
//        dutchManager.update()
        
        return newPersonDetails
    }
}

// MARK: - ParticipantsController
extension DutchService {
    func swapPersonOrder(person1: Person, person2: Person, closure: @escaping () -> Void) {
        dutchManager.swapPersonOrder(of: person1, with: person2)
    closure()
    }
    
    
    func addPerson(name: String, completion: @escaping (Person) -> Void ) {
        
        guard let currentGathering = currentGathering else { fatalError() }
        
        let newPerson = dutchManager.createPerson(name: name, currentGathering: currentGathering)
        
        dutchManager.addPeople(addedPeople: [newPerson], currentGathering: currentGathering)
        
        completion(newPerson)
    }
    
    func removePerson(person: Person, completion: @escaping () -> Void) {
        guard let currentGathering = currentGathering else { fatalError() }
        dutchManager.removePeople(from: currentGathering, removedPeople: [person])
        completion()
    }
    
    func update() {
        dutchManager.update()
    }
}


// MARK: - SideViewController

extension DutchService {
    func removeGathering(target: Gathering, completion: @escaping (Result<[Gathering], DutchError>) -> Void) {
        dutchManager.deleteGathering(gathering: target) {
            let allGatherings = self.dutchManager.fetchGatherings()
            completion(.success(allGatherings))
        }
        completion(.failure(.failedToDelete))
    }
    
    func fetchAllGatherings(completion: @escaping (([Gathering]) -> Void)) {
        let allGatherings = dutchManager.fetchGatherings()
        completion(allGatherings)
    }
}

// MARK: - ResultViewController
extension DutchService {
    func createOverallInfo(gathering: Gathering) -> [OverallPersonInfo] {
        return dutchManager.createOverallInfo(gathering: gathering)
    }
    
    func createPersonPayInfos(gathering: Gathering) -> [PersonPaymentInfo] {
        return dutchManager.createPersonPayInfos(gathering: gathering)
    }
    
//    func create
    
}

// MARK: - Result
extension DutchService {
    
//    func calculateResults(gathering: Gathering, closure: @escaping ([DetailResultTuple]) -> Void) {
    
    func calculateResults(gathering: Gathering) -> [DetailResultTuple] {
        

        let overallPayInfos = createPersonPayInfos(gathering: gathering)

        let people = gathering.people

        //        let person = people.first?.
                                                            // PersonTuple: (name: String, spentAmount: Int, idx: Idx)
        let tupleIngredients = overallPayInfos.map { paymentInfo -> PersonTuple in
            guard let person = people.filter({ $0.name == paymentInfo.name}).first else { fatalError() }
            let correspondingIdx = Idx(person.order)
            return PersonTuple(name: paymentInfo.name, spentAmount: Int(paymentInfo.toGet), idx: correspondingIdx )
        }
        // ResultTuple:  (from: Idx, to: Idx, amount: Int)
        let resultsWithIndices = calculateUsing(personTuples: tupleIngredients)
        
        let ret = resultsWithIndices.map { resultTuple -> DetailResultTuple in
            guard let sender = people.filter({ $0.order == resultTuple.from }).first,
            let receiver = people.filter({ $0.order == resultTuple.to}).first else { fatalError() }
        
            let amt = resultTuple.amount
            
            return DetailResultTuple(from: sender.name, to: receiver.name, amount: amt )
        }
        
        // DetailResultTuple:  (from: String, to: String, amount: Int)
        return ret
    }
    
}

enum DutchError: Error {
    case failedToGetGathering
    case cancelAskingName
    case duplicateName
    case failedToDelete
}



