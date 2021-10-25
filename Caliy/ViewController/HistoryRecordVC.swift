

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
    
    
    var deviceInfo = UIDevice.modelName
    
    let fontSize = FontSizes()
    let frameSize = FrameSizes()
    var tableView = UITableView()
    
    var historyRecords : Results<HistoryRecord>!
    
    let colorList = ColorList()
    
    var userDefaultSetup = UserDefaultSetup()

    lazy var darkModeOn = userDefaultSetup.getDarkMode()
    
    let realm = RealmService.shared.realm
    
    let trashbinImage = UIImageView(image: #imageLiteral(resourceName: "trashBinSample"))
    let trashbinHelper = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    var portraitMode = true
    
    var basicVCWillDisappear = false
    
    var FromTableToBaseVCdelegate : FromTableToBaseVC?
    
    let localizedStrings = LocalizedStringStorage()
    
    
    
    let ansToTableNotification = Notification.Name(rawValue: NotificationKey.answerToTableNotification.rawValue)
    let viewWillTransitionNotification = Notification.Name(rawValue: NotificationKey.viewWilltransitionNotification.rawValue)
    let viewWillDisappearBasicVCNotification = Notification.Name(rawValue: NotificationKey.viewWillDisappearbaseViewController.rawValue)
    let viewWillAppearBasicVCNotification = Notification.Name(rawValue: NotificationKey.viewWillAppearbaseViewController.rawValue)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("HistoryRecordVC has been deinitialized")
    }
    
    
    
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
    
    override func viewDidLoad() {
        print("viewDidLoad table")
        if deviceInfo.first == " "{
            deviceInfo.removeFirst()
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
        
        darkModeOn = userDefaultSetup.getDarkMode()
        
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

    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear table")
        viewDidLoad()
    }
    
    
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
        let paddingForNotch : CGFloat = UIDevice.hasNotch ? 0 : 34
        
        print("setupLayout table")
        for subview in tableView.subviews{
            subview.removeFromSuperview()
        }
        
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
        view.addSubview(tableView)
        
        if portraitMode{
            tableView.pinWithSpace2(to: view, type : userDefaultSetup.getDeviceSize())
            
            view.addSubview(infoView)
            infoView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
            
            
            switch userDefaultSetup.getDeviceSize() {
            case DeviceSize.smallest.rawValue:  infoView.setHeight(50)
            case DeviceSize.small.rawValue:  infoView.setHeight(80)
            case DeviceSize.medium.rawValue:  infoView.setHeight(80)
            case DeviceSize.large.rawValue:  infoView.setHeight(70)
            default:infoView.setHeight(80)
            }
            
            // no constraints for infoLabel width
            infoView.addSubview(infoLabel)
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            
            infoLabel.centerX(inView: infoView)
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
            
            
            if darkModeOn{
                infoView.backgroundColor = colorList.bgColorForExtrasDM
                infoLabel.textColor = .white
                
                tableView.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
                
                view.addSubview(subHistoryDark)
                
                
                
                subHistoryDark.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 30, paddingBottom: paddingForNotch)
                
                subHistoryDark.setDimensions(width: 40, height: 40)
                
                
                
            }else{
                infoView.backgroundColor = colorList.bgColorForExtrasLM
                // 들췄을 때 color
                tableView.backgroundColor = colorList.bgColorForEmptyAndNumbersLM
                
                view.addSubview(subHistoryLight)
                
                subHistoryLight.anchor(left: view.leftAnchor, bottom: view.safeBottomAnchor, paddingLeft: 30)
                                
                
                
                subHistoryLight.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 30, paddingBottom: paddingForNotch)
                
                
                
                subHistoryLight.setDimensions(width: 40, height: 40)
                
            }
            
            view.addSubview(historyClickButton)
            

            
            
            historyClickButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 30, paddingBottom: paddingForNotch)
            

            historyClickButton.setDimensions(width: 40, height: 40)
            
        }else{
//            tableView.pin(to: view) // 이거같은데?
            tableView.fillSuperview()
            
            tableView.backgroundColor = darkModeOn ? colorList.bgColorForEmptyAndNumbersDM : colorList.bgColorForEmptyAndNumbersLM
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
                    
                    self.toastHelper(msg: self.localizedStrings.deleteAllComplete, wRatio: 0.3, hRatio: 0.04)
                  })
    }
    
    @objc func changeColorToOriginal(sender : UITableViewCell){
        print("backToOriginalColor table")
        if darkModeOn{
            sender.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
        }else{
            sender.backgroundColor = colorList.bgColorForEmptyAndNumbersLM
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
    
    let trashButton = UIButton()
    
    let historyClickButton = UIButton()
    
    let subHistoryLight = UIImageView(image: #imageLiteral(resourceName: "light_up")) // history Button Image
    
    let subHistoryDark = UIImageView(image: #imageLiteral(resourceName: "dark_up")) // history Button Image
}







// MARK: - Table view data source.
//extension HistoryRecordVC : UITableViewDataSource, UITableViewDelegate{
extension HistoryRecordVC : UITableViewDataSource{
    
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
        cell.setupColor(isDarkModeOn: darkModeOn)
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
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editName = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            let maxNumber = self.historyRecords.count
            let historyIndex = maxNumber - indexPath.row - 1
            
            var userInput = ""
            
            if self.historyRecords[historyIndex].titleLabel != nil {
                userInput = self.historyRecords[historyIndex].titleLabel!
            }
            // alert
            let alertController = UIAlertController(title: self.localizedStrings.editName, message: "", preferredStyle: UIAlertController.Style.alert)
            
            
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = userInput
            }
            
            let saveAction = UIAlertAction(title: self.localizedStrings.save, style: UIAlertAction.Style.default, handler: { alert -> Void in
                let textFieldInput = alertController.textFields![0] as UITextField
//                textFieldInput.delegate = self
                
                textFieldInput.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                
                if textFieldInput.text!.count >= 30 {
                    textFieldInput.deleteBackward()
                }
                
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
            
            let cancelAction = UIAlertAction(title: self.localizedStrings.cancel, style: UIAlertAction.Style.destructive, handler: {
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
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            self.toastHelper(msg: self.localizedStrings.deleteComplete, wRatio: 0.2, hRatio: 0.04)
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("sender.text: \(textField.text!)")
        
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
            
            self.toastHelper(msg: self.localizedStrings.copyComplete, wRatio: 0.25, hRatio: 0.04)
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

extension HistoryRecordVC : UITableViewDelegate {
    
}
