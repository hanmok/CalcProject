//
//  AddingUnitController.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/28.
//  Copyright © 2022 Mac mini. All rights reserved.
//


// MARK: - Problems
/*
 새로운 항목인지, 이미 있던 항목인지 구분하지 못함 ??
 
값을 입력 후 다른 곳을 누르면 정상 처리
          완료를 누르면 이상하게 처리함.
 
 */

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
    /// 10
    private let smallPadding: CGFloat = 10
    

    private let appliedCellHeight = 40

    
    var spentPlaceTFJustTapped = false
    
//    let scrollView = UIScrollView()
    
    var isShowingKeyboard = false {
        willSet {
            print("dismissing flag 4: isShowingKeyboard: \(newValue)")
        }
    }
    
    var viewModel: DutchUnitViewModel
    
    private let cellIdentifier = "PersonDetailCell"
    
    weak var needingDelegate: NeedingControllerDelegate?
    
   
    weak var addingDelegate: AddingUnitControllerDelegate?
    
    var dutchUnit: DutchUnit?
    var gathering: Gathering
    
    var selectedPriceTF: PriceTextField?
    var selectedIdx: Int?

    weak var dutchDelegate: DutchUnitDelegate?
    
    var detailPriceDic: [Int: Double] = [:] {
        willSet {
            var sum = 0.0
            for (_, value2) in newValue.enumerated() {
                sum += value2.value
            }
            sumOfIndividual = sum
            print("detailPriceDic updated \(newValue), \nspentAmount: \(spentAmount), \nsumOfIndividual:\(sumOfIndividual)")
        }
        didSet {
            print("umm")
        }
    }
    
    var detailAttendingDic: [Idx: Bool] = [:]
    
    var spentAmount: Double = 0 {
        willSet {
            let condition = (sumOfIndividual == newValue) && (newValue != 0)
            updateConditionState(condition)
            print("condition flag 4, spentAmount updated \(newValue), sumOfIndividual: \(sumOfIndividual)")
        }
    }
    
    var sumOfIndividual: Double = 0 {
        willSet {
        let condition = (newValue == spentAmount) && (newValue != 0)
            updateConditionState(condition)
            print("condition flag 5, sumOfIndividual updated to \(newValue), spentAmount: \(spentAmount)")
        }
    }
    
    
    init(
        initialDutchUnit: DutchUnit? = nil,
        gathering: Gathering
    ) {
        self.viewModel = DutchUnitViewModel(selectedDutchUnit: initialDutchUnit, gathering: gathering)
        self.dutchUnit = initialDutchUnit
        self.gathering = gathering
//        self.spentAmount =
        if let initialDutchUnit = initialDutchUnit {
            self.spentAmount = initialDutchUnit.spentAmount
        }
        print("initializing personDetails flag 0, dutchUnit: \(initialDutchUnit)")
        
        super.init(nibName: nil, bundle: nil)
//        initializePersonDetails(initialDutchUnit: initialDutchUnit)
    }
    
    /// set DetailPriceDic if viewDidLoad
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var insets = view.safeAreaInsets
            insets.top = 0
//            tableView.contentInset = insets
        scrollView.contentInset = insets
    
        
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 2000)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        view.insetsLayoutMarginsFromSafeArea = false
        print("initializing personDetails flag 3")
        print("current personDetails: ")
        
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
            self.setConfirmBtnState(isActive: condition)
        }
        
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(otherViewTapped))
        
//        let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectAllText(_:)))
        
//        spentPlaceTF.addGestureRecognizer(tap3)
        
        view.addGestureRecognizer(tap2)
        print("flag, dutchUnit: \(dutchUnit)")
        
        if dutchUnit != nil {
            setConfirmBtnState(isActive: true)
        } else {
            askTotalSpentAmount()
        }
    }
    
    private func blinkSpentAmount() {
        
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
    
    private func askTotalSpentAmount() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spentAmountTF.becomeFirstResponder()
            self.needingDelegate?.presentNumberPad()
            self.blinkSpentAmount()
        }
    }
    
    private func setConfirmBtnState(isActive: Bool) {
        confirmBtn.isUserInteractionEnabled = isActive
        print("setConditionBtnState to \(isActive)!!")
//        confirmBtn.backgroundColor = isActive ? ColorList().bgColorForExtrasLM : UIColor(white: 0.85, alpha: 0.9)
        DispatchQueue.main.async {
            self.confirmBtn.backgroundColor = isActive ? ColorList().confirmBtnColor : UIColor(white: 0.85, alpha: 0.9)
        }

    }
    
    
    private func setupDictionary() {
        
        for idx in 0 ..< viewModel.personDetails.count {
            detailPriceDic[idx] = viewModel.personDetails[idx].spentAmount
            detailAttendingDic[idx] = viewModel.personDetails[idx].isAttended
        }
    }
    
    @objc func otherViewTapped() {
        
        print("otherViewTapped called!!, spentPlaceTFJustTapped: \(spentPlaceTFJustTapped)")
        
        if spentPlaceTFJustTapped == false {
        
            dismissKeyboard()
            
            guard let validSelectedPriceTF = selectedPriceTF else { return }
        
        let currentText = validSelectedPriceTF.text!
        
        updateDictionary(tag: validSelectedPriceTF.tag, currentText: currentText)
        
        print("otherView Tapped!!")
        
//        needingDelegate?.hideNumberPad { print("hide!")}
        
        if validSelectedPriceTF.tag != -1 {
            let selectedRow = validSelectedPriceTF.tag
            personDetailCollectionView.reloadItems(at: [IndexPath(row:selectedRow, section: 0)])
            
            print("selected flag 1, updated row: \(selectedRow)")
        } else {
            spentAmountTF.backgroundColor = UIColor(rgb: 0xE7E7E7)
            spentAmountTF.textColor = .black
            print("selected flag 2")
        }
        print("selected flag 3")
        }
    }
    
    
    
    func updateDictionary(tag: Int, currentText: String) {
        print("dismissing flag::  tag: \(tag), currentText: \(currentText)")
        
        if tag == -1{
            spentAmount = currentText.convertToDouble()
            viewModel.updateSpentAmount(to: spentAmount)
            print("dismissing flag 6, spentAmount: \(spentAmount)")
        } else {
            detailPriceDic[tag] = currentText.convertToDouble()
        }
        
        print("after updating dictionary, spentAmount: \(spentAmount), dic: \(detailPriceDic), currentText: \(currentText)")
    }
    
    var updateConditionState: (Bool) -> Void = { _ in }
    
    private func setupBindings() {
        
        viewModel.updateCollectionView = { [weak self] in
            guard let self = self else { return }
            self.relocateCollectionView()
            print("initializing personDetails flag 4")
            print("numOfDetails: \(self.viewModel.personDetails.count)")
        }
        
        viewModel.changeableConditionState = {[weak self] bool in
            guard let self = self else { return }
            self.setConfirmBtnState(isActive: bool)
            print("changeableConditionState changed to \(bool)")
        }
    }
    
    
    private func setupTargets() {
        resetBtn.addTarget(self, action: #selector(resetState), for: .touchUpInside)
        addPersonBtn.addTarget(self, action: #selector(presentAddingPeopleAlert), for: .touchUpInside)
        dismissBtn.addTarget(nil, action: #selector(dismissTapped), for: .touchUpInside)
        confirmBtn.addTarget(nil, action: #selector(confirmTapped), for: .touchUpInside)
        
        spentPlaceTF.addTarget(self, action: #selector(selectAllText(_:)), for: .touchDown)
//        spentPlaceTF.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: .)
    }
    
    // 좀.. 이상한데 ??
    @objc func selectAllText(_ sender: UITextField) {
        print("selectAllText called")
        sender.selectAll(nil)
        
        spentPlaceTFJustTapped = true
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            print("spentPlaceTFJustTapped changed to false")
            self.spentPlaceTFJustTapped = false
        }
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
    
    // TODO: 이거, Custom 으로 만들어야겠어 ;;
    @objc private func presentAskingSpentAmountAlert(completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "지출 금액", message: "지출한 총 비용을 입력해주세요.", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "cost"
            textField.tag = 100
            textField.delegate = self
            textField.keyboardType = .decimalPad // replace with custom numberpad
        }
        
        view.endEditing(true)
        
        needingDelegate?.presentNumberPad()
        let saveAction = UIAlertAction(title: "Confirm", style: .default) { [self] alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
        
            let spentAmountStr = textFieldInput.text!
            
            spentAmount = spentAmountStr.convertToDouble()
            viewModel.updateSpentAmount(to: spentAmount)
            spentAmountTF.text = spentAmount.addComma()
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
                    make.leading.equalToSuperview().inset(self.smallPadding * 1.5)
                    make.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
                    make.top.equalTo(self.divider.snp.bottom).offset(30)
//                    make.height.equalTo(50 * self.viewModel.personDetails.count - 20)
//                    make.height.equalTo(30 * self.viewModel.personDetails.count + 20 * (self.viewModel.personDetails.count - 1))

//                    make.height.equalTo(30 * self.viewModel.personDetails.count)
                    make.height.equalTo(self.appliedCellHeight * self.viewModel.personDetails.count)

                }
                
//                self.resetBtn.snp.makeConstraints { make in
//                    make.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
//                    make.width.equalTo(80)
//                    make.height.equalTo(40)
//                    make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
//                }
                
                self.addPersonBtn.snp.makeConstraints { make in
//                    make.leading.equalToSuperview().inset(self.smallPadding * 1.5)
                    make.leading.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
//                    make.trailing.equalTo(self.resetBtn.snp.leading).offset(-10)
                    make.height.equalTo(40)
                    make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(20)
                }
            }
        }
    }
    
    @objc func dismissTapped() {
        addingDelegate?.dismissChildVC()

        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc func confirmTapped() {
        
        viewModel.updateDutchUnit(spentPlace: spentPlaceTF.text!,
                                  spentAmount: spentAmount,
                                  spentDate: Date(),
                                  detailPriceDic: detailPriceDic,
        detailAttendingDic: detailAttendingDic) { [weak self] in
            
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            self.needingDelegate?.dismissNumberLayer()
        }
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
                
                self.showToast(message: msg, defaultWidthSize: self.screenWidth, defaultHeightSize: self.screenHeight, widthRatio: 0.9, heightRatio: 0.025, fontsize: 16)
                
                DispatchQueue.main.async {
                    self.personDetailCollectionView.reloadData()
                    
                    self.personDetailCollectionView.snp.remakeConstraints { make in
                        make.leading.equalToSuperview().inset(self.smallPadding)
                        make.trailing.equalToSuperview().inset(self.smallPadding)
                        make.top.equalTo(self.divider.snp.bottom).offset(30)

//                        make.height.equalTo(50 * self.viewModel.personDetails.count - 20) // -20 은 spacing
                        
//                        make.height.equalTo(30 * self.viewModel.personDetails.count + 20 * (self.viewModel.personDetails.count - 1)) // -20 은 spacing

                        
//                        make.height.equalTo(30 * self.viewModel.personDetails.count)
                        make.height.equalTo(self.appliedCellHeight * self.viewModel.personDetails.count)

                    }
                    
//                    self.resetBtn.snp.makeConstraints { make in
//                        make.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
//                        make.width.equalTo(80)
//                        make.height.equalTo(40)
//                        make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
//                    }
                    
                    self.addPersonBtn.snp.makeConstraints { make in
//                        make.leading.equalToSuperview().inset(self.smallPadding * 1.5)
                        make.leading.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
//                        make.trailing.equalTo(self.resetBtn.snp.leading).offset(-10)
                        make.height.equalTo(40)
//                        make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
                        make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(20)
                    }
                }
                
            case .failure(let errorMsg):
                print("duplicate flag 3")
                self.showToast(message: errorMsg.localizedDescription, defaultWidthSize: self.screenWidth, defaultHeightSize: self.screenHeight, widthRatio: 0.9, heightRatio: 0.025, fontsize: 16)
            }
        }
    }
    
    private func relocateCollectionView() {
        DispatchQueue.main.async {
            
            self.personDetailCollectionView.reloadData()
            
            self.personDetailCollectionView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().inset(self.smallPadding)
                make.trailing.equalToSuperview().inset(self.smallPadding)
                make.top.equalTo(self.divider.snp.bottom).offset(30)

//                make.height.equalTo(50 * self.viewModel.personDetails.count - 20)
//                make.height.equalTo(30 * self.viewModel.personDetails.count + 20 * (self.viewModel.personDetails.count - 1))

//                make.height.equalTo(30 * self.viewModel.personDetails.count)
                make.height.equalTo(self.appliedCellHeight * self.viewModel.personDetails.count)

            }
            
//            self.resetBtn.snp.makeConstraints { make in
//                make.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
//                make.width.equalTo(80)
//                make.height.equalTo(40)
//                make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
//            }
            
            self.addPersonBtn.snp.makeConstraints { make in
//                make.leading.equalToSuperview().inset(self.smallPadding * 1.5)
                make.leading.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
//                make.trailing.equalTo(self.resetBtn.snp.leading).offset(-10)
                make.height.equalTo(40)
//                make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(15)
                make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(20)
            }
        }
        
        print("relocate collectionView called, count: \(viewModel.personDetails.count)")
    }
    
    
    private func setupCollectionView() {
        personDetailCollectionView.register(PersonDetailCell.self, forCellWithReuseIdentifier: cellIdentifier)
        personDetailCollectionView.delegate = self
        personDetailCollectionView.dataSource = self
        
//        DispatchQueue.main.async {
//            self.personDetailCollectionView.reloadData()
//        }
//        reloadInputViews()
        
        
        relocateCollectionView()
    }
    
    private func setupLayout() {
        
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
//        [
//            dismissBtn,
//            spentPlaceLabel, spentPlaceTF,
//            spentAmountLabel, spentAmountTF, currenyLabel,
//            spentDateLabel,
//            spentDatePicker,
//            divider,
//            personDetailCollectionView,
//            resetBtn, addPersonBtn,
////            confirmBtn,
//            bottomContainerView
//        ].forEach { v in
//            self.view.addSubview(v)
//        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
//            make.top.equalTo(view)
//            make.leading.equalToSuperview()
//            make.width.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            
//            make.leading.top.bottom.equalToSuperview()
//            make.width.equalToSuperview()
        }
        
                [
                    dismissBtn,
                    spentPlaceLabel, spentPlaceTF,
                    spentAmountLabel, spentAmountTF, currenyLabel,
                    spentDateLabel,
                    spentDatePicker,
                    divider,
                    personDetailCollectionView,
                    resetBtn, addPersonBtn
                ].forEach { v in
                    self.scrollView.addSubview(v)
                }
        view.addSubview(bottomContainerView)
        
        spentPlaceTF.delegate = self
        spentAmountTF.delegate = self
        
        dismissBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
//            make.top.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview().offset(56)
            make.height.equalTo(30)
//            make.width.equalTo(15)
            make.width.equalTo(30)
        }
        
        spentPlaceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(smallPadding * 2)
//            make.top.equalTo(dismissBtn.snp.bottom).offset(20)
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
//            make.width.equalToSuperview().dividedBy(1.7) // prev: 1.5
//            make.width.equalToSuperview().dividedBy(2.0)
//            make.top.equalTo(spentAmountTF.snp.bottom).offset(30)
            make.top.equalTo(spentDateLabel.snp.bottom).offset(5)
            make.height.equalTo(40)
        }
        
        
        divider.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(5)
//            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-10)
            make.width.equalTo(view.snp.width).offset(-10)
            make.height.equalTo(1)
            make.top.equalTo(spentDatePicker.snp.bottom).offset(15)
        }
        
        
        personDetailCollectionView.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(50)
            make.leading.equalToSuperview().inset(5)
//            make.trailing.equalToSuperview().inset(smallPadding)
//            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-2 * smallPadding)
//            make.width.equalTo(300)
//            make.width.equalTo(view.snp.width).offset(-10)
            make.width.equalTo(divider.snp.width)
            make.top.equalTo(divider.snp.bottom).offset(30)
//            make.height.equalTo(45 * viewModel.personDetails.count - 20)
//            make.height.equalTo(30 * self.viewModel.personDetails.count + 20 * (self.viewModel.personDetails.count - 1))
//            make.height.equalTo(30 * self.viewModel.personDetails.count)
            make.height.equalTo(appliedCellHeight * self.viewModel.personDetails.count)
//            make.height.equalTo(30 * self.viewModel.personDetails.count)
//            make.height.equalTo(200)
            

        }
        
//        addPersonBtn.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(smallPadding * 1.5)
//            make.height.equalTo(40)
//            make.top.equalTo(personDetailCollectionView.snp.bottom).offset(20)
//        }
  
        bottomContainerView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view)
            make.height.equalTo(70)
        }
        
//        confirmBtn.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
////            make.bottom.equalTo(view).inset(20)
//            make.bottom.equalToSuperview().inset(20)
//            make.width.equalTo(view.snp.width).dividedBy(2)
//            make.height.equalTo(50)
//        }
        
        bottomContainerView.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(20)
        }
        
        addPersonBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
//            make.width.equalTo(150)
            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-32)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    
    // MARK: - UI Properties
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
//        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 3000)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .cyan
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    
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
//        $0.textAlignment = .right
        $0.text = "지출 일시"
    }
    
    private let spentDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .automatic
//        picker.backgroundColor = .magenta
        picker.contentMode = .left
        picker.sizeThatFits(CGSize(width: 150, height: 40))
//        picker.sizeToFit()
//        picker.semanticContentAttribute = .forceRightToLeft
//        picker.subviews.first?.semanticContentAttribute = .forceRightToLeft
//        picker.semanticContentAttribute = .forceLeftToRight
        return picker
    }()
    
    private let personDetailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = false
//        cv.isScrollEnabled = false
//        cv.backgroundColor = UIColor(white: 0.8, alpha: 1)
        
        return cv
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
    
    private let addPersonBtn = UIButton().then {
        $0.setTitle("인원 추가", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor(white: 0.92, alpha: 1)
    }
    
    private let resetBtn = UIButton().then {
        let imgView = UIImageView(image: UIImage(systemName: "arrow.counterclockwise"))
        imgView.tintColor = .red
        imgView.contentMode = .scaleAspectFit

        $0.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview().inset(6)
        }
        
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor(white: 0.88, alpha: 1)
    }
    
    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = UIColor(white: 0.85, alpha: 0.9)
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = false
    }
    
    private let bottomContainerView = UIView().then {
        $0.backgroundColor = .magenta
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func completeAction3() {
        print("complete recognized from dutchunitController")
        otherViewTapped()
    }
    
    // MARK: - NeedingController Delegate
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
    
//    override func fullPriceAction2() {
//        print("fullprice from addingUnitController!")
//        guard let selectedPriceTF = selectedPriceTF else {
//            fatalError()
//        }
//
//        let totalAmount = spentAmountTF.text!.convertNumStrToDouble()
//
//        //        sumOfIndividual = 0
//
//        //        for (tag, number) in textFieldWithPriceDic {
//        //            print("tag: \(tag), number: \(number)")
//        //            sumOfIndividual += number
//        //        }
//
//        //        var costRemaining = spentAmount - sumOfIndividual
//
//        //        costRemaining -= selectedPriceTF.text!.convertNumStrToDouble()
//
//        //        let remainingStr = costRemaining.addComma()
//        //        textFieldWithPriceDic[selectedPriceTF.tag] = costRemaining
//
//        //        self.viewModel.personDetails[selectedPriceTF.tag].spentAmount = costRemaining
//
//        //        selectedPriceTF.text = remainingStr
//
//    }
}



// MARK: - UICOllectionView Delegates
extension DutchUnitController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfItemsInSection: \(viewModel.personDetails.count)")
        
        return viewModel.personDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PersonDetailCell
        
        cell.spentAmountTF.tag = indexPath.row
        cell.attendingBtn.tag = indexPath.row
        cell.fullPriceBtn.tag = indexPath.row
        
        cell.spentAmountTF.delegate = self
        
        
        let target = viewModel.personDetails[indexPath.row]
        
        let personDetail = viewModel.personDetails[indexPath.row]
        
        cell.viewModel = PersonDetailCellViewModel(personDetail: personDetail)
        // 이 값을 쓰는 이유는 ? 업데이트가 계속 될 때, View 에서 가장 최신 값 받아오기. (나중에 수정이 필요할 수도 있음)
        // ummm... 왜 변환이 안되지 ?? ;;
       var text = (detailPriceDic[indexPath.row] ?? 0.0).convertToIntString()
        
        text.applyNumberFormatter()
        
        cell.delegate = self
        
        cell.spentAmountTF.text = text
        
        print("newText: \(cell.spentAmountTF.text!)")

        cell.spentAmountTF.textColor = .black
        cell.spentAmountTF.backgroundColor = UIColor(rgb: 0xE7E7E7)
        
        // update Dictionary
        let currentIdx = indexPath.row
        if detailPriceDic[currentIdx] == nil {
            detailPriceDic[currentIdx] = 0
        }
        if detailAttendingDic[currentIdx] == nil {
            detailAttendingDic[currentIdx] = true
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: 30)
        
        return CGSize(width: Int(view.frame.width) - 30, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
        return 0
    }
}

// MARK: - PersonDetailCell Delegate
extension DutchUnitController: PersonDetailCellDelegate {
    
    func fullPriceAction(idx: Int) {
        print("fullPriceAction in dutchUnitController called")
        print("current idx: \(idx), spentAmout: \(spentAmount)")
        
        for (tag, amount) in detailPriceDic {
            print("tag: \(tag), amount: \(amount)")
        }

        // 여기 두줄이 문제.. 본인 값을 잘못 반영하고있음.
        // umm..
        let prev = detailPriceDic[idx] ?? 0
        
        // TODO: update sumOfIndividual
        // 음.. 입력을 하다가 이걸 누르는 경우는 고려하지 않은 상태. ;
        // TextField 를 연속해서 (Custom NumberPad 를 dismiss 시키지 않은 채) 입력하면 값이 반영되지 않음. 어떻게 해결하지??
        
        let remaining = spentAmount - sumOfIndividual + prev

        
        if remaining != 0 {
            detailPriceDic[idx] = remaining

            personDetailCollectionView.reloadItems(at: [IndexPath(row: idx, section: 0)])
        }
        
        delegate?.hideNumberPad()
    }
    
    func cell(_ cell: PersonDetailCell, isAttending: Bool) {
        print("didTapAttended triggered")
    }
    
    func updateAttendingState(with tag: Int, to isAttending: Bool) {
        detailAttendingDic[tag] = isAttending
    }
    
    func cell(_ cell: PersonDetailCell, from peopleIndex: Int) {
        
                
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
//        personDetailCollectionView.reloadItems(at: [IndexPath(row: , section: <#T##Int#>)])
        // FIXME: dismissKeyboardOnly, dismissKeyboard 두개 구분해서 사용하기.
        if let tf = textField as? PriceTextField {
            
            if isShowingKeyboard {
                print("dismissing flag 2")
                //FIXME: Fatal Error !
                guard let prevSelectedPriceTF = selectedPriceTF else { fatalError() }
                updateDictionary(tag: prevSelectedPriceTF.tag, currentText: prevSelectedPriceTF.text!)
//                prevSelectedPriceTF.backgroundColor = UIColor(rgb: 0xF2F2F2)
                prevSelectedPriceTF.backgroundColor = UIColor(rgb: 0xE7E7E7)
                prevSelectedPriceTF.textColor = .black
            }
            
            print("dismissing flag 3")
            delegate?.initializeNumberText()
            
            self.dismissKeyboardOnly()
            
            needingDelegate?.presentNumberPad()
            
            isShowingKeyboard = true
            
            selectedPriceTF = tf
            
            selectedPriceTF?.backgroundColor = UIColor(rgb: 0xF2F2F2)
            selectedPriceTF?.textColor = UIColor(white: 0.7, alpha: 1)
            
            print("tag : \(textField.tag)")
            print("textField: \(textField)")
            
            return false
            
        } else {
            
            needingDelegate?.hideNumberPad()
            
            isShowingKeyboard = false
            
            print("tag : \(textField.tag)")
            return true
        }
    }
}


//extension DutchUnitController {
//    private func presentAskingSpentPlace( completion: @escaping (NewNameAction)) {
//        let alertController = UIAlertController(title: "Edit Gathering Name", message: "새로운 모임 이름을 입력해주세요", preferredStyle: .alert)
//
//        alertController.addTextField { (textField: UITextField!) -> Void in
//            textField.placeholder = "Gathering Name"
//        }
//
//        let saveAction = UIAlertAction(title: "Done", style: .default) { alert -> Void in
//            let textFieldInput = alertController.textFields![0] as UITextField
//
//            let newGroupName = textFieldInput.text!
//
//            guard newGroupName.count != 0 else {
//                completion(.failure(.cancelAskingName))
//                fatalError("Name must have at least one character")
//            }
//
//            completion(.success(newGroupName))
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
//            (action : UIAlertAction!) -> Void in
//            completion(.failure(.cancelAskingName))
//        })
//
//        alertController.addAction(cancelAction)
//        alertController.addAction(saveAction)
//
//        self.present(alertController, animated: true)
//    }
//}
