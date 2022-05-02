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
class DutchpayController: UIViewController {
    
    
    // MARK: - Properties
    
//    var gathering: Gathering2 = Gathering2(title: "지원이와 강아지", totalCost: 80000)
//
//    var dutchUnits : [DutchUnit2] = [
//        DutchUnit2(placeName: "쭈꾸미집", spentAmount: 30000, date: Date(),
//                   personUnits: [
//            PersonDetail2(person: Person2("지원이"), spentAmount: 30000),
//            PersonDetail2(person: Person2("한목이"), spentAmount: 0),
//            PersonDetail2(person: Person2("강아지"), spentAmount: 0)
//                   ]),
//        DutchUnit2(placeName: "카페", spentAmount: 10000, date: Date(),
//                   personUnits: [
//                    PersonDetail2(person: Person2("지원이"), spentAmount: 10000),
//                    PersonDetail2(person: Person2("한목이"), spentAmount: 0),
//                    PersonDetail2(person: Person2("강아지"), spentAmount: 0)
//                   ]),
//        DutchUnit2(placeName: "술집", spentAmount: 40000, date: Date(),
//                   personUnits: [
//                    PersonDetail2(person: Person2("지원이"), spentAmount: 0),
//                    PersonDetail2(person: Person2("한목이"), spentAmount: 40000)
    //                   ]),
    //    ]
    
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
    
    
    
    let persistenceManager: PersistenceManager
    
    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
    func createUser() {
        let user = User(context: persistenceManager.context)
        user.name = "andrew"
        
        persistenceManager.save()
        
    }
    */
    
    /*
    func getUsers() {
        
//        guard let users = try! persistenceManager.context.fetch(User.fetchRequest()) as? [User] else { return }
        
        let users = persistenceManager.fetch(User.self)
        users.forEach({ print($0.name) })
        
    }
     */
    
    
    
//    var dutchTitle
    
    
    
    var userDefaultSetup = UserDefaultSetup()
    
    let colorList = ColorList()
    
    
    var isAdding = false
//    var isAdding = true
    
    let containerView: UIView = {
        let uiview = UIView()
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
    
//    private let gatheringTitleLabel = UILabel().then {
//        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
//        $0.textColor = .magenta
//        $0.textAlignment = .center
//    }
    
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
    
    
    
//    private let blurredView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
//        return view
//    }()
    private var blurredView = UIView()
    
   
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = colorList.bgColorForExtrasLM
        
        setupCollectionView()
        setupLayout()
        addTargets()
        
    }
    
    private func addTargets() {
        plusBtn.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func addBtnTapped(_ sender: UIButton) {
        
//        isAdding.toggle()
        
//        popupToShow = .AddingNewDutchpay
        
//        if popupToShow != nil {
//            switch popupToShow! {
//
//            case .AddingNewDutchpay:
//                presentAddingController()
//
//            case .Modifying:
//                //TODO: presentModifyingController
//                break
//            }
//        }
        print("addBtnTapped")
        blurredView.isHidden = false
        presentAddingController()
    }
    
    private func setupCollectionView(){
        if isAdding {
            dutchCollectionView.delegate = self
            dutchCollectionView.dataSource = self
            self.dutchCollectionView.register(DutchCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
            
            self.dutchCollectionView.register(DutchHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
            
            self.dutchCollectionView.register(DutchFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
            
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
        
//        if blurredView.
        blurredView.backgroundColor = .clear
        
    }
    
    // need to remove after dismiss
    private func presentAddingController() {
//        blurredView.removeFromSuperview()
        // should i.. append this ?
//        view.addSubview(blurredView)
//        blurredView.snp.makeConstraints { make in
//            make.left.top.right.bottom.equalToSuperview()
//        }
        blurredView.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        
        let participantsController = ParticipantsController()
        
        let some = UINavigationController(rootViewController: participantsController)

        UINavigationBar.appearance().backgroundColor = .cyan
                
        UINavigationBar.appearance().barTintColor = .red

        UINavigationBar.appearance().tintColor = .magenta // chevron Color
        
        self.addChild(some)
        
        self.view.addSubview(some.view)
        
        some.view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(view).dividedBy(1.2)
            make.height.equalTo(view).dividedBy(1.5)
        }
        
        some.view.layer.cornerRadius = 10
        
        some.didMove(toParent: self)
    }
    
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(historyBtn)
        containerView.addSubview(plusBtn)
        
        // saveArea on the bottom
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
        
        
        if isAdding {

//            containerView.addSubview(gatheringTitleLabel)
//            gatheringTitleLabel.snp.makeConstraints { make in
//                make.top.equalTo(historyBtn.snp.bottom).offset(10)
//                make.leading.equalToSuperview().offset(10)
//                make.trailing.equalToSuperview().offset(-10)
//                make.height.equalTo(50)
//            }
            
            containerView.addSubview(dutchCollectionView)
            dutchCollectionView.snp.makeConstraints { make in
                make.top.equalTo(historyBtn.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.bottom.equalToSuperview()
            }
        }
        
        
        
        if !isAdding {
            plusBtn.snp.makeConstraints { make in
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
        return gathering.dutchUnits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! DutchCollectionViewCell
        print("cutchpay cell has appeared")
        cell.viewModel = DutchUnitViewModel(dutchUnit: gathering.dutchUnits[indexPath.row])
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
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! DutchHeader
            header.viewModel = DutchHeaderViewModel(gathering: gathering)
            return header
            
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerIdentifier, for: indexPath) as! DutchFooter
            footer.viewModel = DutchFooterViewModel(gathering: gathering)
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
    }
}
