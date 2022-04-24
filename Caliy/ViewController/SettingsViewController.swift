//
//  SettingsViewController.swift
//  Caliy
//
//  Created by Mac mini on 2021/10/13.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit
import SnapKit
//private let reuseIdentifier = "SettingsCell"
//private let myCollectionIdentifer = "CollectionCell"

// sender for notification of updating UserDefaut

protocol SettingsViewControllerDelegate: AnyObject {
    func updateUserdefault()
}


class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    var hasLoaded = false
    
    
    lazy var isDarkMode = userDefaultSetup.getDarkMode()
    
    let colorList = ColorList()
    weak var delegate: SettingsViewControllerDelegate?
    weak var settingsDelegate: SettingsViewControllerDelegate?
    var userDefaultSetup = UserDefaultSetup()
    
    let tableView = UITableView()

//    let containerView = UIView()
//    let emptyView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        tableView.backgroundColor = isDarkMode ? colorList.bgColorForEmptyAndNumbersDM : colorList.bgColorForEmptyAndNumbersLM
        
        
        if userDefaultSetup.getDarkMode() {
//            view.backgroundColor = colorList.newMainForDarkMode
            view.backgroundColor = colorList.bgColorForExtrasDM
        } else {
//            view.backgroundColor = colorList.newMainForLightMode
            view.backgroundColor = colorList.bgColorForExtrasLM
        }
//        emptyView.backgroundColor = .orange
        
        
    }
    
    lazy var tabbarheight = tabBarController?.tabBar.bounds.size.height ?? 83
    
    func configureTableView() {
        print("configureTableView triggered!")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
         
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.identifier)
        
        view.addSubview(tableView)
//        view.addSubview(emptyView)
        
//        emptyView.snp.makeConstraints { make in
//            make.left.top.right.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-tabbarheight)
//        }
//
//        emptyView.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
//        emptyView.backgroundColor = .orange
        
    }
    
    func configureUI() {
        configureTableView()
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppUtility.lockOrientation(.all)
    }
    
    // triggered each time switch has toggled
    func sendUpdatingUserDefault() {
        print("sendUPdatingUserDefault has triggered")
        let userDefaultInfo = ["isDarkOn": userDefaultSetup.getDarkMode(),
                               "isSoundOn": userDefaultSetup.getSoundMode(),
                               "isNotificationOn": userDefaultSetup.getNotificationMode()]
        
        let name = Notification.Name(rawValue: NotificationKey.sendUpdatingUserDefaultNotification.rawValue)
        
        NotificationCenter.default.post(name: name, object: nil, userInfo: userDefaultInfo as [AnyHashable : Any])
        print("sending updateUserdefault from SettingsVC")
        
        // 이거 두개.. screen Mode 가 바뀔 때에만 호출할 수는 없나 ?
        isDarkMode = userDefaultSetup.getDarkMode()
        
//        tableView.backgroundColor = isDarkMode ? .black  : UIColor(white: 242 / 255, alpha: 1)
        tableView.backgroundColor = isDarkMode ? colorList.bgColorForEmptyAndNumbersDM : UIColor(white: 242 / 255, alpha: 1)
//        tableView.backgroundColor = .magenta
        
        }
}




// MARK: - UITableViewDataSource, UITabViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        
        switch section {
        case .Mode:return ModeOptions.allCases.count
        case .General: return GeneralOptions.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        print("viewForheaderInSection, hasLoaded : \(hasLoaded), ")
        // has changed displayMode
        
        // give animation
        if hasLoaded {
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve) {

                if self.userDefaultSetup.getDarkMode() {
                    headerView.backgroundColor = self.colorList.bgColorForExtrasDM
                } else {
                    headerView.backgroundColor = self.colorList.bgColorForExtrasLM
                }
            }
        } else {
            if self.userDefaultSetup.getDarkMode() {
                headerView.backgroundColor = self.colorList.bgColorForExtrasDM
            } else {
                headerView.backgroundColor = self.colorList.bgColorForExtrasLM
            }
        }
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = isDarkMode ? .white : colorList.textColorForResultLM
        
        title.text = SettingsSection(rawValue: section)?.description
        
        headerView.addSubview(title)
        
        title.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, paddingLeft: 16, paddingBottom: 10)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return 60
        // return 70 // original
//        return 85
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt triggered")
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.identifier, for: indexPath) as! SettingsTableCell
      
        
        cell.delegate = self
        cell.hasLoaded = hasLoaded
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .Mode:
            let mode = ModeOptions(rawValue: indexPath.row)
            cell.sectionType = mode
            
            switch mode {
            case .darkMode:
                cell.switchControl.isOn = userDefaultSetup.getDarkMode()
                print("getIsDarkModeOn: \(userDefaultSetup.getDarkMode())")
                cell.switchControl.tag = indexPath.row
                
            case .sound:
                cell.switchControl.isOn = userDefaultSetup.getSoundMode()
                cell.switchControl.tag = indexPath.row
                
            case .notification:
                cell.switchControl.isOn = userDefaultSetup.getNotificationMode()
                cell.switchControl.tag = indexPath.row
            
            case .none:
                print("none")
            }
        case .General:
            let general = GeneralOptions(rawValue: indexPath.row)
            cell.sectionType = general
        }
        cell.configureCellColor(hasLoaded: hasLoaded)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .General:
            print(String(describing:GeneralOptions(rawValue: indexPath.row)?.description))
            
            // rate
            if indexPath.row == 0 {
                ReviewService.shared.requestReview()
            }
            
            // review
            if indexPath.row == 1 {
                if let languageCode = Locale.current.languageCode{
                    if languageCode.contains("ko"){ //
                        if let url = URL(string: "https://apps.apple.com/kr/app/%EC%B9%BC%EB%A6%AC/id1525102227") { //\\
                            UIApplication.shared.open(url, options: [:])
                        }
                    }else{// english google question page.
                        if let url = URL(string: "https://apps.apple.com/us/app/calie/id1525102227?l=en") {
                            UIApplication.shared.open(url, options: [:])
                        }
                    }
                }
            }
            
        case .Mode:
            print("nothing")
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

// handleSwitchAction -> handleSwitchChanged
extension SettingsViewController: SettingsTableCellDelegate {
    func handleSwitchChanged(_ tag: Int, changedTo isOn: Bool) {
        switch tag {
        case 0:
            userDefaultSetup.setDarkMode(isDarkMode: isOn)
           
            hasLoaded = true
            self.tableView.reloadData()
            
            if userDefaultSetup.getDarkMode() {
                view.backgroundColor = colorList.bgColorForExtrasDM
//                view.backgroundColor = colorList.newMainForDarkMode
//                emptyView.backgroundColor = .orange
            } else {
                view.backgroundColor = colorList.bgColorForExtrasLM
//                view.backgroundColor = colorList.newMainForLightMode
//                emptyView.backgroundColor = .orange
            }
            
        case 1:
            userDefaultSetup.setSoundMode(isSoundOn: isOn)
            print("soundMode has changed to \(userDefaultSetup.getSoundMode())")
        case 2:
            userDefaultSetup.setNotificationMode(isNotificationOn: isOn)
            print("notification has changed to \(userDefaultSetup.getNotificationMode())")
            
            
        default:
            print("wrong tag has pressed")
        }
        delegate?.updateUserdefault()
        sendUpdatingUserDefault() // broadcast update !
    }
}
