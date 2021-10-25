////
////  MVCSampleCode.swift
////  Caliy
////
////  Created by Mac mini on 2021/10/14.
////  Copyright © 2021 Mac mini. All rights reserved.
////
//
//import UIKit
//
//
//
//// Conform to the delegate protocol
//class SomeViewController: UIViewController, SomeViewDelegate {
//  var someView: SomeView!
//
//  func buttonWasPressed() {
//    // UIViewController can handle SomeView's button press.
//  }
//}
//
//// Simple delegate protocol.
//protocol SomeViewDelegate: AnyObject {
//  // Method used to tell the delegate that the button was pressed in the subview.
//  // You can add parameters here as you like.
//  func buttonWasPressed()
//}
//
//class SomeView: UIView {
//  // Define the view's delegate.
//  weak var delegate: SomeViewDelegate?
//
//  // Assuming you already have a button.
//  var button: UIButton!
//
//  // Once your view & button has been initialized, configure the button's target.
//  func configureButton() {
//    // Set your target
//    self.button.addTarget(self, action: #selector(someButtonPressed(_:)), for: .touchUpInside)
//  }
//
//  @objc func someButtonPressed(_ sender: UIButton) {
//    delegate?.buttonWasPressed()
//  }
//}
//
