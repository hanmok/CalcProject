//
//  GroupTableCell.swift
//  Calie
//
//  Created by Mac mini on 2022/06/13.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit
import Then
import SnapKit


class GroupTableCell: UITableViewCell {
    
    static let identifier = "GroupTableCell"
    var viewModel: GroupViewModel? {
        didSet {
            self.loadView()
        }
    }
    
    private let groupTitleLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        $0.textColor = .black
    }
    
    private let peopleNameLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .body)
        $0.textColor = .black
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {

        [groupTitleLabel, peopleNameLabel].forEach { self.addSubview($0) }
        groupTitleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        peopleNameLabel.snp.makeConstraints { make in
            make.top.equalTo(groupTitleLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func loadView() {
        guard let viewModel = viewModel else {
            return
        }
        groupTitleLabel.text = viewModel.title
        peopleNameLabel.text = viewModel.peopleNames
    }
}


struct GroupViewModel {
    private let group: Group
    
    public var title: String { return group.title }
    
    public var peopleNames: String { return group.people.map{ $0.name}.sorted().joined(separator: ", ") }
    
    init(group: Group) {
        self.group = group
    }
}
