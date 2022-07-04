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
//    func removeChildrenControllers()
    func hideParticipantsController()
//    func initializeGathering(with gathering: Gathering)
    func updateParticipants()
}

extension ParticipantsController: DutchpayToParticipantsDelegate {
    func updateParticipants3(gathering: Gathering) {
        self.gathering = gathering
        self.participants = gathering.people.sorted()
        DispatchQueue.main.async {
            self.participantsTableView.reloadData()
        }
        print("updating flag!!")
    }
}

class ParticipantsController: UIViewController{
    
    
    // MARK: - Properties
    var dutchController: DutchpayController
    weak var delegate: ParticipantsVCDelegate?

    var gathering: Gathering
    
    init(dutchController: DutchpayController, gathering: Gathering) {
        self.dutchController = dutchController
        self.gathering = gathering

        self.participants = gathering.people.sorted()
        super.init(nibName: nil, bundle: nil)
        self.dutchController.dutchToPartiDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var participants: [Person] = []

//    private var selectedGroup: Group? {
//        didSet {
//            setGroup()
//            // TODO: Setup Height each time num of people changed?
//            //            setupCollectionViewHeight()
//            //            setupLayout()
//            reloadCollectionView()
//        }
//    }

//    private func setGroup() {
//        print("setGroup triggered!")
//        guard let selectedGroup = selectedGroup else { return }
//        print("flag1")
//        participants.removeAll()
//        print("flag2")
//        selectedGroup.people.forEach {
//            participants.append($0)
//            print("append!")
//            print($0.name)
//        }
//        print("flag3")
//        reloadCollectionView()
//    }

//    private func setupCollectionViewHeight() {
//
//    }

    private func reloadCollectionView() {
        print("flag4")
        DispatchQueue.main.async {
            self.participantsTableView.reloadData()
            print("what the..")
        }
        print("flag5")
    }

//    let groupStackView = UIStackView().then {
//        $0.axis = .horizontal
//        $0.spacing = 5
//        $0.distribution = .fillEqually
//    }

//    let groupTitleLabel =  UILabel().then {$0.text = "Group: "}

//    let decisionStackView = UIStackView().then {
//        $0.axis = .horizontal
//        $0.spacing = 0
//        $0.distribution = .fillEqually
//    }

    private let containerView = UIView().then {
//        $0.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        $0.backgroundColor = UIColor(white: 0.93, alpha: 1)
    }
    
    private let titleLabel = UILabel().then {
//        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        let attrTitle = NSAttributedString(string: "참가 인원 수정", attributes: [
//            .font: UIFont.preferredFont(forTextStyle: .largeTitle)])
        
        let attrTitle = NSAttributedString(string: "참가 인원 수정", attributes: [
//            .font: UIFont.preferredFont(forTextStyle: .headline)
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ])
        
        $0.attributedText = attrTitle
        $0.textAlignment = .center
    }

    private let dismissBtn: UIButton = {
        let btn = UIButton()
        let imageView = UIImageView(image: UIImage(systemName: "chevron.left"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        
        btn.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
//        btn.backgroundColor = .magenta
        return btn
    }()
    
    private let sortingBtn: UIButton = {
        let btn = UIButton()
        let imageView = UIImageView(image: UIImage(systemName: "arrow.up.arrow.down"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        
        btn.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
//        btn.backgroundColor = .magenta
        return btn
    }()
    

    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
//        $0.addBorders(edges: [.top, .left], color: .white)
        $0.backgroundColor = .white
        $0.isUserInteractionEnabled = false
//        $0.setTitleColor(.gray, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
    }



//    private let participantsTableView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        return cv
//    }()
    
    private let participantsTableView = UITableView().then {
        $0.layer.borderColor = UIColor(white: 0.8, alpha: 0.7).cgColor
        $0.layer.borderWidth = 1
    }

    private let addPeopleBtn = UIButton().then {
        let plusImage = UIImageView(image: UIImage(systemName: "plus.circle"))
        plusImage.contentMode = .scaleAspectFit
        $0.addSubview(plusImage)

        plusImage.tintColor = .blue
        plusImage.snp.makeConstraints { make in
//            make.top.bottom.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }

//        $0.backgroundColor = .magenta
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
        
//        view.backgroundColor = .gray
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        
        setupParticipants()
        
        registerCollectionView()
        setupLayout()
        setupAddTargets()
    }
    
    private func setupParticipants() {
//        gathering.people
        participants = gathering.people.sorted()
    }

    private func registerCollectionView() {

//        self.participantsTableView.register(
//            ParticipantCollectionViewCell.self,
//            forCellWithReuseIdentifier: cellIdentifier)

        
        participantsTableView.register(ParticipantTableViewCell.self, forCellReuseIdentifier: ParticipantTableViewCell.identifier)
//        participantsTableView.delegate = self
//        participantsTableView.dataSource = self
        participantsTableView.delegate = self
        participantsTableView.dataSource = self
    }



    private func setupLayout() {

        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }

        [confirmBtn, addPeopleBtn, participantsTableView,
         titleLabel, dismissBtn, sortingBtn ]
            .forEach { containerView.addSubview($0)}
        
        confirmBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        addPeopleBtn.snp.makeConstraints { make in
            make.bottom.equalTo(confirmBtn.snp.top).offset(-5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        participantsTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
//            make.leading.trailing.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addPeopleBtn.snp.top).offset(-10)
//            make.bottom.equalTo(addPeopleBtn.snp.centerY)
        }
        
        titleLabel.snp.makeConstraints { make in
//            make.height.equalTo(30)
            make.height.equalTo(34)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.top.equalToSuperview().offset(10)
        }
        
        dismissBtn.snp.makeConstraints { make in
            make.height.equalTo(30)
//            make.height.equalTo(38)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(30)
        }
        
        sortingBtn.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(30)
        }
    }

    private func setupAddTargets() {
        
        dismissBtn.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)

        sortingBtn.addTarget(self, action: #selector(didTapSort), for: .touchUpInside)
        addPeopleBtn.addTarget(self, action: #selector(addPersonBtnTapped(_:)), for: .touchUpInside)

        confirmBtn.addTarget(nil, action: #selector(confirmTapped(_:)), for: .touchUpInside)
    }



    @objc func cancelTapped(_ sender: UIButton) {
        print("cancel tapped!")
        delegate?.hideParticipantsController()
    }


    @objc func confirmTapped(_ sender: UIButton) {
            print("next Tapped!")
//            if participants.count != 0 {
//                // Pass participants
//
//                var gatheringTitle = ""
//                var names = ""
//                for eachName in participants.map({$0.name}) {
//                    names += eachName + ", "
//                }
//
//                if names.count != 0 {
//                    names.removeLast()
//                    names.removeLast()
//                }
//
//                let gathering = Gathering.save(title: gatheringTitle, people: participants)
//
//                delegate?.initializeGathering(with: gathering)
//            }
        delegate?.hideParticipantsController()
        delegate?.updateParticipants()
        
        }


    @objc func groupBtnTapped(_ sender: UIButton) {
        print("btn Tapped!")
        
        guard let selectedGroupBtn = sender as? GroupButton else { return }

        // TODO: set other btn backgroundColor different from the selected one

        if !selectedGroupBtn.isSelected_ {
            selectedGroupBtn.isSelected_ = true
        }

//        selectedGroup = selectedGroupBtn.group
//        print("selectedGroup : \(selectedGroup?.title)")


    }

    @objc func addPersonBtnTapped(_ sender: UIButton) {
        presentAddingPeopleAlert()
        //        showNumberController()
    }

    private func presentAddingPeopleAlert() {
        let alertController = UIAlertController(title: "Add People", message: "추가할 사람을 입력해주세요", preferredStyle: .alert)

        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Name"
        }

        let saveAction = UIAlertAction(title: "Add", style: .default) { alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField

//            guard let newPersonName = textFieldInput.text
            guard textFieldInput.text!.count != 0 else { fatalError("Name must have at least one character") }

            let somePerson = Person.save(name: textFieldInput.text!)

//            self.participants.append(somePerson)
            self.participants.append(somePerson)
            self.reloadCollectionView()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        self.present(alertController, animated: true)
    }
    
    @objc func didTapSort() {
        if participantsTableView.isEditing {
            showBottomBtns()
            participantsTableView.setEditing(false, animated: true)
        } else {
            hideBottomBtns()
            participantsTableView.setEditing(true, animated: true)
        }
    }
    
    private func hideBottomBtns() {
        UIView.animate(withDuration: 1.0) {
            self.addPeopleBtn.isHidden = true
//            self.addPeopleBtn.tintColor = .clear
            self.confirmBtn.isHidden = true
        }
    }
    
    private func showBottomBtns() {
        UIView.animate(withDuration: 1.0) {
            self.addPeopleBtn.isHidden = false
            self.confirmBtn.isHidden = false
        }
    }

}

/*
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
*/

extension ParticipantsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantTableViewCell.identifier, for: indexPath) as! ParticipantTableViewCell
        
//        cell.viewModel = ParticipantViewModel(person: participants[indexPath.row])
//        cell.description = participants[indexPath.row]
        cell.textLabel?.text = participants[indexPath.row].name
//        cell.textLabel?.textAlignment = .right
//        UIListContentConfiguration =
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            let selectedPerson = self.gathering.people.sorted()[indexPath.row]
            
            self.gathering.people.remove(selectedPerson)

            
            DispatchQueue.main.async {
                self.participantsTableView.reloadData()
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
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        participants.swapAt(sourceIndexPath.row, destinationIndexPath.row)
//        let tempOrder = sourceIndexPath.row
        
        let sourcePerson = participants[sourceIndexPath.row]
        let destinationPerson = participants[destinationIndexPath.row]
        
//        sourcePerson.setValue(destinationIndexPath.row, forKey: .Person.order)
//        destinationPerson.setValue(sourceIndexPath.row, forKey: .Person.order)
        // save CoreData !!
        
        Person.changeOrder(of: sourcePerson, with: destinationPerson)
        
    }
}
