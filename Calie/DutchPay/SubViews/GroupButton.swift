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
    
    
    public var group: Group2
    
    public var title: String {
        return group.title
    }

    public var people: [Person2] {
//        return group.people.map{ $0.name }
        return group.people
    }
    
//    public var
    init( group: Group2, _ frame: CGRect = .zero) {
        self.group = group
        super.init(frame: frame)
        loadView()
    }
    
    var isSelected_: Bool {
        get {
            return isSelected
        }
        set {
            self.isSelected = newValue
            loadView()
            
        }
    }
    
    
    private func loadView() {
        self.setTitle(title, for: .normal)
        self.backgroundColor = .brown
        self.layer.cornerRadius = 5
        self.layer.borderColor = .init(gray: 0.5, alpha: 0.5)
        self.layer.borderWidth = 1
        
        if isSelected {
            self.backgroundColor = .black
        } else {
            self.backgroundColor = .magenta
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
