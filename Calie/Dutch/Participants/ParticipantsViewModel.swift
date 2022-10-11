//
//  ParticipantsViewModel.swift
//  Calie
//
//  Created by Mac mini on 2022/08/08.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

// MARK: - Update Change Only when ConfirmBtn Tapped!!


class ParticipantsViewModel {

    var gathering: Gathering
    var dutchService: DutchService
    
    var initialParticipants: [Person]
    
    var participants: [Person] {
        willSet {
            updateParticipants()
        }
    }
    
    var updateParticipants: () -> Void = { }
    
    init(gathering: Gathering) {
        self.gathering = gathering
        self.initialParticipants = gathering.sortedPeople
        self.participants = gathering.sortedPeople
        self.dutchService = DutchService(currentGathering: gathering)
    }
    
    func makeGatheringLatest() {
        dutchService.updateDate(gathering: gathering)
    }
    
    func addPerson(name: String, needDuplicateCheck: Bool = false, completion: (Result<Void, DutchError>) -> Void ) {
        
        if needDuplicateCheck {
            if participants.map({ $0.name }).contains(name) {
                completion(.failure(.duplicateName))
                return
            }
        }
        
        dutchService.addPerson(name: name) { [weak self] newPerson in
            guard let self = self else { return }
            self.participants.append(newPerson)
        }
        
        completion(.success(()))
    }
    
    public func swapPersonOrder(of sourceIdx: Int, with destinationIdx: Int  ) {
        
        let person1 = participants[sourceIdx]
        let person2 = participants[destinationIdx]
        
        dutchService.swapPersonOrder(person1: person1, person2: person2) {
            self.participants.swapAt(sourceIdx, destinationIdx)
        }
    }
    
    public func removePerson(idx: Int, completion: @escaping (Bool) -> Void ) {
        let targetPerson = participants[idx]
        dutchService.removePerson(person: targetPerson) { success in
            if success {
                self.participants.remove(at: idx)
                completion(success)
            } else {
                completion(false)
            }
        }
    }
    
    public func editPersonName(target: Person, newName: String, completion: @escaping (Bool) -> Void) {
        if newName == "" {
            completion(false)
        } else {
            dutchService.changePersonName(target: target, newName: newName) { success in
                self.participants = gathering.sortedPeople
                completion(success)
            }
        }
    }
}
