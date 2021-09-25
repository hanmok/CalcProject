//
//  ColorList.swift
//  Neat Calc
//
//  Created by hanmok on 2020/05/20.
//  Copyright © 2020 hanmok. All rights reserved.
//

import UIKit

struct ColorList{
    let bgColorForEmptyAndNumbersDM = UIColor(red: 0.24706, green: 0.24706, blue: 0.24706, alpha : 1)
    let bgColorForOperatorsDM = UIColor(red: 0.33333, green: 0.33333, blue: 0.33333, alpha: 1)
    let bgColorForExtrasDM = UIColor(red: 0.537254902, green: 0.5411764706, blue: 0.4549019608, alpha: 1)
    let bgColorForExtrasDMAlpha = UIColor(red: 0.537254902, green: 0.5411764706, blue: 0.4549019608, alpha: 0.8)
    
    let bgColorForEmptyAndNumbersBM = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1)
    let bgColorForOperatorsBM = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
    let bgColorForExtrasBM = UIColor(red: 0.894, green: 0.902, blue: 0.792, alpha: 1)
    let bgColorForExtrasBMAlpha = UIColor(red: 0.894, green: 0.902, blue: 0.792, alpha: 0.8)
    
    let bgColorForExtrasMiddle = UIColor(red : (0.537254902 + 0.894)/2, green: (0.5411764706 + 0.902)/2, blue: (0.4549019608 + 0.792)/2, alpha: 1)
    
    let textColorForResultDM = UIColor(white: 0.86274, alpha: 1) // 220
    let textColorForSemiResultDM = UIColor(white : 0.70, alpha : 0.5)
    let textColorForNumAndOpersDM = UIColor(white: 0.78431, alpha: 1) // 200
    let textColorForProcessDM = UIColor(white: 0.76863, alpha: 1) // 196
    let textColorForDateDM = UIColor(white: 0.4, alpha: 1)
    
    
    let textColorForResultBM = UIColor(white : 1-0.86274, alpha : 1)// 255 - 220
    let textColorForSemiResultBM = UIColor(white : 1 - 0.70, alpha : 0.5)
    let textColorForNumAndOpersBM = UIColor(white: 1-0.78431, alpha: 1) // 255 - 200
    let textColorForProcessBM = UIColor(white: 1-0.76853, alpha: 1) // 255 - 196
    let textColorForDateBM = UIColor(white: 0.6, alpha: 1)
    
    
    let bgColorForExtrasBMAndEmpty = UIColor(red: (0.988+0.894)/2, green: (0.988+0.902)/2, blue: (0.988+0.792)/2, alpha: 1)
    let bgColorForExtrasDMAndEmpty = UIColor(red :(0.24706+0.537254902)/2, green: (0.24706+0.5411764706)/2, blue: (0.24706+0.4549019608)/2, alpha: 1 )
}
