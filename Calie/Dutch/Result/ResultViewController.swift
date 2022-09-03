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
        imageView.tintColor = .black
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

//        // TODO: 여기에만 색상 넣기. 부호 넣어 말어..?
         let toPayLabel = UILabel().then {
            $0.textAlignment = .right
             $0.text = "받을 금액"
        }

         let summaryLabel = UILabel().then {
            $0.textAlignment = .right
        }

        let pricesContainer = UIView()
        
        $0.addSubview(nameLabel)
        $0.addSubview(pricesContainer)
        
        [spentAmountLabel, toPayLabel, summaryLabel].forEach { pricesContainer.addSubview($0)}
        
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(4)
        }
        
        pricesContainer.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        spentAmountLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        
        toPayLabel.snp.makeConstraints { make in
            make.leading.equalTo(spentAmountLabel.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
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
            dividerView,
            calculatedInfoTableView
        ].forEach { self.view.addSubview($0)}
        
        dismissBtn.snp.makeConstraints { make in
            
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
//            make.height.equalTo(viewModel.overallPayInfos.count * 50 + 20 + 40)
            make.height.equalTo(viewModel.overallPayInfos.count * 50 + 40)
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(briefInfoTableView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        calculatedInfoTableView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(viewModel.calculatedResultTuples.count * 50)
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
//        $0.font = UIFont.systemFont(ofSize: 32, weight: .regular)
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    private let dividerView = UIView().then { $0.backgroundColor = UIColor(white: 0.8, alpha: 0.9)}
    
    private let briefInfoTableView = UITableView().then {
        $0.isScrollEnabled = false
    }
    
    private let calculatedInfoTableView = UITableView().then {
        $0.isScrollEnabled = false
    }
    
    
    private func registerTableView() {
        briefInfoTableView.register(ResultBriefInfoTableCell.self, forCellReuseIdentifier: ResultBriefInfoTableCell.identifier)
        briefInfoTableView.delegate = self
        briefInfoTableView.dataSource = self
        briefInfoTableView.rowHeight = 50
        briefInfoTableView.separatorStyle = .none
        
        briefInfoTableView.tableHeaderView = briefHeaderView
        
        calculatedInfoTableView.register(CalculatedResultTableCell.self, forCellReuseIdentifier: CalculatedResultTableCell.identifier)
        calculatedInfoTableView.delegate = self
        calculatedInfoTableView.dataSource = self
        calculatedInfoTableView.rowHeight = 50
        calculatedInfoTableView.separatorStyle = .none
        
    }
}


extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.overallPersonInfos.count
        if tableView == briefInfoTableView {
            return viewModel.overallPayInfos.count
        } else if tableView == calculatedInfoTableView {
            return viewModel.calculatedResultTuples.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == briefInfoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultBriefInfoTableCell.identifier, for: indexPath) as! ResultBriefInfoTableCell
            cell.personCostInfo = viewModel.overallPayInfos[indexPath.row]
            return cell
        } else if tableView == calculatedInfoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: CalculatedResultTableCell.identifier, for: indexPath) as! CalculatedResultTableCell
//            cell.description = viewModel.calcu
//            cell.viewModel =
            cell.exchangeInfo = viewModel.calculatedResultTuples[indexPath.row]
            return cell
        }
      
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
