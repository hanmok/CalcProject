//
//  AttendingButton.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/25.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit

class AttendingButton: UIButton {
    
    var isAttending: Bool {
        willSet {
            setupLayout(using: newValue)
        }
    }
    
    private func setupLayout(using condition: Bool) {
        setTitle(condition ? "참석" : "불참", for: .normal)
        setTitleColor(condition ? .black : .red, for: .normal)
//        backgroundColor = condition ? .green : .red
    }

    init( _ attending: Bool = true, _ frame: CGRect = .zero) {
        self.isAttending = attending
        super.init(frame: frame)

        setupInitialLayout()
    }
    
    private func setupInitialLayout() {
        self.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
//        self.backgroundColor = .green
        self.layer.cornerRadius = 5
//        self.layer.borderColor = .init(gray: 0.5, alpha: 0.5)
//        self.layer.borderWidth = 1
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
