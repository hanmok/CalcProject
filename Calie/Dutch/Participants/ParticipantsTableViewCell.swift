//
//  ParticipantCollectionViewCell.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/28.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit

class ParticipantTableViewCell: UITableViewCell {
    
    static let identifier = "ParticipantTableViewCell"
    
    var isAttended = true
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLayout()
    }
    
    private func setupLayout() {
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    private func loadView() {

//        guard let viewModel = viewModel else {
//            return
//        }
        
//        nameLabel.text = viewModel.personName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

