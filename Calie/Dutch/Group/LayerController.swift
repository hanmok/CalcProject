//
//  LayerController.swift
//  Calie
//
//  Created by Mac mini on 2022/06/14.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit

class LayerController: UIViewController {
    
    let backgroundColor: UIColor
    
    weak var delegate: LayerControllerDelegate?
    
    private var presentingChildVC: UIViewController
    
    init(bgColor: UIColor, presentingChildVC: UIViewController) {
        self.backgroundColor = bgColor
        self.presentingChildVC = presentingChildVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol LayerControllerDelegate: AnyObject {
    func dismissLayerController()
}
