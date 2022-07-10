//
//  MainTabController.swift
//  Caliy
//
//  Created by Mac mini on 2021/10/13.
//  Copyright © 2021 Mac mini. All rights reserved.
//

// tintColor: color for icon
// barTintColor: background color tab bar

import UIKit

class MainTabController: UITabBarController, UINavigationControllerDelegate {
    
    let updateUserDefaultNotification = Notification.Name(rawValue: NotificationKey.sendUpdatingUserDefaultNotification.rawValue)
    
    var userDefaultSetup = UserDefaultSetup()
    let colorList = ColorList()
    
    lazy var isDarkMode = userDefaultSetup.darkModeOn
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()

        print("viewDidLoad in MainTabController called")
        
        createObservers()
        configureColors()
        
        print("flag darkMode: \(isDarkMode)")
        print("userdefault: \(userDefaultSetup.darkModeOn)")
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabController.updateModes(notification:)), name: updateUserDefaultNotification, object: nil)
    }
    
    @objc func updateModes(notification: NSNotification) {
        guard let darkModeInfo = notification.userInfo?["isDarkOn"] as? Bool else {
            print("something is wrong with isDarkOn ")
            return
        }
        
        isDarkMode = darkModeInfo
        configureColors() // horrible cause all the views has setup to initial state!!
        
    }
    
    func configureViewControllers() {
        
        let calculator = templateNavigationController(
            unselectedImage: UIImage(systemName: "plus.slash.minus")!,
            selectedImage: UIImage(systemName: "plus.slash.minus")!,
            rootViewController: BaseViewController())

        let dutchController = DutchpayController(persistenceManager: PersistenceController.shared)
        dutchController.delegate = self
        
        
        let dutch = templateNavigationController(
            unselectedImage: UIImage(systemName: "divide.circle")!,
            selectedImage: UIImage(systemName: "divide.circle")!,
            rootViewController: dutchController)
//            rootViewController: uiNav)
        
//        let dutchNav = UINavigationController(rootViewController: dutch)
        
        let settingsVC = SettingsViewController()
        settingsVC.settingsDelegate = self
        
        let settings = templateNavigationController(
            unselectedImage: UIImage(systemName: "gear")!,
            selectedImage: UIImage(systemName: "gear")!,
            rootViewController: settingsVC)
        
        //        settings.delegate = self
        

        
#if DEBUG
//        viewControllers = [calculator, dutch, settings]
        viewControllers = [dutch, calculator, settings]
//        viewControllers = [dutchNav, calculator, settings]
#else
        viewControllers = [calculator, settings]
#endif
        
        
        //        viewControllers = [calculator, dutch, settings]
        
        
    }
    func configureColors() {
        
        if isDarkMode {
            UIView.transition(with: self.tabBar, duration: 0.4, options: .transitionCrossDissolve) {
                self.tabBar.barTintColor = self.colorList.bgColorForExtrasDM
            }
            
        } else {
            
            UIView.transition(with: self.tabBar, duration: 0.4, options: .transitionCrossDissolve) {
                self.tabBar.barTintColor = self.colorList.bgColorForExtrasDM
            }
        }
        
        if isDarkMode {
            self.tabBar.tintColor = .black
            self.tabBar.unselectedItemTintColor = UIColor(white: 0.4, alpha: 1)
            
            
        } else {
            self.tabBar.tintColor = .black
            self.tabBar.unselectedItemTintColor = UIColor(white: 0.6, alpha: 1)
        }
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
        if let validIndex = index {
            print("selected viewController: \(validIndex)")
        }
        if index == 0 {
            print("calculator ")
            viewController.viewDidLoad()
        } else {
            print("settingsVC")
        }
        print("hi..")
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        
      
            print("selected tabBarIndex: \(tabBarIndex)")
      
        
        print(#line, "didSelect in MainTabController triggered")
        if tabBarIndex == 0 {
            self.viewDidLoad()
        }
    }
    
//    tabbarcontr
}
//Thread 1: "-[UITabBarController setSelectedViewController:] only a view controller in the tab bar controller's list of view controllers can be selected."




extension MainTabController: SettingsViewControllerDelegate {
    func updateUserdefault() {
        print("updateUserDefaultTriggered in MainTabController")
        print("vcs: \(String(describing: viewControllers))")
        self.viewDidLoad()
    }
}

extension MainTabController: DutchpayControllerDelegate {
    func dutchpayController(shouldHideMainTab: Bool) {
//        tabBar.isHidden = true
        if shouldHideMainTab {
            tabBar.isHidden = true
        } else {
            tabBar.isHidden = false
        }
    }
    
    
}
