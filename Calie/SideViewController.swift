//
//  SideViewController.swift
//  Calie
//
//  Created by Mac mini on 2022/07/10.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit
import Then
import SnapKit

class SideViewController: UIViewController {
    
    
    var gatherings: [Gathering] = []
    // tableview
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        view.backgroundColor = .magenta
        registerTableView()
    }
    
    private let sideTableView = UITableView().then {
        $0.layer.borderColor = UIColor(white: 0.8, alpha: 0.7).cgColor
        $0.layer.borderWidth = 1
    }
    
    private func registerTableView() {
        sideTableView.register(DutchTableCell.self, forCellReuseIdentifier: DutchTableCell.identifier)
        sideTableView.delegate = self
        sideTableView.dataSource = self
        sideTableView.rowHeight = 70
        
//        sideTableView.tableHeaderView = headerContainer
        
    }
    
    
}

extension SideViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gatherings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DutchTableCell.identifier, for: indexPath) as! SideTableCell
        
        cell.viewModel = SideViewModel(gathering: gatherings[indexPath.row])
        
        return cell
    }
}


//import Foundation
//import UIKit
//import Then
//import SnapKit


class SideTableCell: UITableViewCell {
    
    static let identifier = "sideTableCell"
    var viewModel: SideViewModel? {
        didSet {
            self.loadView()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func loadView() {
        guard let viewModel = viewModel else {
            return
        }
    }
}


struct SideViewModel {
    var gathering: Gathering
    
    
}
