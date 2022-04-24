//
//  AddingBriefController.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/24.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit
import AddThen

class AddingBriefController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupLayout()
    }
    
    private let redView: UIView = {
        let v = UIView()
        v.backgroundColor = .red
        return v
    }()
    
    private let blueView: UIView = {
        let v = UIView()
        v.backgroundColor = .blue
        return v
    }()
    
    private let greenView: UIView = {
        let v = UIView()
        v.backgroundColor = .green
        return v
    }()
    
    private let magentaView: UIView = {
        let v = UIView()
        v.backgroundColor = .magenta
        return v
    }()
    
    private let placeLabel: UILabel = {
        let label = UILabel()
        label.text = "Where ?"
        return label
    }()
    
    private let placeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Where TF"
        return tf
    }()
    
   
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "How much ?"
        return label
    }()
    
    private let priceTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "price TF"
        return tf
    }()
    
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "When ?"
        return label
    }()
    
    private let timeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "\(Date()) TF"
        return tf
    }()
    
    private let placeContainer = UIStackView()
    private let priceContainer = UIStackView()
    private let timeContainer = UIStackView()
    private let someContainer : UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .magenta
        return stack
    }()
    
    private let confirmBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Next", for: .normal)
        btn.layer.borderColor = UIColor.blue.cgColor
        btn.layer.borderWidth = 1
        return btn
        
    }()
    
    private let cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.layer.borderColor = UIColor.magenta.cgColor
        btn.layer.borderWidth = 1
        return btn
        
    }()
    
    
    private func setupLayout() {
        

        
        view.backgroundColor = .brown
        
        let containerViews = [ placeContainer, priceContainer, timeContainer]
        
        
        containerViews.forEach { stackView  in
            view.addSubview(stackView)
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 10
        }
        
        [placeLabel, placeTextField].forEach { placeView in
//            placeContainer.addSubview(placeView)
            placeContainer.addArranged(placeView)
        }

        
        [priceLabel, priceTextField].forEach { priceView in
//            priceContainer.addSubview(priceView)
            priceContainer.addArranged(priceView)
        }
        
        [timeLabel, timeTextField].forEach { timeView in
//            timeContainer.addSubview(timeView)
            timeContainer.addArranged(timeView)
        }
        
        // Containers
        placeContainer.snp.makeConstraints { make in
//            make.left.top.right.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
            make.height.equalTo(50)
        }
        
        priceContainer.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(placeContainer.snp.bottom)
            make.height.equalTo(50)
        }
        
        timeContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(priceContainer.snp.bottom)
            make.height.equalTo(50)
        }
        
        
        let btns = [confirmBtn, cancelBtn]
        
        btns.forEach { btn in
            view.addSubview(btn)
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(10)
            make.bottom.equalTo(view).offset(-10)
            make.width.equalTo(view.snp.width).dividedBy(2)
            make.height.equalTo(50)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view).offset(-10)
            make.width.equalTo(view.snp.width).dividedBy(2)
            make.height.equalTo(50)
        }
    }
    

}
