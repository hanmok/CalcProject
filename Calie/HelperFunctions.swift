//
//  HelperFunctions.swift
//  Calie
//
//  Created by Mac mini on 2022/09/04.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation


public func printPeople(peopleArr: [Person]? = nil, peopleSet: Set<Person>? = nil ) {

    if let people = peopleArr {
        for person in people {
            print(person.name)
        }
    }
    
    if let people = peopleSet {
        for person in people {
            print(person.name)
        }
    }
}
