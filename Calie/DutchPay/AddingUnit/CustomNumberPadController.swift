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
//    func numberPadView(_ tappedNumber: String)
    func numberPadViewShouldReturn()
//    func numberPadViewShouldDelete()
    func numberPadView(updateWith numTextInput: String)
}

//protocol CustomNumberController {
//    associatedtype tf
//}

class CustomNumberPadController: UIViewController {
//    typealias tf = UITextField
    
//    typealias tf
    public var numberText = "0" {
        didSet {
            numberText.applyNumberFormatter()
            delegate?.numberPadView(updateWith: numberText)
        }
    }
    
    static let colorList = ColorList()
    
    weak var delegate: CustomNumberPadDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 370)
        
        setupLayoutUp()
        setupAddTargets()
        view.backgroundColor = .blue
    }
    
    
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
    
    private let deleteBtn = UIButton().then { $0.setTitle("delete", for: .normal )
        $0.setTitleColor(.black, for: .normal)
    }
    
    private let deleteBar = UIView().then {
        $0.backgroundColor = UIColor.bgColorForExtrasLM
    }
    
    private let completeBtn = UIButton().then { $0.setTitle("완료", for: .normal )
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .bgColorForExtrasLM
    }
    

    
    private func setupAddTargets() {
        [num7, num8, num9,
         num4, num5, num6,
        num1, num2, num3,
        num0, num00, num000
        ].forEach { $0.addTarget(self, action: #selector(appendToNumberText(_:)), for: .touchUpInside)}
        
        completeBtn.addTarget(self, action: #selector(completeTapped(_:)), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
    }
    
    @objc func completeTapped(_ sender: UIButton) {
        print("complete Tapped!!")
        delegate?.numberPadViewShouldReturn()
    }
    
    @objc func deleteTapped(_ sender: UIButton) {
        print("complete Tapped!!")
        if numberText != "" {
            numberText.removeLast()
        }
    }
    
    
    @objc func appendToNumberText(_ sender: NumberButton) {
        print("tapped Btn wrapper: \(sender.wrapperString)")
        numberText += sender.wrapperString
        // update textFields belong to Controllers which conforms NumberPadDelegate
    }
    
    private func setupLayoutUp() {
        
        view.addSubview(deleteBar)
        deleteBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
//            make.bottom.equalTo(hor3Stack.snp.top)
            make.top.equalToSuperview()
        }
        
        deleteBar.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
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
        
        hor3Stack.snp.makeConstraints { make in
//            make.bottom.equalTo(hor2Stack.snp.top)
            make.top.equalTo(deleteBtn.snp.bottom)
        }
        
        hor2Stack.snp.makeConstraints { make in
//            make.bottom.equalTo(hor1Stack.snp.top)
            make.top.equalTo(hor3Stack.snp.bottom)
        }
        
        hor1Stack.snp.makeConstraints { make in
//            make.bottom.equalTo(hor0Stack.snp.top)
            make.top.equalTo(hor2Stack.snp.bottom)
        }
        
        hor0Stack.snp.makeConstraints { make in
//            make.bottom.equalTo(completeBtn.snp.top)
            make.top.equalTo(hor1Stack.snp.bottom)
        }
        
        
        // The bottom
        view.addSubview(completeBtn)
        completeBtn.snp.makeConstraints { make in
//            make.bottom.equalToSuperview()
            make.top.equalTo(hor0Stack.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(70)
        }
        
        
        
    }
    
    private func setupLayoutBottom() {

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
        // The bottom
        view.addSubview(completeBtn)
        completeBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(70)
        }
        
        
        hor0Stack.snp.makeConstraints { make in
            make.bottom.equalTo(completeBtn.snp.top)
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
        
        view.addSubview(deleteBar)
        deleteBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalTo(hor3Stack.snp.top)
        }
        
        deleteBar.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
