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
    
    weak var delegate: DutchpayControllerDelegate?
    // MARK: - Properties
    
    var coreGathering: Gathering? {
        didSet {
            printCurrentState()
            DispatchQueue.main.async {
                self.dutchCollectionView.reloadData()
            }
            print("coregathering has assigned, title: \(oldValue?.title)")
        }
    }
    
    private func printCurrentState() {
        guard let gathering = coreGathering else { fatalError() }
        print("gathering Info: \(gathering)")
    }
    
    private func fetchDefaultGathering() {
        let allGatherings = Gathering.fetchAll()
        print("numOfAllGatherings : \(allGatherings.count)")
        if let latestGathering = Gathering.fetchLatest() {
                coreGathering = latestGathering
        }
    }

//    var gathering: Gathering2 = Gathering2(title: "지원이와 강아지", totalCost: 80000, dutchUnits: [
//        DutchUnit2(placeName: "쭈꾸미집", spentAmount: 30000, personDetails: [
//            PersonDetail2(person: Person2(name: .jiwon), spentAmount: 30000),
//            PersonDetail2(person: Person2(name: .hanmok), spentAmount: 0),
//            PersonDetail2(person: Person2(name: .dog), spentAmount: 0)
//        ]),
//        DutchUnit2(placeName: "카페", spentAmount: 10000, personDetails: [
//            PersonDetail2(person: Person2(name: .jiwon), spentAmount: 10000),
//            PersonDetail2(person: Person2(name: .hanmok), spentAmount: 0),
//            PersonDetail2(person: Person2(name: .dog), spentAmount: 0)
//        ]),
//        DutchUnit2(placeName: "술집", spentAmount: 80000, personDetails: [
//            PersonDetail2(person: Person2(name: .jiwon), spentAmount: 0),
//            PersonDetail2(person: Person2(name: .hanmok), spentAmount: 80000),
//            PersonDetail2(person: Person2(name: .dog), spentAmount: 0,isAttended: false)
//        ])
//    ],
//        people: [
//            Person2(.jiwon),
//            Person2(.hanmok),
//            Person2(.dog)
//        ])
    
    var popupToShow: PopupScreens?
    
    let persistenceManager: PersistenceController
    
    var userDefaultSetup = UserDefaultSetup()
    
    let colorList = ColorList()
    
    var isAdding = false
    
    private let containerView: UIView = {
        let uiview = UIView()
        uiview.backgroundColor = .white
        return uiview
    }()
    
    private let blurredView = UIView().then {
        $0.backgroundColor = UIColor(white: 0, alpha: 0.5)
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
    
    @objc func handleAddDutchUnit(_ sender: UIButton) {
        
        // TODO: Add DutchUnit
        print("didTapPlus triggered in DutchpayController!!")
        guard let coreGathering = coreGathering else { fatalError() }
        
        let addingUnitController = AddingUnitController(participants: coreGathering.sortedPeople, gathering: coreGathering)
        print("numOfPeople: \(coreGathering.sortedPeople.count)")
        addingUnitController.addingDelegate = self
        
        
        blurredView.isHidden = false
        
        self.addChild(addingUnitController)
        self.view.addSubview(addingUnitController.view)
        addingUnitController.view.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.snp.centerY).offset(-100)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalToSuperview().dividedBy(2)
        }
        
        let layerController = LayerController(bgColor: UIColor(white: 0.7, alpha: 1), presentingChildVC: addingUnitController)
        
        layerController.parentDelegate = self
        
    }
    
    private let dutchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.layer.borderColor = UIColor.black.cgColor
        cv.layer.borderWidth = 1
        cv.layer.cornerRadius = 10
        return cv
    }()
    
    private let totalPriceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24)
        $0.textAlignment = .center
        $0.text = "총 금액"

    }
    
    private let totalPriceValueLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24)
        $0.textAlignment = .right
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = colorList.bgColorForExtrasLM
        
        fetchDefaultGathering()
        
        setupCollectionView()
        setupLayout()
        addTargets()
        
        fetchAll()
        
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
    
    
    private func addTargets() {
        gatheringPlusBtn.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
        
        dutchUnitPlusBtn.addTarget(self, action: #selector(handleAddDutchUnit(_:)), for: .touchUpInside)
    }
    
    let customAlert = MyAlert()
    
    @objc func addBtnTapped(_ sender: UIButton) {
        presentAddingController()
    }
    
    @objc func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    private func setupCollectionView(){
//        if isAdding {
//        if coreGathering != nil {
        
            dutchCollectionView.delegate = self
            dutchCollectionView.dataSource = self
            self.dutchCollectionView.register(DutchCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
            
            self.dutchCollectionView.register(DutchHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
            
//            self.dutchCollectionView.register(DutchFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
//        }
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
        
        UINavigationBar.appearance().backgroundColor = .cyan
                
        UINavigationBar.appearance().barTintColor = .red

        UINavigationBar.appearance().tintColor = .magenta // chevron Color
        
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
    
    
    private func setupLayout() {
        print("setupLayout triggered")
        let allViews = view.subviews
        
        allViews.forEach {
            $0.removeFromSuperview()
        }
    
//        blurredView.isHidden = true
        
        view.addSubview(containerView)
        containerView.addSubview(historyBtn)
        containerView.addSubview(gatheringPlusBtn)
        
        // safeArea on the bottom
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        historyBtn.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(40)
            make.top.equalTo(containerView).offset(50)
        }
        
        
        
//        if isAdding {
        if coreGathering != nil {
            //            if coreGathering != nil {
            containerView.addSubview(dutchCollectionView)
            
            dutchCollectionView.snp.makeConstraints { make in
                make.top.equalTo(historyBtn.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
//                make.bottom.equalToSuperview()
                make.bottom.equalToSuperview().inset(100)
            }
            
            containerView.addSubview(dutchUnitPlusBtn)
            dutchUnitPlusBtn.snp.makeConstraints { make in
                make.centerY.equalTo(dutchCollectionView.snp.bottom)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(50)
            }
            
            
            containerView.addSubview(totalPriceLabel)
            totalPriceLabel.snp.makeConstraints { make in
                make.top.equalTo(dutchCollectionView.snp.bottom).offset(10)
//                make.leading.trailing.equalToSuperview().inset(10)
                make.leading.equalToSuperview().inset(10)
                make.width.equalToSuperview().dividedBy(2)
                make.height.equalTo(50)
            }
            
            
            containerView.addSubview(totalPriceValueLabel)
            totalPriceValueLabel.snp.makeConstraints { make in
                make.top.equalTo(dutchCollectionView.snp.bottom).offset(10)
                make.trailing.equalToSuperview().inset(10)
                make.leading.equalTo(totalPriceLabel.snp.trailing)
                make.height.equalTo(50)
            }
            // TODO: relocate assigning location, convert double to string with comma
            totalPriceValueLabel.text = String(coreGathering!.totalCost)
            
        } else {
            gatheringPlusBtn.snp.makeConstraints { make in
                make.width.height.equalTo(containerView.snp.width).dividedBy(3)
                make.center.equalTo(containerView)
            }
        }
        
        view.addSubview(blurredView)
        blurredView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        blurredView.isHidden = true
    }
}


extension DutchpayController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("dutchpay collectionView has appeared!!")
//        return gathering.dutchUnits.count
        
        
        if let coreGathering = coreGathering {
            return coreGathering.dutchUnits.count
        } else { return 0 }
        
//        return coreGathering?.dutchUnits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! DutchCollectionViewCell
        print("cutchpay cell has appeared")
//        cell.viewModel = DutchUnitViewModel(dutchUnit: gathering.dutchUnits[indexPath.row])
        guard let coreGathering = coreGathering else { fatalError() }
        let dutchUnits = coreGathering.dutchUnits.sorted { $0.date < $1.date }
        cell.viewModel = CoreDutchUnitViewModel(dutchUnit: dutchUnits[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width - 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let coreGathering = coreGathering else { fatalError() }
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:

            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! DutchHeader
//            header.viewModel = DutchHeaderViewModel(gathering: gathering)
            
            header.viewModel = DutchHeaderViewModel(gathering: coreGathering)
            header.delegate = self
            return header
            
//        case UICollectionView.elementKindSectionFooter:
//            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerIdentifier, for: indexPath) as! DutchFooter
////            footer.viewModel = DutchFooterViewModel(gathering: gathering)
//            footer.viewModel = DutchFooterViewModel(gathering: coreGathering)
//            footer.footerDelegate = self
//            return footer
         
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width - 50, height: 60)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: view.frame.width - 50, height: 100)
//    }
}



//extension DutchpayController: DutchFooterDelegate {
//    func didTapPlus() {
//        // TODO: Add DutchUnit
//        print("didTapPlus triggered in DutchpayController!!")
//        guard let coreGathering = coreGathering else { fatalError() }
//
//        let addingUnitController = AddingUnitController(participants: coreGathering.sortedPeople, gathering: coreGathering)
//        print("numOfPeople: \(coreGathering.sortedPeople.count)")
//        addingUnitController.delegate = self
////        self.present(addingUnitController, animated: true)
//        // Presenting 방식을.. 어떻게 바꿀까 ??
//        // ChildView, 한 중간쯤 차지하게 바꾸고싶어.
//
////        view.addSubview()
//        blurredView.isHidden = false
//
//        self.addChild(addingUnitController)
//        self.view.addSubview(addingUnitController.view)
//        addingUnitController.view.snp.makeConstraints { make in
////            make.center.equalToSuperview()
//            make.centerX.equalToSuperview()
//            make.centerY.equalTo(view.snp.centerY).offset(-100)
////            make.centerY.equalToSuperview()
//            make.leading.trailing.equalToSuperview().inset(10)
//            make.height.equalToSuperview().dividedBy(2)
//        }
//    }
//}


extension DutchpayController: ParticipantsVCDelegate {
    func removeParticipantsController() {
        removeChildrenControllers()
        fetchDefaultGathering()
    }
    
    
    func initializeGathering(with gathering: Gathering) {
        self.coreGathering = gathering
        dutchCollectionView.reloadData()
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
       removeChildrenControllers()
        DispatchQueue.main.async {
            self.blurredView.isHidden = true
        }
        
        // TODO: Update Gathering's DutchUnits
        // UI .. 가 너무 큰문제인데.. ??
//        음... NumberCOntroller 를, DutchpayController 에서 띄워야해 ..
        // 나중에는 또 다른 곳에서도 띄워야 할 수 있으니까, 어떻게 하지 ?
    }

    func updateDutchUnits() {
        fetchDefaultGathering()
    }
}


extension DutchpayController: HeaderDelegate {
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
        
            guard let coreGathering = self.coreGathering else { return }
//            coreGathering.setValue(newGroupName, forKey: .Group.title)
            coreGathering.title = newGroupName
            
            DispatchQueue.main.async {
                self.dutchCollectionView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
}


extension DutchpayController: LayerDelegateToParent {
    
}
