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
//    func updateDutchUnits()
    func dismissChildVC()
//    func updateParticipants2()
}

protocol DutchUnitDelegate: AnyObject {
    func updateDutchUnit(_ dutchUnit: DutchUnit, isNew: Bool)
}

class DutchUnitController: NeedingController {
    
    // MARK: - Properties

    private let cellIdentifier = "PersonDetailCell"
    
    weak var needingDelegate: NeedingControllerDelegate?
    /// 10
    private let smallPadding: CGFloat = 10

//    let gathering: Gathering
    var dutchUnit: DutchUnit?
    
    // need to handle both
    var participants: [Person]
    var personDetails: [PersonDetail] = []
    
    var selectedPriceTF: PriceTextField?
    
    weak var addingDelegate: AddingUnitControllerDelegate?
    
    weak var dutchDelegate: DutchUnitDelegate?
    
    private var spentAmount: Double = 0
    
    private var sumOfIndividual: Double = 0
    private var textFieldWithPriceDic: [Int : Double] = [:]
    private var attendingDic: [Int: Bool] = [:]
    private var isConditionSatisfied = false
    
    
    // MARK: - UI Properties
    
    private let currenyLabel = UILabel().then {
        $0.text = "원"
    }

    private let spentPlaceLabel = UILabel().then {
        $0.text = "지출 항목"}

    
    private let spentPlaceTF = UITextField(withPadding: true).then {
//        $0.placeholder = "지출한 곳을 입력해주세요."
        $0.textAlignment = .right
        $0.backgroundColor = UIColor(rgb: 0xE7E7E7)
        $0.tag = 1
        $0.layer.cornerRadius = 5
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
        picker.semanticContentAttribute = .forceRightToLeft
        picker.subviews.first?.semanticContentAttribute = .forceRightToLeft

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
    
    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.backgroundColor = .orange
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = false
    }
    
    private var numOfAllUnits: Int?
    
    var initialDutchUnit: DutchUnit? {
        didSet {
            print("initialDutchUnit set, : \(oldValue)")
        }
    }
    
//    init(gathering: Gathering, initialDutchUnit: DutchUnit? = nil) {
    init(initialDutchUnit: DutchUnit? = nil, numOfAllUnits: Int? = nil, participants: [Person]) {
        
        self.initialDutchUnit = initialDutchUnit
        self.participants = participants
        self.numOfAllUnits = numOfAllUnits
        
        super.init(nibName: nil, bundle: nil)
        initializePersonDetails(initialDutchUnit: initialDutchUnit)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let initialDutchUnit = initialDutchUnit {
            setupInitialState(dutchUnit: initialDutchUnit)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad in dutchunitController called")
        
        view.backgroundColor = .white
        
        // Recognizer for resigning keyboards
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        registerCollectionView()
        setupLayout()
        setupTargets()
    
//        gathering.dutchUnits
        setPlaceHolderForSpentPlace()
        
        if let initialDutchUnit = initialDutchUnit {
            setupInitialState(dutchUnit: initialDutchUnit)
            print("initialDutchUnit is valid")
        } else {
            print("initialDutchUnit is nil")
        }
        
        personDetailCollectionView.reloadData()
        changeConfirmBtn()
        
        print("numOfPeople: \(participants.count)")
        for participant in participants {
            print(participant.name)
        }
    }
    
    private func setPlaceHolderForSpentPlace() {
//        let count = gathering.dutchUnits.count
        guard let numOfAllUnits = numOfAllUnits else {
            return
        }

        spentPlaceTF.placeholder = "항목 \(numOfAllUnits + 1)"
    }
    
    private func setupInitialState(dutchUnit: DutchUnit) {
        print("setup initialState called !")
        spentPlaceTF.text = dutchUnit.placeName
        spentAmountTF.text = dutchUnit.spentAmount.addComma()
        // TODO: set people Spent Amount
        
        changeConfirmBtn()
    }
    
    
    private func registerCollectionView() {
        personDetailCollectionView.register(PersonDetailCell.self, forCellWithReuseIdentifier: cellIdentifier)
        personDetailCollectionView.delegate = self
        personDetailCollectionView.dataSource = self
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
            addPersonBtn,
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
            make.width.equalToSuperview().dividedBy(1.5)
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
            make.height.equalTo(45 * participants.count - 20)
        }

        addPersonBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(smallPadding * 1.5)
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

    
    
    @objc private func presentAddingPeopleAlert() {
        let alertController = UIAlertController(title: "Add People", message: "추가할 사람의 이름을 입력해주세요", preferredStyle: .alert)

        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Name"
        }

        let saveAction = UIAlertAction(title: "Add", style: .default) { [self] alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField

            guard textFieldInput.text!.count != 0 else { fatalError("Name must have at least one character") }
            
            let newPersonName = textFieldInput.text!
            var isDuplicateName = false
            for eachPerson in self.participants {
                
                if eachPerson.name == newPersonName {
                    //TODO: Popup alert
                    isDuplicateName = true
                    break
                }
            }
            
            if isDuplicateName == false {
                let newPerson = Person.save(name: textFieldInput.text!)
                self.participants.append(newPerson)
                
                let newDetail = PersonDetail.save(person: newPerson)
                self.personDetails.append(newDetail)
            }
            
            

            
            self.personDetailCollectionView.reloadData()
            
            self.personDetailCollectionView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().inset(self.smallPadding)
                make.trailing.equalToSuperview().inset(self.smallPadding)
                make.top.equalTo(self.divider.snp.bottom).offset(30)
                make.height.equalTo(50 * self.participants.count - 20)
            }

            self.addPersonBtn.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
                make.height.equalTo(40)
                make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        self.present(alertController, animated: true)
    }

    
    private func setupTargets() {
        addPersonBtn.addTarget(self, action: #selector(presentAddingPeopleAlert), for: .touchUpInside)
        dismissBtn.addTarget(nil, action: #selector(dismissTapped), for: .touchUpInside)
        confirmBtn.addTarget(nil, action: #selector(confirmTapped(_:)), for: .touchUpInside)
    }
    
    @objc func dismissTapped() {
        print("cancel action")
        exitAction()
        addingDelegate?.dismissChildVC()
        self.dismiss(animated: true)
    }
    
    private func exitAction() {
        print("success action")
        
        for personIndex in 0 ..< participants.count {
            personDetails[personIndex].isAttended = attendingDic[personIndex] ?? true
            personDetails[personIndex].spentAmount = textFieldWithPriceDic[personIndex] ?? 0
        }
        
        guard let numOfAllUnits = numOfAllUnits else { return }

        let spentPlace = spentPlaceTF.text! != "" ? spentPlaceTF.text! : "항목 \(numOfAllUnits + 1)"
        
        if let initialDutchUnit = initialDutchUnit {
            
            dutchUnit = DutchUnit.update(spentTo: spentPlace, spentAmount: spentAmount, personDetails: personDetails, spentDate: spentDatePicker.date, from: initialDutchUnit)
            
            dutchDelegate?.updateDutchUnit(dutchUnit!, isNew: false)
    
        } else {
            
            dutchUnit = DutchUnit.save(spentTo: spentPlace,
                                       spentAmount: spentAmount,
                                       personDetails: personDetails,
                                       spentDate: spentDatePicker.date)
            
            dutchDelegate?.updateDutchUnit(dutchUnit!, isNew: true)
        }

        needingDelegate?.dismissNumberLayer()
    }
    
    @objc func confirmTapped(_ sender: UIButton) {
        exitAction()
        
    }
    
    
    override func fullPriceAction2() {
        print("fullprice from addingUnitController!")
        guard let selectedPriceTF = selectedPriceTF else {
            fatalError()
        }
        
        let totalAmount = spentAmountTF.text!.convertNumStrToDouble()
        
        sumOfIndividual = 0
        
        for (tag, number) in textFieldWithPriceDic {
            print("tag: \(tag), number: \(number)")
            sumOfIndividual += number
        }
        
        var costRemaining = spentAmount - sumOfIndividual
        
        costRemaining -= selectedPriceTF.text!.convertNumStrToDouble()
        
        let remainingStr = costRemaining.addComma()
        textFieldWithPriceDic[selectedPriceTF.tag] = costRemaining
        
        self.personDetails[selectedPriceTF.tag].spentAmount = costRemaining
        
        selectedPriceTF.text = remainingStr
        
        changeConfirmBtn()
        
        
    }
    
    override func updateNumber(with numberText: String) {
        print("hi, \(numberText)")
        
        guard let selectedPriceTF = selectedPriceTF else {
            return
        }
        
        selectedPriceTF.text = numberText
        
        let selectedTag = selectedPriceTF.tag
        
        switch selectedTag {
        case -1: spentAmount = numberText.convertStrToDouble()
        default:
            textFieldWithPriceDic[selectedTag] = numberText.convertStrToDouble()
            personDetails[selectedTag].spentAmount = numberText.convertStrToDouble()
        }
        
        changeConfirmBtn()
    }
    
    
    @objc func dismissKeyboard() {
        print("dismissKeyboard triggered!!")
        
        changeConfirmBtn()
        
        view.endEditing(true)
        
        needingDelegate?.hideNumberPad()
    }
    
    func dismissKeyboardOnly() {
        view.endEditing(true)
    }
    

    private func initializePersonDetails(initialDutchUnit: DutchUnit? = nil ) {
        
        if let dutchUnit = initialDutchUnit {
            personDetails = dutchUnit.personDetails.sorted()
        } else {
            
            for participant in participants {
                let newPersonDetail = PersonDetail.save(person: participant)
                personDetails.append(newPersonDetail)
            }
        }
        
        DispatchQueue.main.async {
            self.personDetailCollectionView.reloadData()
        }
        
//        self.personDetails = []
//
//        var allNames = Set<String>()
//        var initializedNames = Set<String>()
//        var notInitializedNames = Set<String>()
//
//
//        participants.map { $0.name }.forEach {
//            allNames.insert($0)
//        }
//
//        if let initialDutchUnit = initialDutchUnit {
//            self.personDetails = initialDutchUnit.personDetails.sorted()
//
//            self.personDetails.forEach {
//                initializedNames.update(with: $0.person!.name)
//            }
//        }
//
//        notInitializedNames = allNames.subtracting(initializedNames)
//
//        notInitializedNames.sorted().forEach {
//      // TODO: Comment line below. Instead, get Person objc from gathering.
//            let newPerson = Person.save(name: $0)
//
//            let personDetail = PersonDetail.save(person: newPerson)
//            self.personDetails.append(personDetail)
//        }
//
//        self.personDetails = self.personDetails.sorted()
//
//        DispatchQueue.main.async {
//            self.personDetailCollectionView.reloadData()
//        }
        
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
    
    
    @objc func textDidChange(_ textField: PriceTextField) {
        print("tag: \(textField.tag)")
        if let tf = textField as? PriceTextField {
            print("tag: \(tf.tag)")
            print("it's pricetextfield!, textDidChange")
        } else {
            print("it's not priceTextField!")
        }
    }
    
    
    
    
    
    private func changeConfirmBtn() {
        print("changeConfirmBtn called ")
        sumOfIndividual = 0
        
        for (tag, number) in textFieldWithPriceDic {
            print("tag: \(tag), number: \(number)")
            sumOfIndividual += number
        }
        print("condition: \nsumofIndividual: \(sumOfIndividual) \nspentAmount: \(spentAmount)")
        let condition = (sumOfIndividual == spentAmount) && (sumOfIndividual != 0)
        
        isConditionSatisfied = condition
        setupConfirmBtn(condition: isConditionSatisfied)
    }
    
    private func setupConfirmBtn(condition: Bool) {
        confirmBtn.isUserInteractionEnabled = condition
        
        confirmBtn.backgroundColor = condition ? .green : .orange
    }
}



// MARK: - UICOllectionView Delegates
extension DutchUnitController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numOfParticipantsInAddingUnitController: \(participants.count)")
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PersonDetailCell
        
        cell.spentAmountTF.tag = indexPath.row
        cell.attendingBtn.tag = indexPath.row
        cell.fullPriceBtn.tag = indexPath.row
        
        cell.spentAmountTF.delegate = self
        
        cell.delegate = self
        
        let peopleDetail = self.personDetails.sorted()
        
        // FIXME: index out of range, 7.11
            cell.spentAmountTF.text = peopleDetail[indexPath.row].spentAmount.addComma()
            
            textFieldWithPriceDic[indexPath.row] = peopleDetail[indexPath.row].spentAmount
            print("textFieldWithPriceDic: \(textFieldWithPriceDic)")
        
        if indexPath.row == (participants.count) - 1 {
            if let initialDutchUnit = initialDutchUnit {
                spentAmount = initialDutchUnit.spentAmount
                changeConfirmBtn()
            }
        }
        
        cell.viewModel = PersonDetailViewModel(personDetail: personDetails[indexPath.row])
        
        // personDetails 가 아직 없는 듯 ??
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
        attendingDic[tag] = isAttending
    }
    
    func cell(_ cell: PersonDetailCell, from peopleIndex: Int) {
        
        for (tag, amount) in textFieldWithPriceDic {
            print("tag: \(tag), amount: \(amount)")
        }
        
        let prev = textFieldWithPriceDic[peopleIndex] ?? 0
        
        let remaining = spentAmount - sumOfIndividual - prev
        
        if remaining != 0 {
            textFieldWithPriceDic[peopleIndex] = remaining
            
            var strRemaining = String(remaining)
            strRemaining.applyNumberFormatter()
            cell.spentAmountTF.text = strRemaining
            
        }
    }
}




// MARK: - TextField Delegate

extension DutchUnitController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == spentPlaceTF {
            spentAmountTF.becomeFirstResponder()
        }
        
        changeConfirmBtn()
        return true
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if let tf = textField as? PriceTextField {
            delegate?.initializeNumberText()
            self.dismissKeyboardOnly()
            
            needingDelegate?.presentNumberPad()
            
            selectedPriceTF = tf
            print("tag : \(textField.tag)")
            print("textField: \(textField)")
            changeConfirmBtn()
            return false
        } else {
            
            needingDelegate?.hideNumberPad()
            print("tag : \(textField.tag)")
            changeConfirmBtn()
            return true
        }
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeConfirmBtn()
    }
}
