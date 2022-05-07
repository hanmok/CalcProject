//
//  SelectableButton.swift
//  Calie
//
//  Created by Mac mini on 2022/05/07.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import Then

class SelectableButton: UIButton, Identifiable { // has id
    var id = UUID()
    var title: String
    
    public var isSelected_: Bool {
        get {
            return self.isSelected
        }
        set {
            self.isSelected = newValue
        }
    }
    
    init(title: String, frame: CGRect = .zero) {
        self.title = title
        super.init(frame: frame)
        setupInitialColor()
    }
    
    public func setupInitialColor() {
        self.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//class SelectableButtonGroup: UIView {
class SelectableButtonStackView: UIStackView {
    
    func addArrangedButton(_ btn: SelectableButton) {
        super.addArrangedSubview(btn)
        buttons.append(btn)
    }
    
    public var buttons: [SelectableButton] = []
    public var selectedBtnIndex: Int?
    
    private var selectedColor: UIColor
    private var defaultColor: UIColor
    
    private var prevPressedBtnId: UUID?
    private var currentPressedBtnId: UUID?
    
    public func buttonSelected(_ id: UUID) {
        prevPressedBtnId = currentPressedBtnId // both can be nil for the first selection
        
        for (index, button ) in buttons.enumerated() {
            if button.id == id {
                currentPressedBtnId = id
                selectedBtnIndex = index
                button.backgroundColor = selectedColor
            } else if let validPrev = prevPressedBtnId,
                      validPrev == button.id {
                button.backgroundColor = defaultColor
            }
        }
    }
    
    private func setupInitialColor(){
        for eachBtn in buttons {
            eachBtn.setupInitialColor()
        }
    }
    
    init(selectedColor: UIColor = .gray, defaultColor: UIColor = .black, spacing: CGFloat = 10,  frame: CGRect = .zero) {
        self.selectedColor = selectedColor
        self.defaultColor = defaultColor
        super.init(frame: frame)
        setupInitialColor()
        
        self.distribution = .fillEqually
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
