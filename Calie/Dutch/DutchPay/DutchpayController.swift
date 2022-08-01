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
    func dutchpayController(shouldHideMainTab: Bool)
//    func dutchpayController(shouldShowSideView: Bool, dutchManager: DutchManager)
    func dutchpayController(shouldShowSideView: Bool)
}

protocol DutchpayToParticipantsDelegate: AnyObject {
    func updateParticipants3(gathering: Gathering)
}


class DutchpayController: UIViewController {
    
    var viewModel: DutchpayViewModel

    var mainTabController: MainTabController
    var sideViewController: SideViewController?

    
    // MARK: - Properties
    weak var delegate: DutchpayControllerDelegate?
    weak var dutchToPartiDelegate: DutchpayToParticipantsDelegate?
    
    var participantsController: ParticipantsController?
    
//    let customAlert = MyAlert()
    
    var popupToShow: PopupScreens?
    
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
    
//    init(persistenceManager: PersistenceController, mainTabController: MainTabController) {
    init(mainTabController: MainTabController) {
        
        self.mainTabController = mainTabController
        
//        self.persistenceManager = persistenceManager
        
        self.viewModel = DutchpayViewModel()
        
        super.init(nibName: nil, bundle: nil)
        
        self.mainTabController.mainToDutchDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = colorList.bgColorForExtrasLM
        
        viewModel.setActions(to: .viewDidLoad)
            
        registerTableView()
        setupLayout()
        setupAddTargets()
        
        setupBindings()
        
        view.insetsLayoutMarginsFromSafeArea = false
    }
    
    // need to be sorted
    
    var cellData: [DutchUnitCellComponents] = [] {
        didSet {
            DispatchQueue.main.async {
                self.dutchTableView.reloadData()
            }
        }
    }
    
    private func setupBindings() {

        viewModel.updateDutchUnitCells = { [weak self] dutchCellComponents in
            guard let self = self else { return }
            self.cellData = dutchCellComponents
        }
        
        viewModel.updateGathering = { [weak self] gatheringInfo in
            guard let self = self else { return }
            self.updateGatheringName(with: gatheringInfo.title)
            self.updateSpentTotalPrice(to: gatheringInfo.totalPrice)
        }
        
//        viewModel.createGathering = { [weak self ] in
//            guard let self = self else { return }
//            // TODO: don't ask Gathering name. Set it to Gatherig n
////            self.
//        }
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
        viewModel.setActions(to: .resetGathering(needGathering: true))
    }
    
    @objc func blurredViewTapped() {
        viewModel.setActions(to: .blurredViewTapped)
        
        if isShowingSideController {
            
            isShowingSideController = false
            hideSideController()
        }
    }
    
    @objc func calculateBtnAction() {
        viewModel.setActions(to: .calculate(needGathering: true))
        print("calculateBtn Tapped !!")
        
        guard let gathering = viewModel.gathering else { fatalError() }

        let resultVC = ResultViewController(gathering: gathering)

        navigationController?.pushViewController(resultVC, animated: true)
        // TODO: Handle this!
        delegate?.dutchpayController(shouldHideMainTab: true)
    }
    
    @objc func editPeopleBtnAction() {
        
        viewModel.setActions(to: .createIfNeeded)
        
        guard let gathering = viewModel.gathering else {fatalError()}
        
        presentParticipantsController(with: gathering.sortedPeople)
    }
    
    @objc func historyBtnAction() {
        // TODO: Handle
        viewModel.setActions(to: .showHistory)
    }
    
    
    @objc private func changeGatheringNameAction() {
        
        self.presentAskingGatheringName { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let newName):
                self.viewModel.setActions(to: .changeGatheringName(newName))
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
    }
    
    @objc func handleAddDutchUnit() {
        viewModel.setActions(to: .addDutchUnit(needGathering: true))
        // TODO: Add DutchUnit
        presentDutchUnitController()
    
    }
    
    private func presentDutchUnitController(selectedUnit: DutchUnit? = nil) {
        

        viewModel.setActions(to: .createIfNeeded)

        guard let gathering = viewModel.gathering else { fatalError() }
        
        
        let addingUnitController = DutchUnitController(
            initialDutchUnit: nil,
            gathering: gathering
        )

        
        addingUnitController.addingDelegate = self
        addingUnitController.dutchDelegate = self

        let numLayerController = NumberLayerController(
            bgColor: UIColor(white: 0.7, alpha: 1),
            presentingChildVC: addingUnitController
        )
        
        numLayerController.childDelegate = addingUnitController
        
        addingUnitController.needingDelegate = numLayerController
        
        navigationController?.pushViewController(numLayerController, animated: true)
        
        navigationController?.navigationBar.isHidden = true
        
        delegate?.dutchpayController(shouldHideMainTab: true)
        
        numLayerController.parentDelegate = self
    }
    
    
    // MARK: - Helper Functions
   
    private func registerTableView() {
        dutchTableView.register(DutchTableCell.self, forCellReuseIdentifier: DutchTableCell.identifier)
        dutchTableView.delegate = self
        dutchTableView.dataSource = self
        
        dutchTableView.rowHeight = 70
        
        dutchTableView.tableHeaderView = headerContainer
    }
    
    
    private func updateGatheringName(with title: String) {
        
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
        
        viewModel.setActions(to: .createIfNeeded)
        
        // TODO: Need Gathering
        participantsController = ParticipantsController(currentGathering: viewModel.gathering!)
        
        guard let participantsController = participantsController else {
            fatalError()
        }

        participantsController.delegate = self
  
         participantsNavController = UINavigationController(rootViewController: participantsController)
        
        guard let participantsNavController = participantsNavController else {
            fatalError()
        }

        self.addChild(participantsNavController)

        self.mainContainer.addSubview(participantsNavController.view)
        participantsNavController.didMove(toParent: self)
        
        participantsNavController.view.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
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
        delegate?.dutchpayController(shouldShowSideView: false)
    }
    
    private func showSideController() {
        
//        delegate?.dutchpayController(shouldShowSideView: true, dutchManager: dutchManager)
        delegate?.dutchpayController(shouldShowSideView: true)
        
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
        $0.backgroundColor = UIColor(white: 0.8, alpha: 1)
     }
    
    private let blurredView = UIButton().then {
        $0.isHidden = true
        $0.backgroundColor = UIColor(white: 1, alpha: 0)
    }
    
    private let totalPriceContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
    }
    
    let historyBtn: UIButton = {
        let btn = UIButton()
        let circle = UIImageView(image: UIImage(systemName: "circle.fill")!)
        let innerImage = UIImageView(image: UIImage(systemName: "list.bullet")!)
        
        circle.tintColor = .white
        innerImage.tintColor = .black
        
        btn.addSubview(circle)
        circle.addSubview(innerImage)
        
        circle.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalTo(btn)
        }
        
        innerImage.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalTo(circle)
        }
        
        return btn
    }()
    
    let resetGatheringBtn: UIButton = {
        let btn = UIButton()
        let circle = UIImageView(image: UIImage(systemName: "circle.fill")!)
        let innerImage = UIImageView(image: UIImage(systemName: "multiply")!)
        
        circle.tintColor = .white
        innerImage.tintColor = .black
        
        btn.addSubview(circle)
        circle.addSubview(innerImage)
        
        circle.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalTo(btn)
        }
        
        innerImage.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalTo(circle)
        }
        
        return btn
    }()
    
    let addGatheringBtn: UIButton = {
        let btn = UIButton()
        let circle = UIImageView(image: UIImage(systemName: "circle.fill")!)
        let innerImage = UIImageView(image: UIImage(systemName: "plus")!)
        
        circle.tintColor = .white
        innerImage.tintColor = .black
        
        btn.addSubview(circle)
        circle.addSubview(innerImage)
        
        circle.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalTo(btn)
        }
        
        innerImage.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalTo(circle)
        }
        
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
        $0.backgroundColor = UIColor(white: 0.93, alpha: 1)
    }
    
    private let groupBtn = UIButton().then {
        
        let innerImage = UIImageView(image: UIImage(systemName: "person.3.fill")!)
        innerImage.contentMode = .scaleAspectFit

        innerImage.tintColor = .black
        $0.addSubview(innerImage)
        innerImage.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        $0.isHidden = true
    }
    
    private let gatheringPlusBtn: UIButton = {
        let btn = UIButton()

        let inner = UIImageView(image: UIImage(systemName: "plus.circle"))

        btn.addSubview(inner)
        inner.snp.makeConstraints { make in
            make.center.equalTo(btn)
            make.width.equalTo(btn)
            make.height.equalTo(btn)
        }
        
        return btn
    }()
    
    private let dutchUnitPlusBtn: UIButton = {
        let btn = UIButton()
        
       let plusImage = UIImageView(image: UIImage(systemName: "plus.circle"))
        
        
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
    
    
    
    private let dutchTableView = UITableView().then {
        $0.layer.borderColor = UIColor(white: 0.8, alpha: 0.7).cgColor
        $0.layer.borderWidth = 1
    }
    
    private let totalPriceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24)
        $0.textAlignment = .center
        $0.text = "총 금액"
    }
    
    private let totalPriceValueLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24)
        $0.textAlignment = .right
    }
    
    private let calculateBtn = UIButton().then {
        
        let attr = NSMutableAttributedString(string: "정산하기", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold)])
        $0.setAttributedTitle(attr, for: .normal)
        $0.backgroundColor = UIColor(white: 0.93, alpha: 1)
    }
    
    private func setupLayout() {
        print("setupLayout triggered")
        let allViews = view.subviews
        
        allViews.forEach {
            $0.removeFromSuperview()
        }
        
        view.addSubview(wholeContainerView)

        wholeContainerView.addSubview(historyBtn)
        
        wholeContainerView.addSubview(addGatheringBtn)
        wholeContainerView.addSubview(resetGatheringBtn)
        
        wholeContainerView.addSubview(groupBtn)
        wholeContainerView.addSubview(gatheringPlusBtn)
        
        wholeContainerView.addSubview(mainContainer)
        
        mainContainer.addSubview(totalPriceContainerView)
        mainContainer.addSubview(calculateBtn)
        
        wholeContainerView.addSubview(blurredView)
        // safeArea on the bottom
        
        wholeContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        historyBtn.snp.makeConstraints { make in
            make.leading.equalTo(wholeContainerView.snp.leading).offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.width.equalTo(30)
        }
        

        resetGatheringBtn.snp.makeConstraints { make in
            make.trailing.equalTo(wholeContainerView.snp.trailing).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.width.equalTo(30)
        }
        
            mainContainer.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(10)
                make.top.equalTo(historyBtn.snp.bottom).offset(30)
                make.bottom.equalToSuperview().inset(10)
            }
            
            calculateBtn.snp.makeConstraints { make in
                make.height.equalTo(60)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            [totalPriceLabel, totalPriceValueLabel].forEach {
                self.totalPriceContainerView.addSubview($0)
            }

            totalPriceContainerView.snp.makeConstraints { make in
                make.bottom.equalTo(calculateBtn.snp.top).offset(-5)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(50)
            }

            totalPriceLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview()
                make.width.equalToSuperview().dividedBy(2.1)
                make.height.equalTo(50)
            }

            totalPriceValueLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().inset(10)
                make.width.equalToSuperview().dividedBy(2.1)
                make.height.equalTo(50)
            }
            
            

            mainContainer.addSubview(dutchTableView)
            dutchTableView.snp.makeConstraints { make in
                make.top.equalToSuperview()
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
    }
    
    private func setupHeaderView() {
        [
            titleLabelBtnInHeader,
            groupBtnInHeader,
        ].forEach { self.headerContainer.addSubview($0) }
        
        titleLabelBtnInHeader.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalToSuperview().dividedBy(2)
        }
        
        groupBtnInHeader.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
            make.height.width.equalTo(24)
        }
    }
}



extension DutchpayController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DutchTableCell.identifier, for: indexPath) as! DutchTableCell
        print("cutchpay cell has appeared")
        
        cell.dutchUnitCellComponents = cellData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            self.viewModel.setActions(to: .deleteDutchUnit(idx: indexPath.row))

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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


extension DutchpayController: ParticipantsVCDelegate {
    
    func hideParticipantsController() {
    
        guard let participantsController = participantsController else { fatalError() }
        
        participantsController.willMove(toParent: nil)
        participantsController.view.removeFromSuperview()
        participantsController.removeFromParent()
        
        guard let participantsNavController = participantsNavController else { fatalError() }
        
        participantsNavController.willMove(toParent: nil)
        participantsNavController.view.removeFromSuperview()
        participantsNavController.removeFromParent()
    }
    
    func updateParticipants(with participants: [Person]) {
        viewModel.setActions(to: .updatePeople(updatedPeople: participants))
    }
}


extension DutchpayController: DutchUnitDelegate {

    func updateDutchUnit(_ dutchUnit: DutchUnit, isNew: Bool) {
        viewModel.setActions(to: .updateDutchUnit(dutchUnit: dutchUnit, isNew: isNew))
    }
}

extension DutchpayController: AddingUnitControllerDelegate {
    
    func dismissChildVC() {
        print("dismissChildVC 1")
        
        navigationController?.popViewController(animated: true)
        
        delegate?.dutchpayController(shouldHideMainTab: false)
    }
}



extension DutchpayController {
    
    typealias NewNameAction = (Result<String, DutchError>) -> Void
    
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


extension DutchpayController: NumberLayerDelegateToSuperVC {
    
}


extension Set {
    func setmap<U>(transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.lazy.map(transform))
    }
}


extension DutchpayController: MainTabDelegate {
    func updateGatheringFromMainTab(with newGathering: Gathering) {
//        updateGatheringInfo(with: newGathering)
        viewModel.setActions(to: .replaceGathering(with: newGathering))
    }
}
