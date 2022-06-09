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

    func cell(_ cell: PersonDetailCell, from peopleIndex: Int)
    
    func updateAttendingState(with tag: Int, to isAttending: Bool)
}

class PersonDetailCell: UICollectionViewCell {
    
    var viewModel: PersonDetailViewModel? {
        didSet {
            self.loadView()
            self.setupTargets()
        }
    }
    
    weak var delegate: PersonDetailCellDelegate?
    
    private let nameLabel = UILabel().then {
        $0.textColor = .black
        $0.backgroundColor = .magenta
    }
    
    public let spentAmountTF = PriceTextField().then {
        $0.textAlignment = .right
        $0.backgroundColor = .gray
    }
    
    public let attendingBtn = AttendingButton()
    
    public let fullPriceBtn = UIButton().then {
        $0.setTitle("전액", for: .normal)
        $0.setTitleColor(.black, for: .normal)
//        $0.backgroundColor = .yellow
        $0.backgroundColor = UIColor(white: 240 / 255, alpha: 1)
    }
    
    private func setupTargets() {
        fullPriceBtn.addTarget(self, action: #selector(fullPriceBtnTapped(_:)), for: .touchUpInside)
        attendingBtn.addTarget(self, action: #selector(attendingBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func fullPriceBtnTapped(_ sender: UIButton) {
        print("fullPrice Tapped!")
        delegate?.cell(self, from: sender.tag)
//        delegate?.updatePriceState(with: sender.tag)
        
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
        [nameLabel, spentAmountTF, fullPriceBtn, attendingBtn].forEach { v in
            addSubview(v)
        }
        
        spentAmountTF.delegate = self
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(70)
        }
        
        
        attendingBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(60)
            make.top.bottom.equalToSuperview()
        }
        
        fullPriceBtn.snp.makeConstraints { make in
            make.trailing.equalTo(attendingBtn.snp.leading).offset(-5)
            make.width.equalTo(60)
            make.top.bottom.equalToSuperview()
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.trailing.equalTo(fullPriceBtn.snp.leading).offset(-10)
            make.top.bottom.equalToSuperview()
        }
    }
}

extension PersonDetailCell: UITextFieldDelegate {
    // need to communicate to.. the viewController that contains CollectionView which is of type PersonDetailCell for its cell
}
