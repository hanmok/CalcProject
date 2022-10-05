//
//  PersonDetailFooter.swift
//  Calie
//
//  Created by Mac mini on 2022/09/14.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Then


protocol PersonDetailFooterDelegate: AnyObject {
    func addPersonAction()
}


class PersonDetailFooter: UICollectionReusableView {
    
    static let footerIdentifier = "FooterIdentifier"
    
    private let emptyView = UIView()
    
    weak var footerDelgate: PersonDetailFooterDelegate?
    
    private let addPersonBtn = UIButton().then {
        $0.setTitle(ASD.AddPerson.localized, for: .normal)

//        let titleColor = UIColor(white: 0.2, alpha: 1)
//        $0.setTitleColor(titleColor, for: .normal)
//        $0.setTitleColor(UserDefaultSetup.applyColor(onDark: UIColor(white: 0.8, alpha: 1), onLight: UIColor(white: 0.2, alpha: 1)), for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 8

//        $0.backgroundColor = ColorList().bgColorForExtrasLM
//        $0.backgroundColor = UserDefaultSetup.applyColor(onDark: .extrasBGMiddle, onLight: <#T##UIColor#>)
        $0.backgroundColor = UIColor.extrasBGMiddle
    }
    
    @objc func addPersonTapped(_ sender: UIButton) {
        footerDelgate?.addPersonAction()
    }
    
    private func setupAddtargets() {
        addPersonBtn.addTarget(self, action: #selector(addPersonTapped), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAddtargets()
        
        addSubview(emptyView)
        addSubview(addPersonBtn)
        
        addPersonBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
    
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(addPersonBtn.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




class Colors {
    var gl:CAGradientLayer!

    init() {
        let colorTop = UIColor(red: 192.0 / 255.0, green: 38.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 35.0 / 255.0, green: 2.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0).cgColor

        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}
