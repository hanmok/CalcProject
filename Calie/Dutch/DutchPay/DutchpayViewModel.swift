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
    
    var userDefaultSetup = UserDefaultSetup()
    
    // MARK: - Actions when Observed Properties changed.
    
    var updateDutchUnitCellsHandler: ([DutchUnitCellComponents]) -> Void = { _ in}
    
    var updateGatheringHandler: (GatheringInfo) -> Void = { _ in }
    
    var updateDutchUnitsHandler: () -> Void = { }
    
    // MARK: - Properties To be Observed
    
    var gathering: Gathering? = nil {
        didSet {
            guard let gathering = gathering else { return }
            
            dutchService.currentGathering = gathering
            
            let gatheringInfo = GatheringInfo(title: gathering.title, totalPrice: gathering.totalCostStr)

            updateGatheringHandler(gatheringInfo)
            
            updateDutchUnits2(gathering: gathering)
            
        }
    }
    
    var dutchUnits: [DutchUnit] = [] {
        didSet {
            
            updateDutchUnitsHandler()
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
    
    func updateDutchUnits2(gathering: Gathering) {
        self.dutchUnits = gathering.dutchUnits.sorted()
    }
    
    func deleteDutchUnitAction(idx: Int) {
        dutchService.deleteDutchUnit(idx: idx) { gathering in
            self.gathering = gathering
        }
    }
    
    /// create `Gathering n`
    private func createGathering(completion: @escaping (Gathering) -> Void) {
        dutchService.createGathering { gathering in
//            return gathering
        completion(gathering)
//            self.gathering = gathering
        }
    }
    
    func showHistoryAction() {
        
    }
    
    func addDutchUnit(needGathering: Bool) {
        if needGathering && gathering == nil {
//            createGathering()
            createGathering { gathering in
                self.gathering = gathering
            }
        }
    }
    
    func resetGatheringAction(needGathering: Bool, completion: @escaping (Void) -> Void ) {
        
        if needGathering && gathering == nil {
            createGathering { gathering in
                self.gathering = gathering
            }
        }
        
        dutchService.currentGathering = gathering
        
        // 인원 초기화에 문제가 있음.
        dutchService.resetGathering { newGathering in
                self.gathering = newGathering
                self.dutchUnits = self.gathering!.dutchUnits.sorted()
            
                completion(())
        }
    }
    
    func addDutchUnitAction() {
        
    }
    
    // 이게 호출되지 않음. 왜 ?
    func changeGatheringNameAction(newName: String) {
        print("gatheringName flag 6")
        dutchService.changeGatheringName(to: newName) { gathering in
            self.gathering = gathering
        print("gatheringName has changed to \(newName)")
        }
        
    }
    
    func calculateAction(needGathering: Bool) {
        if needGathering && gathering == nil {
            createGathering { gathering in
                self.gathering = gathering
            }
        }
        // TODO: Calculate! ?? 
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
            createGathering { gathering in
                self.gathering = gathering
            }
        }
    }
    func updateDutchUnit(dutchUnit: DutchUnit, isNew: Bool) {
        dutchService.updateDutchUnit(dutchUnit: dutchUnit, isNew: isNew) { gathering in
            self.gathering = gathering
            self.updateDutchUnits2(gathering: gathering)
        }
    }
    
    func replaceGathering(newGathering: Gathering) {
        self.gathering = newGathering
    }
    
    func updatePeople(updatedPeople: [Person]) {
        dutchService.updatePeople(with: updatedPeople) { gathering in
            self.gathering = gathering
            self.updateDutchUnits2(gathering: gathering)
        }
    }
    
    func viewDidLoadAction() {
//        fetchLastUsedGathering()
        fetchLatestGathering()
    
    }
    
//    func fetchLastUsedGathering() {
        
//        let lastUsedId = userDefaultSetup.workingGatheringId
//        dutchService.fetchLastUsedGathering(lastUsedGatheringId: lastUsedId) { gathering in
//            self.gathering = gathering
//        }
//    }
    
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
