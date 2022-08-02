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

    var personDetailCellState: ([Int: DetailState]) -> Void = { _ in }

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
    
    public var peopleDetail: [PersonDetail] = [] {
        willSet {
            var sum = 0.0
            for (_, value) in newValue.enumerated() {
                sum += value.spentAmount
            }
            sumOfIndividual = sum
            updateCollectionView()
//            personDetailCellState
        }
    }
    
    
    // MARK: - Main Functions
    
    // TODO: using service layer, store or update dutchUnit
    
    public func updateDutchUnit(completion: @escaping () -> Void) {
        
//        for personIndex in 0 ..< participants.count {
//        for personNameIndex in 0 ..< participantsNames.count {
        
//        }
        
        //        guard let numOfAllUnits = numOfAllUnits else { return }
        let numOfAllUnits = 0
//        let spentPlace = spentPlaceTF.text! != "" ? spentPlaceTF.text! : "항목 \(numOfAllUnits + 1)"
        
        if let initialDutchUnit = selectedDutchUnit {
            
            dutchService.updateDutchUnit(originalDutchUnit: initialDutchUnit, peopleDetail: peopleDetail, spentPlace: "", spentDate: Date())
            
        } else {
            dutchService.createDutchUnit(peopleDetails: peopleDetail, spentPlace: "spent place", spentDate: Date())
        }
        
        completion()
    }
    
    public func reset(completion: @escaping () -> Void ) {
        
//        participantsNames = initialParticipantsNames
        participants = initialParticipants
        peopleDetail = []
        completion()
            
        //        textFieldWithPriceDic = [:]
//        setAction(to: .initializePriceDic)
        // TODO: Initialize Price Dic
//                initializePersonDetails(initialDutchUnit: initialDutchUnit)
    
    }
    
    public func initializePersonDetails(dutchUnit: DutchUnit?) {
        
    }
    
    public func addPerson(name: String, completion: @escaping (Result<String, DutchUnitError>) -> Void) {
        // TODO: Set personDetails
        
        dutchService.addPerson(name: name, personDetails: peopleDetail) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let peopleDetail):
                self.peopleDetail = peopleDetail
                guard let lastPersonDetail = peopleDetail.last,
                      let lastPerson = lastPersonDetail.person else { fatalError() }
                
                self.participants.append(lastPerson)
                completion(.success("\(name) has added"))
                
            case .failure(let e):
                print(e.localizedDescription)
                completion(.failure(.duplicateName))
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
