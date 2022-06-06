//
//  SettingGroupController.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/25.
//  Copyright © 2022 Mac mini. All rights reserved.
//


//struct Flag {
//    static let
//}


import UIKit
import SnapKit
import AddThen
import Then

private let cellIdentifier = "SettingGroupCell"
private let footerIdentifier = "ProfileFooter" // Plus Button


protocol ParticipantsVCDelegate: AnyObject {
    func removeParticipantsController()
    func initializeGathering(with gathering: Gathering)
}

class ParticipantsController: UIViewController {
    // MARK: - Properties
    var dutchController: DutchpayController
    weak var delegate: ParticipantsVCDelegate?
    
    init(dutchController: DutchpayController) {
        self.dutchController = dutchController
        super.init(nibName: nil, bundle: nil)
//        dutchController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var participants: [Person] = [] {
        willSet {
            if newValue.count != 0 {
                confirmBtn.isUserInteractionEnabled = true
                confirmBtn.setTitleColor(.white, for: .normal)
            } else {
                confirmBtn.isUserInteractionEnabled = false
                confirmBtn.setTitleColor(.gray, for: .normal)
            }
            print("numOfParticipants: \(newValue.count)")
        }
    }
    
    private var selectedGroup: Group? {
        didSet {
            setGroup()
            // TODO: Setup Height each time num of people changed?
            //            setupCollectionViewHeight()
            //            setupLayout()
            reloadCollectionView()
        }
    }
    
    private func setGroup() {
        print("setGroup triggered!")
        guard let selectedGroup = selectedGroup else { return }
        print("flag1")
        participants.removeAll()
        print("flag2")
        selectedGroup.people.forEach {
            participants.append($0)
            print("append!")
            print($0.name)
        }
        print("flag3")
        reloadCollectionView()
    }
    
    private func setupCollectionViewHeight() {
        participantsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(groupStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(10)
            //            make.height.equalTo(0)
            make.height.equalTo(participants.count * 40 - 10)
        }
    }
    
    private func reloadCollectionView() {
        print("flag4")
        DispatchQueue.main.async {
            self.participantsCollectionView.reloadData()
            print("what the..")
        }
        print("flag5")
    }
    
    // TODO: make it dynamically with CollectionView,
//    lazy var groupBtn1 = GroupButton(group: sampleGroups[0])
//    lazy var groupBtn2 = GroupButton(group: sampleGroups[1])
    
    let groupStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 5
        $0.distribution = .fillEqually
    }
    
    let groupTitleLabel =  UILabel().then {$0.text = "Group: "}
    
    let decisionStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
        $0.distribution = .fillEqually
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
    }
    
    private let cancelBtn = UIButton().then {
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        $0.addBorders(edges: [.top], color: .white)
        $0.addTarget(nil, action: #selector(cancelTapped(_:)), for: .touchUpInside)
    }
    
    private let confirmBtn = UIButton().then {
        $0.setTitle("Next", for: .normal)
        $0.addBorders(edges: [.top, .left], color: .white)
        
        $0.isUserInteractionEnabled = false
        $0.setTitleColor(.gray, for: .normal)
    }
    
    
    
    private let participantsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    private let addPeopleBtn = UIButton().then {
        let someImage = UIImageView(image: UIImage(systemName: "plus.circle"))
        someImage.contentMode = .scaleAspectFit
        $0.addSubview(someImage)
        
        someImage.tintColor = .blue
        someImage.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        $0.backgroundColor = .magenta
    }
    
    
    private let bottomView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let showBtn = UIButton().then {
        $0.setTitle("show", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
    }
    
    private let hideBtn = UIButton().then {
        $0.setTitle("hide", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
    }
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        
        setupNavigation()
        registerCollectionView()
        setupLayout()
        setupAddTargets()
    }
    
    
    private func setupNavigation() {
        self.title = "참가 인원"
        
        self.navigationController?.navigationBar.tintColor = .brown
        self.navigationController?.navigationBar.barTintColor = .blue
    }
    
    
    private func registerCollectionView() {
        
        self.participantsCollectionView.register(
            ParticipantCollectionViewCell.self,
            forCellWithReuseIdentifier: cellIdentifier)
        
        participantsCollectionView.delegate = self
        participantsCollectionView.dataSource = self
    }
    
    
    
    private func setupLayout() {
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
        
        [ groupTitleLabel, groupStackView].forEach { v in
            self.containerView.addSubview(v)
        }
        
//        let testGroupBtns = [groupBtn1, groupBtn2]
//        groupStackView.addArranged(testGroupBtns)
        
        groupTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(30)
            make.width.equalTo(60)
        }
        
        groupStackView.snp.makeConstraints { make in
            make.leading.equalTo(groupTitleLabel.snp.trailing).offset(5)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(30)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        containerView.addSubview(participantsCollectionView)
        
        participantsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(groupStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(10)
            
            make.bottom.equalToSuperview().offset(-200)
        }
        
        
        containerView.addSubview(addPeopleBtn)
        addPeopleBtn.snp.makeConstraints { make in
            make.top.equalTo(participantsCollectionView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        // Bottom, Decision Buttons
        containerView.addSubview(decisionStackView)
        
        let decisionBtns = [cancelBtn, confirmBtn]
        
        decisionStackView.addArranged(decisionBtns)
        
        decisionStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            //            make.bottom.equalToSuperview().offset(-70)
            make.top.equalTo(addPeopleBtn.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
        
    }
    
    private func setupAddTargets() {
//        let btns = [groupBtn1,groupBtn2]
        
//        btns.forEach { btn in
//            btn.addTarget(self, action: #selector(groupBtnTapped(_:)), for: .touchUpInside)
//        }
        
        addPeopleBtn.addTarget(self, action: #selector(addPersonBtnTapped(_:)), for: .touchUpInside)
        
        confirmBtn.addTarget(nil, action: #selector(confirmTapped(_:)), for: .touchUpInside)
    }
    
    
    
    @objc func cancelTapped(_ sender: UIButton) {
        print("cancel tapped!")
        delegate?.removeParticipantsController()
        //        delegate?.removeBlurredBGView()
    }
    
    @objc func confirmTapped(_ sender: UIButton) {
        print("next Tapped!")
        if participants.count != 0 {
            // Pass participants
            var gatheringTitle = ""
            for eachName in participants.map({$0.name}) {
                gatheringTitle.append(eachName.first!)
            }
            
            let gathering = Gathering.save(title: gatheringTitle, people: participants)
            
            delegate?.initializeGathering(with: gathering)
            
        }
        
    }
    
    @objc func groupBtnTapped(_ sender: UIButton) {
        print("btn Tapped!")
        //        let selectedGroupBtn = sender as! GroupButton
        //        let groupTitle = selectedGroupBtn.title
        //        let selectedPeople = selectedGroupBtn.people
        
        guard let selectedGroupBtn = sender as? GroupButton else { return }
        
        //        let groupTitle = selectedGroupBtn.title // 어디쓰지? .. ;;
        //        let selectedPeople = selectedGroupBtn.people
        
        // TODO: set other btn backgroundColor different from the selected one
        
        if !selectedGroupBtn.isSelected_ {
            selectedGroupBtn.isSelected_ = true
        }
        
        selectedGroup = selectedGroupBtn.group
        print("selectedGroup : \(selectedGroup?.title)")
        
        
    }
    
    @objc func addPersonBtnTapped(_ sender: UIButton) {
        presentAddingPeopleAlert()
        //        showNumberController()
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
            
            self.participants.append(somePerson)
            
            self.reloadCollectionView()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
    
}


extension ParticipantsController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ParticipantCollectionViewCell
        cell.viewModel = ParticipantViewModel(person: participants[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 100
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}


//extension ParticipantsController: AddingUnitControllerDelegate {
//    func dismissChildVC() {
//        delegate?.removeParticipantsController()
//    }
//}
