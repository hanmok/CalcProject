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

protocol AddingUnitControllerDelegate: AnyObject {
    func dismissChildVC()
}

protocol DutchUnitDelegate: AnyObject {
    func updateDutchUnit(_ dutchUnit: DutchUnit, isNew: Bool)
}

class DutchUnitController: NeedingController {
    
    // MARK: - Properties
    
    private let smallPadding: CGFloat = 10
    
    var viewModel: DutchUnitViewModel
    
    private let cellIdentifier = "PersonDetailCell"
    
    weak var needingDelegate: NeedingControllerDelegate?
    /// 10
    /// 
   
    weak var addingDelegate: AddingUnitControllerDelegate?
    
    var dutchUnit: DutchUnit?
    var gathering: Gathering
    
    var selectedPriceTF: PriceTextField?

    weak var dutchDelegate: DutchUnitDelegate?
    
    
    
    var detailPriceDic: [Int: Double] = [:] {
        willSet {
            var sum = 0.0
            for (_, value2) in newValue.enumerated() {
                sum += value2.value
            }
            sumOfIndividual = sum
            print("detailPriceDic updated \(newValue)")
        }
        didSet {
            print("umm")
        }
    }
    
    var spentAmount: Double = 0 {
        willSet {
            let condition = (sumOfIndividual == newValue) && (newValue != 0)
            updateConditionState(condition)
            print("spentAmount updated \(newValue)")
        }
    }
    
    var sumOfIndividual: Double = 0 {
        willSet {
        let condition = (newValue == spentAmount) && (newValue != 0)
            updateConditionState(condition)
            print("sumOfIndividual updated \(newValue)")
        }
    }
    
    
    init(
        initialDutchUnit: DutchUnit? = nil,
        gathering: Gathering
    ) {
        self.viewModel = DutchUnitViewModel(selectedDutchUnit: initialDutchUnit, gathering: gathering)
        self.dutchUnit = initialDutchUnit
        self.gathering = gathering
        viewModel.initializePersonDetails(gathering: gathering, dutchUnit: initialDutchUnit)
        
        super.init(nibName: nil, bundle: nil)
//        initializePersonDetails(initialDutchUnit: initialDutchUnit)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /// set DetailPriceDic if viewDidLoad
    private func setupDictionary() {
        
        for idx in 0 ..< viewModel.personDetails.count {
            detailPriceDic[idx] = viewModel.personDetails[idx].spentAmount
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("initializing personDetails flag 3")
        view.backgroundColor = .white
        
        setupBindings()
        
        viewModel.initializePersonDetails(gathering: gathering, dutchUnit: dutchUnit)
        
        print("flag 5, currentPersonDetails: \(viewModel.personDetails.count)")
        
        setupDictionary()
        
        setupLayout()
        setupTargets()
        
        setupCollectionView()



        
        viewModel.setupInitialState { [weak self] initialState, newDutchUnitIndex in
            guard let self = self else { return }
            if let initialState = initialState {
                self.spentPlaceTF.text = initialState.place
                self.spentAmountTF.text = initialState.amount
                self.spentDatePicker.date = initialState.date
            } else {
                guard let numOfElements = newDutchUnitIndex else {return }
                // TODO: Setup PlaceHolder? // 이미 되어있어야함.
                self.spentPlaceTF.text = "항목 \(numOfElements)"
            }
        }
        
        viewModel.setupInitialCells { [weak self] cells in
            guard let self = self else { return }
//            DispatchQueue
        }
        
        updateConditionState = { [weak self] condition in
            print("current condition: \(condition)")
            guard let self = self else { return }
            self.confirmBtn.isUserInteractionEnabled = condition
            self.confirmBtn.backgroundColor = condition ? .green : .orange
        }
        
        
        // Recognizer for resigning keyboards
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(otherViewTapped))
        
//        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(tap2)
        
    }
    
    @objc func otherViewTapped() {
//        UIInputViewController.dismissKeyboard(UIInputViewController)
        guard let selectedPriceTF = selectedPriceTF else {
            return
        }
        
        let currentText = selectedPriceTF.text!
        
        if selectedPriceTF.tag == -1 {
            spentAmount = currentText.convertToDouble()
        } else { //
            detailPriceDic[selectedPriceTF.tag] = currentText.convertToDouble()
        }
        print("otherView Tapped!!")
        dismissKeyboard()
    }
    
    var updateConditionState: (Bool) -> Void = { _ in }
    
    private func setupBindings() {
        
        viewModel.updateCollectionView = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.personDetailCollectionView.reloadData()
            }
            print("initializing personDetails flag 4")
            print("numOfDetails: \(self.viewModel.personDetails.count)")
        }
    }
    
    
    private func setupTargets() {
        resetBtn.addTarget(self, action: #selector(resetState), for: .touchUpInside)
        addPersonBtn.addTarget(self, action: #selector(presentAddingPeopleAlert), for: .touchUpInside)
        dismissBtn.addTarget(nil, action: #selector(dismissTapped), for: .touchUpInside)
        confirmBtn.addTarget(nil, action: #selector(confirmTapped), for: .touchUpInside)
    }
    
    

    @objc private func presentAddingPeopleAlert() {
        let alertController = UIAlertController(title: "Add People", message: "추가할 사람의 이름을 입력해주세요", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Name"
            textField.tag = 100
            textField.delegate = self
        }
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { [self] alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
        
            let newPersonName = textFieldInput.text!
            
            addPersonAction(with: newPersonName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
    
    

    @objc func resetState() {
        viewModel.reset {
            DispatchQueue.main.async {
                self.personDetailCollectionView.snp.remakeConstraints { make in
                    make.leading.equalToSuperview().inset(self.smallPadding)
                    make.trailing.equalToSuperview().inset(self.smallPadding)
                    make.top.equalTo(self.divider.snp.bottom).offset(30)
//                    make.height.equalTo(50 * self.viewModel.participantsNames.count - 20)
                    make.height.equalTo(50 * self.viewModel.participants.count - 20)
                }
                
                self.resetBtn.snp.makeConstraints { make in
                    make.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
                    make.width.equalTo(80)
                    make.height.equalTo(40)
                    make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
                }
                
                self.addPersonBtn.snp.makeConstraints { make in
                    make.leading.equalToSuperview().inset(self.smallPadding * 1.5)
                    make.trailing.equalTo(self.resetBtn.snp.leading).offset(-10)
                    make.height.equalTo(40)
                    make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
                }
            }
        }
    }
    
    @objc func dismissTapped() {
        addingDelegate?.dismissChildVC()
        self.dismiss(animated: true)
    }
    
    
    
    @objc func confirmTapped() {
        
        viewModel.updateDutchUnit(spentPlace: spentPlaceTF.text!,
                                  spentAmount: spentAmount,
                                  spentDate: Date(),
                                  detailPriceDic: detailPriceDic) { [weak self] in
            
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            self.needingDelegate?.dismissNumberLayer()
        }
        
    }
    
    
    override func fullPriceAction2() {
        print("fullprice from addingUnitController!")
        guard let selectedPriceTF = selectedPriceTF else {
            fatalError()
        }
        
        let totalAmount = spentAmountTF.text!.convertNumStrToDouble()
        
        //        sumOfIndividual = 0
        
        //        for (tag, number) in textFieldWithPriceDic {
        //            print("tag: \(tag), number: \(number)")
        //            sumOfIndividual += number
        //        }
        
        //        var costRemaining = spentAmount - sumOfIndividual
        
        //        costRemaining -= selectedPriceTF.text!.convertNumStrToDouble()
        
        //        let remainingStr = costRemaining.addComma()
        //        textFieldWithPriceDic[selectedPriceTF.tag] = costRemaining
        
        //        self.viewModel.personDetails[selectedPriceTF.tag].spentAmount = costRemaining
        
        //        selectedPriceTF.text = remainingStr
        
    }
    
    
    override func updateNumber(with numberText: String) {
        print("hi, \(numberText)")
        
        guard let selectedPriceTF = selectedPriceTF else {
            return
        }
        
        selectedPriceTF.text = numberText
        
        let selectedTag = selectedPriceTF.tag
        
        //        switch selectedTag {
        //        case -1: spentAmount = numberText.convertStrToDouble()
        //        default:
        //            textFieldWithPriceDic[selectedTag] = numberText.convertStrToDouble()
        //            viewModel.personDetails[selectedTag].spentAmount = numberText.convertStrToDouble()
        //        }
        
    }
    
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
        needingDelegate?.hideNumberPad()
    }
    
    func dismissKeyboardOnly() {
        view.endEditing(true)
    }
    
    
    @objc func textDidBegin(_ textField: UITextField) {
        if textField == spentAmountTF {
            print("it's spentAmountTF")
        } else if textField == spentPlaceTF {
            print("it's spentPlaceTF")
        }
        
        
        if let tf = textField as? PriceTextField {
            print("tag: \(tf.tag)")
            print("it's pricetextfield!, textDidBegin")
        } else {
            print("it's not priceTextField!")
        }
    }
    
    
    
    
    private func addPersonAction(with newName: String) {
        guard newName.count != 0 else { fatalError("Name must have at least one character") }
        
        viewModel.addPerson(name: newName) { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let msg):
//                 participantsNames
                
                self.showToast(message: msg, defaultWidthSize: self.screenWidth, defaultHeightSize: self.screenHeight, widthRatio: 0.9, heightRatio: 0.025, fontsize: 16)
                
                DispatchQueue.main.async {
                    self.personDetailCollectionView.reloadData()
                    
                    self.personDetailCollectionView.snp.remakeConstraints { make in
                        make.leading.equalToSuperview().inset(self.smallPadding)
                        make.trailing.equalToSuperview().inset(self.smallPadding)
                        make.top.equalTo(self.divider.snp.bottom).offset(30)
//                        make.height.equalTo(50 * self.viewModel.participantsNames.count - 20)
                        make.height.equalTo(50 * self.viewModel.participants.count - 20)
                    }
                    
                    self.resetBtn.snp.makeConstraints { make in
                        make.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
                        make.width.equalTo(80)
                        make.height.equalTo(40)
                        make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
                        
                    }
                    
                    self.addPersonBtn.snp.makeConstraints { make in
                        make.leading.equalToSuperview().inset(self.smallPadding * 1.5)
                        make.trailing.equalTo(self.resetBtn.snp.leading).offset(-10)
                        make.height.equalTo(40)
                        make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
                    }
                }
                
            case .failure(let errorMsg):
                print("duplicate flag 3")
                self.showToast(message: errorMsg.localizedDescription, defaultWidthSize: self.screenWidth, defaultHeightSize: self.screenHeight, widthRatio: 0.9, heightRatio: 0.025, fontsize: 16)
            }
        }
    }
    
    
    private func setupCollectionView() {
        personDetailCollectionView.register(PersonDetailCell.self, forCellWithReuseIdentifier: cellIdentifier)
        personDetailCollectionView.delegate = self
        personDetailCollectionView.dataSource = self
        
        DispatchQueue.main.async {
            self.personDetailCollectionView.reloadData()
        }
    }
    
    private func setupLayout() {
        
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
        [
            dismissBtn,
            spentPlaceLabel, spentPlaceTF,
            spentAmountLabel, spentAmountTF, currenyLabel,
            spentDateLabel,
            spentDatePicker,
            divider,
            personDetailCollectionView,
            resetBtn, addPersonBtn,
            confirmBtn
        ].forEach { v in
            self.view.addSubview(v)
        }
        
        spentPlaceTF.delegate = self
        spentAmountTF.delegate = self
        
        dismissBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(30)
            make.width.equalTo(15)
        }
        
        spentPlaceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(smallPadding * 2)
            make.top.equalTo(dismissBtn.snp.bottom).offset(20)
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
        
        
        spentDatePicker.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(2) // prev: 1.5
            make.top.equalTo(spentAmountTF.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(15)
            make.height.equalTo(40)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
            make.height.equalTo(1)
            make.top.equalTo(spentDatePicker.snp.bottom).offset(15)
        }
        
        
        personDetailCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(smallPadding)
            make.trailing.equalToSuperview().inset(smallPadding)
            make.top.equalTo(divider.snp.bottom).offset(30)
//            make.height.equalTo(45 * viewModel.participantsNames.count - 20)
            make.height.equalTo(45 * viewModel.participants.count - 20)
        }
        
        resetBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(smallPadding * 1.5)
            make.width.equalTo(80)
            make.height.equalTo(40)
            make.top.equalTo(personDetailCollectionView.snp.bottom).offset(15)
            
        }
        
        addPersonBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(smallPadding * 1.5)
            make.trailing.equalTo(resetBtn.snp.leading).offset(-10)
            make.height.equalTo(40)
            make.top.equalTo(personDetailCollectionView.snp.bottom).offset(15)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view).inset(20)
            make.width.equalTo(view.snp.width).dividedBy(2)
            make.height.equalTo(50)
        }
    }
    
    
    // MARK: - UI Properties
    
    private let currenyLabel = UILabel().then {
        $0.text = "원"
    }
    
    private let spentPlaceLabel = UILabel().then {
        $0.text = "지출 항목"}
    
    
    private let spentPlaceTF = UITextField(withPadding: true).then {
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
    
    private let spentAmountLabel = UILabel().then { $0.text = "지출 금액"}
    
    private let spentAmountTF = PriceTextField(placeHolder: "비용").then {
        $0.backgroundColor = UIColor(rgb: 0xE7E7E7)
        $0.tag = -1
        $0.isTotalPrice = true
        $0.layer.cornerRadius = 5
    }
    
    private let spentDateLabel = UILabel().then {
        $0.textAlignment = .right
    }
    
    private let spentDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.sizeToFit()
//        picker.semanticContentAttribute = .forceRightToLeft
//        picker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        picker.semanticContentAttribute = .forceLeftToRight
        return picker
    }()
    
    private let personDetailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    
    
    private let dismissBtn: UIButton = {
        let btn = UIButton()
        let imageView = UIImageView(image: UIImage(systemName: "chevron.left"))
        imageView.contentMode = .scaleToFill
        btn.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        return btn
    }()
    
    private let addPersonBtn = UIButton().then {
        
        $0.setTitle("인원 추가", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor(white: 0.8, alpha: 1)
    }
    
    private let resetBtn = UIButton().then {
        $0.setTitle("초기화", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor(white: 0.9, alpha: 1)
    }
    
    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.backgroundColor = .orange
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = false
    }
}



// MARK: - UICOllectionView Delegates
extension DutchUnitController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("numOfParticipantsInAddingUnitController: \(viewModel.participantsNames.count)")
        print("numOfParticipantsInAddingUnitController: \(viewModel.participants.count)")
//        return viewModel.participantsNames.count
//        return viewModel.participants.count
        return viewModel.personDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PersonDetailCell
        
        cell.spentAmountTF.tag = indexPath.row
        cell.attendingBtn.tag = indexPath.row
        cell.fullPriceBtn.tag = indexPath.row
        
        cell.spentAmountTF.delegate = self
        
//        cell.spentAmountTF.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
//        cell.spentAmountTF.addTarget(self, action: #selector(textChanged(_:)), for: .valueChanged)
        cell.delegate = self
        
        // FIXME: index out of range, 7.11, 7.18
        print("indexPath.row: \(indexPath.row)")
        
        let personDetail = viewModel.personDetails[indexPath.row]
        
        cell.viewModel = PersonDetailCellViewModel(personDetail: personDetail)
        // 이 값을 쓰는 이유는 ? 업데이트가 계속 될 때, View 에서 가장 최신 값 받아오기.
        // 나중에 수정이 필요할 수도 있음.
        cell.spentAmountTF.text = String(detailPriceDic[indexPath.row] ?? 0)
        
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
extension DutchUnitController: PersonDetailCellDelegate {
    
    
    func cell(_ cell: PersonDetailCell, isAttending: Bool) {
        print("didTapAttended triggered")
    }
    
    func updateAttendingState(with tag: Int, to isAttending: Bool) {
        //        attendingDic[tag] = isAttending
    }
    
    func cell(_ cell: PersonDetailCell, from peopleIndex: Int) {
        
        //        for (tag, amount) in textFieldWithPriceDic {
        //            print("tag: \(tag), amount: \(amount)")
        //        }
        
        //        let prev = textFieldWithPriceDic[peopleIndex] ?? 0
        
        //        let remaining = spentAmount - sumOfIndividual - prev
        
        //        if remaining != 0 {
        //            textFieldWithPriceDic[peopleIndex] = remaining
        //
        //            var strRemaining = String(remaining)
        //            strRemaining.applyNumberFormatter()
        //            cell.spentAmountTF.text = strRemaining
        //        }
    }
}




// MARK: - TextField Delegate

extension DutchUnitController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == spentPlaceTF {
            spentAmountTF.becomeFirstResponder()
        }
        
        // adding people succeessively
        if textField.tag == 100 {
            addPersonAction(with: textField.text!) // alert's tag
            textField.text = ""
            
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
//        if textField is PriceTextField {
//            textField.becomeFirstResponder()
//            textField.selectAll(nil)
//        }
        
        if let tf = textField as? PriceTextField {
            

            delegate?.initializeNumberText()
            
            self.dismissKeyboardOnly()
            
            needingDelegate?.presentNumberPad()
            
            // 이게 호출되네 ??
            selectedPriceTF = tf
            
            print("tag : \(textField.tag)")
            print("textField: \(textField)")
            
            
            
            return false
            
        } else {
            
            needingDelegate?.hideNumberPad()
            print("tag : \(textField.tag)")
            return true
        }
    }
}
