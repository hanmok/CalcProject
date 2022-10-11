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
    
    public var name: String? {
        didSet {
            self.loadView()
        }
    }
    
    var isAttended = true
    
    public let nameLabel: UILabel = {
        let label = UILabel()
//        label.textAlignment = .right
        label.textAlignment = .left
        label.textColor = UserDefaultSetup.applyColor(onDark: UIColor(white: 0.8, alpha: 1), onLight: UIColor(white: 0.2, alpha: 1))
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
        
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    private func loadView() {

        nameLabel.text = name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

