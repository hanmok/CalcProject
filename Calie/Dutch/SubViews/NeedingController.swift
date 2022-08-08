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
    func initializeNumberText()
}

protocol NeedingControllerProtocol: AnyObject {
    func updateNumber(with numberText: String)
    func fullPriceAction2()
    var numLayerController: NumberLayerController? { get set }
    var delegate: NeedingControllerDelegate? { get set }
}



class NeedingController: UIViewController, NeedingControllerProtocol {
    
    weak var delegate: NeedingControllerDelegate?
    
    func updateNumber(with numberText: String) {
        
    }
    
    func fullPriceAction2() {
        
    }
    
    public var numLayerController: NumberLayerController? {
        didSet {
            oldValue?.childDelegate = self
        }
    }
}

extension NeedingController: NumberLayerDelegateToChild {
    func fullPriceAction() {
        print("fullPriceAction")
        fullPriceAction2()
    }
    
    func update(with numberText: String) {
        print("printed from needingController: \(numberText)")
        
        updateNumber(with: numberText)
    }
}
