//
//  PersonDetailCVCell.swift
//  Calie
//
//  Created by Mac mini on 2022/05/03.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import Then
import SnapKit


class PersonDetailCVCell: UICollectionViewCell {
    
    var viewModel: PersonDetailViewModel? {
        didSet {
            self.loadView()
        }
    }
    
    
    private let nameLabel = UILabel().then {
//        $0.backgroundColor = .green
//        $0.textColor = .blue
        $0.textColor = .black
        
    }
    
    private let spentAmountTF = PriceTextField()
    
    private let attendedBtn = UIButton().then {
        $0.setTitle("참석", for: .normal)
        $0.backgroundColor = .green
        $0.setTitleColor(.white, for: .normal)
    }
    
    private let fullPriceBtn = UIButton().then {
        $0.setTitle("전액", for: .normal)
        $0.setTitleColor(.black, for: .normal)
//        $0.backgroundColor = .magenta
        $0.backgroundColor = .yellow
    }
    
    private func loadView() {
        print("load View triggered")
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.name
//        spentAmountTF.text = viewModel.spentAmount
        print("attendedBtn title: \(viewModel.attendedBtnTitle)")
        attendedBtn.setTitle(viewModel.attendedBtnTitle, for: .normal)
        attendedBtn.setTitleColor(viewModel.attendedBtnColor, for: .normal)
//        attendedBtn.setTitleColor(.blue, for: .normal)
        
//        fullPriceBtn.setTitle("전액", for: .normal)
//        fullPriceBtn.setTitleColor(.green, for: .normal)
        
        print("load View ended")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .gray
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [nameLabel, spentAmountTF, fullPriceBtn, attendedBtn].forEach { v in
            self.addSubview(v)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(10)
            make.height.equalTo(30)
            make.width.equalTo(70)
        }
        
        
        attendedBtn.snp.makeConstraints { make in
//            make.leading.equalTo(fullPriceBtn.snp.trailing)
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
        
        fullPriceBtn.snp.makeConstraints { make in
//            make.leading.equalTo(spentAmountTF.snp.trailing)
            make.trailing.equalTo(attendedBtn.snp.leading)
            make.width.equalTo(60)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing)
            make.trailing.equalTo(fullPriceBtn.snp.leading)
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(20)
        }
        
        
        
    }
}
