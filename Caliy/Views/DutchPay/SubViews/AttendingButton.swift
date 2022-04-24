//
//  AttendingButton.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/25.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit

class AttendingButton: UIButton {
    
    var attending: Bool

    init( _ attending: Bool = true, _ frame: CGRect = .zero) {
        self.attending = attending
        super.init(frame: frame)
        loadView()
    }
    
    private func loadView() {
        let title = attending ? "참석" : "불참"
        
        self.setTitle(title, for: .normal)
        self.backgroundColor = .brown
        self.layer.cornerRadius = 5
        self.layer.borderColor = .init(gray: 0.5, alpha: 0.5)
        self.layer.borderWidth = 1
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

