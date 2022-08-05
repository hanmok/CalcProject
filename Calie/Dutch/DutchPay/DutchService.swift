//
//  DutchpayService.swift
//  Calie
//
//  Created by Mac mini on 2022/07/31.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation


class DutchService {
    
    var currentGathering: Gathering?
    var currentDutchUnit: DutchUnit?
    
    let dutchManager = DutchManager()
    

    
    
    func fetchDutchUnits(closure: @escaping () -> [DutchUnit]) {
        
    }
    
    
    
    typealias ResultTest = (Result<Gathering, DutchError>) -> Void
    
    func resetGathering(completion: @escaping ResultTest) {
        //        currentGathering
        guard let gathering = currentGathering else {
            //            completion(nil)
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
        completion(newGathering!)
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

    
//    func updateDutchUnit(originalDutchUnit: DutchUnit, peopleDetailDic: [Int: DetailState], updatedName: String?, updatedDate: Date? ) {
    func updateDutchUnit(originalDutchUnit: DutchUnit, peopleDetail: [PersonDetail], spentPlace: String?, spentDate: Date?) {
        
        // TODO: replace personDetails using dic
        // ex:
        //            viewModel.personDetails[personIndex].isAttended = attendingDic[personIndex] ?? true
        //            viewModel.personDetails[personIndex].spentAmount = textFieldWithPriceDic[personIndex] ?? 0
        
    }
    
//    func createDutchUnit(peopleDetailDic: [Int: DetailState], spentPlace: String, spentDate: Date) {
    func createDutchUnit(spentplace: String, spentAmount: Double, spentDate: Date, peopleDetails: [PersonDetail] ) -> Gathering{
        // TODO: create DutchUnit
        guard let currentGathering = currentGathering else {fatalError("no gathering ") }
        
        let newDutchUnit = dutchManager.createDutchUnit(spentTo: spentplace, spentAmount: spentAmount, personDetails: peopleDetails, spentDate: Date())
        
        // Need to be done inside DutchManger ?? 
        currentGathering.dutchUnits.insert(newDutchUnit)
        
        // 사람 비교해서, 구성인원이 다를 경우 Participants 처리해줘야함. ;;
        
        
        dutchManager.update()
        
        
        
        return currentGathering
        
    }
    
    func addPerson(name: String, personDetails: [PersonDetail], completion: @escaping (Result<[PersonDetail], DutchUnitError>) -> Void) {
        
        for personDetail in personDetails {
            guard let person = personDetail.person else { fatalError() }
            print("current person name: \(person.name)")
            print("compared name: \(name)\n")
            if person.name == name {
print("duplicate flag 1")
                completion(.failure(.duplicateName))
                return
            }
        }
        
        
        
        //TODO: Make New Person, PersonDetail
        
        let newPerson = dutchManager.createPerson(name: name)
        
        let newPersonDetail = dutchManager.createPersonDetail(person: newPerson)
        
        let resultDetails = personDetails + [newPersonDetail]
        
        completion(.success(resultDetails))
        return
    }
    
    func updatePersonDetails(initialDetails: [PersonDetail], detailPriceDic: [Int:Double]) -> [PersonDetail] {
        
        var newPersonDetails = initialDetails
//        newPersonDetails
        for (idx, eachValue) in detailPriceDic {
            newPersonDetails[idx].spentAmount = eachValue
        }
        
        return newPersonDetails
    }
}


enum DutchError: Error {
    case failedToGetGathering
    case cancelAskingName
}
