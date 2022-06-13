//
//  ColorExt.swift
//  
//
//  Created by 이한목 on 2022/05/05.
//

import UIKit

extension UIColor {
    
    /// background Color for Empty, and Numbers In Dark Mode
    static let bgColorForEmptyAndNumbersDM = UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha : 1)
    /// background Color for Operators In Dark Mode
    static let bgColorForOperatorsDM = UIColor(red: 0.33333, green: 0.333, blue: 0.333, alpha: 1)
    /// background Color for Extras In Dark Mode
    static let bgColorForExtrasDM = UIColor(red: 0.537, green: 0.541, blue: 0.454, alpha: 1)
    /// background Color for Empty, and Numbers In Dark Mode
    
    
    /// background Color for Empty, and Numbers In Light Mode
    static let bgColorForEmptyAndNumbersLM = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1)
    static let bgColorForOperatorsLM = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
    static let bgColorForExtrasLM = UIColor(red: 0.894, green: 0.902, blue: 0.792, alpha: 1)
    
    static let bgColorForExtrasMiddle = UIColor(red : (0.537 + 0.894)/2, green: (0.541 + 0.902)/2, blue: (0.454 + 0.792)/2, alpha: 1)
    
    
    
    // TextColor
    //    static let textColorForResultDM = UIColor(white: 0.862, alpha: 1) // 220
    static let textColorForResultDM = UIColor(white: 0.902, alpha: 1) // 220
    //    static let textColorForSemiResultDM = UIColor(white : 0.70, alpha : 0.5)
    static let textColorForSemiResultDM = UIColor(white : 0.8, alpha : 0.7)
    static let textColorForNumAndOpersDM = UIColor(white: 0.784, alpha: 1) // 200
    static let textColorForProcessDM = UIColor(white: 0.768, alpha: 1) // 196
    //    static let textColorForDateDM = UIColor(white: 0.4, alpha: 1)
    static let textColorForDateDM = UIColor(white: 0.6, alpha: 1)
    
    
    static let textColorForResultLM = UIColor(white : 1-0.862, alpha : 1)// 255 - 220
    static let textColorForSemiResultLM = UIColor(white : 1 - 0.70, alpha : 0.5) // 0.3
    static let textColorForNumAndOpersLM = UIColor(white: 1-0.784, alpha: 1) // 255 - 200, 0.22
    static let textColorForProcessLM = UIColor(white: 1-0.768, alpha: 1) // 255 - 196, 0.23
    //    static let textColorForDateLM = UIColor(white: 0.6, alpha: 1) //
    
    static let textColorForDateLM = UIColor(white: 0.4, alpha: 1) //
    
    
    static let newMainForDarkMode = UIColor(rgb: 0x9CCC65) // LightGreen 400
    static let newMainForLightMode = UIColor(rgb: 0x7CB342) // Light Green 600
    
}
