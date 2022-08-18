//
//  DutchUnit+Helper.swift
//  Calie
//
//  Created by Mac mini on 2022/06/02.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import CoreData
extension DutchUnit {
    
    public var id: UUID {
        get {
            if let validId = self.id_ {
                return validId
            } else {
                self.id_ = UUID()
                return self.id_!
            }
        }
        set {
            self.id_ = UUID()
        }
    }
    
    public var isAmountEqual: Bool {
        get {
            return self.isAmountEqual_
        }
        set {
            self.isAmountEqual_ = newValue
        }
    }
    
    var personDetails: Set<PersonDetail> {
        get {
            self.personDetails_ as? Set<PersonDetail> ?? []
        }
        set {
            self.personDetails_ = newValue as NSSet
        }
    }
    
    var placeName: String {
        get {
            return self.placeName_ ?? "default place"
        }
        set {
            self.placeName_ = newValue
        }
    }
    
    var spentDate: Date {
        get {
            return self.spentDate_ ?? Date()
        }
        set {
            self.spentDate_ = newValue
        }
    }
}

extension DutchUnit: RemovableProtocol {}


extension DutchUnit: Comparable {
    public static func < (lhs: DutchUnit, rhs: DutchUnit) -> Bool {
        if lhs.spentDate != rhs.spentDate {
            return lhs.spentDate < rhs.spentDate
        } else {
            return lhs.placeName < rhs.placeName
        }
    }
}

