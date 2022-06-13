//
//  NeedingController.swift
//  Calie
//
//  Created by Mac mini on 2022/06/08.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit


protocol NeedingControllerDelegate: AnyObject {
    func presentNumberPad()
    func hideNumberPad()
    func dismissNumberLayer()
}

/// Controller that need numberPadController
class NeedingController: UIViewController {
   
//    func some() {
    func updateNumber(with numberText: String) {
        print("some triggered")
    }
    
//    weak var
    weak var delegate: NeedingControllerDelegate?

    public var numLayerController: NumberLayerController? {
        didSet {
            oldValue?.childDelegate = self
        }
    }
}

extension NeedingController: NumberLayerDelegateToChild {
    func update(with numberText: String) {
        print("printed from needingController: \(numberText)")
        
        updateNumber(with: numberText)
    }
}
