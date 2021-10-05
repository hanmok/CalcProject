//
//  BasicCalculator.swift
//  Caliy
//
//  Created by Mac mini on 2021/09/27.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit
import RealmSwift
import AudioToolbox

enum ToastEnum {
    case numberLimit
    case answerLimit
    case floatingLimit
    case modified
    case saved
}


class BasicCalculator {
    
    init() {
        // setupNumberFormatter
        nf6.roundingMode = .down
        nf6.maximumFractionDigits = 6
        
        let realm = RealmService.shared.realm
        historyRecords = realm.objects(HistoryRecord.self)
        
    }
    let localizedStrings = LocalizedStringStorage()
    
    var historyRecords : Results<HistoryRecord>!
    var userDefaultSetup = UserDefaultSetup()
    let nf6 = NumberFormatter()
    var setteroi : Int = 0
    
    var sumOfUnitSizes : [Double] = [0.0]
    
    var pOfNumsAndOpers = [""]
    var pOfNumsAndOpersCount = 1
    var strForProcess = [""]
    
    var lastMoveOP : [[Int]] = [[0],[0],[0]]
        
    var numOfEnter = [0,0,0]
    var dictionaryForLine = [Int : String]()
    
    var numParenCount = 0
    
    var process = ""
//    var result = ""
    
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
    
//    var process = ""
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
    
    /// make deleteFaster function called after 0.5 s (deafult deletionTerm)
    var deletionForFasterTrigger = Timer()
    /// perform delete every 0.1s (chagned deletionTerm)
    var deletionTimerForFaster = Timer()
    /// call pauseDelete (invalidate deletion timers) after 2.35 s (deletionPausedAt)
    var deletionTimerForPause = Timer()
    /// call didPressedDeleteLong, which calls clear()  and invalidate all timers  after 2.5 s (deletionTimeForInitialState)
    var deletionTimerForInitialSetup = Timer()
    
    /// little term before deletion getting faster ( 5 times ), default = 0.5 s
    var deletionTerm = 0.5
    /// pause delete after button has been being pressed for 2.35s
    let deletionPausedAt = 2.35
    /// delete all digits after button has been being pressed for 2.5s
    let deletionTimeForInitialState = 2.5
    
    var showingAnsAdvance = false
    
    
    // MARK: - NUMBER INPUT
    public func didReceiveNumber(_ senderTag: Int) {
        if let input = tagToString[senderTag]{
                if ansPressed
                {
                    clear()
                    process = ""
                    ansPressed = false
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
                            if input == "00"{sendToastCaseNotification(toastCase: .modified)}
                        case "-":
                            tempDigits[pi][ni[pi]] += "0"
                            process += "0"
                            if input == "00"{sendToastCaseNotification(toastCase: .modified)}
                        case "0" : sendToastCaseNotification(toastCase: .modified);break
                        case "-0": sendToastCaseNotification(toastCase: .modified);break
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
                        sendToastCaseNotification(toastCase: .modified)
                    }// 기존 입력 : 0 or -0 , 새 입력 : 0, 00, . 이 아닌경우!
                    else if (input != "0" && input != "00" && input != ".") && (tempDigits[pi][ni[pi]] == "0" || tempDigits[pi][ni[pi]] == "-0"){ // 0 , -0 >> 숫자 입력 : 모든 경우 수정됨.
                        tempDigits[pi][ni[pi]].removeLast()
                        tempDigits[pi][ni[pi]] += input
                        
                        process.removeLast()
                        process += input
                        sendToastCaseNotification(toastCase: .modified)
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
                        
                        setupOperVariables("×", ni[pi])
                        process += operationStorage[pi][ni[pi]]
                        updateIndexes()
                        tempDigits[pi][ni[pi]] = input
                        
                        if input == "."{
                            tempDigits[pi][ni[pi]] = "0."
                            process += "0"
                        }
                        
                        process += String(input)
                        sendToastCaseNotification(toastCase: .modified)
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
                    sendToastCaseNotification(toastCase: .modified)
                    
                    if let safeDigits = Double(tempDigits[pi][ni[pi]]){
                        DS[pi][ni[pi]] = safeDigits
                        freshDI[pi][ni[pi]] = 1
                        negativePossible = false
                    }
                    
                }// 15자리에서 .이 이미 있는 경우
                else if ((DS[pi][ni[pi]] >= 1e14 || DS[pi][ni[pi]] <= -1e14) && tempDigits[pi][ni[pi]].contains(".")){
                    
                    if input == "."{
                        sendToastCaseNotification(toastCase: .modified)
                        
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
                        sendToastCaseNotification(toastCase: .numberLimit)
                    }
                }
                addPOfNumsAndOpers()
                
                pOfNumsAndOpers[setteroi] = "n"
                
                addStrForProcess()
                showAnsAdvance()
                
                printProcess()
            }
    }
    
    // MARK: - OPERATOR INPUT
    public func didReceiveOper( senderTag: Int) {
        
            if let operInput = tagToString[senderTag]{ // : String
   
                if ansPressed{    // ans + - x /
                    
                    clear()
                    process = ""
                    ansPressed = false
                    DS[0][0] = savedResult!
                    
                    tempDigits[0][0] = nf6.string(for: savedResult!)!
                    
                    
                    if DS[0][0] < 0{
                        negativeSign = [[false,true]]
                    }
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "n"
                    
                    addStrForProcess()
                    
                    negativePossible = false
                    
                    printProcess()
                    savedResult = nil
                    freshDI[0][0] = 1
                    setteroi += 1
                    
                    setupOperVariables(operInput, ni[0])
                    
                    addSumOfUnitSizes()
                    sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
                    
                    addPOfNumsAndOpers()
                    pOfNumsAndOpers[setteroi] = "oper"
                    dictionaryForLine[setteroi] = operInput
                    
                    addStrForProcess()
                    strForProcess[setteroi] = operInput
                    // ["+","-","×","÷","(",")"]
                    process += operationStorage[0][0]
                    updateIndexes()
                    setteroi += 1
                    addPOfNumsAndOpers()
                    addSumOfUnitSizes()
                    addStrForProcess()
                }
                
                else if negativePossible{ // true until number input.
                    if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == ""{// input negative Sign
                        
                        if operInput == "-"{
                            process += "-"
                            negativeSign[pi][numOfPossibleNegative[pi]] = true
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
                            sendToastCaseNotification(toastCase: .modified)
                        }
                    }
                    
                    else if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == "-"{ // for negative sign
                        if operInput == "-"{}// - >> - : ignore input.
                        else if operInput != "-"{ // - >> + * /
                            //                        printLineSetterElements("operation modified3")
                            process.removeLast()
                            negativeSign[pi][numOfPossibleNegative[pi]] = false
                            tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = ""
                            sumOfUnitSizes[setteroi] -= tagToUnitSize["-"]!
                            setteroi -= 1
                            if setteroi < 0{
                                setteroi = 0
                            }
                            pOfNumsAndOpers.removeLast()
                            strForProcess.removeLast()
                            
                        }
                        
                        sendToastCaseNotification(toastCase: .modified)// both cases are abnormal.
                    }
                }
                
                else if !negativePossible{ // modify Operation Input for duplicate case.
                    if tempDigits[pi][ni[pi]] == ""{
                      
                        setupOperVariables(operInput, ni[pi]-1)
                        process.removeLast()
                        process += operationStorage[pi][ni[pi]-1]
                        sendToastCaseNotification(toastCase: .modified)
                        
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
                                sendToastCaseNotification(toastCase: .modified)
                                
                                strForProcess[setteroi].removeLast()
                            }
                        }
                        setteroi += 1
                        
                        
                        setupOperVariables(operInput, ni[pi])
                        process += operationStorage[pi][ni[pi]]
                        updateIndexes()
                        
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
    // MARK: - PARENTHESES INPUT
    public func didReceiveParen(_ senderTag: Int) {

            if let input = tagToString[senderTag]{
                if input == "("{
                    
                    if ansPressed{
                        clear()
                        process = ""
                        ansPressed = false
                        
                        DS[0][0] = savedResult!
                        
                        freshDI[0][0] = 1
                        tempDigits[0][0] = nf6.string(for: savedResult!)!
                        
                        freshDI[0][0] = 1
                        if DS[0][0] < 0{
                            negativeSign = [[false,true]]
                        }
                        negativePossible = false
                        
                        printProcess() // duplicate printProcess ??
                        addPOfNumsAndOpers()
                        pOfNumsAndOpers[setteroi] = "n"
                        
                        addStrForProcess()
                        
                        setteroi += 1
                        
                        
                        savedResult = nil
                        setupOperVariables("×", ni[0])
                        
                        addSumOfUnitSizes()
                        sumOfUnitSizes[setteroi] = tagToUnitSize["×"]!
                        
                        addPOfNumsAndOpers()
                        pOfNumsAndOpers[setteroi] = "oper"
                        
                        addStrForProcess()
                        strForProcess[setteroi] = "×"
                        
                        dictionaryForLine[setteroi] = "×"
                        
                        process += "×"
                        updateIndexes()
                        
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
                            sendToastCaseNotification(toastCase: .modified)
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
                            updateIndexes()
                            sendToastCaseNotification(toastCase: .modified)
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
                        negativeSign.append([false, false])
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
                        
                        negativeSign[pi].append(false)
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
                                sendToastCaseNotification(toastCase: .modified)
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
                    else{sendToastCaseNotification(toastCase: .modified) } // input is ) and end of process is ( + - × ÷ >> ignore !
                }
                else{sendToastCaseNotification(toastCase: .modified)} // pi == 0 , close paren before open it.
                printProcess()
            }
    }
    // MARK: -  ANS INPUT
    public func didReceiveAns() {
        calculateAns()
        
    }
    
    @objc public func calculateAns() {
        
        if process == ""{
            clear()
        }
        
        if !ansPressed {
            copyCurrentStates()
            
            filterProcess()
            numParenCount = pi
            while pi > 0{
                niEnd[pi].append(ni[pi])
                pi -= 1
                process += ")"
                //                numParenCount += 1
                if !showingAnsAdvance{
//                    pressedButtons += "="
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
                    sendToastCaseNotification(toastCase: .modified)
                }
            }
            
            if !showingAnsAdvance{
                copyCurrentStates()
                printProcess()
                if process != ""{
                    ansPressed = true // 이거 원래 한 5줄 아래에 있었음.
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
                                if negativeSign[pi-1][b]{
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

                    sendToastCaseNotification(toastCase: .answerLimit)
                    ansPressed = false // 이게 왜 여기있어 ? 여기 있어 ㅇㅇ .
                    break piLoop
                }
                if result != nil{
                    if process != ""{
                        floatingNumberDecider(ans : result!)
                    }else{
                        niEnd = [[0]]
                        result = nil
                        

                        sendResultNotification(receivedResult: "")
                    }
                    //                            historyIndex += 1
                }
                
                // what is this notification mean..??
                // update History(table) in landscape Mode
                let name = Notification.Name(rawValue: NotificationKey.answerToTableNotification.rawValue)
                NotificationCenter.default.post(name: name, object: nil)
                break piLoop
            } // piLoop : while pi >= 0 {
        }
        print("flag process: \(process), result: \(String(describing: result))")
//        sendResultNotification(receivedResult: result)
    }
    
    func showAnsAdvance() {
        showingAnsAdvance = true
        calculateAns()
        
        ansPressed = false
        sendUpdateResultColorNotification(receivedAnsPressed: ansPressed)
        pasteStates()
        showingAnsAdvance = false
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
                        sendToastCaseNotification(toastCase: .modified)
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
                        negativeSign.removeLast()
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
                        negativeSign[pi].removeLast()
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
                    sendToastCaseNotification(toastCase: .modified)
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
                        negativeSign[pi][numOfPossibleNegative[pi]] = false
                        if !showingAnsAdvance{
                            sumOfUnitSizes[setteroi] = 0
                            setteroi -= 1
                            pOfNumsAndOpers.removeLast()
                            sumOfUnitSizes.removeLast()
                            strForProcess.removeLast()
                        }
                    }
                    sendToastCaseNotification(toastCase: .modified)
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
            
            dummyStrWithComma = addCommasToString(num: dummyAnsString!)
            
            // view area
            print("flag2, sendingResult: \(dummyStrWithComma)")
            sendResultNotification(receivedResult: dummyStrWithComma)
            sendUpdateResultColorNotification(receivedAnsPressed: true)
            
            if !showingAnsAdvance{
                sendToastCaseNotification(toastCase: .saved)
                
                let newHistoryRecord = HistoryRecord(processOrigin : process, processStringHis : alignForHistory(1.4),processStringHisLong: alignForHistory(1.8), processStringCalc: process, resultString: dummyStrWithComma, resultValue : realAns, dateString: dateString)
                lastMoveOP[1] = [0]
                lastMoveOP[2] = [0]
                numOfEnter[1] = 0
                numOfEnter[2] = 0
                
                
                RealmService.shared.create(newHistoryRecord)
//                RealmService.shared.update(newHistoryRecord, with: dict)
                
                savedResult = realAns // what is the difference?
                
            }
        }else{
            sendToastCaseNotification(toastCase: .answerLimit)
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
                copiedprocess = process
                printProcess()
            }
        }
    }
    
    // initialSetup
    // MARK: - CLEAR ANS
    public func didReceiveClear() { // clearPressed
        
        clear()
    
        sendResultNotification(receivedResult: "")
        
        sendProcessNotification(receivedProcess: "")
        
        savedResult = nil

        process = ""
    }
    
    func clear(){ // clear()
       negativePossible = true
       ansPressed = false
       
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
       negativeSign = [[false, false]]
       
       process = ""
       result = nil
       
       copiedfreshDI = [[0]]
       copiedfreshAI = [[0]]
       copiedpi = 0
       copiedDS = [[0.0]]
       copiedanswer = [[100]]
       copiedni = [0]
       copiedniStart = [[0,0]]
       copiedniEnd = [[0]]
       
       copiedtempDigits = [[""]]
       copiedoperationStorage = [[""]]
       copiedmuldiOperIndex = [[false]]
       
       copiedpiMax = 0
       copiedindexPivotHelper = [false]
       copiednumOfPossibleNegative = [1]
       copiedpositionOfParen = [[0]]
       copiedNegativeSign = [[false, false]]
       copiedNegativePossible = true
       copiedAnsPressed = false
       copiedprocess = ""
       
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
    
    // MARK: - DELETE
    
    @objc public func didReceiveDelete() { // deleteExecute(), deleteFaster 에 사용
        print(#file, #function)
        playSound()
        
        caseframe : if process != ""{ // caseframe is not appropriate name..
            
            if process[process.index(before: process.endIndex)] == "\n"{
                process.removeLast()
            }
            
            
            if ansPressed
            {
                pasteStates()
            }
            ansPressed = false
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
                        negativeSign[pi][numOfPossibleNegative[pi]] = false
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
                    negativeSign.removeLast()
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
                    negativeSign[pi].removeLast()
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

            sendToastCaseNotification(toastCase: .modified)
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
    
    @objc public func didPressedDeleteLong() { // initialSetup
        clear()
        sendProcessNotification(receivedProcess: "")
        sendResultNotification(receivedResult: "")
        
        deletionTerm = 0.5
        
        deletionForFasterTrigger.invalidate()
        deletionTimerForFaster.invalidate()
        deletionTimerForInitialSetup.invalidate()
    }
    
    public func didDragOutDelete() {
//        deletionForFasterTrigger.invalidate()
//        deletionTimerForFaster.invalidate()
//        deletionTimerForPause.invalidate()
//        deletionTimerForInitialSetup.invalidate()
        invalidateAllTimers()
    }
    
    public func didPressedDownDelete() {
        if deletionTerm == 0.5 {
            didReceiveDelete()
        }
        // after 0.5s, make deleteSpeed 0.1 (5times faster)
        deletionForFasterTrigger = Timer.scheduledTimer(timeInterval: deletionTerm, target: self, selector: #selector(deleteFaster), userInfo: nil, repeats: false)
        // pauseDelete
        deletionTimerForPause = Timer.scheduledTimer(timeInterval: deletionPausedAt, target: self, selector: #selector(pauseDelete), userInfo: nil, repeats: false)
        //initialSetup
        deletionTimerForInitialSetup = Timer.scheduledTimer(timeInterval: deletionTimeForInitialState, target: self, selector: #selector(didPressedDeleteLong), userInfo: nil, repeats: false)
        
    }
    /// change delete delay to 0.1s, and delete each digit every 0.1s
    @objc func deleteFaster() {
        deletionTerm = 0.1
        deletionTimerForFaster = Timer.scheduledTimer(timeInterval: deletionTerm, target: self, selector: #selector(didReceiveDelete), userInfo: nil, repeats: true)
    }
    /// pause delete for a while, if pressed down longer, set all variables to initial state
    @objc func pauseDelete(){
        deletionForFasterTrigger.invalidate()
        deletionTimerForFaster.invalidate()
    }
    
    @objc public func handleDeleteTapped() {
//        deletionFasterTriggerTimer.invalidate()
//        deletionFasterTimer.invalidate()
//        deletionTimerPause.invalidate()
//        deletionTimerInitialSetup.invalidate()
        
        //for testing
        print(#file, #function)
        invalidateAllTimers()
        deletionTerm = 0.5
    }
    
    public func invalidateAllTimers() {
        deletionForFasterTrigger.invalidate()
        deletionTimerForFaster.invalidate()
        deletionTimerForPause.invalidate()
        deletionTimerForInitialSetup.invalidate()
    }
    
    // MARK: - PROCESS
    public func printProcess(){
        if tempDigits[pi][ni[pi]] != ""{
            removeLastNumber()
            
            let withCommaReturnValue = addCommasToString(num: tempDigits[pi][ni[pi]])
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
        align()
        
        sendProcessNotification(receivedProcess: process)

        sendScrollNotification()
    }
    
    /// - delete digits until it  come across any operator except for negative sign
    func removeLastNumber(){
        end : while(process != ""){
            switch process[process.index(before: process.endIndex)]{
            case "+","-","×","÷","(",")","=" : break
            default :
                process.removeLast()
                continue end
            }
            // when the last digit of process met any operator
            if tempDigits[pi][ni[pi]].contains("-") && process[process.index(before: process.endIndex)] == "-" {
                process.removeLast()
            }
            break end
        }
    }
    
    func addCommasToString(num : String) -> String{
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
    
   
    // MARK: - NOTIFICATIONS
    // newNotification, sender
    func sendProcessNotification(receivedProcess: String) {
        let sendingProcess = ["process": receivedProcess]
        
        let name = Notification.Name(rawValue: NotificationKey.processToBaseVCNotification.rawValue)
        NotificationCenter.default.post(name: name, object: nil, userInfo: sendingProcess as [AnyHashable: Any])
        print("sending process from sender: \(receivedProcess)")
    }
    
    func sendResultNotification(receivedResult: String) {
        let sendingResult = ["result": receivedResult]
        
        let name = Notification.Name(rawValue: NotificationKey.resultToBaseVCNotification.rawValue)
        NotificationCenter.default.post(name: name, object: nil, userInfo: sendingResult as [AnyHashable: Any])
        print("seding Result from sender: \(receivedResult)")
    }
    
    func sendScrollNotification() {
        let name = Notification.Name(rawValue: NotificationKey.progressViewScrollToVisibleNotification.rawValue)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func sendUpdateResultColorNotification(receivedAnsPressed: Bool) {
        let sendingAnsPressed = ["ansPressed": receivedAnsPressed]
        let name = Notification.Name(rawValue: NotificationKey.resultTextColorChangeNotification.rawValue)
        NotificationCenter.default.post(name: name, object: nil, userInfo: sendingAnsPressed as [AnyHashable: Any])
        print("sendUpdateResultColorNotification")
    }
    
    func sendToastCaseNotification(toastCase: ToastEnum) {
        let sendingCase = ["toastCase": toastCase]
        let name = Notification.Name(rawValue: NotificationKey.sendingToastNotification.rawValue)
        NotificationCenter.default.post(name: name, object: nil, userInfo: sendingCase as [AnyHashable: Any])
        print("sendToastCaseNotification")
    }
    

    
    // MARK: - HELPERS
    
    func updateIndexes(){
        ni[pi] += 1
        tempDigits[pi].append("")
        DS[pi].append(0)
        freshDI[pi].append(0)
        answer[pi].append(150)
        freshAI[pi].append(0)
        operationStorage[pi].append("")
        muldiOperIndex[pi].append(false)
    }
    
    
    func setupOperVariables( _ tempOperInput : String, _ tempi : Int){
        switch tempOperInput {
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
    
    
    func playSound(){
//        if soundModeOn{ // change it to userDefault
            AudioServicesPlaySystemSound(1104)
//        }
        print("soundModeOn: \(userDefaultSetup.getIsSoundOn())")
    }
    
    
    
    
    
    // MARK: - COPY AND PASTE
    func copyCurrentStates(){
        print("copyCurrentStates called")
        copiedNegativePossible = negativePossible
        copiedAnsPressed = ansPressed
        copiedpi = pi
        copiedni = ni
        copiedtempDigits = tempDigits
        copiedDS = DS
        copiedanswer = answer
        copiedoperationStorage = operationStorage
        copiedmuldiOperIndex = muldiOperIndex
        copiedfreshDI = freshDI
        copiedfreshAI = freshAI
        copiedniStart = niStart
        copiedniEnd = niEnd
        copiedpiMax = piMax
        copiedindexPivotHelper = indexPivotHelper
        copiednumOfPossibleNegative = numOfPossibleNegative
        copiedpositionOfParen = positionOfParen
        copiedNegativeSign = negativeSign
        copiedprocess = process
        copiedresult = result
        print("copied isAnsPressed : \(ansPressed)")
    }
    
    func pasteStates(){
        print("pasteStates baseVC")
        negativePossible = copiedNegativePossible
        ansPressed = copiedAnsPressed
        pi = copiedpi
        ni = copiedni
        tempDigits = copiedtempDigits
        DS = copiedDS
        answer = copiedanswer
        operationStorage = copiedoperationStorage
        muldiOperIndex = copiedmuldiOperIndex
        freshDI = copiedfreshDI
        freshAI = copiedfreshAI
        niStart = copiedniStart
        niEnd = copiedniEnd
        piMax = copiedpiMax
        indexPivotHelper = copiedindexPivotHelper
        numOfPossibleNegative = copiednumOfPossibleNegative
        positionOfParen = copiedpositionOfParen
        negativeSign = copiedNegativeSign
        process = copiedprocess
        result = copiedresult
    }
    
    // MARK: - ALIGN
    
    func align(){
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
    
    
    func alignForHistory( _ length : Double) -> String{
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
                    
                    continue startFor
                }
                
            } // and of for
            break startFor
        }
        
        if str.count > 0{
            for eachOne in 0 ... setteroi{
                processToBeReturn += str[eachOne]
            }
        }
        return processToBeReturn
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
    
    // MARK: - HISTORY TABLE -> BASEVC -> BASIC CALC
    public func didReceiveAnsFromTable(receivedValue: String) {
        var plusNeeded = false
        var parenNeeded = false
        var manualClearNeeded = false
//        let valueFromTable = ansString
        
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
        
        if receivedValue.contains("-") && manualClearNeeded{
            clearWithFetchingAns()
        }
        
        if plusNeeded{
            manualOperationPressed(operSymbol: "+")
        }
        
        if parenNeeded && receivedValue.contains("-"){
            insertParentheWithHistory(openParen: true)
        }
        
        if receivedValue.contains("-"){
            manualOperationPressed(operSymbol: "-")
        }
        
        insertAnsFromHistory(numString : receivedValue)
        
        if parenNeeded && receivedValue.contains("-"){
            insertParentheWithHistory(openParen: false)
        }
    }
    
    func clearWithFetchingAns(){
        clear()
        savedResult = nil

        process = ""
        sendProcessNotification(receivedProcess: process)
    }
    
    func manualOperationPressed(operSymbol : String){
        
        let operInput = operSymbol
        
        if ansPressed{
            
            clear()
            process = ""
            ansPressed = false
            DS[0][0] = savedResult!
            
            tempDigits[0][0] = nf6.string(for: savedResult!)!
            
            
            if DS[0][0] < 0{
                negativeSign = [[false,true]]
            }
            addPOfNumsAndOpers()
            pOfNumsAndOpers[setteroi] = "n"
            
            addStrForProcess()
            
            negativePossible = false
            
            printProcess()
            savedResult = nil
            freshDI[0][0] = 1
            setteroi += 1
            
            setupOperVariables(operInput, ni[0])
            
            addSumOfUnitSizes()
            sumOfUnitSizes[setteroi] = tagToUnitSizeString[operInput]!
            
            addPOfNumsAndOpers()
            pOfNumsAndOpers[setteroi] = "oper"
            dictionaryForLine[setteroi] = operInput
            
            addStrForProcess()
            strForProcess[setteroi] = operInput
            process += operationStorage[0][0]
            updateIndexes()
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
                    negativeSign[pi][numOfPossibleNegative[pi]] = true
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
                    sendToastCaseNotification(toastCase: .modified)
                    sendToastCaseNotification(toastCase: .modified)
                }
            }
            
            else if tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] == "-"{
                if operInput == "-"{}// - >> - : ignore input.
                else if operInput != "-"{ // - >> + * /
                    process.removeLast()
                    negativeSign[pi][numOfPossibleNegative[pi]] = false
                    tempDigits[pi][niStart[pi][numOfPossibleNegative[pi]]] = ""
                    sumOfUnitSizes[setteroi] -= tagToUnitSizeString["-"]!
                    setteroi -= 1
                    if setteroi < 0{
                        setteroi = 0
                    }
                    pOfNumsAndOpers.removeLast()
                    strForProcess.removeLast()
                    
                }
                 sendToastCaseNotification(toastCase: .modified)// both cases are abnormal.
            }
        }
        else if !negativePossible{ // modify Operation Input
            if tempDigits[pi][ni[pi]] == ""{
                setupOperVariables(operInput, ni[pi]-1)
                process.removeLast()
                process += operationStorage[pi][ni[pi]-1]
                 sendToastCaseNotification(toastCase: .modified)
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
                         sendToastCaseNotification(toastCase: .modified)
                        
                        strForProcess[setteroi].removeLast()
                    }
                } // && 조건으로 엮기.
                setteroi += 1
                
                setupOperVariables(operInput, ni[pi])
                process += operationStorage[pi][ni[pi]]
                updateIndexes()
                
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
    
    func insertParentheWithHistory(openParen : Bool){
        let input = openParen ? "(" : ")"
        
        if input == "("{
            
            
            if operationStorage[pi][ni[pi]] == "" && tempDigits[pi][ni[pi]] != ""{ //
   
                if process[process.index(before : process.endIndex)] == "."{ // 5.( >> 5x(
                    //remove dot.
                    //                        sumOfUnitSizes.append(0)
                    addSumOfUnitSizes()
                    
                    sumOfUnitSizes[setteroi] -= tagToUnitSize["."]!
                    tempDigits[pi][ni[pi]].removeLast()
                    process.removeLast()
                     sendToastCaseNotification(toastCase: .modified)
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
                    updateIndexes()
                     sendToastCaseNotification(toastCase: .modified)
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
                negativeSign.append([false, false])
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
                
                negativeSign[pi].append(false)
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
                         sendToastCaseNotification(toastCase: .modified)
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
            else{ sendToastCaseNotification(toastCase: .modified) } // input is ) and end of process is ( + - × ÷ >> ignore !
        }
        else{ sendToastCaseNotification(toastCase: .modified)} // pi == 0 , close paren before open it.
        printProcess()
        
    }
    
    func insertAnsFromHistory(numString : String){
        
        if ansPressed{
            clear()
            process = ""
            ansPressed = false
        }
        
        addPOfNumsAndOpers()
        addStrForProcess()
        
        if pOfNumsAndOpers[setteroi] == "op"{
            setteroi += 1
        }
        
        negativePossible = false
        let freshString = extractPositiveNumber(from: numString)
        
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
    
    func extractPositiveNumber(from stringValue : String ) -> String{
        var stringToReturn = stringValue
        // remove - at the front
        if stringValue.hasPrefix("-"){
            stringToReturn = String(stringValue.dropFirst())
        }
        // remove comma
        if stringValue.contains(","){
            stringToReturn = stringToReturn.components(separatedBy: ",").joined()
        }
        
        // remove dot if it contains at the end
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
        
    
    
    
    
    func checkIndexes(with comment : String){
        print("func checkIndexes(saySomething : \(comment){")
        print(" \(comment)")
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
        print("isNegativeSign : \(negativeSign)")
        print("isNegativePossible : \(negativePossible)")
        print("6.")
        print("answer : \(answer)")
        print("freshAI : \(freshAI)")
        print("result : \(String(describing: result))")
        if savedResult != nil{
            print("saveResult : \(savedResult!)")
        }else{
            print("saveResult is nil.")
        }
        print("isAnsPressed : \(ansPressed)\n\n")
        
        print("process : \(process)")
        print("oi : \(setteroi)")
        print("sumOfUnitSizes : \(sumOfUnitSizes)")
        print("pOfNumsAndOpers : \(pOfNumsAndOpers)")
        print("strForProcess : \(strForProcess)")
        print("lastMoveOP : \(lastMoveOP)")
        print("numOfEnter : \(numOfEnter)")
        print("dictionaryForLine : \(dictionaryForLine)")
    }
}
