//
//  FontSizes.swift
//  Neat Calc
//
//  Created by Mac mini on 2020/07/25.
//  Copyright © 2020 hanmok. All rights reserved.
//

import UIKit
struct FontSizes{
    
    
    let processBasicPortrait : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 18,
         DeviceSize.small.rawValue : 18,
         DeviceSize.medium.rawValue : 27,
         DeviceSize.large.rawValue : 30]
    
    let resultBasicPortrait : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 33,
         DeviceSize.small.rawValue : 33,
         DeviceSize.medium.rawValue : 50,
         DeviceSize.large.rawValue : 55]
    
    let dateHistory : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 10,
         DeviceSize.small.rawValue : 10,
         DeviceSize.medium.rawValue : 15,
         DeviceSize.large.rawValue : 15]
    
    let processBasicLandscape : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 15,
         DeviceSize.small.rawValue : 19,
         DeviceSize.medium.rawValue : 27,
         DeviceSize.large.rawValue : 30]
    
    let resultBasicLandscape : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 18,
         DeviceSize.small.rawValue : 22,
         DeviceSize.medium.rawValue : 33,
         DeviceSize.large.rawValue : 34]
    
    let processHistoryPortrait : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 16,
         DeviceSize.small.rawValue : 16,
         DeviceSize.medium.rawValue : 27,
         DeviceSize.large.rawValue : 30]
    
    let resultHistoryPortrait : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 20,
         DeviceSize.small.rawValue : 20,
         DeviceSize.medium.rawValue : 34,
         DeviceSize.large.rawValue : 39]
    
    let processHistoryLandscape : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 16,
         DeviceSize.small.rawValue : 16,
         DeviceSize.medium.rawValue : 27,
         DeviceSize.large.rawValue : 30]
    
    let resultHistoryLandscape : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 20,
         DeviceSize.small.rawValue : 20,
         DeviceSize.medium.rawValue : 34,
         DeviceSize.large.rawValue : 39]
    
    let showToastTextSize : [String : CGFloat] =
        [DeviceSize.smallest.rawValue : 13,
         DeviceSize.small.rawValue : 13,
         DeviceSize.medium.rawValue : 20,
         DeviceSize.large.rawValue : 25]
    
}
