//
//  ColorList.swift
//  Neat Calc
//
//  Created by hanmok on 2020/05/20.
//  Copyright © 2020 hanmok. All rights reserved.
//

import UIKit

// better implement uisng Extension Color
struct ColorList{
    
    // BackgroundColor
    
    /// background Color for Empty, and Numbers In Dark Mode
    let bgColorForEmptyAndNumbersDM = UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha : 1)
    /// background Color for Operators In Dark Mode
    let bgColorForOperatorsDM = UIColor(red: 0.33333, green: 0.333, blue: 0.333, alpha: 1)
    /// background Color for Extras In Dark Mode
    let bgColorForExtrasDM = UIColor(red: 0.537, green: 0.541, blue: 0.454, alpha: 1)
    /// background Color for Empty, and Numbers In Dark Mode
    
    
    /// background Color for Empty, and Numbers In Light Mode
    let bgColorForEmptyAndNumbersLM = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1)
    let bgColorForOperatorsLM = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
    let bgColorForExtrasLM = UIColor(red: 0.894, green: 0.902, blue: 0.792, alpha: 1)
    
    let bgColorForExtrasMiddle = UIColor(red : (0.537 + 0.894)/2, green: (0.541 + 0.902)/2, blue: (0.454 + 0.792)/2, alpha: 1)
    
    
    
    // TextColor
    //    let textColorForResultDM = UIColor(white: 0.862, alpha: 1) // 220
    let textColorForResultDM = UIColor(white: 0.902, alpha: 1) // 220
    //    let textColorForSemiResultDM = UIColor(white : 0.70, alpha : 0.5)
    let textColorForSemiResultDM = UIColor(white : 0.8, alpha : 0.7)
    let textColorForNumAndOpersDM = UIColor(white: 0.784, alpha: 1) // 200
    let textColorForProcessDM = UIColor(white: 0.768, alpha: 1) // 196
    //    let textColorForDateDM = UIColor(white: 0.4, alpha: 1)
    let textColorForDateDM = UIColor(white: 0.6, alpha: 1)
    
    
    let textColorForResultLM = UIColor(white : 1-0.862, alpha : 1)// 255 - 220
    let textColorForSemiResultLM = UIColor(white : 1 - 0.70, alpha : 0.5) // 0.3
    let textColorForNumAndOpersLM = UIColor(white: 1-0.784, alpha: 1) // 255 - 200, 0.22
    let textColorForProcessLM = UIColor(white: 1-0.768, alpha: 1) // 255 - 196, 0.23
    //    let textColorForDateLM = UIColor(white: 0.6, alpha: 1) //
    
    let textColorForDateLM = UIColor(white: 0.4, alpha: 1) //
    
    
    let newMainForDarkMode = UIColor(rgb: 0x9CCC65) // LightGreen 400
    let newMainForLightMode = UIColor(rgb: 0x7CB342) // Light Green 600
    
    
    /*
    let testColors: [UIColor] = [
        //        UIColor(rgb: 0x2E7D32), // Green 800 // 너무 진함 나쁘진 않아.
        //        UIColor(red: 0.85, green: 0.85, blue: 0.7, alpha: 1),
        //         UIColor(red: 0.894, green: 0.902, blue: 0.792, alpha: 1),
        //        UIColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1), // switch Color 너무 진한데 ?
        UIColor(rgb: 0x388E3C), // Green 700, 다크모드용 ? 아님. Light 로는 ㄱㅊ?
        UIColor(rgb: 0x81C784), // Green 300, 좀더 예쁜 에메랄드 색. 다크모드일때 색이 안맞음.
        UIColor(rgb: 0x66BB6A), // Green 400 // 에메랄드 색깔. 약간 애매..
        UIColor(rgb: 0x43A047), // Green 600 // 너무 선명함
        UIColor(rgb: 0x689F38), //  Light Green 700 look fine
        UIColor(rgb: 0x7CB342), //  Light Green 600
        UIColor(rgb: 0x558B2F), //  Light Green 800, not bad
        UIColor(rgb: 0x9CCC65) //  Light Green 400, too bright
        
    ]
    
    
    
    let testColors2: [ColorTest] = [
        
        ColorTest(color: UIColor(red: 0.537, green: 0.541, blue: 0.454, alpha: 1), desc: "Dark MainColor"),
        ColorTest(color: UIColor(red: 0.894, green: 0.902, blue: 0.792, alpha: 1), desc: "Light MainColor"),
        // Green
        ColorTest(color: UIColor(rgb: 0xE8F5E9), desc: "Green50"),
        ColorTest(color: UIColor(rgb: 0xC8E6C9), desc: "Green100"),
        ColorTest(color: UIColor(rgb: 0xA5D6A7), desc: "Green200"),
        ColorTest(color: UIColor(rgb: 0x81C784), desc: "Green300"),
        ColorTest(color: UIColor(rgb: 0x66BB6A), desc: "Green400"),
        ColorTest(color: UIColor(rgb: 0x4CAF50), desc: "Green500"),
        ColorTest(color: UIColor(rgb: 0x43A047), desc: "Green600"),
        ColorTest(color: UIColor(rgb: 0x388E3C), desc: "Green700"),
        ColorTest(color: UIColor(rgb: 0x2E7D32), desc: "Green800"),
        ColorTest(color: UIColor(rgb: 0x1B5E20), desc: "Green900"),
        ColorTest(color: UIColor(rgb: 0xB9F6Ca), desc: "GreenA100"),
        ColorTest(color: UIColor(rgb: 0x69F0AE), desc: "GreenA200"),
        ColorTest(color: UIColor(rgb: 0x00E676), desc: "GreenA400"),
        ColorTest(color: UIColor(rgb: 0x00C853), desc: "GreenA700"),
        
        // Light Green
        ColorTest(color: UIColor(rgb: 0xF1F8E9), desc: "LightGreen 50"),
        ColorTest(color: UIColor(rgb: 0xDCEDC8), desc: "LightGreen 100"),
        ColorTest(color: UIColor(rgb: 0xC5E1A5), desc: "LightGreen 200"),
        ColorTest(color: UIColor(rgb: 0xAED581), desc: "LightGreen 300"),
        ColorTest(color: UIColor(rgb: 0x9CCC65), desc: "LightGreen 400"), // my choice for dark mode
        ColorTest(color: UIColor(rgb: 0x8BC34A), desc: "LightGreen 500"),
        ColorTest(color: UIColor(rgb: 0x7CB342), desc: "LightGreen 600"), // recommended for light version.
        ColorTest(color: UIColor(rgb: 0x689F38), desc: "LightGreen 700"),
        ColorTest(color: UIColor(rgb: 0x558B2F), desc: "LightGreen 800"),
        ColorTest(color: UIColor(rgb: 0x33691E), desc: "LightGreen 900"),
        ColorTest(color: UIColor(rgb: 0xCCFF90), desc: "LightGreen A100"),
        ColorTest(color: UIColor(rgb: 0xB2FF59), desc: "LightGreen A200"),
        ColorTest(color: UIColor(rgb: 0x76FF03), desc: "LightGreen A300"),
        ColorTest(color: UIColor(rgb: 0x64DD17), desc: "LightGreen A400")
    ]
    */

    
    
    
}

struct ColorTest {
    let color: UIColor
    let desc: String
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}


