//
//  CustomNumberPadController.swift
//  Calie
//
//  Created by Mac mini on 2022/05/04.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit
import Then

protocol CustomNumberPadDelegate: AnyObject {
    // update Text to numberText
    func updateCost()
}

class CustomNumberPadController: UIViewController {
    
    public var numberText = "0" {
        didSet {
            numberText.applyNumberFormatter()
        }
    }
    
    weak var delegate: CustomNumberPadDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupAddTargets()
    }
    
    private let someBtn = NumberButton("0")
    private let num0 = NumberButton("0")
    private let num00 = NumberButton("00")
    private let num000 = NumberButton("000")
    private let num1 = NumberButton("1")
    private let num2 = NumberButton("2")
    private let num3 = NumberButton("3")
    private let num4 = NumberButton("4")
    private let num5 = NumberButton("5")
    private let num6 = NumberButton("6")
    private let num7 = NumberButton("7")
    private let num8 = NumberButton("8")
    private let num9 = NumberButton("9")
    
    private let deleteBtn = UIButton().then { $0.setTitle("delete", for: .normal ) }
    private let completeBtn = UIButton().then { $0.setTitle("완료", for: .normal ) }
    
    private func setupAddTargets() {
        [num0, num00, num000].forEach { $0.addTarget(self, action: #selector(appendToNumberText(_:)), for: .touchUpInside)}
    }
    
    @objc func appendToNumberText(_ sender: NumberButton) {
        numberText += sender.wrapperString
//        applyNumberFormatter(numberText)
//        numberText = numberText.applyNumberFormatter()
        numberText.applyNumberFormatter()
    }
    
//    private func applyNumberFormatter(_ num: String) -> String{
//        guard let intNum = Int(num) else {return ""}
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//
//        if let result = numberFormatter.string(for: intNum) {
//            return result
//        }
//      return num
//    }
    
    private func setupLayout() {

        let hor3Stack = UIStackView(arrangedSubviews: [num7, num8, num9])
        let hor2Stack = UIStackView(arrangedSubviews: [num4, num5, num6])
        let hor1Stack = UIStackView(arrangedSubviews: [num1, num2, num3])
        let hor0Stack = UIStackView(arrangedSubviews: [num0, num00, num000])
        
        [hor0Stack, hor1Stack, hor2Stack, hor3Stack].forEach {
            view.addSubview($0)
            $0.distribution = .fillEqually
            $0.spacing = 0
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(60)
            }
        }
        
        
        hor0Stack.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
        hor1Stack.snp.makeConstraints { make in
            make.bottom.equalTo(hor0Stack.snp.top)
        }
        hor2Stack.snp.makeConstraints { make in
            make.bottom.equalTo(hor1Stack.snp.top)
        }
        hor3Stack.snp.makeConstraints { make in
            make.bottom.equalTo(hor2Stack.snp.top)
        }
        
        [completeBtn, deleteBtn].forEach {
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.height.equalTo(60)
                make.bottom.equalTo(hor3Stack.snp.top)
            }
        }
        
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.equalTo(40)
        }
        
        completeBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(deleteBtn.snp.leading)
        }
    }
}
