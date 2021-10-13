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
    case Social
    case Communications
    
    var description: String {
        switch self {
        case .Social: return "Social"
        case .Communications: return "Communications"
        }
    }
}

enum SocialOptions: Int, CaseIterable, SectionType {
    case editProfile
    case logout
    
    var containsSwitch: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .editProfile: return "editProfile"
        case .logout: return "logout"
        }
    }
}


enum CommunicationOptions: Int, CaseIterable, SectionType {
    case notifications
    case email
    case reportCrashes
    
    var containsSwitch: Bool {
        switch self {
        case .notifications: return true
        case .email: return true
        case .reportCrashes: return false
        }
    }
    
    var description: String {
        switch self {
        case .notifications: return "notifications"
        case .email: return "email"
        case .reportCrashes: return "reportCrashes"
        }
    }
}
