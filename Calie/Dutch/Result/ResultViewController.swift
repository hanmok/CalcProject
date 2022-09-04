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
    
    let briefRowHeight: CGFloat = 80
    let calculatedRowHeight: CGFloat = 50
    
    
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
        
        let infoLabel = UILabel().then {
            $0.attributedText = NSAttributedString(string: "개인별 지출 현황", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)])
        }
        
        $0.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        let bottomLineView = UIView().then {
            $0.backgroundColor = UIColor(white: 0.6, alpha: 0.9)
        }
        
        infoLabel.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private let calculatedResultHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 40)).then {
        
        let infoLabel = UILabel().then {
            $0.attributedText = NSAttributedString(string: "정산 결과", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)])
        }
        
        $0.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        
        let bottomLineView = UIView().then {
            $0.backgroundColor = UIColor(white: 0.6, alpha: 0.9)
        }
        
        infoLabel.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
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
//            make.height.equalTo(viewModel.overallPayInfos.count * 50 + 40)
            make.height.equalTo(viewModel.overallPayInfos.count * Int(self.briefRowHeight) + 40)
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(briefInfoTableView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(1)
        }
        
        calculatedInfoTableView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(viewModel.calculatedResultTuples.count * Int(self.calculatedRowHeight) + 40) // 40: Header Size
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
    
    private let dividerView = UIView()
//        .then { $0.backgroundColor = UIColor(white: 0.5, alpha: 1)}
    
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
        briefInfoTableView.rowHeight = self.briefRowHeight
        briefInfoTableView.separatorStyle = .singleLine
        
        briefInfoTableView.tableHeaderView = briefHeaderView
        
        calculatedInfoTableView.register(CalculatedResultTableCell.self, forCellReuseIdentifier: CalculatedResultTableCell.identifier)
        calculatedInfoTableView.delegate = self
        calculatedInfoTableView.dataSource = self
        calculatedInfoTableView.rowHeight = self.calculatedRowHeight
        calculatedInfoTableView.separatorStyle = .none
        
        calculatedInfoTableView.tableHeaderView = calculatedResultHeaderView
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
