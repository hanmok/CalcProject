//
//  DutchpayController.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/19.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit


enum PopupScreens {
    case AddingNewDutchpay
    case Modifying
}


protocol DutchpayControllerDelegate: AnyObject {
    func shouldHideMainTab(_ bool: Bool)
    
    func shouldShowSideView(_ bool: Bool)
}


class DutchpayController: UIViewController {
    
    var viewModel: DutchpayViewModel
    
    let updateUserDefaultNotification = Notification.Name(rawValue: NotificationKey.sendUpdatingUserDefaultNotification.rawValue)
    
    var mainTabController: MainTabController
//    var sideViewController: SideViewController?
    
//    var currentGathering
    
    // MARK: - Properties
    weak var dutchToMainTapDelegate: DutchpayControllerDelegate?
    
    var participantsController: ParticipantsController?
    
    //    let customAlert = MyAlert()
    
//    var popupToShow: PopupScreens?
    
    //    let persistenceManager: PersistenceController
    
    var userDefaultSetup = UserDefaultSetup()
    
    let colorList = ColorList()
    
    var isShowingSideController = false
    var shouldShowSideView = false
    
    var isAdding = false
    
    var isShowingParticipants = false
    
    private var participantsNavController: UINavigationController?
    
    // MARK: - LifeCycle
    
    init(mainTabController: MainTabController) {
        
        self.mainTabController = mainTabController
        
        self.viewModel = DutchpayViewModel()
        
        super.init(nibName: nil, bundle: nil)
        
        self.mainTabController.mainToDutchDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
        viewModel.viewDidLoadAction()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    
//        if userDefaultSetup.darkModeOn {
//            view.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
//        } else {
//            view.backgroundColor =
//        }
    }
    
    private let topView = UIView().then {

        if UserDefaultSetup().darkModeOn {
            $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        } else{
            $0.backgroundColor = UIColor.emptyAndNumbersBGLight
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        if userDefaultSetup.darkModeOn {
            view.backgroundColor = colorList.bgColorForExtrasDM
        } else {

            view.backgroundColor = colorList.bgColorForExtrasLM
        }
        
        registerTableView()
        setupLayout()
        setupAddTargets()
        
        setupBindings()
        
        view.insetsLayoutMarginsFromSafeArea = false
        
        // FIXME: Test Code
//        userDefaultSetup.isKorean = false
        
//        NotificationCenter.default.addObserver(self, selector: #selector(DutchpayController.updateModes(notification:)), name: updateUserDefaultNotification, object: nil)
    }
    
//    @objc func updateModes(notification: NSNotification) {
//        guard let darkModeInfo = notification.userInfo?["isDarkOn"] as? Bool else {
//            print("something is wrong with isDarkOn in BaseViewController")
//            return
//        }
//        guard let soundModeInfo = notification.userInfo?["isSoundOn"] as? Bool else {
//            print("something is wrong with soundMode in BaseViewController")
//            return
//        }
//        guard let notificationModeInfo = notification.userInfo?["isNotificationOn"] as? Bool else {
//            print("something is wrong with soundMode in BaseViewController")
//            return
//        }
//
//
//
//    }
    
    
    private func setupBindings() {
        
        viewModel.updateDutchUnitsHandler = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dutchTableView.reloadData()
            }
        }
        
        viewModel.updateGatheringHandler = { [weak self] gatheringInfo in
            guard let self = self else { return }
            
            self.updateGatheringName(with: gatheringInfo.title)
            self.updateSpentTotalPrice(to: gatheringInfo.totalPrice)
            // TODO: update TableView
            // TODO: Separate changing gathering infos only with dutchUnits
            
            DispatchQueue.main.async {
                self.dutchTableView.reloadData()
            }
        }
    }
    
    
    private func setupAddTargets() {
        historyBtn.addTarget(self, action: #selector(historyBtnAction), for: .touchUpInside)
        
        resetGatheringBtn.addTarget(self, action: #selector(resetGatheringBtnAction), for: .touchUpInside)
        
        
        dutchUnitPlusBtn.addTarget(self, action: #selector(handleAddDutchUnit), for: .touchUpInside)
        
        titleLabelBtnInHeader.addTarget(self, action: #selector(changeGatheringNameAction), for: .touchUpInside)
        
        groupBtnInHeader.addTarget(self, action: #selector(editPeopleBtnAction), for: .touchUpInside)
        
        calculateBtn.addTarget(self, action: #selector(calculateBtnAction), for: .touchUpInside)
        
        blurredView.addTarget(self, action: #selector(blurredViewTapped), for: .touchUpInside)
    }
    
    private func updateSpentTotalPrice(to amountStr: String) {
        DispatchQueue.main.async {
            self.totalPriceValueLabel.text = amountStr
        }
    }
    
    
    private func presentResetAlert() {
        let alertController = UIAlertController(title: ASD.resetGatheringTitle.localized, message: ASD.resetGatheringMsg.localized, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: ASD.reset.localized, style: .destructive) { _ in
            self.resetAction()
        }
        
        let cancelAction = UIAlertAction(title: ASD.cancel.localized, style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true)
    }
    
    private func resetAction() {
        viewModel.resetGatheringAction(needGathering: true) { [weak self] in
            // TODO: reset tableView
//            dutchTableView
            self?.dutchTableView.reloadData()
//            self?.updateGatheringName(with: "")
            
        }
    }
    // MARK: - Actions
    @objc func resetGatheringBtnAction() {
        
        guard let currentGathering = viewModel.gathering else { return }
        
        if !(currentGathering.title == "" && currentGathering.dutchUnits.count == 0 && currentGathering.people.count == 0) {
            self.presentResetAlert()
        }
    }
    
    
    @objc func blurredViewTapped() {
        if isShowingSideController {
            isShowingSideController = false
            hideSideController()
        }
    }
    
    @objc func calculateBtnAction() {
        
        guard let gathering = viewModel.gathering else { fatalError() }
        
        let resultVC = ResultViewController(gathering: gathering)
        resultVC.addingDelegate = self

        navigationController?.pushViewController(resultVC, animated: true)
        dutchToMainTapDelegate?.shouldHideMainTab(true)
        
    }
    
    @objc func editPeopleBtnAction() {
        
        viewModel.createIfNeeded()
        
        guard let gathering = viewModel.gathering else {fatalError()}
        
        presentParticipantsController(with: gathering.sortedPeople)
    }
    
    @objc func historyBtnAction() {
        showSideController()
    }
    
    
    @objc private func changeGatheringNameAction() {
        
        self.presentAskingGatheringName { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let newName):
                self.viewModel.changeGatheringNameAction(newName: newName)
                
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
    }
    
    @objc func handleAddDutchUnit() {
        
        viewModel.addDutchUnit(needGathering: true)
        // TODO: Add DutchUnit
        presentDutchUnitController()
        
    }
    
    private func presentDutchUnitController(selectedUnit: DutchUnit? = nil) {
        // MARK: - 이미 하나는 어디선가 가지고 있어야함.
        
        guard let gathering = viewModel.gathering else { fatalError() }
        
        let addingUnitController = DutchUnitController(
            initialDutchUnit: selectedUnit,
            gathering: gathering
        )
        
        addingUnitController.addingDelegate = self
        addingUnitController.dutchDelegate = self
        
        let numLayerController = NumberLayerController(
            bgColor: UIColor(white: 0.7, alpha: 1),
            presentingChildVC: addingUnitController
        )
        
//        numLayerController.childDelegate = addingUnitController
        numLayerController.childDelegate = addingUnitController as? NumberLayerToChildDelegate
        
        addingUnitController.needingDelegate = numLayerController
        
        navigationController?.pushViewController(numLayerController, animated: true)
        
        navigationController?.navigationBar.isHidden = true
        
        dutchToMainTapDelegate?.shouldHideMainTab(true)
        
        numLayerController.parentDelegate = self
    }
    
    
    // MARK: - Helper Functions
    
    private func registerTableView() {
        dutchTableView.register(DutchTableCell.self, forCellReuseIdentifier: DutchTableCell.identifier)
        dutchTableView.delegate = self
        dutchTableView.dataSource = self
        
        dutchTableView.rowHeight = 70
    }
    
    
    private func updateGatheringName(with title: String) {

        let styleCenter = NSMutableParagraphStyle()
        styleCenter.alignment = NSTextAlignment.center
        
        let attrTitle = NSAttributedString(string: title, attributes: [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .paragraphStyle: styleCenter,
            .foregroundColor: userDefaultSetup.darkModeOn ? UIColor.semiResultTextDM : .black
        ])
        
        DispatchQueue.main.async {
            self.titleLabelBtnInHeader.setAttributedTitle(attrTitle, for: .normal)
        }
    }
    
    
    private func removeChildVC() {
        if self.children.count > 0 {
            let viewControllers: [UIViewController] = self.children
            for eachVC in viewControllers {
                eachVC.willMove(toParent: nil)
                eachVC.view.removeFromSuperview()
                eachVC.removeFromParent()
            }
        }
    }
    
    private func presentParticipantsController(with people: [Person]) {
        
        // MARK: - 이게 여기 있으면 안됨. 이미 하나는 가지고 있어야함.
        // ???
        // TODO: Need Gathering
        participantsController = ParticipantsController(currentGathering: viewModel.gathering!)
        participantsController!.delegate = self
        participantsController!.addingDelegate = self
        
        navigationController?.pushViewController(participantsController!, animated: true)
        dutchToMainTapDelegate?.shouldHideMainTab(true)
        
    }
    
    
    private func hideSideController() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurredView.backgroundColor = UIColor(white: 1, alpha: 0)
        }, completion: { done in
            if done {
                self.blurredView.isHidden = true
                self.isShowingSideController = false
            }
        })
        
        dutchToMainTapDelegate?.shouldShowSideView(false)
    }
    
    private func showSideController() {
        
        dutchToMainTapDelegate?.shouldShowSideView(true)
        
        UIView.animate(withDuration: 0.3) {
            self.blurredView.isHidden = false // 이거.. ;;
            self.blurredView.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
            
        } completion: { done in
            if done {
                self.isShowingSideController = true
            }
        }
    }
    
    func removeChildrenControllers() {
        isShowingParticipants = false
    }
    
    
    // MARK: - UI Properties
    
    private let wholeContainerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 60)).then {
//        $0.backgroundColor = UIColor(white: 0.8, alpha: 1)
//        $0.backgroundColor = .white
//        $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        if UserDefaultSetup().darkModeOn {
            $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        } else{
            $0.backgroundColor = UIColor.emptyAndNumbersBGLight
        }
    }
    
    private let blurredView = UIButton().then {
        $0.isHidden = true
        $0.backgroundColor = UIColor(white: 1, alpha: 0)
    }
    
    private let totalPriceContainerView = UIView().then {
//        $0.backgroundColor = .white
//        $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        if UserDefaultSetup().darkModeOn {
            $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        } else{
            $0.backgroundColor = UIColor.emptyAndNumbersBGLight
        }
        
        $0.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        $0.layer.cornerRadius = 8
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    let historyBtn: UIButton = {
        let btn = UIButton()
        
        let innerImage = UIImageView(image: UIImage(systemName: "line.horizontal.3")!)
        
        innerImage.contentScaleFactor = 0.7
        
        innerImage.tintColor = ColorList().bgColorForExtrasDM
        
        
        btn.addSubview(innerImage)
        
        innerImage.snp.makeConstraints { make in
//            make.width.height.equalTo(30)
            make.width.height.equalToSuperview()
//            make.center.equalTo(circle)
            make.center.equalToSuperview()
        }
        
        return btn
    }()
    
    let resetGatheringBtn: UIButton = {
        let btn = UIButton()

        let innerImage = UIImageView(image: UIImage(systemName: "multiply")!)
        
        innerImage.tintColor = UIColor(red: 0.95, green: 0, blue: 0, alpha: 1)

        btn.addSubview(innerImage)

        innerImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalToSuperview().dividedBy(2)
        }
        
        btn.backgroundColor = UserDefaultSetup().darkModeOn ? UIColor.operatorsBGDark : UIColor.extrasBGMiddle
        
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 8
        
        return btn
    }()
    
    private let titleLabelBtnInHeader = UIButton()
    
    private let groupBtnInHeader = UIButton().then {
        let innerImage = UIImageView(image: UIImage(systemName: "person.3.fill")!)
        innerImage.contentMode = .scaleAspectFit
        
//        innerImage.tintColor = .black
        innerImage.tintColor = UserDefaultSetup().darkModeOn ? UIColor.resultTextDM : UIColor.resultTextLM
        
        $0.addSubview(innerImage)
        innerImage.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private let mainContainer = UIView().then {
//        $0.backgroundColor = UIColor.emptyAndNumbersBGDark
//        if UserDefaultSetup().darkModeOn {
//            $0.backgroundColor = UIColor.emptyAndNumbersBGDark
//        } else{
//            $0.backgroundColor = UIColor.emptyAndNumbersBGLight
//        }
        
        $0.backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
    }
    
    private let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 60)).then {

//        $0.backgroundColor = .white
//        $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        if UserDefaultSetup().darkModeOn {
            $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        } else{
            $0.backgroundColor = UIColor.emptyAndNumbersBGLight
        }
        
        $0.addBorders(edges: .bottom, color: UIColor(white: 0.8, alpha: 0.9))
    }
    
    private let dutchUnitPlusBtn: UIButton = {
        let btn = UIButton()
        
        let plusImage = UIImageView(image: UIImage(systemName: "plus.circle"))
//        plusImage.tintColor = ColorList().bgColorForExtrasMiddle
        plusImage.tintColor = UIColor.extrasBGMiddle
        
        let removingLineView = UIView()
//        removingLineView.backgroundColor = .white
//        removingLineView.backgroundColor = .clear
        
        removingLineView.backgroundColor = UserDefaultSetup().darkModeOn ? UIColor.emptyAndNumbersBGDark : .emptyAndNumbersBGLight
        
        btn.addSubview(removingLineView)
        removingLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
            make.centerY.equalToSuperview()
        }
        
        btn.addSubview(plusImage)
        plusImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        return btn
    }()
    
    
    
    private let dutchTableView = UITableView().then {
//        $0.backgroundColor = .white
//        $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        if UserDefaultSetup().darkModeOn {
            $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        } else{
            $0.backgroundColor = UIColor.emptyAndNumbersBGLight
        }
    }
    
    private let tableViewBottomBorder = UIView().then {
//        $0.backgroundColor = UIColor(white: 0.8, alpha: 0.7)
        if UserDefaultSetup().darkModeOn {
            $0.backgroundColor = UIColor.emptyAndNumbersBGLight
        } else{
            $0.backgroundColor = UIColor.emptyAndNumbersBGDark
        }
    }
    
    private let totalPriceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 32)
        $0.textAlignment = .center
        $0.textColor = UserDefaultSetup().darkModeOn ? UIColor.resultTextDM : UIColor.resultTextLM
    }
    
    private let totalPriceValueLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 32)
        $0.textAlignment = .right
        $0.textColor = UserDefaultSetup().darkModeOn ? UIColor.resultTextDM : UIColor.resultTextLM
    }
    
    private let calculateBtn = UIButton().then {
        
        let attr = NSMutableAttributedString(string: ASD.calculate.localized, attributes: [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: UserDefaultSetup().darkModeOn ? UIColor.white : UIColor.black
        ]
        )
        
        $0.setAttributedTitle(attr, for: .normal)
        
//        $0.backgroundColor = UIColor(white: 0.9, alpha: 1)
    
        $0.backgroundColor = UserDefaultSetup().darkModeOn ? UIColor.extrasBGDark : UIColor.extrasBGLight
        
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private func setupLayout() {
        let allViews = view.subviews
        
        allViews.forEach {
            $0.removeFromSuperview()
        }
        
        view.addSubview(wholeContainerView)
        view.addSubview(topView)
        
        wholeContainerView.addSubview(mainContainer)
        
        mainContainer.addSubview(totalPriceContainerView)
        mainContainer.addSubview(calculateBtn)
        mainContainer.addSubview(resetGatheringBtn)
        
        view.addSubview(blurredView)
        // safeArea on the bottom
        
        wholeContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
//            make.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(wholeContainerView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        mainContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
        
        resetGatheringBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        calculateBtn.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.leading.equalToSuperview()
            make.trailing.equalTo(resetGatheringBtn.snp.leading).inset(-10)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        
        [totalPriceLabel, totalPriceValueLabel].forEach {
            self.totalPriceContainerView.addSubview($0)
        }
        
        totalPriceContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(calculateBtn.snp.top).offset(-20)
            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(50)
            make.height.equalTo(70)
        }
        
        totalPriceLabel.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2.1)
            make.height.equalTo(50)
        }
        
        totalPriceValueLabel.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
//            make.width.equalToSuperview().dividedBy(2.1)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        
        totalPriceContainerView.addSubview(tableViewBottomBorder)
        
        tableViewBottomBorder.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        mainContainer.addSubview(headerContainer)
        headerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        [
            titleLabelBtnInHeader,
            groupBtnInHeader,
            historyBtn
        ].forEach { self.headerContainer.addSubview($0) }
        
        titleLabelBtnInHeader.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalToSuperview().dividedBy(2)
        }
        
        groupBtnInHeader.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
            make.height.width.equalTo(30)
        }
        
        historyBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        mainContainer.addSubview(dutchTableView)
        dutchTableView.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(totalPriceContainerView.snp.top)
        }
        
        mainContainer.addSubview(dutchUnitPlusBtn)
        dutchUnitPlusBtn.snp.makeConstraints { make in
            make.centerY.equalTo(totalPriceContainerView.snp.top)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        blurredView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        setupHeaderView()
    }
    
    private func setupHeaderView() {
        
    }
}


extension DutchpayController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        totalPriceLabel.isHidden = (viewModel.dutchUnits.count == 0)
        return viewModel.dutchUnits.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DutchTableCell.identifier, for: indexPath) as! DutchTableCell
        
        // FIXME: Fatal Error! index out of range!
        let dutchUnit = viewModel.dutchUnits[indexPath.row]
        
        cell.viewModel = DutchTableCellViewModel(dutchUnit: dutchUnit)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UserDefaultSetup.applyColor(onDark: .extrasBGDark, onLight: .extrasBGLight)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            
            self.viewModel.deleteDutchUnitAction(idx: indexPath.row)
            completionhandler(true)
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete])
        
        return rightSwipe
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let selectedIndex = indexPath.row
        guard let gathering = viewModel.gathering else { fatalError() }
        let selectedUnit = gathering.dutchUnits.sorted()[selectedIndex]
        presentDutchUnitController(selectedUnit: selectedUnit)
    }
    
    // Header Height
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


extension DutchpayController: ParticipantsVCDelegate {
    
    func hideParticipantsController() {

    }
    
    func updateParticipants(with participants: [Person]) {
        
        viewModel.updatePeople(updatedPeople: participants)
    }
    
//    func update() {
    func update(gathering: Gathering) {
//        viewModel.viewDidLoadAction(gathering: gathering)
    }
//        viewModel.viewDidLoadAction()
        // 업데이트 어떻게 시켜주지..?? ;;
        
//        viewModel.gathering =
        // Gathering.. ??? ddd
//    }
}


extension DutchpayController: DutchUnitDelegate {
    
    func updateDutchUnit(_ dutchUnit: DutchUnit, isNew: Bool) {
        
        viewModel.updateDutchUnit(dutchUnit: dutchUnit, isNew: isNew)
    }
}

extension DutchpayController: AddingUnitControllerDelegate {
    
    func dismissChildVC() {
        navigationController?.popViewController(animated: true)
        
        dutchToMainTapDelegate?.shouldHideMainTab(false)
    }
}



extension DutchpayController {
    

    
    // Done!
    private func presentAskingGatheringName( completion: @escaping (NewNameAction)) {
        let alertController = UIAlertController(title: ASD.editGatheringName.localized, message: ASD.editGatheringNameMsg.localized, preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = ASD.gatheringName.localized
        }
        
        let saveAction = UIAlertAction(title: ASD.done.localized, style: .default) { alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
            
            let newGroupName = textFieldInput.text!
            
            if newGroupName.count != 0 {
                completion(.success(newGroupName))
            } else {
                completion(.failure(.cancelAskingName))
            }
        }
        
        let cancelAction = UIAlertAction(title: ASD.cancel.localized, style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in
            completion(.failure(.cancelAskingName))
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
}


extension DutchpayController: NumberLayerToParentDelegate {
    
}


extension Set {
    func setmap<U>(transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.lazy.map(transform))
    }
}


extension DutchpayController: MainTabToDutchDelegate {
    func initializeCurrentGathering() {
        viewModel.resetGatheringAction(needGathering: false) { [weak self] _ in
            guard let self = self else { return }
            self.dutchTableView.reloadData()
            self.updateGatheringName(with: "")
        }
    }
    
    func renameTriggered(target: Gathering) {
        if self.viewModel.gathering == target {
            // update!
            viewModel.gathering = target
        }
    }
    
    func deleteTriggered(target: Gathering) {
        if self.viewModel.gathering == target {
            // update with latest!
            viewModel.fetchLatestGathering()
        }
    }
    
    
    func clearifyBlurredView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.blurredView.backgroundColor = UIColor(white: 1, alpha: 0)
        }, completion: { done in
            if done {
                self.blurredView.isHidden = true
                self.isShowingSideController = false
            }
        })
    }
    
    func updateGatheringFromMainTab(with newGathering: Gathering) {
        self.viewModel.gathering = newGathering
    }
}
