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
    
    var isAttended: Bool = true

    weak var delegate: PersonDetailCellDelegate?
    
    private let nameLabel = UILabel().then {
        $0.textColor = .black
        $0.backgroundColor = .white
        $0.adjustsFontSizeToFitWidth = true
    }
    
    public let spentAmountTF = PriceTextField().then {
        $0.textAlignment = .right
    
        $0.layer.cornerRadius = 5
    }
    
    private let currencyLabel = UILabel().then {
        $0.text = ASD.currencyShort.localized
        $0.adjustsFontSizeToFitWidth = true
    }
    
    public let attendingBtn = AttendingButton()
    
    public let fullPriceBtn = UIButton().then {
        

        $0.backgroundColor = UIColor(white: 231.0 / 255.0, alpha: 0.95)
        $0.isHidden = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(white: 200.0/255.0, alpha: 1).cgColor
        $0.layer.cornerRadius = 8
        
        let imgView = UIImageView()
    }
    
    private let checkMark = UIImageView().then {
        $0.image = UIImage(systemName: "checkmark")
        $0.tintColor = UIColor(white: 188.0 / 255.0, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }
    
    private func setupTargets() {
        fullPriceBtn.addTarget(self, action: #selector(fullPriceBtnTapped(_:)), for: .touchUpInside)
        attendingBtn.addTarget(self, action: #selector(attendingBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func fullPriceBtnTapped(_ sender: UIButton) {
        print("fullPrice Tapped!")
//        if viewModel?.isAttended {
        guard let viewModel = viewModel else {
            return
        }
        
//        if viewModel.isAttended {
        
            delegate?.fullPriceAction(idx: sender.tag)
            // Post notify to hide fullPrices
            NotificationCenter.default.post(name: .hideRemainingPriceSelectors, object: nil)
        
    }
    
    @objc func attendingBtnTapped(_ sender: AttendingButton) {

        guard var viewModel = viewModel else {
            return
        }
                
        print("Attended Btn Tapped!")
        // UI update
        attendingBtn.isAttending.toggle()
        // DutchUnitController 의 '값' 만 업데이트.
        delegate?.updateAttendingState(with: sender.tag, to: sender.isAttending)
        
        isAttended = !isAttended
    }
    
    private func loadView() {
        print("load View triggered")
        guard let viewModel = viewModel else { return }

        isAttended = viewModel.isAttended
        nameLabel.text = viewModel.name
        
        attendingBtn.isAttending = isAttended
        attendingBtn.markAttendedState(using: isAttended)
        
        spentAmountTF.text = viewModel.spentAmount
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupTargets()
        addObservers()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(showUpFullPriceBtn), name: .showRemainingPriceSelectors, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideFullPriceBtn), name: .hideRemainingPriceSelectors, object: nil)
    }
    
    //MARK: -  ViewModel 을 바꿔주는 주기를 알아야함.. 그렇지 않으면 해당 조건문이 소용이 없다.
    @objc func hideFullPriceBtn() {
        fullPriceBtn.isHidden = true
    }
    
    @objc func showUpFullPriceBtn() {
        fullPriceBtn.isHidden = false
    }
    
    private func setupLayout() {
        [nameLabel, spentAmountTF, currencyLabel,
         fullPriceBtn,
         attendingBtn].forEach { v in
            addSubview(v)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(70)
        }
        
        attendingBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.equalTo(60)
            make.top.bottom.equalToSuperview()
        }
        
        currencyLabel.snp.makeConstraints { make in
            make.trailing.equalTo(attendingBtn.snp.leading).offset(-20)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(15)
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.trailing.equalTo(currencyLabel.snp.leading).offset(-5)
            make.top.bottom.equalToSuperview()
        }
        
        fullPriceBtn.snp.makeConstraints { make in
            make.leading.equalTo(spentAmountTF.snp.leading)
            make.trailing.equalTo(currencyLabel.snp.trailing)
            make.top.bottom.equalToSuperview()
        }
        
        fullPriceBtn.addSubview(checkMark)
        checkMark.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(30)
        }
    }
}
