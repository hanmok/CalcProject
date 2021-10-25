//
//  Public+Extension.swift
//  Neat Calc
//
//  Created by Mac mini on 2020/07/26.
//  Copyright © 2020 hanmok. All rights reserved.
//

import Foundation
import UIKit


public extension UIDevice {
    
    static var hasNotch: Bool {
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom != 0
        }
    
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
        
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "5iPo"
            case "iPod7,1":                                 return "6iPo"
            case "iPod9,1":                                 return "7iPo"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "4iPh"
            case "iPhone4,1":                               return "4siPh"
            case "iPhone5,1", "iPhone5,2":                  return "5iPh"
            case "iPhone5,3", "iPhone5,4":                  return "5ciPh"
            case "iPhone6,1", "iPhone6,2":                  return "5siPh"
            case "iPhone7,2":                               return "6iPh"
            case "iPhone7,1":                               return "6+iPh"
            case "iPhone8,1":                               return "6siPh"
            case "iPhone8,2":                               return "6s+iPh"
            case "iPhone8,4":                               return "SEiPh"
            case "iPhone9,1", "iPhone9,3":                  return "7iPh"
            case "iPhone9,2", "iPhone9,4":                  return "7+iPh"
            case "iPhone10,1", "iPhone10,4":                return "8iPh"
            case "iPhone10,2", "iPhone10,5":                return "8+iPh"
            case "iPhone10,3", "iPhone10,6":                return "XiPh"
            case "iPhone11,2":                              return "XSiPh"
            case "iPhone11,4", "iPhone11,6":                return "XSMaxiPh"
            case "iPhone11,8":                              return "XRiPh"
            case "iPhone12,1":                              return "11iPh"
            case "iPhone12,3":                              return "11ProiPh"
            case "iPhone12,5":                              return "11ProMaxiPh"
            case "iPhone12,8":                              return "SE2iPh"
            case "iPhone13,1":                              return "12miiPh"
            case "iPhone13,2":                              return "12iPh"
            case "iPhone13,3":                              return "12ProiPh"
            case "iPhone13,4":                              return "12ProMaxiPh"
                
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            
            case "i386", "x86_64":                          return " \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            
            #endif
        }
        return mapToDevice(identifier: identifier)
    }()
}
