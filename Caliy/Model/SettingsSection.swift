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
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Mode
    case General
    
    var description: String {
        switch self {
//        case .Mode: return "Mode"
//        case .General: return "General"
        case .Mode: return LocalizedStringStorage.init().mode
        case .General: return LocalizedStringStorage.init().general
        
        }
    }
}

enum ModeOptions: Int, CaseIterable, SectionType {
    case darkMode
    case sound
    case notification
//    case changingOrientation
    
    var containsSwitch: Bool {
        return true
    }
    
    var description: String {
        switch self {
        case .darkMode: return LocalizedStringStorage.init().darkMode
//        case .darkMode: return LocalizedString
//        case .sound: return "SoundMode"
        case .sound: return LocalizedStringStorage.init().soundMode
//        case .notification: return "Notification"
        case .notification: return LocalizedStringStorage.init().notificationMode
//        case .changingOrientation: return "changingOrientation"
        }
    }
}


enum GeneralOptions: Int, CaseIterable, SectionType {
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
//        case .rate: return "Rate"
        case .rate: return LocalizedStringStorage.init().rate
//        case .review: return "Review"
        case .review: return LocalizedStringStorage.init().review
        
        }
    }
}
