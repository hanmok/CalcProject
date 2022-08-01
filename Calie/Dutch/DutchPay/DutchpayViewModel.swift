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
            let cellComponents = convertDutchUnits(dutchUnits: dutchUnits)
            updateDutchUnitCells(cellComponents)
        }
    }
    
    
    
    
    

    
    
    // MARK: - Actions
    var action: Actions = .none {
        didSet {
            switch action {
            case .showHistory:
                break
                
            case .resetGathering(let needGathering):
                if needGathering && gathering == nil {
                    createGathering()
                }
                resetGatheringAction()
                
            case .addDutchUnit(let needGathering):
                if needGathering && gathering == nil {
                    createGathering()
                }
                
            case .changeGatheringName(let newName):
                self.changeGatheringNameAction(newName: newName)
                
            case .calculate(let needGathering):
                if needGathering && gathering == nil {
                    createGathering()
                }
                calculateAction()
                
            case .blurredViewTapped:
                break
                
            case .viewDidLoad:
                viewDidLoadAction()
                
            case .createOne(let name):
                makeGathering(with: name)
                
            case .createIfNeeded:
                if gathering == nil {
                    createGathering()
                }
                
            case .deleteDutchUnit(let idx):
                deleteDutchUnitAction(idx: idx)
                
            case .updatePeople(updatedPeople: let updatedPeople):
                
                dutchService.updatePeople(with: updatedPeople) { gathering in
                    self.gathering = gathering
                    self.updateDutchUnits(gathering: gathering)
                }
                
            case .updateDutchUnit(let dutchUnit, let isNew):
                dutchService.updateDutchUnit(dutchUnit: dutchUnit, isNew: isNew) { gathering in
                    self.gathering = gathering
                    self.updateDutchUnits(gathering: gathering)
                }
                
            case .replaceGathering(let newGathering):
                self.gathering = newGathering
                
            case .none:
                break
            }
        }
    }
    
    
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
    
    func resetGatheringAction() {
        dutchService.resetGathering { result in
            switch result {
            case .success(let result):
                self.gathering = result
                self.dutchUnits = self.gathering!.dutchUnits.sorted()
            case .failure(let e):
                print(e.localizedDescription)
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
    
    func calculateAction() {
        
    }
    
    func blurredViewTappedAction() {
        
    }
    
    ///  Create gathering, assign
    func makeGathering(with name: String) {
        dutchService.createGathering { gathering in
            self.gathering = gathering
        }
    }
    
    func viewDidLoadAction() {
        fetchLatestGathering()
    }
    
    func fetchLatestGathering() {
        
        dutchService.updateGathering { gathering in
            self.gathering = gathering
        }
    }
    
    
    // MARK: - Actions Enum
    
    enum Actions {
        case none
        case showHistory
        case resetGathering(needGathering: Bool)
        case addDutchUnit(needGathering: Bool) // need default gathering
        case changeGatheringName(String)
        case calculate(needGathering: Bool)
        case blurredViewTapped
        case viewDidLoad
        case createIfNeeded
        case createOne(String)
        case deleteDutchUnit(idx: Int)
        
        case updatePeople(updatedPeople: [Person])
        case updateDutchUnit(dutchUnit: DutchUnit, isNew: Bool)
        case replaceGathering(with: Gathering)
    }
    
    public func setActions(to action: Actions) {
        self.action = action
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
