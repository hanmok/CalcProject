
//
//  DutchTableCell.swift
//  Calie
//
//  Created by Mac mini on 2022/06/13.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit
import Then
import SnapKit


class DutchTableCell: UITableViewCell {

    static let identifier = "DutchTableCell"
    
//    var viewModel: NewDutchUnitCellViewModel? {
//        didSet {
//            self.loadView()
//        }
//    }
    
    var viewModel: DutchTableCellViewModel? {
        didSet {
            self.loadView()
        }
    }
    
//    var dutchUnitCellComponents: DutchUnitCellComponents? {
//        didSet {
//            self.loadView()
//        }
//    }

    private let placeNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = UserDefaultSetup().darkModeOn ? UIColor.numAndOpersTextDM : UIColor.numAndOpersTextLM
    }

    private let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .black
        $0.textAlignment = .right
        $0.textColor = UserDefaultSetup().darkModeOn ? UIColor.resultTextDM : UIColor.resultTextLM
    }

    private let peopleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textColor = .black
        $0.textAlignment = .right
        $0.textColor = UserDefaultSetup().darkModeOn ? UIColor.numAndOpersTextDM : UIColor.numAndOpersTextLM
    }
    
    private let dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10)
//        $0.textColor = .black
        $0.textColor = UIColor(white: 0, alpha: 0.7)
        $0.textAlignment = .left
        $0.textColor = UserDefaultSetup().darkModeOn ? UIColor.dateTextDM : UIColor.dateTextLM
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLayout()
        if UserDefaultSetup().darkModeOn {
            self.backgroundColor = UIColor.emptyAndNumbersBGDark
        } else{
            self.backgroundColor = UIColor.emptyAndNumbersBGLight
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        
        
        
        self.addSubview(placeNameLabel)
        placeNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
//            make.centerY.equalToSuperview().offset(8)
            make.top.equalToSuperview().inset(5)
//            make.height.equalToSuperview().dividedBy(1.5)
            make.height.equalTo(self.snp.height).dividedBy(2)
            make.width.equalToSuperview().dividedBy(3)
        }

        self.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
//            make.top.equalToSuperview().inset(8)
            make.width.equalToSuperview().dividedBy(3)
//            make.height.equalTo(10)
            make.top.equalTo(placeNameLabel.snp.bottom)
            make.bottom.equalToSuperview().inset(5)
        }
       
        
        
        
        self.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalToSuperview().dividedBy(3)
            make.height.equalTo(self.snp.height).dividedBy(2)
        }

        self.addSubview(peopleLabel)
        peopleLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom)
            make.bottom.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalToSuperview().dividedBy(2)
        }
    }

    private func loadView() {
//        guard let dutchUnitCellComponents = dutchUnitCellComponents else { return }
//
//        placeNameLabel.text = dutchUnitCellComponents.placeName
//        priceLabel.text = dutchUnitCellComponents.spentAmount
//        peopleLabel.text = dutchUnitCellComponents.peopleNameList
//        dateLabel.text = dutchUnitCellComponents.date
        
        guard let viewModel = viewModel else { return }

        placeNameLabel.text = viewModel.placeName
        priceLabel.text = viewModel.spentAmount
        peopleLabel.text = viewModel.peopleNameList
        dateLabel.text = viewModel.date
        
    }
}



//struct DutchUnitCellComponents {
//    var placeName: String
//    var spentAmount: String
//    var peopleNameList: String
//    var date: String
//}
