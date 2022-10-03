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
    func hideTabbar()
    func showTabbar()
}


class SettingsViewController: UIViewController {
    
//    let droppingDigitCases = [-2, -1, 0, 1, 2, 3, 4, 5]
//    if userdefaul
//    userdefaultSetup()
    
    var droppingDigitCases: [Int] = []
    var userDefaultSetup = UserDefaultSetup()
    
//    if userDefaultSetup.usingFloatingPoint {
   
    
    let currencyUnitCases = ["a", "b", "c"]
    
    // MARK: - Properties
    
    var hasLoaded = false
    
    var selectedPicker: PickerType? {
        didSet {
            print("picker flag 0, picker changed to : \(selectedPicker)")
        }
    }
    
    let colorList = ColorList()

    weak var delegate: SettingsViewControllerDelegate?

//    weak var settingsDelegate: SettingsViewControllerDelegate?

//    var userDefaultSetup = UserDefaultSetup()
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userDefaultSetup.usingFloatingPoint == true { // ????
            droppingDigitCases = [-2, -1, 0, 1, 2, 3, 4, 5]
        } else {
            droppingDigitCases = [0, 1, 2, 3, 4, 5]
        }
        
        
        configureUI()
        
        tableView.backgroundColor = userDefaultSetup.darkModeOn
        ? colorList.bgColorForEmptyAndNumbersDM : colorList.bgColorForEmptyAndNumbersLM
        
        if userDefaultSetup.darkModeOn {

            view.backgroundColor = colorList.bgColorForExtrasDM
        } else {
            view.backgroundColor = colorList.bgColorForExtrasLM
        }
        
        droppingDigitPicker.delegate = self
        droppingDigitPicker.dataSource = self
        
        currencyUnitPicker.delegate = self
        currencyUnitPicker.dataSource = self
        setupAddTargets()
    }
    
    lazy var tabbarheight = tabBarController?.tabBar.bounds.size.height ?? 83
    
    func configureTableView() {
        print("configureTableView triggered!")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
         
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.identifier)
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(pickerContainerView)
        pickerContainerView.addSubview(currencyUnitPicker)
        pickerContainerView.addSubview(droppingDigitPicker)

        pickerContainerView.addSubview(confirmBtn)
        pickerContainerView.addSubview(cancelBtn)
        
        
        pickerContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(240)
            make.height.equalTo(240)
        }
        
        droppingDigitPicker.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        
        currencyUnitPicker.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(10)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
    }
    
    @objc func setupAddTargets() {
        confirmBtn.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    @objc func confirmTapped() {
        print("confirm tapped")
        pickerContainerView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(240)
            make.height.equalTo(240)
        }
        updateWithAnimation()

        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
            self.delegate?.showTabbar()
        }
    }
    
    @objc func cancelTapped() {
        print("cancel tapped")
        pickerContainerView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(240)
            make.height.equalTo(240)
        }
        updateWithAnimation()
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
            self.delegate?.showTabbar()
        }

    }
    
    private func updateWithAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
    }
    private let cancelBtn = UIButton().then {
        $0.setTitle("Cancel", for: .normal)
    }
    
    private let pickerContainerView = UIView().then {
        $0.backgroundColor = .gray
        let topCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.maskedCorners = topCorners
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 16
        $0.layer.borderColor = UIColor.clear.cgColor
    }
    
    private let droppingDigitPicker = UIPickerView().then{ $0.isHidden = true }
    private let currencyUnitPicker = UIPickerView().then {
        $0.isHidden = true
//        $0.backgroundColor = .magenta
//        $0.tintColor = .cyan
    }
//    .then {

//    }
    
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
        let userDefaultInfo = ["isDarkOn": userDefaultSetup.darkModeOn,
                               "isSoundOn": userDefaultSetup.soundOn,
                               "isNotificationOn": userDefaultSetup.notificationOn]
        
        let name = Notification.Name(rawValue: NotificationKey.sendUpdatingUserDefaultNotification.rawValue)
        
        NotificationCenter.default.post(name: name, object: nil, userInfo: userDefaultInfo as [AnyHashable : Any])
        
        tableView.backgroundColor = userDefaultSetup.darkModeOn ? colorList.bgColorForEmptyAndNumbersDM : UIColor(white: 242 / 255, alpha: 1)
        
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
        case .Mode: return ModeOptions.allCases.count
        case .Dutchpay: return DutchOptions.allCases.count
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

                if self.userDefaultSetup.darkModeOn {
                    headerView.backgroundColor = self.colorList.bgColorForExtrasDM
                } else {
                    headerView.backgroundColor = self.colorList.bgColorForExtrasLM
                }
            }
        } else {
            if self.userDefaultSetup.darkModeOn {
                headerView.backgroundColor = self.colorList.bgColorForExtrasDM
            } else {
                headerView.backgroundColor = self.colorList.bgColorForExtrasLM
            }
        }
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = userDefaultSetup.darkModeOn ? .white : colorList.textColorForResultLM
        
        title.text = SettingsSection(rawValue: section)?.description
        
        headerView.addSubview(title)
        
        title.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, paddingLeft: 16, paddingBottom: 10)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//                return 60
//        return 50
        return 40
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
                cell.switchControl.isOn = userDefaultSetup.darkModeOn
                cell.switchControl.tag = indexPath.row
                
            case .sound:
                cell.switchControl.isOn = userDefaultSetup.soundOn
                cell.switchControl.tag = indexPath.row
                
            case .notification:
                cell.switchControl.isOn = userDefaultSetup.notificationOn
                
                cell.switchControl.tag = indexPath.row
            
            case .none:
                print("none")
            }
            
        case .Dutchpay:
            let pay = DutchOptions(rawValue: indexPath.row)
            cell.sectionType = pay
            switch pay {
              
            case .useFloatingPoint:
                cell.switchControl.isOn = userDefaultSetup.usingFloatingPoint
//                cell.switchControl.tag = indexPath.row
                cell.switchControl.tag = Int.floatingPointTag

            case .droppingDigit:
                cell.triggerBtn.tag = Int.droppingDigitTag
                cell.delegate = self
                
            case .currencyUnit:
                cell.triggerBtn.tag = Int.currencyUnitTag
                cell.delegate = self
                
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
                        if let url = URL(string: "https://apps.apple.com/kr/app/%EC%B9%BC%EB%A6%AC/id1525102227") {
                            UIApplication.shared.open(url, options: [:])
                        }
                    }else{
                        if let url = URL(string: "https://apps.apple.com/us/app/calie/id1525102227?l=en") {
                            UIApplication.shared.open(url, options: [:])
                        }
                    }
                }
            }
            
        case .Mode:
            print("nothing")
            
        case .Dutchpay:
            if indexPath.row == 0 {
                print("row : 0")
            }
            if indexPath.row == 1 {
                print("row : 1")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// handleSwitchAction -> handleSwitchChanged
extension SettingsViewController: SettingsTableCellDelegate {
    func btnTapped(_ tag: Int) {

        print("tapped btn tag: \(tag)")
        
        if tag == Int.droppingDigitTag {

            droppingDigitPicker.isHidden = false
            currencyUnitPicker.isHidden = true
        } else if tag == Int.currencyUnitTag {

            droppingDigitPicker.isHidden = true
            currencyUnitPicker.isHidden = false
            print("currencyUnitPicker is visible!")
        }
        
        delegate?.hideTabbar()
        
        pickerContainerView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(240)
        }

        updateWithAnimation()
    }
    
    func handleSwitchChanged(_ tag: Int, changedTo isOn: Bool) {
        switch tag {
        case 0:
            userDefaultSetup.darkModeOn = isOn
           
            hasLoaded = true
            self.tableView.reloadData()
            
            if userDefaultSetup.darkModeOn {
                view.backgroundColor = colorList.bgColorForExtrasDM

            } else {
                view.backgroundColor = colorList.bgColorForExtrasLM
            }
            
        case 1:
            userDefaultSetup.soundOn = isOn
        case 2:
            userDefaultSetup.notificationOn = isOn
            
        default:
            print("wrong tag has pressed")
        }
        delegate?.updateUserdefault()
        sendUpdatingUserDefault() // broadcast update !
    }
}


extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == currencyUnitPicker {
            return currencyUnitCases[row]
        } else {
            return String(droppingDigitCases[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == currencyUnitPicker {
            userDefaultSetup.currencyUnit = currencyUnitCases[row]
        } else {
            userDefaultSetup.droppingDigitIdx = droppingDigitCases[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
        if pickerView == droppingDigitPicker {
//            return 8
            if userDefaultSetup.usingFloatingPoint {
                return 8
            } else {
                return 6
            }
        } else {
            print("picker flag 1, pickerView: currency, return 3")
            return 3
        }
    }
}


enum PickerType {
    case droppingDigit
    case currenyUnit
}
