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
    
    private let innerImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    public func markAttendedState(using condition: Bool) {
        print("markAttended")
        let image = condition ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
   
        let color: UIColor = condition ? .systemBlue : UIColor(white: 0.8, alpha: 1)
        DispatchQueue.main.async {
            self.innerImageView.image = image
            self.innerImageView.tintColor = color
        }
    }

    init( _ attending: Bool = true, _ frame: CGRect = .zero) {
        self.isAttending = attending
        super.init(frame: frame)

        setupInitialLayout()
    }
    
    private func setupInitialLayout() {
        
        addSubview(innerImageView)
        innerImageView.snp.makeConstraints { make in
            make.left.top.trailing.bottom.equalToSuperview()
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
