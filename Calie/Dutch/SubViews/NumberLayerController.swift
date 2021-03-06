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


protocol NumberLayerDelegateToChild: AnyObject {
    func update(with numberText: String)
    func fullPriceAction()
}

protocol NumberLayerDelegateToSuperVC: AnyObject {
    func dismissChildVC()
}

class NumberLayerController : UIViewController {
    
    let backgroundColor: UIColor
    
    weak var childDelegate: NumberLayerDelegateToChild?
    weak var parentDelegate: NumberLayerDelegateToSuperVC?
    
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
        view.backgroundColor = .white
        
        view.addSubview(presentingChildVC.view)
        
        presentingChildVC.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupDelegate() {
        presentingChildVC.delegate = self
        numberPadController.delegate = self
    }

    private func prepareNumberPad() {
        view.addSubview(numberPadController.view)
        numberPadController.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 370)
    }
    
    private func showNumberPadAction() {
        UIView.animate(withDuration: 0.4) {
            self.numberPadController.view.frame = CGRect(x: 0, y: UIScreen.height - 370 + 10, width: UIScreen.width, height: 370)
        }
    }
    
    private func hideNumberPadAction() {
        UIView.animate(withDuration: 0.4) {
            self.numberPadController.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 370)
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
    
    func fullPriceAction() {
        childDelegate?.fullPriceAction()
    }
    
    
    func numberPadViewShouldReturn() {
        hideNumberPadAction()
    }
    
    func numberPadView(updateWith numText: String) {
        print("updated value: \(numText)")
        childDelegate?.update(with: numText)
    }
}
