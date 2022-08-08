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

    func removeGathering(target: Gathering) {
        dutchService.removeGathering(target: target) { result in
            switch result {
                
            case .success(let updatedGatherings):
                self.allGatherings = updatedGatherings
            case .failure(_):
                fatalError("failed to remove gathering")
            }
        }
    }
}
