//
//  UIViewController+Ext.swift
//  Neat Calc
//
//  Created by Mac mini on 2020/07/17.
//  Copyright © 2020 hanmok. All rights reserved.
//
//
import UIKit
//import Toast_Swift
//import
import Toast_Swift
import SnapKit

let localizedStrings = LocalizedStringStorage()

extension UIViewController {
    func showAlert(title : String, message : String, handlerA : ((UIAlertAction) -> Void)?, handlerB : ((UIAlertAction) -> Void)?){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let actionA = UIAlertAction(title: localizedStrings.cancel, style: .cancel, handler: handlerA)
        
        let actionB = UIAlertAction(title: localizedStrings.delete, style: .destructive, handler: handlerB)
        
        alert.addAction(actionB)
        alert.addAction(actionA) // order independent.
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Need to implement using Queue.
    func showNewToast(msg: String, numOfLines: Int = 2) {
        let toastLabel = UILabel()
        toastLabel.sizeToFit()

        
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white

        toastLabel.font = UIFont.systemFont(ofSize: 16)
        toastLabel.textAlignment = .center

        toastLabel.text = msg
        toastLabel.alpha = 0.0
        
        toastLabel.layer.cornerRadius = 10;
       
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        self.view.addSubview(toastLabel)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        toastLabel.bottomAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        toastLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -70).isActive = true
        toastLabel.heightAnchor.constraint(equalToConstant: CGFloat(numOfLines * 25)).isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            
            toastLabel.transform = CGAffineTransform(translationX: 0, y: 150)
            toastLabel.alpha = 1.0
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 2.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                toastLabel.alpha = 0
                toastLabel.transform = toastLabel.transform.translatedBy(x: 0, y: -150)
            }) { (_) in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    func testCode() {
        let titleLabel = UILabel()
        let bodyLabel = UILabel()
        
        titleLabel.backgroundColor = .red
        bodyLabel.backgroundColor = .green
        
        
        titleLabel.numberOfLines = 0
        titleLabel.text = "Welcome to Company XYZ"
        titleLabel.font = UIFont(name: "Futura", size: 34)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.text = "BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY BODY  "
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        view.addSubview(stackView)
        
        // enables autolayout
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        
        
        // animations
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapAnimations)))
        
        print("animating")
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            
            titleLabel.transform = CGAffineTransform(translationX: -30, y: 0)
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                titleLabel.alpha = 0
                titleLabel.transform = titleLabel.transform.translatedBy(x: 0, y: -150)
                
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            
            bodyLabel.transform = CGAffineTransform(translationX: -30, y: 0)
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                bodyLabel.alpha = 0
                bodyLabel.transform = bodyLabel.transform.translatedBy(x: 0, y: -150)
                
            }
        }
        
        
        
    }
    
    @objc func handleTapAnimations() {
        
        
    }
    
    
//    func showToast(message : String ,defaultWidthSize : CGFloat, defaultHeightSize : CGFloat, widthRatio : Float, heightRatio : Float, fontsize : CGFloat) {
//
////        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width*CGFloat(0.5) - defaultWidthSize * CGFloat(widthRatio/2), y: self.view.frame.size.height*0.1, width: defaultWidthSize * CGFloat(widthRatio), height: defaultHeightSize * CGFloat(heightRatio)))
//        let toastLabel = UILabel()
////        toastLabel.sizeToFit()
////        toastLabel.resiz
////        toastLabel.alignmentRectInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
////        toastLabel.bounds = toastLabel.frame.insetBy(dx: 10, dy: 10)
//
//        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        toastLabel.textColor = UIColor.white
//        toastLabel.font = UIFont.systemFont(ofSize: fontsize)
//        toastLabel.textAlignment = .center
//        toastLabel.text = message
//        toastLabel.alpha = 1.0
//
//        toastLabel.numberOfLines = 1
//        toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds = true
//        toastLabel.numberOfLines = 0
//
//        self.view.addSubview(toastLabel)
//        toastLabel.translatesAutoresizingMaskIntoConstraints = false
//
////        toastLabel.snp.makeConstraints { make in
////            make.centerX.equalToSuperview()
////            make.width.equalTo(defaultWidthSize * CGFloat(widthRatio))
//////            make.bottom.equalTo(self.view.snp.top)
////            make.bottom.equalTo(self.view.snp.top).offset(50)
////            make.height.equalTo(30)
////        }
////
////        UIView.animate(withDuration: 2.0, delay: 2.0) {
////            print("animation started!")
////            // locate on the center
////            toastLabel.snp.updateConstraints { make in
////                make.bottom.equalTo(self.view.snp.top).offset(self.view.frame.size.height * 0.2)
////            }
////            toastLabel.alpha = 1.0
////            self.updateWithAnimation(duration: 0.3)
////
////        } completion: { completed in
////
////            if completed {
////                print("animation completed!")
////                UIView.animate(withDuration: 0.3, delay: 2.0) {
////                    // TODO: move to the top
////                    toastLabel.snp.updateConstraints { make in
////                        make.bottom.equalTo(self.view.snp.top)
////                    }
////                    self.updateWithAnimation(duration: 0.3)
////                    //                toastLabel.alpha = 0.0
////                } completion: { completed2 in
////                    print("animation completed 2")
////                    // TODO: remove from superView
////                    if completed2 {
//////                        toastLabel.removeFromSuperview()
////                    }
////                }
////            }
////        }
//
//
//
//
//        let titleLabel = UILabel()
//        let bodyLabel = UILabel()
//
//        titleLabel.backgroundColor = .red
//        bodyLabel.backgroundColor = .green
//
//        let stackView = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
//        stackView.axis = .vertical
//
//        stackView.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
//        view.addSubview(stackView)
//
//
//    }
    
    func updateWithAnimation(duration: CGFloat) {
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    

}


