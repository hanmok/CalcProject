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

class ParticipantsController: UIViewController {

    private var participants: [Person2] = [Person2("hanmok"), Person2("jiwon"), Person2("dog")]
    
    private var selectedGroup: Group2? {
        didSet {
            participantsCollectionView.reloadData()
        }
    }
    
    let sampleGroups: [Group2] = [
        Group2(people: [Person2(name: "hanmok"), Person2(name: "jiwon")], title: "my love"),
        Group2(people: [Person2(name: "Zoy"), Person2(name: "julie"), Person2(name: "jong hun"), Person2(name: "hanmok")], title: "dev"),
        Group2(people: [Person2(name: "Zoy"), Person2(name: "julie"), Person2(name: "jong hun"), Person2(name: "hanmok")], title: "some other")
    ]
    
    
    
//
//    let topView = UILabel().then {
//        $0.text = "참가 인원"
//        $0.textAlignment = .center
//        $0.font = .boldSystemFont(ofSize: 16)
//        $0.backgroundColor = .white
//        $0.textColor = .black
//    }
    
    lazy var testBtn1 = GroupButton(group: sampleGroups[0])
    lazy var testBtn2 = GroupButton(group: sampleGroups[1])
    
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
    
    
    
    
    let participantsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    private let addPersonBtn = UIButton().then {
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
    }
    
    @objc func nextTapped(_ sender: UIButton) {
        print("next Tapped!")
        let addingUnitController = AddingUnitController(participants: participants)
//        self.present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>)
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
        
        let testBtns = [testBtn1, testBtn2]
        
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
//            make.bottom.equalTo(decisionStackView.snp.top).offset(-10)
            make.height.equalTo(participants.count * 40 - 10)
        }
        participantsCollectionView.delegate = self
        participantsCollectionView.dataSource = self
        
        view.addSubview(addPersonBtn)
        addPersonBtn.snp.makeConstraints { make in
            make.top.equalTo(participantsCollectionView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            
        }
    }
    
    private func setupAddTargets() {
        let btns = [testBtn1,testBtn2]
        
        btns.forEach { btn in
            btn.addTarget(self, action: #selector(btnTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func btnTapped(_ sender: UIButton) {
        print("btn Tapped!")
        let groupBtn = sender as! GroupButton
        let groupTitle = groupBtn.title
        
        switch groupTitle {
        default:
            print(groupTitle)
        }
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
