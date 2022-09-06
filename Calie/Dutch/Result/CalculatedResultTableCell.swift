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
        
        
        attributedStr.append(NSAttributedString(string: "는(은)", attributes: [.font:UIFont.systemFont(ofSize: 18)]))
        
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
