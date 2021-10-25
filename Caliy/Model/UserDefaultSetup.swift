//
//  UserDefaultSetup.swift
//  Neat Calc
//
//  Created by hanmok on 2020/05/21.
//  Copyright © 2020 hanmok. All rights reserved.
//

import Foundation
struct UserDefaultSetup{
    
    let defaults = UserDefaults.standard
    
    enum UserDefaultKey : String{
        case soundOn
        case darkModeOn
        case notificationOn
        case everChanged
        case deviceSize
        case deviceVersion
//        case deviceVersionType
    }
    
    // MARK: - Set
    
    func setSoundMode(isSoundOn : Bool){
        
        defaults.set(isSoundOn,forKey: UserDefaultKey.soundOn.rawValue)
    }
    
    func setDarkMode(isDarkMode : Bool){
        
        defaults.set(isDarkMode,forKey: UserDefaultKey.darkModeOn.rawValue)
    }
    
    func setNotificationMode(isNotificationOn : Bool){
        
        defaults.set(isNotificationOn,forKey: UserDefaultKey.notificationOn.rawValue)
    }
    
    func setDeviceSize(size : String){
        defaults.set(size, forKey: UserDefaultKey.deviceSize.rawValue)
    }
    
    func setDeviceVersion(userDeviceVersionInfo : String){
        defaults.set(userDeviceVersionInfo, forKey: UserDefaultKey.deviceVersion.rawValue)
    }
    
//    func setDeviceVersionType(userDeviceVersionTypeInfo : String){
//        defaults.set(userDeviceVersionTypeInfo, forKey: UserDefaultKey.deviceVersionType.rawValue)
//    }
    
    
    func setHasEverChanged(hasEverChanged : Bool){
        defaults.set(hasEverChanged, forKey: UserDefaultKey.everChanged.rawValue)
    }
    
    
    
    // MARK: - Get
    func getSoundMode() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.soundOn.rawValue)
    }
    
    func getDarkMode() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.darkModeOn.rawValue)
    }
    
    func getNotificationMode() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.notificationOn.rawValue)
    }
    
    func getDeviceSize() -> String{
        return defaults.string(forKey: UserDefaultKey.deviceSize.rawValue) ?? DeviceSize.smallest.rawValue
    }
    // version -> versionTypeInfo
    func getDeviceVersion() -> String{
        return defaults.string(forKey: UserDefaultKey.deviceVersion.rawValue) ?? "iPhone"
    }
    /// used at adjusting infoview's height in historyVC
//    func getDeviceVersionType() -> String{
//        return defaults.string(forKey: UserDefaultKey.deviceVersionType.rawValue) ?? DeviceVersionType.recentPhones.rawValue
//    }
    
    func getHasEverChanged() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.everChanged.rawValue)
    }
}



enum DeviceSize: String {
    case smallest
    case small
    case medium
    case large
}

// why iPads are not contained ??
//enum DeviceVersionType: String {
//    case oldPhones
//    case recentPhones
//    case iPod
//}
