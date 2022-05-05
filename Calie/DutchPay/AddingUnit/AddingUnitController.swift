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

private let cellIdentifier = "PersonDetailCell"

protocol AddingUnitControllerDelegate: AnyObject {
    func dismissChildVC()
}

class AddingUnitController: UIViewController {
    
    let participants: [Person2]
    
    var dutchUnit: DutchUnit2?
    var personDetails: [PersonDetail2] = []
    
    weak var delegate: AddingUnitControllerDelegate?
    private let spentToLabel = UILabel().then { $0.text = "Spent To"}
    private let spentPlaceTF = UITextField().then {
        $0.placeholder = "지출한 곳을 입력해주세요."
        $0.textAlignment = .center
    }
    
    private let spentAmount = UILabel().then { $0.text = "Spent Amount"}
    
    private let spentAmountTF = PriceTextField(placeHolder: "지출 비용")
    
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
        $0.addTarget(nil, action: #selector(cancelTapped(_:)), for: .touchUpInside)
    }
    
    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.addBorders(edges: [.top, .left], color: .black)
        $0.addTarget(nil, action: #selector(nextTapped(_:)), for: .touchUpInside)
    }
    
    private let numberController = CustomNumberPadController()
    
    private func prepareNumberController() {
        numberController.delegate = self
        addChild(numberController)
        view.addSubview(numberController.view)
        self.numberController.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 360)
    }
    
    @objc func cancelTapped(_ sender: UIButton) {
        print("cancel action")
        
        delegate?.dismissChildVC()
    }
    
    @objc func nextTapped(_ sender: UIButton) {
        print("success action")
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        setupLayout()
        initializePersonDetails()
        prepareNumberController()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // sequence : Init -> viewDidLoad
    init(participants: [Person2]) {
        self.participants = participants
        super.init(nibName: nil, bundle: nil)
    }
    
    private func initializePersonDetails() {
        participants.forEach { person in
            self.personDetails.append(PersonDetail2(person: person))
        }
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
    
    
    private func setupLayout() {
        [spentToLabel, spentPlaceTF,
         spentAmount, spentAmountTF,
         spentDateLabel, spentDatePicker,
         payCollectionView
        ].forEach { v in
            self.view.addSubview(v)
        }
        
        spentPlaceTF.delegate = self
        spentAmountTF.delegate = self
        
        
        spentToLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
        
        spentPlaceTF.snp.makeConstraints { make in
            make.leading.equalTo(spentToLabel.snp.trailing).offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(30)
        }
        
        
        spentAmount.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(spentToLabel.snp.bottom).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalTo(spentAmount.snp.trailing).offset(20)
            make.top.equalTo(spentToLabel.snp.bottom).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(30)
        }
        
        
        
        spentDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(spentAmount.snp.bottom).offset(20)
            make.width.equalTo(70)
            make.height.equalTo(50)
        }
        
        spentDatePicker.snp.makeConstraints { make in
            make.leading.equalTo(spentDateLabel.snp.trailing).offset(20)
            make.top.equalTo(spentAmount.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        payCollectionView.register(PersonDetailCVCell.self, forCellWithReuseIdentifier: cellIdentifier)
        payCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(spentDateLabel.snp.bottom).offset(20)
            make.height.equalTo(60 * participants.count - 10)
        }
        
        payCollectionView.delegate = self
        payCollectionView.dataSource = self
        
        
        let btns = [confirmBtn, cancelBtn]
        
        btns.forEach { btn in
            view.addSubview(btn)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PersonDetailCVCell
        print("numberOfParticipants: \(participants.count)")
        let name = participants[indexPath.row].name
        let spentAmount: Double = Double(spentAmountTF.text ?? "0") ?? 0.0
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







extension AddingUnitController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == spentPlaceTF {
            spentAmountTF.becomeFirstResponder()
        }
        return true
    }
}



extension AddingUnitController: CustomNumberPadDelegate {
    
    func numberPadViewShouldReturn() {
        print("Complete has been pressed!")
        // TODO: Dismiss CustomPad ! or.. move to the bottom to not be seen.
        hideNumberController()
        
    }
    
    func numberPadView(updateWith numTextInput: String) {
        print("text: \(numTextInput)")
        // update textField with text
    }
    
}
