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
    func update()
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
    
    var viewModel: ParticipantsViewModel
    
    weak var delegate: ParticipantsVCDelegate?
    
    private var updatedParticipants: [Person] = []
    
    
    init(currentGathering: Gathering) {
        self.viewModel = ParticipantsViewModel(gathering: currentGathering)
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        
        setupBindings()
        
        registerTableView()
        setupLayout()
        setupAddTargets()
    }
    
    private func setupBindings() {
        viewModel.updateParticipants = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.participantsTableView.reloadData()
            }
        }
    }
    
    
    private func setupAddTargets() {
        
//        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        editingBtn.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        
        addPeopleBtn.addTarget(self, action: #selector(addPersonBtnTapped(_:)), for: .touchUpInside)
        
//        confirmBtn.addTarget(nil, action: #selector(confirmAction), for: .touchUpInside)
        
        dismissBtn.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
    }
    
    
//    @objc func cancelAction() {
//        //TODO: Add alert if any changes occurred.
//        delegate?.hideParticipantsController()
//    }
    
//    @objc func confirmAction() {
    @objc func dismissTapped() {
        
//        participants.forEach { print($0.name) }
//        viewModel.updatePeople()
//        delegate?.updateParticipants(with: participants)
        delegate?.hideParticipantsController()
        
        delegate?.update()
    }
    
    
//    @objc func groupBtnTapped(_ sender: UIButton) {
//        print("btn Tapped!")
//
//        guard let selectedGroupBtn = sender as? GroupButton else { return }
//
//        // TODO: set other btn backgroundColor different from the selected one
//
//        if !selectedGroupBtn.isSelected_ {
//            selectedGroupBtn.isSelected_ = true
//        }
//    }
    
    
    
    
    @objc func didTapEdit() {
        if participantsTableView.isEditing {
            // not on Editing Mode
            editingBtn.setTitle("EDIT", for: .normal)
            
            // show !
            
            dismissBtn.snp.remakeConstraints { make in
                make.height.equalTo(30)
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.leading.equalToSuperview().inset(10)
                make.width.equalTo(30)
            }
            
            addPeopleBtn.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.height.equalTo(55)
                make.centerX.equalToSuperview()
                make.width.equalTo(40)
            }
            
            participantsTableView.setEditing(false, animated: true)
            
        } else {
            // turn on Editing Mode
            editingBtn.setTitle("Done", for: .normal)
            
            // hide !
            
            dismissBtn.snp.remakeConstraints { make in
                make.height.equalTo(30)
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.leading.equalToSuperview().offset(-30)
                make.width.equalTo(30)
            }
            
            addPeopleBtn.snp.remakeConstraints { make in
                make.bottom.equalToSuperview().offset(50)
                make.centerX.equalToSuperview()
                make.width.equalTo(40)
                make.height.equalTo(55)
            }
            
            participantsTableView.setEditing(true, animated: true)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func addPersonBtnTapped(_ sender: UIButton) {
        presentAddingPeopleAlert()
    }
    
    private func presentAddingPeopleAlert() {
        let alertController = UIAlertController(title: "Add People", message: "추가할 사람을 입력해주세요", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Name"
            textField.tag = 100
            textField.delegate = self
        }
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
            
            let newName = textFieldInput.text!
            
            self.addPerson(newName: newName)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
    
    private func addPerson(newName: String) {
        guard newName.count != 0 else { fatalError("Name must have at least one character") }
        
        // TODO: Dupliccate check
        //        if self.names.contains(newName) {
        
        viewModel.addPerson(name: newName, needDuplicateCheck: true, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success():
                self.showToast(message: "\(newName) has added", defaultWidthSize: screenWidth , defaultHeightSize: screenHeight, widthRatio: 0.8, heightRatio: 0.05, fontsize: 16)
                
            case .failure(_):
                self.showToast(message: "person with name: \(newName) already exist!", defaultWidthSize: screenWidth , defaultHeightSize: screenHeight, widthRatio: 0.8, heightRatio: 0.05, fontsize: 16)
            }
        })
    }
    
    
    // MARK: - UI Properties
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.93, alpha: 1)
    }
    
    private let titleLabel = UILabel().then {
        let attrTitle = NSAttributedString(string: "참가 인원", attributes: [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ])
        
        $0.attributedText = attrTitle
        $0.textAlignment = .center
    }
    
        private let dismissBtn: UIButton = {
            let btn = UIButton()
            let imageView = UIImageView(image: UIImage(systemName: "chevron.left"))
            imageView.contentMode = .scaleAspectFit
//            imageView.tintColor = .black
    
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
    
//    private let cancelBtn = UIButton().then {
//        $0.setTitle("Cancel", for: .normal)
//        $0.backgroundColor = .white
//        $0.setTitleColor(.red, for: .normal)
//        $0.layer.borderWidth = 1
//        $0.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
//        $0.layer.cornerRadius = 10
//    }
    
    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.backgroundColor = .white
        $0.setTitleColor(.black, for: .normal)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
        $0.layer.cornerRadius = 10
    }
    
    
    private let participantsTableView = UITableView().then {
//        $0.layer.borderColor = UIColor(white: 0.8, alpha: 0.7).cgColor
        $0.layer.borderColor = UIColor.clear.cgColor
//        $0.layer.borderWidth = 1
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
    
    private let bottomContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.clear.cgColor
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
        
        [
//            cancelBtn, confirmBtn,
//         addPeopleBtn,
            bottomContainerView,
         participantsTableView,
         titleLabel,
         editingBtn, dismissBtn]
            .forEach { containerView.addSubview($0)}
        
        // TODO: Make it contained in Stack View
//        cancelBtn.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(10)
//            make.height.equalTo(50)
//            make.width.equalToSuperview().dividedBy(2.15)
//            make.bottom.equalToSuperview().inset(10)
//        }
        
//        confirmBtn.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().inset(10)
//            make.width.equalToSuperview().dividedBy(2.15)
//            make.bottom.equalToSuperview().inset(10)
//            make.height.equalTo(50)
//        }
        
        
        
        
        
        participantsTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
//            make.bottom.equalTo(addPeopleBtn.snp.top).offset(-10)
//            make.bottom.equalTo(bottomContainerView.snp.top).offset(5)
            make.bottom.equalToSuperview().inset(50)
        }
        
        
        bottomContainerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
        }
        
        bottomContainerView.addSubview(addPeopleBtn)
        
        addPeopleBtn.snp.makeConstraints { make in
//            make.bottom.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.bottom.equalToSuperview()
            make.height.equalTo(55)
        }
        
        
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.top.equalToSuperview().offset(10)
        }
        
        editingBtn.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
            make.width.equalTo(70)
        }
        
        dismissBtn.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ParticipantsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantTableViewCell.identifier, for: indexPath) as! ParticipantTableViewCell
        
        let participant = viewModel.participants[indexPath.row]
        // MARK: - Not Using Custom Cell yet.
        cell.textLabel?.text = participant.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            self.viewModel.removePerson(idx: indexPath.row) {
                completionhandler(true)
            }
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
        
        viewModel.swapPersonOrder(of: sourceIndexPath.row, with: destinationIndexPath.row)
        
    }
}

extension ParticipantsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 100 {
            print("hi")
            addPerson(newName: textField.text!)
            textField.text = ""
        }
        return false
    }
}
