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
    let dutchService = DutchManager()
    
    init(selectedDutchUnit: DutchUnit?, gathering: Gathering) {
        self.selectedDutchUnit = selectedDutchUnit
        self.gathering = gathering
    }
}
