//
//  DutchHeader.swift
//  Calie
//
//  Created by Mac mini on 2022/05/02.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit



class DutchHeader: UICollectionReusableView {
    
    var viewModel: DutchHeaderViewModel? {
        didSet { self.loadView()}
    }
    
    private func loadView() {
        guard let viewModel = viewModel else {
            return
        }
        
        titleLabel.text = viewModel.gatheringTitle
        print("loadView in header Triggered")
    }
    
    private let titleLabel = UILabel().then {
//        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        $0.addBorders(edges: .bottom, color: .gray)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        print("header has loaded")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
}


struct DutchHeaderViewModel {
    let gathering: Gathering2
    
    var gatheringTitle: String { return gathering.title }
}

