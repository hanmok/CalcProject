//
//  ResultViewModel.swift
//  Calie
//
//  Created by Mac mini on 2022/08/10.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

/*
typealias OverallPersonInfo = (name: String, relativePaidAmount: Double, attendedPlaces: String)

 typealias PersonPaymentInfo = (name: String, paidAmt: Double, toPay: Double, sum: Double)
 
 */



class ResultViewModel {
    var dutchService: DutchService
    
    let currentGathering: Gathering
    init(gathering: Gathering) {
        self.dutchService = DutchService(currentGathering: gathering)
        self.currentGathering = gathering
    }
    
//    var overallPersonInfos: [OverallPersonInfo] {
//        return dutchService.createOverallInfo(gathering: currentGathering)
//    }
    
    var overallPayInfos: [PersonPaymentInfo] {
        return dutchService.createPersonPayInfos(gathering: currentGathering)
    }
}

// MARK: - 음.. 상대적 비용, 어디어디 갔었는지 보다는
// MARK: - 낸 비용, 받을 비용, 결과값 세개를 출력하는게 ...??
// Detail 한 사항 원하면 클릭 !



