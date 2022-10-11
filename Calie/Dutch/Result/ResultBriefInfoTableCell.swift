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

class ResultBriefInfoTableCell: UITableViewCell {
    static let identifier = "ResultBriefInfoTableCell"
    
    let userDefaultSetup = UserDefaultSetup()
//    var viewModel: ResultBriefInfoTableCellViewModel? {
//        didSet {
//            configureLayout()
//        }
//    }
    
//    public var overallPersonInfo: OverallPersonInfo? {
//        didSet {
//            configureLayout()
//        }
//    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 50))
//
//    }
    
    public var personCostInfo: PersonPaymentInfo? {
        didSet {
            configureLayout()
        }
    }
    
    private let nameLabel = UILabel().then {
//        $0.textColor = UserDefaultSetup.applyColor(onDark: .semiResultTextDM, onLight: .semiResultTextLM)
        $0.textColor = UserDefaultSetup.applyColor(onDark: .semiResultTextDM, onLight: UIColor(white: 0.1, alpha: 1))
        $0.adjustsFontSizeToFitWidth = true
    }

    
    private let pricesContainer = UIView()
    
    private let spentAmountLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular) // 18
//        $0.textColor = UserDefaultSetup.applyColor(onDark: .semiResultTextDM, onLight: .semiResultTextLM)
        $0.textColor = UserDefaultSetup.applyColor(onDark: .semiResultTextDM, onLight: UIColor(white: 0.1, alpha: 1))
    }
    
    private let spentAmountInfoLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = ASD.expenses.localized
//        $0.sizeToFit()
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = .gray
    }
    

    private let toPayLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = UserDefaultSetup.applyColor(onDark: .resultTextDM, onLight: .resultTextLM)
    }
    
    private let toPayInfoLabel = UILabel().then {
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.adjustsFontSizeToFitWidth = true
    }
    
    
    
    
    
    private func configureLayout() {
//        guard let overallPersonInfo = overallPersonInfo else {            return
//        }
        
        let isUsingFloatingPoint = false
        
        guard let personCostInfo = personCostInfo else {
            return
        }

//        nameLabel.attributedText = NSAttributedString(string: personCostInfo.name, attributes: [.font: UIFont.systemFont(ofSize: 26, weight: .light)])
        
        nameLabel.attributedText = NSAttributedString(string: personCostInfo.name, attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .light)])
        
        let spentAmtStr = personCostInfo.paidAmt.applyDecimalFormatWithCurrency()

        spentAmountLabel.text = spentAmtStr

        let toPayAmt = personCostInfo.toGet

        let unsignedAmt = toPayAmt > 0 ? toPayAmt : -toPayAmt
        
        let toPayAmtStr = unsignedAmt.applyDecimalFormatWithCurrency()
        
        if unsignedAmt != 0 {
            toPayLabel.text = toPayAmtStr
        }
        
        switch toPayAmt {
        case _ where toPayAmt < 0:
            toPayInfoLabel.text = ASD.Send.localized
            
        case _ where toPayAmt > 0:
            toPayInfoLabel.text = ASD.get.localized
            
        default:
            break
        }
        
        let blueInDarkMode = UIColor(red: 100, green: 190, blue: 255)
        let blue = UserDefaultSetup.applyColor(onDark: blueInDarkMode, onLight: .blue)
        let red = UIColor(red: 246, green: 101, blue: 101)

        toPayInfoLabel.textColor = toPayAmt > 0 ? blue : red
    }
    
    private func setupLayout() {
        backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
        
        [nameLabel,
         pricesContainer
         
        ].forEach { addSubview($0)}
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(6)
            make.width.equalTo(80)
        }
        
        pricesContainer.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview().inset(6)
            make.trailing.equalToSuperview()
        }
        
        [spentAmountLabel, toPayLabel,
         spentAmountInfoLabel, toPayInfoLabel
        ].forEach { self.pricesContainer.addSubview($0)}
        
        spentAmountInfoLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2.1)
            make.width.equalTo(70)
        }
        
        spentAmountLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(15)
            make.top.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2.1)
            make.trailing.equalTo(spentAmountInfoLabel.snp.leading).offset(-5)
        }
        
        toPayInfoLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.top.equalTo(spentAmountInfoLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview()
            make.width.equalTo(70)
        }
        
        toPayLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(15)
            make.top.equalTo(spentAmountLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview()
            make.trailing.equalTo(toPayInfoLabel.snp.leading).offset(-5)
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
