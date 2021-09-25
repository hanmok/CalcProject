//
//  LocalizedStringStorage.swift
//  Neat Calc
//
//  Created by Mac mini on 2020/07/19.
//  Copyright © 2020 hanmok. All rights reserved.
//

import Foundation

struct LocalizedStringStorage{
    let removeAll = NSLocalizedString("removeAlertMessage", comment: "모든 데이터 지우시겠습니까?")
    let numberLimit = NSLocalizedString("A numberLength Limit", comment: "15 digit 이하로 입력해주세요.")
    let answerLimit = NSLocalizedString("A answerLength Limit", comment: "15 digit 이하로 답이 나와야합니다.")
    let floatingLimit = NSLocalizedString("A floatingLength Limit", comment: "소숫점 아래 10 digit ")
    let soundOn = NSLocalizedString("Sound On", comment: "소리 켜짐")
    let soundOff = NSLocalizedString("Sound Off", comment: "소리 꺼짐")
    let notificationOn = NSLocalizedString("Noti On", comment: "알림 켜짐")
    let notificationOff = NSLocalizedString("Noti Off", comment: "알림 꺼짐")
    let modified = NSLocalizedString("Modification", comment: "수정됨")
    let darkMode = NSLocalizedString("darkMode", comment: "다크모드 on")
    let lightMode = NSLocalizedString("lightMode", comment: "라이트모드 on")
    
    
    let copy = NSLocalizedString("copy", comment: "복사")
    let copyComplete = NSLocalizedString("copy complete", comment: "복사 완료")
    let share = NSLocalizedString("share", comment: "공유")
    let delete = NSLocalizedString("delete", comment: "삭제")
    let cancel = NSLocalizedString("cancel", comment: "취소")
    
    let deleteComplete = NSLocalizedString("delete complete", comment: "제거 완료")
    let deleteAllComplete = NSLocalizedString("delete all complete", comment: "모든 기록 제거완료.")
    
    let savedToHistory = NSLocalizedString("saved to history", comment: "기록되었습니다.")

}
