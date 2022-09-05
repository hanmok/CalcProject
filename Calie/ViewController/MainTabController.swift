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
import SnapKit
import Then


protocol MainTabDelegate: AnyObject {
//    func updateGatheringFromMainTab(with newGathering: Gathering)
}

class MainTabController: UITabBarController, UINavigationControllerDelegate {
    
    weak var mainToDutchDelegate: MainTabDelegate?
     
    let updateUserDefaultNotification = Notification.Name(rawValue: NotificationKey.sendUpdatingUserDefaultNotification.rawValue)
    
    var userDefaultSetup = UserDefaultSetup()
    let colorList = ColorList()
    
    var sideViewController: UINavigationController?
    
    
    lazy var isDarkMode = userDefaultSetup.darkModeOn
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()

        print("viewDidLoad in MainTabController called")
        
        createObservers()
        configureColors()
        
        print("flag darkMode: \(isDarkMode)")
        print("userdefault: \(userDefaultSetup.darkModeOn)")
        
        self.delegate = self
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

//        let dutchController = DutchpayController(persistenceManager: PersistenceController.shared, mainTabController: self)
        
        let dutchController = DutchpayController(mainTabController: self)
        
        dutchController.dutchToMainTapDelegate = self
        
        
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
        
                settings.delegate = self
        

        
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
    
    
    
    
//    private func showSideController(dutchManager: DutchManager) {
    private func showSideController() {
//        let sidevc = SideViewController(dutchManager: dutchManager)
        
        
        
        let sideVC = SideViewController()
        sideVC.sideDelegate = self
//        sideViewController = SideViewController(dutchManager: dutchManager)
        
        let sideInNavController = UINavigationController(rootViewController: sideVC)
//        sideViewController = sideVC
        sideViewController = sideInNavController
//        sideViewController?.sideDelegate = self
        guard let sideViewController = sideViewController else {
            return
        }
        
//        let sideInNavController = UINavigationController(rootViewController: sideVC)
        
        
       self.addChild(sideViewController)
       self.view.addSubview(sideViewController.view)
       sideViewController.didMove(toParent: self)
       
        sideViewController.view.frame = CGRect(x: -screenWidth / 1.5, y: 0, width: screenWidth / 1.5 , height: screenHeight)
        
        
        UIView.animate(withDuration: 0.3) {
            
            sideViewController.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth / 1.5, height: self.screenHeight)
            
        }
    } 
    
    private func hideSideController() {
        guard let sideViewController = sideViewController else { return }
    
        UIView.animate(withDuration: 0.3) {

            sideViewController.view.frame = CGRect(x: -self.screenWidth / 1.5, y: 0, width: self.screenWidth / 1.5, height: self.screenHeight)
            
        } completion: { done in
            if done {
                sideViewController.willMove(toParent: nil)
                sideViewController.view.removeFromSuperview()
                sideViewController.removeFromParent()
            }
        }
    }
}

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
print("tab flag 1")
        
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
        
        hideSideController()
        
        print("hi..")
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("tab flag 2")
        let tabBarIndex = tabBarController.selectedIndex
        
            print("selected tabBarIndex: \(tabBarIndex)")
      
        print(#line, "didSelect in MainTabController triggered")
        
        if tabBarIndex == 0 {
            self.viewDidLoad()
        }
        hideSideController()
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
    
    func shouldShowSideView(_ bool: Bool) {
        if bool {
            showSideController()
        } else {
            hideSideController()
        }
    }
    
    func shouldHideMainTab(_ bool: Bool) {
        tabBar.isHidden = bool
    }
}


extension MainTabController: SideControllerDelegate {
    
    
    func dismissSideVC(with gathering: Gathering) {
        
        hideSideController()
    }
}
