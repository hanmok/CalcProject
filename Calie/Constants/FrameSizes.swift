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
    
    let showToastWidthSize : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 375,
         DeviceSize.small.rawValue : 375,
         DeviceSize.medium.rawValue : 600,
         DeviceSize.large.rawValue : 800]
    
    let showToastHeightSize : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 667,
         DeviceSize.small.rawValue : 667,
         DeviceSize.medium.rawValue : 1000,
         DeviceSize.large.rawValue : 1200]
}

// A -> smallest
// B -> small
// C -> medium
// D -> Large

//frameSize:self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375)

//frameSize:self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667)

