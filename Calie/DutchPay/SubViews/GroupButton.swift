//
//  GroupButton.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/25.
//  Copyright © 2022 Mac mini. All rights reserved.
//

//import Foundation
import UIKit

class GroupButton: UIButton {
    
    var title: String

    init( group: Group2, _ frame: CGRect = .zero) {
        self.title = group.title
        super.init(frame: frame)
        loadView()
    }
    
    private func loadView() {
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
