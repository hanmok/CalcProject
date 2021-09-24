//
//  ButtonTag.swift
//  Caliy
//
//  Created by Mac mini on 2021/07/21.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit

class ButtonTag : UIButton {
    
    init(withTag : Int) {
        super.init(frame: .zero)
        
        tag = withTag
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
