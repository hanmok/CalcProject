//
//  PersonDetailTestCell.swift
//  Calie
//
//  Created by Mac mini on 2022/05/08.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import Then
import SnapKit


class PersonDetailTestCell: UICollectionViewCell {
    
    
    
    public let attendedBtn = UIButton().then {
        $0.setTitle("참석", for: .normal)
        $0.backgroundColor = .green
        $0.setTitleColor(.white, for: .normal)
    }
    
    public let fullPriceBtn = UIButton().then {
        $0.setTitle("전액", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .yellow
    }
    
    private func setupTargets() {
        fullPriceBtn.addTarget(self, action: #selector(fullPriceTapped(_:)), for: .touchUpInside)
        attendedBtn.addTarget(self, action: #selector(attendedBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func fullPriceTapped(_ sender: UIButton) {
        print("fullPrice Tapped!")
        
    }
    
    @objc func attendedBtnTapped(_ sender: UIButton) {
        print("Attended Btn Tapped!")
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupLayout() {
        
        addSubview(fullPriceBtn)
        addSubview(attendedBtn)
        
        
//        attendedBtn.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(20)
//            make.width.equalTo(100)
//            make.top.equalToSuperview().offset(20)
//            make.height.equalToSuperview()
//        }
        
        fullPriceBtn.snp.makeConstraints { make in
//            make.leading.equalTo(attendedBtn.snp.trailing).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(100)
            make.top.equalToSuperview().offset(20)
            make.height.equalToSuperview()
        }
        
        attendedBtn.snp.makeConstraints { make in

            make.leading.equalTo(fullPriceBtn.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview()
            
        }
        

    }
}
