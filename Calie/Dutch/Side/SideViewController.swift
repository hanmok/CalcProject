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
    func dismissSideVC(with gathering: Gathering)
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
        
//        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
//        navigationController?.navigationBar.isHidden = true
        
        
        view.insetsLayoutMarginsFromSafeArea = false
        navigationController?.navigationBar.isHidden = true
        
//        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.backgroundColor = .white
        print("viewDidLoad in SideViewController called")
        
//        viewModel.viewDidLoadAction()
        
        registerTableView()

        
        setupBindings()
        
        viewModel.fetchAllGatherings()

        
        setupLayout()
//        setupAddTargets()
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
//        $0.layer.borderColor = UIColor(white: 0.8, alpha: 0.7).cgColor
//        $0.layer.borderWidth = 1
//        $0.layer.cornerRadius = 12

//        $0.backgroundColor = UIColor(white: 0.96, alpha: 1)
        
        $0.backgroundColor = UIColor(white: 0.96, alpha: 1)
        $0.separatorStyle = .none
    }
    
    
    
    private func registerTableView() {
        
        gatheringTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        gatheringTableView.delegate = self
        gatheringTableView.dataSource = self
    }
    
    
    
    
    private func setupAddTargets() {
        
//        dismissBtn.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        
//        gatheringPlusBtn.addTarget(self, action: #selector(addGaterhing), for: .touchUpInside)
        
    }
    
//    @objc func dismissSelf() {
//        sideDelegate?.dismissSideController()
//    }
    
    
    @objc func addGaterhing() {
//        sideDelegate?.addNewGathering()
    }
    
    private func setupLayout() {
        
        view.addSubview(sideLabel)
        sideLabel.snp.makeConstraints { make in
//            make.leading.equalTo(dismissBtn.snp.trailing).offset(75)
            make.leading.equalToSuperview().offset(10)
//            make.trailing.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.height.equalTo(40)
        }
        
        view.addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
//            make.top.trailing.equalToSuperview().inset(10)
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.centerY.equalTo(sideLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
        
        view.addSubview(gatheringTableView)
        gatheringTableView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(5)
            make.leading.trailing.equalToSuperview()
//            make.top.equalTo(dismissBtn.snp.bottom).offset(10)
            make.top.equalTo(sideLabel.snp.bottom).offset(10)
//            make.bottom.equalTo(gatheringPlusBtn.snp.top).offset(-20)
//            make.bottom.equalTo(view.safeAreaLayoutGuide)
//            make.bottom.equalToSuperview().inset(tabbarheight)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
    }
    
    // MARK: - UI properties
    private let dismissBtn: UIButton = {
        let btn = UIButton()
        let imageView = UIImageView(image: UIImage(systemName: "chevron.left"))
        imageView.tintColor = .black
//        imageView.contentMode = .scaleToFit
        imageView.contentMode = .scaleAspectFit
        btn.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(30)
        }
//        btn.backgroundColor = .magenta
        btn.isHidden = true
        return btn
    }()
    
    private let sideLabel = UILabel().then {
        $0.text = "지난 모임"
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.textColor = .black
        $0.textAlignment = .left
//        $0.textAlignment = .center
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
        cell.backgroundColor = UIColor(white: 0.96, alpha: 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let targetGathering = viewModel.allGatherings[indexPath.row]
        
        sideDelegate?.dismissSideVC(with: targetGathering)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            let targetGathering = self.viewModel.allGatherings[indexPath.row]
            
            self.viewModel.removeGathering(target: targetGathering)
            
            completionhandler(true)
        }
        
        let editName = UIContextualAction(style: .normal, title: "") { action, view, completionHandler in
            // TODO: Implement Renaming
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        editName.image = UIImage(systemName: "pencil")
        editName.backgroundColor = UIColor(white: 0.4, alpha: 1)
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete, editName])
        
        return rightSwipe
    }
}

