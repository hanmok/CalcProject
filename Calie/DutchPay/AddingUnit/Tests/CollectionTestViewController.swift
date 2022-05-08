////
////  CollectionTestViewController.swift
////  Calie
////
////  Created by Mac mini on 2022/05/08.
////  Copyright © 2022 Mac mini. All rights reserved.
////
//
//import UIKit
//import Then
//import SnapKit
//
//private let reuseId = "someId"
//class CollectionTestViewController: UIViewController {
//
//    private let payCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        return cv
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        payCollectionView.register(PersonDetailTestCell.self, forCellWithReuseIdentifier: reuseId)
//        payCollectionView.delegate = self
//        payCollectionView.dataSource = self
//        view.addSubview(payCollectionView)
//
//        payCollectionView.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview()
//        }
//    }
//
//    @objc func btnTapped(_ sender: UIButton) {
//        print("btn tapped!")
//    }
//}
//
//extension CollectionTestViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 5
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! PersonDetailTestCell
//        cell.attendedBtn.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: 30)
//    }
//}
