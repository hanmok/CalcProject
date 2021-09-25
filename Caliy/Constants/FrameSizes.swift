//
//  FrameSizes.swift
//  Caliy
//
//  Created by Mac mini on 2020/07/31.
//  Copyright © 2020 Mac mini. All rights reserved.
//
import UIKit
import Foundation

struct FrameSizes{
    
    let showToastWidthSize : [String : CGFloat] = ["A" : 375, "B" : 375, "C" : 600, "D" : 800]
    
    let showToastHeightSize : [String : CGFloat] = ["A" : 667, "B" : 667, "C" : 1000, "D" : 1200]
}


//frameSize:self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375)

//frameSize:self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667)

