////
////  JosaTestingController.swift
////  Calie
////
////  Created by 핏투비 on 2022/09/05.
////  Copyright © 2022 Mac mini. All rights reserved.
////
//
//import Foundation
//import UIKit
//import SnapKit
//import Then
//
//class JosaTestingController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.addSubview(josaTF)
//        josaTF.delegate = self
//
//        josaTF.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
//    }
//
//    let josaTF = UITextField()
//
//
//}
//
//
//
//extension JosaTestingController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {        guard let text = textField.text else { return false }
//            self.josaTF.text = text + ( self.splitText(text: text) ? "을" : "를" )
//            return true
//        }
//}
//
//
//// func splitText(text: String) -> Bool { guard let text = text.last else { return false }
//
//extension JosaTestingController {
//    func splitText(text: String) -> Bool {
//        guard let text = text.last else { return false }
//        let val = UnicodeScalar(String(text))?.value
//        guard let value = val else { return false }
//
//        let x = (value - 0xac00) / 28 / 21
//        let y = ((value - 0xac00) / 28) % 21
//        let z = (value - 0xac00) % 28
//
//        print(x,y,z)//“안” -> 11 0 4
//
//        let i = UnicodeScalar(0x1100 + x) //초성
//        let j = UnicodeScalar(0x1161 + y) //중성
//        let k = UnicodeScalar(0x11a6 + 1 + z) //종성
//
//        guard let end = k else { return false}
//        if end.value == 4519 {
//            return false
//            }
//        return true
//    }
//}
////    출처: https://zeddios.tistory.com/493 [ZeddiOS:티스토리]
