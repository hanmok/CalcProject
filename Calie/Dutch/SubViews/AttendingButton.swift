//
//  AttendingButton.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/25.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit

class AttendingButton: UIButton {
    
    // toggle when btn tapped
    var isAttending: Bool {
        willSet {
            markAttendedState(using: newValue)
        }
    }
    
    private let innerImageView = UIImageView()
    
    public func markAttendedState(using condition: Bool) {

//        let image = condition ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "xmark.rectangle")
        let image = condition ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
        
//        let color: UIColor = condition ? .systemBlue : .systemRed
        let color: UIColor = condition ? .systemBlue : .gray
        
        innerImageView.image = image
        innerImageView.tintColor = color
    }

    init( _ attending: Bool = true, _ frame: CGRect = .zero) {
        self.isAttending = attending
        super.init(frame: frame)

        setupInitialLayout()
    }
    
    private func setupInitialLayout() {
//        self.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
//        self.backgroundColor = .green
//        self.layer.cornerRadius = 5
//        self.layer.borderColor = .init(gray: 0.5, alpha: 0.5)
//        self.layer.borderWidth = 1
        
        addSubview(innerImageView)
        innerImageView.snp.makeConstraints { make in
            make.left.top.trailing.bottom.equalToSuperview()
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
