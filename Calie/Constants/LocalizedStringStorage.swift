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


extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - 이거 쓰면 더 편하게 만들 수 있을 것 같은데...
extension NSString {
    func NSLocalizedString(_ str: String) -> String {
        return Foundation.NSLocalizedString(str, comment: "")
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


    static let attendances = "참가 인원";

    static let calculate = "정산하기"; // 수정할 것.
    static let remainder = "남은 금액";
    static let spentFor = "지출 항목"; // 수정할 것. 아래와 일관성 맞지 않음.
    static let SpentAmt = "지출 금액";

    static let SpentDate = "지출 일시";

    static let AddPerson = "인원 추가";
    static let attended = "참가";

    static let gathering = "모임";
    
    static let USD = "원"
    
    static let confirm = "Confirm"
    
//    static let at
}
