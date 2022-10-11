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
    

    // 실패할 수 있나 ?? 현재 gathering 이 없는 경우 ; ?
    func resetGathering(completion: @escaping (Gathering) -> Void ) {

        guard let gathering = currentGathering else {
            fatalError()
        
        }
        
        dutchManager.resetCurrentGathering(gathering: gathering) { cleanGathering in
            completion(cleanGathering)
        }
        
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
    
    func fetchLastUsedGathering(lastUsedGatheringId: String, completion: @escaping (Gathering) -> Void) {
//        let lastUsedGatheringUUID = UserDefaultSetup
        if let lastUsedGathering = dutchManager.fetchGathering(.id(lastUsedGatheringId)) {
            completion(lastUsedGathering)
        } else {
            
            let latestGathering = dutchManager.fetchGathering(.latest)
            
            guard let latestGathering = latestGathering else { return }

            completion(latestGathering)
            
        }
        
    }
    
    func fetchLatestGathering(completion: @escaping (Gathering) -> Void) {
        
        let latestGathering = dutchManager.fetchGathering(.latest)
        
        guard let latestGathering = latestGathering else { return }

        completion(latestGathering)
    }
    
//    func makeGatheringLatest
    func updateDate(gathering: Gathering) {
        dutchManager.updateDate(gathering: gathering)
    }
    
    
    
    func changeGatheringName(to newName: String, completion: @escaping (Gathering) -> Void) {
        guard let gathering = currentGathering else { return }
        gathering.title = newName
        self.dutchManager.update()
        completion(gathering)
    }
    
    func changePersonName(target: Person, newName: String, completion: (Bool) -> Void) {
        target.name = newName
        self.dutchManager.update()
        completion(true)
    }
    
    func changeGatheringName(to newName: String, target: Gathering, completion: @escaping () -> Void) {
//        guard let gathering = currentGathering else { return }
//        let gathering =
//        var gathering = target
//        gathering.title = newName
        target.title = newName
        self.dutchManager.update()
//        completion(gathering)
        completion()
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
        
        dutchManager.updateAllDetailsWithNewPeople(updatedPeople: newPeople, currentGathering: currentGathering)
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
        let newTitle = "Gathering " + String(allGatheringsCount + 1)

        let newGathering = dutchManager.createGathering(title: newTitle)
        completion(newGathering)
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
        
        dutchManager.updateAllDetailsWithNewPeople(updatedPeople: updatedPeople, currentGathering: currentGathering)
        
        dutchManager.updateDutchUnit(target: originalDutchUnit, spentTo: spentPlace ?? "somewhere", spentAmount: spentAmount, personDetails: peopleDetail, spentDate: spentDate)
    }
    
    func createDutchUnit(spentplace: String, spentAmount: Double, spentDate: Date, personDetails: [PersonDetail]) -> Gathering {
        // TODO: create DutchUnit
        
        guard let currentGathering = currentGathering else {fatalError("no gathering") }
        
        let newDutchUnit = dutchManager.createDutchUnit(spentTo: spentplace, spentAmount: spentAmount, personDetails: personDetails, spentDate: Date())


        // personDetails : Updated
        let updatedPeople = personDetails.map { $0.person! }
            print("people flag 1, updatedPeople: \(updatedPeople)")
        
        dutchManager.updateAllDetailsWithNewPeople(updatedPeople: updatedPeople, currentGathering: currentGathering)
        
        // Need to be done inside DutchManger ?? 
        currentGathering.dutchUnits.insert(newDutchUnit)
        
        dutchManager.update()
        
        return currentGathering
    }
    
    func addPerson(name: String, personDetails: [PersonDetail], completion: @escaping (Result<[PersonDetail], DutchUnitError>) -> Void) {
        
        // convert current personDetails into names Set
        let personNames = Set(personDetails.map { $0.person!.name} )
        
        // Check if name set contains new name
        if personNames.contains(name) {
            completion(.failure(.duplicateName))
        }
        
        
        //TODO: Make New Person, PersonDetail
        
        guard let currentGathering = currentGathering else { fatalError() }
        
        // FIXME: 여기 과정 때문에 UpdateUnit 이 제대로 이루어지지 않음.
        // 다른 personDetails 에서 새로운 Person 이 생기지 않음.
//        let newPerson = dutchManager.addPersonToGathering(name: name, currentGathering: currentGathering)
        let newPerson = dutchManager.createPerson(name: name, order: personDetails.count)
        
        let newPersonDetail = dutchManager.createPersonDetail(person: newPerson)
        
        //FIXME: 이거 여기서 하면 안돼요~
//        dutchManager.addPeople(addedPeople: [newPerson], currentGathering: currentGathering)
        
        let resultDetails = personDetails + [newPersonDetail]
        
        completion(.success(resultDetails))
        return
    }
    
    func returnPersonDetails(initialDetails: [PersonDetail], detailPriceDic: [Int:Double], detailAttendingDic: [Idx: Bool]) -> [PersonDetail] {
        
        var newPersonDetails = initialDetails
        
//        newPersonDetails
        
//        for (idx, eachValue) in detailPriceDic {
//            newPersonDetails[idx].spentAmount = eachValue
//            guard let isAttended = detailAttendingDic[idx] else { fatalError() }
//            newPersonDetails[idx].isAttended = isAttended
//        }
        
        for idx in 0 ..< newPersonDetails.count {
//            newPersonDetails[idx].spentAmount =
            guard let spentAmt = detailPriceDic[idx], let isAttended = detailAttendingDic[idx] else { fatalError() }
            newPersonDetails[idx].spentAmount = spentAmt
            newPersonDetails[idx].isAttended = isAttended
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
        
        let newPerson = dutchManager.addPersonToGathering(name: name, currentGathering: currentGathering)
        
        dutchManager.addPeople(addedPeople: [newPerson], currentGathering: currentGathering)
        
        completion(newPerson)
    }
    
    func removePerson(person: Person, completion: @escaping (Bool) -> Void) {
        guard let currentGathering = currentGathering else { fatalError() }
        
        var personDetails: [PersonDetail] = []
        for eachUnit in currentGathering.dutchUnits {
            personDetails = eachUnit.personDetails.filter { $0.person == person }
        }

        if personDetails.filter({ $0.spentAmount != 0 }).count != 0 {
            completion(false)
        } else {
            dutchManager.removePeople(from: currentGathering, removedPeople: [person])
            completion(true)
        }
        

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
//        completion(.failure(.failedToDelete))
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
    
    // MARK: - 계산 후에 이름을 바꾸게 될 수도 있으니까, 우선 Order 로 하는게 좋지 않을까 ??
    // MARK: - 음.. 아니면 Person 에 UUID 를 주거나.. 이름을 바꿀 수도 있고, 순서를 바꿀 수도 있으니까.
    
    func calculateResults(gathering: Gathering) -> [ResultTupleWithId] {
        
        let overallPayInfos = createPersonPayInfos(gathering: gathering)

        let people = gathering.people

        let tupleIngredients = overallPayInfos.map { paymentInfo -> PersonTuple in
            guard let person = people.filter({ $0.name == paymentInfo.name}).first else { fatalError() }
            let correspondingIdx = Idx(person.order)
          
            return PersonTuple(
                name: paymentInfo.name,
                spentAmount: Int(paymentInfo.toGet * 100) , // * 100 으로 Int 로 만들어버리기.
                idx: correspondingIdx )
        }
        
        print("just before calculate, Check info:")
        
        for tuple in tupleIngredients {
            print("name: \(tuple.name), idx: \(tuple.idx), amt: \(tuple.spentAmount)")
        }
        
        let resultsWithIndices = calculateDutchResults(using: tupleIngredients)
        
        let ret = resultsWithIndices.map { resultTuple -> ResultTupleWithId in
            guard let sender = people.filter({ $0.order == resultTuple.from }).first,
            let receiver = people.filter({ $0.order == resultTuple.to}).first else { fatalError() }
        

            let amt = Double(resultTuple.amount) / 100
            
            return ResultTupleWithId(from: sender.id, to: receiver.id, amount: amt )
        }
        
        return ret
    }
    
    func convertResultIDIntoName(gathering: Gathering, resultTupleIds: [ResultTupleWithId]) -> [ResultTupleWithName] {
        
        let people = gathering.people

//        let sortedResultTuple = resultTupleIds.sort
        
        let ret = resultTupleIds.map { resultTupleId -> ResultTupleWithName in
            let source = resultTupleId
            guard let fromPerson = people.first(where: ({ source.from == $0.id })), // $0: person in people
                    let toPerson = people.first(where: { source.to == $0.id}) else {
                fatalError()
            }
            
            return ResultTupleWithName(from: fromPerson.name, to: toPerson.name, amount: source.amount)
        }
        
        return ret
    }
    
    func returnValidInfoAfterCalculation(gathering: Gathering) -> [ResultTupleWithName] {
//         ResultTupleWithId = (from: UUID, to: UUID, amount: Double)
        let firstResult = calculateResults(gathering: gathering)

//         ResultTupleWithName = (from: String, to: String, amount: Double)
        let finalResult = convertResultIDIntoName(gathering: gathering, resultTupleIds: firstResult)
        // 여기에서 값이 틀리게 나오는건 아닌데, 왜.. 이상하게 나올까 ??
        print("finalResult: \(finalResult)")
        return finalResult
    }
}

enum DutchError: Error {
    case failedToGetGathering
    case cancelAskingName
    case duplicateName
    case failedToDelete
}



