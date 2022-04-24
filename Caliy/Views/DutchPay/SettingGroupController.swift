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

struct Group2 {
    let people: [Person2]
        let title: String
}

struct Person2 {
    let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    init(name: String) {
        self.name = name
    }
}

private let cellIdentifier = "SettingGroupCell"
private let footerIdentifier = "ProfileFooter" // Plus Button

class SettingGroupController: UIViewController {

    private var participants = [Person2]()
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
    
    
    lazy var testBtn1 = GroupButton(group: sampleGroups[0])
    lazy var testBtn2 = GroupButton(group: sampleGroups[1])
    
    let groupStackView = UIStackView()
    
    let groupTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Group: "
        return label
    }()
    
    let decisionStackView = UIStackView()
    
    
    private let cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.addBorders(edges: [.top], color: .white)
        return btn
    }()
    
    private let nextBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Next", for: .normal)
        btn.addBorders(edges: [.top, .left], color: .white)
        return btn
        
    }()
    
    let participantsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupLayout()
        setupAddTargets()
    }
    
    private func setupLayout() {
        view.backgroundColor = .gray

        view.addSubview(groupTitleLabel)
        view.addSubview(groupStackView)

        let testBtns = [testBtn1, testBtn2]
        
        groupStackView.addArranged(testBtns)
        
        groupStackView.axis = .horizontal
        groupStackView.spacing = 5
        groupStackView.distribution = .fillEqually
        
        groupTitleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(10)
            make.height.equalTo(30)
            make.width.equalTo(60)
        }
        
        groupStackView.snp.makeConstraints { make in
            make.leading.equalTo(groupTitleLabel.snp.trailing).offset(5)
            make.top.equalToSuperview().offset(10)
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
        
        
        
        // participants CollectionView
        self.participantsCollectionView.register(
            ParticipantCollectionViewCell.self,
            forCellWithReuseIdentifier: cellIdentifier)
        
        view.addSubview(participantsCollectionView)
        participantsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(groupStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(decisionStackView.snp.top).offset(-10)
        }
        participantsCollectionView.delegate = self
        participantsCollectionView.dataSource = self
        
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


extension SettingGroupController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedGroup = selectedGroup { return selectedGroup.people.count }
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ParticipantCollectionViewCell
//        cell.name = participants[indexPath.row].name
//        cell.backgroundColor = .magenta
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 100
        return CGSize(width: width, height: 30)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
    
    
}

struct ParticipantViewModel {
    
}

class ParticipantCollectionViewCell: UICollectionViewCell {
    
    
    var viewModel: ParticipantViewModel? {
        didSet {
            self.loadView()
        }
    }
    
    var name: String?
    
    var isAttended = true
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let attendingButton = AttendingButton()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }
    
    
    
    private func loadView() {
        self.addSubview(nameLabel)
        self.addSubview(attendingButton)
        
//        guard let name = name else { return }
        
//        nameLabel.text = name
        nameLabel.text = "name Label"
//        attendingButton
        nameLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        
        attendingButton.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(5)
            make.top.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



