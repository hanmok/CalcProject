//
//  Group.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/28.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

struct Group2 {
    let people: [Person2]
        let title: String
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


struct Payment {
    let name: String
    let spentAmount: Double
    let attended: Bool
    let spentTo: String
    let totalAmount: Double
}
