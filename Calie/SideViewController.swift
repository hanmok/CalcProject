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
    func dismissSideController()
    func addNewGathering()
    func updateGathering(with gathering: Gathering)
}

class SideViewController: UIViewController {
    
    let cellIdentifier = "SideTableCell"
    var dutchManager: DutchManager
    
    init(dutchManager: DutchManager) {
        self.dutchManager = dutchManager
        
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
            make.leading.top.trailing.equalToSuperview()
        }
        return btn
    }()
    weak var sideDelegate: SideControllerDelegate?
    
    var gatherings: [Gathering] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        updateGatherings()
        
        registerTableView()
        
        setupLayout()
        setupAddTargets()
    }
    
    public func updateGatherings() {
//        let allGatherings = Gathering.fetchAll()
        let allGatherings = dutchManager.fetchGatherings()
        
        gatherings = allGatherings.sorted {$0.createdAt < $1.createdAt }
        // not registered yet ;;
        DispatchQueue.main.async {
            self.gatheringTableView.reloadData()
        }
    }
    
    private let gatheringTableView = UITableView().then {
        $0.layer.borderColor = UIColor(white: 0.8, alpha: 0.7).cgColor
        $0.layer.borderWidth = 1
    }
    
    private let gatheringPlusBtn: UIButton = {
        let btn = UIButton()
        // 왜.. 아래에서 보이지 ?
       let plusImage = UIImageView(image: UIImage(systemName: "plus.circle"))
//        let plusImage = UIImageView(image: UIImage(systemName: "folder"))
        
        let removingLineView = UIView()
        removingLineView.backgroundColor = .white
        
        btn.addSubview(removingLineView)
        removingLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
            make.centerY.equalToSuperview()
        }
        
        btn.addSubview(plusImage)
        plusImage.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    
        return btn
    }()
    
    
    private func registerTableView() {
//        gatheringTableView.register(SideTableCell.self, forCellReuseIdentifier: SideTableCell.identifier)
//        gatheringTableView.register(UITableViewCell.self, forCellReuseIdentifier: SideTableCell.identifier)
        gatheringTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        gatheringTableView.delegate = self
        gatheringTableView.dataSource = self
    }
    
    
    private func setupLayout() {
        view.addSubview(dismissBtn)
        dismissBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.width.height.equalTo(40)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        view.addSubview(gatheringPlusBtn)
        gatheringPlusBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview().inset(100)
        }
        
        view.addSubview(gatheringTableView)
        gatheringTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
            make.top.equalTo(dismissBtn.snp.bottom).offset(10)
            make.bottom.equalTo(gatheringPlusBtn.snp.top).offset(-20)
        }
    }
    

    
    private func setupAddTargets() {
        dismissBtn.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        
        gatheringPlusBtn.addTarget(self, action: #selector(addGaterhing), for: .touchUpInside)
        
    }
    
    @objc func dismissSelf() {
        sideDelegate?.dismissSideController()
    }
    
    
    @objc func addGaterhing() {
        sideDelegate?.addNewGathering()
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
        sideDelegate?.updateGathering(with: gatherings[indexPath.row])
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


//import Foundation
//import UIKit
//import Then
//import SnapKit


//class SideTableCell: UITableViewCell {
//
//    static let identifier = "sideTableCell"
//
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
