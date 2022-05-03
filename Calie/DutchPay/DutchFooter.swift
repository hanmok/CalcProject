//
//  DutchHeader.swift
//  Calie
//
//  Created by Mac mini on 2022/05/02.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit

protocol DutchFooterDelegate: AnyObject {
    func didTapPlus()
}

class DutchFooter: UICollectionReusableView {
    
    var viewModel: DutchFooterViewModel? {
        didSet { self.loadView()}
    }
    
    var footerDelegate: DutchFooterDelegate?
    
    private func loadView() {
        guard let viewModel = viewModel else {
            return
        }

        leadingCostLabel.text = viewModel.leadingTotalCost
        trailingCostLabel.text = viewModel.trailingTotalCost
        print("loadView in header Triggered")

    }
    
    private let leadingCostLabel = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .left
        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    }
    private let trailingCostLabel = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .right
        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    }
    
    private let plusBtn: UIButton = {
        let btn = UIButton()
       let plusImage = UIImageView(image: UIImage(systemName: "plus.circle"))
//        plusImage.backgroundColor = .white
        
        let removingLineView = UIView()
        removingLineView.backgroundColor = .white
        
        btn.addSubview(removingLineView)
        removingLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
            make.centerY.equalToSuperview()
        }
        
        btn.addSubview(plusImage)
        plusImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        

        
        
        
        btn.addTarget(nil, action: #selector(handleTappedAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleTappedAction(_ sender: UIButton){
        print("plus btn tapped from DutchFooter!")
        footerDelegate?.didTapPlus()
    }
    
    private let bottomContainer = UIView().then {
        $0.addBorders(edges: .top, color: .black)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        print("header has loaded")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2)
        }
        

        bottomContainer.addSubview(leadingCostLabel)
        leadingCostLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(130)
        }
        
        bottomContainer.addSubview(trailingCostLabel)
        trailingCostLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-30)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        

        addSubview(plusBtn)
        plusBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.centerY.equalTo(bottomContainer.snp.top)
            make.width.height.equalTo(46)
        }
    }
}


struct DutchFooterViewModel {
    
    let gathering: Gathering2
    
    var trailingTotalCost: String {
        // TODO: Apply Global Currency
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let intValue = gathering.totalCost.convertToInt() {
            return numberFormatter.string(from: NSNumber(value: intValue))! + " 원"
        } else {
            return numberFormatter.string(from: NSNumber(value: gathering.totalCost))! + " 원"
        }
    }
    
    var leadingTotalCost: String { return "총 금액"}
}

