//
//  ResultViewController.swift
//  Calie
//
//  Created by Mac mini on 2022/07/18.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit

class ResultViewController: UIViewController {
    
    var gathering: Gathering
    
    override func viewDidLoad() {
        super.viewDidLoad()
    print("resultVC presented!")
    }
    
    
    init(gathering: Gathering) {
        self.gathering = gathering
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
