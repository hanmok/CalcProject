//
//  SettingGroupController.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/25.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit
import AddThen
import Then

private let cellIdentifier = "SettingGroupCell"
private let footerIdentifier = "ProfileFooter" // Plus Button


protocol ParticipantsVCDelegate: AnyObject {
    func removeParticipantsController()
//    func removeBlurredBGView()
}

class ParticipantsController: UIViewController {

//    private var participants: [Person2] = [Person2("hanmok"), Person2("jiwon"), Person2("dog")]
    
    weak var delegate: ParticipantsVCDelegate?
    
    private var participants: [Person2] = []
    
    private var selectedGroup: Group2? {
        didSet {
            setGroup()
            // TODO: Setup Height each time num of people changed?
//            setupCollectionViewHeight()
//            setupLayout()
            reloadCollectionView()
        }
    }
    
    let sampleGroups: [Group2] = [
        Group2(people: [Person2(name: "hanmok"), Person2(name: "jiwon")], title: "my love"),
        Group2(people: [Person2(name: "Zoy"), Person2(name: "julie"), Person2(name: "jong hun"), Person2(name: "hanmok")], title: "dev"),
        Group2(people: [Person2(name: "Zoy"), Person2(name: "julie"), Person2(name: "jong hun"), Person2(name: "hanmok")], title: "some other")
    ]
    
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
    
    
    lazy var groupBtn1 = GroupButton(group: sampleGroups[0])
    lazy var groupBtn2 = GroupButton(group: sampleGroups[1])
    
    let groupStackView = UIStackView()
    
    let groupTitleLabel =  UILabel().then {$0.text = "Group: "}
    
    let decisionStackView = UIStackView()
    
    
    private let cancelBtn = UIButton().then {
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        $0.addBorders(edges: [.top], color: .white)
        $0.addTarget(nil, action: #selector(cancelTapped(_:)), for: .touchUpInside)
    }
    
    private let nextBtn = UIButton().then {
        $0.setTitle("Next", for: .normal)
        $0.addBorders(edges: [.top, .left], color: .white)
        $0.addTarget(nil, action: #selector(nextTapped(_:)), for: .touchUpInside)
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
    
    @objc func cancelTapped(_ sender: UIButton) {
            print("cancel tapped!")
        delegate?.removeParticipantsController()
//        delegate?.removeBlurredBGView()
    }
    
    @objc func nextTapped(_ sender: UIButton) {
        print("next Tapped!")
        let addingUnitController = AddingUnitController(participants: participants)
        addingUnitController.delegate = self
        navigationController?.pushViewController(addingUnitController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupLayout()
        setupAddTargets()
        
    }
    
    private func setupLayout() {
        view.backgroundColor = .gray
        
        self.title = "참가 인원"
//        self.navigationController?.navigationBar.backgroundColor
        self.navigationController?.navigationBar.tintColor = .brown
        self.navigationController?.navigationBar.barTintColor = .blue
//        self.navigationController?.navigationBar.title
//        [ topView, groupTitleLabel, groupStackView].forEach { v in
//            self.view.addSubview(v)
//        }
        [ groupTitleLabel, groupStackView].forEach { v in
            self.view.addSubview(v)
        }

//        topView.snp.makeConstraints { make in
//            make.left.top.right.equalTo(view.safeAreaLayoutGuide)
//            make.height.equalTo(40)
//        }
        
        let testBtns = [groupBtn1, groupBtn2]
        
        groupStackView.addArranged(testBtns)
        
        groupStackView.axis = .horizontal
        groupStackView.spacing = 5
        groupStackView.distribution = .fillEqually
        
        groupTitleLabel.snp.makeConstraints { make in
//            make.top.equalTo(topView.snp.bottom).offset(10)
//            make.top.equalTo(view.snp.bottom).offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(30)
            make.width.equalTo(60)
        }
        
        groupStackView.snp.makeConstraints { make in
            make.leading.equalTo(groupTitleLabel.snp.trailing).offset(5)
//            make.top.equalTo(topView.snp.bottom).offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.top.equalTo(view.snp.bottom).offset(10)
            make.height.equalTo(30)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        

        // Bottom, Decision Buttons
        view.addSubview(decisionStackView)
       
        let decisionBtns = [ cancelBtn, nextBtn]
        
        decisionStackView.addArranged(decisionBtns)
        
        decisionStackView.axis = .horizontal
        decisionStackView.spacing = 0
        decisionStackView.distribution = .fillEqually
        
        decisionStackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        self.participantsCollectionView.register(
            ParticipantCollectionViewCell.self,
            forCellWithReuseIdentifier: cellIdentifier)
        
        view.addSubview(participantsCollectionView)
        
        participantsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(groupStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(10)
//            make.height.equalTo(0)
//            make.height.equalTo(participants.count * 40 - 10)
            make.bottom.equalToSuperview().offset(-100)
        }
        participantsCollectionView.delegate = self
        participantsCollectionView.dataSource = self
        
        view.addSubview(addPeopleBtn)
        addPeopleBtn.snp.makeConstraints { make in
            make.top.equalTo(participantsCollectionView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    
    private func setupAddTargets() {
        let btns = [groupBtn1,groupBtn2]
        
        btns.forEach { btn in
            btn.addTarget(self, action: #selector(groupBtnTapped(_:)), for: .touchUpInside)
        }
        
        addPeopleBtn.addTarget(self, action: #selector(addPersonBtnTapped(_:)), for: .touchUpInside)
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
    }
    
    private func presentAddingPeopleAlert() {
        let alertController = UIAlertController(title: "Add People", message: "추가할 사람을 입력해주세요", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Person Name"
        }
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
            
            self.participants.append(Person2(textFieldInput.text!))
            self.reloadCollectionView()
        }
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.destructive, handler: {
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


extension ParticipantsController: AddingUnitControllerDelegate {
    func dismissChildVC() {
        delegate?.removeParticipantsController()
    }
}


class NumberPadController: UIViewController {
    
    
    
    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
