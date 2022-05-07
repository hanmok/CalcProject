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


protocol PersonDetailCellDelegate: AnyObject {
    func showUpNumberPad()
    func hideNumberpad()
    func cell(_ cell: PersonDetailCell, didTapFullPrice: Bool)
    func cell(_ cell: PersonDetailCell, didTapAttended: Bool)
}

class PersonDetailCell: UICollectionViewCell {
    
    var viewModel: PersonDetailViewModel? {
        didSet {
            self.loadView()
            self.setupTargets()
//            self.contentView.isUserInteractionEnabled = false
        }
    }
    
    weak var delegate: PersonDetailCellDelegate?
    
    private let nameLabel = UILabel().then {
        $0.textColor = .black
    }
    
    public let spentAmountTF = PriceTextField().then { // !!!! ;;;
        $0.textAlignment = .right
        $0.backgroundColor = .gray
    }
    
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
        delegate?.cell(self, didTapFullPrice: true)
        
    }
    
    @objc func attendedBtnTapped(_ sender: UIButton) {
        print("Attended Btn Tapped!")
        delegate?.cell(self, didTapAttended: true)
    }
    
    private func loadView() {
        print("load View triggered")
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.name
        
        attendedBtn.setTitle(viewModel.attendedBtnTitle, for: .normal)
        attendedBtn.setTitleColor(viewModel.attendedBtnColor, for: .normal)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupTargets()
//        self.fullPriceBtn.addTarget(self, action: #selector(didTapMyButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//
//        guard isUserInteractionEnabled else { return nil }
//
//        guard !isHidden else { return nil }
//
//        guard alpha >= 0.01 else { return nil }
//
//        guard self.point(inside: point, with: event) else { return nil }
//
//
//        // add one of these blocks for each button in our collection view cell we want to actually work
////        if self.myButton.point(inside: convert(point, to: myButton), with: event) {
////            return self.myButton
////        }
//        if self.fullPriceBtn.point(inside: convert(point, to: fullPriceBtn), with: event) {
//            return self.fullPriceBtn
//        }
//
//        return super.hitTest(point, with: event)
//    }
    
//    @objc func didTapMyButton(sender:UIButton!) {
//        print("Tapped it!")
//    }
    
    private func setupLayout() {
        [nameLabel, spentAmountTF, fullPriceBtn, attendedBtn].forEach { v in
//            self.addSubview(v)
//            self.contentView.addSubview(v)
//            self.addSubview(v)
            addSubview(v)
        }
        
        spentAmountTF.delegate = self
        
        nameLabel.snp.makeConstraints { make in
//            make.leading.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(70)
        }
        
        
        attendedBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(60)
//            make.top.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.height.equalTo(30)
        }
        
        fullPriceBtn.snp.makeConstraints { make in
            make.trailing.equalTo(attendedBtn.snp.leading).offset(-5)
            make.width.equalTo(60)
//            make.top.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.height.equalTo(30)
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.trailing.equalTo(fullPriceBtn.snp.leading).offset(-10)
            make.height.equalTo(30)
//            make.top.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
    }
}

extension PersonDetailCell: UITextFieldDelegate {
    // need to communicate to.. the viewController that contains CollectionView which is of type PersonDetailCell for its cell
}



