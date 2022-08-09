//
//  ResultViewController.swift
//  Calie
//
//  Created by Mac mini on 2022/07/18.
//  Copyright © 2022 Mac mini. All rights reserved.
//

// MARK: - 원 이 너무 많음. 화면에 따로 '단위: 원' 써주고, 금액만 써주는게 좋을 것 같아.

import Foundation
import UIKit
import SnapKit

class ResultViewController: UIViewController {
    
    var gathering: Gathering
    
    var viewModel: ResultViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableView()
        setupLayout()
        setupAddTargets()
        view.backgroundColor = .white
    }
    
    private let dismissBtn = UIButton().then {
        
        let imageView = UIImageView(image: UIImage(systemName: "chevron.left")!)
        imageView.contentMode = .scaleAspectFit
        $0.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    private let briefHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 40)).then {
        let nameLabel = UILabel().then { $0.text = "name"
            $0.textAlignment = .left
        }
    
        
         let spentAmountLabel = UILabel().then {
            $0.textAlignment = .right
             $0.text = "쓴 금액"
        }
//
//        // TODO: 여기에만 색상 넣기. 부호 넣어 말어..?
         let toPayLabel = UILabel().then {
            $0.textAlignment = .right
//            $0.backgroundColor = .cyan
             $0.text = "보낼 금액"
        }
        
         let summaryLabel = UILabel().then {
            $0.textAlignment = .right
            $0.backgroundColor = .orange
             $0.text = "종합"
        }
        
        let pricesContainer = UIView()
        
        $0.addSubview(nameLabel)
        $0.addSubview(pricesContainer)
        
//        $0.addSubview(spentAmountLabel)
//        $0.addSubview(toPayLabel)
//        $0.addSubview(summaryLabel)
        [spentAmountLabel, toPayLabel, summaryLabel].forEach { pricesContainer.addSubview($0)}
        
        
//        nameLabel.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(10)
//            make.top.bottom.equalToSuperview()
//            make.width.equalTo(70)
//        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
//            make.width.equalTo(70)
            make.width.equalToSuperview().dividedBy(4)
        }
        
//        spentAmountLabel.snp.makeConstraints { make in
//            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
//            make.top.bottom.equalToSuperview()
////            make.width.equalTo(100)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//
//        toPayLabel.snp.makeConstraints { make in
//            make.leading.equalTo(spentAmountLabel.snp.trailing).offset(10)
//            make.top.bottom.equalToSuperview()
////            make.width.equalTo(100)
//            make.width.equalToSuperview().dividedBy(4)
//        }
//
//        summaryLabel.snp.makeConstraints { make in
//            make.leading.equalTo(toPayLabel.snp.trailing).offset(10)
//            make.trailing.equalToSuperview().inset(10)
//            make.top.bottom.equalToSuperview()
//        }
        
        pricesContainer.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        spentAmountLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing)
            make.top.bottom.equalToSuperview()
//            make.width.equalTo(100)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        toPayLabel.snp.makeConstraints { make in
            make.leading.equalTo(spentAmountLabel.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
//            make.width.equalTo(100)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        summaryLabel.snp.makeConstraints { make in
            make.leading.equalTo(toPayLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview()
        }
        
        
    }
    
    private func setupLayout() {
        
        [
            dismissBtn,
            titleLabel,
            briefInfoTableView,
            dividerView
        ].forEach { self.view.addSubview($0)}
        
        dismissBtn.snp.makeConstraints { make in
//            make.leading.equalToSuperview()
//            make.top.equalToSuperview().offset(60)
            
            make.top.equalToSuperview().offset(56)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        briefInfoTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.height.equalTo(viewModel.overallPayInfos.count * 40 + 20 + 40)
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(briefInfoTableView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
    }
    
    private func setupAddTargets() {
        dismissBtn.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
    }
    
    @objc func dismissTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    init(gathering: Gathering) {
        self.gathering = gathering
        self.viewModel = ResultViewModel(gathering: gathering)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    
    private let titleLabel = UILabel().then {
        $0.text = "정산 결과"
        $0.textAlignment = .center
        $0.textColor = .black
//        $0.font = UIFont.preferredFont(forTextStyle: .headline)
        $0.font = UIFont.systemFont(ofSize: 32, weight: .regular)
    }
    
    private let dividerView = UIView().then { $0.backgroundColor = UIColor(white: 0.8, alpha: 0.9)}
    
    private let briefInfoTableView = UITableView()
    
    private func registerTableView() {
        briefInfoTableView.register(ResultBriefInfoTableCell.self, forCellReuseIdentifier: ResultBriefInfoTableCell.identifier)
        briefInfoTableView.delegate = self
        briefInfoTableView.dataSource = self
        briefInfoTableView.rowHeight = 50
        briefInfoTableView.separatorStyle = .none
        
//        briefInfoTableView.tableFooterView = UIView()
        
        briefInfoTableView.tableHeaderView = briefHeaderView
    }
}


extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.overallPersonInfos.count
        return viewModel.overallPayInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResultBriefInfoTableCell.identifier, for: indexPath) as! ResultBriefInfoTableCell
//        cell.overallPersonInfo = viewModel.overallPersonInfos[indexPath.row]
        cell.personCostInfo = viewModel.overallPayInfos[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
