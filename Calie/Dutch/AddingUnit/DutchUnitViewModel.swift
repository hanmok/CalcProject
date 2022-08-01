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

        guard let selectedDutchUnit = selectedDutchUnit else {
            return
        }
        
        initialParticipants = selectedDutchUnit.personDetails.sorted().map { $0.person!}
    }
    
    var initialParticipants: [Person] = []
    var personDetails: [PersonDetail] = []
    var participants: [Person] = []
    
    
    // MARK: - Actions when Observed Properties changed.
    
    var changeableConditionState: (Bool) -> Void = { _ in }

    var personDetailCellState: ([Int: DetailState]) -> Void = { _ in }
    // MARK: - Properties To be Observed
    

    
    private var isConditionSatisfied = false {
        willSet {
            changeableConditionState(newValue)
        }
    }
    
    

    
    private var spentAmount: Double = 0 {
        willSet {
            let condition = (newValue == sumOfIndividual) && (newValue != 0)
            isConditionSatisfied = condition
        }
    }
    
    private var sumOfIndividual: Double = 0 {
        willSet {
            isConditionSatisfied = newValue == spentAmount
        }
    }
    
    public func confirmAction(completion: @escaping () -> Void) {
        
        for personIndex in 0 ..< participants.count {
            //            viewModel.personDetails[personIndex].isAttended = attendingDic[personIndex] ?? true
            //            viewModel.personDetails[personIndex].spentAmount = textFieldWithPriceDic[personIndex] ?? 0
        }
        
        //        guard let numOfAllUnits = numOfAllUnits else { return }
        let numOfAllUnits = 0
//        let spentPlace = spentPlaceTF.text! != "" ? spentPlaceTF.text! : "항목 \(numOfAllUnits + 1)"
        
        if let initialDutchUnit = selectedDutchUnit {
            
            //            dutchManager.updateDutchUnit(
            //                target: initialDutchUnit,
            //                spentTo: spentPlace,
            //                spentAmount: spentAmount,
            //                personDetails: personDetails,
            //                spentDate: spentDatePicker.date)
//            viewModel.setAction(to: .update)
            updateDutchUnit()
            
//            dutchDelegate?.updateDutchUnit(initialDutchUnit, isNew: false)
            
        } else {
            //            dutchUnit = dutchManager.createDutchUnit(spentTo: spentPlace, spentAmount: spentAmount, personDetails: personDetails, spentDate: spentDatePicker.date)
//            viewModel.setAction(to: .createDutchUnit)
            
            createDutchUnit()
            
//            dutchDelegate?.updateDutchUnit(dutchUnit!, isNew: true)
        }
        
        completion()
    }
    
    typealias DetailState = (spentAmount: Double, isAttended: Bool)
    
    typealias InitialState = (place: String, amount: String, date: Date)
    
    private var textFieldWithStateDic: [Int : DetailState] = [:] {
        willSet {
            sumOfIndividual = self.addDictionaryValue(dic: newValue)
            personDetailCellState(newValue)
        }
    }
    
    
    // MARK: - Main Functions
    public func reset(completion: @escaping () -> Void ) {
        //        self.participants = initialParticipants
        participants = initialParticipants
        personDetails = []
        completion()
        //        textFieldWithPriceDic = [:]
//        setAction(to: .initializePriceDic)
        // TODO: Initialize Price Dic
//                initializePersonDetails(initialDutchUnit: initialDutchUnit)
    }
    
    public func updateDutchUnit() {
        
    }
    
    public func createDutchUnit() {
        
    }
    
    public func addPerson(name: String, completion: @escaping (Result<String, DutchUnitError>) -> Void) {
        // TODO: Set personDetails
        var isDuplicateName = false
        
        for eachPerson in participants {
            if eachPerson.name == name {
//                completion("Duplicate name")
                completion(.failure(.duplicateName))
                isDuplicateName = true
                break
            }
        }
        
        if isDuplicateName == false {
            // TODO: Make New Person, PersonDetail.
            
            // TODO: reset 누르면 이것들 초기화 해주기..
            //            let newPerson = dutchManager.createPerson(name: newName, prevPeople: participants)
            //            self.participants.append(newPerson)
            
            //            let newDetail = dutchManager.createPersonDetail(person: newPerson)
            //            self.personDetails.append(newDetail)
            
            completion(.success("\(name) has added"))

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
