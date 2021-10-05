//
//  HistoryRecord.swift
//  Neat Calc
//
//  Created by hanmok on 2020/05/20.
//  Copyright © 2020 hanmok. All rights reserved.
//

// migration error solution
//https://www.selmanalpdundar.com/solution-of-realm-migration-error-code-10.html
//  https://www.youtube.com/watch?v=hC6dLLbfUXc
import Foundation
import RealmSwift

@objcMembers class HistoryRecord : Object {
    dynamic var processOrigin : String?
    dynamic var processStringHis : String?
    dynamic var processStringHisLong : String?
    dynamic var processStringCalc : String?
    dynamic var resultString : String?
    dynamic var resultValue : Double?
    dynamic var dateString : String?
    dynamic var titleLabel: String? = ""
    
    convenience init(processOrigin : String?, processStringHis : String?,processStringHisLong : String?, processStringCalc : String?, resultString : String?, resultValue : Double?, dateString : String?){
        self.init()
        self.processOrigin = processOrigin
        self.processStringHis = processStringHis
        self.processStringHisLong = processStringHisLong
        self.processStringCalc = processStringCalc
        self.resultString = resultString
        self.resultValue = resultValue
        self.dateString = dateString
        
    }
    
}
