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


protocol LayerDelegateToChild: AnyObject {
    func update(with numberText: String)
}

protocol LayerDelegateToParent: AnyObject {
    func dismissChildVC()
}

class LayerController : UIViewController {
    
    let backgroundColor: UIColor
    
    weak var childDelegate: LayerDelegateToChild?
    weak var parentDelegate: LayerDelegateToParent?
    
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
        view.backgroundColor = UIColor(white: 0.3, alpha: 0.95)
//        view.backgroundColor = .cyan
        
        view.addSubview(presentingChildVC.view)
        
        presentingChildVC.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(150)
            make.height.equalToSuperview().dividedBy(2)
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


extension LayerController: NeedingControllerDelegate {
    func presentNumberPad() {
        showNumberPadAction()
    }
    
    func hideNumberPad() {
        hideNumberPadAction()
    }
    
    func dismissLayer() {
        parentDelegate?.dismissChildVC()
    }
}


extension LayerController: CustomNumberPadDelegate {
    
    func numberPadViewShouldReturn() {
        hideNumberPadAction()
    }
    
    func numberPadView(updateWith numText: String) {
        print("updated value: \(numText)")
        childDelegate?.update(with: numText)
    }
}