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

protocol MainTabToDutchDelegate: AnyObject {
    func updateGatheringFromMainTab(with newGathering: Gathering)
    func clearifyBlurredView()
    
    func renameTriggered(target: Gathering)
    func deleteTriggered(target: Gathering)
    func initializeCurrentGathering()

}

class MainTabController: UITabBarController, UINavigationControllerDelegate {
    
    weak var mainToDutchDelegate: MainTabToDutchDelegate?
     
    let updateUserDefaultNotification = Notification.Name(rawValue: NotificationKey.sendUpdatingUserDefaultNotification.rawValue)
    
    var userDefaultSetup = UserDefaultSetup()
    
    let colorList = ColorList()
    
    var sideViewController: UINavigationController?
    
    lazy var isDarkMode = userDefaultSetup.darkModeOn
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()

        print("viewDidLoad in MainTabController called")
        print("initialTapScreen: \(userDefaultSetup.initialViewIdx)")
        
        createObservers()
        configureColors()
        
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
        configureColors()
    }
    
    func configureViewControllers() {
        
        let calculator = templateNavigationController(
            unselectedImage: UIImage(systemName: "plus.slash.minus")!,
            selectedImage: UIImage(systemName: "plus.slash.minus")!,
            rootViewController: BaseViewController())
        
        let dutchController = DutchpayController(mainTabController: self)
        
        dutchController.dutchToMainTapDelegate = self
        
        let dutch = templateNavigationController(
            unselectedImage: UIImage(systemName: "divide.circle")!,
            selectedImage: UIImage(systemName: "divide.circle")!,
            rootViewController: dutchController)

        
        let settingsVC = SettingsViewController()
//        settingsVC.settingsDelegate = self
        settingsVC.delegate = self
        let settings = templateNavigationController(
            unselectedImage: UIImage(systemName: "gear")!,
            selectedImage: UIImage(systemName: "gear")!,
            rootViewController: settingsVC)
        
        settings.delegate = self
        
        viewControllers = [calculator, dutch, settings]
        
    }

// 대체 뭐하는 코드일까?
    func configureColors() {
        print("configureColors called")
        
        // 필요 없는 코드 같은데 ?
//        if isDarkMode {
//            UIView.transition(with: self.tabBar, duration: 0.4, options: .transitionCrossDissolve) {
////                self.tabBar.barTintColor = self.colorList.bgColorForExtrasDM
//                self.tabBar.barTintColor = .magenta
//            }
//        } else {
//            UIView.transition(with: self.tabBar, duration: 0.4, options: .transitionCrossDissolve) {
//
//
////                self.tabBar.barTintColor =
//            }
//        }
        
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
//        nav.navigationBar.tintColor = .black
        nav.navigationBar.tintColor = .magenta
        return nav
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func showSideController() {

        let sideVC = SideViewController()
        sideVC.sideDelegate = self
        
        let sideInNavController = UINavigationController(rootViewController: sideVC)
        sideViewController = sideInNavController
        guard let sideViewController = sideViewController else {
            return
        }
        
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
    
    // Tab 바꿀 때 호출됨.
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("tab flag 2")
        let tabBarIndex = tabBarController.selectedIndex

        userDefaultSetup.initialViewIdx = tabBarIndex
            print("selected tabBarIndex: \(tabBarIndex)")
      
        print(#line, "didSelect in MainTabController triggered")
    
        hideSideController()
    }
}

//Thread 1: "-[UITabBarController setSelectedViewController:] only a view controller in the tab bar controller's list of view controllers can be selected."





extension MainTabController: SettingsViewControllerDelegate {
    func hideTabbar() {
        print("tabbar flag, is hidden!")
        tabBar.isHidden = true
        
    }
    
    func showTabbar() {
        tabBar.isHidden = false
    }
    
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
   
    func dismissSideVC(with gathering: Gathering?) {
        
        mainToDutchDelegate?.clearifyBlurredView()
        
        mainToDutchDelegate?.updateGatheringFromMainTab(with: gathering!)
            hideSideController()
            print("hideSideController called")
    }
    
    func renameGathering(gathering: Gathering) {
        mainToDutchDelegate?.renameTriggered(target: gathering)
    }
    
    func deleteGathering(gathering: Gathering) {
        mainToDutchDelegate?.deleteTriggered(target: gathering)
    }
    
    func removeLastGathering() {
        mainToDutchDelegate?.clearifyBlurredView()
        hideSideController()
        mainToDutchDelegate?.initializeCurrentGathering()
    }
}
