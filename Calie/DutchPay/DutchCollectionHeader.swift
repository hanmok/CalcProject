////
////  DutchHeader.swift
////  Calie
////
////  Created by Mac mini on 2022/05/02.
////  Copyright © 2022 Mac mini. All rights reserved.
////
//
//import UIKit
//
//
//
//protocol HeaderDelegate: AnyObject {
//    func didTapGroupName()
//}
//
//class DutchCollectionHeader: UICollectionReusableView {
//
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
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayout()
//        print("header has loaded")
//        backgroundColor = .magenta
//    }
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
//
//
//struct DutchHeaderViewModel {
////    let gathering: Gathering2
//    let gathering: Gathering
//
//    var gatheringTitle: String { return gathering.title }
//}
//
