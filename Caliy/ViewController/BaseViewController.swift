
import UIKit
import AudioToolbox
import RealmSwift



// receiver for basicCalculator
class BaseViewController: UIViewController, FromTableToBaseVC {
    
    let basicCalc = BasicCalculator()
    
    lazy var tabbarheight = tabBarController?.tabBar.bounds.size.height ?? 83
    
    //receiver
    let ansFromTableNotification = Notification.Name(rawValue: NotificationKey.ansFromTableNotification.rawValue)
    
    // newNotification, receiver
    let processToBaseVCNotification = Notification.Name(rawValue: NotificationKey.processToBaseVCNotification.rawValue)
    
    let resultToBaseVCNotification = Notification.Name(rawValue: NotificationKey.resultToBaseVCNotification.rawValue)
    
    let scrollToVisibleNotification = Notification.Name(rawValue: NotificationKey.progressViewScrollToVisibleNotification.rawValue)
    
    let resultTextColorChangeNotification = Notification.Name(rawValue: NotificationKey.resultTextColorChangeNotification.rawValue)
    
    let sendingToastNotification = Notification.Name(rawValue: NotificationKey.sendingToastNotification.rawValue)
    
    lazy var multiplier = 1 - 0.108*5 - tabbarheight/frameView.frame.height
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Basic setup
    /// declared to use realmSwift to save data
//    var historyRecords : Results<HistoryRecord>! // model
    
    /// used to place HistoryRecordVC on the left side in landscape mode
    let childTableVC = HistoryRecordVC()        // view
    /// used to navigate to historyRecordVC
    let newTableVC = HistoryRecordVC()      // view
    
    var userDefaultSetup = UserDefaultSetup() // model, view
    let reviewService = ReviewService.shared    //settings
    /// entire view for basic calculator (not HistoryRecordVC)
    var frameView = UIView()        //view
    
    let colorList = ColorList()     //view
    let localizedStrings = LocalizedStringStorage()     // show Toast
    let fontSize = FontSizes()      // view, show Toast
    let frameSize = FrameSizes()    // view

    
    /// belong to view
    var portraitMode = true     // view
    
    /// pressedButtons joined into string, but not used at all.
//    var pressedButtons = "" // need to be changed!

//    let nf1 = NumberFormatter() // what is this for?
    /// 6 digis for floating numbers
    let nf6 = NumberFormatter()     // model
//    let nf11 = NumberFormatter() // what is this for?
    
    
    var soundModeOn = true// settings
    var lightModeOn = false// settings
    var notificationOn = false// settings, model
    var numOfReviewClicked = 0 // settings
    
    // what does o represent ??
    var setteroi : Int = 0
    /// sum of unit sizes for characters in a line
    var sumOfUnitSizes : [Double] = [0.0]
    
    var pOfNumsAndOpers = [""]
    var pOfNumsAndOpersCount = 1
    var strForProcess = [""]
    
    var lastMoveOP : [[Int]] = [[0],[0],[0]]
        
    var numOfEnter = [0,0,0]
    var dictionaryForLine = [Int : String]()
    
    var numParenCount = 0
    
    //MARK: - MAIN Variables
    let numbers : [Character] = ["0","1","2","3","4","5","6","7","8","9","."]
    let operators : [Character] = ["+","×","-","÷"] // used once
    let parenthesis : [Character] = ["(",")"] // not used
    let notToDeleteList : [Character] = ["+","-","×","÷","(",")"] // not used
    
    /// whether specific position can be negative or not
    var negativePossible = true
    /// indicate whether ans button has pressed
    var ansPressed = false
    /// Index for parenthesis
    var pi = 0
    /// increase after pressing operation button.
    var ni = [0]
    /// save all digits to make a number
    var tempDigits = [[""]]
    /// Double Numbers Storage
    var DS = [[0.0]]
    var answer : [[Double]] = [[100]] // the default value // what the hell is this answer?
    
    
    var operationStorage = [[""]]
    
    /// true if it is × or ÷
    var muldiOperIndex = [[false]]
    
    /// 0 : newly made, 1: got UserInput, 2 : used
    var freshDI = [[0]]
    
    // 0 :newly made, 1 : calculated, 2 : used
    var freshAI = [[0]]
    
    /// remember the start indexes of number to calculate (within parenthesis)
    var niStart = [[0,0]]
    
    /// remember the end indexes of number to calculate (within parenthesis)
    var niEnd = [[0]]
    /// used to measure duplicate parenthesis level
    var piMax = 0
    
    
    var indexPivotHelper = [false]
    /// 123 x (1 + 2) x (3 + 4 :  -> [1,2,0]
    var numOfPossibleNegative = [1]
    
    /// remember the position of empty DS
    var positionOfParen = [[0]]
    
    var negativeSign = [[false, false]]
    
    
    var process = ""
    /// if you want operate after press ans button, this value will come up and used.
    var savedResult : Double?
    var result : Double? // to be printed, one of the answer array.
    //    var isSaveResultInt : Bool?
    //    var floatingNumberDigits : Int?
    var copiedpi = 0
    var copiedni = [0]
    var copiedtempDigits = [[""]]
    var copiedDS = [[0.0]]
    var copiedanswer : [[Double]] = [[100]]
    var copiedoperationStorage = [[""]]
    var copiedmuldiOperIndex = [[false]]
    var copiedfreshDI = [[0]]
    var copiedfreshAI = [[0]]
    var copiedniStart = [[0,0]]
    var copiedniEnd = [[0]]
    var copiedpiMax = 0
    var copiedindexPivotHelper = [false]
    var copiednumOfPossibleNegative = [1]
    var copiedpositionOfParen = [[0]]
    var copiedNegativeSign = [[false, false]]
    var copiedNegativePossible = true
    var copiedAnsPressed = false
    var copiedprocess = ""
    var copiedresult : Double? // to be printed, one of the answer array.
    var copiedsaveResult : Double?
    
    var deletionTimer = Timer()
    var deletionTimer2 = Timer()
    var deletionTimerInitialSetup = Timer()
    var deletionTimerPause = Timer()
    var deletionSpeed = 0.5
    let deletionPause = 2.35
    let deletionInitialSetup = 2.5
    
    var showingAnsAdvance = false
    
    
    
    
    
    // MARK: - LifeCycles
    
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
    
    
    override func viewDidLoad() {
        print(#function, #file)
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        portraitMode = screenHeight > screenWidth ? true : false
        
        childTableVC.FromTableToBaseVCdelegate = self
        newTableVC.FromTableToBaseVCdelegate = self
        
        super.viewDidLoad()
        
//        let realm = RealmService.shared.realm
//        historyRecords = realm.objects(HistoryRecord.self)
        setupUserDefaults()
        setupPositionLayout()
        setupColorAndImage()
        setupAddTargets()
        
        createObservers()
        
        navigationController?.navigationBar.isHidden = true
    }
    
    func createObservers() {
        // newNotification, receiver
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.updateProcess(notification:)), name: processToBaseVCNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.updateResult(notification:)), name: resultToBaseVCNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.scrollToVisible(notification:)), name: scrollToVisibleNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.updateResultTextColor(notification:)), name: resultTextColorChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.sendToast(notification:)), name: sendingToastNotification, object: nil)
    }
    
    // newNotification, receiver
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
    // no need to specify value. just need to send a signal
    @objc func scrollToVisible(notification: NSNotification) {
            progressView.scrollRangeToVisible(progressView.selectedRange)
    }
    
    @objc func updateResultTextColor(notification: NSNotification) {
        guard let receivedAnsPressed = notification.userInfo?["ansPressed"] as? Bool else {
            print("there's an error in receiving result from basicCalculator")
            return
        }
        if receivedAnsPressed {
            resultTextView.textColor = lightModeOn ? colorList.textColorForResultLM : colorList.textColorForResultDM
        } else {
            resultTextView.textColor = lightModeOn ? colorList.textColorForSemiResultLM : colorList.textColorForSemiResultDM
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
            self.toastHelper(msg: localizedStrings.modified, wRatio: 0.4, hRatio: 0.04)
        case .saved:
            self.toastHelper(msg: localizedStrings.savedToHistory, wRatio: 0.4, hRatio: 0.04)
        }
    }
    // MARK: - Helpers
    
    
    // MARK: - from History, delegate pattern
    
    func pasteAnsFromHistory(ansString: String) { //
        basicCalc.didReceiveAnsFromTable(receivedValue: ansString)
    }
    
    @objc func handleNumberTapped(sender : UIButton){
        basicCalc.didReceiveNumber(sender.tag)
    }
    
    @objc func handleOperationTapped(sender : UIButton){
        basicCalc.didReceiveOper(senderTag: sender.tag)
    }
    
    
    /// view area
//    func toastAnsLimitExceed(){
//        if let languageCode = Locale.current.languageCode{
//            if languageCode.contains("ko"){
////                self.showToast(message: self.localizedStrings.answerLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getDeviceSize()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667, widthRatio: 0.7, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
//
//            }else{
//
////                self.showToast(message: self.localizedStrings.answerLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getDeviceSize()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667, widthRatio: 0.6, heightRatio: 0.08, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
//
//            }
//        }
//    }
    /// view area
//    func toastFloatingDigitLimitExceed(){
//        if let languageCode = Locale.current.languageCode{
//            if languageCode.contains("ko"){
////                self.showToast(message: self.localizedStrings.floatingLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getDeviceSize()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667, widthRatio: 0.7, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
//
//            }else{
//
////                self.showToast(message: self.localizedStrings.floatingLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getDeviceSize()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667, widthRatio: 0.6, heightRatio: 0.08, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
//
//            }
//        }
//    }
    
    @objc func handlePerenthesisTapped(sender : UIButton){
        basicCalc.didReceiveParen(sender.tag)
    }
    
    @objc func handleDeleteAction(){
        basicCalc.didReceiveDelete()
        print(#file, #function)
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
    
    //MARK: - SUB Functions
    
    
    @objc func turnIntoOriginalColor(sender : UIButton){
        if lightModeOn{
            switch sender.tag {
            case -2 ... 9:
                sender.backgroundColor = colorList.bgColorForEmptyAndNumbersLM
            case 10 ... 20 :
                sender.backgroundColor =  colorList.bgColorForOperatorsLM
            case 31 ... 40:
                sender.backgroundColor =  colorList.bgColorForExtrasLM
            case 21 ... 30 :
                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersLM
                basicCalc.invalidateAllTimers()
            default :
                sender.backgroundColor = .magenta
            }
        }else{
            switch sender.tag {
            case -2 ... 9:
                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
            case 10 ... 20 :
                sender.backgroundColor =  colorList.bgColorForOperatorsDM
            case 31 ... 40:
                sender.backgroundColor =  colorList.bgColorForExtrasDM
            case 21 ... 30 :
                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
                basicCalc.invalidateAllTimers()
            default :
                sender.backgroundColor = .magenta
            }
        }
    }
    
    
    @objc func handleDeleteDragOutAction(sender : UIButton){ // deleteDragOut
        basicCalc.didDragOutDelete()
    }
    
    
    @objc func toggleSoundMode(sender : UIButton){
        
        basicCalc.checkIndexes(with: "test from \(#line)")
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        
        soundModeOn = userDefaultSetup.getIsSoundOn()
        
        soundModeOn.toggle()
        userDefaultSetup.setIsSoundOn(isSoundOn: soundModeOn)
        setupColorAndImage()
    }
    
    /// 보류 settings
    @objc func toggleDarkMode(sender : UIButton){
       
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        
        lightModeOn = userDefaultSetup.getIsLightModeOn()
        
        lightModeOn.toggle()
        
        userDefaultSetup.setIsLightModeOn(isLightModeOn: lightModeOn)
        setupColorAndImage()
        
    }
    /// 보류 settings
    @objc func toggleNotificationAlert(sender : UIButton){
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        
        notificationOn = userDefaultSetup.getIsNotificationOn()
        
        notificationOn.toggle()
        
        userDefaultSetup.setIsNotificationOn(isNotificationOn: notificationOn)
        setupColorAndImage()
    }
    
    /// 보류 settings
    @objc func navigateToReviewSite(sender : UIButton){
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        numOfReviewClicked = userDefaultSetup.getNumberReviewClicked()
        userDefaultSetup.setNumberReviewClicked(numberReviewClicked: numOfReviewClicked+1)
        
        if (numOfReviewClicked < 3){
            reviewService.requestReview()
        }else{
            if let languageCode = Locale.current.languageCode{
                if languageCode.contains("ko"){ // kor google survey page
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
    }
    
    
    
    //google for kor : https://docs.google.com/forms/d/e/1FAIpQLScpexKHzOxWQjbzG0cnCjMkPR-OWX021QBUst4OwLp2b01ZYQ/viewform?usp=sf_link"
    //google for eng : https://docs.google.com/forms/d/e/1FAIpQLSeuMqhwdEI29WrZxAmhxQNdnNfSjlsl_l5ELvWJFze6QHG3pA/viewform?usp=sf_link
    
    
//    func sendNotification(){
//        if notificationOn{
////            self.showToast(message: self.localizedStrings.modified, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getDeviceSize()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
//        }
//    }
    
    /// 보류 settings
    func setupUserDefaults(){
        if userDefaultSetup.getWhetherUserEverChanged(){
            lightModeOn = userDefaultSetup.getIsLightModeOn()
            soundModeOn = userDefaultSetup.getIsSoundOn()
            notificationOn = userDefaultSetup.getIsNotificationOn()
            numOfReviewClicked = userDefaultSetup.getNumberReviewClicked()
        }
        else{ // initial value . when a user first downloaded.
            userDefaultSetup.setIsLightModeOn(isLightModeOn: false)
            userDefaultSetup.setIsNotificationOn(isNotificationOn: false)
            userDefaultSetup.setIsSoundOn(isSoundOn: true)
            userDefaultSetup.setNumberReviewClicked(numberReviewClicked: 0)
            
            lightModeOn = false
            notificationOn = false
            soundModeOn = true
            numOfReviewClicked = 0
        }
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        
        let maxLength = screenWidth > screenHeight ? screenWidth : screenHeight
        
        switch maxLength {
        case 0 ... 800:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "A")
        case 801 ... 1000:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "B")
        case 1001 ... 1100:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "C")
        case 1101 ... 1500:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "D")
        default:
            userDefaultSetup.setUserDeviceSizeInfo(userDeviceSizeInfo: "A")
        }
    }
    
    
    func playSound(){
        if soundModeOn{
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    // deletePressedDown
    @objc func handleDeletePressedDown(sender : UIButton){
        print(#file, #function)
        if lightModeOn{
            sender.backgroundColor =  colorList.bgColorForExtrasLM
        }else{
            sender.backgroundColor =  colorList.bgColorForExtrasDM
        }
        
        basicCalc.didPressedDownDelete()
        
    }
    
    
    @objc func handleDeleteTapped(sender : UIButton){
        sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersLM
    
        basicCalc.handleDeleteTapped()
    }

    
    @objc func handleSoundAction(sender: UIButton) {
        playSound()
    }
    
    @objc func handleColorChangeAction(sender: UIButton) {
        if lightModeOn{
            sender.backgroundColor =  colorList.bgColorForExtrasLM
        }else{
            sender.backgroundColor =  colorList.bgColorForExtrasDM
        }
    }
    
    
    @objc func moveToHistoryTable(sender : UIButton){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        newTableVC.modalPresentationStyle = .fullScreen
        self.present(newTableVC, animated: true, completion: nil)
    }
    
    func toastHelper(msg: String, wRatio: Float, hRatio: Float) {
        showToast(message: msg,
                  defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getDeviceSize()] ?? 375,
                  defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getDeviceSize()] ?? 667,
                  widthRatio: wRatio, heightRatio: hRatio,
                  fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getDeviceSize()] ?? 13)
    }
    
    
    
    //MARK: - < Main Functional Section Ends >
    //MARK: - < UI Section Starts >
    
    //
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

//    var soundBtnImg = transparentImage
//    var colorBtnImg = transparentImage
//    var notificationBtnImg = transparentImage
//    var feedbackBtnImg = transparentImage
    
    // those are all transparent!
    
    //MARK: - <#UI Section starts
    
    
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
//    let soundButton = ButtonTag(withTag: 31)
//    let displayThemeButton = ButtonTag(withTag: 32)
//    let notificationButton = ButtonTag(withTag: 33)
//    let reviewButton = ButtonTag(withTag: 34)
    
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
//        result.backgroundColor = .magenta
        
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
        print(#function)
        // frameView = UIView()
        for subview in frameView.subviews{
            subview.removeFromSuperview()
        }
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
//        print("tabBarHeight : \(tabBarController?.tabBar.bounds.size.height)")
//        let horStackView0 : [UIButton] = [soundButton, displayThemeButton, notificationButton, reviewButton]
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
            
//            for button in horStackView0{ //extras 1,2,3,4
//                frameView.addSubview(button)
//                button.translatesAutoresizingMaskIntoConstraints = false
//                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.108).isActive = true
//            }
        }else if !portraitMode{ // LandScape Mode
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
//                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.10).isActive = true
            }else{
                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: CGFloat(0.108*1.2)).isActive = true
            }
            
            button.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.25).isActive = true
            //            button.layer.borderWidth = 0.23
            button.layer.borderWidth = 0.23
            button.layer.borderColor = CGColor(genericGrayGamma2_2Gray: 0, alpha: 0.15)
            //frameView : view or rightSideForLandscapeMode view (UIView)
        }
        
        
        if portraitMode{
//            for button in horStackView0{
//                button.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.25).isActive = true
//                button.anchor(bottom: frameView.bottomAnchor)
//                button.layer.borderWidth = 0.23
//                button.layer.borderColor = CGColor(genericGrayGamma2_2Gray: 0, alpha: 0.15)
//            }
            
            for button in horStackView1{
//                button.anchor(bottom: soundButton.topAnchor)
//                button.anchor(bottom: view.safeBottomAnchor, paddingBottom: tabbarheight)
                button.anchor(bottom: view.safeBottomAnchor)
            }
            
//            soundButton.anchor(left: frameView.leftAnchor)
//            displayThemeButton.anchor(left: soundButton.rightAnchor)
//            notificationButton.anchor(left: displayThemeButton.rightAnchor)
//            reviewButton.anchor(left: notificationButton.rightAnchor, right: frameView.rightAnchor)
            
          
            
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
            
            /// used for emptySpace. because of tabbar, its ratio has changed a little
//            let multiplier = 1 - 0.108*5 - tabbarheight/frameView.frame.height
            // this value change.. i don't know why..
//            let multiplier = CGFloat(0.36736607142857136)
            print("valueOfMultiplier: \(multiplier)")
//            let multiplier = 1 - 0.108*5 - 80/frameView.frame.height
            
            emptySpace.anchor(top: frameView.topAnchor, left: frameView.leftAnchor, right: frameView.rightAnchor)
//            emptySpace.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.352).isActive = true // this is.. problematic..
            emptySpace.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: multiplier).isActive = true // this is.. problematic..
            
            // only applied to portrait Mode
            
            deleteWidthReference.anchor(right: frameView.rightAnchor)
            deleteWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.122).isActive = true
            print(#line, #function)
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
        }else{
            let k = 1.307
            emptySpace.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.352).isActive = true
            emptySpace.anchor(top: frameView.topAnchor, left: frameView.leftAnchor, right: frameView.rightAnchor)
            // only applied to portrait Mode
            
            deleteWidthReference.anchor(right: frameView.rightAnchor)
            deleteWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.032).isActive = true
            print(#line, #function)
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
        
        resultTextView.font = UIFont.systemFont(ofSize: fontSize.resultBasicPortrait[userDefaultSetup.getDeviceSize()]!)
        progressView.font = UIFont.systemFont(ofSize: fontSize.processBasicPortrait[userDefaultSetup.getDeviceSize()]!)
        
//        view.backgroundColor = .magenta
        view.backgroundColor = colorList.bgColorForExtrasDM
        view.backgroundColor = colorList.bgColorForExtrasLM
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
//            aButton.addTarget(self, action: #selector( otherPressedDown), for: .touchDown)
            aButton.addTarget(self, action: #selector(handleSoundAction), for: .touchDown)
            aButton.addTarget(self, action: #selector(handleColorChangeAction), for: .touchDown)
            aButton.addTarget(self, action: #selector(turnIntoOriginalColor(sender:)), for: .touchUpInside)//does nothing
            aButton.addTarget(self, action: #selector(turnIntoOriginalColor), for: .touchDragExit)
        }
        
        equalButton.addTarget(self, action: #selector( handleAnsTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector( handleClearTapped), for: .touchUpInside)
        
        openParenthesis.addTarget(self, action: #selector( handlePerenthesisTapped), for: .touchUpInside)
        closeParenthesis.addTarget(self, action: #selector( handlePerenthesisTapped), for: .touchUpInside)
        
        deleteButton.addTarget(self, action: #selector( handleDeletePressedDown), for: .touchDown)
        deleteButton.addTarget(self, action: #selector(handleDeleteTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(handleDeleteDragOutAction), for: .touchDragExit)
        
        deleteButton.addTarget(self, action: #selector( turnIntoOriginalColor), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(turnIntoOriginalColor), for: .touchDragExit)
        //sound, backgroundColor, notification, feedback
//        soundButton.addTarget(self, action: #selector(toggleSoundMode), for: .touchUpInside)
//        displayThemeButton.addTarget(self, action: #selector(toggleDarkMode(sender:)), for: .touchUpInside)
//        notificationButton.addTarget(self, action: #selector(toggleNotificationAlert), for: .touchUpInside)
//        reviewButton.addTarget(self, action: #selector(navigateToReviewSite), for: .touchUpInside)
        
        historyClickButton.addTarget(self, action: #selector(moveToHistoryTable), for: .touchUpInside)
        historyClickButton.addTarget(self, action: #selector(moveToHistoryTable), for: .touchDragExit)
        historyDragButton.addTarget(self, action: #selector(moveToHistoryTable), for: .touchDragExit)
    }
    
    
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
//        colorBtnImg = UIImageView(image: #imageLiteral(resourceName: "white_to_dark"))
//        feedbackBtnImg = UIImageView(image: #imageLiteral(resourceName: "whitemode_review"))
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
//        colorBtnImg = UIImageView(image: #imageLiteral(resourceName: "dark_to_white"))
//        feedbackBtnImg = UIImageView(image: #imageLiteral(resourceName: "darkmode_review"))
    }
    
    fileprivate func setupButtonPositionAndSize(_ modifiedWidth: inout [Double]) {
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
        
//        displayThemeButton.addSubview(colorBtnImg)
//        colorBtnImg.center(inView: displayThemeButton)
//        colorBtnImg.widthAnchor.constraint(equalTo: displayThemeButton.heightAnchor, multiplier: CGFloat(0.288) * CGFloat(ratio)).isActive = true
//        colorBtnImg.heightAnchor.constraint(equalTo: displayThemeButton.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
//
//        reviewButton.addSubview(feedbackBtnImg)
//        feedbackBtnImg.center(inView: reviewButton)
//        feedbackBtnImg.widthAnchor.constraint(equalTo: reviewButton.heightAnchor, multiplier: CGFloat(0.288 * ratio) ).isActive = true
//        feedbackBtnImg.heightAnchor.constraint(equalTo: reviewButton.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
        
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


        let numButtons = [num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num0,num00,numberDot,progressView,resultTextView,emptySpace]
        
        let otherButtons = [clearButton,openParenthesis,closeParenthesis,operationButtonDivide,operationButtonMultiply,operationButtonPlus,operationButtonMinus,equalButton]
        
//        let extras = [soundButton, displayThemeButton, notificationButton, reviewButton]
        
        if lightModeOn{
            for num in numButtons{
                num.backgroundColor =  colorList.bgColorForEmptyAndNumbersLM
            }
            for other in otherButtons{
                other.backgroundColor =  colorList.bgColorForOperatorsLM
            }
//            for extra in extras{
//                extra.backgroundColor =  colorList.bgColorForExtrasLM
//            }
            deleteButton.backgroundColor =  colorList.bgColorForEmptyAndNumbersLM
//            deleteButton.backgroundColor = .magenta
            setupButtonImageInLightMode()
            
            
            for view in subHistory.subviews{
                view.removeFromSuperview()
            }
            
            for i in 0 ..< numsAndOpers.count{
                for view in numsAndOpers[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
//            for i in 0 ..< extras.count{
//                for view in extras[i].subviews{
//                    view.removeFromSuperview()
//                }
//            }
            historyClickButton.addSubview(subHistory)
    
            subHistory.fillSuperview()
            
            setupButtonPositionAndSize(&modifiedWidth)
            
//            soundBtnImg = soundModeOn ? soundOnLightImg : soundOffLightImg
//            notificationBtnImg = notificationOn ? alarmOnLightImg : alarmOffLightImg
            
            
            progressView.textColor = colorList.textColorForProcessLM
            
            resultTextView.textColor = ansPressed ? colorList.textColorForResultLM : colorList.textColorForSemiResultLM
            
        }else{ // darkMode
            for num in numButtons{
                num.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
            }
            for other in otherButtons{
                other.backgroundColor =  colorList.bgColorForOperatorsDM
            }
//            for extra in extras{
//                extra.backgroundColor =  colorList.bgColorForExtrasDM
//            }
            deleteButton.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
//            deleteButton.backgroundColor = .magenta
            setupButtonImageInDarkMode()
            
            for view in historyClickButton.subviews{
                view.removeFromSuperview()
            }
            
            for i in 0 ..< numsAndOpers.count{
                for view in numsAndOpers[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
//            for i in 0 ..< extras.count{
//                for view in extras[i].subviews { // It works !!! whow!!
//                    view.removeFromSuperview()
//                }
//            }
            
            historyClickButton.addSubview(subHistory)
            
            subHistory.fillSuperview()
            
            setupButtonPositionAndSize(&modifiedWidth)

//            soundBtnImg = soundModeOn ? soundOnDarkImg : soundOffDarkImg
//            notificationBtnImg = notificationOn ? alarmOnDarkImg : alarmOffDarkImg
            
            progressView.textColor = colorList.textColorForProcessDM
            resultTextView.textColor = ansPressed ? colorList.textColorForResultDM : colorList.textColorForSemiResultDM
        }
        
//        soundButton.addSubview(soundBtnImg)
//        soundBtnImg.center(inView: soundButton)
//
//        soundBtnImg.widthAnchor.constraint(equalTo: soundButton.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
//        soundBtnImg.heightAnchor.constraint(equalTo: soundButton.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
//
//        notificationButton.addSubview(notificationBtnImg)
//        notificationBtnImg.center(inView: notificationButton)
//        notificationBtnImg.widthAnchor.constraint(equalTo: notificationButton.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
//        notificationBtnImg.heightAnchor.constraint(equalTo: notificationButton.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
    }
}
