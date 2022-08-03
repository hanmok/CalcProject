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
//    var dutchManager: DutchManager
    
//    init(dutchManager: DutchManager) {
    init() {
//        self.dutchManager = dutchManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .black
//        $0.textAlignment = .left
        $0.textAlignment = .center
    }
    
    weak var sideDelegate: SideControllerDelegate?
    
    var gatherings: [Gathering] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
//        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        updateGatherings()
        
        registerTableView()
        
        setupLayout()
        setupAddTargets()
    }
    
    public func updateGatherings() {
//        let allGatherings = Gathering.fetchAll()
//        let allGatherings = dutchManager.fetchGatherings()
        
//        gatherings = allGatherings.sorted {$0.createdAt < $1.createdAt }
//        // not registered yet ;;
//        DispatchQueue.main.async {
//            self.gatheringTableView.reloadData()
//        }
    }
    
    private let gatheringTableView = UITableView().then {
        $0.layer.borderColor = UIColor(white: 0.8, alpha: 0.7).cgColor
        $0.layer.borderWidth = 1
    }
    
    private func registerTableView() {
        
        gatheringTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        gatheringTableView.delegate = self
        gatheringTableView.dataSource = self
    }
    
    
    private func setupLayout() {
        
        view.addSubview(dismissBtn)
        dismissBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.width.height.equalTo(40)
//            make.top.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
        }
        
        view.addSubview(sideLabel)
        sideLabel.snp.makeConstraints { make in
//            make.leading.equalTo(dismissBtn.snp.trailing).offset(75)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            make.height.equalTo(40)
        }
        
        view.addSubview(gatheringTableView)
        gatheringTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
            make.top.equalTo(dismissBtn.snp.bottom).offset(10)
//            make.bottom.equalTo(gatheringPlusBtn.snp.top).offset(-20)
//            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview().inset(tabbarheight)
        }
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
}

extension SideViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gatherings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: SideTableCell.identifier, for: indexPath) as! SideTableCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: SideTableCell.identifier, for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = gatherings[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sideDelegate?.dismissSideVC(with: gatherings[indexPath.row])
        print("selectedGathering title: \(gatherings[indexPath.row].title)")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "") { action, view, completionhandler in
            
            let selectedGathering = self.gatherings[indexPath.row]

            Gathering.deleteSelf(selectedGathering)

            self.gatherings.remove(at: indexPath.row)
            
            DispatchQueue.main.async {
                self.gatheringTableView.reloadData()
            }
            
            completionhandler(true)
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .red
        
        let rightSwipe = UISwipeActionsConfiguration(actions: [delete])
        
        return rightSwipe
    }
}

