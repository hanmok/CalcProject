//
//  ReviewService.swift
//  Caliy
//
//  Created by Mac mini on 2020/08/09.
//  Copyright © 2020 Mac mini. All rights reserved.
//

import Foundation
import StoreKit

class ReviewService{
    
    private init(){}
    static let shared = ReviewService()
    
    func requestReview(){
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
