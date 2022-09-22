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
    //    var spentAmount: String { return String(personDetail.spentAmount) + " 원"}
    var spentAmount: String {
        return personDetail.spentAmount.convertToIntString()}
    
    var isAttended: Bool { return personDetail.isAttended }
    
//    var attendingBtnTitle: String { return personDetail.isAttended ? "참석" : "불참"}
//    var attendingBtnColor: UIColor { return personDetail.isAttended ? .black : .red }
    
    init(personDetail: PersonDetail) {
        self.personDetail = personDetail
    }
}


//struct Payment {
//    let name: String
//    let spentAmount: Double
//    let attended: Bool
//    let spentTo: String
//    let totalAmount: Double
//}
