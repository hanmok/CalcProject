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

//    func cell(_ cell: PersonDetailCell, from peopleIndex: Int)
    func fullPriceAction(idx: Int)
    
    func updateAttendingState(with tag: Int, to isAttending: Bool)
}

class PersonDetailCell: UICollectionViewCell {
    
    var viewModel: PersonDetailCellViewModel? {
        didSet {
            self.loadView()
            self.setupTargets()
        }
    }
    
    weak var delegate: PersonDetailCellDelegate?
    
    private let nameLabel = UILabel().then {
        $0.textColor = .black
        $0.backgroundColor = .white
        $0.adjustsFontSizeToFitWidth = true
//        $0.backgroundColor = .magenta
    }
    
//    public let bottomLineView = UIView().then {
//        $0.backgroundColor = .green
//        $0.isHidden = true
//    }
    
    public let spentAmountTF = PriceTextField().then {
        $0.textAlignment = .right
        $0.backgroundColor = UIColor(rgb: 0xE7E7E7)
        $0.layer.cornerRadius = 5
    }
    
    private let currencyLabel = UILabel().then {
        $0.text = "원"
    }
    
    public let attendingBtn = AttendingButton()
    
    public let fullPriceBtn = UIButton().then {
        $0.setTitle("전액", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = UIColor(white: 240 / 255, alpha: 1)
    }
    
    
    
    private func setupTargets() {
        fullPriceBtn.addTarget(self, action: #selector(fullPriceBtnTapped(_:)), for: .touchUpInside)
        attendingBtn.addTarget(self, action: #selector(attendingBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func fullPriceBtnTapped(_ sender: UIButton) {
        print("fullPrice Tapped!")
//        delegate?.cell(self, from: sender.tag)
        delegate?.fullPriceAction(idx: sender.tag)
    }
    
    @objc func attendingBtnTapped(_ sender: AttendingButton) {
        print("Attended Btn Tapped!")
        attendingBtn.isAttending.toggle()
        
        delegate?.updateAttendingState(with: sender.tag, to: sender.isAttending)
    }
    
    private func loadView() {
        print("load View triggered")
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.name
        
        attendingBtn.setTitle(viewModel.attendingBtnTitle, for: .normal)
        attendingBtn.setTitleColor(viewModel.attendingBtnColor, for: .normal)
        
        spentAmountTF.text = viewModel.spentAmount
        
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
        [nameLabel, spentAmountTF, currencyLabel,
//         bottomLineView,
         fullPriceBtn, attendingBtn].forEach { v in
            addSubview(v)
        }
        
        spentAmountTF.delegate = self
        
        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
//            make.leading.equalToSuperview().inset(10)
//            make.leading.equalToSuperview().inset(15)
            make.leading.equalToSuperview()
            make.width.equalTo(70)
        }
        
        attendingBtn.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-20)
            make.trailing.equalToSuperview()
            make.width.equalTo(60)
            make.top.bottom.equalToSuperview()
        }
        
        fullPriceBtn.snp.makeConstraints { make in
            make.trailing.equalTo(attendingBtn.snp.leading).offset(-10)
            make.width.equalTo(60)
            make.top.bottom.equalToSuperview()
        }
        
        currencyLabel.snp.makeConstraints { make in
//            make.trailing.equalTo(attendingBtn.snp.leading).offset(-35)
            make.trailing.equalTo(fullPriceBtn.snp.leading).offset(-15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(15)
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
//            make.trailing.equalTo(attendingBtn.snp.leading).offset(-20)
            make.trailing.equalTo(currencyLabel.snp.leading).offset(-5)
            make.top.bottom.equalToSuperview()
        }
        
//        bottomLineView.snp.makeConstraints { make in
//            make.leading.equalTo(spentAmountTF.snp.leading)
//            make.trailing.equalTo(spentAmountTF.snp.trailing)
//            make.bottom.equalTo(spentAmountTF.snp.bottom)
//            make.height.equalTo(1)
//        }
    }
}

extension PersonDetailCell: UITextFieldDelegate {
    // need to communicate to.. the viewController that contains CollectionView which is of type PersonDetailCell for its cell
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("textFieldDidBeginEditing called !!")
//        bottomLineView.isHidden = false
//    }
}
