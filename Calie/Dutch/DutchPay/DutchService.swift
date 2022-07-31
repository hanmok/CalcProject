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
    
    let dutchManager = DutchManager()
    
    var selectedDutchUnit: DutchUnit?
    
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
//        completion(gathering)
        completion(.success(gathering))
        
        // order updating to viewmodel
    }
    
    func changeGatheringName(to newName: String, completion: @escaping (Gathering) -> Void) {
        guard let gathering = currentGathering else { return }
        gathering.title = newName
        self.dutchManager.update()
        completion(gathering)
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
    }
    
    func updatePeople(with newPeople: [Person], completion: @escaping (Gathering) -> Void) {
        guard let currentGathering = currentGathering else {
            return
        }

        dutchManager.updatePeople(updatedPeople: newPeople, currentGathering: currentGathering)
         let newGathering = currentGathering
        completion(newGathering)
        
    }
    
    func deleteDutchUnit(idx: Int, completion: @escaping (Gathering) -> Void) {
        guard let currentGathering = currentGathering else {
            fatalError()
        }

        DutchUnit.deleteSelf(currentGathering.dutchUnits.sorted()[idx])
        completion(currentGathering)
    }
    func createGathering( completion: @escaping (Gathering) -> Void) {
        let allGatheringsCount = dutchManager.fetchGatherings().count
        let newGathering = dutchManager.createGathering(title: String(allGatheringsCount + 1))
        completion(newGathering!)
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
    }
}


enum DutchError: Error {
    case failedToGetGathering
    case cancelAskingName
}
