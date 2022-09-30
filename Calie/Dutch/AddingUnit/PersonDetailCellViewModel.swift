//
//  PersonDetailViewModel.swift
//  Calie
//
//  Created by Mac mini on 2022/05/03.
//  Copyright © 2022 Mac mini. All rights reserved.
//


import UIKit


struct PersonDetailCellViewModel {
    private let personDetail: PersonDetail
    
    var name: String { return personDetail.person!.name }
    
    var spentAmount: String {
        return personDetail.spentAmount.convertToIntString()}
    
//    var isAttended: Bool { return personDetail.isAttended }
    var isAttended: Bool {
        get {
            return personDetail.isAttended
        }
        set {
            
        }
    }

    init(personDetail: PersonDetail) {
        self.personDetail = personDetail
    }
    
    mutating func toggleIsAttended() {
        self.isAttended = !isAttended
    }
}


//struct Payment {
//    let name: String
//    let spentAmount: Double
//    let attended: Bool
//    let spentTo: String
//    let totalAmount: Double
//}
