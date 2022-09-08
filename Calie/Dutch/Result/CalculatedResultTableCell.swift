//
//  ResultBriefInfoTableCell.swift
//  Calie
//
//  Created by Mac mini on 2022/08/10.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
//import JosaFormatter

class CalculatedResultTableCell: UITableViewCell {
    static let identifier = "ResultOverallTableCell"
    
    public var exchangeInfo: ResultTupleWithName? {
        didSet {
            configureLayout()
        }
    }
    
    
    private let exchangeTextLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 22)
//        $0.backgroundColor = .magenta
    }
    
    private func configureLayout() {
        guard let exchangeInfo = exchangeInfo else {
            return
        }
        
        let (from, to, amt) = exchangeInfo
        
//        let convertedAmt = amt.getStrWithoutDots()
        
        let convertedAmt = amt.convertIntoKoreanPrice()
        
        var attributedStr = NSMutableAttributedString(string: from + " ", attributes: [.font: UIFont.systemFont(ofSize: 22)])
        
        
//        let correctJosa = KoreanUtils.format("'%@'는", from)
//        print("correctJosa: \(correctJosa)")
        
        let postPosition = getCorrectPostPosition(from: from)
        
        attributedStr.append(NSAttributedString(string: postPosition, attributes: [.font:UIFont.systemFont(ofSize: 18)]))
        
        attributedStr.append(NSAttributedString(string: " " + to + " ", attributes: [.font:UIFont.systemFont(ofSize: 22)]))
        
        attributedStr.append(NSAttributedString(string: "에게", attributes: [.font:UIFont.systemFont(ofSize: 18)]))

        attributedStr.append(NSAttributedString(string: " " + convertedAmt, attributes: [.font:UIFont.systemFont(ofSize: 22)]))

        attributedStr.append(NSAttributedString(string: "을 보내주세요.", attributes: [.font:UIFont.systemFont(ofSize: 18)]))
//        let str = " \(from) 이 \(to) 에게 \(convertedAmt) 를 보내주세요."
        exchangeTextLabel.attributedText = attributedStr
        
//        exchange
        
//        exchangeTextLabel.text = str
    }
    
    private func setupLayout() {
        
        addSubview(exchangeTextLabel)
        exchangeTextLabel.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview().inset(5)
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ResultBriefInfoTableCell.identifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension CalculatedResultTableCell {
    // x, y, i, j 는 사실 필요가 없을수도
    // MARK: - 영문일 경우 막아놔야함. 이상한 텍스트 들어갔을 때도..
    func getCorrectPostPosition(from name: String) -> String {
    print("josa Testing started ")
        
//    let text = "소방관"
        let text = name
        print("postPosition text: \(text)")
        guard let text = text.last else {  fatalError() }
        let val = UnicodeScalar(String(text))?.value
//        guard let value = val else {  fatalError() }
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
