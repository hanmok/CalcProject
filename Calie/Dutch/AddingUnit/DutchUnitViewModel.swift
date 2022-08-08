//
//  DutchUnitViewModel.swift
//  Calie
//
//  Created by Mac mini on 2022/07/31.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

typealias DetailState = (spentAmount: Double, isAttended: Bool)

typealias InitialState = (place: String, amount: String, date: Date)


class DutchUnitViewModel {
    
    var selectedDutchUnit: DutchUnit?
    var gathering: Gathering
    
    let dutchService = DutchService()
    
    
    init(selectedDutchUnit: DutchUnit?, gathering: Gathering) {
        self.selectedDutchUnit = selectedDutchUnit
        self.gathering = gathering
        dutchService.currentGathering = gathering
        guard let selectedDutchUnit = selectedDutchUnit else {
            return
        }
        
//        initialParticipantsNames = selectedDutchUnit.personDetails.sorted().map { $0.person!.name }
    }
    
    var initialParticipants: [Person] = [] // shouldn't be real model ??
//    var initialParticipantsNames: [String] = [] // shouldn't be real model ??
//    var personDetails: [PersonDetail] = []
    var participants: [Person] = []
//    var participantsNames: [String] = []
    
    // MARK: - Actions when Observed Properties changed.
    
    var changeableConditionState: (Bool) -> Void = { _ in }

//    var personDetailCellState: ([Int: DetailState]) -> Void = { _ in }

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
    
    private var sumOfIndividual: Double = 0 {
        willSet {
            let condition = (sumOfIndividual == spentAmount) && (newValue != 0)
            isConditionSatisfied = condition
            print("condition flag 3, \(condition)")
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
        }
    }
    
    
    
    // MARK: - Main Functions
    
    // TODO: using service layer, store or update dutchUnit
    
//    public func updateDutchUnit(completion: @escaping () -> Void) {
    public func updateDutchUnit(spentPlace: String,
                                spentAmount: Double,
                                spentDate: Date,
                                detailPriceDic: [Int:Double],
                                completion: @escaping () -> Void ) {
        
        // TODO: Update PersonDetails
//        let newPersonDetails =
        personDetails = dutchService.updatePersonDetails(initialDetails: personDetails, detailPriceDic: detailPriceDic)
        
        
        
        //        guard let numOfAllUnits = numOfAllUnits else { return }
        let numOfAllUnits = 0
//        let spentPlace = spentPlaceTF.text! != "" ? spentPlaceTF.text! : "항목 \(numOfAllUnits + 1)"
        
        
        
        if let initialDutchUnit = selectedDutchUnit {
            
            dutchService.updateDutchUnit(originalDutchUnit: initialDutchUnit,
                                         peopleDetail: personDetails,
                                         spentPlace: "",
                                         spentDate: Date())
        } else {
//            dutchService.createDutchUnit(peopleDetails: personDetails,
//                                         spentPlace: "spent place",
//                                         spentDate: Date())
            
            gathering = dutchService.createDutchUnit(spentplace: spentPlace, spentAmount: spentAmount, spentDate: Date(), peopleDetails: personDetails)
        }
        
        completion()
    }
    
    public func reset(completion: @escaping () -> Void ) {
        // TODO: Ask DutchService
        participants = initialParticipants
        personDetails = []
        completion()

    }
    
    public func initializePersonDetails(gathering: Gathering, dutchUnit: DutchUnit?) {
        print("initializing personDetails flag 1")
//        guard let dutchUnit = dutchUnit else { return }
        if let dutchUnit = dutchUnit {
            personDetails = dutchUnit.personDetails.sorted()
        } else {
//            DutchManager
//            dutchService.create
//            personDetails =
            personDetails = dutchService.createPersonDetails(from: gathering)
                
            
        }
    
        print("initializing personDetails flag 2")
        print("numOfPersonDetails: \(personDetails.count)")
        // 사람을 생성하지 않았어..
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
        
        let initialState = InitialState(place: initialDutchUnit.placeName, amount: initialDutchUnit.spentAmount.addComma(), date: initialDutchUnit.spentDate)
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
