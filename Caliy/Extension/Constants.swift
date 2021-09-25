//
//  Constants.swift
//  Caliy
//
//  Created by Mac mini on 2021/07/21.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit


// MARK: - imageConstants
let transparentImage = UIImageView(image: UIImage(named: "transparent"))

let dark00 = UIImageView(image: UIImage(named: "D00opReg"))
let dark0 = UIImageView(image: UIImage(named: "D0opReg"))
let dark1 = UIImageView(image: UIImage(named: "D1opReg"))
let dark2 = UIImageView(image: UIImage(named: "D2opReg"))
let dark3 = UIImageView(image: UIImage(named: "D3opReg"))
let dark4 = UIImageView(image: UIImage(named: "D4opReg"))
let dark5 = UIImageView(image: UIImage(named: "D5opReg"))
let dark6 = UIImageView(image: UIImage(named: "D6opReg"))
let dark7 = UIImageView(image: UIImage(named: "D7opReg"))
let dark8 = UIImageView(image: UIImage(named: "D8opReg"))
let dark9 = UIImageView(image: UIImage(named: "D9opReg"))

let darkDot = UIImageView(image: UIImage(named: "DDotopReg"))
let darkClear = UIImageView(image: UIImage(named: "DClearopReg"))
let darkOpenParen = UIImageView(image: UIImage(named: "DOpenParenopReg"))
let darkCloseParen = UIImageView(image: UIImage(named: "DCloseParenopReg"))

let darkPlus = UIImageView(image: UIImage(named: "DPlusopReg"))
let darkSubtract = UIImageView(image: UIImage(named: "DSubtractopReg"))

let darkTimes = UIImageView(image: UIImage(named: "DTimesopReg"))
let darkDivide = UIImageView(image: UIImage(named: "DDivideopReg"))

let darkEqual = UIImageView(image: UIImage(named: "DEqualopReg"))



let light00 = UIImageView(image: UIImage(named: "L00opReg"))
let light0 = UIImageView(image: UIImage(named: "L0opReg"))
let light1 = UIImageView(image: UIImage(named: "L1opReg"))
let light2 = UIImageView(image: UIImage(named: "L2opReg"))
let light3 = UIImageView(image: UIImage(named: "L3opReg"))
let light4 = UIImageView(image: UIImage(named: "L4opReg"))
let light5 = UIImageView(image: UIImage(named: "L5opReg"))
let light6 = UIImageView(image: UIImage(named: "L6opReg"))
let light7 = UIImageView(image: UIImage(named: "L7opReg"))
let light8 = UIImageView(image: UIImage(named: "L8opReg"))
let light9 = UIImageView(image: UIImage(named: "L9opReg"))

let lightDot = UIImageView(image: UIImage(named: "LDotopReg"))
let lightClear = UIImageView(image: UIImage(named: "LClearopReg"))
let lightOpenParen = UIImageView(image: UIImage(named: "LOpenParenopReg"))
let lightCloseParen = UIImageView(image: UIImage(named: "LCloseParenopReg"))

let lightPlus = UIImageView(image: UIImage(named: "LPlusopReg"))
let lightSubtract = UIImageView(image: UIImage(named: "LSubtractopReg"))

let lightTimes = UIImageView(image: UIImage(named: "LTimesopReg"))
let lightDivide = UIImageView(image: UIImage(named: "LDivideopReg"))

let lightEqual = UIImageView(image: UIImage(named: "LEqualopReg"))

let ex1OnDark = UIImageView(image: #imageLiteral(resourceName: "darkmode_sound_on"))
let ex1OffDark = UIImageView(image: #imageLiteral(resourceName: "darkmode_sound_off"))

let ex3OnDark = UIImageView(image: #imageLiteral(resourceName: "darkmode_alarm_on"))
let ex3OffDark = UIImageView(image: #imageLiteral(resourceName: "darkmode_alarm_off"))

let ex1OnLight = UIImageView(image: #imageLiteral(resourceName: "whitemode_sound_on"))
let ex1OffLight = UIImageView(image: #imageLiteral(resourceName: "whitemode_sound_off"))

let ex3OnLight = UIImageView(image: #imageLiteral(resourceName: "whitemode_alarm_on"))
let ex3OffLight = UIImageView(image: #imageLiteral(resourceName: "whitemode_alarm_off"))



// MARK: - Ratio Constants

let ratio = 1.0465

let widths = [0.12, 0.12*0.6, 0.12, 0.12, 0.12*1.05, 0.12*0.98,0.12,0.12,0.12,0.12,1.9*0.12,0.2*0.12,0.13*1.05, 0.12*0.5, 0.12*0.5,0.13*1.15,0.10,0.13,0.13,0.14 ]

let heights =  [0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*1.9,0.12*0.3,0.13*1.9,0.12*2.45,0.12*2.45,0.13*1.5,0.10*1.9,0.13*1.3,0.13*0.2,0.14*0.8] // for numsAndOpers

/// button Tag
let tagToString = [1 : "1", 2 : "2", 3 : "3", 4 : "4", 5 : "5", 6 : "6", 7 : "7", 8 : "8", 9 : "9", 0 : "0", -1 : "00", -2 : ".", 11 : "Clear", 12 : "(", 13 : ")", 14 : "÷", 15 : "×", 16 : "+", 17 : "-", 18 : "=", 21 : "del", 31 : "etc1", 32 : "etc2", 33 : "etc3", 34 : "etc4" ]

// maybe.. i can chage it using generic .
// two constants ( tagToUnitSize and tagToUnitSizeString) are identical
/// size for each digits including operators and dot (.)

let tagToUnitSize : [Character : Double] =  ["1" : 0.02857142857, "2" : 0.03703703704, "3" : 0.03846153846, "4" : 0.04, "5" : 0.03846153846, "6" : 0.04, "7" : 0.03571428571, "8" : 0.04, "9" : 0.04, "0" : 0.03846153846, "," : 0.01724137931, "." : 0.01724137931, ")" : 0.02272727273, "(" : 0.02272727273, "+" : 0.04, "×" : 0.04, "÷" : 0.04, "-" : 0.02777777778, "=" : 0.02777777778]

let tagToUnitSizeString : [String : Double] =  ["1" : 0.02857142857, "2" : 0.03703703704, "3" : 0.03846153846, "4" : 0.04, "5" : 0.03846153846, "6" : 0.04, "7" : 0.03571428571, "8" : 0.04, "9" : 0.04, "0" : 0.03846153846, "," : 0.01724137931, "." : 0.01724137931, ")" : 0.02272727273, "(" : 0.02272727273, "+" : 0.04, "×" : 0.04, "÷" : 0.04, "-" : 0.02777777778, "=" : 0.02777777778]
