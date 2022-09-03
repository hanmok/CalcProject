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

class CalculatedResultTableCell: UITableViewCell {
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
    

    
    public var exchangeInfo: ResultTupleWithName? {
        didSet {
            configureLayout()
        }
    }
    
    
    private let exchangeTextLabel = UILabel()
    
    private func configureLayout() {
        guard let exchangeInfo = exchangeInfo else {
            return
        }
        
        let (from, to, amt) = exchangeInfo
        
        let str = " \(from) 이 \(to) 에게 \(amt) 를 보내주세요."
        exchangeTextLabel.text = str
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
