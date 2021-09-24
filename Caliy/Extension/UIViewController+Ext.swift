//
//  UIViewController+Ext.swift
//  Neat Calc
//
//  Created by Mac mini on 2020/07/17.
//  Copyright © 2020 hanmok. All rights reserved.
//
//
import UIKit
//let localizedStrings = LocalizedStringStorage()
let localizedStrings = LocalizedStringStorage()
extension UIViewController{
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
    
    
    func showToast(message : String , with numOfLines : Int, for sec : Double,defaultWidthSize : CGFloat, defaultHeightSize : CGFloat, widthRatio : Float,heightRatio : Float, fontsize : CGFloat) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width*CGFloat(0.5) - defaultWidthSize * CGFloat(widthRatio/2), y: self.view.frame.size.height*0.1, width: defaultWidthSize * CGFloat(widthRatio), height: defaultHeightSize * CGFloat(heightRatio)))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: fontsize)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.numberOfLines = numOfLines
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: sec, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}


