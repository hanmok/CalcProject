//
//  ColorExt+.swift
//  Calie
//
//  Created by Mac mini on 2022/05/07.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit



extension UIColor {
    
    /// background Color for Empty, and Numbers In Dark Mode
    static let emptyAndNumbersBGDark = UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha : 1)
    /// background Color for Operators In Dark Mode
    static let operatorsBGDark = UIColor(red: 0.33333, green: 0.333, blue: 0.333, alpha: 1)
    /// background Color for Extras In Dark Mode
    static let extrasBGDark = UIColor(red: 0.537, green: 0.541, blue: 0.454, alpha: 1)
    /// background Color for Empty, and Numbers In Dark Mode
    
    
    /// background Color for Empty, and Numbers In Light Mode
    static let emptyAndNumbersBGLight = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1)
    static let operatorsBGLight = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
    static let extrasBGLight = UIColor(red: 0.894, green: 0.902, blue: 0.792, alpha: 1)
    
    
    static let extrasBGMiddle = UIColor(red : (0.537 + 0.894)/2, green: (0.541 + 0.902)/2, blue: (0.454 + 0.792)/2, alpha: 1)
    
    
    
    // TextColor
    static let resultTextDM = UIColor(white: 0.902, alpha: 1) // 220
    static let semiResultTextDM = UIColor(white : 0.8, alpha : 0.7)
    static let numAndOpersTextDM = UIColor(white: 0.784, alpha: 1) // 200
    static let processTextDM = UIColor(white: 0.768, alpha: 1) // 196
    static let dateTextDM = UIColor(white: 0.6, alpha: 1)
    
    
    static let resultTextLM = UIColor(white : 0.138, alpha : 1)// 255 - 220
    static let semiResultTextLM = UIColor(white : 0.30, alpha : 0.5) // 0.3
    static let numAndOpersTextLM = UIColor(white: 0.216, alpha: 1) // 255 - 200, 0.22
    static let processTextLM = UIColor(white: 0.232, alpha: 1) // 255 - 196, 0.23
    static let dateTextLM = UIColor(white: 0.4, alpha: 1) // ?? 이거 너무 잘보이는거 아냐?
    
    
//    static let newMainForDarkMode = UIColor(rgb: 0x9CCC65) // LightGreen 400
//    static let newMainForLightMode = UIColor(rgb: 0x7CB342) // Light Green 600
    
}
