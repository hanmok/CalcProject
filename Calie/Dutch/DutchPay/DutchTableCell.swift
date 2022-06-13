//
//  DutchTableCell.swift
//  Calie
//
//  Created by Mac mini on 2022/06/13.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit
import Then
import SnapKit


class DutchTableCell: UITableViewCell {

    static let identifier = "DutchTableCell"
    var viewModel: CoreDutchUnitViewModel? {
        didSet {
            self.loadView()
        }
    }

    private let placeNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .black
        $0.textAlignment = .center
    }

    private let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .black
        $0.textAlignment = .right
    }

    private let peopleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textColor = .black
        $0.textAlignment = .right
    }

//    override init(frame: CGRect) {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

//        backgroundColor = .cyan
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        self.addSubview(placeNameLabel)
        placeNameLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }

        self.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalToSuperview().dividedBy(3)
            make.height.equalTo(self.snp.height).dividedBy(2)
        }

        self.addSubview(peopleLabel)
        peopleLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom)
            make.bottom.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalToSuperview().dividedBy(2)
        }
    }

    private func loadView() {
        guard let viewModel = viewModel else {
            return
        }

        placeNameLabel.text = viewModel.placeName
        priceLabel.text = viewModel.spentAmount
        peopleLabel.text = viewModel.peopleList
    }
}
