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
//    func
}

protocol AddingUnitNavDelegate: AnyObject {
    func dismissWithInfo(dutchUnit: DutchUnit2)
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
    weak var navDelegate: AddingUnitNavDelegate?
    
    private var spentAmount: Double = 0
    
    private var sumOfIndividual: Double = 0
    private var textFieldWithPriceDic: [Int : Double] = [:]
    private var attendingDic: [Int: Bool] = [:]
    private var isConditionSatisfied = false
    
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
        $0.isTotalPrice = true
    }
    
    
    private let spentDateLabel = UILabel().then { $0.text = "지출 시각"}
    private let spentDatePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .compact
        $0.locale = Locale(identifier: "ko-KR")
        $0.datePickerMode = .dateAndTime
    }
    
    private let personDetailCollectionView: UICollectionView = {
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
//        $0.setBackgroundImage(, for: <#T##UIControl.State#>)
        $0.backgroundColor = .gray
        $0.isUserInteractionEnabled = false
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
        
        personDetailCollectionView.reloadData()
    }
    
    
    private func registerCollectionView() {
        personDetailCollectionView.register(PersonDetailCell.self, forCellWithReuseIdentifier: cellIdentifier)
        personDetailCollectionView.delegate = self
        personDetailCollectionView.dataSource = self
    }
    
    private func setupLayout() {
        
        [spentPlaceLabel, spentPlaceTF,
         spentAmountLabel, spentAmountTF,
         spentDateLabel, spentDatePicker,
         personDetailCollectionView,
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
        
        
        personDetailCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(spentDateLabel.snp.bottom).offset(20)
            make.height.equalTo(60 * participants.count - 10)
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
        // send data to the next screen ?? no next screen... ;;
//        personDetails
        let peopleNames = participants.map { $0.name }
        
//        for (personIndex, person) in participants {
        for personIndex in 0 ..< participants.count {
            
            personDetails.append(PersonDetail2(
                person: Person2(peopleNames[personIndex]),
                spentAmount: textFieldWithPriceDic[personIndex] ?? 0,
                isAttended: attendingDic[personIndex] ?? true)
            )
        }
        
        dutchUnit = DutchUnit2(
            placeName: spentPlaceTF.text!,
            spentAmount: spentAmount,
            date: spentDatePicker.date,
            personDetails: personDetails
        )
        
        navDelegate?.dismissWithInfo(dutchUnit: dutchUnit!)
    }
    
    
    @objc func dismissKeyboard() {
        print("dismissKeyboard triggered!!")
        completeAction()
        numberController.numberText = ""
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
    
    func completeAction() {
        guard let tf = selectedPriceTF else { return }
        
        if tf.isTotalPrice {
            spentAmount = tf.text!.convertToDouble()
        print("spentAmount: \(spentAmount)")
        } else {
            textFieldWithPriceDic[tf.tag] = tf.text!.convertToDouble()
            
            sumOfIndividual = 0
            for (tag, number) in textFieldWithPriceDic {
                print("uuid: \(tag), number: \(number)")
                sumOfIndividual += number
            }
            
            // if sumOfIndividual is larger than spentAmount,
            // update spentAmount with corresponding textField
            if spentAmount < sumOfIndividual {
                spentAmount = sumOfIndividual
                var str = String(spentAmount)
                str.applyNumberFormatter()
                spentAmountTF.text = str
            }
        }

       
        // if sumofIndividual and spent amount is the same,
        // && if that amount is not 0 -> enable 'confirm' btn.
        isConditionSatisfied = (sumOfIndividual == spentAmount) && (sumOfIndividual != 0)
        
        setupConfirmBtn(condition: isConditionSatisfied)
        
        hideNumberController()
    }
    
    private func setupConfirmBtn(condition: Bool) {
        confirmBtn.isUserInteractionEnabled = condition
        confirmBtn.backgroundColor = condition ? .white : .gray
    }
}



// MARK: - UICOllectionView Delegates
extension AddingUnitController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PersonDetailCell
        
        cell.spentAmountTF.tag = indexPath.row
        cell.attendingBtn.tag = indexPath.row
        cell.fullPriceBtn.tag = indexPath.row
        
        cell.spentAmountTF.delegate = self
        
        cell.delegate = self
        
        
        cell.viewModel = PersonDetailViewModel(personDetail: personDetails[indexPath.row])
        
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
    
    
    func cell(_ cell: PersonDetailCell, isAttending: Bool) {
        print("didTapAttended triggered")
    }
    
    func updateAttendingState(with tag: Int, to isAttending: Bool) {
        attendingDic[tag] = isAttending
    }
    
    func cell(_ cell: PersonDetailCell, from peopleIndex: Int) {
        
        for (tag, amount) in textFieldWithPriceDic {
            print("tag: \(tag), amount: \(amount)")
        }

        let prev = textFieldWithPriceDic[peopleIndex] ?? 0
        
        let remaining = spentAmount - sumOfIndividual - prev
        print("currentIndex: \(peopleIndex)")
        print("spentAmount: \(spentAmount), sumOfIndividual: \(sumOfIndividual), prev: \(prev), remaining: \(remaining)")
        
        if remaining != 0 {
            textFieldWithPriceDic[peopleIndex] = remaining

            var strRemaining = String(remaining)
            strRemaining.applyNumberFormatter()
            cell.spentAmountTF.text = strRemaining

        }
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
        
//        textField.selectAll(self)
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
    }
}




extension AddingUnitController: CustomNumberPadDelegate {
    
    func numberPadView(updateWith numTextInput: String) {
        print("numberPadUpdateWith triggered")
        print("text: \(numTextInput)")
        guard let tf = selectedPriceTF else { return }
        
        tf.text = numTextInput
    }
    
    
    func numberPadViewShouldReturn() {
        print("Complete has been pressed!")
        // TODO: Dismiss CustomPad ! or.. move to the bottom to not be seen.
      
        completeAction()
    }
}
