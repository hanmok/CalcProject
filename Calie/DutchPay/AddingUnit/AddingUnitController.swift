//
//  AddingUnitController.swift
//  Caliy
//
//  Created by Mac mini on 2022/04/28.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit
import Then

private let cellIdentifier = "CoreCell"

class AddingUnitController: UIViewController {

    let participants: [Person2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.7, alpha: 1)
        
        setupLayout()
    }

    private let spentToLabel = UILabel().then { $0.text = "Spent To"}
    private let spentTF = UITextField().then {
        $0.placeholder = "쭈꾸미 집"
        $0.textAlignment = .center
    }
    
    private let spentAmount = UILabel().then { $0.text = "Spent Amount"}
    private let spentAmountTF = UITextField().then {
        $0.placeholder = "10,000 원"
        $0.textAlignment = .center
        $0.keyboardType = .numberPad // need to be custom Pad
        
    }
    
    private let spentDateLabel = UILabel().then { $0.text = "When ?"}
    private let spentDatePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .compact
        $0.locale = Locale(identifier: "ko-KR")
        $0.datePickerMode = .dateAndTime
    }
    
    private let payCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = .white
        return cv
    }()
    
    private let cancelBtn = UIButton().then {
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        $0.addBorders(edges: [.top], color: .white)
        $0.addTarget(nil, action: #selector(cancelTapped(_:)), for: .touchUpInside)
    }
    
    private let confirmBtn = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.addBorders(edges: [.top, .left], color: .white)
        $0.addTarget(nil, action: #selector(nextTapped(_:)), for: .touchUpInside)
    }
    
    @objc func cancelTapped(_ sender: UIButton) {
        print("canel action")
    }
    
    @objc func nextTapped(_ sender: UIButton) {
        print("success action")
    }
    

    init(participants: [Person2]) {
        self.participants = participants
        super.init(nibName: nil, bundle: nil)
    }
    
    private func setupLayout() {
        [spentToLabel, spentTF,
         spentAmount, spentAmountTF,
         spentDateLabel, spentDatePicker,
         payCollectionView
        ].forEach { v in
            self.view.addSubview(v)
        }
        
        spentToLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
        
        spentTF.snp.makeConstraints { make in
            make.leading.equalTo(spentToLabel.snp.trailing).offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(30)
        }
        
        
        spentAmount.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(spentToLabel.snp.bottom).offset(20)
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalTo(spentAmount.snp.trailing).offset(20)
            make.top.equalTo(spentToLabel.snp.bottom).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(30)
        }
        
        

        spentDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(spentAmount.snp.bottom).offset(20)
            make.width.equalTo(70)
            make.height.equalTo(50)
        }
        
        spentDatePicker.snp.makeConstraints { make in
            make.leading.equalTo(spentDateLabel.snp.trailing).offset(20)
            make.top.equalTo(spentAmount.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        payCollectionView.register(PayCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        payCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(spentDateLabel.snp.bottom).offset(40)
            make.height.equalTo(60 * participants.count - 10)
        }
        
        payCollectionView.delegate = self
        payCollectionView.dataSource = self
        
        
        let btns = [confirmBtn, cancelBtn]
        
        btns.forEach { btn in
            view.addSubview(btn)
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.bottom.equalTo(view)
            make.width.equalTo(view.snp.width).dividedBy(2)
            make.height.equalTo(50)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view)
            make.width.equalTo(view.snp.width).dividedBy(2)
            make.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// need to divide AddingUnitController into Two, One with PayCollectionView

extension AddingUnitController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PayCollectionViewCell
        print("numberOfParticipants: \(participants.count)")
        let name = participants[indexPath.row].name
        let spentAmount: Double = Double(spentAmountTF.text ?? "0.0") ?? 0.0
        cell.viewModel = PayViewModel(pay: Payment(name: name,
                                                spentAmount: 0,
                                                attended: true,
                                                   spentTo: "", totalAmount: spentAmount))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}


class PayCollectionViewCell: UICollectionViewCell {
    
    var viewModel: PayViewModel? {
        didSet {
            self.loadView()
        }
    }
    
    
    private let nameLabel = UILabel().then { $0.backgroundColor = .green
        $0.textColor = .blue
    }

    private let spentAmountTF = UITextField().then { $0.text = "0"
        $0.keyboardType = .numberPad
//        $0.backgroundColor = .blue
        $0.backgroundColor = .brown
        $0.text = "222,222 원"
    }
    
    private let attendedBtn = UIButton().then {
        $0.setTitle("참석", for: .normal)
        $0.backgroundColor = .green
        $0.setTitleColor(.white, for: .normal)
    }
    
    private let fullPriceBtn = UIButton().then {
        $0.setTitle("전액", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.backgroundColor = .magenta
    }
    
    private func loadView() {
        print("load View triggered")
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.name
        spentAmountTF.text = viewModel.spentAmount
        print("attendedBtn title: \(viewModel.attendedBtnTitle)")
        attendedBtn.setTitle(viewModel.attendedBtnTitle, for: .normal)
        attendedBtn.setTitleColor(viewModel.attendedBtnColor, for: .normal)
//        attendedBtn.setTitleColor(.blue, for: .normal)
        
        fullPriceBtn.setTitle("전액", for: .normal)
        fullPriceBtn.setTitleColor(.green, for: .normal)
        
        print("load View ended")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [nameLabel, spentAmountTF, fullPriceBtn, attendedBtn].forEach { v in
            self.addSubview(v)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(20)
            make.height.equalTo(30)
            make.width.equalTo(70)
        }
        
        spentAmountTF.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing)
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(20)
        }
        
        fullPriceBtn.snp.makeConstraints { make in
            make.leading.equalTo(spentAmountTF.snp.trailing)
            make.width.equalTo(60)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
        
        attendedBtn.snp.makeConstraints { make in
            make.leading.equalTo(fullPriceBtn.snp.trailing)
            make.width.equalTo(60)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
    }
}


struct PayViewModel {
    private let pay: Payment
    
    var name: String { return pay.name }
    var spentAmount: String { return String(pay.spentAmount) + " 원"}
    var attendedBtnTitle: String { return pay.attended ? "참석" : "불참"}
    var attendedBtnColor: UIColor { return pay.attended ? .blue : .red }

    init(pay: Payment) {
        self.pay = pay
    }
}
    

