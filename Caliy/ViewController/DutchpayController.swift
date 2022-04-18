//
//  DutchpayController.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/19.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit

class DutchpayController: UIViewController {
    
    
    // MARK: - Properties
    
    let colorList = ColorList()
    
    
    let containerView: UIView = {
        let uiview = UIView()
        return uiview
    }()
    
    let historyBtn: UIButton = {
        let btn = UIButton()
        let circle = UIImageView(image: UIImage(systemName: "circle.fill")!)
        let innerImage = UIImageView(image: UIImage(systemName: "list.bullet")!)
        
        circle.tintColor = .white
        innerImage.tintColor = .black
        
        btn.addSubview(circle)
        circle.addSubview(innerImage)
        
        circle.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalTo(btn)
        }
        
        innerImage.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalTo(circle)
        }
        
        return btn
    }()
    
    private let plusBtn: UIButton = {
        let btn = UIButton()

        let inner = UIImageView(image: UIImage(systemName: "plus.circle"))
        
        btn.addSubview(inner)
        inner.snp.makeConstraints { make in
            make.center.equalTo(btn)
            make.width.equalTo(btn)
            make.height.equalTo(btn)
        }
        return btn
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
   
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colorList.bgColorForExtrasLM
        setupLayout()
        addTargets()
    }
    
    private func addTargets() {
        plusBtn.addTarget(self, action: #selector(addDutchpay(_:)), for: .touchUpInside)
    }
    
    @objc func addDutchpay(_ sender: UIButton) {
            print("btn pressed!")
    }
    
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(historyBtn)
        containerView.addSubview(plusBtn)
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        historyBtn.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(40)
            make.top.equalTo(containerView).offset(50)
        }
        
        plusBtn.snp.makeConstraints { make in
            make.width.height.equalTo(containerView.snp.width).dividedBy(3)
            make.center.equalTo(containerView)
        }
    }
}
