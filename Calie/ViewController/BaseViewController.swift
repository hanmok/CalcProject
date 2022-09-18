
import UIKit
import AudioToolbox
import RealmSwift


class BaseViewController: UIViewController, FromTableToBaseVC {
    
    //MARK: - Basic setup

    /// basic Calculator Model
    let basicCalc = BasicCalculator()
    
    /// used to place HistoryRecordVC on the left side in landscape mode
    let childTableVC = HistoryRecordVC()
    
    /// used to navigate to historyRecordVC
    let newTableVC = HistoryRecordVC()
    
    var colorIndex = 0
    let colorList = ColorList()
    let localizedStrings = LocalizedStringStorage()     // show Toast
    let fontSize = FontSizes()      // view, show Toast
    let frameSize = FrameSizes()    // view
    
    var userDefaultSetup = UserDefaultSetup() // model, view
    // USERDEFAULT VALUES
//    lazy var isDarkMode = userDefaultSetup.darkModeOn
//    lazy var isSoundOn = userDefaultSetup.getSoundMode()
//    lazy var isNotificationOn = userDefaultSetup.getNotificationMode()
//    lazy var deviceSize = userDefaultSetup.getDeviceSize()
    
    /// entire view for basic calculator (not HistoryRecordVC)
    var frameView = UIView()
    
    // MARK: - For Color Testing
    var isShowing = true
    
    let upButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("+1", for: .normal)
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 5
        return btn
    }()

    let downButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("-1", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 5
        return btn
    }()
    
    let colorIndexLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .black
        return label
    }()
    
    let colorDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = .black
        return label
    }()
    
    let testToggleButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("hide", for: .normal)
        btn.setTitleColor(UIColor(red: 0.537, green: 0.541, blue: 0.454, alpha: 0.3), for: .normal)
        return btn
    }()
    
  
    /// belong to view
    var portraitMode = true     // view
    
    
    // LAYOUT
    lazy var multiplier = 1 - 0.108*5 - tabbarheight/frameView.frame.height
    
    lazy var tabbarheight = tabBarController?.tabBar.bounds.size.height ?? 83
    // 83 이 아닌데 ?? 
    
//    lazy var tabbarheight = tabBarController?.tabBar.bounds.size.height ?? 98
    
    
    /// indicate whether ans button has pressed
    var ansPressed = false // this one is used.
    
    
    
    
    // MARK: - NOTIFICATION, RECEIVERS
    let ansFromTableNotification = Notification.Name(rawValue: NotificationKey.ansFromTableNotification.rawValue)
    
    
    let processToBaseVCNotification = Notification.Name(rawValue: NotificationKey.processToBaseVCNotification.rawValue)
    
    let resultToBaseVCNotification = Notification.Name(rawValue: NotificationKey.resultToBaseVCNotification.rawValue)
    
    let scrollToVisibleNotification = Notification.Name(rawValue: NotificationKey.progressViewScrollToVisibleNotification.rawValue)
    
    let resultTextColorChangeNotification = Notification.Name(rawValue: NotificationKey.resultTextColorChangeNotification.rawValue)
    
    let sendingToastNotification = Notification.Name(rawValue: NotificationKey.sendingToastNotification.rawValue)
    
    let updateUserDefaultNotification = Notification.Name(rawValue: NotificationKey.sendUpdatingUserDefaultNotification.rawValue)
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    
   
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        portraitMode = screenHeight > screenWidth ? true : false
        
        childTableVC.FromTableToBaseVCdelegate = self
        newTableVC.FromTableToBaseVCdelegate = self
        
        super.viewDidLoad()
        
        setupUserDefaults()
        setupPositionLayout()
        setupColorAndImage()
        setupAddTargets()
        
        createObservers()
        
        navigationController?.navigationBar.isHidden = true
        print("darkMode in baseVC: \(userDefaultSetup.darkModeOn)")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape {
            portraitMode = false
            
        } else if UIDevice.current.orientation.isPortrait {
            portraitMode = true
        }
        
        setupPositionLayout()
        setupColorAndImage()
        setupAddTargets()
        
        basicCalc.printProcess()
        
        let isPortrait = ["orientation" : portraitMode]
        let name = Notification.Name(rawValue: NotificationKey.viewWilltransitionNotification.rawValue)
        
        NotificationCenter.default.post(name: name, object: nil, userInfo: isPortrait as [AnyHashable : Any])
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let name = Notification.Name(rawValue: NotificationKey.viewWillAppearbaseViewController.rawValue)
        NotificationCenter.default.post(name : name, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let name = Notification.Name(rawValue: NotificationKey.viewWillDisappearbaseViewController.rawValue)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    
    
    
    // MARK: - NOTIFICATION CENTER
    func createObservers() {
//        From Model -> Self, Update ProgressText
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.updateProcess(notification:)), name: processToBaseVCNotification, object: nil)
        
//        From  Model , Update ResultText
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.updateResult(notification:)), name: resultToBaseVCNotification, object: nil)
        
//        From Model, update ResultText Color depends on whether ans has obtained
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.updateResultTextColor(notification:)), name: resultTextColorChangeNotification, object: nil)
        
//        From Model, send Toast depend on cases
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.sendToast(notification:)), name: sendingToastNotification, object: nil)
        
//        From Model, scroll PregressText to see current Inputs
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.scrollToVisible(notification:)), name: scrollToVisibleNotification, object: nil)
        
//        From SettingViewController, update screen & sound mode.
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.updateModes(notification:)), name: updateUserDefaultNotification, object: nil)
    }
    
    
    // MARK: - Notification Handlers
    @objc func updateProcess(notification: NSNotification) {
        guard let receivedProcess = notification.userInfo?["process"] as? String else {
            print("there's an error in receiving process from basicCalculator")
            return
        }
        progressView.text = receivedProcess
    }
    
    
    @objc func updateResult(notification: NSNotification) {
        guard let receivedResult = notification.userInfo?["result"] as? String else {
            print("there's an error in receiving result from basicCalculator")
            return
        }
        print("flag3, receivedResult: \(receivedResult)")
        resultTextView.text = receivedResult
    }
    
    
    @objc func updateResultTextColor(notification: NSNotification) {
        guard let receivedAnsPressed = notification.userInfo?["ansPressed"] as? Bool else {
            print("there's an error in receiving result from basicCalculator")
            return
        }
        if receivedAnsPressed {
            resultTextView.textColor = userDefaultSetup.darkModeOn ? colorList.textColorForResultDM : colorList.textColorForResultLM
            
        } else {
            resultTextView.textColor = userDefaultSetup.darkModeOn ? colorList.textColorForSemiResultDM : colorList.textColorForSemiResultLM
        }
    }
    
    
    @objc func sendToast(notification: NSNotification) {
        
        guard let toastCase = notification.userInfo?["toastCase"] as? ToastEnum else {
            print("there's an error in receiving message from basicCalculator")
            return
        }
        var isKorean = true
        if let languageCode = Locale.current.languageCode{
            if !languageCode.contains("ko"){
                isKorean = false
            }
        }
        
        print("isKorean: \(isKorean)")
        
        switch toastCase {
        case .answerLimit:
            if isKorean {
                self.toastHelper(msg: localizedStrings.answerLimit, wRatio: 0.7, hRatio: 0.04)
            } else {
                self.toastHelper(msg: localizedStrings.answerLimit, wRatio: 0.6, hRatio: 0.08)
            }
        case .numberLimit:
            self.toastHelper(msg: localizedStrings.numberLimit, wRatio: 0.8, hRatio: 0.04)
        case .floatingLimit:
            if isKorean {
                self.toastHelper(msg: localizedStrings.floatingLimit, wRatio: 0.7, hRatio: 0.04)
            } else {
                self.toastHelper(msg: localizedStrings.floatingLimit, wRatio: 0.6, hRatio: 0.08)
            }
        case .modified:
            if userDefaultSetup.notificationOn {
                self.toastHelper(msg: localizedStrings.modified, wRatio: 0.4, hRatio: 0.04)
            }
        case .saved:
            self.toastHelper(msg: localizedStrings.savedToHistory, wRatio: 0.4, hRatio: 0.04)
        }
    }
    
    
    @objc func scrollToVisible(notification: NSNotification) {
            progressView.scrollRangeToVisible(progressView.selectedRange)
    }
    
    
    @objc func updateModes(notification: NSNotification) {
        guard let darkModeInfo = notification.userInfo?["isDarkOn"] as? Bool else {
            print("something is wrong with isDarkOn in BaseViewController")
            return
        }
        guard let soundModeInfo = notification.userInfo?["isSoundOn"] as? Bool else {
            print("something is wrong with soundMode in BaseViewController")
            return
        }
        guard let notificationModeInfo = notification.userInfo?["isNotificationOn"] as? Bool else {
            print("something is wrong with soundMode in BaseViewController")
            return
        }
        
        
        // both of these updates each time
//        isDarkMode = darkModeInfo
//        userDefaultSetup
//        isSoundOn = soundModeInfo
//        isNotificationOn = notificationModeInfo
        
        setupColorAndImage()
        
        
//        view.backgroundColor = colorList.testColors2[23].color
//        view.backgroundColor = isDarkMode ? colorList.newMainForDarkMode : colorList.newMainForLightMode
        view.backgroundColor = userDefaultSetup.darkModeOn ? colorList.bgColorForExtrasDM : colorList.bgColorForExtrasLM
    }
    
    
    
    // MARK: - from History, delegate pattern
    // send ans     HistoryRecordVC -> BaseVC -> calculator
    func pasteAnsFromHistory(ansString: String) { //
        basicCalc.didReceiveAnsFromTable(receivedValue: ansString)
    }
   

    // MARK: - Button Tap Action Handlers
    
    
    // View - > Controller -> BasicCalculator. send when button tapped
    @objc func handleNumberTapped(sender : UIButton){
        basicCalc.didReceiveNumber(sender.tag)
    }
    
    @objc func handleOperationTapped(sender : UIButton){
        basicCalc.didReceiveOper(senderTag: sender.tag)
    }
    
    @objc func handlePerenthesisTapped(sender : UIButton){
        basicCalc.didReceiveParen(sender.tag)
    }
    
    @objc func handleDeleteAction(){
        basicCalc.didReceiveDelete()
    }
    
    @objc func handleClearTapped(sender : UIButton){
        basicCalc.didReceiveClear()
    }
    
    @objc func handleAnsTapped(sender : UIButton){
        basicCalc.didReceiveAns()
        basicCalc.calculateAns()
    }
    
    @objc func handleLongDeleteAction(){
        basicCalc.didPressedDeleteLong()
    }
    
    
    
    
    // tags -2 ~ 9 : number, 11 ~ 18 : operators, delete: 21
    @objc func turnIntoOriginalColor(sender : UIButton){
        if userDefaultSetup.darkModeOn{
            switch sender.tag {
            case -2 ... 9:
                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
            case 10 ... 20 :
                sender.backgroundColor =  colorList.bgColorForOperatorsDM
            case 21 ... 30 :
//                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
                sender.backgroundColor = colorList.bgColorForExtrasDM
                basicCalc.invalidateAllTimers()
            default :
//                sender.backgroundColor = .magenta
                break
            }
        }else{
            switch sender.tag {
            case -2 ... 9:
                sender.backgroundColor = colorList.bgColorForEmptyAndNumbersLM
            case 10 ... 20 :
                sender.backgroundColor =  colorList.bgColorForOperatorsLM

            case 21 ... 30 :
//                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersLM
                sender.backgroundColor = colorList.bgColorForExtrasLM
                basicCalc.invalidateAllTimers()
            default :
//                sender.backgroundColor = .magenta
                break
            }
        }
    }
    
    
    @objc func handleDeleteDragOutAction(sender : UIButton){ // deleteDragOut
        basicCalc.didDragOutDelete()
    }
    
    
    
    // deletePressedDown
    @objc func handleDeletePressedDown(sender : UIButton){

        if userDefaultSetup.darkModeOn{
//            sender.backgroundColor =  colorList.bgColorForExtrasDM
            sender.backgroundColor = colorList.bgColorForOperatorsDM
        }else{
//            sender.backgroundColor =  colorList.bgColorForExtrasLM
            sender.backgroundColor = colorList.bgColorForOperatorsLM
        }
        basicCalc.didPressedDownDelete()
    }
    
    
    @objc func handleDeleteTapped(sender : UIButton){
//        sender.backgroundColor = colorList.bgColorForEmptyAndNumbersLM
        sender.backgroundColor = colorList.bgColorForOperatorsDM
        basicCalc.handleDeleteTapped()
    }

    
    @objc func handleSoundAction(sender: UIButton) {
        playSound()
    }
    
     /// when button tapped 'down', change colors
    @objc func handleColorChangeAction(sender: UIButton) {
        sender.backgroundColor = userDefaultSetup.darkModeOn ? colorList.bgColorForExtrasDM : colorList.bgColorForExtrasLM
    }
    
    /// triggerd when historyButton Tapped
    @objc func moveToHistoryTable(sender : UIButton){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        newTableVC.modalPresentationStyle = .fullScreen
        self.present(newTableVC, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Other Functions
    
    /// 보류 settings
    func setupUserDefaults(){
//        if userDefaultSetup.getHasEverChanged(){
//        userDefaultSetup.everChanged {
////            isDarkMode = userDefaultSetup.darkModeOn
////            isSoundOn = userDefaultSetup.getSoundMode()
////            isNotificationOn = userDefaultSetup.getNotificationMode()
//
//        }
//        else{ // initial value . when a user first download.
//            print("flag2, this line has called")
////            userDefaultSetup.setDarkMode(isDarkMode: true)
////            userDefaultSetup.darkModeOn = true
////            userDefaultSetup.setNotificationMode(isNotificationOn: false)
////            userDefaultSetup.setSoundMode(isSoundOn: true)
//
//        }
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        
        let maxLength = screenWidth > screenHeight ? screenWidth : screenHeight
        
        switch maxLength {
        case 0 ... 800:
//            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "A")
//            userDefaultSetup.setDeviceSize(size: DeviceSize.smallest.rawValue)
            userDefaultSetup.deviceSize = DeviceSize.smallest.rawValue
        case 801 ... 1000:
//            userDefaultSetup.setDeviceSize(size: DeviceSize.small.rawValue)
            userDefaultSetup.deviceSize = DeviceSize.small.rawValue
        case 1001 ... 1100:
//            userDefaultSetup.setDeviceSize(size: DeviceSize.medium.rawValue)
            userDefaultSetup.deviceSize = DeviceSize.medium.rawValue
        case 1101 ... 1500:
//            userDefaultSetup.setDeviceSize(size: DeviceSize.large.rawValue)
            userDefaultSetup.deviceSize = DeviceSize.large.rawValue
        default:
//            userDefaultSetup.setDeviceSize(size: DeviceSize.smallest.rawValue)
            userDefaultSetup.deviceSize = DeviceSize.smallest.rawValue
        }
    }
    
    
    func playSound(){
//        if isSoundOn {
        if userDefaultSetup.soundOn {
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    
    func toastHelper(msg: String, wRatio: Float, hRatio: Float) {
        showToast(message: msg,
                  defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.deviceSize] ?? 375,
                  defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.deviceSize] ?? 667,
                  widthRatio: wRatio, heightRatio: hRatio,
                  fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.deviceSize] ?? 13)
    }

    //MARK: - < Main Functional Section Ends >
    
    
    
    
    
    
    
    //MARK: - < UI Section Starts >
    
    //MARK: - setup images transparent
    var subHistory = transparentImage
    var sub0 = transparentImage
    var sub00 = transparentImage
    var sub1 = transparentImage
    var sub2 = transparentImage
    var sub3 = transparentImage
    var sub4 = transparentImage
    var sub5 = transparentImage
    var sub6 = transparentImage
    var sub7 = transparentImage
    var sub8 = transparentImage
    var sub9 = transparentImage
    var subDot = transparentImage
    let subsubDot = transparentImage
    var subPlus = transparentImage
    var subMinus = transparentImage
    var subMulti = transparentImage
    var subDivide = transparentImage
    var subClear = transparentImage
    var subOpenpar = transparentImage
    var subClosepar = transparentImage
    var subEqual = transparentImage

    
    let num0 = ButtonTag(withTag: 0)
    let num1 = ButtonTag(withTag: 1)
    let num2 = ButtonTag(withTag: 2)
    let num3 = ButtonTag(withTag: 3)
    let num4 = ButtonTag(withTag: 4)
    let num5 = ButtonTag(withTag: 5)
    let num6 = ButtonTag(withTag: 6)
    let num7 = ButtonTag(withTag: 7)
    let num8 = ButtonTag(withTag: 8)
    let num9 = ButtonTag(withTag: 9)
    let num00 = ButtonTag(withTag: -1)
    let numberDot = ButtonTag(withTag: -2)
    
    let clearButton = ButtonTag(withTag: 11)
    let openParenthesis = ButtonTag(withTag: 12)
    let closeParenthesis = ButtonTag(withTag: 13)
    let operationButtonDivide = ButtonTag(withTag: 14)
    let operationButtonMultiply = ButtonTag(withTag: 15)
    let operationButtonPlus = ButtonTag(withTag: 16)
    let operationButtonMinus = ButtonTag(withTag: 17)
    let equalButton = ButtonTag(withTag: 18)
    
    let deleteButton : UIButton = {
        let del = UIButton(type: .custom)
        del.translatesAutoresizingMaskIntoConstraints = false
        del.tag = 21
        
        let sub = UIImageView(image: #imageLiteral(resourceName: "delD")) // delete Image.
        del.addSubview(sub)
//        del.backgroundColor = .magenta
        sub.center(inView: del)
        sub.widthAnchor.constraint(equalTo: del.heightAnchor, multiplier: 0.5625).isActive = true
        sub.heightAnchor.constraint(equalTo: del.heightAnchor, multiplier: 0.5).isActive = true
        
        return del
    }()
    
    
    let emptySpace = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    let resultTextView : UITextView = {
        let result = UITextView()
        result.textAlignment = .right
        result.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        result.adjustsFontForContentSizeCategory = true
        result.textContainer.maximumNumberOfLines = 1
        result.isUserInteractionEnabled = true
        result.isEditable = false
        return result
    }()
    
    
    var progressView : UITextView = {
        let progress = UITextView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.isUserInteractionEnabled = true
        progress.isEditable = false
        progress.textAlignment = .right
        progress.font = UIFont.preferredFont(forTextStyle: .body)
        progress.adjustsFontForContentSizeCategory = true
        return progress
    }()
    
    
    let deleteWidthReference = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    let deleteHeightReference = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    let resultWidthReference = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    let resultHeightReference = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    let progressWidthReference = UIImageView(image: #imageLiteral(resourceName: "transparent"))

    let progressHeightReference = UIImageView(image: #imageLiteral(resourceName: "transparent"))
    
    let historyClickButton = UIButton()
    
    let historyDragButton = UIButton()
    
    let rightSideForLandscapeMode = UIView()
    
    let leftSideForLandscapeMode = UIView()
    
    //MARK: - <#UI Section Not Included Any Function End.
    
    func setupPositionLayout(){
        
        for subview in frameView.subviews{
            subview.removeFromSuperview()
        }
        
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
        let horStackView1 : [UIButton] = [num0, num00, numberDot, equalButton]
        let horStackView2 : [UIButton] = [num1, num2, num3, operationButtonPlus]
        let horStackView3 : [UIButton] = [num4, num5, num6, operationButtonMinus]
        let horStackView4 : [UIButton] = [num7, num8, num9, operationButtonMultiply]
        let horStackView5 : [UIButton] = [clearButton, openParenthesis, closeParenthesis, operationButtonDivide]
        
        let numAndOper : [UIButton] = horStackView1 + horStackView2 + horStackView3 + horStackView4 + horStackView5
        
        let verStackView0 : [UIButton] = [clearButton, num7, num4, num1, num0]
        let verStackView1 : [UIButton] = [openParenthesis, num8, num5, num2, num00]
        let verStackView2 : [UIButton] = [closeParenthesis, num9, num6, num3, numberDot]
        let verStackView3 : [UIButton] = [operationButtonDivide, operationButtonMultiply, operationButtonPlus, operationButtonMinus, equalButton]
        
        
        if portraitMode{ // Portrait Mode
            tabBarController?.tabBar.isHidden = false
            frameView = view
            
        } else if !portraitMode{ // LandScape Mode
            tabBarController?.tabBar.isHidden = true
            
            //right side (calculator)
            view.addSubview(rightSideForLandscapeMode)
            
            rightSideForLandscapeMode.anchor(top: view.topAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
            rightSideForLandscapeMode.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.562).isActive = true
            
            //what are these lines?
            frameView = rightSideForLandscapeMode as UIView
            frameView.translatesAutoresizingMaskIntoConstraints = false
            
            //additional setup for tableView at the left side.
            view.addSubview(leftSideForLandscapeMode)

            leftSideForLandscapeMode.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor)
            leftSideForLandscapeMode.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.438).isActive = true
            

            
            addChild(childTableVC)
            //            adds the specified ViewController as a child of current view controller
            view.addSubview(childTableVC.view)
            //            childTableVC.didMove(toParent: self)
            //            Called after the view controller is added or removed from a container view controller.
            
            childTableVC.view.anchor(left: view.leftAnchor, bottom: view.bottomAnchor)
            childTableVC.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.438).isActive = true
            childTableVC.view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        }
        
        
        
        // execute all the time (portrait and landscape mode)
        for button in numAndOper{
            frameView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            if portraitMode{
                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.108).isActive = true
            }else{
                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: CGFloat(0.108*1.2)).isActive = true
            }
            
            button.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.25).isActive = true
            
            button.layer.borderWidth = 0.23
            button.layer.borderColor = CGColor(genericGrayGamma2_2Gray: 0, alpha: 0.15)
            //frameView : view or rightSideForLandscapeMode view (UIView)
        }
        
        
        if portraitMode{
            
            for button in horStackView1{
                button.anchor(bottom: view.safeBottomAnchor)
//                button.anchor(bottom: view.bottomAnchor)
            }
            
        }else {
            for button in horStackView1{
                button.anchor(bottom: frameView.bottomAnchor)
            }
        }
        
        
        for button in horStackView2{
            button.anchor(bottom: num0.topAnchor)
        }
        for button in horStackView3{
            button.anchor(bottom: num1.topAnchor)
        }
        for button in horStackView4{
            button.anchor(bottom: num4.topAnchor)
        }
        for button in horStackView5{
            button.anchor(bottom: num7.topAnchor)
        }
        
        for button in verStackView0{
            button.anchor(left: frameView.leftAnchor)
        }
        for button in verStackView1{
            button.anchor(left: num0.rightAnchor)
        }
        for button in verStackView2{
            button.anchor(left: num00.rightAnchor)
        }
        for button in verStackView3{
            button.anchor(left: numberDot.rightAnchor, right: view.rightAnchor)
        }
        
        frameView.addSubview(emptySpace)
        
        frameView.addSubview(deleteWidthReference)
        frameView.addSubview(deleteHeightReference)
        frameView.addSubview(deleteButton)
        
        frameView.addSubview(resultWidthReference)
        frameView.addSubview(resultHeightReference)
        frameView.addSubview(resultTextView)
        
        frameView.addSubview(progressWidthReference)
        frameView.addSubview(progressHeightReference)
        frameView.addSubview(progressView)
        
        if portraitMode{
            
            emptySpace.anchor(top: frameView.topAnchor, left: frameView.leftAnchor, right: frameView.rightAnchor)
            emptySpace.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: multiplier).isActive = true
            
            // only applied to portrait Mode
            
            deleteWidthReference.anchor(right: frameView.rightAnchor)
            deleteWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.122).isActive = true
//            print(#line, #function)
            deleteHeightReference.anchor(bottom: emptySpace.bottomAnchor)
            deleteHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.1446010638).isActive = true
            
            deleteButton.centerXAnchor.constraint(equalTo: deleteWidthReference.leftAnchor).isActive = true
            deleteButton.centerYAnchor.constraint(equalTo: deleteHeightReference.topAnchor).isActive = true
            deleteButton.widthAnchor.constraint(equalTo: emptySpace.widthAnchor, multiplier: 0.18).isActive = true
            deleteButton.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.255).isActive = true
            
            
            resultWidthReference.anchor(right: frameView.rightAnchor)
            resultWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.01).isActive = true
            
            resultHeightReference.anchor(bottom: emptySpace.bottomAnchor)
            resultHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.2978723404).isActive = true
            
            resultTextView.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.27).isActive = true
            resultTextView.anchor(left: emptySpace.leftAnchor, bottom: resultHeightReference.topAnchor, right: resultWidthReference.leftAnchor)
            
            
            progressWidthReference.anchor(right: frameView.rightAnchor)
            progressWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.248).isActive = true
            
            progressHeightReference.anchor(bottom: emptySpace.bottomAnchor)
            progressHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.02).isActive = true
            
            
            progressView.widthAnchor.constraint(equalTo: emptySpace.widthAnchor, multiplier: 0.6906666667).isActive = true
            progressView.anchor(bottom: progressHeightReference.topAnchor, right: progressWidthReference.leftAnchor)
            progressView.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: 0.264).isActive = true
        }
        else{
            
            let k = 1.307
            emptySpace.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.352).isActive = true
            emptySpace.anchor(top: frameView.topAnchor, left: frameView.leftAnchor, right: frameView.rightAnchor)
            // only applied to portrait Mode
            
            deleteWidthReference.anchor(right: frameView.rightAnchor)
            deleteWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.032).isActive = true
//            print(#line, #function)
            deleteHeightReference.anchor(bottom: emptySpace.bottomAnchor)
            deleteHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.0171*k)).isActive = true
            
            deleteButton.anchor(bottom: deleteHeightReference.topAnchor, right: deleteWidthReference.leftAnchor)
            deleteButton.widthAnchor.constraint(equalTo: emptySpace.widthAnchor, multiplier: 0.18).isActive = true
            deleteButton.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.386364*k)).isActive = true
            
            
            progressWidthReference.anchor(right: frameView.rightAnchor)
            progressWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.248).isActive = true
            
            progressHeightReference.anchor(bottom: emptySpace.bottomAnchor)
            progressHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.02*k)).isActive = true
            
            
            progressView.widthAnchor.constraint(equalTo: emptySpace.widthAnchor, multiplier: 0.6906666667).isActive = true
            progressView.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.35*k)).isActive = true
            progressView.anchor(bottom: progressHeightReference.topAnchor, right: progressWidthReference.leftAnchor)
            
            
            resultWidthReference.anchor(right: frameView.rightAnchor)
            resultWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.01).isActive = true
            
            
            resultHeightReference.anchor(bottom: emptySpace.bottomAnchor)
            resultHeightReference.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.385 * k)).isActive = true
            
            
            resultTextView.heightAnchor.constraint(equalTo: emptySpace.heightAnchor, multiplier: CGFloat(0.30*k)).isActive = true
            resultTextView.anchor(left: emptySpace.leftAnchor, bottom: resultHeightReference.topAnchor, right: resultWidthReference.leftAnchor)
            
        }
        
        if portraitMode{
            frameView.addSubview(historyDragButton)
            frameView.addSubview(historyClickButton)
            
            
            historyClickButton.anchor(top: frameView.safeTopAnchor,left: view.leftAnchor, paddingTop: 5, paddingLeft: 30 )
            historyClickButton.setDimensions(width: 40, height: 40)

            historyDragButton.anchor(top: frameView.safeTopAnchor, left: view.leftAnchor, paddingLeft: 30)
            historyDragButton.setDimensions(width: 40, height: 40)
        }
        
        resultTextView.font = UIFont.systemFont(ofSize: fontSize.resultBasicPortrait[userDefaultSetup.deviceSize]!)
        progressView.font = UIFont.systemFont(ofSize: fontSize.processBasicPortrait[userDefaultSetup.deviceSize]!)
        
        
        view.backgroundColor = userDefaultSetup.darkModeOn ? colorList.bgColorForExtrasDM : colorList.bgColorForExtrasLM
        
        
        
        /*       color Testing Code
        frameView.addSubview(upButton)
        frameView.addSubview(colorIndexLabel)
        frameView.addSubview(downButton)

        frameView.addSubview(colorDescLabel)
        frameView.addSubview(testToggleButton)

        downButton.snp.makeConstraints { make in
            make.top.equalTo(historyClickButton.snp.bottom)
            make.left.equalTo(view).offset(20)
            make.width.height.equalTo(30)
        }


        upButton.snp.makeConstraints { make in
            make.top.equalTo(downButton)
            make.left.equalTo(downButton.snp.right).offset(20)
            make.width.height.equalTo(30)
        }

        colorDescLabel.snp.makeConstraints { make in
            make.top.equalTo(downButton)
            make.left.equalTo(upButton.snp.right).offset(20)
            make.width.equalTo(180)
            make.height.equalTo(30)
        }

        colorIndexLabel.snp.makeConstraints { make in
            make.top.equalTo(downButton)
            make.left.equalTo(colorDescLabel.snp.right)
//            make.width.height.equalTo(30)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }

        testToggleButton.snp.makeConstraints { make in
            make.bottom.equalTo(deleteButton.snp.top)
            make.left.equalTo(colorIndexLabel.snp.right)
            make.width.equalTo(50)
//            make.height.equalTo(30)
            make.height.equalTo(200)
        }
        
        view.backgroundColor = colorList.testColors2[colorIndex].color
         */
    }
    
    func setupAddTargets(){
        
        let numButtons = [num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num0,num00,numberDot]
        let operButtons = [operationButtonDivide,operationButtonMultiply,operationButtonPlus,operationButtonMinus]
        let otherButtons = [clearButton,openParenthesis,closeParenthesis,operationButtonDivide,operationButtonMultiply,operationButtonPlus,operationButtonMinus,equalButton]
        
        for aButton in numButtons {
            aButton.addTarget(self, action: #selector( handleNumberTapped), for: .touchUpInside)
//            aButton.addTarget(self, action: #selector(numberPressedDown), for: .touchDown)
            aButton.addTarget(self, action: #selector(handleSoundAction), for: .touchDown)
            aButton.addTarget(self, action: #selector(handleColorChangeAction), for: .touchDown)
            aButton.addTarget(self, action: #selector(turnIntoOriginalColor), for: .touchUpInside) // does nothing.
            aButton.addTarget(self, action: #selector(turnIntoOriginalColor), for: .touchDragExit)
        }
        for aButton in operButtons{
            aButton.addTarget(self, action: #selector( handleOperationTapped), for: .touchUpInside)
            aButton.addTarget(self, action: #selector(turnIntoOriginalColor), for: .touchDragExit)
        }
        for aButton in otherButtons{
            aButton.addTarget(self, action: #selector(handleSoundAction), for: .touchDown)
            aButton.addTarget(self, action: #selector(handleColorChangeAction), for: .touchDown)
            aButton.addTarget(self, action: #selector(turnIntoOriginalColor(sender:)), for: .touchUpInside)//does nothing
            aButton.addTarget(self, action: #selector(turnIntoOriginalColor), for: .touchDragExit)
        }
        
        equalButton.addTarget(self, action: #selector( handleAnsTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector( handleClearTapped), for: .touchUpInside)
        
        openParenthesis.addTarget(self, action: #selector( handlePerenthesisTapped), for: .touchUpInside)
        closeParenthesis.addTarget(self, action: #selector( handlePerenthesisTapped), for: .touchUpInside)
        
        
        
        deleteButton.addTarget(self, action: #selector(handleDeletePressedDown), for: .touchDown)
        deleteButton.addTarget(self, action: #selector(handleDeleteTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(handleDeleteDragOutAction), for: .touchDragExit)
        
        deleteButton.addTarget(self, action: #selector( turnIntoOriginalColor), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(turnIntoOriginalColor), for: .touchDragExit)
        
        
        
        historyClickButton.addTarget(self, action: #selector(moveToHistoryTable), for: .touchUpInside)
        historyClickButton.addTarget(self, action: #selector(moveToHistoryTable), for: .touchDragExit)
        historyDragButton.addTarget(self, action: #selector(moveToHistoryTable), for: .touchDragExit)
        /*
        upButton.addTarget(self, action: #selector(countUp), for: .touchUpInside)
        downButton.addTarget(self, action: #selector(countDown), for: .touchUpInside)

        testToggleButton.addTarget(self, action: #selector(toggleVisibility), for: .touchUpInside)
         */
    }
    
    /* TestCode
    @objc func countUp(_ sender: UIButton) {
        colorIndex += 1
        if colorIndex == colorList.testColors2.count {
            colorIndex = 0
        }
        colorIndexLabel.text = String(colorIndex)

        view.backgroundColor = colorList.testColors2[colorIndex].color
        colorDescLabel.text = colorList.testColors2[colorIndex].desc
    }
    @objc func countDown(_ sender: UIButton) {
        colorIndex -= 1
        if colorIndex < 0 {
            colorIndex = colorList.testColors2.count - 1
        }
        colorIndexLabel.text = String(colorIndex)
        view.backgroundColor = colorList.testColors2[colorIndex].color
        colorDescLabel.text = colorList.testColors2[colorIndex].desc

    }
    
    @objc func toggleVisibility(_ sender: UIButton) {


            isShowing.toggle()

        if isShowing {
            upButton.isHidden = true
            downButton.isHidden = true
            colorDescLabel.isHidden = true
            colorIndexLabel.isHidden = true
            testToggleButton.setTitle("show", for: .normal)
        } else {
            upButton.isHidden = false
            downButton.isHidden = false
            colorDescLabel.isHidden = false
            colorIndexLabel.isHidden = false
            testToggleButton.setTitle("hide", for: .normal)
        }
    }
     */
    
    fileprivate func setupButtonImageInLightMode() {
        
        sub0 = light0
        sub1 = light1
        
        sub2 = light2
        sub3 = light3
        
        sub4 = light4
        sub5 = light5
        sub6 = light6
        sub7 = light7
        sub8 = light8
        sub9 = light9
        sub00 = light00
        subDot = lightDot
        subClear = lightClear
        subOpenpar = lightOpenParen
        subClosepar = lightCloseParen
        
        subDivide = lightDivide
        subMulti = lightTimes
        subPlus = lightPlus
        subMinus = lightSubtract
        subEqual = lightEqual
        
        subHistory = UIImageView(image: #imageLiteral(resourceName: "light_down"))
    }
    
    fileprivate func setupButtonImageInDarkMode() {
        
        sub0 = dark0
        sub1 = dark1
        
        sub2 = dark2
        sub3 = dark3
        
        sub4 = dark4
        sub5 = dark5
        sub6 = dark6
        sub7 = dark7
        sub8 = dark8
        sub9 = dark9
        sub00 = dark00
        subDot = darkDot
        subClear = darkClear
        subOpenpar = darkOpenParen
        subClosepar = darkCloseParen
        
        subDivide = darkDivide
        subMulti = darkTimes
        subPlus = darkPlus
        subMinus = darkSubtract
        subEqual = darkEqual
        
        subHistory = UIImageView(image: #imageLiteral(resourceName: "dark_down"))
        
    }
    
//    fileprivate func setupButtonPositionAndSize(_ modifiedWidth: inout [Double]) {
    fileprivate func setupButtonPositionAndSize(_ modifiedWidth: [Double]) {
        num0.addSubview(sub0)
        sub0.center(inView: num0)
        sub0.widthAnchor.constraint(equalTo: num0.heightAnchor, multiplier: CGFloat(modifiedWidth[0])).isActive = true
        sub0.heightAnchor.constraint(equalTo: num0.heightAnchor, multiplier: CGFloat(heights[0])).isActive = true
        
        num1.addSubview(sub1)
        sub1.center(inView: num1)
        sub1.widthAnchor.constraint(equalTo: num1.heightAnchor, multiplier: CGFloat(modifiedWidth[1])).isActive = true
        sub1.heightAnchor.constraint(equalTo: num1.heightAnchor, multiplier: CGFloat(heights[1])).isActive = true
        
        num2.addSubview(sub2)
        sub2.center(inView: num2)
        sub2.widthAnchor.constraint(equalTo: num2.heightAnchor, multiplier: CGFloat(modifiedWidth[2])).isActive = true
        sub2.heightAnchor.constraint(equalTo: num2.heightAnchor, multiplier: CGFloat(heights[2])).isActive = true
        
        num3.addSubview(sub3)
        sub3.center(inView: num3)
        sub3.widthAnchor.constraint(equalTo: num3.heightAnchor, multiplier: CGFloat(modifiedWidth[3])).isActive = true
        sub3.heightAnchor.constraint(equalTo: num3.heightAnchor, multiplier: CGFloat(heights[3])).isActive = true
        
        num4.addSubview(sub4)
        sub4.center(inView: num4)
        sub4.widthAnchor.constraint(equalTo: num4.heightAnchor, multiplier: CGFloat(modifiedWidth[4])).isActive = true
        sub4.heightAnchor.constraint(equalTo: num4.heightAnchor, multiplier: CGFloat(heights[4])).isActive = true
        
        num5.addSubview(sub5)
        sub5.center(inView: num5)
        sub5.widthAnchor.constraint(equalTo: num5.heightAnchor, multiplier: CGFloat(modifiedWidth[5])).isActive = true
        sub5.heightAnchor.constraint(equalTo: num5.heightAnchor, multiplier: CGFloat(heights[5])).isActive = true
        
        num6.addSubview(sub6)
        sub6.center(inView: num6)
        sub6.widthAnchor.constraint(equalTo: num6.heightAnchor, multiplier: CGFloat(modifiedWidth[6])).isActive = true
        sub6.heightAnchor.constraint(equalTo: num6.heightAnchor, multiplier: CGFloat(heights[6])).isActive = true
        
        num7.addSubview(sub7)
        sub7.center(inView: num7)
        sub7.widthAnchor.constraint(equalTo: num7.heightAnchor, multiplier: CGFloat(modifiedWidth[7])).isActive = true
        sub7.heightAnchor.constraint(equalTo: num7.heightAnchor, multiplier: CGFloat(heights[7])).isActive = true
        
        num8.addSubview(sub8)
        sub8.center(inView: num8)
        sub8.widthAnchor.constraint(equalTo: num8.heightAnchor, multiplier: CGFloat(modifiedWidth[8])).isActive = true
        sub8.heightAnchor.constraint(equalTo: num8.heightAnchor, multiplier: CGFloat(heights[8])).isActive = true
        
        num9.addSubview(sub9)
        sub9.center(inView: num9)
        sub9.widthAnchor.constraint(equalTo: num9.heightAnchor, multiplier: CGFloat(modifiedWidth[9])).isActive = true
        sub9.heightAnchor.constraint(equalTo: num9.heightAnchor, multiplier: CGFloat(heights[9])).isActive = true
        
        num00.addSubview(sub00)
        sub00.center(inView: num00)
        sub00.widthAnchor.constraint(equalTo: num00.heightAnchor, multiplier: CGFloat(modifiedWidth[10])).isActive = true
        sub00.heightAnchor.constraint(equalTo: num00.heightAnchor, multiplier: CGFloat(heights[10])).isActive = true
        
        numberDot.addSubview(subsubDot)
        subsubDot.anchor(left: numberDot.leftAnchor, bottom: numberDot.bottomAnchor, right: numberDot.rightAnchor)
        subsubDot.heightAnchor.constraint(equalTo: numberDot.heightAnchor, multiplier: 0.385).isActive = true
        
        
        
        numberDot.addSubview(subDot)
        subDot.centerX(inView: numberDot)
        subDot.anchor(bottom: subsubDot.topAnchor)
        subDot.widthAnchor.constraint(equalTo: numberDot.heightAnchor, multiplier: CGFloat(modifiedWidth[11])).isActive = true
        subDot.heightAnchor.constraint(equalTo: numberDot.heightAnchor, multiplier: CGFloat(heights[11])).isActive = true
        
        
        clearButton.addSubview(subClear)
        subClear.center(inView: clearButton)
        subClear.widthAnchor.constraint(equalTo: clearButton.heightAnchor, multiplier: CGFloat(modifiedWidth[12])).isActive = true
        subClear.heightAnchor.constraint(equalTo: clearButton.heightAnchor, multiplier: CGFloat(heights[12])).isActive = true
        
        
        openParenthesis.addSubview(subOpenpar)
        subOpenpar.center(inView: openParenthesis)
        subOpenpar.widthAnchor.constraint(equalTo: openParenthesis.heightAnchor, multiplier: CGFloat(modifiedWidth[13])).isActive = true
        subOpenpar.heightAnchor.constraint(equalTo: openParenthesis.heightAnchor, multiplier: CGFloat(heights[13])).isActive = true
        
        closeParenthesis.addSubview(subClosepar)
        subClosepar.center(inView: closeParenthesis)
        subClosepar.widthAnchor.constraint(equalTo: closeParenthesis.heightAnchor, multiplier: CGFloat(modifiedWidth[14])).isActive = true
        subClosepar.heightAnchor.constraint(equalTo: closeParenthesis.heightAnchor, multiplier: CGFloat(heights[14])).isActive = true
        
        operationButtonDivide.addSubview(subDivide)
        subDivide.center(inView: operationButtonDivide)
        subDivide.widthAnchor.constraint(equalTo: operationButtonDivide.heightAnchor, multiplier: CGFloat(modifiedWidth[15])).isActive = true
        subDivide.heightAnchor.constraint(equalTo: operationButtonDivide.heightAnchor, multiplier: CGFloat(heights[15])).isActive = true
        
        operationButtonMultiply.addSubview(subMulti)
        subMulti.center(inView: operationButtonMultiply)
        subMulti.widthAnchor.constraint(equalTo: operationButtonMultiply.heightAnchor, multiplier: CGFloat(modifiedWidth[16])).isActive = true
        subMulti.heightAnchor.constraint(equalTo: operationButtonMultiply.heightAnchor, multiplier: CGFloat(heights[16])).isActive = true
        
        operationButtonPlus.addSubview(subPlus)
        subPlus.center(inView: operationButtonPlus)
        subPlus.widthAnchor.constraint(equalTo: operationButtonPlus.heightAnchor, multiplier: CGFloat(modifiedWidth[17])).isActive = true
        subPlus.heightAnchor.constraint(equalTo: operationButtonPlus.heightAnchor, multiplier: CGFloat(heights[17])).isActive = true
        
        operationButtonMinus.addSubview(subMinus)
        subMinus.center(inView: operationButtonMinus)
        subMinus.widthAnchor.constraint(equalTo: operationButtonMinus.heightAnchor, multiplier: CGFloat(modifiedWidth[18])).isActive = true
        subMinus.heightAnchor.constraint(equalTo: operationButtonMinus.heightAnchor, multiplier: CGFloat(heights[18])).isActive = true
        
        equalButton.addSubview(subEqual)
        subEqual.center(inView: equalButton)
        subEqual.widthAnchor.constraint(equalTo: equalButton.heightAnchor, multiplier: CGFloat(modifiedWidth[19])).isActive = true
        subEqual.heightAnchor.constraint(equalTo: equalButton.heightAnchor, multiplier: CGFloat(heights[19])).isActive = true
    }
    
    func setupColorAndImage(){
        
//        var ratio = 1.3
//        ratio = 1.3 * 1.15 * 0.7
//        let ratio = 1.0465
        
        let numsAndOpers = [num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num00,numberDot,clearButton,openParenthesis,closeParenthesis,operationButtonDivide,operationButtonMultiply, operationButtonPlus,operationButtonMinus,equalButton]
        
        var modifiedWidth = [Double]()
        
        for widthElement in widths{
            modifiedWidth.append(widthElement * ratio)
        }


//        let numButtons = [num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num0,num00,numberDot,progressView,resultTextView,emptySpace]
        let numBtns = [num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num0,num00,numberDot]
        
        let operatorBtns = [clearButton,openParenthesis,closeParenthesis,operationButtonDivide,operationButtonMultiply,operationButtonPlus,operationButtonMinus,equalButton]
        
        let backgrounds = [progressView,resultTextView,emptySpace, deleteButton]
        
        if userDefaultSetup.darkModeOn{
            
            
            for numBtn in numBtns{ // emptySpace 등 도 포함..;;
                numBtn.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
            }
            for operBtn in operatorBtns{
                operBtn.backgroundColor =  colorList.bgColorForOperatorsDM
            }
            
            for other in backgrounds {
//                other.backgroundColor = colorList.bgColorForExtrasDM
                other.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
            }
            
            setupButtonImageInDarkMode()
            
            for view in historyClickButton.subviews{
                view.removeFromSuperview()
            }
            
            for i in 0 ..< numsAndOpers.count{
                for view in numsAndOpers[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
            historyClickButton.addSubview(subHistory)
            
            subHistory.fillSuperview()
            
//            setupButtonPositionAndSize(&modifiedWidth)
            setupButtonPositionAndSize(modifiedWidth)

            
            progressView.textColor = colorList.textColorForProcessDM
            resultTextView.textColor = ansPressed ? colorList.textColorForResultDM : colorList.textColorForSemiResultDM
            
            
            
        }else{ // lightMode
            
            for numBtn in numBtns{
                numBtn.backgroundColor =  colorList.bgColorForEmptyAndNumbersLM
            }
            for operBtn in operatorBtns{
                operBtn.backgroundColor =  colorList.bgColorForOperatorsLM
            }
            
            for other in backgrounds {
//                other.backgroundColor = colorList.bgColorForExtrasLM
                other.backgroundColor = colorList.bgColorForEmptyAndNumbersLM
            }
            
            deleteButton.backgroundColor =  colorList.bgColorForEmptyAndNumbersLM
            
            setupButtonImageInLightMode()
            
            
            for view in subHistory.subviews{
                view.removeFromSuperview()
            }
            
            for i in 0 ..< numsAndOpers.count{
                for view in numsAndOpers[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
            historyClickButton.addSubview(subHistory)
    
            subHistory.fillSuperview()
            
//            setupButtonPositionAndSize(&modifiedWidth)
            setupButtonPositionAndSize(modifiedWidth)
            
            
            progressView.textColor = colorList.textColorForProcessLM
            
            resultTextView.textColor = ansPressed ? colorList.textColorForResultLM : colorList.textColorForSemiResultLM
        }
        
    }
}






//google for kor : https://docs.google.com/forms/d/e/1FAIpQLScpexKHzOxWQjbzG0cnCjMkPR-OWX021QBUst4OwLp2b01ZYQ/viewform?usp=sf_link"
//google for eng : https://docs.google.com/forms/d/e/1FAIpQLSeuMqhwdEI29WrZxAmhxQNdnNfSjlsl_l5ELvWJFze6QHG3pA/viewform?usp=sf_link

