//
//  SettingsCell.swift
//  Caliy
//
//  Created by Mac mini on 2021/10/13.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    // MARK: - Properties
    
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
//            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
//        switchControl.isOn = true
        switchControl.onTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
//        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        switchControl.backgroundColor = .magenta
        return switchControl
    }()
    
    lazy var myBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .magenta
        btn.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
        return btn
    }()
    
    @objc func btnPressed(_ sender: UIButton) {
        print("btn pressed!")
    }
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(switchControl)
        
        switchControl.anchor(right: rightAnchor, paddingRight: 12)
        switchControl.centerY(inView: self)
        
        addSubview(myBtn)
        myBtn.anchor(right: switchControl.leftAnchor, paddingRight: 20)
        myBtn.centerY(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            print("turned on")
        } else {
            print("turned off")
        }
        print("switch has pressed!")
    }
}
