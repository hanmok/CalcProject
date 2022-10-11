//
//  SideViewController.swift
//  Calie
//
//  Created by Mac mini on 2022/07/10.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit
import Then
import SnapKit

protocol SideControllerDelegate: AnyObject {
//    func dismissSideController()
//    func addNewGathering()
    func dismissSideVC(with gathering: Gathering?)
    
    func renameGathering(gathering: Gathering)
    
    func deleteGathering(gathering: Gathering)
    
    func removeLastGathering()
}

class SideViewController: UIViewController {
    lazy var tabbarheight = tabBarController?.tabBar.bounds.size.height ?? 83
    
    let cellIdentifier = "SideTableCell"

    var viewModel: SideViewModel
    
    init() {
        self.viewModel = SideViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var sideDelegate: SideControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.insetsLayoutMarginsFromSafeArea = false
        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
                
        registerTableView()

        setupBindings()
        
        viewModel.fetchAllGatherings()
        
        setupLayout()
        setupAddTargets()
    }
    
    private func setupBindings() {
        viewModel.updateGatherings = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.gatheringTableView.reloadData()
            }
        }
    }
    
    
    
    private let addBtn = UIButton().then {
        
        let imgView = UIImageView()
        let plusImg = UIImage(systemName: "plus")
        imgView.image = plusImg
        
        $0.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    private let gatheringTableView = UITableView().then {
        $0.backgroundColor = UserDefaultSetup.applyColor(onDark: .operatorsBGDark, onLight: .operatorsBGLight)
        $0.separatorStyle = .none
    }
    
    
    private func registerTableView() {
        
        gatheringTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        gatheringTableView.delegate = self
        gatheringTableView.dataSource = self
    }
    
    
    
    
    private func setupAddTargets() {
        
        addBtn.addTarget(self, action: #selector(addGathering), for: .touchUpInside)
    }
    
    
    @objc func addGathering() {

    
        viewModel.addGathering { newGathering in
            
            self.gatheringTableView.reloadData()
            
            self.sideDelegate?.dismissSideVC(with: newGathering)
        }
    }
    
    private func setupLayout() {
        
        view.addSubview(sideLabel)
        sideLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.width.equalToSuperview().dividedBy(2)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.height.equalTo(40)
        }
        
        view.addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
            make.centerY.equalTo(sideLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
        
        view.addSubview(gatheringTableView)
        gatheringTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(sideLabel.snp.bottom).offset(10)
//            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - UI properties
    private let dismissBtn: UIButton = {
        let btn = UIButton()
        let imageView = UIImageView(image: UIImage(systemName: "chevron.left"))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        btn.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(30)
        }
        btn.isHidden = true
        return btn
    }()
    
    private let sideLabel = UILabel().then {
        $0.text = ASD.gatheringRecord.localized
        $0.font = UIFont.systemFont(ofSize: 18)
//        $0.textColor = .black
//        $0.textColor = UserDefaultSetup.applyColor(onDark: .resultTextDM, onLight: .resultTextLM)
        $0.textColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.95, alpha: 1), onLight: UIColor(white: 0.05, alpha: 1))
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
    }
}

extension SideViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.allGatherings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let targetGathering = viewModel.allGatherings[indexPath.row]
        
        cell.textLabel?.text = targetGathering.title
//        cell.backgroundColor = UIColor(white: 0.96, alpha: 1)
        cell.backgroundColor = UserDefaultSetup.applyColor(onDark: .operatorsBGDark, onLight: .operatorsBGLight)
//        cell.textLabel?.textColor = UserDefaultSetup.applyColor(onDark: .semiResultTextDM, onLight: .semiResultTextLM)
        cell.textLabel?.textColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.85, alpha: 1), onLight: UIColor(white: 0.25, alpha: 1))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let targetGathering = viewModel.allGatherings[indexPath.row]
        
        sideDelegate?.dismissSideVC(with: targetGathering)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionHandler in
            
            let targetGathering = self.viewModel.allGatherings[indexPath.row]
            
            // must have at least one gathering
            if self.viewModel.allGatherings.count != 1 {
                self.viewModel.removeGathering(target: targetGathering) {
                    self.gatheringTableView.deleteRows(at: [indexPath], with: .automatic)
                    self.sideDelegate?.deleteGathering(gathering: targetGathering)
                }
            } else {
                self.sideDelegate?.removeLastGathering()
            }

            
            completionHandler(true)
        }
        
        let editName = UIContextualAction(style: .normal, title: "") { action, view, completionHandler in
            // TODO: Implement Renaming
            
            self.presentAskingGatheringName { [weak self] result in
                guard let self = self else { return }
                switch result {
                    
                case .success(let newName):
                    let target = self.viewModel.allGatherings[indexPath.row]
                    self.viewModel.changeGatheringNameAction(newName: newName, target: target) {
                        DispatchQueue.main.async {
                            self.gatheringTableView.reloadData()
                        }
                        self.sideDelegate?.deleteGathering(gathering: target)
                    }
                    
                case .failure(let e):
                    print(e.localizedDescription)
                }
                
            }
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        editName.image = UIImage(systemName: "pencil")
        editName.backgroundColor = UIColor(white: 0.4, alpha: 1)
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete, editName])
        
        return rightSwipe
    }
}


extension SideViewController {
    private func presentAskingGatheringName(completion: @escaping (NewNameAction)) {
        
        let alertController = UIAlertController(title: ASD.editGatheringName.localized, message: ASD.editGatheringNameMsg.localized, preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = ASD.gatheringName.localized
        }
        
        let saveAction = UIAlertAction(title: ASD.done.localized, style: .default) { alert -> Void in
            let textFieldInput = alertController.textFields![0] as UITextField
            
            let newGroupName = textFieldInput.text!
            
            guard newGroupName.count != 0 else {
                completion(.failure(.cancelAskingName))
                fatalError(ASD.emptyNameAlert.localized)
            }
         
            
            completion(.success(newGroupName))
        }
        
        let cancelAction = UIAlertAction(title: ASD.cancel.localized, style: UIAlertAction.Style.destructive, handler: {
            (action : UIAlertAction!) -> Void in
            completion(.failure(.cancelAskingName))
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true)
    }
}
