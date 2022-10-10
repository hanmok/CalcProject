//
//  LayerView.swift
//  Calie
//
//  Created by Mac mini on 2022/06/08.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit
import Then


protocol NumberLayerToChildDelegate: AnyObject {
    func update(with numberText: String)
    func completeAction2()
}

protocol NumberLayerToParentDelegate: AnyObject {
    func dismissChildVC()
}

class NumberLayerController : UIViewController {
    
    let backgroundColor: UIColor
    
    weak var childDelegate: NumberLayerToChildDelegate?
    weak var parentDelegate: NumberLayerToParentDelegate?
    
    private var presentingChildVC: NeedingController
    
    private let numberPadController = CustomNumberPadController()
    
    init(bgColor: UIColor, presentingChildVC: NeedingController) {
        self.backgroundColor = bgColor
        self.presentingChildVC = presentingChildVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        prepareNumberPad()
        setupDelegate()
    }
    
    private func setupLayout() {
//        view.backgroundColor = .white
        view.backgroundColor = UserDefaultSetup.applyColor(onDark: .emptyAndNumbersBGDark, onLight: .emptyAndNumbersBGLight)
        
        view.addSubview(presentingChildVC.view)
        
        presentingChildVC.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
//            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupDelegate() {
        presentingChildVC.delegate = self
        numberPadController.numberPadDelegate = self
    }

    private func prepareNumberPad() {
        view.addSubview(numberPadController.view)
        
        if UIDevice.hasNotch {
        numberPadController.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 370)
        } else {
            numberPadController.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 280)
        }
    }
    
    private func showNumberPadAction() {
        UIView.animate(withDuration: 0.3) {
            if UIDevice.hasNotch {
            self.numberPadController.view.frame = CGRect(x: 0, y: UIScreen.height - 370 + 10, width: UIScreen.width, height: 370)
            } else {
                self.numberPadController.view.frame = CGRect(x: 0, y: UIScreen.height - 280, width: UIScreen.width, height: 280)
            }
        }
    }
    
    private func hideNumberPadAction() {
        UIView.animate(withDuration: 0.3) {
            if UIDevice.hasNotch {
            self.numberPadController.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 370)
            } else {
                self.numberPadController.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 280)
            }
        }
    }
}


extension NumberLayerController: NeedingControllerDelegate {
    
    func initializeNumberText() {
        numberPadController.numberText = ""
    }
    
    func presentNumberPad() {
        showNumberPadAction()
    }
    
    func hideNumberPad() {
        hideNumberPadAction()
    }
    
    func dismissNumberLayer() {
        parentDelegate?.dismissChildVC()
    }
}


extension NumberLayerController: CustomNumberPadDelegate {
    func completeAction() {
        print("complete tapped")
        childDelegate?.completeAction2()
    }
    
    
//    func fullPriceAction() {
//        childDelegate?.fullPriceAction()
//    }
    
    
    func numberPadViewShouldReturn() {
        hideNumberPadAction()
    }
    
    func numberPadView(updateWith numText: String) {
        print("updated value: \(numText)")
        childDelegate?.update(with: numText)
    }
}
