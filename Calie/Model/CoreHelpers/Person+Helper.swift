//
//  Person+Helper.swift
//  Calie
//
//  Created by 핏투비 on 2022/05/31.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import CoreData

extension Person {
    
    var name: String {
        get {
            return self.name_ ?? "가나다라마바사아자차카타파하"
        }
        set {
            self.name_ = newValue
        }
    }
    
    public var order: Int64 {
        get {
            return self.order_
        }
        set {
            self.order_ = newValue
        }
    }
    
    public var id: UUID {
        get {
            if let validId = self.id_ {
                return validId
            } else {
                let newId = UUID()
                self.id_ = newId
                return self.id_!
            }
        }
        set {
            self.id_ = newValue
        }
    }
}


extension Person: Comparable {
    public static func < (lhs: Person, rhs: Person) -> Bool {
        return lhs.order < rhs.order
//        return lhs.name < rhs.name
    }
}



// 사람 구별은 id 로..
extension Person {
    public static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
}
