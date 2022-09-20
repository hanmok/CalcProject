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

extension DutchUnitController: PersonDetailHeaderDelegate {
    func dismissAcion() {
        addingDelegate?.dismissChildVC()

        self.navigationController?.popViewController(animated: true)
    }
    
    func spentAmtTapped() {
        self.needingDelegate?.initializeNumberText()
        print("spentAmtTapped!")

    }
    
    func textFieldTapAction(sender: UITextField, isSpentAmountTF: Bool) {
        print("selectAllText called")
        
        if isSpentAmountTF {

            NotificationCenter.default.post(name: .changePriceStateIntoActive, object: nil)

            dismissKeyboardOnly()
            self.needingDelegate?.presentNumberPad()
            
            self.needingDelegate?.initializeNumberText()
        } else { // spentPlace
            sender.selectAll(nil)
            
            spentPlaceTFJustTapped = true
            
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                print("spentPlaceTFJustTapped changed to false")
                self.spentPlaceTFJustTapped = false
            }
        }
    }
    
    func valueUpdated(spentAmount: Double, spentPlace: String) {
        self.spentPlace = spentPlace
        self.spentAmount = spentAmount
    }
}

extension DutchUnitController: PersonDetailFooterDelegate {
    func addPersonAction() {
        print("presentAddingPeopleAlert called")
        self.presentAddingPeopleAlert()
    }
}

class DutchUnitController: NeedingController {
    
    
    
    // MARK: - Properties
    /// 10
    private let smallPadding: CGFloat = 10
    
    private let appliedCellHeight = 40

    var spentPlaceTFJustTapped = false
    
    var hasLoadedFirst = true
    
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
    
    var spentPlace: String = ""
    var spentDate: Date = Date()
    
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
        if let initialDutchUnit = initialDutchUnit {
            self.spentAmount = initialDutchUnit.spentAmount
        }
        print("initializing personDetails flag 0, dutchUnit: \(initialDutchUnit)")
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        var insets = view.safeAreaInsets
        insets.top = 0
        personDetailCollectionView.contentInset = insets
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWithHeaderInfo(_:)), name: .sendHeaderInfoBack, object: nil)
    }
    
    @objc func updateWithHeaderInfo(_ notification: Notification) {
        print("changeStateToActive called!!")
        
//        guard let amtInput = notification.userInfo?["spentAmt"] as? Double else {return }
        guard let spentPlace = notification.userInfo?["spentPlace"] as? String,
              let spentAmt = notification.userInfo?["spentAmt"] as? String,
              let spentDate = notification.userInfo?["spentDate"] as? Date else { return }
        
        self.spentPlace = spentPlace
        self.spentAmount = spentAmt.convertToDouble()
        self.spentDate = spentDate
    }
    
        
        
    // MARK: - Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        
        personDetailCollectionView.contentInsetAdjustmentBehavior = .never
        
        navigationController?.navigationBar.isHidden = true
        
        print("initializing personDetails flag 3")
        print("current personDetails: ")
        
        view.backgroundColor = .white
        
        setupBindings()
        
        viewModel.initializePersonDetails(gathering: gathering, dutchUnit: dutchUnit)
        
        print("flag 5, currentPersonDetails: \(viewModel.personDetails.count)")
        
        setupDictionary()
        
        viewModel.setupInitialState { [weak self] initialState, newDutchUnitIndex in
            guard let self = self else { return }
            
            
            if let initialState = initialState {
                self.spentPlace = initialState.place
                self.spentAmount = initialState.amount // Double, String
                self.spentDate = initialState.date
                
            } else {
                guard let numOfElements = newDutchUnitIndex else { return }
                self.spentPlace = "항목 \(numOfElements)"
                print("slef.spentPlace, numOfElements: \(numOfElements)")
                
            }
        }
        
        
        setupLayout()
        setupTargets()
        
        self.setupCollectionView()
                
        // TODO: 이거.. 여기서 하면 안될 것 같은데 ?? 구조가 많이 바뀌었음.
        
        viewModel.setupInitialCells { [weak self] cells in
            guard let self = self else { return }
        }
        
        updateConditionState = { [weak self] condition in
            print("current condition: \(condition)")
            guard let self = self else { return }
            self.setConfirmBtnState(isActive: condition)
        }
        
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(otherViewTapped))
        
        view.addGestureRecognizer(tap2)
        print("flag, dutchUnit: \(dutchUnit)")
        
        if dutchUnit != nil {
            setConfirmBtnState(isActive: true)
        } else {
            askTotalSpentAmount()
        }
        
        setupNotification()
    }
    
//    @objc func headerAmtChanged(_ textField: UITextField) {
        
//    }
    
    
    private func updateHeaderSpentAmt(input: Double) {
//        let amt: Double = 100
//        let amt = inpu
    
//        let spentAmt: [AnyHashable: Any] = ["spentAmt": amt]
        let spentAmt: [AnyHashable: Any] = ["spentAmt": input]
        
        NotificationCenter.default.post(name: .updateSpentAmt, object: nil, userInfo: spentAmt)
        
    }
    
    private func askTotalSpentAmount() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // prev code
//            self.spentAmountTF.becomeFirstResponder()
            self.needingDelegate?.presentNumberPad()
        }
    }
    
    private func setConfirmBtnState(isActive: Bool) {
        confirmBtn.isUserInteractionEnabled = isActive
        print("setConditionBtnState to \(isActive)!!")
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
        
        NotificationCenter.default.post(name: .changePriceStateIntoInactive, object: nil)
        
        NotificationCenter.default.post(name: .notifyOtherViewTapped, object: nil)
        
        print("otherViewTapped called!!, spentPlaceTFJustTapped: \(spentPlaceTFJustTapped)")
        
        if spentPlaceTFJustTapped == false {
            
            dismissKeyboard()
            
            guard let validSelectedPriceTF = selectedPriceTF else { return }
            
            let currentText = validSelectedPriceTF.text!
            
            updateDictionary(tag: validSelectedPriceTF.tag, currentText: currentText)
            
            print("otherView Tapped!!")
            
            // meaningless..
            if validSelectedPriceTF.tag != -1 {
                
                let selectedRow = validSelectedPriceTF.tag
                personDetailCollectionView.reloadItems(at: [IndexPath(row:selectedRow, section: 0)])
                
                print("selected flag 1, updated row: \(selectedRow)")
            } else {
                
//                textFieldShouldReturn(<#T##textField: UITextField##UITextField#>)
                
//                spentAmountTF.backgroundColor = .magenta
//                spentAmountTF.backgroundColor = UIColor(rgb: 0xE7E7E7)
//                spentAmountTF.textColor = .black
                
                print("selected flag 2")
            }
            print("selected flag 3")
        }
    }
    
    

    func updateDictionary(tag: Int, currentText: String) {
        print("dismissing flag::  tag: \(tag), currentText: \(currentText)")
        
        if tag == -1 {
            
            spentAmount = currentText.convertToDouble()
            viewModel.updateSpentAmount(to: spentAmount)
            print("dismissing flag 6, spentAmount: \(spentAmount)")
            
            updateHeaderSpentAmt(input: spentAmount)
    
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
        
        confirmBtn.addTarget(nil, action: #selector(confirmTapped), for: .touchUpInside)
        // prev code
//        spentPlaceTF.addTarget(self, action: #selector(selectAllText(_:)), for: .touchDown)
        
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
    
    // TODO: 만약에 Header 로 하다가 잘 안되면, 이것도 방법이겠다..
//    @objc private func presentAskingSpentAmountAlert(completion: @escaping () -> Void) {
//        let alertController = UIAlertController(title: "지출 금액", message: "지출한 총 비용을 입력해주세요.", preferredStyle: .alert)
//
//        alertController.addTextField { (textField: UITextField!) -> Void in
//            textField.placeholder = "cost"
//            textField.tag = 100
//            textField.delegate = self
//            textField.keyboardType = .decimalPad // replace with custom numberpad
//        }
//
//        view.endEditing(true)
//
//        needingDelegate?.presentNumberPad()
//        let saveAction = UIAlertAction(title: "Confirm", style: .default) { [self] alert -> Void in
//            let textFieldInput = alertController.textFields![0] as UITextField
//
//            let spentAmountStr = textFieldInput.text!
//
//            spentAmount = spentAmountStr.convertToDouble()
//            viewModel.updateSpentAmount(to: spentAmount)
//            spentAmountTF.text = spentAmount.addComma()
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
//            (action : UIAlertAction!) -> Void in })
//
//        alertController.addAction(cancelAction)
//        alertController.addAction(saveAction)
//
//        self.present(alertController, animated: true)
//    }
    
    

    @objc func resetState() {
        viewModel.reset {
            DispatchQueue.main.async {
                self.personDetailCollectionView.snp.remakeConstraints { make in
//                    make.leading.equalToSuperview().inset(self.smallPadding * 1.5)
//                    make.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
                    make.leading.trailing.equalToSuperview()
//                    make.top.equalTo(self.divider.snp.bottom).offset(30)
                    make.top.equalToSuperview()

//                    make.height.equalTo(self.appliedCellHeight * self.viewModel.personDetails.count)
                    make.height.equalToSuperview()
//                    make.height.equalTo(100)
                }


//                self.addPersonBtn.snp.makeConstraints { make in
//                    make.leading.trailing.equalToSuperview().inset(self.smallPadding * 1.5)
//                    make.height.equalTo(40)
//                    make.top.equalTo(self.personDetailCollectionView.snp.bottom).offset(20)
//                }
            }
        }
    }
    
//    @objc func dismissTapped() {
//        addingDelegate?.dismissChildVC()
//
//        self.navigationController?.popViewController(animated: true)
//    }
    
    
    
    @objc func confirmTapped() {
    // 여기에 Header 고려해서 업데이트 해주면 좋겠는데...
        viewModel.updateDutchUnit(spentPlace: self.spentPlace,
                                  spentAmount: self.spentAmount,
                                  spentDate: self.spentDate,
                                  
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
        
        moveDownCollectionView()
        updateWithAnimation()
    }
    
    func dismissKeyboardOnly() {
        view.endEditing(true)
    }
    
    
    @objc func textDidBegin(_ textField: UITextField) {
//        if textField == spentAmountTF {
//            print("it's spentAmountTF")
//        } else if textField == spentPlaceTF {
//            print("it's spentPlaceTF")
//        }
        
        
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
//                    self.personDetailCollectionView.reloadData()
                    self.personDetailCollectionView.reloadItems(inSection: 0)
//                    self.personDetailCollectionView.reload
                    
                    self.moveDownCollectionView()
                }
                
                self.updateWithAnimation()
               
                
            case .failure(let errorMsg):
                print("duplicate flag 3")
                self.showToast(message: errorMsg.localizedDescription, defaultWidthSize: self.screenWidth, defaultHeightSize: self.screenHeight, widthRatio: 0.9, heightRatio: 0.025, fontsize: 16)
            }
        }
    }
    
    private func relocateCollectionView() {
        DispatchQueue.main.async {
            
//            self.personDetailCollectionView.reloadData()
            self.personDetailCollectionView.reloadItems(inSection: 0)
            
            self.moveDownCollectionView()
        }
        
        print("relocate collectionView called, count: \(viewModel.personDetails.count)")
    }
    
    
    private func setupCollectionView() {
        personDetailCollectionView.register(PersonDetailCell.self, forCellWithReuseIdentifier: cellIdentifier)
        personDetailCollectionView.delegate = self
        personDetailCollectionView.dataSource = self
        
        
        personDetailCollectionView.register(PersonDetailHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PersonDetailHeader.headerIdentifier)
        
        personDetailCollectionView.register(PersonDetailFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PersonDetailFooter.footerIdentifier)
        
        
        
        relocateCollectionView()
    }

    
    private func setupLayout() {
        
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
        view.addSubview(personDetailCollectionView)
        
        
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(gradientView)
        bottomContainerView.addSubview(remainingView)
//        spentPlaceTF.delegate = self
//        spentAmountTF.delegate = self
        
        personDetailCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview()
        }
  
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-70)
            make.height.equalTo(110)
        }
        
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(20)
        }
        
        remainingView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(gradientView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        
        bottomContainerView.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    
    // MARK: - UI Properties
    
    
    
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
    
    private lazy var personDetailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = true
//        cv.isScrollEnabled = false
        cv.showsVerticalScrollIndicator = true
//        cv.isHidden = true
        return cv
    }()
    
    
    
//    private let dismissBtn: UIButton = {
//        let btn = UIButton()
//        let imageView = UIImageView(image: UIImage(systemName: "chevron.left"))
//        imageView.contentMode = .scaleAspectFit
//        imageView.tintColor = .black
//
//        btn.addSubview(imageView)
//        imageView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.centerY.equalToSuperview()
//            make.height.equalToSuperview()
//        }
//
//        return btn
//    }()
    
//    private let addPersonBtn = UIButton().then {
//        $0.setTitle("인원 추가", for: .normal)
//        $0.setTitleColor(.black, for: .normal)
//        $0.layer.cornerRadius = 8
//        $0.backgroundColor = UIColor(white: 0.92, alpha: 1)
//    }
    
//    private let resetBtn = UIButton().then {
//        let imgView = UIImageView(image: UIImage(systemName: "arrow.counterclockwise"))
//        imgView.tintColor = .red
//        imgView.contentMode = .scaleAspectFit
//
//        $0.addSubview(imgView)
//        imgView.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview().inset(6)
//        }
//
//        $0.layer.cornerRadius = 8
//        $0.backgroundColor = UIColor(white: 0.88, alpha: 1)
//    }
    
    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = UIColor(white: 0.85, alpha: 0.9)
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = false
    }
    
    private let bottomContainerView = UIView()
//        .then {
//        $0.backgroundColor = .white
//    }
//        .then {
//        $0.backgroundColor = .white
//    }
    
    //    private let gradientView = UIView().then {
    private let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 20)).then {
        let colorTop =  UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 255.5/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.frame = $0.frame
        
        $0.layer.addSublayer(gradientLayer)
        
    }
    
    private let remainingView = UIView().then {
        $0.backgroundColor = .white
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
    }
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

        // MARK: - 색상 원상태로 변경
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
        
        return CGSize(width: Int(view.frame.width) - 30, height: 30)
//        return CGSize(width: Int(view.frame.width) - 30, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DutchUnitController {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("kind: \(kind)")
        
        if kind == "UICollectionElementKindSectionHeader" {
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PersonDetailHeader.headerIdentifier, for: indexPath) as! PersonDetailHeader
            
            header.headerDelegate = self
            header.spentAmountTF.delegate = self
            header.spentPlaceTF.delegate = self
            
//            if dutchUnit == nil {
            if dutchUnit == nil && hasLoadedFirst == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.needingDelegate?.presentNumberPad()
                    header.blinkSpentAmount()
                    header.spentAmountTF.becomeFirstResponder()
                }
                
                header.viewModel = PersonHeaderViewModel(spentAmt: "0", spentPlace: spentPlace, spentDate: Date())
                
                hasLoadedFirst = false
                
            } else {
                let amtString = spentAmount.addComma()
                header.viewModel = PersonHeaderViewModel(spentAmt: amtString, spentPlace: spentPlace, spentDate: spentDate)
                
            }
            
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PersonDetailFooter.footerIdentifier, for: indexPath) as! PersonDetailFooter
            footer.footerDelgate = self
            return footer
        }
    }
    
//    invalidate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 360)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 180)
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
        
            self.personDetailCollectionView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalToSuperview()
            }
        
        updateWithAnimation()
        
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
        print("textField returned")
        // adding people succeessively, tag 100: Alert Controller
        
        // header.spentPlaceTF
        if textField.tag == 1 {
            self.spentPlace = textField.text!
            print("text input: \(textField.text!)")
            self.dismissKeyboardOnly()
            spentPlaceTFJustTapped = true
        }
        
        if textField.tag == 100 {
            addPersonAction(with: textField.text!) // alert's tag
            textField.text = ""
            
            return false
        } else {
            return true
        }
    }
    

    // Cell 의 TF 누를 때 Trigger. 여기서.. 구분해주면 되겠다 .
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // FIXME: dismissKeyboardOnly, dismissKeyboard 두개 구분해서 사용하기.
        if let tf = textField as? PriceTextField {
            
            if tf.tag == -1 {
                print("header spentAmt tapped!")
            } else {
                moveUpCollectionView()
            }
            
            
            if isShowingKeyboard {
                //FIXME: Fatal Error !
                guard let prevSelectedPriceTF = selectedPriceTF else { fatalError() }
                updateDictionary(tag: prevSelectedPriceTF.tag, currentText: prevSelectedPriceTF.text!)
                
                prevSelectedPriceTF.textColor = .black
            }
            
            // NeedingController delegate
            delegate?.initializeNumberText()
            
            self.dismissKeyboardOnly()
            
            needingDelegate?.presentNumberPad()
            
            // TODO: move up collectionview
            

            
            updateWithAnimation()
            
            isShowingKeyboard = true
            
            selectedPriceTF = tf
            
            // MARK: - 입력할 때 색상 변경
            selectedPriceTF?.backgroundColor = UIColor(rgb: 0xF2F2F2)
            selectedPriceTF?.textColor = UIColor(white: 0.7, alpha: 1)
            
            print("tag : \(textField.tag)")
            print("textField: \(textField)")
            
            return false
            
        } else {
            
            needingDelegate?.hideNumberPad()
            
            moveDownCollectionView()
            
            updateWithAnimation()
            
            isShowingKeyboard = false
            
            print("tag : \(textField.tag)")
            return true
        }
    }
}

func setGradientBackground() {
    let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
    let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
                
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [colorTop, colorBottom]
    gradientLayer.locations = [0.0, 1.0]
    
}


extension DutchUnitController {
    private func moveUpCollectionView() {
        self.personDetailCollectionView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalToSuperview().offset(-190)
        }
    }
    
    private func moveDownCollectionView() {
        self.personDetailCollectionView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    private func updateWithAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension UICollectionView {
    func reloadItems(inSection section: Int) {
        reloadItems(at: (0 ..< numberOfItems(inSection: section)).map {
            IndexPath(item: $0, section: section)
        })
    }
}
