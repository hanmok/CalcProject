//
//  SideViewModel.swift
//  Calie
//
//  Created by 핏투비 on 2022/08/08.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

class SideViewModel {
    
//    var currentGathering: Gathering
    
    var dutchService: DutchService
    
    var allGatherings: [Gathering] = []
    
    var updateGatherings: () -> Void = { }
    
    init() {
//    init(currentGathering: Gathering) {
//        self.currentGathering = currentGathering // 음.. 표시를 해주는게 좋을 것 같은데..
        self.dutchService = DutchService() // current Gathering 은 필요 없을 것 같은데.. ??
    }
    
    //
    
    
    func fetchAllGatherings() {
        dutchService.fetchAllGatherings { fetchedGatherings in
            self.allGatherings = fetchedGatherings
        }
    }

    func removeGathering(target: Gathering, completion: @escaping () -> Void) {
        dutchService.removeGathering(target: target) { result in
            switch result {
                
            case .success(let updatedGatherings):
                self.allGatherings = updatedGatherings
                completion()
            case .failure(_):
                // FIXME: called when
                fatalError("failed to remove gathering")
            }
        }
    }
    
    func addGathering(completion: @escaping (Gathering) -> Void) {
        print("sideViewModel addGathering called")
        dutchService.createGathering { gathering in
            print("side flag 2")
            self.allGatherings.append(gathering)
            completion(gathering)
        }
    }
    
    func changeGatheringNameAction(newName: String, target: Gathering, completion: @escaping () -> Void ) {
        print("gatheringName flag 6")
        dutchService.changeGatheringName(to: newName, target: target) {
            completion()
        }
//        dutchService.changeGatheringName(to: newName) { gathering in
//            self.gathering = gathering
        print("gatheringName has changed to \(newName)")
        }
}
