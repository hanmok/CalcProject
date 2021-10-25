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
        case .Mode: return "Mode"
        case .General: return "General"
        
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
        case .darkMode: return "DarkMode"
        case .sound: return "SoundMode"
        case .notification: return "Notification"
//        case .changingOrientation: return "changingOrientation"
        }
    }
}


enum GeneralOptions: Int, CaseIterable, SectionType {
    case rate
    case feedback
    
    var containsSwitch: Bool {
        switch self {
        case .rate: return false
        case .feedback: return false
       
        }
    }
    
    var description: String {
        switch self {
        case .rate: return "Rate"
        case .feedback: return "Feedback"
        
        }
    }
}
