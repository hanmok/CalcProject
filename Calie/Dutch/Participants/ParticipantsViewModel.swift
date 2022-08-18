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
    
//    public func updatePeople() {
//
//        dutchService.updatePeople(with: participants) { _ in }
//        dutchService.update()
//    }
    
    func addPerson(name: String, needDuplicateCheck: Bool = false, completion: (Result<Void, DutchError>) -> Void ) {
        
        if needDuplicateCheck {
            if participants.map({ $0.name }).contains(name) {
                completion(.failure(.duplicateName))
                return
            }
        }
        
        // MARK: - It works !! ㅠㅠ...
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
    
    public func removePerson(idx: Int, completion: @escaping () -> Void ) {
//        let targetPerson = participants[idx]
        participants.remove(at: idx)
        completion()
    }
}
