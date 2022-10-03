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
    func btnTapped(_ tag: Int)
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
            triggerBtn.isHidden = !sectionType.containsButton
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()

        switchControl.onTintColor = UIColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1)
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        
        return switchControl
    }()
    
    lazy var triggerBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("hello", for: .normal)
//        btn.setTitle("hellansldkiawubiawjnliawjniAsdo", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        
        btn.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        btn.backgroundColor = .magenta
        return btn
    }()
    
    @objc func btnTapped() {
        delegate?.btnTapped(triggerBtn.tag)
        print("tapped tag: \(triggerBtn.tag)")
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(switchControl)
        contentView.addSubview(triggerBtn)
        contentView.clipsToBounds = true
        
        accessoryType = .none
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
        
        triggerBtn.anchor(right: rightAnchor, paddingRight: 12)
        triggerBtn.centerY(inView: self)
        
        if hasLoaded { // make animations
            UIView.transition(with: self.contentView, duration: 0.5, options: .transitionCrossDissolve) {
                
                self.contentView.backgroundColor = self.isDarkMode ? UIColor(white: 33 / 255, alpha: 1) : .white

                self.textLabel?.textColor = self.isDarkMode ? .white : .black
            }
        } else {
            
            self.contentView.backgroundColor = self.isDarkMode ? UIColor(white: 33 / 255, alpha: 1) : .white
            
            textLabel?.textColor = isDarkMode ? .white : .black
        }
    }
    
    // MARK: - Selectors
    @objc func handleSwitchAction(_ sender: UISwitch) {
        
        
        delegate?.handleSwitchChanged(sender.tag, changedTo: sender.isOn)

        print("SettingsTableCell, handleSwitchAction triggered")
        if sender.isOn {
            print("switch has turned on")
        } else {
            print("switch has turned off") // has printed.
        }
    }
}
