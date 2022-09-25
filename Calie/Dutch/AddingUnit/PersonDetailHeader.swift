//
//  PersonDetailHeader.swift
//  Calie
//
//  Created by Mac mini on 2022/09/14.
//  Copyright © 2022 Mac mini. All rights reserved.
//

// Notifcation pattern 쓰는게 가장 좋을 것 같은데 ?

import Foundation
import UIKit
import Then

protocol PersonDetailHeaderDelegate: AnyObject {
    func dismissAcion()
    func spentAmtTapped()
    func textFieldTapAction(sender: UITextField, isSpentAmountTF: Bool)
    func valueUpdated(spentAmount: Double, spentPlace: String)
    func remainingBtnTapped()
//    func updateSpentPlace() {
//
//    }
    
}


struct PersonHeaderViewModel {
    var spentAmt: String
    var spentPlace: String
    var spentDate: Date
//    var remainder: String
    var remainder: Double
}

class PersonDetailHeader: UICollectionReusableView {
    
    var viewModel: PersonHeaderViewModel? {
        didSet {
            print("personDetailHeader viewModel changed") // not called!
            configureLayout()
        }
    }
    
    static let headerIdentifier = "HeaderIdentifier"
    
    weak var headerDelegate: PersonDetailHeaderDelegate?
    
    private let smallPadding: CGFloat = 10
    
    private let emptyView = UIView().then {
        $0.backgroundColor = .yellow
    }
    
    var remainingBtnTapped: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupAddTargets()
        setupNotification()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeStateToActive(_:)), name: .changePriceStateIntoActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeStateToInactive(_:)), name: .changePriceStateIntoInactive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSpentAmt(_:)), name: .updateSpentAmt, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifiedOtherViewTapped(_:)), name: .notifyOtherViewTapped, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(remainingPriceChanged), name: .remainingPriceChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleRemainingBtnTapped), name: .hideRemainingPriceSelectors, object: nil)
    }
    
    @objc func toggleRemainingBtnTapped(_ notification: Notification) {
        remainingBtnTapped = false
    }
    
    @objc func notifiedOtherViewTapped(_ notification: Notification) {
        print("changeStateToActive called!!")
//        spentAmountTF.backgroundColor = UIColor(rgb: 0xF2F2F2)
//        spentAmountTF.textColor = UIColor(white: 0.7, alpha: 1)
        
        let headerInfoDic: [AnyHashable: Any] = ["spentPlace": spentPlaceTF.text!, "spentAmt": spentAmountTF.text!, "spentDate": spentDatePicker.date]
        
        NotificationCenter.default.post(name: .sendHeaderInfoBack, object: nil, userInfo: headerInfoDic)
    }
    
    @objc func remainingPriceChanged(_ notification: Notification) {
        
//        let remainingInfoDic: [AnyHashable: Any] = ["remainingPrice": spentPlaceTF.text!, "spentAmt": spentAmountTF.text!, "spentDate": spentDatePicker.date]
        
        guard let remainderInfo = notification.userInfo?["remainingPrice"] as? Double else { return }
        
        let remainderString = "남은 금액: " +  remainderInfo.addComma() + "원"
        
        self.remainingPriceBtn.setTitle(remainderString, for: .normal)
        
        self.remainingPriceBtn.isUserInteractionEnabled = remainderInfo != 0
        
        if remainderInfo >= 0.009 {
            // enabled // 디자인이 좀 별로임.
            self.remainingPriceBtn.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
            self.remainingPriceBtn.layer.borderWidth = 1
            self.remainingPriceBtn.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).cgColor
        } else {
            // disabled 이건 현재 괜찮은데..
            self.remainingPriceBtn.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
            
        }
    }
    
    
    @objc func changeStateToActive(_ notification: Notification) {
        print("changeStateToActive called!!")
        spentAmountTF.backgroundColor = UIColor(rgb: 0xF2F2F2)
        spentAmountTF.textColor = UIColor(white: 0.7, alpha: 1)
    }
    
    // TODO: Add Animation
    @objc func changeStateToInactive(_ notification: Notification) {
        print("changeStateToActive called!!")
        
        spentAmountTF.textColor = .black
        spentAmountTF.backgroundColor = UIColor(rgb: 0xE7E7E7)
    }
    
    @objc func updateSpentAmt(_ notification: Notification) {
        print("changeStateToActive called!!")
        guard let amtInput = notification.userInfo?["spentAmt"] as? Double else { return }
                
        spentAmountTF.text = amtInput.addComma()
    }
    
    
    private func configureLayout() {
        guard let viewModel = viewModel else { return }
        
        spentAmountTF.text = viewModel.spentAmt
        spentDatePicker.date = viewModel.spentDate
        spentPlaceTF.text = viewModel.spentPlace
        
        let remainingStr = "남은 금액: \(viewModel.remainder.addComma())원"

        remainingPriceBtn.setTitle(remainingStr, for: .normal)
        
        if viewModel.remainder >= 0.009 { // != 0 for Double
            self.remainingPriceBtn.isUserInteractionEnabled = true
            self.remainingPriceBtn.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
            self.remainingPriceBtn.layer.borderWidth = 1
            self.remainingPriceBtn.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).cgColor
        } else {
            self.remainingPriceBtn.isUserInteractionEnabled = false

            self.remainingPriceBtn.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        }
    }
    
    private func setupAddTargets() {
        dismissBtn.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        
        // not working ;;
//        spentPlaceTF.addTarget(self, action: #selector(spentPlaceTapped(_:)), for: .touchDown)
        
        spentPlaceTF.addTarget(self, action: #selector(textFieldTapped(_:)), for: .editingDidBegin)
        
        spentAmountTF.addTarget(self, action: #selector(textFieldTapped(_:)), for: .editingDidBegin)
        
        remainingPriceBtn.addTarget(self, action: #selector(remainingPriceTapped), for: .touchUpInside)
        
        spentPlaceTF.delegate = self
        spentAmountTF.delegate = self
    }
    
    // not called ;;
    @objc func textFieldTapped(_ sender: UITextField) {
        print("spentPlace Tapped!")
        
        headerDelegate?.textFieldTapAction(sender: sender, isSpentAmountTF: sender == spentAmountTF)
    }
    
    @objc func dismissTapped(_ sender: UIButton) {
        headerDelegate?.dismissAcion()
    }
    
    @objc func remainingPriceTapped(_ sender: UIButton) {
        print("remainingPriceTapped! state: \(remainingBtnTapped)")
        
        if remainingBtnTapped {
            print("updateRemainingPrice noti called ")
            NotificationCenter.default.post(name: .hideRemainingPriceSelectors, object: nil)
            remainingBtnTapped = false
        } else {
            NotificationCenter.default.post(name: .showRemainingPriceSelectors, object: nil)
            remainingBtnTapped = true
        }
    }
    
    
    
    // shouln't be btn
    private let attendedLabel = UILabel().then {
        $0.text = ASD.attended.localized
        $0.textColor = UIColor(white: 0.28, alpha: 1)
        $0.textAlignment = .center
    }
    
    private let remainingPriceBtn = UIButton().then {
        $0.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        $0.layer.cornerRadius = 8
        $0.setTitleColor(UIColor(white: 0.2, alpha: 1), for: .normal)
    }
    
    private func setupLayout() {
        
        [
            dismissBtn,
            spentPlaceLabel, spentPlaceTF,
            spentAmountLabel, spentAmountTF, currenyLabel,
            spentDateLabel,
            spentDatePicker,
            divider,
            remainingPriceBtn, attendedLabel
        ].forEach { v in
            self.addSubview(v)
        }
        
        dismissBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(10)
            
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        spentPlaceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(smallPadding * 2)
            make.top.equalTo(dismissBtn.snp.bottom).offset(30)
            make.width.equalTo(150)
            make.height.equalTo(20)
        }
        
        
        spentPlaceTF.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(spentPlaceLabel.snp.bottom).offset(5)
            make.width.equalTo(170)
            make.height.equalTo(30)
        }
        
        spentAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(smallPadding * 2)
            make.top.equalTo(spentPlaceTF.snp.bottom).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(spentAmountLabel.snp.bottom).offset(5)
            make.width.equalTo(170)
            make.height.equalTo(30)
        }
        
        currenyLabel.snp.makeConstraints { make in
            make.leading.equalTo(spentAmountTF.snp.trailing).offset(5)
            make.height.equalTo(spentAmountTF.snp.height)
            make.centerY.equalTo(spentAmountTF.snp.centerY)
            make.width.equalTo(15)
        }
        
        spentDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(smallPadding * 2)
            make.top.equalTo(spentAmountTF.snp.bottom).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        spentDatePicker.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(spentDateLabel.snp.bottom).offset(5)
            make.height.equalTo(40)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(5)
            make.width.equalTo(self.snp.width).offset(-10)
            make.height.equalTo(1)
            make.top.equalTo(spentDatePicker.snp.bottom).offset(15)
        }
        
        attendedLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.equalTo(90)
            make.top.equalTo(divider.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        remainingPriceBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalTo(attendedLabel.snp.centerY)
            make.trailing.equalTo(attendedLabel.snp.leading).offset(-10)
            make.height.equalTo(30)
        }
    }
    
    public func blinkSpentAmount() {
        
        UIView.animate(withDuration: 0.2) {
            self.spentAmountTF.backgroundColor = UIColor(white: 0.8, alpha: 1)
        } completion: { bool in
            if bool {
                UIView.animate(withDuration: 0.2) {
                    self.spentAmountTF.backgroundColor = UIColor(white: 0.9, alpha: 1)
                } completion: { bool in
                    if bool {
                        UIView.animate(withDuration: 0.2) {
                            self.spentAmountTF.backgroundColor = UIColor(white: 0.8, alpha: 1)
                        } completion: { bool in
                            if bool {
                                UIView.animate(withDuration: 0.2) {
                                    self.spentAmountTF.backgroundColor = UIColor(white: 0.9, alpha: 1)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let currenyLabel = UILabel().then { $0.text = ASD.USD.localized }
    
    private let spentPlaceLabel = UILabel().then { $0.text = ASD.spentFor.localized }
    
    
//    private let spentPlaceTF =
    public let spentPlaceTF =
    UITextField(withPadding: true).then {
        $0.textAlignment = .right
        $0.backgroundColor = UIColor(rgb: 0xE7E7E7)
        $0.tag = 1
        $0.layer.cornerRadius = 5
        $0.autocorrectionType = .no
    }
    
    private let divider = UIView().then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
    }
    
    private let spentAmountLabel = UILabel().then { $0.text = ASD.SpentAmt.localized}
    
//    public let spentAmountTF = PriceTextField(placeHolder: "비용").then {
    public let spentAmountTF = PriceTextField().then {
        $0.backgroundColor = UIColor(rgb: 0xE7E7E7)
        $0.tag = -1
        $0.isTotalPrice = true
        $0.layer.cornerRadius = 5
    }
    
    private let spentDateLabel = UILabel().then {
        $0.text = ASD.SpentDate.localized
    }
    
    private let spentDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .automatic
        picker.contentMode = .left
        picker.sizeThatFits(CGSize(width: 150, height: 40))
        return picker
    }()
    
    private let dismissBtn: UIButton = {
        let btn = UIButton()
        let imageView = UIImageView(image: UIImage(systemName: "chevron.left"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black

        btn.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }

        return btn
    }()
}



extension PersonDetailHeader: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        return true
    }
}


public enum NotificationKeys {
    static let changePriceStateIntoActive = Notification.Name(rawValue: "changePriceStateIntoActive")
    
    static let changePriceStateIntoInactive = Notification.Name(rawValue: "changePriceStateIntoInactive")
    
    static let updateSpentAmt = Notification.Name(rawValue: "updateSpentAmt")
    
    static let updateSpentPlace = Notification.Name(rawValue: "updateSpentPlace")
    
    static let notifyOtherViewTapped = Notification.Name(rawValue: "notifyOtherViewTapped")
    
    static let sendHeaderInfoBack = Notification.Name(rawValue: "sendHeaderInfoBack")
    
    static let showRemainingPriceBtn = Notification.Name(rawValue: "showRemainingPriceBtn")
    
    static let hideRemainingPriceBtn = Notification.Name(rawValue: "hideRemainingPriceBtn")
    
    static let remainingPriceChanged = Notification.Name(rawValue: "remainingPriceChanged")
}


extension Notification.Name {

    static let changePriceStateIntoActive = NotificationKeys.changePriceStateIntoActive

    static let changePriceStateIntoInactive = NotificationKeys.changePriceStateIntoInactive
    
    static let updateSpentAmt = NotificationKeys.updateSpentAmt
    
    static let notifyOtherViewTapped = NotificationKeys.notifyOtherViewTapped
    
    static let sendHeaderInfoBack = NotificationKeys.sendHeaderInfoBack
    
    static let showRemainingPriceSelectors = NotificationKeys.showRemainingPriceBtn
    
    static let hideRemainingPriceSelectors = NotificationKeys.hideRemainingPriceBtn
    
    static let remainingPriceChanged = NotificationKeys.remainingPriceChanged
}





//tapped Btn wrapper: 4
//updated value: 524
//printed from needingController: 524
//hi, 524
