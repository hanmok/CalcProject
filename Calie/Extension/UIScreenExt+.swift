//
//  UIScreenExt+.swift
//  Calie
//
//  Created by 이한목 on 2022/05/05.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit

extension UIScreen {
    
    static let screenRect = UIScreen.main.bounds

    static let width = UIScreen.main.bounds.size.width

    static let height = UIScreen.main.bounds.size.height
}


extension UIViewController {
    public var screenWidth: CGFloat {
        return UIScreen.width
    }
    
    public var screenHeight: CGFloat {
        return UIScreen.height
    }
}
