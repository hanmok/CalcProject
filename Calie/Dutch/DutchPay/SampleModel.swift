//
//  Group.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/28.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation


struct Payment2 {
    let name: String
    let spentAmount: Double
    let attended: Bool
    let spentTo: String
    let totalAmount: Double
}



struct Person2 {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    init(name: String) {
        self.name = name
    }
}

struct Group2 {
    let people: [Person2]
    let title: String
}

struct PersonDetail2 {
    var person: Person2
    var spentAmount: Double = 0
    var isAttended: Bool = true
}







struct Gathering2 {
    let title: String
    var totalCost: Double
    var dutchUnits: [DutchUnit2]
    let people: [Person2]
}


struct DutchUnit2 {
    var placeName: String
    var spentAmount: Double
    var date: Date = Date()
    var personDetails: [PersonDetail2]
}


extension String {
    static let jiwon = "jiwon"
    static let hanmok = "hanmok"
    static let dog = "dog"
}
