//
//  AddingUnitController.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/28.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit
import Then

/*
struct PersonDetail2 {
    var person: Person2
    var spentAmount: Double = 0
    var isAttended: Bool = true
}
*/

protocol AddingUnitControllerDelegate: AnyObject {
    func dismissChildVC()
}


class AddingUnitController: UIViewController {
    
    // MARK: - Properties
    
    private let cellIdentifier = "PersonDetailCell"
    
    let participants: [Person2]
    
    var dutchUnit: DutchUnit2?
    var personDetails: [PersonDetail2] = []
    var selectedPriceTF: PriceTextField?
    
    private let numberController = CustomNumberPadController()
    
    weak var delegate: AddingUnitControllerDelegate?
    
    
    private let spentPlaceLabel = UILabel().then { $0.text = "Spent To"}
    
    private let spentPlaceTF = UITextField().then {
        $0.placeholder = "지출한 곳을 입력해주세요."
        $0.textAlignment = .center
        $0.backgroundColor = .yellow
        $0.tag = 1
    }
    
    
    private let spentAmountLabel = UILabel().then { $0.text = "Spent Amount"}
    
    private let spentAmountTF = PriceTextField(placeHolder: "지출 비용").then {
        $0.backgroundColor = .magenta
        $0.tag = 2
    }
    
    
    private let spentDateLabel = UILabel().then { $0.text = "지출 시각"}
    private let spentDatePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .compact
        $0.locale = Locale(identifier: "ko-KR")
        $0.datePickerMode = .dateAndTime
    }
    
    private let payCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    
    private let cancelBtn = UIButton().then {
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        $0.addBorders(edges: [.top], color: .black)
    }
    
    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.addBorders(edges: [.top, .left], color: .black)
    }
    
    
    
    
    
    
    init(participants: [Person2]) {
        self.participants = participants
        super.init(nibName: nil, bundle: nil)
        initializePersonDetails()
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Recognizer for resigning keyboards
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        registerCollectionView()
        setupLayout()
        setupTargets()
        initializePersonDetails()
        prepareNumberController()
        
        payCollectionView.reloadData()
    }
    
    
    private func registerCollectionView() {
        payCollectionView.register(PersonDetailCell.self, forCellWithReuseIdentifier: cellIdentifier)
        payCollectionView.delegate = self
        payCollectionView.dataSource = self
    }
    
    
    private func setupLayout() {
        
        [spentPlaceLabel, spentPlaceTF,
         spentAmountLabel, spentAmountTF,
         spentDateLabel, spentDatePicker,
         payCollectionView,
         cancelBtn, confirmBtn
        ].forEach { v in
            self.view.addSubview(v)
        }
        
        spentPlaceTF.delegate = self
        spentAmountTF.delegate = self
        
        spentPlaceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        spentPlaceTF.snp.makeConstraints { make in
            make.leading.equalTo(spentPlaceLabel.snp.trailing).offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(30)
        }
        
        
        spentAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(spentPlaceLabel.snp.bottom).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalTo(spentAmountLabel.snp.trailing).offset(20)
            make.top.equalTo(spentPlaceLabel.snp.bottom).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(30)
        }
        
        
        spentDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(spentAmountLabel.snp.bottom).offset(20)
            make.width.equalTo(70)
            make.height.equalTo(50)
        }
        
        spentDatePicker.snp.makeConstraints { make in
            make.leading.equalTo(spentDateLabel.snp.trailing).offset(20)
            make.top.equalTo(spentAmountLabel.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        
        payCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(spentDateLabel.snp.bottom).offset(20)
            make.height.equalTo(60 * participants.count - 10)
//            make.height.equalTo(300)
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.bottom.equalTo(view)
            make.width.equalTo(view.snp.width).dividedBy(2)
            make.height.equalTo(50)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view)
            make.width.equalTo(view.snp.width).dividedBy(2)
            make.height.equalTo(50)
        }
    }
    
    private func setupTargets() {
        cancelBtn.addTarget(nil, action: #selector(cancelTapped(_:)), for: .touchUpInside)
        confirmBtn.addTarget(nil, action: #selector(confirmTapped(_:)), for: .touchUpInside)
    }
    
    
    @objc func cancelTapped(_ sender: UIButton) {
        print("cancel action")
        
        delegate?.dismissChildVC()
    }
    
    @objc func confirmTapped(_ sender: UIButton) {
        print("success action")
    }
    
    
    @objc func dismissKeyboard() {
        print("dismissKeyboard triggered!!")
        view.endEditing(true)
        hideNumberController()
    }
    
    func dismissKeyboardOnly() {
        view.endEditing(true)
    }
    
    // MARK: - .. ??
    private func initializePersonDetails() {
        participants.forEach { person in
            self.personDetails.append(PersonDetail2(person: person))
        }
    }
    
    private func prepareNumberController() {
        numberController.delegate = self
        addChild(numberController)
        view.addSubview(numberController.view)
        self.numberController.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 360)
    }
    
    private func showNumberController() {
        UIView.animate(withDuration: 0.4) {
            self.numberController.view.frame = CGRect(x: 0, y: UIScreen.height - 360, width: UIScreen.width, height: 360)
        }
    }
    
    private func hideNumberController() {
        UIView.animate(withDuration: 0.4) {
            self.numberController.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 360)
        }
    }
    
    
    @objc func fullPriceTapped(_ sender: UIButton) {
        print("fullPriceTapped")
    }
    
    @objc func attendedTapped(_ sender: UIButton) {
        print("attended Btn Tapped")
    }
    
    @objc func textDidBegin(_ textField: UITextField) {
        if textField == spentAmountTF {
            print("it's spentAmountTF")
        } else if textField == spentPlaceTF {
            print("it's spentPlaceTF")
        }
        
        print("tag: \(textField.tag)")
        if let tf = textField as? PriceTextField {
            print("tag: \(tf.tag)")
            print("it's pricetextfield!, textDidBegin")
        } else {
            print("it's not priceTextField!")
        }
    }
    
    @objc func textDidChange(_ textField: PriceTextField) {
        print("tag: \(textField.tag)")
        if let tf = textField as? PriceTextField {
            print("tag: \(tf.tag)")
            print("it's pricetextfield!, textDidChange")
        } else {
            print("it's not priceTextField!")
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - UICOllectionView Delegates
extension AddingUnitController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PersonDetailCell
        
        cell.spentAmountTF.delegate = self
        
        cell.delegate = self

        cell.contentView.isUserInteractionEnabled = false
        cell.fullPriceBtn.addTarget(self, action: #selector(fullPriceTapped(_:)), for: .touchUpInside)
        cell.attendedBtn.addTarget(self, action: #selector(attendedTapped(_:)), for: .touchUpInside)
        print("numberOfParticipants: \(participants.count)")
//        let name = participants[indexPath.row].name
//        let spentAmount: Double = Double(spentAmountTF.text ?? "0") ?? 0.0
        cell.viewModel = PersonDetailViewModel(personDetail: personDetails[indexPath.row])
        print("cell loaded !!")
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

// MARK: - PersonDetailCell Delegate
extension AddingUnitController: PersonDetailCellDelegate {
    func showUpNumberPad() {
        
    }
    
    func hideNumberpad() {
        
    }
    
    func cell(_ cell: PersonDetailCell, didTapFullPrice: Bool) {
        print("didTapFullPrice triggered")
    }
    
    func cell(_ cell: PersonDetailCell, didTapAttended: Bool) {
        print("didTapAttended triggered")
    }
    
    
}




// MARK: - TextField Delegate
// Type 이 달라서 호출이 안되는 것 같은데 ??
// PriceTextFieldDelegate 이라서 ... ;;
extension AddingUnitController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == spentPlaceTF {
            spentAmountTF.becomeFirstResponder()
        }
        return true
    }
    
    //    func textFieldDidBeginEditing(_ textField: UITextField) {
    //        if let tf = textField as? PriceTextField {
    //            print("tag: \(tf.tag)")
    //            textField.resignFirstResponder()
    //        }
    //
    //        print("textFieldTag: \(textField.tag)")
    //
    //        self.dismissKeyboardOnly()
    //        print("textFieldDidBeginEditing textField called")
    //    }
    //    textfielddidbegin
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if let tf = textField as? PriceTextField {
            self.dismissKeyboardOnly()
            showNumberController()
            selectedPriceTF = tf
            print("tag : \(textField.tag)")
            print("textField: \(textField)")
            return false
        } else {
            hideNumberController()
            print("tag : \(textField.tag)")
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.text =
    }
}




extension AddingUnitController: CustomNumberPadDelegate {
    
    func numberPadView(updateWith numTextInput: String) {
        print("text: \(numTextInput)")
        guard let tf = selectedPriceTF else { return }
        tf.text = numTextInput
    }
    
    
    func numberPadViewShouldReturn() {
        print("Complete has been pressed!")
        // TODO: Dismiss CustomPad ! or.. move to the bottom to not be seen.
        hideNumberController()
        
    }

    func numberPadView(updateWith numTextInput: String, textField: UITextField) {
        print("text: \(numTextInput)")
        // update textField with text
        
    }
}
