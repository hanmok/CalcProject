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

extension DutchUnitController: PersonDetailFooterDelegate {
    func addPersonAction() {
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
    
    var isShowingKeyboard = false
    
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
            let amt = sumOfIndividual.applyCustomNumberFormatter()
            let totalAmt =  UserDefaultSetup.appendProperUnit(to: amt)
            
            spentAmountLabel.text = totalAmt
            self.setConfirmBtnState(isActive: sumOfIndividual.isAlmostZero == false )

        }
    }
    
    var detailAttendingDic: [Idx: Bool] = [:]
    
    var spentAmount: Double = 0
    
    var spentPlace: String = ""
    var spentDate: Date = Date()
    
    var sumOfIndividual: Double = 0
    
    
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
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        
        personDetailCollectionView.contentInsetAdjustmentBehavior = .never
        
        navigationController?.navigationBar.isHidden = true
         
        view.backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
        
        setupBindings()
        
        viewModel.initializePersonDetails(gathering: gathering, dutchUnit: dutchUnit)
        
        setupDictionary()
        
        viewModel.setupInitialState { [weak self] initialState, newDutchUnitIndex in
            guard let self = self else { return }
            
            if let initialState = initialState {
                self.spentPlace = initialState.place
                self.spentAmount = initialState.amount // Double, String
                self.spentDate = initialState.date
                
            } else {
                guard let numOfElements = newDutchUnitIndex else { return }
                self.spentPlace = "\(ASD.element.localized) \(numOfElements)"
            }
        }
        
        setupLayout()
        setupTargets()
        
        self.setupCollectionView()
                
        // TODO: 이거.. 여기서 하면 안될 것 같은데 ?? 구조가 많이 바뀌었음.
        
        
        updateConditionState = { [weak self] condition in
            guard let self = self else { return }
            self.setConfirmBtnState(isActive: condition)
        }
        
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(otherViewTapped))
        
        view.addGestureRecognizer(tap2)
        
        if dutchUnit != nil {
            setConfirmBtnState(isActive: true)
        }
        
        view.insetsLayoutMarginsFromSafeArea = false
        
        spentPlaceTF.delegate = self
    }
    
    private func setConfirmBtnState(isActive: Bool) {
        confirmBtn.isUserInteractionEnabled = isActive
        DispatchQueue.main.async {
            self.confirmBtn.setTitleColor(isActive ? .black : UIColor(white: 0.2, alpha: 1), for: .normal)

            self.confirmBtn.backgroundColor = isActive ? ColorList().bgColorForExtrasLM : UIColor(white: 0.45, alpha: 0.9)
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
        
        if spentPlaceTFJustTapped == false {
            
            dismissKeyboard()
            
            guard let validSelectedPriceTF = selectedPriceTF else { return }
            
            let currentText = validSelectedPriceTF.text!
            
            updateDictionary(tag: validSelectedPriceTF.tag, currentText: currentText)
            
            // meaningless..
            if validSelectedPriceTF.tag != -1 {
                
                let selectedRow = validSelectedPriceTF.tag
                personDetailCollectionView.reloadItems(at: [IndexPath(row:selectedRow, section: 0)])
            }
        }
    }
    
    

    func updateDictionary(tag: Int, currentText: String) {
        detailPriceDic[tag] = currentText.convertToDouble()
    }
    
    var updateConditionState: (Bool) -> Void = { _ in }
    
    private func setupBindings() {
        
        viewModel.updateCollectionView = { [weak self] in
            guard let self = self else { return }
            self.relocateCollectionView()
        }
        
        viewModel.changeableConditionState = {[weak self] bool in
            guard let self = self else { return }
            self.setConfirmBtnState(isActive: bool)
        }
        
    }
    
    
    private func setupTargets() {
        
        confirmBtn.addTarget(nil, action: #selector(confirmTapped), for: .touchUpInside)
        
        dismissBtn.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
    }
    
    // 좀.. 이상한데 ??
    @objc func selectAllText(_ sender: UITextField) {
        sender.selectAll(nil)
        
        spentPlaceTFJustTapped = true
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            self.spentPlaceTFJustTapped = false
        }
    }
    
    

    @objc private func presentAddingPeopleAlert() {
        let alertController = UIAlertController(title: ASD.addingPeople.localized, message: ASD.addingPersonMsg.localized, preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = ASD.name.localized
            textField.tag = 100
            textField.delegate = self
        }
        
        let saveAction = UIAlertAction(title: ASD.add.localized, style: .default) { [self] alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
        
            let newPersonName = textFieldInput.text!
            
            addPersonAction(with: newPersonName)
        }
        
        let cancelAction = UIAlertAction(title: ASD.cancel.localized, style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
    

    @objc func resetState() {
        viewModel.reset {
            DispatchQueue.main.async {
                self.personDetailCollectionView.snp.remakeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.equalToSuperview()
                }
            }
        }
    }
    
    
    @objc func confirmTapped() {
        
        var totalAmt = 0.0
        for (_, v) in detailPriceDic {
            totalAmt += v
        }
        print("spentPlace: \(self.spentPlace)")
        viewModel.updateDutchUnit(spentPlace: self.spentPlace,
                                  spentAmount: totalAmt,
                                  spentDate: self.spentDate,
                                  detailPriceDic: detailPriceDic,
                                  detailAttendingDic: detailAttendingDic) { [weak self] in
            
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            self.needingDelegate?.dismissNumberLayer()
        }
    }
    
    @objc func dismissAction() {
        addingDelegate?.dismissChildVC()

        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
        
        needingDelegate?.hideNumberPad()
        
        updateWithAnimation()
    }
    
    func dismissKeyboardOnly() {
        view.endEditing(true)
    }
    
    private func addPersonAction(with newName: String) {
        guard newName.count != 0 else { fatalError("Name must have at least one character") }
        
        viewModel.addPerson(name: newName) { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let msg):
    
                    self.showNewToast(msg: msg)
                
                DispatchQueue.main.async {
                    self.personDetailCollectionView.reloadItems(inSection: 0)

                }
                
                self.updateWithAnimation()
                
            case .failure(let errorMsg):
                    self.showNewToast(msg: errorMsg.localizedDescription)
            }
        }
    }
    
    private func relocateCollectionView() {
        DispatchQueue.main.async {
            self.personDetailCollectionView.reloadItems(inSection: 0)
        }
    }
    
    
    private func setupCollectionView() {
        personDetailCollectionView.register(PersonDetailCell.self, forCellWithReuseIdentifier: cellIdentifier)
        personDetailCollectionView.delegate = self
        personDetailCollectionView.dataSource = self
        
        personDetailCollectionView.register(PersonDetailFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PersonDetailFooter.footerIdentifier)
        
        relocateCollectionView()
    }

    
    private func setupLayout() {
        
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        
        view.addSubview(dismissBtn)
        
        dismissBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(10)
            
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        
        [personNameGuideLabel, spentAmtGuideLabel, attendedGuideLabel].forEach { self.view.addSubview($0)}
        
        personNameGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(dismissBtn.snp.bottom).offset(30)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(15)
            make.width.equalTo(70)
        }
        
        attendedGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(personNameGuideLabel.snp.top)
            make.height.equalTo(30)
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(60)
        }
        
        spentAmtGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(personNameGuideLabel.snp.top)
            make.height.equalTo(30)
            make.leading.equalTo(personNameGuideLabel.snp.trailing).offset(10)
            make.trailing.equalTo(attendedGuideLabel.snp.leading).offset(-20)
        }
        
        view.addSubview(personDetailCollectionView)
        
        personDetailCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(personNameGuideLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }

        view.addSubview(overallInfoContainerView)
        
        overallInfoContainerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(220)
        }
        
        
        [spentPlaceLabel, spentPlaceTF,
         spentAmountGuideLabel, spentAmountLabel,
         spentDateLabel, spentDatePicker,
         confirmBtn
        ].forEach {
            overallInfoContainerView.addSubview($0)
        }
        
        spentPlaceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(20)
        }
        
        spentPlaceTF.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(30)
            make.leading.equalTo(spentPlaceLabel.snp.trailing).offset(10)
            make.height.equalTo(30)
            make.top.equalTo(spentPlaceLabel.snp.top)
        }
        
        
        spentAmountGuideLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.top.equalTo(spentPlaceLabel.snp.bottom).offset(10)
        }
        
        spentAmountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(30)
            make.leading.equalTo(spentPlaceLabel.snp.trailing).offset(10)
            make.height.equalTo(30)
            make.top.equalTo(spentAmountGuideLabel.snp.top)
        }
        
        spentDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.top.equalTo(spentAmountLabel.snp.bottom).offset(10)
        }
        
        spentDatePicker.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(30)
            make.leading.equalTo(spentPlaceLabel.snp.trailing).offset(10)
            make.height.equalTo(30)
            make.top.equalTo(spentDateLabel.snp.top)
        }
        
        
        confirmBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
    
    
    // MARK: - UI Properties
    
    private let dismissBtn: UIButton = {
        let btn = UIButton()
        let imageView = UIImageView(image: UIImage(systemName: "chevron.left"))
        imageView.contentMode = .scaleAspectFit

        imageView.tintColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGLight, onLight: .emptyAndNumbersBGDark)

        btn.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }

        return btn
    }()
    
    private let personNameGuideLabel = UILabel().then {
        $0.text = "이름"
        $0.textAlignment = .left
        $0.textColor = UIColor(white: 0.3, alpha: 1)
    }
    
    private let spentAmtGuideLabel = UILabel().then {
        $0.text = "지출 금액"
        $0.textAlignment = .right
        $0.textColor = UIColor(white: 0.3, alpha: 1)
    }
    
    private let attendedGuideLabel = UILabel().then {
        $0.text = "참가"
        $0.textAlignment = .center
//        $0.textColor = .black
        $0.textColor = UIColor(white: 0.3, alpha: 1)
    }
    
    private lazy var personDetailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = true
        cv.showsVerticalScrollIndicator = true
        cv.backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
        return cv
    }()
    
    
    private let confirmBtn = UIButton().then {
        $0.setTitle(ASD.confirm.localized, for: .normal)
        $0.backgroundColor = UIColor(white: 0.65, alpha: 0.9)
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = false
    }
    
    private let bottomContainerView = UIView().then {
        $0.backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
    }
    
    private let overallInfoContainerView = UIView().then {
        $0.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.2)
        $0.layer.cornerRadius = 16
    }
    
    /// 지출 항목 Guide
    private let spentPlaceLabel = UILabel().then {
        $0.text = ASD.spentFor.localized

        if UserDefaultSetup().darkModeOn {
            $0.textColor = .semiResultTextDM
        }
    }
    
    /// 지출 항목 TextField
    private let spentPlaceTF = UITextField(withPadding: true).then {
        $0.textAlignment = .right

        $0.backgroundColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.5, alpha: 1), onLight: UIColor(rgb: 0xE7E7E7))
        
        $0.textColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.8, alpha: 1), onLight: .black)
        $0.tag = 1
        $0.layer.cornerRadius = 5
        $0.autocorrectionType = .no
    }
    
    private let spentAmountGuideLabel = UILabel().then {
        $0.text = ASD.spentAmt.localized

        if UserDefaultSetup().darkModeOn {
            $0.textColor = .semiResultTextDM
        }
    }
    
    /// 지출 금액 Label
    private let spentAmountLabel = UILabel().then {

        $0.textAlignment = .right
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
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func completeAction3() {
        otherViewTapped()
    }
    
    // MARK: - NeedingController Delegate
    override func updateNumber(with numberText: String) {
        
        guard let selectedPriceTF = selectedPriceTF else { return }
        
        selectedPriceTF.text = numberText
    }
}



// MARK: - UICOllectionView Delegates
extension DutchUnitController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.personDetails.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PersonDetailCell
        
        cell.spentAmountTF.tag = indexPath.row
        cell.attendingBtn.tag = indexPath.row
//        cell.fullPriceBtn.tag = indexPath.row
        
        cell.spentAmountTF.delegate = self
        
        let target = viewModel.personDetails[indexPath.row]
        
        let personDetail = viewModel.personDetails[indexPath.row]
        
        cell.viewModel = PersonDetailCellViewModel(personDetail: personDetail)

        var text = (detailPriceDic[indexPath.row] ?? 0.0).applyCustomNumberFormatter()
        
        text.applyNumberFormatter()
        
        cell.delegate = self
                
        cell.spentAmountTF.text = UserDefaultSetup.appendProperUnit(to: text)

        // MARK: - 색상 원상태로 변경
        
        cell.spentAmountTF.textColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.8, alpha: 1), onLight: .black)
        
        cell.spentAmountTF.backgroundColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.5, alpha: 1), onLight: UIColor(rgb: 0xE7E7E7))
        
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

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DutchUnitController {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PersonDetailFooter.footerIdentifier, for: indexPath) as! PersonDetailFooter
            footer.footerDelgate = self
            return footer
    }
    
    
    // Footer Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 180)
    }
}


// MARK: - PersonDetailCell Delegate
extension DutchUnitController: PersonDetailCellDelegate {
    
    func updateAttendingState(with tag: Int, to isAttending: Bool) {
        detailAttendingDic[tag] = isAttending
    }
}




// MARK: - TextField Delegate

extension DutchUnitController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // adding people succeessively, tag 100: Alert Controller
        
        // header.spentPlaceTF
        if textField.tag == 1 {
            self.spentPlace = textField.text!
            print("spentPlace flag 1, text: \(self.spentPlace)")
            self.dismissKeyboardOnly()
            spentPlaceTFJustTapped = true
        }
        print("spentPlace flag 2, text: \(self.spentPlace)")
        
        // new person name TF
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
            
            selectedPriceTF?.backgroundColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.85, alpha: 1), onLight: UIColor(rgb: 0xF2F2F2))
            
            selectedPriceTF?.textColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.15, alpha: 1), onLight: UIColor(white: 0.7, alpha: 1))
            
            return false
            
        } else {
            
            needingDelegate?.hideNumberPad()
            
//            moveDownCollectionView()
            
            updateWithAnimation()
            
            isShowingKeyboard = false
            
            return true
        }
    }
}

func setGradientBackground() {
    let colorTop =  UIColor(red: 1.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
    let colorBottom = UIColor(red: 1.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
                
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
