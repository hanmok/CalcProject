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

class ResultOverallTableCell: UITableViewCell {
    static let identifier = "ResultOverallTableCell"
    
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
    
    public var personCostInfo: PersonPaymentInfo? {
        didSet {
            configureLayout()
        }
    }
    
    private let nameLabel = UILabel()
    

    
    private let pricesContainer = UIView()
    
    private let spentAmountLabel = UILabel().then {
        $0.textAlignment = .right
    }
    
    // TODO: 여기에만 색상 넣기. 부호 넣어 말어..?
    private let toPayLabel = UILabel().then {
        $0.textAlignment = .right
//        $0.backgroundColor = .cyan
    }
    
    private let summaryLabel = UILabel().then {
        $0.textAlignment = .right
//        $0.backgroundColor = .orange
    }
    
//    private let attendedPlacesLabel = UILabel().then {
//        $0.textAlignment = .center
//        $0.sizeToFit()
//
//    }
    
    
    
    private func configureLayout() {
//        guard let overallPersonInfo = overallPersonInfo else {            return
//        }
        guard let personCostInfo = personCostInfo else {
            return
        }


//        nameLabel.text = overallPersonInfo.name
        nameLabel.text = personCostInfo.name
        
        spentAmountLabel.text = personCostInfo.paidAmt.convertIntoKoreanPrice()
        toPayLabel.text = personCostInfo.toGet.convertIntoKoreanPrice()
        summaryLabel.text = personCostInfo.sum.convertIntoKoreanPrice()
        
        
//        spentAmountLabel.text = overallPersonInfo.relativePaidAmount.convertIntoKoreanPrice()
        
//        attendedPlacesLabel.text = overallPersonInfo.attendedPlaces
        
        
    }
    
    private func setupLayout() {
        
//        separatorInset = UIEdgeInsets.zero
//        layoutMargins = UIEdgeInsets.zero
        
        [nameLabel,
         pricesContainer
//         spentAmountLabel,
//         toPayLabel, summaryLabel
         
//         spentAmountLabel, attendedPlacesLabel
        ].forEach { addSubview($0)}
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
//            make.width.equalTo(70)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        pricesContainer.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        [spentAmountLabel, toPayLabel, summaryLabel].forEach { self.pricesContainer.addSubview($0)}
        
        
        spentAmountLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing)
            make.top.bottom.equalToSuperview()
//            make.width.equalTo(100)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        toPayLabel.snp.makeConstraints { make in
            make.leading.equalTo(spentAmountLabel.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
//            make.width.equalTo(100)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        summaryLabel.snp.makeConstraints { make in
            make.leading.equalTo(toPayLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview()
        }
        
        
        
        
//        spentAmountLabel.snp.makeConstraints { make in
//            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
//            make.top.bottom.equalToSuperview()
//            make.width.equalTo(100)
//        }
        
//        attendedPlacesLabel.snp.makeConstraints { make in
//            make.leading.equalTo(spentAmountLabel.snp.trailing).offset(10)
//            make.trailing.equalToSuperview().inset(10)
//            make.top.bottom.equalToSuperview()
//        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ResultBriefInfoTableCell.identifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
