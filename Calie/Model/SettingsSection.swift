//
//  SettingsSection.swift
//  Caliy
//
//  Created by Mac mini on 2021/10/13.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import Foundation

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
    var containsButton: Bool { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Mode
    case Dutchpay
    case General
    
    
    var description: String {
        switch self {
            
        case .Mode: return LocalizedStringStorage().mode
        case .Dutchpay: return ASD.dutchpay.localized
        case .General: return LocalizedStringStorage().general
        }
    }
}

enum ModeOptions: Int, CaseIterable, SectionType {
    var containsButton: Bool {
        return false
    }
    
    case darkMode
    case sound
    case notification

    
    var containsSwitch: Bool {
        return true
    }
    
    var description: String {
        switch self {
        case .darkMode: return LocalizedStringStorage().darkMode

        case .sound: return LocalizedStringStorage().soundMode

        case .notification: return LocalizedStringStorage().notificationMode
        }
    }
}

enum DutchOptions: Int, CaseIterable, SectionType {
    var containsButton: Bool {
        switch self {
        case .useFloatingPoint:
            return false
        case .droppingDigit:
            return true
        case .currencyUnit:
            return true
        }
    }
    
    var description: String {
        switch self {
            
        case .useFloatingPoint:
            return "소숫점 사용"
        case .droppingDigit:
//            return "정산 시 반올림할 자릿수"
            return "정산할 자릿수"
        case .currencyUnit:
            return "통화 단위"
        }
    }
    
    case useFloatingPoint
    case droppingDigit
    case currencyUnit
    
    var containsSwitch: Bool {
        switch self {
        case .useFloatingPoint: return true
        default: return false
        }
    }
}


enum GeneralOptions: Int, CaseIterable, SectionType {
    var containsButton: Bool {
        return false
    }
    
    case rate
    case review
    
    var containsSwitch: Bool {
        switch self {
        case .rate: return false
        case .review: return false
       
        }
    }
    
    var description: String {
        switch self {

        case .rate: return LocalizedStringStorage.init().rate

        case .review: return LocalizedStringStorage.init().review
        
        }
    }
}


extension Int {
    static let droppingDigitTag = 100
    static let currencyUnitTag = 200
    
    static let floatingPointTag = 100
}
