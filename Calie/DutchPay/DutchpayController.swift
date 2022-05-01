//
//  DutchpayController.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/19.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit

class DutchpayController: UIViewController {
    
    
    // MARK: - Properties
    
    let persistenceManager: PersistenceManager
    
    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    func createUser() {
        let user = User(context: persistenceManager.context)
        user.name = "andrew"
        
        persistenceManager.save()
        
    }
    */
    
    /*
    func getUsers() {
        
//        guard let users = try! persistenceManager.context.fetch(User.fetchRequest()) as? [User] else { return }
        
        let users = persistenceManager.fetch(User.self)
        users.forEach({ print($0.name) })
        
    }
     */
    
    
    
    var userDefaultSetup = UserDefaultSetup()
    
    let colorList = ColorList()
    
    
    let containerView: UIView = {
        let uiview = UIView()
        return uiview
    }()
    
    let historyBtn: UIButton = {
        let btn = UIButton()
        let circle = UIImageView(image: UIImage(systemName: "circle.fill")!)
        let innerImage = UIImageView(image: UIImage(systemName: "list.bullet")!)
        
        circle.tintColor = .white
        innerImage.tintColor = .black
        
        btn.addSubview(circle)
        circle.addSubview(innerImage)
        
        circle.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalTo(btn)
        }
        
        innerImage.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalTo(circle)
        }
        
        return btn
    }()
    
    private let plusBtn: UIButton = {
        let btn = UIButton()

        let inner = UIImageView(image: UIImage(systemName: "plus.circle"))
        
        btn.addSubview(inner)
        inner.snp.makeConstraints { make in
            make.center.equalTo(btn)
            make.width.equalTo(btn)
            make.height.equalTo(btn)
        }
        return btn
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    private let blurredView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
   
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = colorList.bgColorForExtrasLM
        
        setupLayout()
        addTargets()
        
        presentAddingController()
    }
    
    private func addTargets() {
        plusBtn.addTarget(self, action: #selector(addDutchpay(_:)), for: .touchUpInside)
    }
    
    @objc func addDutchpay(_ sender: UIButton) {
            print("btn pressed!")
        
        presentAddingController()
    }
    
    func presentAddingController() {
        
        view.addSubview(blurredView)
        blurredView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        
        
//        let addingBriefController = AddingBriefController()
        let addingBriefController = ParticipantsController()
        
        let some = UINavigationController(rootViewController: addingBriefController)
       
//        UINavigationBar.appearance().backgroundColor = .black
        UINavigationBar.appearance().backgroundColor = .cyan
                
        UINavigationBar.appearance().barTintColor = .red
//        UINavigationBar.appearance().prefersLargeTitles = true // make large title
        UINavigationBar.appearance().tintColor = .magenta // chevron Color
//        UINavigationItem.
//        UINavigationBar.
        
        self.addChild(some)
        
        self.view.addSubview(some.view)
        
        some.view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(view).dividedBy(1.2)
            make.height.equalTo(view).dividedBy(1.5)
        }
        
        some.view.layer.cornerRadius = 10
        
        some.didMove(toParent: self)
    }
    
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(historyBtn)
        containerView.addSubview(plusBtn)
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        historyBtn.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(40)
            make.top.equalTo(containerView).offset(50)
        }
        
        plusBtn.snp.makeConstraints { make in
            make.width.height.equalTo(containerView.snp.width).dividedBy(3)
            make.center.equalTo(containerView)
        }
        
        // Color
        if userDefaultSetup.darkModeOn {
            view.backgroundColor = colorList.bgColorForExtrasDM
            containerView.backgroundColor = colorList.bgColorForEmptyAndNumbersDM
        } else {
            view.backgroundColor = colorList.bgColorForExtrasLM
            containerView.backgroundColor = colorList.bgColorForEmptyAndNumbersLM
        }
    }
    
    
    
}
