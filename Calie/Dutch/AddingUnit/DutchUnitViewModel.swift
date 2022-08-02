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
        
        initialParticipantsNames = selectedDutchUnit.personDetails.sorted().map { $0.person!.name }
    }
    
//    var initialParticipants: [Person] = [] // shouldn't be real model ??
    var initialParticipantsNames: [String] = [] // shouldn't be real model ??
    var personDetails: [PersonDetail] = []
//    var participants: [Person] = []
    var participantsNames: [String] = []
    
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
    
    private var peopleStateDic: [Int : DetailState] = [:] {
        willSet {
            sumOfIndividual = self.addDictionaryValue(dic: newValue)
            personDetailCellState(newValue)
        }
    }
    
    
    // MARK: - Main Functions
    
    // TODO: using service layer, store or update dutchUnit
    // Properties to use: textFieldWithStateDic, spentAmount( + spentPlace, spentDate)
    
    public func confirmAction(completion: @escaping () -> Void) {
        
//        for personIndex in 0 ..< participants.count {
//        for personNameIndex in 0 ..< participantsNames.count {

//        }
        
        //        guard let numOfAllUnits = numOfAllUnits else { return }
        let numOfAllUnits = 0
//        let spentPlace = spentPlaceTF.text! != "" ? spentPlaceTF.text! : "항목 \(numOfAllUnits + 1)"
        
        if let initialDutchUnit = selectedDutchUnit {
            
            dutchService.updateDutchUnit(originalDutchUnit: initialDutchUnit, peopleDetailDic: peopleStateDic, updatedName: "updated Name", updatedDate: nil)
            
        } else {
            dutchService.createDutchUnit(peopleDetailDic: peopleStateDic, spentPlace: "spent place", spentDate: Date())
        }
        
        completion()
    }
    
    public func reset(completion: @escaping () -> Void ) {
        
        participantsNames = initialParticipantsNames
        personDetails = []
        completion()
            
        //        textFieldWithPriceDic = [:]
//        setAction(to: .initializePriceDic)
        // TODO: Initialize Price Dic
//                initializePersonDetails(initialDutchUnit: initialDutchUnit)
    
    }
    
    public func addPerson(name: String, completion: @escaping (Result<String, DutchUnitError>) -> Void) {
        // TODO: Set personDetails
        var isDuplicateName = false
        
//        for eachPerson in participants {
        for eachName in participantsNames {
//            if eachPerson.name == name {
            if eachName == name {
                completion(.failure(.duplicateName))
                isDuplicateName = true
                break
            }
        }
        
        if isDuplicateName == false {
            // TODO: Make New Person, PersonDetail.
//            textFieldWithStateDic[participants.count] = DetailState(spentAmount: 0, isAttended: true)
            peopleStateDic[participantsNames.count] = DetailState(spentAmount: 0, isAttended: true)
//            dutchService.addPerson() ?? 결정 되지도 않았음 ;; 음.. 일단 생성??
//            let newPerson = Person(
            // FIXME: 여기서 생성하면 안됨.
            
//            participants.append(<#T##newElement: Person##Person#>)
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
