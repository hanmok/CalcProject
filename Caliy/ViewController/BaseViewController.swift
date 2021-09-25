
import UIKit
import AudioToolbox
import RealmSwift

class BaseViewController: UIViewController, FromTableToBaseVC {
    
    let ansFromTableNotification = Notification.Name(rawValue: answerFromTableNotificationKey)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Basic setup
    
    let childTableVC = HistoryRecordVC()
    let newTableVC = HistoryRecordVC()
    
    let colorList = ColorList()
    var historyRecords : Results<HistoryRecord>!
    var userDefaultSetup = UserDefaultSetup()
    

    
    let localizedStrings = LocalizedStringStorage()
//    var deviceName : String?

    let fontSize = FontSizes()
    let frameSize = FrameSizes()
    let reviewService = ReviewService.shared
    
//    var lineSettingsum = 0
    
    var frameView = UIView()
    
    var isOrientationPortrait = true
    
    var iPressed = ""
    var countingNumber = 1
    
    let nf1 = NumberFormatter()
    let nf6 = NumberFormatter()
    let nf11 = NumberFormatter()
    
    // MARK: - LifeCycles
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            isOrientationPortrait = false
            
        } else if UIDevice.current.orientation.isPortrait {
            isOrientationPortrait = true
        }
        
        setupPositionLayout()
        colorAndImageSetup()
        addTargetSetup()
        
        printProcess()
        
        setupNumberFormatter()
        
        let isPortrait = ["orientation" : isOrientationPortrait]
        let name = Notification.Name(rawValue: viewWilltransitionNotificationKey)
        
        NotificationCenter.default.post(name: name, object: nil, userInfo: isPortrait as [AnyHashable : Any])
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let name = Notification.Name(rawValue: viewWillAppearbasicViewControllerKey)
        NotificationCenter.default.post(name : name, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let name = Notification.Name(rawValue: viewWillDisappearbasicViewControllerKey)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    
    override func viewDidLoad() {
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        isOrientationPortrait = screenHeight > screenWidth ? true : false
        
        childTableVC.FromTableToBaseVCdelegate = self
        newTableVC.FromTableToBaseVCdelegate = self
        
        super.viewDidLoad()
        
        let realm = RealmService.shared.realm
        historyRecords = realm.objects(HistoryRecord.self)
        defaultSetup()
        setupPositionLayout()
        colorAndImageSetup()
        addTargetSetup()
        
        setupNumberFormatter()
    }
    
    
    
    // MARK: - Helpers
    
    func setupNumberFormatter(){
       
        nf1.roundingMode = .down
        nf1.maximumFractionDigits = 1
        
        nf6.roundingMode = .down
        nf6.maximumFractionDigits = 6
        
        nf11.roundingMode = .down
        nf11.maximumFractionDigits = 10
    }
    
    // MARK: - from History
    
    func copyAndPasteAns(ansString: String) {
        print("copyAndPasteAns called")
        
        var plusNeeded = false
        var parenNeeded = false
        var manualClearNeeded = false
        let valueFromTable = ansString
        
        if process != ""{
            let lastChar = process[process.index(before:process.endIndex)]
            
            switch lastChar {
            case "+", "-", "×","÷" : parenNeeded.toggle()
            case "(" : print("none")
            case ")" : plusNeeded.toggle()
                parenNeeded.toggle()
            case "=" : manualClearNeeded.toggle()
            default:
                plusNeeded.toggle()
                parenNeeded.toggle()
            }
        }
        
        if valueFromTable.contains("-") && manualClearNeeded{
            manualClear()
        }
        
        if plusNeeded{
            manualOperationPressed(operSymbol: "+")
        }
        
        if parenNeeded && valueFromTable.contains("-"){
            manualParenthesis(trueToOpen: true)
        }
        
        if valueFromTable.contains("-"){
            manualOperationPressed(operSymbol: "-")
        }
        
        insertAnsFromHistory(numString : valueFromTable)
        
        if parenNeeded && valueFromTable.contains("-"){
            manualParenthesis(trueToOpen: false)
        }
    }
    
    
    
    
    func insertAnsFromHistory(numString : String){
        
        countingNumber += 1
        
        if isAnsPressed{
            clear()
            process = ""
            isAnsPressed = false
        }
        addPOfNumsAndOpers()
        addStrForProcess()
        
        if pOfNumsAndOpers[setteroi] == "op"{
            setteroi += 1
        }
        negativePossible = false
        let freshString = removeMinusCommaDot0(from: numString)
        
        tempDigits[pi][ni[pi]] += freshString
        process += freshString
        if let doubleNumber = Double(freshString){
            
            DS[pi][ni[pi]] = doubleNumber
            freshDI[pi][ni[pi]] = 1
            if tempDigits[pi][ni[pi]].contains("-"){
                DS[pi][ni[pi]] *= -1
            }
        }
        addPOfNumsAndOpers()
        pOfNumsAndOpers[setteroi] = "n"
        addStrForProcess()
        showAnsAdvance()
        printProcess() // 이거 없애면 숫자들 사이 , 가 없어짐.
    }
    /// remove - , . 0
    func removeMinusCommaDot0(from stringValue : String ) -> String{
        var stringToReturn = stringValue
        if stringValue.hasPrefix("-"){
            stringToReturn = String(stringValue.dropFirst())
        }
        if stringValue.contains(","){
            stringToReturn = stringToReturn.components(separatedBy: ",").joined()
        }
        if stringToReturn.contains("."){
            if let double = Double(stringValue){
                let int = Int(double)
                if double - Double(int) == 0{
                    stringToReturn = String(stringToReturn.dropLast())
                    stringToReturn = String(stringToReturn.dropLast())
                }
            }
        }
        return stringToReturn // without , - .0
    }
    
    
    
    
    
    var isSoundOn = true
    var isLightModeOn = false
    var isNotificationOn = false
    var numberReviewClicked = 0
    
    
    
    // make seperate constants file
    // layer architecture
    // 모듈을 만드는 느낌 ?? 유지보수 .
    
    
    var setteroi : Int = 0
    var sumOfUnitSizes : [Double] = [0.0]
    
    var pOfNumsAndOpers = [""]
    var pOfNumsAndOpersCount = 1
    var strForProcess = [""]
    
    var lastMoveOP : [[Int]] = [[0],[0],[0]]
        
    var numOfEnter = [0,0,0]
    var dictionaryForLine = [Int : String]()
    
    var numParenCount = 0
    
    //MARK: - MAIN FUNCTIONS
    let numbers : [Character] = ["0","1","2","3","4","5","6","7","8","9","."]
    let operators : [Character] = ["+","×","-","÷"]
    let parenthesis : [Character] = ["(",")"]
    let notToDeleteList : [Character] = ["+","-","×","÷","(",")"]
    
    var negativePossible = true
    var isAnsPressed = false
    
    var pi = 0 // index for parenthesis.
    var ni = [0] // increase after pressing operation button.
    var tempDigits = [[""]] // save all digits to make a number
    var DS = [[0.0]] // Double Numbers Storage
    var answer : [[Double]] = [[100]] // the default value
    
    var operationStorage = [[""]]
    var muldiOperIndex = [[false]] // true if it is x or / .
    
    var freshDI = [[0]] // 0 : newly made, 1: got UserInput, 2 : used
    var freshAI = [[0]] // 0 :newly made, 1 : calculated, 2 : used
    
    var niStart = [[0,0]] // remember the indexes to calculate (within parenthesis)
    var niEnd = [[0]]
    
    var piMax = 0
    var indexPivotHelper = [false]
    var numOfPossibleNegative = [1] // 123 x (1 + 2) x (3 + 4 :  -> [1,2,0]
    var positionOfParen = [[0]] // remember the position of empty DS
    var isNegativeSign = [[false, false]]
    
    
    var process = ""
    // if you want operate after press ans button, this value will come up and used.
    var saveResult : Double?
    var result : Double? // to be printed, one of the answer array.
    //    var isSaveResultInt : Bool?
    //    var floatingNumberDigits : Int?
    var copypi = 0
    var copyni = [0]
    var copytempDigits = [[""]]
    var copyDS = [[0.0]]
    var copyanswer : [[Double]] = [[100]]
    var copyoperationStorage = [[""]]
    var copymuldiOperIndex = [[false]]
    var copyfreshDI = [[0]]
    var copyfreshAI = [[0]]
    var copyniStart = [[0,0]]
    var copyniEnd = [[0]]
    var copypiMax = 0
    var copyindexPivotHelper = [false]
    var copynumOfPossibleNegative = [1]
    var copypositionOfParen = [[0]]
    var copyisNegativeSign = [[false, false]]
    var copyisNegativePossible = true
    var copyisAnsPressed = false
    var copyprocess = ""
    var copyresult : Double? // to be printed, one of the answer array.
    var copysaveResult : Double?
    
    var deleteTimer = Timer()
    var deleteTimer2 = Timer()
    var deleteTimerInitialSetup = Timer()
    var deleteTimerPause = Timer()
    var deleteSpeed = 0.5
    let deletePause = 2.35
    let deleteInitialSetup = 2.5
    
    var showingAnsAdvance = false
    
    
    @objc func handleNumberTapped(sender : UIButton){
        
        if let input = tagToString[sender.tag]{
            iPressed += input
            if isAnsPressed
            {
                clear()
                process = ""
                isAnsPressed = false
            }
            addPOfNumsAndOpers()
            addStrForProcess()

            if pOfNumsAndOpers[setteroi] == "op"{
                setteroi += 1
            }
            
            // if made number is not greater than it's limit
            if (DS[pi][ni[pi]] > -1e14  && DS[pi][ni[pi]] < 1e14) && !((DS[pi][ni[pi]] >= 1e13 || DS[pi][ni[pi]] <= -1e13) && input == "00") {
                //기존 입력 : 0, -0, 공백, - && input : 0, 00
                if (input == "0" || input == "00") && (tempDigits[pi][ni[pi]] == "0" || tempDigits[pi][ni[pi]] == "-0" || tempDigits[pi][ni[pi]] == "" || tempDigits[pi][ni[pi]] == "-"){
                    switch tempDigits[pi][ni[pi]] {
                    case ""  :
                        tempDigits[pi][ni[pi]] += "0"
                        process += "0"
                        if input == "00"{sendNotification()}
                    case "-":
                        tempDigits[pi][ni[pi]] += "0"
                        process += "0"
                        if input == "00"{sendNotification()}
                    case "0" : sendNotification();break
                    case "-0": sendNotification();break
                    default : break
                    }
                } // input : . && 기존 입력 : 공백 or - or 이미 . 포함.
                else if (input == ".") && (tempDigits[pi][ni[pi]] == "" || tempDigits[pi][ni[pi]] == "-" || tempDigits[pi][ni[pi]].contains(".")){//공백, - , . >> . : 모든 경우 수정됨.
                    switch tempDigits[pi][ni[pi]] {
                    case ""  :// 기존 입력 : 공백 >> 0. 삽입.
                        tempDigits[pi][ni[pi]]  += "0."
                        process += "0."
                    case "-" :// 기존 입력 : - >> 0. 삽입. ( 이미 - 는 들어가있음)
                        tempDigits[pi][ni[pi]] += "0."
                        process += "0."
                    default : break
                    }
                    sendNotification()
                }// 기존 입력 : 0 or -0 , 새 입력 : 0, 00, . 이 아닌경우!
                else if (input != "0" && input != "00" && input != ".") && (tempDigits[pi][ni[pi]] == "0" || tempDigits[pi][ni[pi]] == "-0"){ // 0 , -0 >> 숫자 입력 : 모든 경우 수정됨.
                    tempDigits[pi][ni[pi]].removeLast()
                    tempDigits[pi][ni[pi]] += input
                    
                    process.removeLast()
                    process += input
                    sendNotification()
                }// 괄호 닫고 바로 숫자 누른 경우.
                else if tempDigits[pi][ni[pi]].contains("parenclose") && operationStorage[pi][ni[pi]] == ""{
                    setteroi += 1
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] += tagToUnitSize["×"]!
                    
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    
                    addStrForProcess()
                    strForProcess[setteroi] = "×"
                    
                    dictionaryForLine[setteroi] = "×"
                    // ["+","-","×","÷","(",")"]
                    setteroi += 1
                    addSumOfUnitSizes()
                    addPOfNumsAndOpers()
                    addStrForProcess()
                    
                    operInputSetup("×", ni[pi])
                    process += operationStorage[pi][ni[pi]]
                    indexUpdate()
                    tempDigits[pi][ni[pi]] = input
                    
                    if input == "."{
                        tempDigits[pi][ni[pi]] = "0."
                        process += "0"
                    }
                    
                    process += String(input)
                    sendNotification()
                }
                else { // usual case
                    tempDigits[pi][ni[pi]] += input
                    process += String(input)
                }
                
                if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                    DS[pi][ni[pi]] = safeDigits
                    freshDI[pi][ni[pi]] = 1
                    negativePossible = false
                }
            } // end if DS[pi][ni[pi]] <= 1e14{
            else if ((DS[pi][ni[pi]] >= 1e13 || DS[pi][ni[pi]] <= -1e13) && input == "00") && (DS[pi][ni[pi]] < 1e14  && DS[pi][ni[pi]] > -1e14){
                
                tempDigits[pi][ni[pi]] += "0"
                process += "0"
                sendNotification()
                
                if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                    DS[pi][ni[pi]] = safeDigits
                    freshDI[pi][ni[pi]] = 1
                    negativePossible = false
                }
                
            }// 15자리에서 .이 이미 있는 경우
            else if ((DS[pi][ni[pi]] >= 1e14 || DS[pi][ni[pi]] <= -1e14) && tempDigits[pi][ni[pi]].contains(".")){
                
                if input == "."{
                    sendNotification()
                    
                }else{
                    process += input
                    tempDigits[pi][ni[pi]] += input
                    
                    if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                        DS[pi][ni[pi]] = safeDigits
                    }
                }
                
                
            }// 15자리에서 . 없는 경우
            else if ((DS[pi][ni[pi]] >= 1e14 || DS[pi][ni[pi]] <= -1e14) && !tempDigits[pi][ni[pi]].contains(".")){
                if input == "."{
                    process += String(input)
                    tempDigits[pi][ni[pi]] += "."
                    
                }else{ // 숫자 초과!!
                    
                    
                    self.showToast(message: self.localizedStrings.numberLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.8, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                    
                }
            }
            addPOfNumsAndOpers()
            
            pOfNumsAndOpers[setteroi] = "n"
            
            addStrForProcess()
            showAnsAdvance()
            
            printProcess()
        }
    }
    // @IBAction func numberPressed(_ sender: UIButton){
    
    
    
    func manualNumberPressed(inputStr : String){
        
        let input = inputStr
        
        if isAnsPressed
        {
            clear()
            process = ""
            isAnsPressed = false
        }
        addPOfNumsAndOpers()
        addStrForProcess()
        
        if pOfNumsAndOpers[setteroi] == "op"{
            setteroi += 1
         
        }
        
        if (DS[pi][ni[pi]] > -1e14  && DS[pi][ni[pi]] < 1e14) && !((DS[pi][ni[pi]] > 1e13 || DS[pi][ni[pi]] < -1e13) && input == "00") {
            
            if (input == "0" || input == "00") && (tempDigits[pi][ni[pi]] == "0" || tempDigits[pi][ni[pi]] == "-0" || tempDigits[pi][ni[pi]] == "" || tempDigits[pi][ni[pi]] == "-"){
                switch tempDigits[pi][ni[pi]] {
                case ""  :
                    tempDigits[pi][ni[pi]] += "0"
                    process += "0"
                    
                case "-":
                    tempDigits[pi][ni[pi]] += "0"
                    process += "0"
                default : break
                }
            }
            
            else if (input == ".") && (tempDigits[pi][ni[pi]] == "" || tempDigits[pi][ni[pi]] == "-" || tempDigits[pi][ni[pi]].contains(".")){//공백, - , . >> . : 모든 경우 수정됨.
                switch tempDigits[pi][ni[pi]] {
                case ""  :
                    tempDigits[pi][ni[pi]]  += "0."
                    process += "0."
                case "-" :
                    tempDigits[pi][ni[pi]] += "0."
                    process += "0."
                default : break
                }
                
            }
            
            else if (input != "0" && input != "00" && input != ".") && (tempDigits[pi][ni[pi]] == "0" || tempDigits[pi][ni[pi]] == "-0"){ // 0 , -0 >> 숫자 입력 : 모든 경우 수정됨.
                tempDigits[pi][ni[pi]].removeLast()
                tempDigits[pi][ni[pi]] += input
                
                process.removeLast()
                process += input
                
            }
            // 괄호 닫고 바로 숫자 누른 경우.
            else if tempDigits[pi][ni[pi]].contains("parenclose") && operationStorage[pi][ni[pi]] == ""{
                setteroi += 1
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] += tagToUnitSize["×"]!
                
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "oper"
                
                addStrForProcess()
                strForProcess[setteroi] = "×"
                
                setteroi += 1
                addSumOfUnitSizes()
                addPOfNumsAndOpers()
                addStrForProcess()
                
                operInputSetup("×", ni[pi])
                process += operationStorage[pi][ni[pi]]
                indexUpdate()
                tempDigits[pi][ni[pi]] = input
                
                if input == "."{
                    tempDigits[pi][ni[pi]] = "0."
                    process += "0"
                }
                
                process += String(input)
                sendNotification()
            }
            
            else { // usual case
                tempDigits[pi][ni[pi]] += input
                process += String(input)
            }
            
            if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                DS[pi][ni[pi]] = safeDigits
                freshDI[pi][ni[pi]] = 1
                negativePossible = false
            }
        }
        else if ((DS[pi][ni[pi]] > 1e14 || DS[pi][ni[pi]] < -1e14) && tempDigits[pi][ni[pi]].contains(".")){
            
            process += input
            tempDigits[pi][ni[pi]] += input
            
            if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                DS[pi][ni[pi]] = safeDigits
                freshDI[pi][ni[pi]] = 1
                negativePossible = false
            }
        }// 15자리에서 . 없는 경우
        else if ((DS[pi][ni[pi]] > 1e14 || DS[pi][ni[pi]] < -1e14) && !tempDigits[pi][ni[pi]].contains(".")){
            if input == "."{
                process += String(input)
                tempDigits[pi][ni[pi]] += "."
            }
        }
        
        addPOfNumsAndOpers()
      
        pOfNumsAndOpers[setteroi] = "n"
     
        
        addStrForProcess()
        showAnsAdvance()
        printProcess()// comment 처리가 왜 되어있었을까?
        
        
    }
    
    
    
    
    
    
    @objc func operationPressed(sender : UIButton){
        
        if let operInput = tagToString[sender.tag]{ // : String
            iPressed += operInput
            
            if isAnsPressed{    // ans + - x /
                
                clear()
                process = ""
                isAnsPressed = false
                DS[0][0] = saveResult!
                
                tempDigits[0][0] = nf6.string(for: saveResult!)!
                
                
                
                if DS[0][0] < 0{
                    isNegativeSign = [[false,true]]
                }
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "n"
                
                addStrForProcess()
                
                negativePossible = false
                
                printProcess()
                saveResult = nil
                freshDI[0][0] = 1
                setteroi += 1
                
                operInputSetup(operInput, ni[0])
                
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
                
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "oper"
                dictionaryForLine[setteroi] = operInput
                
                addStrForProcess()
                strForProcess[setteroi] = operInput
                // ["+","-","×","÷","(",")"]
                process += operationStorage[0][0]
                indexUpdate()
                setteroi += 1
                addPOfNumsAndOpers()
                addSumOfUnitSizes()
                addStrForProcess()
            }
            
            else if negativePossible{ // true until number input.
                if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == ""{// input negative Sign
                    
                    if operInput == "-"{
                        process += "-"
                        isNegativeSign[pi][numOfPossibleNegative[pi]] = true
                        tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = "-"
                        //                        sumOfUnitSizes.append(0)
                        if pi != 0{
                            setteroi += 1
                        }
                        addSumOfUnitSizes()
                        sumOfUnitSizes[setteroi] = tagToUnitSize["-"]!
                        addPOfNumsAndOpers()
                        pOfNumsAndOpers[setteroi] = "n"
                        addStrForProcess()
                        strForProcess[setteroi] = "-"
                        
                    } else if operInput != "-"{ //first input : + x / -> do nothing.
                        sendNotification()
                    }
                }
                
                else if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == "-"{ // for negative sign
                    if operInput == "-"{}// - >> - : ignore input.
                    else if operInput != "-"{ // - >> + * /
                        //                        printLineSetterElements("operation modified3")
                        process.removeLast()
                        isNegativeSign[pi][numOfPossibleNegative[pi]] = false
                        tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = ""
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["-"]!
                        setteroi -= 1
                        if setteroi < 0{
                            setteroi = 0
                        }
                        pOfNumsAndOpers.removeLast()
                        strForProcess.removeLast()
                        
                    }
                    
                    sendNotification()// both cases are abnormal.
                }
            }
            
            else if !negativePossible{ // modify Operation Input for duplicate case.
                if tempDigits[pi][ni[pi]] == ""{
                    //                    printLineSetterElements("operation modified")
                    operInputSetup(operInput, ni[pi]-1)
                    process.removeLast()
                    process += operationStorage[pi][ni[pi]-1]
                    sendNotification()
                    
                    sumOfUnitSizes[setteroi-1] = tagToUnitSizeString[operInput]!
                    strForProcess[setteroi-1] = operInput
                    dictionaryForLine[setteroi-1] = operInput
                    
                }
                
                else{       //normal case
                    if process[process.index(before:process.endIndex)] == "."{ // 1.+ >> 1+ // 요깄당.
                        if tempDigits[pi][ni[pi]].contains("."){
                            sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                            tempDigits[pi][ni[pi]].removeLast() // remove "."
                            process.removeLast()
                            sendNotification()
                            
                            strForProcess[setteroi].removeLast()
                        }
                    }
                    //                    printLineSetterElements("operation modified2")
                    setteroi += 1
                    
                    
                    operInputSetup(operInput, ni[pi])
                    process += operationStorage[pi][ni[pi]]
                    indexUpdate()
                    
                    addSumOfUnitSizes()
                    
                    sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    
                    addStrForProcess()
                    strForProcess[setteroi] = operInput
                    
                    dictionaryForLine[setteroi] = operInput
                    
                    //                    ["+","-","×","÷","(",")"]
                    setteroi += 1
                    addPOfNumsAndOpers()
                    addSumOfUnitSizes()
                    addStrForProcess()
                }
            }
            printProcess()
        }
    }
    

    func manualOperationPressed(operSymbol : String){
        // ["+","-","×","÷","(",")"]
        let operInput = operSymbol
        //        showAnsAdvance()
        
        if isAnsPressed{
            
            clear()
            process = ""
            isAnsPressed = false
            DS[0][0] = saveResult!
            
            tempDigits[0][0] = nf6.string(for: saveResult!)!
            
            
            if DS[0][0] < 0{
                isNegativeSign = [[false,true]]
            }
            addPOfNumsAndOpers()
            pOfNumsAndOpers[setteroi] = "n"
            
            addStrForProcess()
            
            negativePossible = false // 이름 다시 짓기. (negativePossible) 변수는 명사, 함수명은 동사로 .
            
            printProcess()
            saveResult = nil
            freshDI[0][0] = 1
            setteroi += 1
            
            operInputSetup(operInput, ni[0])
            
            addSumOfUnitSizes()
            sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
            
            addPOfNumsAndOpers()
            pOfNumsAndOpers[setteroi] = "oper"
            dictionaryForLine[setteroi] = operInput
            
            addStrForProcess()
            strForProcess[setteroi] = operInput
            process += operationStorage[0][0]
            indexUpdate()
            setteroi += 1
            addPOfNumsAndOpers()
            addSumOfUnitSizes()
            addStrForProcess()
        }
        //        else if isNegativePossible{ // true until number input.
        else if negativePossible{
            if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == ""{// input negative Sign
                
                if operInput == "-"{
                    process += "-"
                    isNegativeSign[pi][numOfPossibleNegative[pi]] = true
                    tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = "-"
                    
                    if pi != 0{
                        setteroi += 1
                    }
                    
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSize["-"]!
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "n"
                    addStrForProcess()
                    strForProcess[setteroi] = "-"
                }
                else if operInput != "-"{ //first input : + x / -> do nothing.
                    sendNotification()
                }
            }
            
            else if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == "-"{
                if operInput == "-"{}// - >> - : ignore input.
                else if operInput != "-"{ // - >> + * /
                    process.removeLast()
                    isNegativeSign[pi][numOfPossibleNegative[pi]] = false
                    tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = ""
                    sumOfUnitSizes[setteroi] -= tagToUnitSizeString["-"]!
                    setteroi -= 1
                    if setteroi < 0{
                        setteroi = 0
                    }
                    pOfNumsAndOpers.removeLast()
                    strForProcess.removeLast()
                    
                }
                sendNotification()// both cases are abnormal.
            }
        }
        else if !negativePossible{ // modify Operation Input
            if tempDigits[pi][ni[pi]] == ""{
                operInputSetup(operInput, ni[pi]-1)
                process.removeLast()
                process += operationStorage[pi][ni[pi]-1]
                sendNotification()
                sumOfUnitSizes[setteroi-1] = tagToUnitSizeString[operInput]!
                strForProcess[setteroi-1] = operInput
                dictionaryForLine[setteroi-1] = operInput
            }
            
            else{
                if process[process.index(before:process.endIndex)] == "."{ // 1.+ >> 1+
                    if tempDigits[pi][ni[pi]].contains("."){
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                        tempDigits[pi][ni[pi]].removeLast() // remove "."
                        process.removeLast()
                        sendNotification()
                        
                        strForProcess[setteroi].removeLast()
                    }
                } // && 조건으로 엮기.
                setteroi += 1
                
                operInputSetup(operInput, ni[pi])
                process += operationStorage[pi][ni[pi]]
                indexUpdate()
                
                addSumOfUnitSizes()
                
                sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "oper"
                
                addStrForProcess()
                strForProcess[setteroi] = operInput
                
                dictionaryForLine[setteroi] = operInput
                
                
                
                //                    ["+","-","×","÷","(",")"]
                setteroi += 1
                addPOfNumsAndOpers()
                addSumOfUnitSizes()
                addStrForProcess()
                
            }
        }
        printProcess()
    }
    
    
    @objc func calculateAns() {
        
        if process == ""{
            clear()
        }
        
        if !isAnsPressed {
            copyCurrentStates()
            
            filterProcess()
            numParenCount = pi
            while pi > 0{
                niEnd[pi].append(ni[pi])
                pi -= 1
                process += ")"
                //                numParenCount += 1
                if !showingAnsAdvance{
                    iPressed += "="
                    while(numParenCount != 0){
                        
                        setteroi += 1
                        addSumOfUnitSizes()
                        sumOfUnitSizes[setteroi] += tagToUnitSize[")"]!
                        
                        addPOfNumsAndOpers()
                        pOfNumsAndOpers[setteroi] = "cp"
                        
                        addStrForProcess()
                        strForProcess[setteroi] = ")"
        
                        numParenCount -= 1
                    }
                }
            
                tempDigits[pi][ni[pi]] += "close"
                if !showingAnsAdvance{
                    sendNotification()
                }
            }
            
            if !showingAnsAdvance{
                copyCurrentStates()
                printProcess()
                if process != ""{
                    isAnsPressed = true // 이거 원래 한 5줄 아래에 있었음.
                }
            }
            
            niEnd[0].append(ni[pi])
            
            pi = piMax
            piLoop : while pi >= 0 {
                for a in 1 ... niStart[pi].count-1{
                    for i in niStart[pi][a] ..< niEnd[pi][a]{
                        // first for statement : for Operation == "×" or "÷"
                        if muldiOperIndex[pi][i]{
                            if freshDI[pi][i] == 1 && freshDI[pi][i+1] == 1{
                                //곱셈 , D[i]전항과 D[i+1]후항 존재, >> 두개 곱함.
                                if operationStorage[pi][i] == "×" {
                                    answer[pi][i] = DS[pi][i] *  DS[pi][i+1]
                                }else if  operationStorage[pi][i] == "÷"{
                                    answer[pi][i] = DS[pi][i] /  DS[pi][i+1]
                                }
                                freshAI[pi][i] = 1 ; freshDI[pi][i] = 2 ; freshDI[pi][i+1] = 2
                                result = answer[pi][i]
                            }else if  freshDI[pi][i] == 2 && freshDI[pi][i+1] == 1{
                                //곱셈, D[i]전항 존재 안할 때 >> A[i-1] * D[i+1]
                                if  operationStorage[pi][i] == "×"{
                                    answer[pi][i] = answer[pi][i-1] *  DS[pi][i+1]
                                }else if  operationStorage[pi][i] == "÷"{
                                    answer[pi][i] = answer[pi][i-1] /  DS[pi][i+1]
                                }
                                freshAI[pi][i] = 1;freshAI[pi][i-1] = 2 ; freshDI[pi][i+1] = 2
                                result = answer[pi][i]
                            }
                        }
                    } // end for i in niStart[pi][a] ...niEnd[pi][a]{
                    
                    for i in niStart[pi][a] ..< niEnd[pi][a]{
                        if !muldiOperIndex[pi][i]{ //{b
                            if freshDI[pi][i+1] == 1{
                                //+ 연산 >> D[i+1] 존재
                                if freshDI[pi][i] == 1{
                                    //+ 연산 >> D[i+1] 존재 >> D[i] 존재
                                    if  operationStorage[pi][i] == "+"{
                                        answer[pi][i] =  DS[pi][i] +  DS[pi][i+1]
                                    } else if  operationStorage[pi][i] == "-"{
                                        answer[pi][i] =  DS[pi][i] -  DS[pi][i+1]
                                    }
                                    freshAI[pi][i] = 1 ; freshDI[pi][i] = 2 ; freshDI[pi][i+1] = 2
                                    result = answer[pi][i]
                                }
                                else if freshDI[pi][i] == 2{
                                    //+ 연산 >> D[i+1] 존재 >> D[i] 존재 ㄴㄴ
                                    tobreak : for k in 1 ... i{
                                        //freshAI[i-k] 찾음
                                        if (freshAI[pi][i-k] == 1){ // 왜 한번이 더돌아? 아.. 예전꺼 찾아가는구나! 끊어줘야해. 어디서?
                                            if  operationStorage[pi][i] == "+"{
                                                answer[pi][i] = answer[pi][i-k] +  DS[pi][i+1]
                                            } else if  operationStorage[pi][i] == "-"{
                                                answer[pi][i] = answer[pi][i-k] -  DS[pi][i+1]
                                            }
                                            freshAI[pi][i] = 1;freshAI[pi][i-k] = 2 ; freshDI[pi][i+1] = 2
                                            result = answer[pi][i]
                                            break tobreak
                                        }
                                    }
                                }
                            }
                            else if freshDI[pi][i+1] == 2{
                                //  D[i+1] 존재 ㄴㄴ
                                noLatterNum : for k in i ... ni[pi]-1 {
                                    //if freshAI[k+1] found
                                    if freshAI[pi][k+1] == 1 {
                                        //  D[i+1] 존재 ㄴㄴ >>Ans[k](k :  i+1, ... ni) 존재 >>  DI[i] 존재
                                        if freshDI[pi][i] == 1{
                                            if  operationStorage[pi][i] == "+"{
                                                answer[pi][i] =  DS[pi][i] + answer[pi][k+1]}
                                            else if  operationStorage[pi][i] == "-"{
                                                answer[pi][i] =  DS[pi][i] - answer[pi][k+1]}
                                            freshAI[pi][i] = 1; freshDI[pi][i] = 2; freshAI[pi][k+1] = 2;
                                            result = answer[pi][i]
                                            break noLatterNum
                                            //+연산 >> D[i+1] 존재 ㄴㄴ >>Ans[k](k : i+1, i+2, ... ni-1 존재 >> D[i] 존재 ㄴㄴ
                                        }
                                        else if freshDI[pi][i] == 2{
                                            for j in 0 ... i{
                                                if freshAI[pi][i-j] == 1 {
                                                    //+연산 >> D[i+1] 존재 ㄴㄴ >>Ans[k](k>i) 존재 >> D[i] 존재 ㄴㄴ >> A[i-j](i-j < i) 존재
                                                    if  operationStorage[pi][i] == "+"{
                                                        answer[pi][i] = answer[pi][i-j] + answer[pi][k+1]
                                                    } else if  operationStorage[pi][i] == "-"{
                                                        answer[pi][i] = answer[pi][i-j] - answer[pi][k+1]
                                                    }
                                                    freshAI[pi][i] = 1; freshAI[pi][i-j] = 2; freshAI[pi][k+1] = 2
                                                    result = answer[pi][i]
                                                    break noLatterNum
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } // end of all calculations. (for i in niStart[pi][a] ..< niEnd[pi][a])
                } // for a in 1 ... niStart[pi].count-1{
                
                
                if pi > 0{
                    for a in 1 ... niStart[pi].count-1{
                        if niStart[pi][a] != niEnd[pi][a]{
                            for i in niStart[pi][a] ..< niEnd[pi][a]{
                                if freshAI[pi][i] == 1{
                                    DS[pi-1][positionOfParen[pi-1][a]] = answer[pi][i]
                                    freshDI[pi-1][ positionOfParen[pi-1][a]] = 1
                                    freshAI[pi][i] = 2
                                }
                            }
                        }
                        else if niStart[pi][a] == niEnd[pi][a]{
                            DS[pi-1][positionOfParen[pi-1][a]] = DS[pi][niStart[pi][a]]
                            freshDI[pi][niStart[pi][a]] = 2
                            freshDI[pi-1][positionOfParen[pi-1][a]] = 1
                        }
                    }
                    
                    for b in 1 ... niStart[pi-1].count-1{
                        if b <  positionOfParen[pi-1].count{
                            if  positionOfParen[pi-1][b] == niStart[pi-1][b]{
                                if isNegativeSign[pi-1][b]{
                                    DS[pi-1][niStart[pi-1][b]] *= -1
                                }
                            }
                        }
                    }
                    pi -= 1
                    continue piLoop
                }
                if result == nil{
                    
                    result = DS[0][0]
                    
                }
                if result! >= 1e15 || result! <= -1e15{
                    pasteStates()
                    anslimitExceedToast()
                    isAnsPressed = false // 이게 왜 여기있어 ? 여기 있어 ㅇㅇ .
                    break piLoop
                }
                if result != nil{
                    if process != ""{
                        floatingNumberDecider(ans : result!)
                    }else{
                        niEnd = [[0]]
                        result = nil
                        resultTextView.text = ""
                    }
                    //                            historyIndex += 1
                }
                let name = Notification.Name(rawValue: answerToTableNotificationKey)
                NotificationCenter.default.post(name: name, object: nil)
                break piLoop
            } // piLoop : while pi >= 0 {
        }
    }
    
    func anslimitExceedToast(){
        if let languageCode = Locale.current.languageCode{
            if languageCode.contains("ko"){
                self.showToast(message: self.localizedStrings.answerLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.7, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
            }else{
                
                self.showToast(message: self.localizedStrings.answerLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.6, heightRatio: 0.08, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
            }
        }
    }
    
    func floatingExceedToast(){
        if let languageCode = Locale.current.languageCode{
            if languageCode.contains("ko"){
                self.showToast(message: self.localizedStrings.floatingLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.7, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
            }else{
                
                self.showToast(message: self.localizedStrings.floatingLimit, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.6, heightRatio: 0.08, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
            }
        }
    }
    
    
    func showAnsAdvance(){
        
        showingAnsAdvance = true
        calculateAns() // 이거 .. 하면 .. 정답 가능성이 보이면 바로 RealmData 에 추가되는거 아니냐?
        
        resultTextView.textColor = isLightModeOn ? colorList.textColorForSemiResultBM : colorList.textColorForSemiResultDM
        isAnsPressed = false
        pasteStates()
        showingAnsAdvance = false
        
    }
    
    
    @objc func parenthesisPressed(sender : UIButton){
        if let input = tagToString[sender.tag]{
            iPressed += input
            
            if input == "("{
                
                if isAnsPressed{
                    clear()
                    process = ""
                    isAnsPressed = false
                    
                    DS[0][0] = saveResult!
                    
                    freshDI[0][0] = 1
                    //                    let nf6 = NumberFormatter()
                    //                    nf6.roundingMode = .down
                    //                    nf6.maximumFractionDigits = 6
                    tempDigits[0][0] = nf6.string(for: saveResult!)!
                    //                    tempDigits[0][0] = "\(String(format : "%.\(floatingNumberDigits ?? 0)f", saveResult!))"
                    
                    freshDI[0][0] = 1
                    if DS[0][0] < 0{
                        isNegativeSign = [[false,true]]
                    }
                    negativePossible = false
                    
                    printProcess() // duplicate printProcess ??
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "n"
                    
                    addStrForProcess()
                    
                    setteroi += 1
                    
                    
                    saveResult = nil
                    operInputSetup("×", ni[0])
                    
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSize["×"]!
                    
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    
                    addStrForProcess()
                    strForProcess[setteroi] = "×"
                    
                    dictionaryForLine[setteroi] = "×"
                    
                    process += "×"
                    indexUpdate()
                    
                    //                    setteroi -= 1
                    //1300
                }// and of isAnsPressed
                
                // 숫자만 입력하고 x 누르지 않은 상태로 ( 누를 때
                if operationStorage[pi][ni[pi]] == "" && tempDigits[pi][ni[pi]] != ""{ // 1(
                    //                    if tempDigits[pi][ni[pi]] == "0." || tempDigits[pi][ni[pi]] == "-0."{// 0. , -0. >> input (
                    if process[process.index(before : process.endIndex)] == "."{ // 5.( >> 5x(
                        //remove dot.
                        //                        sumOfUnitSizes.append(0)
                        addSumOfUnitSizes()
                        
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                        tempDigits[pi][ni[pi]].removeLast()
                        process.removeLast()
                        sendNotification()
                    }
                    if tempDigits[pi][ni[pi]] != "-"{ //add "×" after any number
                        setteroi += 1
                        addPOfNumsAndOpers()
                        pOfNumsAndOpers[setteroi] = "oper"
                        addSumOfUnitSizes()
                        sumOfUnitSizes[setteroi] = tagToUnitSize["×"]!
                        
                        addStrForProcess()
                        strForProcess[setteroi] = "×"
                        
                        dictionaryForLine[setteroi] = "×"
                        
                        
                        operationStorage[pi][ni[pi]] = "×"
                        muldiOperIndex[pi][ni[pi]] = true
                        process += operationStorage[pi][ni[pi]]
                        indexUpdate()
                        sendNotification()
                        setteroi += 1
                    }
                }
                
                addSumOfUnitSizes()
                
                if sumOfUnitSizes[setteroi] != 0{
                    setteroi += 1
                }
                
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "op"
                
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = tagToUnitSize["("]!
                
                addStrForProcess()
                strForProcess[setteroi] = "("
                //                setteroi += 1
                process += input
                
                positionOfParen[pi].append(ni[pi])
                
                tempDigits[pi][ni[pi]] += "paren"
                pi += 1
                //                setteroi += 1// 이렇게 하면 ((( 있을 때 인덱스 껑충껑충함.
                
                if pi > piMax{
                    piMax = pi
                    ni.append(0)
                    tempDigits.append([""])
                    DS.append([0])
                    freshDI.append([0])
                    answer.append([150])
                    freshAI.append([0])
                    operationStorage.append([""])
                    muldiOperIndex.append([false])
                    
                    indexPivotHelper.append(false)
                    isNegativeSign.append([false, false])
                    numOfPossibleNegative.append(1)
                    
                    niStart.append([0])
                    niEnd.append([0])
                    
                    positionOfParen.append([0])
                }
                
                if indexPivotHelper[pi]{ // else case of pi > piMax
                    ni[pi] += 1
                    tempDigits[pi].append("")
                    DS[pi].append(0)
                    freshDI[pi].append(0)
                    
                    operationStorage[pi].append("")
                    muldiOperIndex[pi].append(false)
                    
                    answer[pi].append(0)
                    freshAI[pi].append(0)
                    
                    isNegativeSign[pi].append(false)
                    numOfPossibleNegative[pi] += 1
                }
                
                niStart[pi].append(ni[pi])
                indexPivotHelper[pi] = true
                negativePossible = true
            }
            
            else if (pi != 0) && input == ")"{
                if process[process.index(before:process.endIndex)] != "(" &&  process[process.index(before:process.endIndex)] != "-" && process[process.index(before:process.endIndex)] != "×" && process[process.index(before:process.endIndex)] != "+" && process[process.index(before:process.endIndex)] != "÷" {
                    
                    if process[process.index(before:process.endIndex)] == "."{ // 1.) >> 1) //
                        if tempDigits[pi][ni[pi]].contains("."){
                            tempDigits[pi][ni[pi]].removeLast() // remove "."
                            process.removeLast()
                            sendNotification()
                            addSumOfUnitSizes()
                            sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                        }
                    }
                    
                    setteroi += 1
                    
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSize[")"]!
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "cp"
                    
                    addStrForProcess()
                    strForProcess[setteroi] = ")"
                    
                    niEnd[pi].append(ni[pi])
                    pi -= 1
                    process += input
                    tempDigits[pi][ni[pi]] += "close"
                    negativePossible = false
                }
                else{sendNotification() } // input is ) and end of process is ( + - × ÷ >> ignore !
            }
            else{sendNotification()} // pi == 0 , close paren before open it.
            printProcess()
            //            setteroi += 1
        }
    }
    
    
    func manualParenthesis(trueToOpen : Bool){
        let input = trueToOpen ? "(" : ")"
        
        if input == "("{
            
            
            if operationStorage[pi][ni[pi]] == "" && tempDigits[pi][ni[pi]] != ""{ // 1(
                //                if tempDigits[pi][ni[pi]] == "0." || tempDigits[pi][ni[pi]] == "-0."{// 0. , -0. >> input (
                //                    tempDigits[pi][ni[pi]] += "0"
                //                    process += "0"
                //                    sendNotification()
                //                }
                if process[process.index(before : process.endIndex)] == "."{ // 5.( >> 5x(
                    //remove dot.
                    //                        sumOfUnitSizes.append(0)
                    addSumOfUnitSizes()
                    
                    sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                    tempDigits[pi][ni[pi]].removeLast()
                    process.removeLast()
                    sendNotification()
                }
                if tempDigits[pi][ni[pi]] != "-"{ //add "×" after any number if input is "("
                    setteroi += 1
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSize["×"]!
                    
                    addStrForProcess()
                    strForProcess[setteroi] = "×"
                    
                    dictionaryForLine[setteroi] = "×"
                    
                    
                    
                    
                    operationStorage[pi][ni[pi]] = "×"
                    muldiOperIndex[pi][ni[pi]] = true
                    process += operationStorage[pi][ni[pi]]
                    indexUpdate()
                    sendNotification()
                    setteroi += 1
                    //                    addPOfNumsAndOpers()
                    //                    addStrForProcess()
                    //                    addSumOfUnitSizes()
                }
            }
            
            addSumOfUnitSizes()
            
            if sumOfUnitSizes[setteroi] != 0{// 이건 뭐야?
                setteroi += 1
            }
            addPOfNumsAndOpers()
            pOfNumsAndOpers[setteroi] = "op"
            
            addSumOfUnitSizes()
            sumOfUnitSizes[setteroi] = tagToUnitSize["("]!
            
            addStrForProcess()
            strForProcess[setteroi] = "("
            //            setteroi += 1
            
            process += input
            
            positionOfParen[pi].append(ni[pi])
            
            tempDigits[pi][ni[pi]] += "paren"
            pi += 1
            
            if pi > piMax{
                piMax = pi
                ni.append(0)
                tempDigits.append([""])
                DS.append([0])
                freshDI.append([0])
                answer.append([150])
                freshAI.append([0])
                operationStorage.append([""])
                muldiOperIndex.append([false])
                
                indexPivotHelper.append(false)
                isNegativeSign.append([false, false])
                numOfPossibleNegative.append(1)
                
                niStart.append([0])
                niEnd.append([0])
                
                positionOfParen.append([0])
            }
            
            if indexPivotHelper[pi]{ // else case of pi > piMax
                ni[pi] += 1
                tempDigits[pi].append("")
                DS[pi].append(0)
                freshDI[pi].append(0)
                
                operationStorage[pi].append("")
                muldiOperIndex[pi].append(false)
                
                answer[pi].append(0)
                freshAI[pi].append(0)
                
                isNegativeSign[pi].append(false)
                numOfPossibleNegative[pi] += 1
            }
            
            niStart[pi].append(ni[pi])
            indexPivotHelper[pi] = true
            negativePossible = true
        }
        else if (pi != 0) && input == ")"{
            if process[process.index(before:process.endIndex)] != "(" &&  process[process.index(before:process.endIndex)] != "-" && process[process.index(before:process.endIndex)] != "×" && process[process.index(before:process.endIndex)] != "+" && process[process.index(before:process.endIndex)] != "÷" {
                
                if process[process.index(before:process.endIndex)] == "."{ // 1.) >> 1) //
                    if tempDigits[pi][ni[pi]].contains("."){
                        tempDigits[pi][ni[pi]].removeLast() // remove "."
                        process.removeLast()
                        sendNotification()
                        addSumOfUnitSizes()
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                    }
                }
                
                setteroi += 1
                
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = tagToUnitSize[")"]!
                addPOfNumsAndOpers()
                pOfNumsAndOpers[setteroi] = "cp"
                //                dicForProcess[setteroi] = ")"
                addStrForProcess()
                strForProcess[setteroi] = ")"
                
                
                niEnd[pi].append(ni[pi])
                pi -= 1
                process += input
                tempDigits[pi][ni[pi]] += "close"
                negativePossible = false
            }
            else{sendNotification() } // input is ) and end of process is ( + - × ÷ >> ignore !
        }
        else{sendNotification()} // pi == 0 , close paren before open it.
        printProcess()
        
    }
    
    
    
    @objc func deleteExecute(){
        iPressed += "del"
        
        playSound()
        
        
        
        caseframe : if process != ""{
            
            if process[process.index(before: process.endIndex)] == "\n"{
                process.removeLast()
            }
            
            
            if isAnsPressed
            {
                pasteStates()
            }
            isAnsPressed = false
            // case0_ "="
            if process[process.index(before:process.endIndex)] == "="{ // = 을 지울 경우.
                sumOfUnitSizes[setteroi] = 0
                pOfNumsAndOpers.removeLast()
                setteroi -= 1
                process.removeLast()
                printProcess()
                break caseframe
            }
            
            
            
            // if number deleted.
            //           numbers = ["0","1","2","3","4","5","6","7","8","9","."]
            case1_Number : for i in numbers{
                if process[process.index(before:process.endIndex)] == i{
                    //when last digit is deleted
                    if process.count <= 1{ // less or equal to one digit
                        tempDigits[pi][ni[pi]] = ""
                        DS[pi][ni[pi]] = 0 // 이상해. 지우면 없는 수가 되어야 하는데 0 이 됨. ?? 보류.
                        freshDI[pi][ni[pi]] = 0
                        process = ""
                        negativePossible = true // 이게 문제야. 왜 true 라고 했을까?
                        printProcess()
                        sumOfUnitSizes[setteroi] = 0
                        
                        break caseframe
                    } // usual case.
                    
                    else if process.count > 1{
                        process.removeLast()
                        tempDigits[pi][ni[pi]].removeLast()
                        
                        if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                            DS[pi][ni[pi]] = safeDigits
                            freshDI[pi][ni[pi]] = 1
                        }
                        //                        printProcess()
                        
                        for k in numbers{ // 뒤에 digit 더 있으면 DS, freshDI 없애지 않고 넘어가.
                            if process[process.index(before:process.endIndex)] == k{
                                break caseframe // more numbers left, break loop. tempDigits도 수정해야함...
                            }
                        }
                        
                        if tempDigits[pi][ni[pi]] == "-"{
                            negativePossible = true
                        }
                        
                        // if cannot find number leftover
                        DS[pi][ni[pi]] = 0
                        
                        freshDI[pi][ni[pi]] = 0
                        //                        printLineSetterElements("numberDelete3")
                        sumOfUnitSizes[setteroi] -= tagToUnitSize[i]!
                        
                        if sumOfUnitSizes[setteroi] < 0.01{
                            strForProcess[setteroi] = ""
                        }
                        if process.last == "("{
                            pOfNumsAndOpers.removeLast()
                            strForProcess.removeLast()
                            setteroi -= 1
                        }
                        
                        break caseframe
                    }
                }
            }// end number case.
            
            //if operation deleted.
            case2_Operator : for i in operators{
                if process[process.index(before:process.endIndex)] == i{
                    process.removeLast()
                    
                    //                    sumOfUnitSizes[setteroi] = 0// 이거 꼭 필요해? 이거 .. 아래 놓자.
                    pOfNumsAndOpers.removeLast()
                    strForProcess.removeLast()
                    // why ? why not working well?
                    
                    
                    if ni[pi] > niStart[pi][numOfPossibleNegative[pi]]{
                        ni[pi] -= 1
                        tempDigits[pi].removeLast()
                        DS[pi].removeLast()
                        answer[pi].removeLast()
                        freshDI[pi].removeLast()
                        freshAI[pi].removeLast()
                        
                        operationStorage[pi].removeLast()
                        operationStorage[pi][ni[pi]] = ""
                        
                        muldiOperIndex[pi].removeLast()
                        muldiOperIndex[pi][ni[pi]] = false
                    }
                    
                    else{ // 음수의 부호를 지운 경우 .
                        negativePossible = true
                        tempDigits[pi][ni[pi]].removeLast()
                        isNegativeSign[pi][numOfPossibleNegative[pi]] = false
                        sumOfUnitSizes[setteroi] = 0
                        setteroi -= 1
                        break caseframe
                    }
                    setteroi -= 1
                    dictionaryForLine.removeValue(forKey: setteroi)
                    sumOfUnitSizes[setteroi] = 0
                    setteroi -= 1 // 뭐냐. 왜 두개 감소되냐!!!!
                    break caseframe
                }
            }
            
            case3_OpenParenthesis : if process[process.index(before:process.endIndex)] == "("{
                process.removeLast()
                
                if process != ""{
                    if process[process.index(before:process.endIndex)] == "("{
                        negativePossible = true
                    }else{
                        negativePossible = false
                    }
                }
                
                if numOfPossibleNegative[pi] == 1{ // one parenthesis is only left and about to deleted.
                    indexPivotHelper.removeLast()
                    niStart.removeLast()
                    niEnd.removeLast()
                    numOfPossibleNegative.removeLast()
                    freshAI.removeLast()
                    answer.removeLast()
                    muldiOperIndex.removeLast()
                    operationStorage.removeLast()
                    freshDI.removeLast()
                    DS.removeLast()
                    tempDigits.removeLast()
                    ni.removeLast()
                    isNegativeSign.removeLast()
                    positionOfParen.removeLast()
                }
                
                else if numOfPossibleNegative[pi] > 1{
                    niStart[pi].removeLast()
                    numOfPossibleNegative[pi] -= 1
                    freshAI[pi].removeLast()
                    answer[pi].removeLast()
                    muldiOperIndex[pi].removeLast()
                    operationStorage[pi].removeLast()
                    freshDI[pi].removeLast()
                    DS[pi].removeLast()
                    tempDigits[pi].removeLast()
                    ni[pi] -= 1
                    isNegativeSign[pi].removeLast()
                }
                
                pi -= 1
                positionOfParen[pi].removeLast()
                piMax = ni.count-1
                
                if tempDigits[pi][ni[pi]].contains("paren"){
                    for _ in 1 ... 5 {
                        tempDigits[pi][ni[pi]].removeLast()
                    }
                }
                
                sumOfUnitSizes[setteroi] = 0
                
                if process.last == "("{
                    setteroi -= 1
                    pOfNumsAndOpers.removeLast()
                    
                    strForProcess.removeLast()
                }
                
                break caseframe
            }
            
            case4_ClosingParenthesis : if process[process.index(before:process.endIndex)] == ")"{
                process.removeLast()
                
                if tempDigits[pi][ni[pi]].contains("close"){
                    for _ in 1 ... 5 {
                        tempDigits[pi][ni[pi]].removeLast()
                    }
                }
                
                pi += 1
                niEnd[pi].removeLast()
                
                negativePossible = false
                for i in 0 ... numOfPossibleNegative.count-1{
                    if numOfPossibleNegative[i] != 0{
                        piMax = i
                    }
                }
                
                sumOfUnitSizes[setteroi] = 0
                pOfNumsAndOpers.removeLast()
                strForProcess.removeLast()
                setteroi -= 1
                break caseframe
            }
        } // end of caseframe
        
        else{
            sendNotification()
        }
        
        
        let eProcess = 0
        var sumForEachProcess = 0.0
        
        if numOfEnter[eProcess] != 0{
            
            oiLoop : for eODigit in lastMoveOP[eProcess][numOfEnter[eProcess]-1 ] ... setteroi{
                
                sumForEachProcess += sumOfUnitSizes[eODigit]// oi index
            }
            
            if sumForEachProcess <= 0.95 - 0.1{ // reverse
                
                if let lastEnterPosition = process.lastIndexInt(of: "\n"){
                    
                    process.remove(at: process.index(process.startIndex, offsetBy: lastEnterPosition, limitedBy: process.endIndex)!)
                }
                
                //                lastMovePP[eProcess].removeLast()
                lastMoveOP[eProcess].removeLast()
                numOfEnter[eProcess] -= 1
                
                sumForEachProcess = 0
            }
        }
        showAnsAdvance()
        printProcess()
    }
    
    @objc func clearPressed(sender : UIButton){
        clear()
        resultTextView.text = ""
        progressView.text = ""
        saveResult = nil
        //        floatingNumberDigits = nil
        process = ""
    }
    
    func manualClear(){
        clear()
        saveResult = nil
        //        floatingNumberDigits = nil
        process = ""
        progressView.text = process
    }
    
    
    @objc func clear(){
        iPressed = ""
        negativePossible = true
        isAnsPressed = false
        
        pi = 0
        ni = [0]
        tempDigits = [[""]]
        DS = [[0.0]]
        answer = [[100]]
        operationStorage = [[""]]
        muldiOperIndex = [[false]]
        
        freshDI = [[0]]
        freshAI = [[0]]
        
        niStart = [[0,0]]
        niEnd = [[0]]
        
        piMax = 0
        indexPivotHelper = [false]
        numOfPossibleNegative = [1]
        positionOfParen = [[0]]
        isNegativeSign = [[false, false]]
        
        process = ""
        result = nil
        
        copyfreshDI = [[0]]
        copyfreshAI = [[0]]
        copypi = 0
        copyDS = [[0.0]]
        copyanswer = [[100]]
        copyni = [0]
        copyniStart = [[0,0]]
        copyniEnd = [[0]]
        
        copytempDigits = [[""]]
        copyoperationStorage = [[""]]
        copymuldiOperIndex = [[false]]
        
        copypiMax = 0
        copyindexPivotHelper = [false]
        copynumOfPossibleNegative = [1]
        copypositionOfParen = [[0]]
        copyisNegativeSign = [[false, false]]
        copyisNegativePossible = true
        copyisAnsPressed = false
        copyprocess = ""
        
        sumOfUnitSizes = [0]
        
        
        setteroi = 0
        sumOfUnitSizes = [0.0]
        pOfNumsAndOpers  = [""]
        
        //        lastMovePP = [[0],[0],[0]] // lastMove Process Position
        lastMoveOP = [[0],[0],[0]]
        numOfEnter = [0,0,0]
        dictionaryForLine = [Int : String]()
        
        strForProcess = [""]
        
        numParenCount = 0
        
    }
    
    
    func indexUpdate(){
        ni[pi] += 1
        tempDigits[pi].append("")
        DS[pi].append(0)
        freshDI[pi].append(0)
        answer[pi].append(150)
        freshAI[pi].append(0)
        operationStorage[pi].append("")
        muldiOperIndex[pi].append(false)
    }
    
    
    func filterProcess(){
        let toBeRemovedList = [".", "(", "+", "-", "×", "÷"]
        processTillEmpty : while(process != ""){
            for _ in toBeRemovedList{
                if process[process.index(before:process.endIndex)] == "." { //last char is "."
                    process.removeLast()
                    tempDigits[pi][ni[pi]].removeLast()
                    if !showingAnsAdvance{
                        //                        if sumOfUnitSizes.count >= 1{
                        sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                        //                        }
                        strForProcess[setteroi].removeLast()
                    }
                    if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                        DS[pi][ni[pi]] = safeDigits
                        freshDI[pi][ni[pi]] = 1
                    }
                    if !showingAnsAdvance{
                        sendNotification()
                    }
                    continue processTillEmpty
                }
                
                else if process[process.index(before:process.endIndex)] == "(" { // last char is "("
                    
                    process.removeLast()
                    if !showingAnsAdvance{
                        if process.last == "("{
                            sumOfUnitSizes[setteroi] = 0
                            setteroi -= 1
                            pOfNumsAndOpers.removeLast()
                            strForProcess.removeLast()
                        }
                    }
                    if process != ""{
                        if process[process.index(before:process.endIndex)] == "("{
                            negativePossible = true
                        }else{
                            negativePossible = false
                        }
                    }
                    
                    if numOfPossibleNegative[pi] == 1{ // one parenthesis is only left and about to deleted.
                        indexPivotHelper.removeLast()
                        niStart.removeLast()
                        niEnd.removeLast()
                        numOfPossibleNegative.removeLast()
                        freshAI.removeLast()
                        answer.removeLast()
                        muldiOperIndex.removeLast()
                        operationStorage.removeLast()
                        freshDI.removeLast()
                        DS.removeLast()
                        tempDigits.removeLast()
                        ni.removeLast()
                        isNegativeSign.removeLast()
                        positionOfParen.removeLast()
                    }
                    
                    else if numOfPossibleNegative[pi] > 1{
                        niStart[pi].removeLast()
                        numOfPossibleNegative[pi] -= 1
                        freshAI[pi].removeLast()
                        answer[pi].removeLast()
                        muldiOperIndex[pi].removeLast()
                        operationStorage[pi].removeLast()
                        freshDI[pi].removeLast()
                        DS[pi].removeLast()
                        tempDigits[pi].removeLast()
                        ni[pi] -= 1
                        isNegativeSign[pi].removeLast()
                    }
                    
                    pi -= 1
                    positionOfParen[pi].removeLast()
                    piMax = ni.count-1
                    if tempDigits[pi][ni[pi]].contains("paren"){ // paren 지울 때 5번 필요해서 5번 돌림.
                        for _ in 1 ... 5 {
                            tempDigits[pi][ni[pi]].removeLast()
                        }
                    }
                    //                    printProcess()
                    sendNotification()
                    continue processTillEmpty
                }
                
                else if process[process.index(before:process.endIndex)] == "+" || process[process.index(before:process.endIndex)] == "-" || process[process.index(before:process.endIndex)] == "×" || process[process.index(before:process.endIndex)] == "÷" { // "last char is + - * /"
                    
                    process.removeLast()
                    
                    if !showingAnsAdvance{
                        dictionaryForLine.removeValue(forKey: setteroi-1)
                    }
                    
                    if ni[pi] > niStart[pi][numOfPossibleNegative[pi]]{ // 아마도 괄호 내 첫 수가 아닌경우
                        ni[pi] -= 1
                        tempDigits[pi].removeLast()
                        DS[pi].removeLast()
                        answer[pi].removeLast()
                        freshDI[pi].removeLast()
                        freshAI[pi].removeLast()
                        
                        operationStorage[pi].removeLast()
                        operationStorage[pi][ni[pi]] = ""
                        
                        muldiOperIndex[pi].removeLast()
                        muldiOperIndex[pi][ni[pi]] = false
                        
                        if !showingAnsAdvance{
                            sumOfUnitSizes[setteroi-1] = 0
                            
                            setteroi -= 2
                            
                            pOfNumsAndOpers.removeLast()
                            strForProcess.removeLast()
                        }
                    }
                    else{ // 음수의 부호를 지운 경우 .
                        negativePossible = true
                        tempDigits[pi][ni[pi]].removeLast()
                        isNegativeSign[pi][numOfPossibleNegative[pi]] = false
                        if !showingAnsAdvance{
                            sumOfUnitSizes[setteroi] = 0
                            setteroi -= 1
                            pOfNumsAndOpers.removeLast()
                            sumOfUnitSizes.removeLast()
                            strForProcess.removeLast()
                        }
                    }
                    sendNotification()
                    continue processTillEmpty
                }
            }
            break processTillEmpty
        }
        if !showingAnsAdvance{
            if setteroi < 0{
                clear()
            }
        }
    }
    
    
    func operInputSetup( _ tempOperInput : String, _ tempi : Int){
        switch tempOperInput{
        case "+" :  operationStorage[pi][tempi] = "+"
        case "×" :  operationStorage[pi][tempi] = "×"
        case "-" :  operationStorage[pi][tempi] = "-"
        case "÷" :  operationStorage[pi][tempi] = "÷"
        default: break
        }
        if  operationStorage[pi][tempi] == "×" ||  operationStorage[pi][tempi] == "÷"{
            muldiOperIndex[pi][tempi] = true}
        else {
            muldiOperIndex[pi][tempi] = false}
    }
    
    func floatingNumberDecider(ans : Double) { // ans : result!
       
        
        var realAns = ans
        var dummyStrWithComma = ""
        
        let dummyAnsString = nf6.string(for: ans)
        let dummyAnsDouble = Double(dummyAnsString!)
        realAns = dummyAnsDouble!
        
        
        if realAns == -0.0{
            realAns = 0.0
        }
        let date = Date()
        let dateString = date.getFormattedDate(format: "yyyy.MM.dd HH:mm")
        
        if !realAns.isNaN{
            
            dummyStrWithComma = numStrToNumWithComma(num: dummyAnsString!)
            
            resultTextView.text = dummyStrWithComma
            resultTextView.textColor = isLightModeOn ? colorList.textColorForResultBM : colorList.textColorForResultDM
            
            if !showingAnsAdvance{
                
                self.showToast(message: self.localizedStrings.savedToHistory, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
                
                let newHistoryRecord = HistoryRecord(processOrigin : process, processStringHis : lineSettingOtherProcess(1.4),processStringHisLong: lineSettingOtherProcess(1.8), processStringCalc: process, resultString: dummyStrWithComma, resultValue : realAns, dateString: dateString)
                lastMoveOP[1] = [0]
                lastMoveOP[2] = [0]
                numOfEnter[1] = 0
                numOfEnter[2] = 0
                
                
                RealmService.shared.create(newHistoryRecord)
                saveResult = realAns // what is the difference?
                
            }
            
        }else{
            anslimitExceedToast()
        }
        
        if !showingAnsAdvance{
            if process != ""{
                setteroi += 1
                addPOfNumsAndOpers()
                addStrForProcess()
                pOfNumsAndOpers[setteroi] = "e"
                strForProcess[setteroi] = ""
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = tagToUnitSize["="]!
                
                process += "="
                copyprocess = process
                printProcess()
            }
        }
    }
    
    @objc func ansPressed(sender : UIButton){
        calculateAns()
    }
    
    
    func addPOfNumsAndOpers(){
        if pOfNumsAndOpers.count <= setteroi{
            pOfNumsAndOpers.append("")
        }
    }
    func addSumOfUnitSizes(){
        if sumOfUnitSizes.count <= setteroi{
            sumOfUnitSizes.append(0)
        }
    }
    func addStrForProcess(){
        if strForProcess.count <= setteroi{
            strForProcess.append("")
        }
    }
    
    
    func printProcess(){
        if tempDigits[pi][ni[pi]] != ""{
            removeNumberInProcess()
            
            let withCommaReturnValue = numStrToNumWithComma(num: tempDigits[pi][ni[pi]])
            process += withCommaReturnValue
            
            
            if withCommaReturnValue != ""{
                addStrForProcess()
                strForProcess[setteroi] = withCommaReturnValue
            }
            
            
            if withCommaReturnValue != ""{
                var sum = 0.0
                for element in withCommaReturnValue{
                    sum += tagToUnitSize[element]!
                }
                addSumOfUnitSizes()
                sumOfUnitSizes[setteroi] = sum
            }
        }
        lineSetter()
        
        progressView.text = process
        
        progressView.scrollRangeToVisible(progressView.selectedRange)
        
    }
    
    func printLineSetterElements( _ toPrint : String){
        print(toPrint)
        print("process : \(process)")
        print("oi : \(setteroi)")
        print("sumOfUnitSizes : \(sumOfUnitSizes)")
        print("pOfNumsAndOpers : \(pOfNumsAndOpers)")
        print("strForProcess : \(strForProcess)")
        //        print("positionOfLastMovePP : \(lastMovePP)")
        print("positionOfLastMoveOP : \(lastMoveOP)")
        
        print("numOfEnter : \(numOfEnter)")
        print("dictionaryForLine : \(dictionaryForLine)")
        
        
    }
    
    
    func lineSetter(){
        var sumForEachProcess = 0.0
        
        let eProcess = 0
        if setteroi >= 0{
            
            if lastMoveOP[eProcess][numOfEnter[eProcess]] < setteroi{
               
                oiLoop : for eODigit in lastMoveOP[eProcess][numOfEnter[eProcess]] ... setteroi{
                    
                    sumForEachProcess += sumOfUnitSizes[eODigit]// oi index
                    
                    if sumForEachProcess > 0.95 - 0.1{
                        if let indexForpOfNumsAndOpers = pOfNumsAndOpers.lastIndex(of: "oper"){ // index of last operator
                            print("indexForpOfNumsAndOpers : \(indexForpOfNumsAndOpers)")
                            let lastOperator = (dictionaryForLine[indexForpOfNumsAndOpers]!) // what is operator ?
                            var lastPositionToSave = process.lastIndexInt(of: Character(lastOperator))! //process의 index of that operator.
                            
                            small2 : for _ in 0 ... 5{
                                if String(process[lastPositionToSave - 1]) == "(" {
                                    lastPositionToSave -= 2
                                    if lastPositionToSave < 2 {break small2}
                                }else{break small2}
                            }
                            
                            
                            numOfEnter[eProcess] += 1
                            
                            if lastMoveOP[eProcess].count <= numOfEnter[eProcess]{
                                lastMoveOP[eProcess].append(0)
                            }
                            
                            if lastMoveOP[eProcess][numOfEnter[eProcess]-1] == indexForpOfNumsAndOpers + 1{
                                lastMoveOP[eProcess].removeLast()
                                numOfEnter[eProcess] -= 1
                                //                                if indexForpOfNumsAndOpers + 2 <
                                
                                break oiLoop
                            }
                            
                            process.insert("\n", at: process.index(process.startIndex, offsetBy: lastPositionToSave, limitedBy: process.endIndex)!) // 그 위치에 \n 삽입.
                            
                            lastMoveOP[eProcess][numOfEnter[eProcess]] = indexForpOfNumsAndOpers + 1
                            
                            sumForEachProcess = 0
                            
                            break oiLoop
                        }else{print("indexForpOfNumsAndOpers : nil")}
                    } // if sumForEachProcess > 0.95 - 0.1{
                } // oiLoop : for eODigit in lastMoveOP[eProcess][numOfEnter[eProcess]] ... setteroi{
            } // if lastMoveOP[eProcess][numOfEnter[eProcess]] <= setteroi{
        } // if setteroi >= 0{
    }
    
    
    //2300
    func lineSettingOtherProcess( _ length : Double) -> String{
        var processToBeReturn = ""
        var sumForEachProcess = 0.0
        
        let eProcess = length < 1.5 ? 1 : 2 // for length of 1, eProcess = 1, and 2 for other cases.
        
        var str = strForProcess
        
        var lastOperatorPosition = 0
        //prevent error when floating points are too long
        startFor : while(lastMoveOP[eProcess][numOfEnter[eProcess]] < setteroi){
            
            sumForEachProcess = 0
            
            for eachOi in lastMoveOP[eProcess][numOfEnter[eProcess]] ... setteroi{
                sumForEachProcess += sumOfUnitSizes[eachOi]
                
                if sumForEachProcess > length - 0.1{
                    
                    small1 : for i in 0 ... eachOi - lastMoveOP[eProcess][numOfEnter[eProcess]]{
                        if pOfNumsAndOpers[eachOi-i] == "oper"{ // : operation, op : open paren
                            lastOperatorPosition = eachOi - i
                            break small1
                        }
                    }
                    
                    
                    
                    numOfEnter[eProcess] += 1
                    if lastMoveOP[eProcess].count <= numOfEnter[eProcess]{
                        lastMoveOP[eProcess].append(0)
                    }
                    
                    if lastMoveOP[eProcess][numOfEnter[eProcess]-1] == lastOperatorPosition + 1{
                        //                        lastMoveOP[eProcess].removeLast()
                        //                        numOfEnter[eProcess] -= 1
                        if lastOperatorPosition + 2 < setteroi{
                            lastMoveOP[eProcess][numOfEnter[eProcess]] = lastOperatorPosition + 2
                        }else{
                            break startFor
                        }
                        //                        break startFor
                        continue startFor
                    }
                    
                    str[lastOperatorPosition] = "\n" + str[lastOperatorPosition]
                    
                    lastMoveOP[eProcess][numOfEnter[eProcess]] = lastOperatorPosition + 1
                    sumForEachProcess = 0
                    
                    //                    if lastMoveOP[eProcess][numOfEnter[eProcess]] == lastMoveOP[eProcess][numOfEnter[eProcess]-1]{
                    //                        break startFor
                    //                    }
                    
                    continue startFor
                }
                
            } // and of for
            break startFor
        }
        
        if str.count > 0{
            for eachOne in 0 ... setteroi{
                processToBeReturn += str[eachOne] // str[setteroi] 까지만 작업함. 고로.. 뒤에껀 ㄱㅊ.
            }
        }
        return processToBeReturn
    }
    
    
    
    // what is this for?
    func removeNumberInProcess(){ // for removing last number(including negative sign)
        end : while(process != ""){
            switch process[process.index(before: process.endIndex)]{
            case "+","-","×","÷","(",")","=" : break
            default :
                process.removeLast()
                continue end
            }
            if tempDigits[pi][ni[pi]].contains("-") && process[process.index(before: process.endIndex)] == "-" {
                process.removeLast()
            }
            break end
        }
    }
    
    
    func numStrToNumWithComma(num : String) -> String{
        var k = 0; var mProcess = ""; var num2 = num; var isdotRemoved = false; var isOutputNegativeSign = false; var isDot0Removed = false
        
        if process.contains("="){
            return ""
        }
        if num2.contains("-paren"){
            return ""
        }
        
        if num2[num2.index(before: num2.endIndex)] == "."{
            num2.removeLast()
            isdotRemoved = true
        } // add dot later.
        
        if num2[num2.startIndex] == "-"{
            isOutputNegativeSign = true
            num2.removeFirst()
        }
        
        // comma 붙이는 과정.
        if var tempNum = Double(num2){
            let dummyStr = String(format : "%.0f", tempNum)
            if num2 == dummyStr + ".0"{ // 여기구나! .0 하면 없어지는 이유..!!
                isDot0Removed = true
                num2.removeLast()
                num2.removeLast()
            }
            
            if (tempNum >= 1000) || (tempNum <= -1000){
                while(tempNum >= 1000) || (tempNum <= -1000){
                    tempNum /= 10
                    k += 1
                }
                
                while k != 0{
                    mProcess.insert(num2[num2.startIndex], at: mProcess.endIndex)
                    num2.removeFirst()
                    k -= 1
                    if k % 3 == 0{
                        mProcess.insert(",", at: mProcess.endIndex)
                    }
                    
                    if k == 0{
                        mProcess.insert(contentsOf: num2, at: mProcess.endIndex)
                    }
                }
            }
            
            else { // -1000 < tempNum < 1000
                mProcess = num2
            }
        }
        
        if isOutputNegativeSign{
            mProcess.insert("-", at: mProcess.startIndex)
        }
        
        if isdotRemoved{
            mProcess.insert(".", at: mProcess.endIndex)
            isdotRemoved = false
        }
        
        if isDot0Removed{
            mProcess += ".0"
        }
        //        print("dicForProcess : \(dicForProcess)")
        return mProcess
    }
    
    
    func copyCurrentStates(){
        print("copyCurrentStates called")
        copyisNegativePossible = negativePossible
        copyisAnsPressed = isAnsPressed
        copypi = pi
        copyni = ni
        copytempDigits = tempDigits
        copyDS = DS
        copyanswer = answer
        copyoperationStorage = operationStorage
        copymuldiOperIndex = muldiOperIndex
        copyfreshDI = freshDI
        copyfreshAI = freshAI
        copyniStart = niStart
        copyniEnd = niEnd
        copypiMax = piMax
        copyindexPivotHelper = indexPivotHelper
        copynumOfPossibleNegative = numOfPossibleNegative
        copypositionOfParen = positionOfParen
        copyisNegativeSign = isNegativeSign
        copyprocess = process
        copyresult = result
        print("copied isAnsPressed : \(isAnsPressed)")
    }
    
    func pasteStates(){
        print("pasteStates baseVC")
        negativePossible = copyisNegativePossible
        isAnsPressed = copyisAnsPressed
        pi = copypi
        ni = copyni
        tempDigits = copytempDigits
        DS = copyDS
        answer = copyanswer
        operationStorage = copyoperationStorage
        muldiOperIndex = copymuldiOperIndex
        freshDI = copyfreshDI
        freshAI = copyfreshAI
        niStart = copyniStart
        niEnd = copyniEnd
        piMax = copypiMax
        indexPivotHelper = copyindexPivotHelper
        numOfPossibleNegative = copynumOfPossibleNegative
        positionOfParen = copypositionOfParen
        isNegativeSign = copyisNegativeSign
        process = copyprocess
        result = copyresult
    }
    
    
    @objc func initialSetup(){
        clear()
        progressView.text = ""
        resultTextView.text = ""
        deleteSpeed = 0.5
        deleteTimer.invalidate()
        deleteTimer2.invalidate()
        deleteTimerInitialSetup.invalidate()
    }
    
    //MARK: - SUB Functions
    
    
    @objc func backToOriginalColor(sender : UIButton){
        if isLightModeOn{
            switch sender.tag {
            case -2 ... 9:
                sender.backgroundColor = colorList.bgColorForEmptyAndNumbersBM
            case 10 ... 20 :
                sender.backgroundColor =  colorList.bgColorForOperatorsBM
            case 31 ... 40:
                sender.backgroundColor =  colorList.bgColorForExtrasBM
            case 21 ... 30 :
                sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersBM
                deleteTimer.invalidate()
                deleteTimer2.invalidate()
                deleteTimerPause.invalidate()
                deleteTimerInitialSetup.invalidate()
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
                deleteTimer.invalidate()
                deleteTimer2.invalidate()
                deleteTimerPause.invalidate()
                deleteTimerInitialSetup.invalidate()
            default :
                sender.backgroundColor = .magenta
            }
        }
    }
    
    
    @objc func deleteDragOut(sender : UIButton){
        deleteTimer.invalidate()
        deleteTimer2.invalidate()
        deleteTimerPause.invalidate()
        deleteTimerInitialSetup.invalidate()
    }
    
    
    @objc func soundOnOff1(sender : UIButton){
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        
        isSoundOn = userDefaultSetup.getIsSoundOn()
        
        
        isSoundOn ? self.showToast(message: self.localizedStrings.soundOff, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13) : self.showToast(message: self.localizedStrings.soundOn, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
        
        
        isSoundOn.toggle()
        userDefaultSetup.setIsSoundOn(isSoundOn: isSoundOn)
        colorAndImageSetup()
    }
    
    @objc func backgroundColorChanger2(sender : UIButton){
        print("tempDigits : \(tempDigits)")
        printLineSetterElements("changer")
        print("iPressed : \(iPressed)")
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        checkIndexes(saySomething: "fdsa")
        
        isLightModeOn = userDefaultSetup.getIsLightModeOn()
        
        isLightModeOn ? self.showToast(message: self.localizedStrings.darkMode, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13) : self.showToast(message: self.localizedStrings.lightMode, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.5, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
        
        isLightModeOn.toggle()
        
        userDefaultSetup.setIsLightModeOn(isLightModeOn: isLightModeOn)
        colorAndImageSetup()
        
    }
    
    @objc func notificationOnOff3(sender : UIButton){
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        
        isNotificationOn = userDefaultSetup.getIsNotificationOn()
        
        isNotificationOn ? self.showToast(message: self.localizedStrings.notificationOff, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.65, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13) : self.showToast(message: self.localizedStrings.notificationOn, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.65, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
        
        isNotificationOn.toggle()
        
        userDefaultSetup.setIsNotificationOn(isNotificationOn: isNotificationOn)
        colorAndImageSetup()
        
    }
    
    
    @objc func gotoFeedbackPage4(sender : UIButton){
        userDefaultSetup.setIsUserEverChanged(isUserEverChanged: true)
        numberReviewClicked = userDefaultSetup.getNumberReviewClicked()
        userDefaultSetup.setNumberReviewClicked(numberReviewClicked: numberReviewClicked+1)
        
        if (numberReviewClicked < 3){
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
    
    
    func sendNotification(){
        if isNotificationOn{
            
            self.showToast(message: self.localizedStrings.modified, with: 1, for: 1, defaultWidthSize: self.frameSize.showToastWidthSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 375, defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 667, widthRatio: 0.4, heightRatio: 0.04, fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.getUserDeviceSizeInfo()] ?? 13)
            
        }
    }
    
    
    func defaultSetup(){
        if userDefaultSetup.getIsUserEverChanged(){
            isLightModeOn = userDefaultSetup.getIsLightModeOn()
            isSoundOn = userDefaultSetup.getIsSoundOn()
            isNotificationOn = userDefaultSetup.getIsNotificationOn()
            numberReviewClicked = userDefaultSetup.getNumberReviewClicked()
        }
        else{ // initial value . when a user first downloaded.
            userDefaultSetup.setIsLightModeOn(isLightModeOn: false)
            userDefaultSetup.setIsNotificationOn(isNotificationOn: false)
            userDefaultSetup.setIsSoundOn(isSoundOn: true)
            userDefaultSetup.setNumberReviewClicked(numberReviewClicked: 0)
            
            isLightModeOn = false
            isNotificationOn = false
            isSoundOn = true
            numberReviewClicked = 0
            //            numberReview
            
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
        if isSoundOn{
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    
    @objc func deletePressedDown(sender : UIButton){
        if isLightModeOn{
            sender.backgroundColor =  colorList.bgColorForExtrasBM
        }else{
            sender.backgroundColor =  colorList.bgColorForExtrasDM
        }
        
        if deleteSpeed == 0.5{
            deleteExecute()
        }
        
        deleteTimer = Timer.scheduledTimer(timeInterval: deleteSpeed, target: self, selector: #selector(deleteFaster), userInfo: nil, repeats: false)
        deleteTimerPause = Timer.scheduledTimer(timeInterval: deletePause, target: self, selector: #selector(pauseDelete), userInfo: nil, repeats: false)
        deleteTimerInitialSetup = Timer.scheduledTimer(timeInterval: deleteInitialSetup, target: self, selector: #selector(initialSetup), userInfo: nil, repeats: false)
    }
    
    @objc func deleteFaster(){
        deleteSpeed = 0.1
        deleteTimer2 = Timer.scheduledTimer(timeInterval: deleteSpeed, target: self, selector: #selector(deleteExecute), userInfo: nil, repeats: true)
    }
    
    @objc func pauseDelete(){
        deleteTimer.invalidate()
        deleteTimer2.invalidate()
    }
    
    @objc func deletePressedUp(sender : UIButton){
        sender.backgroundColor =  colorList.bgColorForEmptyAndNumbersBM
        deleteTimer.invalidate()
        deleteTimer2.invalidate()
        deleteTimerPause.invalidate()
        deleteTimerInitialSetup.invalidate()
        deleteSpeed = 0.5
    }
    
    // color change and sound play when touched
    @objc func numberPressedDown(sender : UIButton){
        if isLightModeOn{
            sender.backgroundColor =  colorList.bgColorForExtrasBM
        }else{
            sender.backgroundColor =  colorList.bgColorForExtrasDM
        }
        playSound()
    }
    
    //delete not included
    @objc func otherPressedDown(sender : UIButton){
        playSound()
        if isLightModeOn{
            sender.backgroundColor =  colorList.bgColorForExtrasBM
        }else{
            sender.backgroundColor =  colorList.bgColorForExtrasDM
        }
    }
    
    
    func checkIndexes(saySomething : String){
        print("func checkIndexes(saySomething : \(saySomething){")
        print(" \(saySomething)")
        print("process : \(process)")
        print("1.")
        print("ni : \(ni)")
        print("pi : \(pi)")
        print("piMax : \(piMax)")
        print("2.")
        print("tempDigits : \(tempDigits)")
        print("DS : \(DS)")
        print("freshDI : \(freshDI)")
        print("3.")
        print("operationStorage : \(operationStorage)")
        print("muldiOperIndex : \(muldiOperIndex)")
        print("4.")
        print("niStart : \(niStart)")
        print("niEnd : \(niEnd)")
        print("indexPivotHelper : \(indexPivotHelper)")
        print(" positionOfParen : \( positionOfParen)")
        print("5.")
        print("numOfPossibleNegative : \(numOfPossibleNegative)")
        print("isNegativeSign : \(isNegativeSign)")
        print("isNegativePossible : \(negativePossible)")
        print("6.")
        print("answer : \(answer)")
        print("freshAI : \(freshAI)")
        print("result : \(String(describing: result))")
        if saveResult != nil{
            print("saveResult : \(saveResult!)")
        }else{
            print("saveResult is nil.")
        }
        print("isAnsPressed : \(isAnsPressed)\n\n")
        
        print("process : \(process)")
        print("oi : \(setteroi)")
        print("sumOfUnitSizes : \(sumOfUnitSizes)")
        print("pOfNumsAndOpers : \(pOfNumsAndOpers)")
        print("strForProcess : \(strForProcess)")
        print("lastMoveOP : \(lastMoveOP)")
        print("numOfEnter : \(numOfEnter)")
        print("dictionaryForLine : \(dictionaryForLine)")
        
        
        
    }
    
    func returnLightModeSetup() -> Bool{
        return isLightModeOn
    }
    
    @objc func toHistory(sender : UIButton){
        let transition = CATransition()
        transition.duration = 0.3 // don't adjust it shorter. looks very weird!
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        newTableVC.modalPresentationStyle = .fullScreen
        self.present(newTableVC, animated: true, completion: nil)
    }
    
    
    
    //MARK: - <# Main Functional Section Ends
    
    
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

    var subEx1Sound = transparentImage
    var subEx2Color = transparentImage
    var subEx3Notification = transparentImage
    var subEx4Feedback = transparentImage
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
    let extra1 = ButtonTag(withTag: 31)
    let extra2 = ButtonTag(withTag: 32)
    let extra3 = ButtonTag(withTag: 33)
    let extra4 = ButtonTag(withTag: 34)
    
    let deleteButton : UIButton = {
        let del = UIButton(type: .custom)
        del.translatesAutoresizingMaskIntoConstraints = false
        del.tag = 21
        
        let sub = UIImageView(image: #imageLiteral(resourceName: "delD")) // delete Image.
        del.addSubview(sub)
        
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
        
        // frameView = UIView()
        for subview in frameView.subviews{
            subview.removeFromSuperview()
        }
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
        let horStackView0 : [UIButton] = [extra1, extra2, extra3, extra4]
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
        
        
        if isOrientationPortrait{ // Portrait Mode
            frameView = view
            
            for button in horStackView0{ //extras 1,2,3,4
                frameView.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.108).isActive = true
            }
        }else if !isOrientationPortrait{ // LandScape Mode
            
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
            if isOrientationPortrait{
                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.108).isActive = true
            }else{
                button.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: CGFloat(0.108*1.2)).isActive = true
            }
            
            button.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.25).isActive = true
            //            button.layer.borderWidth = 0.23
            button.layer.borderWidth = 0.23
            button.layer.borderColor = CGColor(genericGrayGamma2_2Gray: 0, alpha: 0.15)
            //frameView : view or rightSideForLandscapeMode view (UIView)
        }
        
        //again? yeap. don't touch it . (already tried ..)
        if isOrientationPortrait{
            for button in horStackView0{
                button.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.25).isActive = true
                button.anchor(bottom: frameView.bottomAnchor)
                button.layer.borderWidth = 0.23
                button.layer.borderColor = CGColor(genericGrayGamma2_2Gray: 0, alpha: 0.15)
            }
            
            for button in horStackView1{
                button.anchor(bottom: extra1.topAnchor)
            }
            
            extra1.anchor(left: frameView.leftAnchor)
            extra2.anchor(left: extra1.rightAnchor)
            extra3.anchor(left: extra2.rightAnchor)
            extra4.anchor(left: extra3.rightAnchor, right: frameView.rightAnchor)
            
          
            
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
        
        if isOrientationPortrait{
            emptySpace.anchor(top: frameView.topAnchor, left: frameView.leftAnchor, right: frameView.rightAnchor)
            emptySpace.heightAnchor.constraint(equalTo: frameView.heightAnchor, multiplier: 0.352).isActive = true
            
            // only applied to portrait Mode
            
            deleteWidthReference.anchor(right: frameView.rightAnchor)
            deleteWidthReference.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.122).isActive = true
            
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
        
        if isOrientationPortrait{
            frameView.addSubview(historyDragButton)
            frameView.addSubview(historyClickButton)
            
            
            historyClickButton.anchor(top: frameView.safeTopAnchor,left: view.leftAnchor, paddingTop: 5, paddingLeft: 30 )
            historyClickButton.setDimensions(width: 40, height: 40)

            historyDragButton.anchor(top: frameView.safeTopAnchor, left: view.leftAnchor, paddingLeft: 30)
            historyDragButton.setDimensions(width: 40, height: 40)
        }
        
        resultTextView.font = UIFont.systemFont(ofSize: fontSize.resultBasicPortrait[userDefaultSetup.getUserDeviceSizeInfo()]!)
        progressView.font = UIFont.systemFont(ofSize: fontSize.processBasicPortrait[userDefaultSetup.getUserDeviceSizeInfo()]!)
    }
    
    func addTargetSetup(){
        
        let numButtons = [num0,num1,num2,num3,num4,num5,num6,num7,num8,num9,num0,num00,numberDot]
        let operButtons = [operationButtonDivide,operationButtonMultiply,operationButtonPlus,operationButtonMinus]
        let otherButtons = [clearButton,openParenthesis,closeParenthesis,operationButtonDivide,operationButtonMultiply,operationButtonPlus,operationButtonMinus,equalButton]
        
        for aButton in numButtons {
            aButton.addTarget(self, action: #selector( handleNumberTapped), for: .touchUpInside)
            aButton.addTarget(self, action: #selector(numberPressedDown), for: .touchDown)
            aButton.addTarget(self, action: #selector(backToOriginalColor), for: .touchUpInside) // does nothing.
            aButton.addTarget(self, action: #selector(backToOriginalColor), for: .touchDragExit)
        }
        for aButton in operButtons{
            aButton.addTarget(self, action: #selector( operationPressed), for: .touchUpInside)
            aButton.addTarget(self, action: #selector(backToOriginalColor), for: .touchDragExit)
        }
        for aButton in otherButtons{
            aButton.addTarget(self, action: #selector( otherPressedDown), for: .touchDown)
            aButton.addTarget(self, action: #selector( backToOriginalColor(sender:)), for: .touchUpInside)//does nothing
            aButton.addTarget(self, action: #selector(backToOriginalColor), for: .touchDragExit)
        }
        
        equalButton.addTarget(self, action: #selector( ansPressed), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector( clearPressed), for: .touchUpInside)
        
        openParenthesis.addTarget(self, action: #selector( parenthesisPressed), for: .touchUpInside)
        closeParenthesis.addTarget(self, action: #selector( parenthesisPressed), for: .touchUpInside)
        
        deleteButton.addTarget(self, action: #selector( deletePressedDown), for: .touchDown)
        deleteButton.addTarget(self, action: #selector(deletePressedUp), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteDragOut), for: .touchDragExit)
        
        deleteButton.addTarget(self, action: #selector( backToOriginalColor), for: .touchUpInside)
        //sound, backgroundColor, notification, feedback
        extra1.addTarget(self, action: #selector(soundOnOff1), for: .touchUpInside)
        extra2.addTarget(self, action: #selector(backgroundColorChanger2(sender:)), for: .touchUpInside)
        extra3.addTarget(self, action: #selector(notificationOnOff3), for: .touchUpInside)
        extra4.addTarget(self, action: #selector(gotoFeedbackPage4), for: .touchUpInside)
        
        historyClickButton.addTarget(self, action: #selector(toHistory), for: .touchUpInside)
        historyClickButton.addTarget(self, action: #selector(toHistory), for: .touchDragExit)
        historyDragButton.addTarget(self, action: #selector(toHistory), for: .touchDragExit)
    }
    
    
    fileprivate func setButtonImageInLightMode() {
        
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
        subEx2Color = UIImageView(image: #imageLiteral(resourceName: "white_to_dark"))
        subEx4Feedback = UIImageView(image: #imageLiteral(resourceName: "whitemode_review"))
    }
    
    fileprivate func setButtonImageInDarkMode() {
        
        
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
        subEx2Color = UIImageView(image: #imageLiteral(resourceName: "dark_to_white"))
        subEx4Feedback = UIImageView(image: #imageLiteral(resourceName: "darkmode_review"))
    }
    
    fileprivate func setButtonPositionAndSize(_ modifiedWidth: inout [Double]) {
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
        
        extra2.addSubview(subEx2Color)
        subEx2Color.center(inView: extra2)
        subEx2Color.widthAnchor.constraint(equalTo: extra2.heightAnchor, multiplier: CGFloat(0.288) * CGFloat(ratio)).isActive = true
        subEx2Color.heightAnchor.constraint(equalTo: extra2.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
        
        extra4.addSubview(subEx4Feedback)
        subEx4Feedback.center(inView: extra4)
        subEx4Feedback.widthAnchor.constraint(equalTo: extra4.heightAnchor, multiplier: CGFloat(0.288 * ratio) ).isActive = true
        subEx4Feedback.heightAnchor.constraint(equalTo: extra4.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
        
    }
    
    func colorAndImageSetup(){
        
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
        
        let extras = [extra1, extra2, extra3, extra4]
        
        if isLightModeOn{
            for num in numButtons{
                num.backgroundColor =  colorList.bgColorForEmptyAndNumbersBM
            }
            for other in otherButtons{
                other.backgroundColor =  colorList.bgColorForOperatorsBM
            }
            for extra in extras{
                extra.backgroundColor =  colorList.bgColorForExtrasBM
            }
            deleteButton.backgroundColor =  colorList.bgColorForEmptyAndNumbersBM
            
            setButtonImageInLightMode()
            
            
            for view in subHistory.subviews{
                view.removeFromSuperview()
            }
            
            for i in 0 ..< numsAndOpers.count{
                for view in numsAndOpers[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
            for i in 0 ..< extras.count{
                for view in extras[i].subviews{
                    view.removeFromSuperview()
                }
            }
            historyClickButton.addSubview(subHistory)
    
            subHistory.fillSuperview()
            
            setButtonPositionAndSize(&modifiedWidth)
            
            subEx1Sound = isSoundOn ? ex1OnLight : ex1OffLight
            subEx3Notification = isNotificationOn ? ex3OnLight : ex3OffLight
            
            
            progressView.textColor = colorList.textColorForProcessBM
            if isAnsPressed{
                resultTextView.textColor = colorList.textColorForResultBM
            }
            
            resultTextView.textColor = isAnsPressed ? colorList.textColorForResultBM : colorList.textColorForSemiResultBM
            
        }else{ // darkMode
            for num in numButtons{
                num.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
            }
            for other in otherButtons{
                other.backgroundColor =  colorList.bgColorForOperatorsDM
            }
            for extra in extras{
                extra.backgroundColor =  colorList.bgColorForExtrasDM
            }
            deleteButton.backgroundColor =  colorList.bgColorForEmptyAndNumbersDM
            
            setButtonImageInDarkMode()
            
            for view in historyClickButton.subviews{
                view.removeFromSuperview()
            }
            
            for i in 0 ..< numsAndOpers.count{
                for view in numsAndOpers[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
            for i in 0 ..< extras.count{
                for view in extras[i].subviews { // It works !!! whow!!
                    view.removeFromSuperview()
                }
            }
            
            historyClickButton.addSubview(subHistory)
            
            subHistory.fillSuperview()
            
            setButtonPositionAndSize(&modifiedWidth)

            subEx1Sound = isSoundOn ? ex1OnDark : ex1OffDark
            subEx3Notification = isNotificationOn ? ex3OnDark : ex3OffDark
            
            progressView.textColor = colorList.textColorForProcessDM
            resultTextView.textColor = isAnsPressed ? colorList.textColorForResultDM : colorList.textColorForSemiResultDM
        }
        
        extra1.addSubview(subEx1Sound)
        subEx1Sound.center(inView: extra1)
    
        subEx1Sound.widthAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
        subEx1Sound.heightAnchor.constraint(equalTo: extra1.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
        
        extra3.addSubview(subEx3Notification)
        subEx3Notification.center(inView: extra3)
        subEx3Notification.widthAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288 * ratio)).isActive = true
        subEx3Notification.heightAnchor.constraint(equalTo: extra3.heightAnchor, multiplier: CGFloat(0.288*1.3)).isActive = true
    }
}
