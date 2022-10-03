//
//  LocalizedStringStorage.swift
//  Neat Calc
//
//  Created by Mac mini on 2020/07/19.
//  Copyright © 2020 hanmok. All rights reserved.
//

import Foundation

struct LocalizedStringStorage{
    // MARK: - Base Controleller
    let removeAll = NSLocalizedString("removeAlertMessage", comment: "모든 데이터 지우시겠습니까?")
    let numberLimit = NSLocalizedString("A numberLength Limit", comment: "15 digit 이하로 입력해주세요.")
    let answerLimit = NSLocalizedString("A answerLength Limit", comment: "15 digit 이하로 답이 나와야합니다.")
    let floatingLimit = NSLocalizedString("A floatingLength Limit", comment: "소숫점 아래 10 digit ")
    let savedToHistory = NSLocalizedString("saved to history", comment: "기록되었습니다.")
    let save = NSLocalizedString("save", comment: "저장")
    
    // MARK: - HistoryRecord
    let copy = NSLocalizedString("copy", comment: "복사")
    let copyComplete = NSLocalizedString("copy complete", comment: "복사 완료")
    let share = NSLocalizedString("share", comment: "공유")
    let delete = NSLocalizedString("delete", comment: "삭제")
    let cancel = NSLocalizedString("cancel", comment: "취소")
    
    let deleteComplete = NSLocalizedString("delete complete", comment: "제거 완료")
    let deleteAllComplete = NSLocalizedString("delete all complete", comment: "모든 기록 제거완료.")
    
    
    
    let editName = NSLocalizedString("edit name", comment: "이름 편집")
    

        // MARK: - Settings
    
    let soundOn = NSLocalizedString("Sound On", comment: "소리 켜짐")
    let soundOff = NSLocalizedString("Sound Off", comment: "소리 꺼짐")
    
    let notificationOn = NSLocalizedString("Noti On", comment: "알림 켜짐")
    let notificationOff = NSLocalizedString("Noti Off", comment: "알림 꺼짐")
    
    let modified = NSLocalizedString("Modification", comment: "수정됨")
    
//    let darkMode = NSLocalizedString("darkMode", comment: "다크모드 on")
//    let lightMode = NSLocalizedString("lightMode", comment: "라이트모드 on")
    
    let mode = NSLocalizedString("mode", comment: "모드")
    let darkMode = NSLocalizedString("darkMode", comment: "다크모드")
    let soundMode = NSLocalizedString("soundMode", comment: "사운드모드")
    let notificationMode = NSLocalizedString("notificationMode", comment: "알림모드")
    
    let general = NSLocalizedString("general", comment: "일반")
    let rate = NSLocalizedString("rate", comment: "평가")
    let review = NSLocalizedString("review", comment: "리뷰")
    
    
//    let some = NSString.NSLocalizedString(<#T##self: NSString##NSString#>)
    
}


// MARK: - 이거 쓰면 더 편하게 만들 수 있을 것 같은데...
extension NSString {
    func NSLocalizedString(_ str: String) -> String {
        return Foundation.NSLocalizedString(str, comment: "")
    }
}



extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}


struct ASD {
    static let overallResult = "Overall Result"
    static let personalResult = "Personal Result"
    static let expenses = "expenses"
    static let get = "Get"
    static let Send = "Send"
    static let send = "send"
    static let gatheringRecord = "Gathering Record"


    static let attendances = "Attendances";

    static let calculate = "Calculate"; // 수정할 것.
    static let remainder = "remainder";
    static let spentFor = "Spent for"; // 수정할 것. 아래와 일관성 맞지 않음.
    static let SpentAmt = "Spent Amt";

    static let SpentDate = "Spent Date";

    static let AddPerson = "Add Person";
    static let attended = "attended";

    static let gathering = "Gathering";
    
    static let currency = "Currency"
    static let currencyShort = "currencyShort"
    static let confirm = "Confirm"
    
    static let element = "element"
    
    static let dutchpay = "Dutchpay"
    
    static let addingPersonMsg = "addingPersonMsg"
    
    static let resetGatheringTitle = "ResetGathering"
    static let resetGatheringMsg = "resetGatheringMsg"
    static let reset = "reset"
    static let cancel = "cancel"
    
    static let editGatheringName = "editGatheringNameTitle"
    
    static let editGatheringNameMsg = "editGatheringNameMsg"
    static let gatheringName = "gatheringName"
    static let done = "done"
    
    static let addingPeople = "addPeople"
    
    static let add = "add"
    static let name = "name"
    static let edit = "edit"
    
    static let emptyNameAlert = "emptyNameAlert"
    
    static let deletingPersonFailMsg = "deletingPersonFailMsg"
    
    static let usingDecimalPoint = "usingDecimalPoint"
    
    static let currencyUnit = "currencyUnit"
    
    static let calculatingPrecision = "calculatingPrecision"
    
    static let precisions = [
        "twoDecimalPlace",
        "firstDecimalPlace",
        "onePlace",
        "tenPlace",
        "hundredPlace",
        "thousandsPlace",
        "tenThousandsPlace"
    ]
    
    
    static func convertDutchResultMsg(from: String, to: String, amt: Double) -> String {

        let convertedAmt = amt.applyDecimalFormatWithCurrency()
        
        var ret: String
        
        if ASD.currencyShort.localized == "원" {
            let postPosition = ASD.getCorrectPostPosition(from: from)
            
            ret = from + postPosition + " " + to + "에게 " + convertedAmt + "을 보내주세요."
        } else {
            ret = from + " should send " + convertedAmt + " to " + to
        }
        
        return ret
    }
    
    
    static func getCorrectPostPosition(from name: String) -> String {
    print("josa Testing started ")
        
//    let text = "소방관"
        let text = name
        print("postPosition text: \(text)")
        guard let text = text.last else {  fatalError() }
        let val = UnicodeScalar(String(text))?.value
        guard let value = val else { return "는" }
        
    // 값
        print("value: \(value)")
        print("0xac00: \(0xac00)")
        // 모음 하나만 있는 경우는 어떻게 처리되지 ??
        if value < 0xac00 { return "는" } // 영어인 경우 필터
        let x = (value - 0xac00) / 28 / 21
        let y = ((value - 0xac00) / 28) % 21
        let z = (value - 0xac00) % 28 // 없을 경우 z 는 0
        
//    print("x: \(x), y: \(y), z: \(z)")
//        print(x,y,z)//“안” -> 11 0 4
        
    // 값 -> Character
        
        let i = UnicodeScalar(0x1100 + x) //초성
        let j = UnicodeScalar(0x1161 + y) //중성
        let k = UnicodeScalar(0x11a6 + 1 + z) //종성, 만약 없으면 항상 \u{11A7} 가 나옴
    // 관
    
//        U+1100부터 U+115E까지는 초성, U+1161부터 U+11A7까지는 중성, U+11A8부터 U+11FF까지는 종성
    
        // z == 0 -> 받침 없음 -> '를'  '는'
        // z != 0 -> 받침 있음 -> '을', '은'
        // 은, 는
    
    let appending = z != 0 ? "은" : "는"
        
    // 받침 ㅇ -> 을 이
    // 받침 X ->  를 가
    // 을 / 를
        
    return appending
    }
}
