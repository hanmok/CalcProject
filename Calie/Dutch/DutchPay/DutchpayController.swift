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

private let cellIdentifier = "DutchCell"
private let headerIdentifier = "headerCell"
//private let footerIdentifier = "footerCell"

protocol DutchpayControllerDelegate: AnyObject {
    func dutchpayController(shouldHideMainTab: Bool)
}


class DutchpayController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: DutchpayControllerDelegate?
       
    let customAlert = MyAlert()
    
    var popupToShow: PopupScreens?
    
    let persistenceManager: PersistenceController
    
    var userDefaultSetup = UserDefaultSetup()
    
    let colorList = ColorList()
    
    var isAdding = false
    
    var coreGathering: Gathering? {
        didSet {
            printCurrentState()
            DispatchQueue.main.async {
                self.dutchTableView.reloadData()
            }
            print("coregathering has assigned, title: \(oldValue?.title)")
        }
    }
    
    private func printCurrentState() {
        guard let gathering = coreGathering else { fatalError() }
        print("gathering Info: \(gathering)")
    }
    
    
    
    // MARK: - UI Properties
    
    private func setupTotalPrice() {
        guard let coreGathering = coreGathering else {
            return
        }
        
//        totalPriceValueLabel.text = convertIntoKoreanPrice(number: coreGathering.totalCost)
        totalPriceValueLabel.text = coreGathering.totalCost
    }

    private let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 60)).then {
        
        $0.backgroundColor = UIColor(white: 0.8, alpha: 1)
     }
    
    private let totalPriceContainerView = UIView().then {
//        $0.backgroundColor = .magenta
        $0.backgroundColor = UIColor(white: 1, alpha: 1)
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
    
    
    private let titleLabelInHeader = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        $0.backgroundColor = .magenta
        $0.textAlignment = .center
    }
    
    private let groupBtnInHeader = UIButton().then {
        let innerImage = UIImageView(image: UIImage(systemName: "person.3.fill")!)
        innerImage.contentMode = .scaleAspectFit

        innerImage.tintColor = .black
        $0.addSubview(innerImage)
        innerImage.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
//        $0.backgroundColor = .cyan
    }
    
    private let renameBtnInHeader = UIButton().then {
        let innerImage = UIImageView(image: UIImage(systemName: "pencil")!)
        innerImage.contentMode = .scaleAspectFit

        innerImage.tintColor = .black
        $0.addSubview(innerImage)
        innerImage.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
//        $0.backgroundColor = .yellow
    }
    
//    private let memberNameLabelInHeader = UILabel().then {
//        $0.textColor = .gray
//        $0.font = UIFont.systemFont(ofSize: 10)
//        $0.backgroundColor = .blue
//    }
    
    private let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 60)).then {
//        $0.backgroundColor = .orange
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
        // 왜.. 아래에서 보이지 ?
       let plusImage = UIImageView(image: UIImage(systemName: "plus.circle"))
//        let plusImage = UIImageView(image: UIImage(systemName: "folder"))
        
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
//        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderColor = UIColor(white: 0.8, alpha: 0.7).cgColor
        $0.layer.borderWidth = 1
//        $0.layer.cornerRadius = 10
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
//        $0.setTitle("정산하기", for: .normal)
//        $0.font = UIFont.systemFont(ofSize: 24)
        let attr = NSMutableAttributedString(string: "정산하기", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold)])
        $0.setAttributedTitle(attr, for: .normal)
        $0.backgroundColor = UIColor(white: 0.93, alpha: 1)
    }
    
    
    
    // MARK: - LifeCycle
    
    init(persistenceManager: PersistenceController) {
        self.persistenceManager = persistenceManager
        super.init(nibName: nil, bundle: nil)
        fetchDefaultGathering()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        AppUtility.lockOrientation(.portrait)
//        contentinset
//        self.contentinset
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = colorList.bgColorForExtrasLM
        
        fetchDefaultGathering()
        
        setupHeaderView()
        
        registerTableView()
        setupLayout()
        setupAddTargets()
        
        fetchAll()
        
        view.insetsLayoutMarginsFromSafeArea = false
    }
    
    // MARK: - Actions
    
    private func setupAddTargets() {
        print("setupAddTargets Called !")
        gatheringPlusBtn.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
        
        dutchUnitPlusBtn.addTarget(self, action: #selector(handleAddDutchUnit(_:)), for: .touchUpInside)
        
//        headerBtn.addTarget(self, action: #selector(changeGroupAction), for: .touchUpInside)
        
        groupBtn.addTarget(self, action: #selector(groupBtnTapped), for: .touchUpInside)
        historyBtn.addTarget(self, action: #selector(historyBtnTapped), for: .touchUpInside)
        
        renameBtnInHeader.addTarget(self, action: #selector(changeGroupAction(_:)), for: .touchUpInside)
        
        groupBtnInHeader.addTarget(self, action: #selector(coreGroupBtnTapped(_:)), for: .touchUpInside)
        
        calculateBtn.addTarget(self, action: #selector(calculateTapped(_:)), for: .touchUpInside)
    }
    
    @objc func calculateTapped(_ sender: UIButton) {
        print("calculateBtn Tapped !!")
    }
    
    @objc func coreGroupBtnTapped(_ sender: UIButton) {
        presentAddingPeopleAlert()
    }
    
    private func presentAddingPeopleAlert() {
        let alertController = UIAlertController(title: "Add People", message: "추가할 사람을 입력해주세요", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Person Name"
        }
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
            
//            guard let newPersonName = textFieldInput.text
            guard textFieldInput.text!.count != 0 else { fatalError("Name must have at least one character") }
        
            let somePerson = Person.save(name: textFieldInput.text!)
            
            guard let coreGathering = self.coreGathering else {
                return
            }

            
            coreGathering.people.update(with: somePerson)
            
            
//            self.participants.append(somePerson)
            
//            self.reloadCollectionView()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
    
    
    @objc func groupBtnTapped(_ sender: UIButton) {
        print("groupBtn Tapped")
//        guard let coreGathering = coreGathering else {
//            return
//        }

//        print("coreInfo: \(coreGathering)")
//        print("totalCost: \(coreGathering.totalCost)")
//        print("people: \(coreGathering.people)")
//        print("title: \(coreGathering.title)")
//        print("numOfPeople: \(coreGathering.people.count)")
    }
    
    @objc func historyBtnTapped(_ sender: UIButton) {
        print("historyBtnTapped")
    }
    
    
    @objc private func changeGroupAction(_ sender: UIButton) {
        self.presentEditingGroupName()
    }
    
    @objc func addBtnTapped(_ sender: UIButton) {
        presentAddingController()
    }
    
    @objc func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    @objc func handleAddDutchUnit(_ sender: UIButton) {
        
        // TODO: Add DutchUnit
//        print("didTapPlus triggered in DutchpayController!!")
//        guard let coreGathering = coreGathering else { fatalError() }
//
//        let addingUnitController = DutchUnitController(participants: coreGathering.sortedPeople, gathering: coreGathering)
//
//        addingUnitController.addingDelegate = self
//
////        print("numOfPeople: \(coreGathering.sortedPeople.count)")
//
//        let numLayerController = NumberLayerController(
//            bgColor: UIColor(white: 0.7, alpha: 1),
//            presentingChildVC: addingUnitController
//        )
//
//        numLayerController.childDelegate = addingUnitController
//
//        addingUnitController.needingDelegate = numLayerController
//
//        navigationController?.pushViewController(numLayerController, animated: true)
//
//        navigationController?.navigationBar.isHidden = true
//
//        delegate?.dutchpayController(shouldHideMainTab: true)
//
//        numLayerController.parentDelegate = self
        presentDutchUnitController()
    }
    
    private func presentDutchUnitController(selectedUnit: DutchUnit? = nil) {
        
        guard let coreGathering = coreGathering else { fatalError() }
        
        let addingUnitController = DutchUnitController(
             gathering: coreGathering,
             initialDutchUnit: selectedUnit)

        addingUnitController.addingDelegate = self
        

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
        dutchTableView.rowHeight = 80
        
        dutchTableView.tableHeaderView = headerContainer
        
        guard let coreGathering = coreGathering else {
//            fatalError()
            return
        }
        
        updateGroupName()
        
    }
    
    // 현재, 제대로 저장도 안됐다.
    private func fetchAll() {
        let gatherings = Gathering.fetchAll()
        for eachGathering in gatherings {
            print("--------------------------------")
            print(eachGathering)
            for eachPerson in eachGathering.sortedPeople {
                print("personName: \(eachPerson.name)")
            }
            print("--------------------------------")
        }
    }
    
    private func fetchDefaultGathering() {
        let allGatherings = Gathering.fetchAll()
        print("numOfAllGatherings : \(allGatherings.count)")
        if let latestGathering = Gathering.fetchLatest() {
                coreGathering = latestGathering
        }
        
        setupTotalPrice()
    }
    
    
    
//    updateGroupname
    private func updateGroupName() {
        guard let coreGathering = coreGathering else {
//            return
            fatalError()
        }

        let attrTitle = NSAttributedString(string: coreGathering.title, attributes: [.font: UIFont.preferredFont(forTextStyle: .largeTitle)])
        
        DispatchQueue.main.async {
            self.titleLabelInHeader.attributedText = attrTitle
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
    
    // need to remove after dismiss
    private func presentAddingController() {
        
        let participantsController = ParticipantsController(dutchController: self)
        
        participantsController.delegate = self
        
        let navParticipantsController = UINavigationController(rootViewController: participantsController)
        
//        UINavigationBar.appearance().backgroundColor = .cyan
                
        UINavigationBar.appearance().barTintColor = .red

//        UINavigationBar.appearance().tintColor = .magenta // chevron Color
        
        self.addChild(navParticipantsController)
        
        self.view.addSubview(navParticipantsController.view)
        
        navParticipantsController.view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(view)
            make.height.equalTo(view)
        }
        
        navParticipantsController.view.layer.cornerRadius = 10
        
        navParticipantsController.didMove(toParent: self)
        
        delegate?.dutchpayController(shouldHideMainTab: true)
    }
    
    func removeChildrenControllers() {
        //children:  An array of children view controllers. This array does not include any presented view controllers.
        if self.children.count > 0 {
            let viewControllers: [UIViewController] = self.children
            for eachVC in viewControllers {
                eachVC.willMove(toParent: nil)
                eachVC.view.removeFromSuperview()
                eachVC.removeFromParent()
            }
        }
    }
    
    
    private func setupHeaderView() {
        [
        titleLabelInHeader,
        renameBtnInHeader,
        groupBtnInHeader,
//        memberNameLabelInHeader
        ].forEach { self.headerContainer.addSubview($0) }
        
        titleLabelInHeader.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalToSuperview().dividedBy(2)
        }
        
        groupBtnInHeader.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
            make.height.width.equalTo(30)
        }
        
        renameBtnInHeader.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(groupBtnInHeader.snp.leading).offset(-10)
            make.height.width.equalTo(30)
        }
        
//        memberNameLabelInHeader.snp.makeConstraints { make in
//            make.top.equalTo(titleLabelInHeader.snp.bottom)
//            make.bottom.equalToSuperview()
//            make.leading.top.equalToSuperview()
//        }
        
    }
    
    
    
    private func setupLayout() {
        print("setupLayout triggered")
        let allViews = view.subviews
        
        allViews.forEach {
            $0.removeFromSuperview()
        }
        
        view.addSubview(containerView)
        containerView.addSubview(historyBtn)
        containerView.addSubview(groupBtn)
        containerView.addSubview(gatheringPlusBtn)
        containerView.addSubview(totalPriceContainerView)
        containerView.addSubview(calculateBtn)
        
        // safeArea on the bottom
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        historyBtn.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading).offset(20)
//            make.top.equalTo(containerView.snp.top).offset(70)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.width.equalTo(30)
        }
        
        groupBtn.snp.makeConstraints { make in
            make.trailing.equalTo(containerView.snp.trailing).inset(20)
//            make.top.equalTo(containerView.snp.top).offset(70)
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.top.equalTo(historyBtn.snp.top)
            make.height.width.equalTo(30)
        }
        
        if coreGathering != nil {
            containerView.addSubview(dutchTableView)
            
            dutchTableView.snp.makeConstraints { make in
                make.top.equalTo(historyBtn.snp.bottom).offset(30)
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
//                make.bottom.equalToSuperview().inset(60)
//                make.bottom.equalToSuperview().inset(tabBarController?.tabBar.bounds.size.height ?? 50)
                make.bottom.equalToSuperview().inset(120)
//                make.bottom.equalToSuperview()
            }
            
            containerView.addSubview(dutchUnitPlusBtn)
            dutchUnitPlusBtn.snp.makeConstraints { make in
                make.centerY.equalTo(dutchTableView.snp.bottom)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(50)
            }
            
            [totalPriceLabel, totalPriceValueLabel].forEach {
                self.totalPriceContainerView.addSubview($0)
            }
            
            totalPriceContainerView.snp.makeConstraints { make in
                make.top.equalTo(dutchTableView.snp.bottom)
                make.leading.trailing.equalToSuperview().inset(11)
                make.height.equalTo(50)
//                make.bottom.equalTo(tabBarController?.tabBar.bounds.size.height ?? 50)
//                make.bottom.equalToSuperview().inset(tabBarController?.tabBar.bounds.size.height ?? 50)
            }
            
//            containerView.addSubview(totalPriceLabel)
            totalPriceLabel.snp.makeConstraints { make in
//                make.top.equalTo(dutchTableView.snp.bottom).offset(10)
                make.centerY.equalToSuperview()
//                make.leading.equalToSuperview().inset(10)
                make.leading.equalToSuperview()
//                make.width.equalToSuperview().dividedBy(2)
//                make.width.equalTo(<#T##other: ConstraintRelatableTarget##ConstraintRelatableTarget#>)
                make.trailing.equalTo(dutchUnitPlusBtn.snp.leading)
                make.height.equalTo(50)
            }
            
//            containerView.addSubview(totalPriceValueLabel)
            totalPriceValueLabel.snp.makeConstraints { make in
//                make.top.equalTo(dutchTableView.snp.bottom).offset(10)
                make.centerY.equalToSuperview()
//                make.trailing.equalToSuperview().inset(10)
//                make.trailing.equalToSuperview()
                make.trailing.equalToSuperview().inset(10)
                make.leading.equalTo(totalPriceLabel.snp.trailing)
                make.height.equalTo(50)
            }
            
            calculateBtn.snp.makeConstraints { make in
                make.top.equalTo(totalPriceLabel.snp.bottom).offset(5)
                make.leading.equalToSuperview().inset(11)
                make.trailing.equalToSuperview().inset(10)
                make.height.equalTo(55)
            }
            
            
        } else {
            gatheringPlusBtn.snp.makeConstraints { make in
                make.width.height.equalTo(containerView.snp.width).dividedBy(3)
                make.center.equalTo(containerView)
            }
        }
    }
}



extension DutchpayController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let coreGathering = coreGathering {
            return coreGathering.dutchUnits.count
        } else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DutchTableCell.identifier, for: indexPath) as! DutchTableCell
        print("cutchpay cell has appeared")

        guard let coreGathering = coreGathering else { fatalError() }
        let dutchUnits = coreGathering.dutchUnits.sorted { $0.date < $1.date }
        cell.viewModel = CoreDutchUnitViewModel(dutchUnit: dutchUnits[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            guard let coreGathering = self.coreGathering else { fatalError() }
            
            let selectedDutchUnit = coreGathering.dutchUnits.sorted { $0.date < $1.date }[indexPath.row]
            
            coreGathering.dutchUnits.remove(selectedDutchUnit)

            DutchUnit.deleteSelf(selectedDutchUnit)
            DispatchQueue.main.async {
                self.dutchTableView.reloadData()
                self.setupTotalPrice()
            }
            
            completionhandler(true)
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete])
        
        return rightSwipe
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let selectedUnit = coreGathering?.dutchUnits
        guard let coreGathering = coreGathering else { fatalError() }
        
        let dutchUnits = coreGathering.dutchUnits.sorted { $0.date < $1.date }
        
        let selectedDutchUnit = dutchUnits[indexPath.row]
        print("tableView tapped, \(selectedDutchUnit)")
        presentDutchUnitController(selectedUnit: selectedDutchUnit)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


extension DutchpayController: ParticipantsVCDelegate {
    func removeParticipantsController() {
        removeChildrenControllers()
        fetchDefaultGathering()
    }
    
    
    func initializeGathering(with gathering: Gathering) {
        self.coreGathering = gathering
        dutchTableView.reloadData()
        removeChildrenControllers()
        fetchDefaultGathering()
        setupLayout()
    }
}


extension DutchpayController: AddingUnitNavDelegate {
    func dismissWithInfo(dutchUnit: DutchUnit) {
        print("dismiss Tapped from aDutchpayController triggered!!")
    }
}



extension DutchpayController: AddingUnitControllerDelegate {
    
    func dismissChildVC() {
        print("dismissChildVC 1")
//       removeChildrenControllers()
        navigationController?.popViewController(animated: true)
        updateDutchUnits()
        delegate?.dutchpayController(shouldHideMainTab: false)

    }

    func updateDutchUnits() {
        fetchDefaultGathering()
    }
}


//extension DutchpayController: HeaderDelegate {
extension DutchpayController {
    func didTapGroupName() {
        print("Groupname Tapped!")
        self.presentEditingGroupName()
    }
    
    private func presentEditingGroupName() {
        let alertController = UIAlertController(title: "Edit Group Name", message: "새로운 그룹 이름을 입력해주세요", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Group Name"
        }
        
        let saveAction = UIAlertAction(title: "Done", style: .default) { alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
            
            let newGroupName = textFieldInput.text!
            
            guard newGroupName.count != 0 else { fatalError("Name must have at least one character") }
        
            guard let coreGathering = self.coreGathering else { fatalError() }
            coreGathering.title = newGroupName
            
            self.updateGroupName()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
}


extension DutchpayController: NumberLayerDelegateToSuperVC {
    
}
