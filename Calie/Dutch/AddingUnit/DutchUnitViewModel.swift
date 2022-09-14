//
//  DutchUnitViewModel.swift
//  Calie
//
//  Created by Mac mini on 2022/07/31.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation



class DutchUnitViewModel {
    
    var selectedDutchUnit: DutchUnit?
    var gathering: Gathering
    
    let dutchService = DutchService()
    
    init(selectedDutchUnit: DutchUnit?, gathering: Gathering) {
        self.selectedDutchUnit = selectedDutchUnit
        self.gathering = gathering
        dutchService.currentGathering = gathering
        
    }
    
    var initialParticipants: [Person] = []
    
    var participants: [Person] = []

    
    // MARK: - Actions when Observed Properties changed.
    
    var changeableConditionState: (Bool) -> Void = { _ in }

    var updateCollectionView: () -> Void = { }
    
    // MARK: - Properties To be Observed

    private var isConditionSatisfied = false {
        willSet {
            print("condition flag 1, \(newValue)")
            changeableConditionState(newValue)
        }
    }
    
    
    private var spentAmount: Double = 0 {
        willSet {
            let condition = (newValue == sumOfIndividual) && (newValue != 0)
            print("condition flag 2, \(condition)")
            isConditionSatisfied = condition
        }
    }
    
    private var spentPlace: String = ""
    
    private var spentDate: Date = Date()
    
    
    // personDeails 에 따라 실시간 업데이트, condition 만족 여부를 확인.
    private var sumOfIndividual: Double = 0 {
        willSet {
            let condition = (newValue == spentAmount) && (newValue != 0)
            
            isConditionSatisfied = condition
            print("condition flag 3, sumOfIndividual: \(newValue), spentAmount: \(spentAmount), condition: \(condition)")

        }
    }
    
    public var personDetails: [PersonDetail] = [] {
        willSet {
            var sum = 0.0
            for (_, value) in newValue.enumerated() {
                sum += value.spentAmount
            }
            sumOfIndividual = sum
            updateCollectionView()
            print("persoNDetail willSet ended")
        }
    }
    
    
    
    // MARK: - Main Functions
    
    // TODO: using service layer, store or update dutchUnit
    

    public func updateDutchUnit(spentPlace: String,
                                spentAmount: Double,
                                spentDate: Date,
                                detailPriceDic: [Int:Double],
                                detailAttendingDic: [Idx: Bool],
                                completion: @escaping () -> Void ) {
    
        // Update PersonDetails with Dictionary
        
        // FIXME: ? 중간에 바뀌었을 가능성이 높은데 왜 이걸써? 아냐. 업데이트 하는거야...;; 왜 이거로 하지? 음.. isAttended 가 고려되지 않음
        // 추가되었을 수도 있는데 ??
        
        personDetails = dutchService.returnPersonDetails(initialDetails: personDetails, detailPriceDic: detailPriceDic, detailAttendingDic: detailAttendingDic)
        
        // Editing Mode
        if let initialDutchUnit = selectedDutchUnit {
            
            let spentAmt = spentAmount != 0 ? spentAmount : initialDutchUnit.spentAmount
            
            dutchService.updateDutchUnit(
                originalDutchUnit: initialDutchUnit,
                peopleDetail: personDetails,
                spentAmount: spentAmt,
                spentPlace: spentPlace,
                spentDate: Date())
        
            // Making Mode
        } else {
            
            gathering = dutchService.createDutchUnit(
                spentplace: spentPlace,
                spentAmount: spentAmount,
                spentDate: Date(),
                personDetails: personDetails)
        }
        
        completion()
    }
    
    public func reset(completion: @escaping () -> Void ) {
        // TODO: Ask DutchService
        participants = initialParticipants
        personDetails = []
        completion()
    }
    
    public func updateSpentAmount(to amt: Double) {
        spentAmount = amt
    }
    
    public func initializePersonDetails(gathering: Gathering, dutchUnit: DutchUnit?) {
        print("initializing personDetails flag 1")
        print("dutchUnit: \(dutchUnit)")
        
        if let dutchUnit = dutchUnit {
            personDetails = dutchUnit.personDetails.sorted()
            print("personDetail flag 1: \(personDetails)")
            spentAmount = dutchUnit.spentAmount
            spentPlace = dutchUnit.placeName
            spentDate = dutchUnit.spentDate
        } else {
            personDetails = dutchService.createPersonDetails(from: gathering)
        }
    

        
        
        print("initializing personDetails flag 2")
        print("numOfPersonDetails: \(personDetails.count)")
    }
    
    public func addPerson(name: String, completion: @escaping (Result<String, DutchUnitError>) -> Void) {
        // TODO: Set personDetails
        
        dutchService.addPerson(name: name, personDetails: personDetails) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let personDetails):
                self.personDetails = personDetails
                guard let lastPersonDetail = personDetails.last,
                      let lastPerson = lastPersonDetail.person else { fatalError() }
                
                self.participants.append(lastPerson)
                
                completion(.success("\(name) has added"))
                return
                
            case .failure(let e):
                print(e.localizedDescription)
                print("duplicate flag 2")
                completion(.failure(.duplicateName))
                return
            }
        }
    }
    
    public func setupInitialState(completion: @escaping (InitialState?, Int?) -> Void) {
        guard let initialDutchUnit = selectedDutchUnit else {
            completion(nil, gathering.dutchUnits.count + 1)
            return }
        
        let initialState = InitialState(place: initialDutchUnit.placeName, amount: initialDutchUnit.spentAmount, date: initialDutchUnit.spentDate)
        
        completion(initialState, nil)
    }
    
    public func setupInitialCells(completion: @escaping ([PersonDetail]) -> Void) {
        
    }
}



extension DutchUnitViewModel {
    private func addDictionaryValue<T: Hashable>(dic: [T: DetailState]) -> Double{
        var sum = 0.0
        for (_, detailState) in dic {
            sum += detailState.spentAmount
        }
        return sum
    }
}

enum DutchUnitError: Error {
    case duplicateName
}



// 저장이 잘 안됐나보다..
