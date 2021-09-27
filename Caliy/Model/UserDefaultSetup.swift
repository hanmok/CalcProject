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
        case lightModeOn
        case notificationOn
        case everChanged
        case deviceSize
        case numOfReviewClicked
        case deviceVersion
        case deviceVersionType
    }
    
    
    func setIsSoundOn(isSoundOn : Bool){
        
        defaults.set(isSoundOn,forKey: UserDefaultKey.soundOn.rawValue)
    }
    
    func setIsLightModeOn(isLightModeOn : Bool){
        
        defaults.set(isLightModeOn,forKey: UserDefaultKey.lightModeOn.rawValue)
    }
    
    func setIsNotificationOn(isNotificationOn : Bool){
        
        defaults.set(isNotificationOn,forKey: UserDefaultKey.notificationOn.rawValue)
    }
    
    func setNumberReviewClicked(numberReviewClicked : Int){
        defaults.set(numberReviewClicked, forKey: UserDefaultKey.numOfReviewClicked.rawValue)
    }
    
    func setUserDeviceSizeInfo(userDeviceSizeInfo : String){
        defaults.set(userDeviceSizeInfo, forKey: UserDefaultKey.deviceSize.rawValue)
    }
    
    func setUserDeviceVersionInfo(userDeviceVersionInfo : String){
        defaults.set(userDeviceVersionInfo, forKey: UserDefaultKey.deviceVersion.rawValue)
    }
    func setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo : String){
        defaults.set(userDeviceVersionTypeInfo, forKey: UserDefaultKey.deviceVersionType.rawValue)
    }
    
    
    
    func getIsSoundOn() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.soundOn.rawValue)
    }
    
    func getIsLightModeOn() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.lightModeOn.rawValue)
    }
    
    func getIsNotificationOn() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.notificationOn.rawValue)
    }
    
    func getNumberReviewClicked() -> Int{
        return defaults.integer(forKey: UserDefaultKey.numOfReviewClicked.rawValue)
    }
    
    func getDeviceSize() -> String{
        return defaults.string(forKey: UserDefaultKey.deviceSize.rawValue) ?? "A"
    }
    func getDeviceVersion() -> String{
        return defaults.string(forKey: UserDefaultKey.deviceVersion.rawValue) ?? "ND"
    }
    func getDeviceVersionType() -> String{
        return defaults.string(forKey: UserDefaultKey.deviceVersionType.rawValue) ?? "What"
    }
    
    //ND stands for Not Determined.
    // MP : Most popular, P : Popular, LP : Least Popular
    
    
    func setIsUserEverChanged(isUserEverChanged : Bool){
        defaults.set(isUserEverChanged, forKey: UserDefaultKey.everChanged.rawValue)
    }
    
    func getIsUserEverChanged() -> Bool{
        return defaults.bool(forKey: UserDefaultKey.everChanged.rawValue)
    }
}
