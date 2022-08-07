//
//  DutchpayViewModel.swift
//  Calie
//
//  Created by Mac mini on 2022/07/31.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

class DutchpayViewModel {
    
    let dutchService = DutchService()
    
    typealias GatheringInfo = (title: String, totalPrice: String)
    
    // MARK: - Actions when Observed Properties changed.
    
    var updateDutchUnitCells: ([DutchUnitCellComponents]) -> Void = { _ in}
    
    var updateGathering: (GatheringInfo) -> Void = { _ in }
    
    var updateDutchUnits: () -> Void = { }
    
    // MARK: - Properties To be Observed
    
    var gathering: Gathering? = nil {
        didSet {
            guard let gathering = gathering else { return }
            
            let gatheringInfo = GatheringInfo(title: gathering.title, totalPrice: gathering.totalCostStr)
            
            updateGathering(gatheringInfo)
        }
    }
    
    var dutchUnits: [DutchUnit] = [] {
        didSet {
//            let cellComponents = convertDutchUnits(dutchUnits: dutchUnits)
//            updateDutchUnitCells(cellComponents)
            
            updateDutchUnits()
        }
    }

    
    // MARK: - Actions
    
    private func convertDutchUnits(dutchUnits: [DutchUnit]) -> [DutchUnitCellComponents] {
        
        let dutchUnitCellComponents = dutchUnits.map { DutchUnitCellComponents(
            placeName: $0.placeName,
            spentAmount: convertSpentAmount(amt: $0.spentAmount),
            peopleNameList: convertPeopleIntoStr(peopleDetails: $0.personDetails),
            date: convertDateIntoStr(date: $0.spentDate)
        )}
        
        return dutchUnitCellComponents
    }
    
    func updateDutchUnits(gathering: Gathering) {
        self.dutchUnits = gathering.dutchUnits.sorted()
    }
    
    func deleteDutchUnitAction(idx: Int) {
        dutchService.deleteDutchUnit(idx: idx) { gathering in
            self.gathering = gathering
        }
    }
    
    /// create `Gathering n`
    private func createGathering() {
        dutchService.createGathering { gathering in
            self.gathering = gathering
        }
    }
    
    func showHistoryAction() {
        
    }
    
    func addDutchUnit(needGathering: Bool) {
        if needGathering && gathering == nil {
            createGathering()
        }
    }
    
//    func changeGatheringName(newName: String) {
//        changeGatheringNameAction(newName: newName)
//    }
    
    
    
    func resetGatheringAction(needGathering: Bool, completion: @escaping (Bool) -> Void ) {
        
        if needGathering && gathering == nil {
            createGathering()
        }
        
        dutchService.currentGathering = gathering
        
        dutchService.resetGathering { newGathering in
            switch newGathering {
            case .success(let newGathering):
                self.gathering = newGathering
                self.dutchUnits = self.gathering!.dutchUnits.sorted()
                completion(true)
            case .failure(let e):
                print(e.localizedDescription)
                completion(false)
            }
        }
    }
    
    func addDutchUnitAction() {
        
    }
    
    func changeGatheringNameAction(newName: String) {
        dutchService.changeGatheringName(to: newName) { gathering in
            self.gathering = gathering
        }
    }
    
    func calculateAction(needGathering: Bool) {
        if needGathering && gathering == nil {
            createGathering()
        }
        // TODO: Calculate!
    }
    
    func blurredViewTappedAction() {
        
    }
    
    ///  Create gathering, assign
    func makeGathering(with name: String) {
        dutchService.createGathering { gathering in
            self.gathering = gathering
        }
    }
    
    func createIfNeeded() {
        if gathering == nil {
            createGathering()
        }
    }
    func updateDutchUnit(dutchUnit: DutchUnit, isNew: Bool) {
        dutchService.updateDutchUnit(dutchUnit: dutchUnit, isNew: isNew) { gathering in
            self.gathering = gathering
            self.updateDutchUnits(gathering: gathering)
        }
    }
    
    func replaceGathering(newGathering: Gathering) {
        self.gathering = newGathering
    }
    
    func updatePeople(updatedPeople: [Person]) {
        dutchService.updatePeople(with: updatedPeople) { gathering in
            self.gathering = gathering
            self.updateDutchUnits(gathering: gathering)
        }
    }
    
    func viewDidLoadAction() {
        fetchLatestGathering()
    }
    
    func fetchLatestGathering() {
        
        dutchService.fetchLatestGathering { gathering in
            self.gathering = gathering
            self.dutchUnits = gathering.dutchUnits.sorted()
            print("gathering.dutchunits.count: \(gathering.dutchUnits.count)")
        }
    }
}

extension DutchpayViewModel {
    
    private func convertSpentAmount(amt: Double) -> String {
        return {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            if let intValue = amt.convertToInt() {
                return convertIntoKoreanPrice(number: Double(intValue))
            } else {
                return convertIntoKoreanPrice(number: amt)
            }
        }()
    }
    
    private func convertIntoKoreanPrice(number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.string(from: NSNumber(value:number))
        return numberFormatter.string(from: NSNumber(value: number))! + " 원"
    }
    
    private func convertPeopleIntoStr(peopleDetails: Set<PersonDetail>) -> String {
        return peopleDetails.sorted().map { $0.person!.name}.joined(separator: ", ")
    }
    
    private func convertDateIntoStr(date: Date) -> String {
        return date.getFormattedDate(format: "yyyy.MM.dd HH:mm")
    }
}


// MARK: - Extensions


struct DutchUnitCellComponents {
    var placeName: String
    var spentAmount: String
    var peopleNameList: String
    var date: String
}
