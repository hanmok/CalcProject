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

protocol DutchpayToParticipantsDelegate: AnyObject {
    func updateParticipants3(gathering: Gathering)
}


class DutchpayController: UIViewController {
    
    var viewModel: DutchpayViewModel
    
    var mainTabController: MainTabController
    var sideViewController: SideViewController?
    
//    var currentGathering
    
    // MARK: - Properties
    weak var dutchToMainTapDelegate: DutchpayControllerDelegate?
    weak var dutchToPartiDelegate: DutchpayToParticipantsDelegate?
    
    var participantsController: ParticipantsController?
    
    //    let customAlert = MyAlert()
    
//    var popupToShow: PopupScreens?
    
    //    let persistenceManager: PersistenceController
    
    var userDefaultSetup = UserDefaultSetup()
    
    let colorList = ColorList()
    
    var isShowingSideController = false
    var shouldShowSideView = false
    
    var isAdding = false
    
    var isShowingParticipants = false {
        didSet {
            print("isShowingParticipants changed to \(oldValue)")
        }
    }
    
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
        print("viewWillAppear in DutchpayController called")
        viewModel.viewDidLoadAction()
        
    }
    private let topView = UIView().then {
        $0.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad in DutchpayController called")
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = colorList.bgColorForExtrasLM
        
        print("current People in DutchpayController: \(viewModel.gathering?.people)")
        
        registerTableView()
        setupLayout()
        setupAddTargets()
        
        setupBindings()
        
        view.insetsLayoutMarginsFromSafeArea = false
        
        // for simplicity.
//        handleAddDutchUnit()
    }
    
    
    private func setupBindings() {
        
        viewModel.updateDutchUnits = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dutchTableView.reloadData()
            }
        }
        
        viewModel.updateGathering = { [weak self] gatheringInfo in
            guard let self = self else { return }
            print("gathering flag 3")
            self.updateGatheringName(with: gatheringInfo.title)
            self.updateSpentTotalPrice(to: gatheringInfo.totalPrice)
            // TODO: update TableView
            // TODO: Separate changing gathering infos only with dutchUnits
            
            DispatchQueue.main.async {
                self.dutchTableView.reloadData()
            }
            print("Gathering has updated, current dutchUnit number: \(self.viewModel.dutchUnits)")
        }
        
        
        
        //        viewModel.createGathering = { [weak self ] in
        //            guard let self = self else { return }
        //            // TODO: don't ask Gathering name. Set it to Gatherig n
        
        
        
        
    }
    
    
    private func setupAddTargets() {
        print("setupAddTargets Called !")
        
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
    
    // MARK: - Actions
    @objc func resetGatheringBtnAction() {
        
        viewModel.resetGatheringAction(needGathering: true) { [weak self]
            bool in
        }
    }
    
    
    @objc func blurredViewTapped() {
        print("blurredView Tapped")
        if isShowingSideController {
            
            isShowingSideController = false
            hideSideController()
        }
    }
    
    @objc func calculateBtnAction() {
        
        // MARK: - Original Code
        
//        viewModel.calculateAction(needGathering: true)
        print("calculateBtn Tapped !!")
        
        guard let gathering = viewModel.gathering else { fatalError() }
        
        let resultVC = ResultViewController(gathering: gathering)
        resultVC.addingDelegate = self

        navigationController?.pushViewController(resultVC, animated: true)
        dutchToMainTapDelegate?.shouldHideMainTab(true)
        
        
        print("current Gathering: \(viewModel.gathering)")
        print("current participants: \(viewModel.gathering?.people)")
        
    }
    
    @objc func editPeopleBtnAction() {
        
        viewModel.createIfNeeded()
        
        guard let gathering = viewModel.gathering else {fatalError()}
        
        presentParticipantsController(with: gathering.sortedPeople)
    }
    
    @objc func historyBtnAction() {
        // TODO: Handle
        
        //        dutchToMainTapDelegate?.shouldHideMainTab(true)
        //        dutchToMainTapDelegate?.shouldShowSideView(true)
        showSideController()
        print("historyBtnTapped")
    }
    
    
    @objc private func changeGatheringNameAction() {
        
        self.presentAskingGatheringName { [weak self] result in
            print("gathering name flag 1, result: \(result)")
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
//        viewModel.createIfNeeded()
        
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
        
//        dutchTableView.tableHeaderView = headerContainer
    }
    
    
    private func updateGatheringName(with title: String) {
        print("gathering flag 5")
        let styleCenter = NSMutableParagraphStyle()
        styleCenter.alignment = NSTextAlignment.center
        
        let attrTitle = NSAttributedString(string: title, attributes: [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .paragraphStyle: styleCenter
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
//        viewModel.createIfNeeded()
        
        // TODO: Need Gathering
        participantsController = ParticipantsController(currentGathering: viewModel.gathering!)
        participantsController!.delegate = self
        participantsController!.addingDelegate = self
        
        navigationController?.pushViewController(participantsController!, animated: true)
        dutchToMainTapDelegate?.shouldHideMainTab(true)
        
//        guard let participantsController = participantsController else {
//            fatalError()
//        }
//
//        participantsController.delegate = self
//
//        participantsNavController = UINavigationController(rootViewController: participantsController)
//
//        guard let participantsNavController = participantsNavController else {
//            fatalError()
//        }
//
//        self.addChild(participantsNavController)
//
//        self.mainContainer.addSubview(participantsNavController.view)
//        participantsNavController.didMove(toParent: self)
//
//        participantsNavController.view.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview()
//        }
        
        
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
        
        //        delegate?.dutchpayController(shouldShowSideView: false, dutchManager: dutchManager)
        //        delegate?.shouldShowSideView(_ bool: false)
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
                print("isShowingSideController : \(self.isShowingSideController)")
            }
        }
    }
    
    func removeChildrenControllers() {
        isShowingParticipants = false
    }
    
    
    // MARK: - UI Properties
    
    private let wholeContainerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 60)).then {
//        $0.backgroundColor = UIColor(white: 0.8, alpha: 1)
        $0.backgroundColor = .white
    }
    
    private let blurredView = UIButton().then {
        $0.isHidden = true
        $0.backgroundColor = UIColor(white: 1, alpha: 0)
    }
    
    private let totalPriceContainerView = UIView().then {
        $0.backgroundColor = .white
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
//        let circle = UIImageView(image: UIImage(systemName: "circle.fill")!)
        let innerImage = UIImageView(image: UIImage(systemName: "multiply")!)
//        innerImage

//        innerImage.tintColor = .black
//        innerImage.tintColor = .orange
        
//        innerImage.tintColor = UIColor(red: 0.95, green: 0, blue: 0)
        
        innerImage.tintColor = UIColor(red: 0.95, green: 0, blue: 0, alpha: 1)

        btn.addSubview(innerImage)

        innerImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalToSuperview().dividedBy(2)
        }
        
        btn.backgroundColor = UIColor(white: 0.90, alpha: 1)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 8
        
        return btn
    }()
    
    private let titleLabelBtnInHeader = UIButton()
    
    private let groupBtnInHeader = UIButton().then {
        let innerImage = UIImageView(image: UIImage(systemName: "person.3.fill")!)
        innerImage.contentMode = .scaleAspectFit
        
        innerImage.tintColor = .black
        $0.addSubview(innerImage)
        innerImage.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private let mainContainer = UIView()
    
    private let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 60)).then {

        $0.backgroundColor = .white
        $0.addBorders(edges: .bottom, color: UIColor(white: 0.8, alpha: 0.9))
    }
    
//    private let
    
//    private let groupBtn = UIButton().then {
//
//        let innerImage = UIImageView(image: UIImage(systemName: "person.3.fill")!)
//        innerImage.contentMode = .scaleAspectFit
//
//        innerImage.tintColor = .black
//        $0.addSubview(innerImage)
//        innerImage.snp.makeConstraints { make in
//            make.top.leading.bottom.trailing.equalToSuperview()
//        }
//        $0.isHidden = true
//    }
    
//    private let gatheringPlusBtn: UIButton = {
//        let btn = UIButton()
//
//        let inner = UIImageView(image: UIImage(systemName: "plus.circle"))
//
//        btn.addSubview(inner)
//        inner.snp.makeConstraints { make in
//            make.center.equalTo(btn)
//            make.width.equalTo(btn)
//            make.height.equalTo(btn)
//        }
//
//        return btn
//    }()
    
    private let dutchUnitPlusBtn: UIButton = {
        let btn = UIButton()
        
        let plusImage = UIImageView(image: UIImage(systemName: "plus.circle"))
        plusImage.tintColor = ColorList().bgColorForExtrasMiddle
        
        let removingLineView = UIView()
        removingLineView.backgroundColor = .white
        
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
    
    
    
    private let dutchTableView = UITableView()
    
    private let tableViewBottomBorder = UIView().then {
        $0.backgroundColor = UIColor(white: 0.8, alpha: 0.7)
    }
    
    private let totalPriceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 32)
        $0.textAlignment = .center
    }
    
    private let totalPriceValueLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 32)
        $0.textAlignment = .right
    }
    
    private let calculateBtn = UIButton().then {
        
        let attr = NSMutableAttributedString(string: "정산하기", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .semibold)])
        $0.setAttributedTitle(attr, for: .normal)
        $0.backgroundColor = UIColor(white: 0.9, alpha: 1)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private func setupLayout() {
        print("setupLayout triggered")
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
            make.left.equalToSuperview()
            make.right.equalToSuperview()
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
            make.width.equalToSuperview().dividedBy(2.1)
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
        print("dutchpay cell has appeared")
        
        
        // cell.dutchUnitCellComponents = cellData[indexPath.row]
        // TODO: Use Cell's ViewModel
        
        //        cell.viewModel = viewModel.dutch
        
        let dutchUnit = viewModel.dutchUnits[indexPath.row]
        
        cell.viewModel = DutchTableCellViewModel(dutchUnit: dutchUnit)
        
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
//        print("selectedUnitInfo: ")
//        print("personDetails: \(selectedUnit.personDetails.sorted())")
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
        
//        guard let participantsController = participantsController else { fatalError() }
//
//        participantsController.willMove(toParent: nil)
//        participantsController.view.removeFromSuperview()
//        participantsController.removeFromParent()
//
//        guard let participantsNavController = participantsNavController else { fatalError() }
//
//        participantsNavController.willMove(toParent: nil)
//        participantsNavController.view.removeFromSuperview()
//        participantsNavController.removeFromParent()
    }
    
    func updateParticipants(with participants: [Person]) {
        
        viewModel.updatePeople(updatedPeople: participants)
    }
    
    func update() {
        viewModel.viewDidLoadAction()
        // 업데이트 어떻게 시켜주지..?? ;;
        
//        viewModel.gathering =
        // Gathering.. ??? ddd
    }
}


extension DutchpayController: DutchUnitDelegate {
    
    func updateDutchUnit(_ dutchUnit: DutchUnit, isNew: Bool) {
        
        viewModel.updateDutchUnit(dutchUnit: dutchUnit, isNew: isNew)
    }
}

extension DutchpayController: AddingUnitControllerDelegate {
    
    func dismissChildVC() {
        print("dismissChildVC 1")
        
        navigationController?.popViewController(animated: true)
        
        //        delegate?.dutchpayController(shouldHideMainTab: false)
        dutchToMainTapDelegate?.shouldHideMainTab(false)
    }
}



extension DutchpayController {
    

    
    // Done!
    private func presentAskingGatheringName( completion: @escaping (NewNameAction)) {
        let alertController = UIAlertController(title: "Edit Gathering Name", message: "새로운 모임 이름을 입력해주세요", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Gathering Name"
        }
        
        let saveAction = UIAlertAction(title: "Done", style: .default) { alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
            
            let newGroupName = textFieldInput.text!
            
            guard newGroupName.count != 0 else {
                completion(.failure(.cancelAskingName))
                fatalError("Name must have at least one character")
            }
            print("gatheringName flag 2, newName: \(newGroupName)")
            
            completion(.success(newGroupName))
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
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


extension DutchpayController: MainTabDelegate {
    //    func updateGatheringFromMainTab(with newGathering: Gathering) {
    //        updateGatheringInfo(with: newGathering)
    
    //    }
}
