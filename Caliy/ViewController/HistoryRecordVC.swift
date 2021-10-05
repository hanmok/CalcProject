

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
    func pasteAnsFromHistory(ansString : String)
}

class HistoryRecordVC: UIViewController {
    
    let localizedStrings = LocalizedStringStorage()
    
    let ansToTableNotification = Notification.Name(rawValue: NotificationKey.answerToTableNotification.rawValue)
    let viewWillTransitionNotification = Notification.Name(rawValue: NotificationKey.viewWilltransitionNotification.rawValue)
    let viewWillDisappearBasicVCNotification = Notification.Name(rawValue: NotificationKey.viewWillDisappearbaseViewController.rawValue)
    let viewWillAppearBasicVCNotification = Notification.Name(rawValue: NotificationKey.viewWillAppearbaseViewController.rawValue)
    
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
    var lightModeOn = false
    
    let realm = RealmService.shared.realm
    
    let trashbinImage = UIImageView(image: #imageLiteral(resourceName: "trashBinSample"))
    let trashbinHelper = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    var portraitMode = true
    
    var basicVCWillDisappear = false
    
    var FromTableToBaseVCdelegate : FromTableToBaseVC?
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        
        //        isOrientationPortrait
        if UIDevice.current.orientation.isLandscape {
            portraitMode = false
            print("Landscape viewWillTransition baseVC")
        } else if UIDevice.current.orientation.isPortrait {
            print("Portrait viewWillTransition baseVC")
            portraitMode = true
        }else{
            print("Neither Landscape nor Portrait mode viewWillTransition baseVC ")
        }
        
        
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        portraitMode = screenWidth > screenHeight ? true : false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryRecordCell.self, forCellReuseIdentifier: "HistoryRecordReuseIdentifier")
        tableView.reloadData()
    }
    
    // P : Popular, MP : Most Popular, LP : Least Popular
    override func viewDidLoad() {
        print("viewDidLoad table")
        if deviceInfo.first == " "{
            deviceInfo.removeFirst()
        }
        
        print("type of userDefaultSetup.getUserDeviceVersionInfo() : \(userDefaultSetup.getDeviceVersion())")
        
        if userDefaultSetup.getDeviceVersion() == "ND"{ // Not Determined
            userDefaultSetup.setUserDeviceVersionInfo(userDeviceVersionInfo: deviceInfo)
            
            if userDefaultSetup.getDeviceVersion().contains("iPh"){
               // iPh 포함
                switch userDefaultSetup.getDeviceVersion().first {
                case "4","5","6","7","8","S":
                    userDefaultSetup.setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo: "P")
                default:
                    userDefaultSetup.setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo: "MP")
                }
            } // "iPod touch model."
            else if userDefaultSetup.getDeviceVersion().contains("iPo"){
                userDefaultSetup.setUserDeviceVersionTypeInfo(userDeviceVersionTypeInfo: "LP")
               
            }
        }

        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        portraitMode = screenHeight > screenWidth ? true : false
        
        super.viewDidLoad()
        
        createObservers()
        
        if UIDevice.current.orientation.isLandscape {
            portraitMode = false
        } else if UIDevice.current.orientation.isPortrait {
            portraitMode = true
        }
        
        lightModeOn = userDefaultSetup.getIsLightModeOn()
        
        setupLayout()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryRecordCell.self, forCellReuseIdentifier: "HistoryRecordReuseIdentifier")
        historyRecords = realm.objects(HistoryRecord.self)
        
        tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
        
        self.tableView.reloadData()
        setupAddTargets()
        
        tableView.setContentOffset(.zero, animated: false)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        print("viewDidAppear table")
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear table")
        viewDidLoad()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        print("viewDidDisappear table")
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        print("viewWillDisappear table")
//        //        print("viewWillDisappear called in table, willbasicVCdisappear : \(willbasicVCdisappear)")
//    }
    
    func createObservers(){
        print("createObservers table")
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryRecordVC.answerToTable(notification:)), name: ansToTableNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(HistoryRecordVC.transitionOccured(notification:)),name: viewWillTransitionNotification,object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryRecordVC.viewWillDisappearBasicVC(notification:)), name: viewWillDisappearBasicVCNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(HistoryRecordVC.viewWillAppearBasicVC(notification:)),name: viewWillAppearBasicVCNotification,object: nil)
    }
    
    @objc func viewWillDisappearBasicVC(notification : NSNotification){
        if !basicVCWillDisappear{
            basicVCWillDisappear.toggle()
        }
    }
    
    @objc func viewWillAppearBasicVC(notification : NSNotification){
        if basicVCWillDisappear{
            basicVCWillDisappear.toggle()
        }
    }
    
    
    @objc func answerToTable(notification: NSNotification) {
        loadData()
    }
    
    @objc func transitionOccured(notification: NSNotification){
       
        guard let newPortrait = notification.userInfo?["orientation"] as? Bool else {
            print("there's an error in tableView transitionOccured function")
            return }
        
        portraitMode = newPortrait // 현재 아무런 역할도 안함
    }
    
    func loadData(){
        print("loadData table")
        historyRecords = realm.objects(HistoryRecord.self)
        tableView.reloadData()
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
        
        if portraitMode{
            tableView.pinWithSpace2(to: view, type : userDefaultSetup.getDeviceVersionType())
            
            view.addSubview(infoView)
            infoView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
            
            
            
            switch userDefaultSetup.getDeviceVersionType() {
            
            case "MP" :
                infoView.setHeight(80)
            case "LP" :
                infoView.setHeight(50)
            default:
                infoView.setHeight(60)
            }
            
            // no constraints for infoLabel width
            infoView.addSubview(infoLabel)
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            
            infoLabel.centerX(inView: infoView)
//            infoLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -7).isActive = true
            infoLabel.anchor(bottom: infoView.bottomAnchor, paddingBottom: 7)
            
            
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
            
            
            if lightModeOn{
                infoView.backgroundColor = colorList.bgColorForExtrasLM
                // 들췄을 때 color
                tableView.backgroundColor = colorList.bgColorForEmptyAndNumbersLM
                
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
//            tableView.pin(to: view) // 이거같은데?
            tableView.fillSuperview()
            
            tableView.backgroundColor = lightModeOn ? colorList.bgColorForEmptyAndNumbersLM : colorList.bgColorForEmptyAndNumbersDM
        }
    }
    
    @objc func moveToBaseVC(){
        if basicVCWillDisappear{
            basicVCWillDisappear.toggle()
        }
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func setupAddTargets(){
        historyClickButton.addTarget(self, action: #selector(moveToBaseVC), for: .touchUpInside)
        historyClickButton.addTarget(self, action: #selector(moveToBaseVC), for: .touchDragExit)
        trashButton.addTarget(self, action: #selector(removeAllAlert), for: .touchUpInside)
    }
    
    @objc func removeAllAlert(){
        showAlert(title: "Clear History", message: localizedStrings.removeAll,
                  handlerA: { actionA in
                  },
                  handlerB: { actionB in
                    
                    for element in self.historyRecords{
                        RealmService.shared.delete(element)
                    }
                    self.tableView.reloadData()
                    
//                    self.showToast(message: self.localizedStrings.deleteAllComplete, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getDeviceSize()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667, widthRatio: 0.6, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
                    
                    self.toastHelper(msg: self.localizedStrings.deleteAllComplete, wRatio: 0.6, hRatio: 0.4)
                  })
    }
    
    @objc func changeColorToOriginal(sender : UITableViewCell){
        print("backToOriginalColor table")
        if lightModeOn{
            sender.backgroundColor = colorList.bgColorForEmptyAndNumbersLM
        }else{
            sender.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
        }
    }
    
    func toastHelper(msg: String, wRatio: Float, hRatio: Float) {
        showToast(message: msg,
                  defaultWidthSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667,
                  defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667,
                  widthRatio: wRatio, heightRatio: hRatio,
                  fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
    }
    
    let infoView = UIView()
    
    let infoLabel : UILabel = {
        let label = UILabel()
        label.text = "History"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
//    let trashButton : UIButton = {
//        let sub = UIButton(type: .custom)
//        sub.translatesAutoresizingMaskIntoConstraints = false
//        return sub
//    }()
    let trashButton = UIButton()
    
//    let historyClickButton : UIButton = {
//        let sub = UIButton(type: .custom)
//        sub.translatesAutoresizingMaskIntoConstraints = false
//        return sub
//    }()
    let historyClickButton = UIButton()
    
    
//    let fillBottom : UIView = {
//        let sub = UIView()
//        sub.translatesAutoresizingMaskIntoConstraints = false
//        return sub
//    }()
    
//    let subHistoryLight : UIImageView = {
//        let sub = UIImageView(image: #imageLiteral(resourceName: "light_up"))
//        sub.translatesAutoresizingMaskIntoConstraints = false
//        return sub
//    }()
    let subHistoryLight = UIImageView(image: #imageLiteral(resourceName: "light_up"))
    
//    let subHistoryDark : UIImageView = {
//        let sub = UIImageView(image: #imageLiteral(resourceName: "dark_up"))
//        sub.translatesAutoresizingMaskIntoConstraints = false
//        return sub
//    }()
    let subHistoryDark = UIImageView(image: #imageLiteral(resourceName: "dark_up"))
}





// MARK: - Table view data source.
extension HistoryRecordVC : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryRecordReuseIdentifier") as? HistoryRecordCell else{ return UITableViewCell()}
        
        //reverse mode,  top the latest
        let maxNumber = historyRecords.count
        let historyIndex = maxNumber - indexPath.row - 1
        
        let historyRecord = historyRecords[historyIndex]
        
        cell.configure(with: historyRecord, orientationPortrait : portraitMode, willbasicVCdisappear : basicVCWillDisappear)
        cell.setupColor(isLightModeOn: lightModeOn)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let maxNumber = historyRecords.count
        let historyIndex = maxNumber - indexPath.row - 1
        
        
        FromTableToBaseVCdelegate?.pasteAnsFromHistory(ansString: historyRecords[historyIndex].resultString ?? "nothing transmitted")
        
        loadData()
        
        if !(!UIDevice.current.orientation.isPortrait && !basicVCWillDisappear){
            moveToBaseVC()
        }
    }
    
    
//    func showEditTitleAlert(handler:(UIAlertAction) -> Void) {
//        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: UIAlertController.Style.alert)
//
//        alertController.addTextField { (textField : UITextField!) -> Void in
//            textField.placeholder = "Name value!"
//        }
//
//        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
//            let textFieldInput = alertController.textFields![0] as UITextField
//            print("input: \(textFieldInput.text)")
//        })
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
//                                            (action : UIAlertAction!) -> Void in })
//
//        alertController.addAction(saveAction)
//        alertController.addAction(cancelAction)
//
//        self.present(alertController, animated: true, completion: nil)
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editName = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
            var userInput = ""
            
            if self.historyRecords[historyIndex].titleLabel != nil {
                userInput = self.historyRecords[historyIndex].titleLabel!
            }
            // alert
            let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: UIAlertController.Style.alert)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = userInput
            }
            
            let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let textFieldInput = alertController.textFields![0] as UITextField
                print("placeholder: \(textFieldInput.placeholder)")
                print("textInput: \(textFieldInput.text)")
                
                if textFieldInput.placeholder != "" && textFieldInput.text == "" {
                    userInput = textFieldInput.placeholder!
                } else {
                    userInput = textFieldInput.text!
                }
                
                if let record = self.historyRecords?[historyIndex]{
                    let dictionary : [String : Any?] = ["processOrigin": record.processOrigin,
                                                        "processStringHis": record.processStringHis,
                                                        "processStringHisLong": record.processStringHisLong,
                                                        "processStringCalc": record.processStringCalc,
                                                        "resultString": record.resultString,
                                                        //"resultValue": record.resultValue,
                                                        "dateString": record.dateString,
                                                        "titleLabel": userInput
                    ]
                    
                    RealmService.shared.update(record, with: dictionary)
                    tableView.reloadData()
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
                                                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            
            
            
            completionHandler(true)
        }
        
        let delete = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
            if let record = self.historyRecords?[historyIndex]{
                RealmService.shared.delete(record)
//                RealmService.shared.delete(<#T##object: T##T#>)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
//            self.showToast(message: self.localizedStrings.deleteComplete, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getDeviceSize()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
            self.toastHelper(msg: self.localizedStrings.deleteComplete, wRatio: 0.4, hRatio: 0.04)
            tableView.reloadData()
            completionHandler(true)
            
        }
        editName.image = UIImage(systemName: "pencil")
        editName.backgroundColor = colorList.textColorForSemiResultDM
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete, editName])
        return rightSwipe
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        let copyAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
            if self.portraitMode{
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
            
//            self.showToast(message: self.localizedStrings.copyComplete, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getDeviceSize()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
            self.toastHelper(msg: self.localizedStrings.copyComplete, wRatio: 0.5, hRatio: 0.04)
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
            if self.portraitMode{
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
