

//
//  HistoryRecordVC.swift
//  Neat Calc
//
//  Created by hanmok on 2020/05/20.
//  Copyright © 2020 hanmok. All rights reserved.
//
// to table receiver

//from table sender

//view will transition listener! (receiver)

import UIKit
import RealmSwift

protocol FromTableToBaseVC{
    func copyAndPasteAns(ansString : String)
}

class HistoryRecordVC: UIViewController {
    
    let localizedStrings = LocalizedStringStorage()
    
    let ansToTableNotification = Notification.Name(rawValue: answerToTableNotificationKey)
    let viewWillTransitionNotification = Notification.Name(rawValue: viewWilltransitionNotificationKey)
    let viewWillDisappearBasicVCNotification = Notification.Name(rawValue: viewWillDisappearbasicViewControllerKey)
    let viewWillAppearBasicVCNotification = Notification.Name(rawValue: viewWillAppearbasicViewControllerKey)
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var deviceInfo = UIDevice.modelName
    
    let fontSize = FontSizes()
    let frameSize = FrameSizes()
    var tableView = UITableView()
    
    var historyRecords : Results<HistoryRecord>!
    
    let colorList = ColorList()
    
    var userDefaultSetup = UserDefaultSetup()
    var isLightModeOn = false
    
    let realm = RealmService.shared.realm
    
    let trashbinImage = UIImageView(image: #imageLiteral(resourceName: "trashBinSample"))
    let trashbinHelper = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    var isOrientationPortrait = true
    
    var willbasicVCdisappear = false
    
    var FromTableToBaseVCdelegate : FromTableToBaseVC?
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        
        //        isOrientationPortrait
        if UIDevice.current.orientation.isLandscape {
            isOrientationPortrait = false
            print("Landscape viewWillTransition baseVC")
        } else if UIDevice.current.orientation.isPortrait {
            print("Portrait viewWillTransition baseVC")
            isOrientationPortrait = true
        }else{
            print("Neither Landscape nor Portrait mode viewWillTransition baseVC ")
        }
        
        
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        isOrientationPortrait = screenWidth > screenHeight ? true : false
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryRecordCell.self, forCellReuseIdentifier: "HistoryRecordReuseIdentifier")
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        print("viewDidLoad table")
        if deviceInfo.first == " "{
            deviceInfo.removeFirst()
        }
        
        print("type of userDefaultSetup.getUserDeviceVersionInfo() : \(userDefaultSetup.getUserDeviceVersionInfo())")
        
        if userDefaultSetup.getUserDeviceVersionInfo() == "ND"{ // Not Determined
            userDefaultSetup.setUserDeviceVersionInfo(userDeviceVersionInfo: deviceInfo)
            
            if userDefaultSetup.getUserDeviceVersionInfo().contains("iPh"){
                print("iPh 포함")
                switch userDefaultSetup.getUserDeviceVersionInfo().first {
                case "4","5","6","7","8","S":
                    userDefaultSetup.setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo: "P")
                    print("first Name : \(String(describing: userDefaultSetup.getUserDeviceVersionInfo().first))")
                default:
                    userDefaultSetup.setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo: "MP")
                    print("first Name : \(String(describing: userDefaultSetup.getUserDeviceVersionInfo().first))")
                    print("what was the version ?:\(userDefaultSetup.getUserDeviceVersionInfo())")
                }
            }
            else if userDefaultSetup.getUserDeviceVersionInfo().contains("iPo"){
                userDefaultSetup.setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo: "LP")
                print("iPod touch model.")
            }
        }else{
            print("modelName : \(deviceInfo)")
        }
        print("userDefaultSetup.getUserDeviceVersionInfo() : \(userDefaultSetup.getUserDeviceVersionInfo())")
        print("deviceType : \(userDefaultSetup.getUserDeviceVersionTypeInfo())")
        // P : Popular, MP : Most Popular, LP : Least Popular
        
        print("modelName : \(deviceInfo)")
        //        print("deviceType : \(type(of: deviceInfo))")
        
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        isOrientationPortrait = screenHeight > screenWidth ? true : false
        
        super.viewDidLoad()
        
        createObservers()
        
        if UIDevice.current.orientation.isLandscape {
            isOrientationPortrait = false
        } else if UIDevice.current.orientation.isPortrait {
            isOrientationPortrait = true
        }
        
        returnLightMode()
        
        setupLayout()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryRecordCell.self, forCellReuseIdentifier: "HistoryRecordReuseIdentifier")
        historyRecords = realm.objects(HistoryRecord.self)
        
        tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
        
        self.tableView.reloadData()
        addTargetSetup()
        
        tableView.setContentOffset(.zero, animated: false)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear table")
    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear table")
        viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear table")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear table")
        //        print("viewWillDisappear called in table, willbasicVCdisappear : \(willbasicVCdisappear)")
    }
    
    func createObservers(){
        print("createObservers table")
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryRecordVC.answerToTable(notification:)), name: ansToTableNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(HistoryRecordVC.transitionOccured(notification:)),name: viewWillTransitionNotification,object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryRecordVC.viewWillDisappearBasicVC(notification:)), name: viewWillDisappearBasicVCNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(HistoryRecordVC.viewWillAppearBasicVC(notification:)),name: viewWillAppearBasicVCNotification,object: nil)
    }
    
    @objc func viewWillDisappearBasicVC(notification : NSNotification){
        print("viewWillDisappearBasicVC table")
        if !willbasicVCdisappear{
            willbasicVCdisappear.toggle()
        }
    }
    
    @objc func viewWillAppearBasicVC(notification : NSNotification){
        print("viewWillAppearBasicVC table")
        if willbasicVCdisappear{
            willbasicVCdisappear.toggle()
        }
    }
    
    
    @objc func answerToTable(notification: NSNotification) {
        print("answerToTable table")
        loadData()
    }
    
    @objc func transitionOccured(notification: NSNotification){
        print("transitionOccured table")
        guard let newPortrait = notification.userInfo?["orientation"] as? Bool else {
            print("there's an error in tableView transitionOccured function")
            return }
        
        isOrientationPortrait = newPortrait // 현재 아무런 역할도 안함
    }
    
    func loadData(){
        print("loadData table")
        historyRecords = realm.objects(HistoryRecord.self)
        tableView.reloadData()
    }
    
    
    func returnLightMode(){
        print("returnLightMode table")
        isLightModeOn = userDefaultSetup.getIsLightModeOn()
    }
    
    func setupLayout(){
        print("setupLayout table")
        for subview in tableView.subviews{
            subview.removeFromSuperview()
        }
        
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
        view.addSubview(tableView)
        
        if isOrientationPortrait{
            tableView.pinWithSpace2(to: view, type : userDefaultSetup.getUserDeviceVersionTypeInfo())
            //            tableView.pinWithSpace2(to: view)
            
            
            
            
            view.addSubview(infoView)
            infoView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
            
            
            
            switch userDefaultSetup.getUserDeviceVersionTypeInfo() {
            //  MP : Most popular, P : Popular, LP : Least Popular
            //            case "MP" : infoView.heightAnchor.constraint(equalToConstant: 70).isActive = true
            case "MP" : //infoView.heightAnchor.constraint(equalToConstant: 80).isActive = true
                infoView.setHeight(80)
            case "LP" : //infoView.heightAnchor.constraint(equalToConstant: 50).isActive = true
                infoView.setHeight(50)
            default:
                //                infoView.heightAnchor.constraint(equalToConstant: 60).isActive = true
                infoView.setHeight(60)
            }
            // no constraints for infoLabel width
            infoView.addSubview(infoLabel)
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            infoLabel.centerX(inView: infoView)
            infoLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -7).isActive = true
            
            
            
            infoView.addSubview(trashButton)
            
            trashButton.anchor(bottom: infoView.bottomAnchor, right: infoView.rightAnchor)
            trashButton.setDimensions(width: 50, height: 35)
            
            trashButton.addSubview(trashbinImage)
            trashButton.addSubview(trashbinHelper)
            
            trashbinHelper.anchor(top: trashButton.topAnchor, left: trashButton.leftAnchor, bottom: trashButton.bottomAnchor)
            trashbinHelper.widthAnchor.constraint(equalTo: trashButton.widthAnchor, multiplier: 0.1).isActive = true
            
            
            trashbinImage.anchor(left: trashbinHelper.rightAnchor, bottom: trashButton.bottomAnchor)
            trashbinImage.heightAnchor.constraint(equalTo: trashButton.heightAnchor, multiplier: 0.9).isActive = true
            trashbinImage.widthAnchor.constraint(equalTo: trashButton.widthAnchor, multiplier: 0.55).isActive = true
            
            
            if isLightModeOn{
                infoView.backgroundColor = colorList.bgColorForExtrasBM
                
                tableView.backgroundColor = colorList.bgColorForEmptyAndNumbersBM // 들췄을 때 color.
                
                
                view.addSubview(subHistoryLight)
                
                subHistoryLight.anchor(left: view.leftAnchor, bottom: view.safeBottomAnchor, paddingLeft: 30)
                subHistoryLight.setDimensions(width: 40, height: 40)
                
            }else{
                infoView.backgroundColor = colorList.bgColorForExtrasDM
                infoLabel.textColor = .white
                
                tableView.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
                
                view.addSubview(subHistoryDark)
                
                subHistoryDark.anchor(left: view.leftAnchor, bottom: view.safeBottomAnchor, paddingLeft: 30)
                subHistoryDark.setDimensions(width: 40, height: 40)
                
            }
            
            view.addSubview(historyClickButton)
            
            historyClickButton.anchor(left: view.leftAnchor, bottom: view.safeBottomAnchor, paddingLeft: 30)
            historyClickButton.setDimensions(width: 40, height: 40)
            
            
        }else{
            tableView.pin(to: view) // 이거같은데?
            
            tableView.backgroundColor = isLightModeOn ? colorList.bgColorForEmptyAndNumbersBM : colorList.bgColorForEmptyAndNumbersDM
        }
    }
    
    @objc func backToBaseController(){
        print("backToBaseController table")
        if willbasicVCdisappear{
            willbasicVCdisappear.toggle()
        }
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func addTargetSetup(){
        print("addTargetSetup table")
        historyClickButton.addTarget(self, action: #selector(backToBaseController), for: .touchUpInside)
        historyClickButton.addTarget(self, action: #selector(backToBaseController), for: .touchDragExit)
        trashButton.addTarget(self, action: #selector(removeAllAlert), for: .touchUpInside)
    }
    
    @objc func removeAllAlert(){
        print("removeAllAlert table")
        showAlert(title: "Clear History", message: localizedStrings.removeAll,
                  handlerA: { actionA in
                  },
                  handlerB: { actionB in
                    
                    for element in self.historyRecords{
                        RealmService.shared.delete(element)
                    }
                    self.tableView.reloadData()
                    
                    self.showToast(message: self.localizedStrings.deleteAllComplete, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.6, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                  })
    }
    
    @objc func backToOriginalColor(sender : UITableViewCell){
        print("backToOriginalColor table")
        if isLightModeOn{
            sender.backgroundColor = colorList.bgColorForEmptyAndNumbersBM
        }else{
            sender.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
        }
    }
    
    let infoView : UIView = {
        let sub = UIView()
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let infoLabel : UILabel = {
        let label = UILabel()
        label.text = "History"
        label.font = .boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    let trashButton : UIButton = {
        let sub = UIButton(type: .custom)
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let historyClickButton : UIButton = {
        let sub = UIButton(type: .custom)
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    
    let fillBottom : UIView = {
        let sub = UIView()
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let subHistoryLight : UIImageView = {
        let sub = UIImageView(image: #imageLiteral(resourceName: "light_up"))
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
    
    let subHistoryDark : UIImageView = {
        let sub = UIImageView(image: #imageLiteral(resourceName: "dark_up"))
        sub.translatesAutoresizingMaskIntoConstraints = false
        return sub
    }()
}





// MARK: - Table view data source.
extension HistoryRecordVC : UITableViewDataSource, UITableViewDelegate{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection table")
        print("section : \(section)")
        return historyRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt table")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryRecordReuseIdentifier") as? HistoryRecordCell else{ return UITableViewCell()}
        
        //reverse mode,  top the latest
        let maxNumber = historyRecords.count
        let historyIndex = maxNumber - indexPath.row - 1
        
        let historyRecord = historyRecords[historyIndex]
        
        cell.configure(with: historyRecord, orientationPortrait : isOrientationPortrait, willbasicVCdisappear : willbasicVCdisappear)
        cell.colorSetup(isLightModeOn: isLightModeOn)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt table")
        
        let maxNumber = historyRecords.count
        let historyIndex = maxNumber - indexPath.row - 1
        
        
        FromTableToBaseVCdelegate?.copyAndPasteAns(ansString: historyRecords[historyIndex].resultString ?? "nothing transmitted")
        
        loadData()
        
        if !(!UIDevice.current.orientation.isPortrait && !willbasicVCdisappear){
            backToBaseController()
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("trailingSwipeActionConfigurationForRowAt table")
        
        let delete = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
            if let record = self.historyRecords?[historyIndex]{
                RealmService.shared.delete(record)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            self.showToast(message: self.localizedStrings.deleteComplete, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
            
            
            completionHandler(true)
            
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete])
        return rightSwipe
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("leadingSwipeActionsConfigurationForRowAt table")
        let copyAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
            if self.isOrientationPortrait{
                if let record = self.historyRecords?[historyIndex]{
                    let toBeSaved = record.processStringHis! + "=" + record.resultString!
                    UIPasteboard.general.string = toBeSaved
                }
            }else{
                if let record = self.historyRecords?[historyIndex]{
                    let toBeSaved = record.processStringCalc! + "=" + record.resultString!
                    UIPasteboard.general.string = toBeSaved
                }
            }
            
            self.showToast(message: self.localizedStrings.copyComplete, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
            
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
            if self.isOrientationPortrait{
                if let record = self.historyRecords?[historyIndex]{
                    let toBeSaved = record.processStringHis! + "=" + record.resultString!
                    
                    UIPasteboard.general.string = toBeSaved
                    let activityController = UIActivityViewController(activityItems: [toBeSaved], applicationActivities: nil)
                    
                    self.present(activityController, animated: true, completion: nil)
                    
                }
            }else{
                if let record = self.historyRecords?[historyIndex]{
                    let toBeSaved = record.processStringCalc! + "=" + record.resultString!
                    let activityController = UIActivityViewController(activityItems: [toBeSaved], applicationActivities: nil)
                    
                    self.present(activityController, animated: true, completion: nil)
                    
                    UIPasteboard.general.string = toBeSaved
                }
            }
            
            
            completionHandler(true)
        }
        
        copyAction.image = UIImage(systemName: "doc.on.doc.fill")
        copyAction.backgroundColor = colorList.bgColorForExtrasDM
        
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        shareAction.backgroundColor = colorList.bgColorForExtrasMiddle
        
        let leftSwipe = UISwipeActionsConfiguration(actions: [copyAction, shareAction])
        return leftSwipe
    }
}
