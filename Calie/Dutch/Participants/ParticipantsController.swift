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
    func updateParticipants(with participants: [Person])
}

extension ParticipantsController: DutchpayToParticipantsDelegate {
    func updateParticipants3(gathering: Gathering) {
//        self.gathering = gathering
//        self.participants = gathering.people.sorted()
        DispatchQueue.main.async {
            self.participantsTableView.reloadData()
        }
        print("updating flag!!")
    }
}

class ParticipantsController: UIViewController{
    
    // MARK: - Properties
    
    weak var delegate: ParticipantsVCDelegate?

    private var participants: [Person]
    private var names: [String]
    
    init(participants: [Person]) {
        self.participants = participants
        self.names = participants.map { $0.name }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    private func reloadCollectionView() {
        print("flag4")
        DispatchQueue.main.async {
            self.participantsTableView.reloadData()
            print("what the..")
        }
        print("flag5")
    }


    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.93, alpha: 1)
    }
    
    private let titleLabel = UILabel().then {
        let attrTitle = NSAttributedString(string: "참가 인원 수정", attributes: [
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
        
        return btn
    }()
    
    private let editingBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("EDIT", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    

    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.backgroundColor = .white
        $0.setTitleColor(.black, for: .normal)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
    }

    
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
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
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
    
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        
        setupParticipants()
        
        registerTableView()
        setupLayout()
        setupAddTargets()
    }
    
    private func setupParticipants() {
        
    }

    private func registerTableView() {
        participantsTableView.register(ParticipantTableViewCell.self, forCellReuseIdentifier: ParticipantTableViewCell.identifier)
        
        participantsTableView.delegate = self
        participantsTableView.dataSource = self
    }


    private func setupLayout() {

        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }

        [confirmBtn,
         addPeopleBtn,
         participantsTableView,
         titleLabel, dismissBtn, editingBtn ]
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
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addPeopleBtn.snp.top).offset(-10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.top.equalToSuperview().offset(10)
        }
        
        dismissBtn.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(30)
        }
        
        
        editingBtn.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
            make.width.equalTo(70)
        }
    }

    private func setupAddTargets() {
        
        dismissBtn.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)

        editingBtn.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        addPeopleBtn.addTarget(self, action: #selector(addPersonBtnTapped(_:)), for: .touchUpInside)
        
        confirmBtn.addTarget(nil, action: #selector(confirmTapped(_:)), for: .touchUpInside)
    }

    @objc func cancelTapped(_ sender: UIButton) {
        print("cancel tapped!")
        delegate?.updateParticipants(with: participants)
        delegate?.hideParticipantsController()
    }
    
    
    @objc func confirmTapped(_ sender: UIButton) {
        print("next Tapped!")
        delegate?.updateParticipants(with: participants)
        delegate?.hideParticipantsController()
    }
    
    
    @objc func groupBtnTapped(_ sender: UIButton) {
        print("btn Tapped!")
        
        guard let selectedGroupBtn = sender as? GroupButton else { return }

        // TODO: set other btn backgroundColor different from the selected one

        if !selectedGroupBtn.isSelected_ {
            selectedGroupBtn.isSelected_ = true
        }
    }

    @objc func addPersonBtnTapped(_ sender: UIButton) {
        presentAddingPeopleAlert()
    }

    private func presentAddingPeopleAlert() {
        let alertController = UIAlertController(title: "Add People", message: "추가할 사람을 입력해주세요", preferredStyle: .alert)

        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Name"
        }

        let saveAction = UIAlertAction(title: "Add", style: .default) { alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField

            let newName = textFieldInput.text!
            
            guard newName.count != 0 else { fatalError("Name must have at least one character") }

            if self.names.contains(newName) {
                // TODO: show message
                print("same name exist!")
            } else {
                let somePerson = Person.save(name: newName)
                self.participants.append(somePerson)
                
                self.reloadCollectionView()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        self.present(alertController, animated: true)
    }
    
    @objc func didTapEdit() {
        if participantsTableView.isEditing {
            // not on Editing Mode
            editingBtn.setTitle("EDIT", for: .normal)
            showDismissBtn()
            showBottomBtns()
            participantsTableView.setEditing(false, animated: true)
        } else {
            // on Editing Mode
            editingBtn.setTitle("Done", for: .normal)
            hideDismissBtn()
            hideBottomBtns()
            participantsTableView.setEditing(true, animated: true)
        }
    }
    
    private func hideBottomBtns() {
        DispatchQueue.main.async {
            self.addPeopleBtn.isHidden = true
            self.confirmBtn.isHidden = true
        }
    }

    private func hideDismissBtn() {
        DispatchQueue.main.async {
            self.dismissBtn.isHidden = true
        }
    }
    
    private func showBottomBtns() {
        
        DispatchQueue.main.async {
            self.addPeopleBtn.isHidden = false
            self.confirmBtn.isHidden = false
        }
    }
    private func showDismissBtn() {
        DispatchQueue.main.async {
            self.dismissBtn.isHidden = false
        }
    }

}

extension ParticipantsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantTableViewCell.identifier, for: indexPath) as! ParticipantTableViewCell
        
        cell.textLabel?.text = participants[indexPath.row].name
//        cell.textLabel?.textAlignment = .right
//        UIListContentConfiguration =
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
//            let selectedPerson = self.gathering.people.sorted()[indexPath.row]
            
//            self.gathering.people.remove(selectedPerson)
            
            
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
        
        let sourcePerson = participants[sourceIndexPath.row]
        let destinationPerson = participants[destinationIndexPath.row]
        
        
        Person.changeOrder(of: sourcePerson, with: destinationPerson)
        
    }
}
