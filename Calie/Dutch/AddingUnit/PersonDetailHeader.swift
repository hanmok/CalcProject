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
//    func dismissAction()
//    func spentAmtTapped()
    func textFieldTapAction(sender: UITextField, isSpentAmountTF: Bool)
    func valueUpdated(spentAmount: Double, spentPlace: String)
//    func remainingBtnTapped()
    
}


struct PersonHeaderViewModel {
    var spentAmt: String
    var spentPlace: String
    var spentDate: Date

    var remainder: Double
}

//class PersonDetailHeader: UICollectionReusableView {
class PersonDetailHeader: UIViewController {
    
    var viewModel: PersonHeaderViewModel? {
        didSet {
            configureLayout()
        }
    }
    
    var gradientLayer: CAGradientLayer?
    
//    var remainder = 0.0 {
//        didSet {
//            self.layoutSubviews()
//        }
//    }
    
    static let headerIdentifier = "HeaderIdentifier"
    
    weak var headerDelegate: PersonDetailHeaderDelegate?
    
    private let smallPadding: CGFloat = 10
    
    private let emptyView = UIView()
//        .then {
//        $0.backgroundColor = .yellow
//    }
    
    var remainderBtnTapped: Bool = false
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
//        setupLayout()
//        setupAddTargets()
//        setupNotification()
//    }
    
    override func viewDidLoad() {
//        backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
        view.backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
        setupLayout()
        setupAddTargets()
        setupNotification()
    }
    
//    override func layoutSublayers(of layer: CALayer) {
//        super.layoutSublayers(of: layer)
//
//        if remainder >= Double.minimumValue {
//
//            gradientLayer?.removeFromSuperlayer()
//
//            gradientLayer = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [
//
//                UIColor.systemBlue.cgColor,
//                UIColor.systemBlue.cgColor
//
//            ], type: .axial)
//
//            guard let gradientLayer = gradientLayer else { return }
//            gradientLayer.frame = remainderBtn.bounds
//            remainderBtn.layer.insertSublayer(gradientLayer, at: 0)
//
//        } else {
//            gradientLayer?.removeFromSuperlayer()
//
//            gradientLayer = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [
//                UIColor(white: 0.4, alpha: 0.5).cgColor,
//                UIColor(white: 0.4, alpha: 0.5).cgColor
//            ], type: .axial)
//            guard let gradientLayer = gradientLayer else { return }
//
//            gradientLayer.frame = remainderBtn.bounds
//            remainderBtn.layer.insertSublayer(gradientLayer, at: 0)
//            remainderBtn.setTitleColor(UIColor(white: 0.8, alpha: 0.5), for: .normal)
//        }
//    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeStateToActive(_:)), name: .changeSpentAmtHeaderStateIntoActive, object: nil)
        
//        self.layoutSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeStateToInactive(_:)), name: .changePriceStateIntoInactive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSpentAmt(_:)), name: .updateSpentAmt, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notifiedOtherViewTapped(_:)), name: .notifyOtherViewTapped, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(remainingPriceChanged), name: .remainingPriceChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleRemainingBtnTapped), name: .hideRemainingPriceSelectors, object: nil)
    }
    
    @objc func toggleRemainingBtnTapped(_ notification: Notification) {
        remainderBtnTapped = false
    }
    
    @objc func notifiedOtherViewTapped(_ notification: Notification) {
        
//        let headerInfoDic: [AnyHashable: Any] = ["spentPlace": spentPlaceTF.text!, "spentAmt": spentAmountLabel.text!, "spentDate": spentDatePicker.date]
        
//        NotificationCenter.default.post(name: .sendHeaderInfoBack, object: nil, userInfo: headerInfoDic)
    }
    
//    @objc func remainingPriceChanged(_ notification: Notification) {
//
//
//        guard let remainderInfo = notification.userInfo?["remainingPrice"] as? Double else { return }
//
//        remainder = remainderInfo
//
//        var remainderString: String
//
//        remainderString = UserDefaultSetup.appendProperUnit(to: remainderInfo.applyCustomNumberFormatter())
//
//        remainderBtn.setTitle("  " + remainderString, for: .normal)
//
//
//        self.remainderBtn.isUserInteractionEnabled = remainderInfo != 0
//
//        if remainderInfo >= 0.009 {
//
//            self.remainderBtn.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).cgColor
//            self.remainderBtn.isUserInteractionEnabled = true
//        } else {
//
//            self.remainderBtn.setTitleColor(UIColor(white: 0.8, alpha: 0.5), for: .normal)
//            self.remainderBtn.isUserInteractionEnabled = false
//
//        }
//
//        remainderBtn.setTitleColor(.white, for: .normal)
//
//        self.layoutSubviews()
//    }
    
    
    
    @objc func changeStateToActive(_ notification: Notification) {

        spentAmountLabel.backgroundColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.85, alpha: 1), onLight: UIColor(rgb: 0xF2F2F2))
        
        spentAmountLabel.textColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.15, alpha: 1), onLight: UIColor(white: 0.7, alpha: 1))
    }
    
    // TODO: Add Animation
    @objc func changeStateToInactive(_ notification: Notification) {

        spentAmountLabel.textColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.8, alpha: 1), onLight: .black)

        spentAmountLabel.backgroundColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.5, alpha: 1), onLight: UIColor(rgb: 0xE7E7E7))
    }
    
    @objc func updateSpentAmt(_ notification: Notification) {
        guard let amtInput = notification.userInfo?["spentAmt"] as? Double else { return }
                
        spentAmountLabel.text = UserDefaultSetup.appendProperUnit(to: amtInput.applyCustomNumberFormatter())
    }
    
    
    private func configureLayout() {
        guard let viewModel = viewModel else { return }
        
        spentAmountLabel.text = UserDefaultSetup.appendProperUnit(to: viewModel.spentAmt)
        
        spentDatePicker.date = viewModel.spentDate
        spentPlaceTF.text = viewModel.spentPlace

        let remainingStr = UserDefaultSetup.appendProperUnit(to: viewModel.remainder.applyCustomNumberFormatter())

//        remainderBtn.setTitle("  " + remainingStr, for: .normal)
        
//        if viewModel.remainder >= 0.009 { // != 0 for Double
//            self.remainderBtn.isUserInteractionEnabled = true
//
//            gradientLayer?.removeFromSuperlayer()
//
//            gradientLayer = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [
//                UIColor(white: 0.8, alpha: 0.7).cgColor,
//                UIColor(white: 0.8, alpha: 0.7).cgColor
//            ], type: .axial)
//
//            guard let gradientLayer = gradientLayer else { return }
//
//            gradientLayer.frame = remainderBtn.bounds
//            remainderBtn.layer.insertSublayer(gradientLayer, at: 0)
//
//            self.remainderBtn.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).cgColor
//        } else {
//
//            self.remainderBtn.isUserInteractionEnabled = false
//
//            gradientLayer?.removeFromSuperlayer()
//
//            gradientLayer = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [
//                UIColor(white: 0.8, alpha: 0.7).cgColor,
//                UIColor(white: 0.8, alpha: 0.7).cgColor
//            ], type: .axial)
//            guard let gradientLayer = gradientLayer else { return }
//
//            gradientLayer.frame = remainderBtn.bounds
//            remainderBtn.layer.insertSublayer(gradientLayer, at: 0)
//
//        }
    }
    
    private func setupAddTargets() {
//        dismissBtn.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        
        spentPlaceTF.addTarget(self, action: #selector(textFieldTapped(_:)), for: .editingDidBegin)
        
//        spentAmountLabel.addTarget(self, action: #selector(textFieldTapped(_:)), for: .editingDidBegin)
        
//        remainderBtn.addTarget(self, action: #selector(remainingPriceTapped), for: .touchUpInside)
        
        spentPlaceTF.delegate = self
//        spentAmountLabel.delegate = self
    }
    
    // not called ;;
    @objc func textFieldTapped(_ sender: UITextField) {
        
        headerDelegate?.textFieldTapAction(sender: sender, isSpentAmountTF: sender == spentAmountLabel)
    }
    
    private let attendedLabel = UILabel().then {
        $0.text = ASD.attended.localized

        $0.textColor = UserDefaultSetup.applyColor(onDark: .resultTextDM, onLight: .resultTextLM)
        $0.textAlignment = .center
    }
    
    
    private func setupLayout() {
//        backgroundColor = .magenta
        [
//            dismissBtn,
            spentPlaceLabel, spentPlaceTF,
            spentAmountLabel, spentAmountLabel,
            spentDateLabel,
            spentDatePicker,
            divider,
//            remainderTextLabel ,remainderBtn, attendedLabel,
//            bottomLine
        ].forEach { v in
//            self.addSubview(v)
            self.view.addSubview(v)
        }
        
       
        
        spentPlaceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(smallPadding * 2)
//            make.top.equalTo(dismissBtn.snp.bottom).offset(30)
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
        
        spentAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(spentAmountLabel.snp.bottom).offset(5)
            make.width.equalTo(170)
            make.height.equalTo(30)
        }
        
        
        spentDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(smallPadding * 2)
            make.top.equalTo(spentAmountLabel.snp.bottom).offset(20)
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
//            make.width.equalTo(self.snp.width).offset(-10)
            make.width.equalToSuperview().offset(-10)
            make.height.equalTo(1)
            make.top.equalTo(spentDatePicker.snp.bottom).offset(15)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 지출 항목
    private let spentPlaceLabel = UILabel().then {
        $0.text = ASD.spentFor.localized
//        $0.textColor = UserDefaultSetup.applyColor(onDark: .semiResultTextDM, onLight: .semiResultTextLM)
        if UserDefaultSetup().darkModeOn {
            $0.textColor = .semiResultTextDM
        }
    }
    
    

    /// 지출 항목 TextField
    public let spentPlaceTF =
    UITextField(withPadding: true).then {
        $0.textAlignment = .right

        $0.backgroundColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.5, alpha: 1), onLight: UIColor(rgb: 0xE7E7E7))
        
        $0.textColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.8, alpha: 1), onLight: .black)
        $0.tag = 1
        $0.layer.cornerRadius = 5
        $0.autocorrectionType = .no
        
    }
    
    private let divider = UIView().then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
    }
    /// 지출 금액
    private let spentAmountGuideLabel = UILabel().then {
        $0.text = ASD.spentAmt.localized

        if UserDefaultSetup().darkModeOn {
            $0.textColor = .semiResultTextDM
        }
    }
    
/// 지출 금액 TF
    public let spentAmountLabel = PriceTextField().then {

        $0.backgroundColor = UserDefaultSetup.applyColor(onDark: .extrasBGLight, onLight: UIColor(rgb: 0xE7E7E7))
        $0.tag = -1
        $0.isTotalPrice = true
        $0.layer.cornerRadius = 5
    }
    
    private let spentDateLabel = UILabel().then {
        $0.text = ASD.spentDate.localized
        if UserDefaultSetup().darkModeOn {
            $0.textColor = .semiResultTextDM
        }
    }
    
    private let spentDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .automatic
        picker.contentMode = .left
        picker.sizeThatFits(CGSize(width: 150, height: 40))
        
        if UserDefaultSetup().darkModeOn {
            picker.backgroundColor = .gray
        }
        
        picker.layer.cornerRadius = 8
        picker.clipsToBounds = true
        return picker
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

    static let changeSpentAmtHeaderStateIntoActive = NotificationKeys.changePriceStateIntoActive

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

//class SummaryBoxController {
//
//}
