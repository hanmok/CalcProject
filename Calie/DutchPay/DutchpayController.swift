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
private let footerIdentifier = "footerCell"

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

    var gathering: Gathering2 = Gathering2(title: "지원이와 강아지", totalCost: 80000, dutchUnits: [
        DutchUnit2(placeName: "쭈꾸미집", spentAmount: 30000, personDetails: [
            PersonDetail2(person: Person2(name: .jiwon), spentAmount: 30000),
            PersonDetail2(person: Person2(name: .hanmok), spentAmount: 0),
            PersonDetail2(person: Person2(name: .dog), spentAmount: 0)
        ]),
        DutchUnit2(placeName: "카페", spentAmount: 10000, personDetails: [
            PersonDetail2(person: Person2(name: .jiwon), spentAmount: 10000),
            PersonDetail2(person: Person2(name: .hanmok), spentAmount: 0),
            PersonDetail2(person: Person2(name: .dog), spentAmount: 0)
        ]),
        DutchUnit2(placeName: "술집", spentAmount: 80000, personDetails: [
            PersonDetail2(person: Person2(name: .jiwon), spentAmount: 0),
            PersonDetail2(person: Person2(name: .hanmok), spentAmount: 80000),
            PersonDetail2(person: Person2(name: .dog), spentAmount: 0,isAttended: false)
        ])
    ],
        people: [
            Person2(.jiwon),
            Person2(.hanmok),
            Person2(.dog)
        ])
    
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
    
    private let plusBtn: UIButton = {
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
    
    private let dutchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.layer.borderColor = UIColor.black.cgColor
        cv.layer.borderWidth = 1
        cv.layer.cornerRadius = 10
        return cv
    }()
    
    
    
    
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
        plusBtn.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
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
            
            self.dutchCollectionView.register(DutchFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
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
    
    private func setupLayout() {
        print("setupLayout triggered")
        let allViews = view.subviews
        
        allViews.forEach {
            $0.removeFromSuperview()
        }
        
        view.addSubview(containerView)
        containerView.addSubview(historyBtn)
        containerView.addSubview(plusBtn)
        
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
                make.bottom.equalToSuperview()
            }
        } else {
            plusBtn.snp.makeConstraints { make in
                make.width.height.equalTo(containerView.snp.width).dividedBy(3)
                make.center.equalTo(containerView)
            }
        }
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
        return CGSize(width: width, height: 50)
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
            return header
            
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerIdentifier, for: indexPath) as! DutchFooter
//            footer.viewModel = DutchFooterViewModel(gathering: gathering)
            footer.viewModel = DutchFooterViewModel(gathering: coreGathering)
            footer.footerDelegate = self
            return footer
         
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}



extension DutchpayController: DutchFooterDelegate {
    func didTapPlus() {
        // TODO: Add DutchUnit
        print("didTapPlus triggered in DutchpayController!!")
        guard let coreGathering = coreGathering else { fatalError() }
        
        let addingUnitController = AddingUnitController(participants: coreGathering.sortedPeople, gathering: coreGathering)
        print("numOfPeople: \(coreGathering.sortedPeople.count)")
        addingUnitController.delegate = self
        self.present(addingUnitController, animated: true)
        
    }
}


extension DutchpayController: ParticipantsVCDelegate {
    
    func removeParticipantsController() {
        if self.children.count > 0 {
            let viewControllers: [UIViewController] = self.children
            for eachVC in viewControllers {
                eachVC.willMove(toParent: nil)
                eachVC.view.removeFromSuperview()
                eachVC.removeFromParent()
            }
        }
        fetchDefaultGathering()
    }
    
    func initializeGathering(with gathering: Gathering) {
        self.coreGathering = gathering
        dutchCollectionView.reloadData()
        removeParticipantsController()
        setupLayout()
    }
}


extension DutchpayController: AddingUnitNavDelegate {
    func dismissWithInfo(dutchUnit: DutchUnit) {
        print("dismiss Tapped from aDutchpayController triggered!!")
    }
}



//extension DutchpayController: AddingUnitControllerDelegate { // 이거 필요없음 ;;
//    func dismissChildVC() {
//
//    }
//}

extension DutchpayController: AddingUnitControllerDelegate {
    func updateDutchUnits() {
        fetchDefaultGathering()
    }
}
