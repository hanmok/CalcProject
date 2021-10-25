//
//  SettingsCollectionCell.swift
//  Caliy
//
//  Created by Mac mini on 2021/10/16.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit

class SettingsCollectionCell: UICollectionViewCell {
    
    var viewModel: SettingsViewModel? {
        didSet { configureUI() }
    }
    
    public var labelText: String = ""
    
    lazy var btn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(handleBtnPressed), for: .touchUpInside)
        return btn
    }()
    
    lazy var mySwitch: UISwitch = {
        let myswitch = UISwitch(frame: .zero)
        return myswitch
    }()
    
    private var clearFullButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleFullButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    private var label: UILabel = {
        let label = UILabel()
        label.text = "this is my label"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .brown
//        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        
       addSubview(label)
        label.attributedText = viewModel?.attributedLabel
        label.anchor(left: leftAnchor, paddingLeft: 20)
        label.centerY(inView: self)
        label.setDimensions(width: 200, height: frame.height - 10)
        
        addSubview(btn)
        btn.anchor(right: rightAnchor, paddingRight: 20)
        btn.centerY(inView: self)
        btn.setDimensions(width: 100, height: frame.height - 10)
        
        if viewModel?.hasSwitch ?? false {
            addSubview(mySwitch)
            mySwitch.center(inView: self)
            mySwitch.setDimensions(width: 50, height: 50)
        }
        
        if viewModel?.hasSwitch ?? false {
            addSubview(clearFullButton)
            clearFullButton.fillSuperview()
        }
    }
    
    @objc func handleBtnPressed(_ sender: UIButton) {
        print("btn pressed!")
    }
    
    @objc func handleFullButtonPressed(_ sender: UIButton) {
        print("handleFullButtonPressed")
    }
}
