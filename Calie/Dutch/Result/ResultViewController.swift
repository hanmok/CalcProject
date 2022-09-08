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
//    static let headerHeight = 50
    let briefRowHeight: CGFloat = 65 // prev: 80
    let calculatedRowHeight: CGFloat = 50
    let headerHeight: CGFloat = 50
//    let scrollView = UIScrollView()
//        .then {
////        $0.backgroundColor = .magenta
//    }
    
    var addingDelegate: AddingUnitControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableView()
        setupLayout()
        setupAddTargets()
        view.backgroundColor = .white
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
//        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 3000)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
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
    
    private let briefHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width - 16, height: 50)).then {
        
        let infoLabel = UILabel().then {
            $0.attributedText = NSAttributedString(string: "개인별 지출 현황", attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .regular)])
        }
        
        $0.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        let bottomLineView = UIView().then {
            $0.backgroundColor = UIColor(white: 0.25, alpha: 0.9)
            $0.layer.cornerRadius = 2
            $0.clipsToBounds = true
        }
        
        infoLabel.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
    }
    
    private let calculatedResultHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width - 100, height: 50)).then {
        
        let infoLabel = UILabel().then {
            $0.attributedText = NSAttributedString(string: "정산 결과", attributes: [.font: UIFont.systemFont(ofSize: 26, weight: .regular)])
        }
        
        $0.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview()
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        
        let bottomLineView = UIView().then {
            $0.backgroundColor = UIColor(white: 0.25, alpha: 0.9)
            $0.layer.cornerRadius = 2
            
            $0.clipsToBounds = true
        }
        
        infoLabel.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(5)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let calculatedTableHeight: CGFloat = CGFloat(viewModel.calculatedResultTuples.count * Int(self.calculatedRowHeight) + Int(self.headerHeight))
        let personalTableHeight: CGFloat = CGFloat(viewModel.overallPayInfos.count * Int(self.briefRowHeight) + Int(self.headerHeight))
        
//        scrollView.contentSize = CGSize(width: view.frame.size.width, height: calculatedTableHeight + personalTableHeight + 290)
        
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: calculatedTableHeight + personalTableHeight + 84)
        
//        scrollView.contentSize = CGSize(width: 1000, height: 3000)
    }
    
    private func setupLayout() {
        
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        

        [
            dismissBtn,
            titleLabel,
            briefInfoTableView,
//            dividerView,
            calculatedInfoTableView
        ].forEach { self.scrollView.addSubview($0)}
        

        scrollView.isScrollEnabled = true
        
        
        dismissBtn.snp.makeConstraints { make in
            
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(50)
//            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.top.equalToSuperview()
//            make.top.equalToSuperview().offset(30)
            make.centerY.equalTo(dismissBtn.snp.centerY)
        }
        
        
//        calculatedInfoTableView.snp.makeConstraints { make in
////            make.leading.trailing.equalToSuperview().inset(16)
//            make.leading.equalTo(scrollView.snp.leading)
//            make.trailing.equalTo(scrollView.snp.trailing)
////            make.top.equalTo(titleLabel.snp.bottom).offset(30)
//            make.top.equalTo(titleLabel.snp.bottom).offset(20)
//            make.height.equalTo(viewModel.calculatedResultTuples.count * Int(self.calculatedRowHeight) + Int(self.headerHeight)) // 40: Header Size
//        }
        

//        calculatedInfoTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
//        calculatedInfoTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
//        calculatedInfoTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
//        calculatedInfoTableView.heightAnchor.constraint(equalToConstant: 1000).isActive = true
//        scrollView.addSubview(tfTableView)
        
//        calculatedInfoTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50).isActive = true
//        calculatedInfoTableView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
//        calculatedInfoTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
//        calculatedInfoTableView.heightAnchor.constraint(equalToConstant: 1000).isActive = true
        
        calculatedInfoTableView.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.top.equalTo(dismissBtn.snp.bottom).offset(30)
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-32)
            make.height.equalTo(viewModel.calculatedResultTuples.count * Int(self.calculatedRowHeight) + Int(self.headerHeight))

        }
        
        briefInfoTableView.snp.makeConstraints { make in
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-32)
            make.top.equalTo(calculatedInfoTableView.snp.bottom).offset(40)
            make.height.equalTo(viewModel.overallPayInfos.count * Int(self.briefRowHeight) + Int(self.headerHeight))
        }
    }
    
    private func setupAddTargets() {
        dismissBtn.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
    }
    
    @objc func dismissTapped(_ sender: UIButton) {
        addingDelegate?.dismissChildVC()
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
print("index: \(indexPath)")
        if tableView == briefInfoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultBriefInfoTableCell.identifier, for: indexPath) as! ResultBriefInfoTableCell
            cell.personCostInfo = viewModel.overallPayInfos[indexPath.row]
            cell.isUserInteractionEnabled = false
            return cell
        } else if tableView == calculatedInfoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: CalculatedResultTableCell.identifier, for: indexPath) as! CalculatedResultTableCell
            cell.isUserInteractionEnabled = false
            
            cell.exchangeInfo = viewModel.calculatedResultTuples[indexPath.row]
            return cell
        }
      
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
}
