//
//  MainTabController.swift
//  Caliy
//
//  Created by Mac mini on 2021/10/13.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        
//        var tabFrame = self.tabBar.frame
//        tabFrame.size.height = 200
//            tabFrame.origin.y = self.view.frame.size.height - 200
//            self.tabBar.frame = tabFrame
    }
    
    func configureViewControllers() {
        self.delegate = self
        let calculator = templateNavigationController(unselectedImage: UIImage(systemName: "plus.slash.minus")!, selectedImage: UIImage(systemName: "plus.slash.minus")!, rootViewController: BaseViewController())
        let settings = templateNavigationController(unselectedImage: UIImage(systemName: "gear")!, selectedImage: UIImage(systemName: "gear")!, rootViewController: SettingsViewController())
        
        viewControllers = [calculator, settings]
        tabBar.tintColor = .black
    }
    
    func templateNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        tabBar.isHidden = true // use this to hide tabBar from
//        tabBar.frame.size.height = 200
//        tabBar.frame.origin.y = view.frame.height - 200
        
        
    }
}

extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 0 {
            print("calculator ")
        } else {
            print("settingsVC")
        }
        return true
    }
}
