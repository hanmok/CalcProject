//
//  SettingsCell.swift
//  Caliy
//
//  Created by Mac mini on 2021/10/13.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit



protocol SettingsTableCellDelegate: AnyObject {
    func handleSwitchChanged(_ tag: Int, changedTo isOn: Bool)
}


class SettingsTableCell: UITableViewCell {
    
    lazy var isDarkMode = userDefaultSetup.darkModeOn
    let colorList = ColorList()
    static let identifier = "SettingsTableCell"
    // MARK: - Properties
    
    var userDefaultSetup = UserDefaultSetup()
    
    weak var delegate: SettingsTableCellDelegate?
    
    var hasLoaded = false
    
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
//        switchControl.isOn = true
//        switchControl.onTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        switchControl.onTintColor = UIColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1)
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        
        return switchControl
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        print(#function)
//        print(#function)
        
        contentView.addSubview(switchControl)
        
        contentView.clipsToBounds = true
        
        accessoryType = .none
         // this function has not been called ..
        
        print("override init called")
    }
    
    func configureCellColor(hasLoaded: Bool) {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // this one called eachTime tableView reloaded.
    override func layoutSubviews() { // 이거 계속 trigger 되는데?
        super.layoutSubviews()
        
        isDarkMode = userDefaultSetup.darkModeOn
        
                switchControl.anchor(right: rightAnchor, paddingRight: 12)
                switchControl.centerY(inView: self)
        
        if hasLoaded { // make animations
            UIView.transition(with: self.contentView, duration: 0.5, options: .transitionCrossDissolve) {
                
//                self.contentView.backgroundColor = self.isDarkMode ? UIColor(white: 33 / 255, alpha: 1) : .white
                // changed .. why ? i don't know.
                self.contentView.backgroundColor = self.isDarkMode ? UIColor(white: 33 / 255, alpha: 1) : .white
                print("line 86, isDarkMode: \(self.isDarkMode)")
                self.textLabel?.textColor = self.isDarkMode ? .white : .black
            }
        } else {
            
            self.contentView.backgroundColor = self.isDarkMode ? UIColor(white: 33 / 255, alpha: 1) : .white
            
            textLabel?.textColor = isDarkMode ? .white : .black
            
            print("hasLoaded: false")
        }
    }
    
    // MARK: - Selectors
//
    @objc func handleSwitchAction(_ sender: UISwitch) {
        print("switch has pressed. tag: \(sender.tag)")
        
        print("tag: \(sender.tag)")
        print("isOn: \(sender.isOn)")
        
//        switch tag {
//        case 0: userDefaultSetup.setIsDarkModeOn(isDarkModeOn: sender.isOn)
//        case 1:userDefaultSetup.setIsSoundOn(isSoundOn: sender.isOn)
//        case 2: userDefaultSetup.setIsNotificationOn(isNotificationOn: sender.isOn)
//        default:
//            print("nothing happened")
//        }
            
        
        
        
        delegate?.handleSwitchChanged(sender.tag, changedTo: sender.isOn)

        print("SettingsTableCell, handleSwitchAction triggered")
        if sender.isOn {
            print("switch has turned on")
        } else {
            print("switch has turned off") // has printed.
        }
    }
}
