////
////  DutchCollectionViewCell.swift
////  Calie
////
////  Created by Mac mini on 2022/05/02.
////  Copyright © 2022 Mac mini. All rights reserved.
////
//
//import UIKit
//
//
//class DutchCollectionCell: UICollectionViewCell {
//
//    var viewModel: CoreDutchUnitViewModel? {
//        didSet {
//            self.loadView()
//        }
//    }
//
//    private let placeNameLabel = UILabel().then {
//        $0.font = UIFont.systemFont(ofSize: 20)
//        $0.textColor = .black
//        $0.textAlignment = .center
//    }
//
//    private let priceLabel = UILabel().then {
//        $0.font = UIFont.systemFont(ofSize: 20)
//        $0.textColor = .black
//        $0.textAlignment = .right
//    }
//
//    private let peopleLabel = UILabel().then {
//        $0.font = UIFont.systemFont(ofSize: 10)
//        $0.textColor = .black
//        $0.textAlignment = .right
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .white
//        setupLayout()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupLayout() {
//        self.addSubview(placeNameLabel)
//        placeNameLabel.snp.makeConstraints { make in
//            make.leading.top.bottom.equalToSuperview()
//            make.width.equalToSuperview().dividedBy(3)
//        }
//
//        self.addSubview(priceLabel)
//        priceLabel.snp.makeConstraints { make in
////            make.trailing.top.equalToSuperview()
//            make.top.equalToSuperview()
//            make.trailing.equalToSuperview().offset(-20)
//            make.width.equalToSuperview().dividedBy(3)
//            make.height.equalTo(self.snp.height).dividedBy(2)
//        }
//
//        self.addSubview(peopleLabel)
//        peopleLabel.snp.makeConstraints { make in
//            make.bottom.equalToSuperview()
//            make.trailing.equalToSuperview().offset(-20)
//            make.top.equalTo(priceLabel.snp.bottom)
//            make.width.equalToSuperview().dividedBy(2)
//        }
//    }
//
//    private func loadView() {
//        guard let viewModel = viewModel else {
//            return
//        }
//
//        placeNameLabel.text = viewModel.placeName
//        priceLabel.text = viewModel.spentAmount
//        peopleLabel.text = viewModel.peopleList
//    }
//}
//
//
//
//
//
//
//
//
//class DutchTableHeader: UITableViewHeaderFooterView {
//
//    static let dutchHeaderIdentifier = "dutchHeaderIdentifier"
//    var viewModel: DutchHeaderViewModel? {
////    var viewModel: COre
//        didSet { self.loadView()}
//    }
//
//    weak var delegate: HeaderDelegate?
//
//    private func loadView() {
//        guard let viewModel = viewModel else {
//            return
//        }
//
//        titleLabel.text = viewModel.gatheringTitle
//        print("loadView in header Triggered")
//    }
//
//    private let titleLabel = UILabel().then {
//        $0.textColor = .black
//        $0.textAlignment = .center
//        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
//        $0.addBorders(edges: .bottom, color: .gray)
//    }
//
//    private let transparentBtn = UIButton().then {
//        $0.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
//        $0.addTarget(nil, action: #selector(handleTappedAction(_:)), for: .touchUpInside)
//    }
//
//    @objc func handleTappedAction(_ sender: UIButton) {
//        delegate?.didTapGroupName()
//    }
//
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//        setupLayout()
//        backgroundColor = .magenta
//    }
//
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupLayout() {
//        self.addSubview(transparentBtn)
//        transparentBtn.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview()
//        }
//
////        self.addSubview(titleLabel)
////        titleLabel.snp.makeConstraints { make in
////            make.leading.top.trailing.bottom.equalToSuperview()
////        }
//
//        transparentBtn.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview()
//        }
//    }
//}
