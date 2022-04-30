//
//  ParticipantCollectionViewCell.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/28.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit

class ParticipantCollectionViewCell: UICollectionViewCell {
    
    
    var viewModel: ParticipantViewModel? {
        didSet {
            self.loadView()
        }
    }

    var isAttended = true
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    private func setupLayout() {
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
    }
    
    private func loadView() {

        guard let viewModel = viewModel else {
            return
        }
        
        nameLabel.text = viewModel.personName
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

