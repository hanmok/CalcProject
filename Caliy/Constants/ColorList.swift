//
//  ColorList.swift
//  Neat Calc
//
//  Created by hanmok on 2020/05/20.
//  Copyright © 2020 hanmok. All rights reserved.
//

import UIKit

struct ColorList{
    
    // BackgroundColor
    
    /// background Color for Empty, and Numbers In Dark Mode
    let bgColorForEmptyAndNumbersDM = UIColor(red: 0.24706, green: 0.24706, blue: 0.24706, alpha : 1)
    /// background Color for Operators In Dark Mode
    let bgColorForOperatorsDM = UIColor(red: 0.33333, green: 0.33333, blue: 0.33333, alpha: 1)
    /// background Color for Extras In Dark Mode
    let bgColorForExtrasDM = UIColor(red: 0.537254902, green: 0.5411764706, blue: 0.4549019608, alpha: 1)
    /// background Color for Empty, and Numbers In Dark Mode
   
    
    /// background Color for Empty, and Numbers In Light Mode
    let bgColorForEmptyAndNumbersLM = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1)
    let bgColorForOperatorsLM = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
    let bgColorForExtrasLM = UIColor(red: 0.894, green: 0.902, blue: 0.792, alpha: 1)
    
    let bgColorForExtrasMiddle = UIColor(red : (0.537254902 + 0.894)/2, green: (0.5411764706 + 0.902)/2, blue: (0.4549019608 + 0.792)/2, alpha: 1)
    
    
    
    // TextColor
    let textColorForResultDM = UIColor(white: 0.86274, alpha: 1) // 220
    let textColorForSemiResultDM = UIColor(white : 0.70, alpha : 0.5)
    let textColorForNumAndOpersDM = UIColor(white: 0.78431, alpha: 1) // 200
    let textColorForProcessDM = UIColor(white: 0.76863, alpha: 1) // 196
    let textColorForDateDM = UIColor(white: 0.4, alpha: 1)
    
    
    let textColorForResultLM = UIColor(white : 1-0.86274, alpha : 1)// 255 - 220
    let textColorForSemiResultLM = UIColor(white : 1 - 0.70, alpha : 0.5)
    let textColorForNumAndOpersLM = UIColor(white: 1-0.78431, alpha: 1) // 255 - 200
    let textColorForProcessLM = UIColor(white: 1-0.76853, alpha: 1) // 255 - 196
    let textColorForDateLM = UIColor(white: 0.6, alpha: 1)
    
}
